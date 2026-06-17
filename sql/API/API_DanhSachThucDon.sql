USE [QLTiec]
GO


/****** Object:  StoredProcedure [dbo].[API_DanhSachThucDon] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('dbo.API_DanhSachThucDon', 'P') IS NOT NULL
    DROP PROCEDURE dbo.API_DanhSachThucDon;
GO

/*
  API Lấy danh sách Món Ăn / Thức Uống / Dịch Vụ
  Phân loại chính xác theo NhomhangID:
    - IsChay  = 1: nhóm thực đơn chay (hậu tố '4': KhaiVi4, MonChinh4...)
    - IsDrink = 1: nhóm đồ uống (Bia, NuocNgot, NuocSuoi...)
    - IsDichVu= 1: nhóm dịch vụ/trang trí/nhân sự (DichVuCuoi, TrangTri, NhanSu...)
*/
CREATE PROCEDURE [dbo].[API_DanhSachThucDon]
    @Keyword NVARCHAR(100) = '',
    @PhanLoai NVARCHAR(50) = '', 
    @IsChay INT = -1             
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        h.Mahang AS MaMon,
        h.Tenhang AS TenMon,
        ISNULL(n.Tennhomhang, N'Khác') AS PhanLoai,
        ISNULL(dg.Dongia, 0) AS DonGia,
        h.GoiThucDonID AS GoiThucDonID,

        -- IsChay: nhóm thực đơn chay (nhóm kết thúc '4', không phải đồ uống/dịch vụ)
        CASE WHEN h.Nhomhangid IN (
            'KhaiVi4','MonChinh4','ComMiLau4','MonRau4','Sup4','TrangMieng4','TruocTiec4'
        ) THEN 1 ELSE 0 END AS IsChay,

        -- IsDrink: nhóm đồ uống các loại
        CASE WHEN h.Nhomhangid IN (
            'Bia','Bia4','QTBIA',
            'NuocNgot','NuocNgot4','QTTU',
            'NuocSuoi','NuocSuoi4',
            'QTTB'
        ) THEN 1 ELSE 0 END AS IsDrink,

        -- IsDichVu: nhóm dịch vụ, trang trí, nhân sự, tính phí, phụ thu...
        CASE WHEN h.Nhomhangid IN (
            'DichVuCuoi','DichVuCuoi4',
            'DichVuHoiNghi','DichVuHoiNghi4',
            'DichVuKhac','DichVuKhac4',
            'QTDV',
            'TrangTri','TrangTri4',
            'NhanSu','NhanSu4',
            'TinhPhi','TinhPhi4',
            'QTKO','QTCL','QTPV','QTVA'
        ) THEN 1 ELSE 0 END AS IsDichVu,

        ISNULL(h.IsMacDinhHopDong, 0) AS IsMacDinhHopDong,
        1 AS TrangThai
    FROM 
        [dbo].[dmHanghoa] h
    LEFT JOIN 
        [dbo].[dmNhomhang] n ON h.Nhomhangid = n.NhomhangID
    OUTER APPLY (
        -- Lấy đơn giá mới nhất của mặt hàng
        SELECT TOP 1 Dongia 
        FROM [dbo].[dmHanghoadg] 
        WHERE Mahang = h.Mahang 
        ORDER BY Ngay DESC, DateCreate DESC
    ) dg
    WHERE 
        ISNULL(h.IsNgungSuDung, 0) = 0
        AND (@Keyword = '' OR h.Tenhang LIKE N'%' + @Keyword + '%' OR h.Mahang LIKE '%' + @Keyword + '%')
        AND (@PhanLoai = '' OR n.Tennhomhang = @PhanLoai)
        AND (@IsChay = -1 
             OR (@IsChay = 1 AND h.Nhomhangid IN ('KhaiVi4','MonChinh4','ComMiLau4','MonRau4','Sup4','TrangMieng4','TruocTiec4'))
             OR (@IsChay = 0 AND h.Nhomhangid NOT IN ('KhaiVi4','MonChinh4','ComMiLau4','MonRau4','Sup4','TrangMieng4','TruocTiec4')))
    ORDER BY 
        CASE 
            WHEN h.Nhomhangid IN ('KhaiVi','KhaiVi4')                                   THEN 1
            WHEN h.Nhomhangid IN ('TruocTiec','TruocTiec4')                              THEN 2
            WHEN h.Nhomhangid IN ('Sup','Sup4')                                          THEN 3
            WHEN h.Nhomhangid IN ('MonChinh','MonChinh4')                                THEN 4
            WHEN h.Nhomhangid IN ('ComMiLau','ComMiLau4')                                THEN 5
            WHEN h.Nhomhangid IN ('MonRau','MonRau4')                                    THEN 6
            WHEN h.Nhomhangid IN ('TrangMieng','TrangMieng4')                            THEN 7
            WHEN h.Nhomhangid IN ('Bia','Bia4','QTBIA')                                  THEN 8
            WHEN h.Nhomhangid IN ('NuocNgot','NuocNgot4','QTTU')                         THEN 9
            WHEN h.Nhomhangid IN ('NuocSuoi','NuocSuoi4','QTTB')                         THEN 10
            WHEN h.Nhomhangid IN ('DichVuCuoi','DichVuCuoi4')                            THEN 11
            WHEN h.Nhomhangid IN ('DichVuHoiNghi','DichVuHoiNghi4')                      THEN 12
            WHEN h.Nhomhangid IN ('DichVuKhac','DichVuKhac4','QTDV')                     THEN 13
            WHEN h.Nhomhangid IN ('TrangTri','TrangTri4')                                THEN 14
            WHEN h.Nhomhangid IN ('NhanSu','NhanSu4')                                    THEN 15
            WHEN h.Nhomhangid IN ('TinhPhi','TinhPhi4','QTCL','QTPV','QTVA','QTKO')      THEN 16
            ELSE 17
        END ASC,
        h.Tenhang ASC;
END
GO
