USE [QLTiec]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:      Antigravity
-- Create date: 2026-06-06
-- Description: API Xóa Mềm Phiếu Thu / Quyết Toán (Soft Delete với kiểm tra Trạng thái)
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[API_XoaPhieuThu]
    @Ids NVARCHAR(MAX), -- Chuỗi danh sách DocumentID phân tách bằng dấu phẩy
    @UserName VARCHAR(50) = 'System'
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        IF (@Ids IS NULL OR @Ids = '')
        BEGIN
            SELECT -1 AS code, N'Thiếu danh sách mã phiếu thu (Ids)' AS msg;
            RETURN;
        END

        -- Kiểm tra xem có phiếu thu nào đã chốt không
        DECLARE @HasLocked INT = 0;
        
        IF EXISTS (
            SELECT 1 FROM tbmk_Phieuthu 
            WHERE (DocumentID IN (SELECT LTRIM(RTRIM(value)) FROM string_split(@Ids, ',')) 
               OR Sohopdong IN (SELECT LTRIM(RTRIM(value)) FROM string_split(@Ids, ','))) 
              AND Status IN ('SIGNED', 'COMPLETED')
        )
        BEGIN
            SET @HasLocked = 1;
        END

        IF @HasLocked = 1
        BEGIN
            SELECT -1 AS code, N'Lỗi: Tuyệt đối không được xóa phiếu thu đã thanh toán hoặc đã chốt!' AS msg;
            RETURN;
        END

        BEGIN TRANSACTION;

        -- Thực hiện soft delete
        UPDATE tbmk_Phieuthu
        SET IsDeleted = 1, 
            DeletedAt = GETDATE(), 
            DeletedBy = @UserName
        WHERE DocumentID IN (SELECT LTRIM(RTRIM(value)) FROM string_split(@Ids, ',')) 
           OR Sohopdong IN (SELECT LTRIM(RTRIM(value)) FROM string_split(@Ids, ','));
              
        DECLARE @RowsAffected INT = @@ROWCOUNT;

        COMMIT TRANSACTION;

        IF @RowsAffected > 0
            SELECT 0 AS code, N'Xóa thành công (Soft Delete) ' + CAST(@RowsAffected AS VARCHAR) + N' phiếu thu/quyết toán.' AS msg;
        ELSE
            SELECT -1 AS code, N'Không tìm thấy phiếu thu/quyết toán phù hợp để xóa.' AS msg;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        SELECT -1 AS code, N'Lỗi xóa phiếu thu: ' + ERROR_MESSAGE() AS msg;
    END CATCH
END
GO
