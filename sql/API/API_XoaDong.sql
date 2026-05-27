IF OBJECT_ID('API_XoaDong', 'P') IS NOT NULL
    DROP PROCEDURE API_XoaDong;
GO

CREATE PROCEDURE [dbo].[API_XoaDong]
    @FormName VARCHAR(50),
    @Ids NVARCHAR(MAX) -- Chuỗi danh sách các ID cần xoá, ví dụ: 'ID1,ID2,ID3'
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @TableName VARCHAR(100);
    DECLARE @PrimaryKey VARCHAR(100);
    
    -- Lấy thông tin Bảng và Khóa chính
    SELECT 
        @TableName = TableName,
        @PrimaryKey = PrimaryKey
    FROM SY_FrmLstTbl 
    WHERE FormID = @FormName;

    IF @TableName IS NULL OR @TableName = ''
    BEGIN
        SELECT -1 AS code, N'Chưa cấu hình TableName cho form ' + @FormName AS msg;
        RETURN;
    END

    IF @PrimaryKey IS NULL OR @PrimaryKey = ''
    BEGIN
        SELECT -1 AS code, N'Chưa cấu hình PrimaryKey cho form ' + @FormName AS msg;
        RETURN;
    END

    -- Sinh câu SQL xoá động sử dụng IN (chỉ dành cho string_split nếu SQL version hỗ trợ, 
    -- Hoặc dùng CHARINDEX để kiểm tra)
    -- Câu SQL đơn giản nhất xoá nhiều dòng (Dành cho SQL Server >= 2016):
    DECLARE @sql NVARCHAR(MAX) = 
        'DELETE FROM ' + QUOTENAME(@TableName) + 
        ' WHERE ' + QUOTENAME(@PrimaryKey) + ' IN (SELECT value FROM string_split(@DeleteIds, '',''))';
        
    -- Chạy lệnh
    EXEC sp_executesql @sql, N'@DeleteIds NVARCHAR(MAX)', @DeleteIds = @Ids;
    
    SELECT 0 AS code, N'Xóa thành công khỏi bảng ' + @TableName AS msg;
END
GO
