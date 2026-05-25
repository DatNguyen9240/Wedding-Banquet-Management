IF OBJECT_ID('API_DanhSachTaiKhoan', 'P') IS NOT NULL
    DROP PROCEDURE API_DanhSachTaiKhoan;
GO

CREATE PROCEDURE API_DanhSachTaiKhoan
    @Keyword nvarchar(100) = NULL,
    @Page int = 1,
    @Limit int = 15
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        UserName,
        HoTen,
        UserGroupID,
        Disable,
        EmployeeID,
        Manager
    FROM SY_User
    WHERE (@Keyword IS NULL OR @Keyword = '' 
           OR UserName LIKE '%' + @Keyword + '%')
    ORDER BY UserName ASC
    OFFSET (ISNULL(@Page, 1) - 1) * ISNULL(@Limit, 15) ROWS
    FETCH NEXT ISNULL(@Limit, 15) ROWS ONLY;
END
GO
