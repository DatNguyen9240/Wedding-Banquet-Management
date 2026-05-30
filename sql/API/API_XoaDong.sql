IF OBJECT_ID('API_XoaDong', 'P') IS NOT NULL
    DROP PROCEDURE API_XoaDong;
GO

CREATE PROCEDURE [dbo].[API_XoaDong]
    @List VARCHAR(50),
    @Ids NVARCHAR(MAX) -- Chuỗi danh sách các ID cần xoá, ví dụ: 'ID1,ID2,ID3'
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @TableName VARCHAR(100);
    DECLARE @PrimaryKey VARCHAR(100);
    
    -- Lấy thông tin Bảng và Khóa chính
    -- Nâng cấp: Dùng SaveTableName (Bảng gốc) để GHI, nếu không có thì xài TableName (View)
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

    BEGIN TRY
        -- Sinh câu SQL xoá động sử dụng IN (chỉ dành cho SQL Server >= 2016)
        DECLARE @sql NVARCHAR(MAX) = 
            'DELETE FROM ' + QUOTENAME(@TableName) + 
            ' WHERE ' + QUOTENAME(@PrimaryKey) + ' IN (SELECT value FROM string_split(@DeleteIds, '',''))';
            
        -- Chạy lệnh
        EXEC sp_executesql @sql, N'@DeleteIds NVARCHAR(MAX)', @DeleteIds = @Ids;
        
        DECLARE @RowsAffected INT = @@ROWCOUNT;
        
        IF @RowsAffected > 0
            SELECT 0 AS code, N'Xóa thành công ' + CAST(@RowsAffected AS VARCHAR) + N' dòng khỏi bảng ' + @TableName AS msg;
        ELSE
            SELECT -1 AS code, N'Không tìm thấy dữ liệu (ID: ' + @Ids + N') để xóa trong bảng ' + @TableName AS msg;
    END TRY
    BEGIN CATCH
        SELECT -1 AS code, N'Lỗi xóa dữ liệu: ' + ERROR_MESSAGE() AS msg;
    END CATCH
END
GO
