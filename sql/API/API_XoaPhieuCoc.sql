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
    @DocumentIDs NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        IF (@DocumentIDs IS NULL OR @DocumentIDs = '')
        BEGIN
            SELECT 0 AS [Success], N'Thiếu danh sách mã chứng từ (DocumentIDs)' AS [Message];
            RETURN;
        END

        BEGIN TRANSACTION;

        -- Khóa dòng trong bảng cha trước để đồng bộ thứ tự khóa (tránh Deadlock với các hàm Save/Update)
        DECLARE @Dummy INT;
        SELECT @Dummy = 1 
        FROM tbmk_Biennhancoccho WITH (XLOCK, ROWLOCK)
        WHERE DocumentID IN (SELECT LTRIM(RTRIM(value)) FROM string_split(@DocumentIDs, ','));

        -- 1. Xóa sảnh phụ/chính liên kết với phiếu cọc
        DELETE FROM tbmk_Biennhancocchosanhtiec 
        WHERE DocumentID IN (SELECT LTRIM(RTRIM(value)) FROM string_split(@DocumentIDs, ','));

        -- 2. Xóa phiếu cọc
        DELETE FROM tbmk_Biennhancoccho 
        WHERE DocumentID IN (SELECT LTRIM(RTRIM(value)) FROM string_split(@DocumentIDs, ','));
        
        DECLARE @RowsAffected INT = @@ROWCOUNT;
        
        COMMIT TRANSACTION;
        
        SELECT 1 AS [Success], N'Đã xóa ' + CAST(@RowsAffected AS VARCHAR) + N' phiếu cọc thành công' AS [Message];
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        SELECT 0 AS [Success], ERROR_MESSAGE() AS [Message];
    END CATCH
END
GO
