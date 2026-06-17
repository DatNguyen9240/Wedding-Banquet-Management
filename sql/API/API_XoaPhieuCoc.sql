USE [QLTiec]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:      Antigravity
-- Create date: 2026-06-01
-- Description: API Xóa Nhiều Phiếu Cọc (Batch Delete)
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[API_XoaPhieuCoc]
    @DocumentIDs NVARCHAR(MAX) = NULL,
    @UserName VARCHAR(50) = 'System'
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        IF (@DocumentIDs IS NULL OR @DocumentIDs = '')
        BEGIN
            SELECT -1 AS [code], 0 AS [Success], N'Thiếu danh sách mã chứng từ (DocumentIDs)' AS [Message], N'Thiếu danh sách mã chứng từ (DocumentIDs)' AS [msg];
            RETURN;
        END

        BEGIN TRANSACTION;

        -- Khóa dòng trong bảng cha trước để đồng bộ thứ tự khóa (tránh Deadlock với các hàm Save/Update)
        DECLARE @Dummy INT;
        SELECT @Dummy = 1 
        FROM tbmk_Biennhancoccho WITH (XLOCK, ROWLOCK)
        WHERE DocumentID IN (SELECT LTRIM(RTRIM(value)) FROM string_split(@DocumentIDs, ','));

        -- Kiểm tra xem có phiếu cọc nào đã chốt (Đã ký, Đã quyết toán, Đã lên Hợp đồng, Đã Hủy) không
        -- IF EXISTS (
        --     SELECT 1 
        --     FROM tbmk_Biennhancoccho
        --     WHERE DocumentID IN (SELECT LTRIM(RTRIM(value)) FROM string_split(@DocumentIDs, ','))
        --       AND (Status IN ('SIGNED', 'COMPLETED') OR IsKetthuc = 1 OR IsHuy = 1)
        -- )
        -- BEGIN
        --     ROLLBACK TRANSACTION;
        --     SELECT -1 AS [code], 0 AS [Success], N'Lỗi: Tuyệt đối không được xóa phiếu cọc đã chốt hoặc đã lên Hợp đồng!' AS [Message], N'Lỗi: Tuyệt đối không được xóa phiếu cọc đã chốt hoặc đã lên Hợp đồng!' AS [msg];
        --     RETURN;
        -- END

        -- Thực hiện Soft Delete
        UPDATE tbmk_Biennhancoccho
        SET IsDeleted = 1,
            DeletedAt = GETDATE(),
            DeletedBy = ISNULL(@UserName, 'System')
        WHERE DocumentID IN (SELECT LTRIM(RTRIM(value)) FROM string_split(@DocumentIDs, ','));
        
        DECLARE @RowsAffected INT = @@ROWCOUNT;
        
        COMMIT TRANSACTION;
        
        SELECT 0 AS [code], 1 AS [Success], N'Đã xóa ' + CAST(@RowsAffected AS VARCHAR) + N' phiếu cọc thành công' AS [Message], N'Đã xóa ' + CAST(@RowsAffected AS VARCHAR) + N' phiếu cọc thành công' AS [msg];
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        SELECT -1 AS [code], 0 AS [Success], ERROR_MESSAGE() AS [Message], ERROR_MESSAGE() AS [msg];
    END CATCH
END
GO
