IF OBJECT_ID('API_DanhSachNhanVien', 'P') IS NOT NULL
    DROP PROCEDURE API_DanhSachNhanVien;
GO

CREATE PROCEDURE API_DanhSachNhanVien
    @Keyword nvarchar(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        NHANVIENID,
        TENNHANVIEN,
        IsGioitinh,
        DIENTHOAI,
        NGAYSINH,
        DIACHI,
        NGAYVAOLAM,
        ISDANGHI,
        Bophanid
    FROM DMNHANVIEN
    WHERE 
        (@Keyword IS NULL OR @Keyword = '' 
         OR TENNHANVIEN LIKE N'%' + @Keyword + '%' 
         OR DIENTHOAI LIKE '%' + @Keyword + '%' 
         OR NHANVIENID LIKE '%' + @Keyword + '%')
    ORDER BY TENNHANVIEN ASC;
END
GO
