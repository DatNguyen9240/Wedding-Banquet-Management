USE [QLTiec]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
  Read model for the quotation list.  The quotation procedure may still return
  additional DOCX/report fields, but this view is the one stable schema used
  by the shared DynamicFormEngine grid.
*/
CREATE OR ALTER VIEW dbo.v_DanhSachBaoGia AS
SELECT
    h.Sohopdong,
    h.Sobiennhan,
    h.Makh,
    CASE
        WHEN NULLIF(k.Tenchure, '') IS NOT NULL
         AND NULLIF(k.Tencodau, '') IS NOT NULL
            THEN k.Tenchure + N' & ' + k.Tencodau
        ELSE ISNULL(k.Tenkh, N'Khach vang lai')
    END AS KhachHang,
    CASE
        WHEN NULLIF(k.Tenchure, '') IS NOT NULL
         AND NULLIF(k.Tencodau, '') IS NOT NULL
            THEN k.Tenchure + N' & ' + k.Tencodau
        ELSE ISNULL(k.Tenkh, N'Khach vang lai')
    END AS TenKhachHang,
    h.Ngaytochuc AS NgayToChuc,
    CONVERT(VARCHAR(10), h.Ngaytochuc, 103) AS NgayToChucFormat,
    ISNULL(h.Tongtienhopdong, 0) AS TongTien,
    CASE
        WHEN h.IsHuy = 1 THEN N'Da huy'
        WHEN h.IsKetthuc = 1 THEN N'Da quyet toan'
        ELSE N'Dang xu ly'
    END AS TrangThai,
    STUFF((
        SELECT N', ' + s.Tensanhtiec
        FROM dbo.tbmk_Hopdongsanhtiec hs
        INNER JOIN dbo.dmSanhtiec s ON s.Sanhtiecid = hs.Sanhtiecid
        WHERE hs.Sohopdong = h.Sohopdong
        ORDER BY hs.IsSanhchinh DESC, hs.Sanhtiecid
        FOR XML PATH(''), TYPE
    ).value('.', 'NVARCHAR(MAX)'), 1, 2, '') AS SanhDat
FROM dbo.tbmk_Hopdong h
LEFT JOIN dbo.dmkhachhang k ON k.Makh = h.Makh
WHERE ISNULL(h.IsDeleted, 0) = 0;
GO
