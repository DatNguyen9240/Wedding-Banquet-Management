CREATE OR ALTER PROCEDURE [dbo].[API_DanhSachQuyetToan]
    @Keyword NVARCHAR(100) = NULL,
    @DocumentID VARCHAR(50) = NULL,
    @Sohopdong VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        pt.DocumentID,
        pt.DocumentDate,
        pt.Sohopdong,
        hd.Tentiec,
        kh.Tenkh,
        pt.Nguoinop,
        pt.Manv,
        pt.TongtienHoaDon,
        pt.Tongtiencoc,
        pt.Thanhtoan,
        pt.Conlai,
        pt.IsKetthuc,
        pt.IsHoaDon,
        pt.IsXacNhanKeToan,
        pt.Ghichu
    FROM tbmk_Phieuthu pt
    LEFT JOIN tbmk_Hopdong hd ON pt.Sohopdong = hd.Sohopdong
    LEFT JOIN dmkhachhang kh ON hd.Makh = kh.Makh
    WHERE 
        (@DocumentID IS NULL OR @DocumentID = '' OR pt.DocumentID = @DocumentID)
        AND (@Sohopdong IS NULL OR @Sohopdong = '' OR pt.Sohopdong = @Sohopdong)
        AND (@Keyword IS NULL OR @Keyword = ''
             OR pt.DocumentID LIKE '%' + @Keyword + '%'
             OR pt.Sohopdong LIKE '%' + @Keyword + '%'
             OR pt.Nguoinop LIKE N'%' + @Keyword + '%'
             OR kh.Tenkh LIKE N'%' + @Keyword + '%')
    ORDER BY pt.DocumentDate DESC;
END
GO
