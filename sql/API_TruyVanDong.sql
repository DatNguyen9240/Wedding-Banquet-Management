CREATE PROCEDURE [dbo].[API_TruyVanDong]
    @FormName VARCHAR(50),
    @q NVARCHAR(200) = '' -- Tham số tìm kiếm (có thể có hoặc không)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @TableName VARCHAR(100);
    
    -- Lấy thông tin Bảng vật lý từ cấu hình form
    SELECT @TableName = TableName FROM SY_FrmLstTbl WHERE FormID = @FormName;

    IF @TableName IS NULL OR @TableName = ''
    BEGIN
        SELECT -1 AS code, N'Chưa cấu hình TableName cho form ' + @FormName AS msg;
        RETURN;
    END

    -- Sinh câu SQL động query thẳng vào bảng
    DECLARE @sql NVARCHAR(MAX) = 'SELECT * FROM ' + QUOTENAME(@TableName);
    
    -- Mở rộng thêm: Nếu có truyền @q, tìm kiếm trên mọi cột text (hoặc tuỳ bạn tự viết thêm)
    -- Ví dụ cơ bản:
    -- IF @q <> ''
    -- BEGIN
    --    @sql = @sql + ' WHERE TênCột LIKE ''%'' + @kw + ''%'''
    -- END

    -- Chạy lệnh
    EXEC sp_executesql @sql, N'@kw NVARCHAR(200)', @kw = @q;
END
GO
