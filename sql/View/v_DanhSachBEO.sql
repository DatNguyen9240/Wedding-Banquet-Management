USE [QLTiec]
GO

CREATE OR ALTER VIEW dbo.v_DanhSachBEO
AS
SELECT
    h.Sohopdong,
    h.Sobiennhan,
    h.Makh,
    k.Tenkh AS TenKhachHang,
    h.Ngaytochuc AS NgayToChuc,
    h.Nhamngay,
    h.Loaitiecid AS LoaiTiecID,
    h.Thoigianid AS ThoiGianID,
    ISNULL(h.SobanManchinhthuc, 0) + ISNULL(h.SobanChaychinhthuc, 0) AS SoBan,
    STUFF((
        SELECT N', ' + s.Tensanhtiec
        FROM dbo.tbmk_Hopdongsanhtiec hs
        INNER JOIN dbo.dmSanhtiec s ON s.Sanhtiecid = hs.Sanhtiecid
        WHERE hs.Sohopdong = h.Sohopdong
        ORDER BY hs.IsSanhchinh DESC, s.Tensanhtiec
        FOR XML PATH(''), TYPE
    ).value('.', 'NVARCHAR(MAX)'), 1, 2, N'') AS SanhDat,
    h.Ghichu,
    h.IsDeleted
FROM dbo.tbmk_Hopdong h
LEFT JOIN dbo.dmkhachhang k ON k.Makh = h.Makh;
GO

