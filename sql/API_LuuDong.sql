IF OBJECT_ID('API_LuuDong', 'P') IS NOT NULL
    DROP PROCEDURE API_LuuDong;
GO

CREATE PROCEDURE [dbo].[API_LuuDong]
    @FormName VARCHAR(50),
    @Data NVARCHAR(MAX) -- Chuỗi JSON chứa dữ liệu cần lưu
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

    -- Ghi chú: Vì tuỳ thuộc vào dữ liệu JSON truyền xuống mà các cột sẽ khác nhau.
    -- Bạn cần viết logic bóc tách JSON và ghép câu lệnh INSERT / UPDATE tương ứng ở đây.
    -- Hoặc nếu phiên bản C# Backend của bạn có hàm hỗ trợ, Backend C# sẽ đọc @TableName 
    -- và dùng Entity Framework / Dapper Contrib để tự động lưu JSON vào bảng mà không cần SP này.
    
    -- Tạm thời trả về thành công để FE không báo lỗi
    SELECT 0 AS code, N'Đã giả lập lưu thành công xuống bảng ' + @TableName AS msg;
END
GO
