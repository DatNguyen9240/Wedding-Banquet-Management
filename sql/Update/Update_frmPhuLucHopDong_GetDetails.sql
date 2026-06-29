USE [QLTiec]
GO
/****** Object:  StoredProcedure [dbo].[API_PhuLucHopDong_Detail]    Script Date: 17/06/2026 9:15:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[API_PhuLucHopDong_Detail]
    @Keyword NVARCHAR(250),
    @Sothaydoi NVARCHAR(50) = ''
AS
BEGIN
    SET NOCOUNT ON;

    IF @Sothaydoi = '' OR @Sothaydoi = 'NULL' OR @Sothaydoi = '{Sothaydoi}' SET @Sothaydoi = NULL;
    DECLARE @SearchStr VARCHAR(50) = COALESCE(@Sothaydoi, @Keyword);

    SELECT 
        -- Mã chính
        pl.Sothaydoi AS [SoPhuLuc],
        pl.Sohopdong AS [Sohopdong],
        pl.LanThayDoi AS [LanDieuChinh],
        pl.Ghichu AS [NoiDungPhuLuc],
        
        -- Ngày lập Phụ lục
        RIGHT('0' + CAST(DAY(pl.Ngaythaydoi) AS VARCHAR), 2) AS [NgayLapPL],
        RIGHT('0' + CAST(MONTH(pl.Ngaythaydoi) AS VARCHAR), 2) AS [ThangLapPL],
        CAST(YEAR(pl.Ngaythaydoi) AS VARCHAR) AS [NamLapPL],

        -- Ngày lập Hợp đồng
        RIGHT('0' + CAST(DAY(hd.Ngayhopdong) AS VARCHAR), 2) AS [NgayLapHD],
        RIGHT('0' + CAST(MONTH(hd.Ngayhopdong) AS VARCHAR), 2) AS [ThangLapHD],
        CAST(YEAR(hd.Ngayhopdong) AS VARCHAR) AS [NamLapHD],

        -- Ngày tổ chức Dương lịch
        CONVERT(VARCHAR(10), ISNULL(pl.NgayToChucTD, hd.Ngaytochuc), 103) AS [NgayToChuc],
        RIGHT('0' + CAST(DAY(ISNULL(pl.NgayToChucTD, hd.Ngaytochuc)) AS VARCHAR), 2) AS [NgayToChucDay],
        RIGHT('0' + CAST(MONTH(ISNULL(pl.NgayToChucTD, hd.Ngaytochuc)) AS VARCHAR), 2) AS [ThangToChuc],
        CAST(YEAR(ISNULL(pl.NgayToChucTD, hd.Ngaytochuc)) AS VARCHAR) AS [NamToChuc],

        -- Ngày tổ chức Âm lịch
        CASE 
            WHEN CHARINDEX('/', ISNULL(pl.NhamNgayTD, hd.Nhamngay)) > 0 
                THEN SUBSTRING(ISNULL(pl.NhamNgayTD, hd.Nhamngay), 1, CHARINDEX('/', ISNULL(pl.NhamNgayTD, hd.Nhamngay)) - 1)
            ELSE ISNULL(pl.NhamNgayTD, hd.Nhamngay)
        END AS [NgayToChucAmLich],
        CASE 
            WHEN CHARINDEX('/', ISNULL(pl.NhamNgayTD, hd.Nhamngay)) > 0 
                THEN CASE 
                    WHEN CHARINDEX('/', ISNULL(pl.NhamNgayTD, hd.Nhamngay), CHARINDEX('/', ISNULL(pl.NhamNgayTD, hd.Nhamngay)) + 1) > 0 
                        THEN SUBSTRING(ISNULL(pl.NhamNgayTD, hd.Nhamngay), CHARINDEX('/', ISNULL(pl.NhamNgayTD, hd.Nhamngay)) + 1, CHARINDEX('/', ISNULL(pl.NhamNgayTD, hd.Nhamngay), CHARINDEX('/', ISNULL(pl.NhamNgayTD, hd.Nhamngay)) + 1) - CHARINDEX('/', ISNULL(pl.NhamNgayTD, hd.Nhamngay)) - 1)
                    ELSE SUBSTRING(ISNULL(pl.NhamNgayTD, hd.Nhamngay), CHARINDEX('/', ISNULL(pl.NhamNgayTD, hd.Nhamngay)) + 1, LEN(ISNULL(pl.NhamNgayTD, hd.Nhamngay)))
                END
            ELSE '...'
        END AS [ThangToChucAmLich],
        CASE 
            WHEN CHARINDEX('/', ISNULL(pl.NhamNgayTD, hd.Nhamngay)) > 0 AND CHARINDEX('/', ISNULL(pl.NhamNgayTD, hd.Nhamngay), CHARINDEX('/', ISNULL(pl.NhamNgayTD, hd.Nhamngay)) + 1) > 0
                THEN SUBSTRING(ISNULL(pl.NhamNgayTD, hd.Nhamngay), CHARINDEX('/', ISNULL(pl.NhamNgayTD, hd.Nhamngay), CHARINDEX('/', ISNULL(pl.NhamNgayTD, hd.Nhamngay)) + 1) + 1, LEN(ISNULL(pl.NhamNgayTD, hd.Nhamngay)))
            ELSE '...'
        END AS [NamToChucAmLich],

        -- Thiết lập sảnh & Giờ
        ISNULL((SELECT TOP 1 s.Tensanhtiec FROM tbmk_Hopdongsanhtiec hs INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid WHERE hs.Sohopdong = pl.Sohopdong), N'Chưa xác định') AS [TenSanhTiec],
        ISNULL(hd.GioDienRaSuKien, N'Chưa xác định') AS [TiecGioBatDau],
        ISNULL((SELECT TOP 1 Tenloaitiec FROM dmLoaihinhtiec WHERE Loaitiecid = hd.Loaitiecid), N'TIỆC CƯỚI') AS [LoaiHinhSuKien],

        -- Khách hàng (Bên B)
        kh.Tenkh AS [BenBTenDaiDien],
        kh.CMNDDaiDien AS [BenBCCCD],
        kh.Diachi AS [BenBDiaChi],
        kh.Dienthoai AS [BenBDienThoai],
        ISNULL(kh.Tenchure, '') + N' & ' + ISNULL(kh.Tencodau, '') AS [BenBTenChuTiec],

        -- Công ty Bên A (từ bảng SY_Setup)
        (SELECT TOP 1 CodeValue FROM [dbo].[SY_Setup] WHERE CodeID = 'BenATenCongTy') AS [BenATenCongTy],
        (SELECT TOP 1 CodeValue FROM [dbo].[SY_Setup] WHERE CodeID = 'BenADiaChi') AS [BenADiaChi],
        (SELECT TOP 1 CodeValue FROM [dbo].[SY_Setup] WHERE CodeID = 'BenASDT') AS [BenASDT],
        COALESCE(
            (SELECT TOP 1 CodeValue FROM [dbo].[SY_Setup] WHERE CodeID = 'HNNguoiDaiDien'),
            (SELECT TOP 1 CodeValue FROM [dbo].[SY_Setup] WHERE CodeID = 'BenADaiDien')
        ) AS [BenADaiDien],
        (SELECT TOP 1 CodeValue FROM [dbo].[SY_Setup] WHERE CodeID = 'HNChucVuNguoiDaiDien') AS [BenAChucVu],

        -- Nhân viên Bên A
        nv.Tennv AS [BenANhanVienPhuTrach],
        nv.DIENTHOAI AS [BenASDTNhanVien],

        -- Quy mô bàn & Đơn giá
        ISNULL(pl.QuyMoBanTuTD, pl.QuyMoBanTu) AS [QuyMoBanTu],
        ISNULL(pl.QuyMoBanDenTD, pl.QuyMoBanDen) AS [QuyMoBanDen],
        ISNULL(pl.SoKhachTrenBanTD, pl.SoKhachTrenBan) AS [SoKhachTrenBan],
        -- Đơn giá bàn: trả '' khi = 0 để không hiện '0VNĐ/bàn' trong template
        CASE WHEN ISNULL(ISNULL(pl.DonGiaBanTiecTD, pl.DonGiaBanTiec), 0) > 0
             THEN FORMAT(ISNULL(pl.DonGiaBanTiecTD, pl.DonGiaBanTiec), 'N0', 'vi-VN')
             ELSE ''
        END AS [DonGiaBanTiec],

        -- Bàn tiệc
        ISNULL(NULLIF(pl.SobanManchinhthuc, 0), hd.SobanManchinhthuc) AS [SobanManchinhthuc],
        ISNULL(NULLIF(pl.SobanManduphong, 0), hd.SobanManduphong) AS [SobanManduphong],
        ISNULL(NULLIF(pl.SobanChaychinhthuc, 0), hd.SobanChaychinhthuc) AS [SobanChaychinhthuc],
        ISNULL(NULLIF(pl.SobanChayduphong, 0), hd.SobanChayduphong) AS [SobanChayduphong],
        ISNULL(ISNULL(pl.SoBanTang, hd.SoBanTang), 0) AS [SoBanTang],

        -- Aliases khớp chính xác với biến template Word
        ISNULL(NULLIF(pl.SobanManchinhthuc, 0), hd.SobanManchinhthuc) AS [SoBanManChinhThuc],
        ISNULL(NULLIF(pl.SobanManduphong, 0), hd.SobanManduphong) AS [SoBanManDuPhong],
        ISNULL(ISNULL(pl.SoBanTang, hd.SoBanTang), 0) AS [BanTang],
        -- Alias {SoBanChinhThuc} và {SoBanDuPhong} cho template
        ISNULL(NULLIF(pl.SobanManchinhthuc, 0), hd.SobanManchinhthuc) AS [SoBanChinhThuc],
        ISNULL(NULLIF(pl.SobanManduphong, 0), hd.SobanManduphong) AS [SoBanDuPhong],

        -- Đợt thanh toán 2
        ISNULL(pl.TenDotThanhToanTD, pl.TenDotThanhToan) AS [TenDotThanhToan],
        FORMAT(ISNULL(pl.ThanhToanDot2SoTienTD, pl.ThanhToanDot2SoTien), 'N0', 'vi-VN') AS [ThanhToanDot2SoTien],
        ISNULL(pl.HinhThucThanhToanDot2TD, pl.HinhThucThanhToanDot2) AS [HinhThucThanhToanDot2],
        CONVERT(VARCHAR(10), ISNULL(pl.HanThanhToanDot2TD, pl.HanThanhToanDot2), 103) AS [HanThanhToanDot2],

        -- Dịch vụ tính phí: trả về JSON array [{TenDichVu, DonGia, GhiChu}]
        -- Ưu tiên: (1) text field thủ công → (2) DanhSachChiPhiTD → (3) JsonDichVu → (4) []
        COALESCE(
            (
                SELECT
                    CASE WHEN CHARINDEX(';', v) > 0
                         THEN LTRIM(RTRIM(LEFT(v, CHARINDEX(';', v) - 1)))
                         ELSE v
                    END AS [TenDichVu],
                    ISNULL(NULLIF(
                        CASE WHEN CHARINDEX(';', v) > 0
                                  AND CHARINDEX(';', v, CHARINDEX(';', v) + 1) > 0
                             THEN LTRIM(RTRIM(SUBSTRING(v,
                                      CHARINDEX(';', v) + 1,
                                      CHARINDEX(';', v, CHARINDEX(';', v) + 1)
                                      - CHARINDEX(';', v) - 1)))
                             WHEN CHARINDEX(';', v) > 0
                             THEN LTRIM(RTRIM(SUBSTRING(v, CHARINDEX(';', v) + 1, LEN(v))))
                             ELSE ''
                        END
                    , ''), '0') AS [DonGia],
                    CASE WHEN CHARINDEX(';', v) > 0
                              AND CHARINDEX(';', v, CHARINDEX(';', v) + 1) > 0
                         THEN LTRIM(RTRIM(SUBSTRING(v,
                                  CHARINDEX(';', v, CHARINDEX(';', v) + 1) + 1,
                                  LEN(v))))
                         ELSE ''
                    END AS [GhiChu]
                FROM (
                    SELECT LTRIM(RTRIM(REPLACE(x.value('.', 'NVARCHAR(MAX)'), CHAR(13), ''))) AS v
                    FROM (
                        SELECT CAST('<i>' +
                            REPLACE(
                                REPLACE(
                                    CASE WHEN pl.DichVuTinhPhiPhuLucTD IS NOT NULL THEN pl.DichVuTinhPhiPhuLucTD ELSE pl.DichVuTinhPhiPhuLuc END,
                                    '&', '&amp;'
                                ),
                                CHAR(10), '</i><i>'
                            )
                        + '</i>' AS XML) AS xmlSplit
                    ) xmlConv
                    CROSS APPLY xmlConv.xmlSplit.nodes('/i') AS T(x)
                ) splitResult
                WHERE v <> ''
                FOR JSON PATH
            ),
            -- Level 2: DanhSachChiPhiTD (cùng nguồn với section 2.5 - đã computed khi lưu)
            (
                SELECT
                    JSON_VALUE(value, '$.NoiDung') AS [TenDichVu],
                    ISNULL(NULLIF(JSON_VALUE(value, '$.DonGia'), ''), '0') AS [DonGia],
                    '' AS [GhiChu]
                FROM OPENJSON(pl.DanhSachChiPhiTD)
                WHERE pl.DanhSachChiPhiTD IS NOT NULL
                  AND pl.DanhSachChiPhiTD <> ''
                  AND pl.DanhSachChiPhiTD <> '[]'
                  AND ISNULL(JSON_VALUE(value, '$.NoiDung'), '') <> ''
                FOR JSON PATH
            ),
            -- Level 3: JsonDichVu (tab dịch vụ raw form)
            (
                SELECT
                    ISNULL(JSON_VALUE(value, '$.TenHang'), JSON_VALUE(value, '$.Mahang')) AS [TenDichVu],
                    FORMAT(
                        ISNULL(CAST(NULLIF(JSON_VALUE(value, '$.Dongia'), '') AS DECIMAL(18,2)), 0),
                        'N0', 'vi-VN'
                    ) AS [DonGia],
                    '' AS [GhiChu]
                FROM OPENJSON(pl.JsonDichVu)
                WHERE pl.JsonDichVu IS NOT NULL
                  AND pl.JsonDichVu <> ''
                  AND pl.JsonDichVu <> '[]'
                FOR JSON PATH
            ),
            '[]'
        ) AS [DichVuTinhPhiPhuLuc],


        ISNULL(pl.ThoaThuanPhuLucKhacTD, pl.ThoaThuanPhuLucKhac) AS [ThoaThuanPhuLucKhac],
        ISNULL(pl.BenAChucVuDaiDienTD, pl.BenAChucVuDaiDien) AS [BenAChucVuDaiDien],

        -- Chi phí tổng cộng
        FORMAT(ISNULL(pl.TongtienHopdongTD, hd.Tongtienhopdong), 'N0', 'vi-VN') AS [TongGiaTriTamTinh],
        FORMAT(ISNULL(pl.TongtienHopdongTD, hd.Tongtienhopdong), 'N0', 'vi-VN') AS [MenuTongCong],

        -- VÒNG LẶP MENU TIỆC (Bơm array [{STT, TenMonAn, DonGia}])
        COALESCE(
            (
                SELECT 
                    ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS [STT],
                    JSON_VALUE(value, '$.TenHang') AS [TenMonAn],
                    FORMAT(ISNULL(CAST(NULLIF(JSON_VALUE(value, '$.Dongia'),'') AS DECIMAL(18,2)), 0), 'N0', 'vi-VN') AS [DonGia]
                FROM OPENJSON(pl.JsonBanTiec)
                WHERE pl.JsonBanTiec IS NOT NULL
                FOR JSON PATH
            ),
            (
                SELECT 
                    ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS [STT],
                    h.Tenhang AS [TenMonAn],
                    '' AS [DonGia]
                FROM dmHangHoa h WITH (NOLOCK)
                WHERE h.GoiThucDonID = hd.GoiThucDonID AND ISNULL(h.IsNgungSuDung, 0) = 0
                FOR JSON PATH
            )
        ) AS [MenuTiec],

        -- VÒNG LẶP CHI PHÍ
        COALESCE(
            (
                SELECT 
                    ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS [STT],
                    JSON_VALUE(value, '$.NoiDung') AS [NoiDung],
                    JSON_VALUE(value, '$.DVT') AS [DVT],
                    JSON_VALUE(value, '$.SoLuong') AS [SoLuong],
                    JSON_VALUE(value, '$.DonGia') AS [DonGia],
                    JSON_VALUE(value, '$.ThanhTien') AS [ThanhTien]
                FROM OPENJSON(pl.DanhSachChiPhiTD)
                WHERE pl.DanhSachChiPhiTD IS NOT NULL AND pl.DanhSachChiPhiTD <> '' AND pl.DanhSachChiPhiTD <> '[]'
                FOR JSON PATH
            ),
            (
                SELECT 
                    ROW_NUMBER() OVER (ORDER BY items.SortOrder) AS [STT],
                    items.NoiDung, items.DVT, items.SoLuong, items.DonGia, items.ThanhTien
                FROM (
                    SELECT 
                        JSON_VALUE(value, '$.TenHang') AS [NoiDung],
                        ISNULL(JSON_VALUE(value, '$.DvtID'), N'Lần') AS [DVT],
                        ISNULL(JSON_VALUE(value, '$.Soluong'), N'0') AS [SoLuong],
                        FORMAT(ISNULL(CAST(JSON_VALUE(value, '$.Dongia') AS DECIMAL(18,2)), 0), 'N0', 'vi-VN') AS [DonGia],
                        FORMAT(ISNULL(CAST(JSON_VALUE(value, '$.Soluong') AS DECIMAL(18,2)), 0) * ISNULL(CAST(JSON_VALUE(value, '$.Dongia') AS DECIMAL(18,2)), 0), 'N0', 'vi-VN') AS [ThanhTien],
                        1 AS SortOrder
                    FROM OPENJSON(pl.JsonDichVu)
                    WHERE pl.JsonDichVu IS NOT NULL AND pl.JsonDichVu <> '' AND pl.JsonDichVu <> '[]'
                    UNION ALL
                    SELECT 
                        JSON_VALUE(value, '$.TenHang') AS [NoiDung],
                        ISNULL(JSON_VALUE(value, '$.DvtID'), N'Két/Lon') AS [DVT],
                        ISNULL(JSON_VALUE(value, '$.Soluong'), N'0') AS [SoLuong],
                        FORMAT(ISNULL(CAST(JSON_VALUE(value, '$.Dongia') AS DECIMAL(18,2)), 0), 'N0', 'vi-VN') AS [DonGia],
                        FORMAT(ISNULL(CAST(JSON_VALUE(value, '$.Soluong') AS DECIMAL(18,2)), 0) * ISNULL(CAST(JSON_VALUE(value, '$.Dongia') AS DECIMAL(18,2)), 0), 'N0', 'vi-VN') AS [ThanhTien],
                        2 AS SortOrder
                    FROM OPENJSON(pl.JsonThucUong)
                    WHERE pl.JsonThucUong IS NOT NULL AND pl.JsonThucUong <> '' AND pl.JsonThucUong <> '[]'
                ) items
                FOR JSON PATH
            ),
            '[]'
        ) AS [DanhSachChiPhi]

    FROM tbmk_Thaydoi pl WITH (NOLOCK)
    INNER JOIN tbmk_Hopdong hd WITH (NOLOCK) ON pl.Sohopdong = hd.Sohopdong
    LEFT JOIN dmkhachhang kh WITH (NOLOCK) ON hd.Makh = kh.Makh
    LEFT JOIN dmNhanvienView nv WITH (NOLOCK) ON nv.NHANVIENID = ISNULL(pl.Manv, hd.Manv) OR nv.Manv = ISNULL(pl.Manv, hd.Manv)
    LEFT JOIN dmNhanvienView nv_user WITH (NOLOCK) ON LOWER(nv_user.USERNAME) = LOWER(COALESCE(NULLIF(pl.UserCreate, ''), NULLIF(pl.UserUpdate, '')))
    WHERE (pl.Sothaydoi = @SearchStr OR pl.Sohopdong = @SearchStr)
      AND ISNULL(pl.IsDeleted, 0) = 0;
END;
GO

DELETE FROM WA_API WHERE List = 'frmPhuLucHopDong' AND Func = 'GetDetails';
INSERT INTO WA_API (List, Func, [SQL], Para)
VALUES ('frmPhuLucHopDong', 'GetDetails', 'API_PhuLucHopDong_Detail', '@Keyword=N''{Keyword}'', @Sothaydoi=N''{Sothaydoi}''');
GO
