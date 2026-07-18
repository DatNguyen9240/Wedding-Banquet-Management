USE [QLTiec]
GO

CREATE OR ALTER VIEW dbo.v_DanhSachQuyetToan
AS
SELECT
    pt.DocumentID,
    pt.DocumentDate,
    pt.Sohopdong,
    h.Tentiec,
    h.Makh,
    k.Tenkh AS TenKhachHang,
    pt.Nguoinop,
    pt.Manv,
    pt.TongtienHoaDon,
    pt.Tongtiencoc,
    pt.Thanhtoan,
    pt.Conlai,
    pt.IsKetthuc,
    pt.Ghichu,
    pt.IsDeleted
FROM dbo.tbmk_Phieuthu pt
LEFT JOIN dbo.tbmk_Hopdong h ON h.Sohopdong = pt.Sohopdong
LEFT JOIN dbo.dmkhachhang k ON k.Makh = h.Makh;
GO
