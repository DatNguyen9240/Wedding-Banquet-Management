USE [QLTiec]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:      Antigravity
-- Create date: 2026-06-06
-- Description: API Xóa Mềm Phụ Lục Thay Đổi (Soft Delete với kiểm tra Trạng thái)
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[API_XoaThayDoi]
    @Ids NVARCHAR(MAX), -- Chuỗi danh sách Sothaydoi phân tách bằng dấu phẩy
    @UserName VARCHAR(50) = 'System'
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        IF (@Ids IS NULL OR @Ids = '')
        BEGIN
            SELECT -1 AS code, N'Thiếu danh sách số phụ lục (Ids)' AS msg;
            RETURN;
        END

        -- Tách @Ids thành bảng thông qua XML (tương thích SQL Server 2008+, không cần STRING_SPLIT)
        DECLARE @XmlIds XML = CAST('<i>' + REPLACE(@Ids, ',', '</i><i>') + '</i>' AS XML);

        -- Kiểm tra xem có phiếu thay đổi nào đã chốt hoặc đã ký duyệt không
        IF EXISTS (
            SELECT 1 
            FROM tbmk_Thaydoi
            WHERE Sothaydoi IN (
                SELECT LTRIM(RTRIM(n.value('.', 'NVARCHAR(100)'))) FROM @XmlIds.nodes('/i') AS T(n)
            )
              AND (Status IN ('SIGNED', 'APPROVED') OR IsKetthuc = 1)
        )
        BEGIN
            SELECT -1 AS code, N'Lỗi: Tuyệt đối không được xóa phụ lục thay đổi đã duyệt hoặc đã ký nhận!' AS msg;
            RETURN;
        END

        BEGIN TRANSACTION;

        -- Thực hiện Soft Delete
        UPDATE tbmk_Thaydoi
        SET IsDeleted = 1,
            DeletedAt = GETDATE(),
            DeletedBy = ISNULL(@UserName, 'System')
        WHERE Sothaydoi IN (
            SELECT LTRIM(RTRIM(n.value('.', 'NVARCHAR(100)'))) FROM @XmlIds.nodes('/i') AS T(n)
        );

        DECLARE @RowsAffected INT = @@ROWCOUNT;

        COMMIT TRANSACTION;

        IF @RowsAffected > 0
            SELECT 0 AS code, N'Xóa thành công (Soft Delete) ' + CAST(@RowsAffected AS VARCHAR) + N' phụ lục thay đổi.' AS msg;
        ELSE
            SELECT -1 AS code, N'Không tìm thấy phụ lục thay đổi phù hợp để xóa.' AS msg;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        SELECT -1 AS code, N'Lỗi xóa phụ lục thay đổi: ' + ERROR_MESSAGE() AS msg;
    END CATCH
END
GO
