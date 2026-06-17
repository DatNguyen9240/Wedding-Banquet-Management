USE [QLTiec]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:      Antigravity
-- Create date: 2026-06-06
-- Description: API Xóa Mềm Hợp Đồng (Soft Delete với kiểm tra Trạng thái)
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[API_XoaHopDong]
    @Ids NVARCHAR(MAX), -- Chuỗi danh sách Sohopdong phân tách bằng dấu phẩy
    @UserName VARCHAR(50) = 'System'
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        IF (@Ids IS NULL OR @Ids = '')
        BEGIN
            SELECT -1 AS code, N'Thiếu danh sách số hợp đồng (Ids)' AS msg;
            RETURN;
        END

        -- Kiểm tra xem có hợp đồng nào đang ở trạng thái "Đã Ký", "Đã Quyết Toán" hoặc "Chốt cứng" không
        IF EXISTS (
            SELECT 1 
            FROM tbmk_Hopdong
            WHERE Sohopdong IN (SELECT LTRIM(RTRIM(value)) FROM string_split(@Ids, ','))
              AND (Status IN ('SIGNED', 'COMPLETED') OR IsKetthuc = 1 OR IsHuy = 1)
        )
        BEGIN
            SELECT -1 AS code, N'Lỗi: Tuyệt đối không được xóa hợp đồng đã chốt (Đã ký hoặc Quyết toán). Hệ thống yêu cầu lưu trữ chứng từ pháp lý!' AS msg;
            RETURN;
        END

        BEGIN TRANSACTION;

        -- Thực hiện Soft Delete
        UPDATE tbmk_Hopdong
        SET IsDeleted = 1,
            DeletedAt = GETDATE(),
            DeletedBy = ISNULL(@UserName, 'System')
        WHERE Sohopdong IN (SELECT LTRIM(RTRIM(value)) FROM string_split(@Ids, ','));

        DECLARE @RowsAffected INT = @@ROWCOUNT;

        COMMIT TRANSACTION;

        IF @RowsAffected > 0
            SELECT 0 AS code, N'Xóa thành công (Soft Delete) ' + CAST(@RowsAffected AS VARCHAR) + N' hợp đồng.' AS msg;
        ELSE
            SELECT -1 AS code, N'Không tìm thấy hợp đồng phù hợp để xóa.' AS msg;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        SELECT -1 AS code, N'Lỗi xóa hợp đồng: ' + ERROR_MESSAGE() AS msg;
    END CATCH
END
GO
