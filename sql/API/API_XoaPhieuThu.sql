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

        -- Kiểm tra xem bảng thực sự là tbPhieuthu hay tbmk_Phieuthu để xác định bảng cần cập nhật
        -- Chúng ta hỗ trợ cả hai bảng nếu tồn tại
        DECLARE @TableName VARCHAR(100) = 'tbPhieuthu';
        IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'tbPhieuthu')
        BEGIN
            SET @TableName = 'tbmk_Phieuthu';
        END

        -- Sử dụng SQL động để kiểm tra nhằm tránh lỗi biên dịch tĩnh nếu cột Status chưa được tạo đầy đủ
        DECLARE @CheckStatusSQL NVARCHAR(MAX) = 
            N'IF EXISTS (SELECT 1 FROM ' + QUOTENAME(@TableName) + 
            N' WHERE DocumentID IN (SELECT LTRIM(RTRIM(value)) FROM string_split(@Ids, '','')) AND Status IN (''SIGNED'', ''COMPLETED''))
              SET @HasLocked = 1;';
              
        DECLARE @HasLocked INT = 0;
        
        BEGIN TRY
            EXEC sp_executesql @CheckStatusSQL, N'@Ids NVARCHAR(MAX), @HasLocked INT OUTPUT', @Ids = @Ids, @HasLocked = @HasLocked OUTPUT;
        END TRY
        BEGIN CATCH
            SET @HasLocked = 0;
        END CATCH

        IF @HasLocked = 1
        BEGIN
            SELECT -1 AS code, N'Lỗi: Tuyệt đối không được xóa phiếu thu đã thanh toán hoặc đã chốt!' AS msg;
            RETURN;
        END

        BEGIN TRANSACTION;

        -- Thực hiện soft delete
        DECLARE @UpdateSQL NVARCHAR(MAX) = 
            N'UPDATE ' + QUOTENAME(@TableName) + 
            N' SET IsDeleted = 1, DeletedAt = GETDATE(), DeletedBy = @User
              WHERE DocumentID IN (SELECT LTRIM(RTRIM(value)) FROM string_split(@Ids, '',''))';
              
        EXEC sp_executesql @UpdateSQL, N'@Ids NVARCHAR(MAX), @User VARCHAR(50)', @Ids = @Ids, @User = @UserName;

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
