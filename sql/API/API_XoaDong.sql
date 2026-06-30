USE [QLTiec]
GO

IF OBJECT_ID('API_XoaDong', 'P') IS NOT NULL
    DROP PROCEDURE API_XoaDong;
GO

CREATE PROCEDURE [dbo].[API_XoaDong]
    @List VARCHAR(50),
    @Ids NVARCHAR(MAX), -- Chuỗi danh sách các ID cần xoá, ví dụ: 'ID1,ID2,ID3'
    @UserName VARCHAR(50) = 'System'
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @TableName VARCHAR(100);
    DECLARE @PrimaryKey VARCHAR(100);
    
    -- Lấy thông tin Bảng và Khóa chính
    SELECT 
        @TableName = COALESCE(SaveTableName, TableName),
        @PrimaryKey = PrimaryKey
    FROM SY_FrmLstTbl 
    WHERE FormID = @List;

    IF @TableName IS NULL OR @TableName = ''
    BEGIN
        SELECT -1 AS code, N'Chưa cấu hình TableName cho form ' + @List AS msg;
        RETURN;
    END

    IF @PrimaryKey IS NULL OR @PrimaryKey = ''
    BEGIN
        SELECT -1 AS code, N'Chưa cấu hình PrimaryKey cho form ' + @List AS msg;
        RETURN;
    END

    -- ==========================================================
    -- XỬ LÝ XÓA ĐỘNG CHUNG CHO TẤT CẢ CÁC BẢNG KHÁC (TỰ ĐỘNG NHẬN DIỆN SOFT/HARD DELETE)
    -- ==========================================================
    BEGIN TRY
        -- Kiểm tra xem bảng có chứa cột IsDeleted hay không để tự động áp dụng Soft Delete
        DECLARE @HasIsDeleted BIT = 0;
        DECLARE @HasDeletedAt BIT = 0;
        DECLARE @HasDeletedBy BIT = 0;

        IF EXISTS (
            SELECT 1 
            FROM sys.columns 
            WHERE object_id = OBJECT_ID(@TableName) 
              AND name = 'IsDeleted'
        )
        BEGIN
            SET @HasIsDeleted = 1;
        END

        IF EXISTS (
            SELECT 1 
            FROM sys.columns 
            WHERE object_id = OBJECT_ID(@TableName) 
              AND name = 'DeletedAt'
        )
        BEGIN
            SET @HasDeletedAt = 1;
        END

        IF EXISTS (
            SELECT 1 
            FROM sys.columns 
            WHERE object_id = OBJECT_ID(@TableName) 
              AND name = 'DeletedBy'
        )
        BEGIN
            SET @HasDeletedBy = 1;
        END

        DECLARE @sql NVARCHAR(MAX) = '';

        IF @HasIsDeleted = 1
        BEGIN
            -- Thực hiện Soft Delete động
            SET @sql = 'UPDATE ' + QUOTENAME(@TableName) + ' SET IsDeleted = 1';
            
            IF @HasDeletedAt = 1
                SET @sql = @sql + ', DeletedAt = GETDATE()';
                
            IF @HasDeletedBy = 1
                SET @sql = @sql + ', DeletedBy = @User';
                
            SET @sql = @sql + ' WHERE ' + QUOTENAME(@PrimaryKey) + ' IN (SELECT LTRIM(RTRIM(value)) FROM string_split(@DeleteIds, '',''))';
                       
            EXEC sp_executesql @sql, N'@DeleteIds NVARCHAR(MAX), @User VARCHAR(50)', @DeleteIds = @Ids, @User = @UserName;
            
            DECLARE @RowsSoft INT = @@ROWCOUNT;
            SELECT 0 AS code, N'Xóa thành công (Soft Delete) ' + CAST(@RowsSoft AS VARCHAR) + N' dòng khỏi bảng ' + @TableName AS msg;
        END
        ELSE
        BEGIN
            -- Thực hiện Hard Delete động (xóa cứng)
            SET @sql = 'DELETE FROM ' + QUOTENAME(@TableName) + 
                       ' WHERE ' + QUOTENAME(@PrimaryKey) + ' IN (SELECT LTRIM(RTRIM(value)) FROM string_split(@DeleteIds, '',''))';
                       
            EXEC sp_executesql @sql, N'@DeleteIds NVARCHAR(MAX)', @DeleteIds = @Ids;
            
            DECLARE @RowsHard INT = @@ROWCOUNT;
            SELECT 0 AS code, N'Xóa thành công ' + CAST(@RowsHard AS VARCHAR) + N' dòng khỏi bảng ' + @TableName AS msg;
        END
    END TRY
    BEGIN CATCH
        SELECT -1 AS code, N'Lỗi xóa dữ liệu: ' + ERROR_MESSAGE() AS msg;
    END CATCH
END
GO
