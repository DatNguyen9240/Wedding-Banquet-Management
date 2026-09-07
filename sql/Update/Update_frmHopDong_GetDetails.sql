IF COL_LENGTH('tbmk_Hopdongthucuong', 'Dvt') IS NULL
BEGIN
    ALTER TABLE tbmk_Hopdongthucuong ADD Dvt NVARCHAR(50) NULL;
END
GO

IF OBJECT_ID('API_LayChiTietHopDong', 'P') IS NOT NULL
    DROP PROCEDURE API_LayChiTietHopDong;
GO

CREATE PROCEDURE [dbo].[API_LayChiTietHopDong]
    @Sohopdong VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        h.Sohopdong,
        v.NgayCocThucTe,
        v.PhiPhucVuTyLe,
        v.MucPhiPhucVu,
        v.DieuKhoanBoSung,
        v.DSKhuyenMai,
        v.BenANguoiGiaoDich,
        v.BenAChucVuGiaoDich,
        v.NoiDungXuatHoaDon,
        v.SoKhachHoiNghi,
        v.SetupHoiNghi,
        v.SetupTiec,
        v.NgaySetupSuKien,
        v.NgaySuKien,
        v.DiaDiemHoiNghi,
        v.CaHoiNghi,
        v.CaTiec,

        -- 1. Thực đơn (Mặn + Chay)
        COALESCE((
            SELECT items.Mahang, items.TenHang, items.DvtID, items.Soluong, items.Dongia, items.IsKhuyenmai, items.STTmon, items.TableType
            FROM (
                SELECT td.Mahang, ISNULL(hh.Tenhang, td.Mahang) AS TenHang, ISNULL(hh.DVTID, N'Đĩa') AS DvtID,
                       CAST(1 AS DECIMAL(18,2)) AS Soluong, ISNULL(td.Dongia, 0) AS Dongia,
                       CAST(0 AS BIT) AS IsKhuyenmai, ISNULL(td.STTmon, 0) AS STTmon, 1 AS TableType,
                       ISNULL(td.STTmon, 0) AS SortOrder
                FROM tbmk_Hopdongthucdonman td
                LEFT JOIN dmHanghoa hh ON td.Mahang = hh.Mahang
                WHERE td.Sohopdong = @Sohopdong
                UNION ALL
                SELECT td.Mahang, ISNULL(hh.Tenhang, td.Mahang), ISNULL(hh.DVTID, N'Đĩa'),
                       CAST(1 AS DECIMAL(18,2)), ISNULL(td.Dongia, 0),
                       CAST(1 AS BIT), ISNULL(td.STTmon, 0), 2,
                       ISNULL(td.STTmon, 0)
                FROM tbmk_Hopdongthucdonchay td
                LEFT JOIN dmHanghoa hh ON td.Mahang = hh.Mahang
                WHERE td.Sohopdong = @Sohopdong
            ) items
            ORDER BY items.TableType, items.SortOrder, items.Mahang
            FOR JSON PATH
        ), h.JsonBanTiec, '[]') AS [JsonBanTiec],

        -- 2. Thức uống
        COALESCE((
            SELECT tu.Mahang, ISNULL(hh.Tenhang, tu.Mahang) AS TenHang, ISNULL(tu.Dvt, hh.DVTID) AS DvtID,
                   ISNULL(tu.IsKhuyenmai, 0) AS IsKhuyenmai, ISNULL(tu.Soluong, 0) AS Soluong,
                   ISNULL(tu.Dongia, 0) AS Dongia, CAST(0 AS DECIMAL(18,2)) AS Soluongle,
                   CAST(0 AS DECIMAL(18,2)) AS Dongiale, ISNULL(tu.Ghichuthucuong, N'') AS Ghichuthucuong
            FROM tbmk_Hopdongthucuong tu
            LEFT JOIN dmHanghoa hh ON tu.Mahang = hh.Mahang
            WHERE tu.Sohopdong = @Sohopdong
            ORDER BY tu.Mahang
            FOR JSON PATH
        ), h.JsonThucUong, '[]') AS [JsonThucUong],

        -- 3. Dịch vụ
        COALESCE((
            SELECT dv.Mahang, ISNULL(hh.Tenhang, dv.Mahang) AS TenHang, ISNULL(hh.DVTID, N'Lần') AS DvtID,
                   CAST(0 AS BIT) AS IsKhuyenmai, ISNULL(dv.Soluong, 0) AS Soluong,
                   ISNULL(dv.Dongia, 0) AS Dongia
            FROM tbmk_Hopdongdichvu dv
            LEFT JOIN dmHanghoa hh ON dv.Mahang = hh.Mahang
            WHERE dv.Sohopdong = @Sohopdong
            ORDER BY dv.Mahang
            FOR JSON PATH
        ), h.JsonDichVu, '[]') AS [JsonDichVu],

        -- 4. Phát sinh (Trống cho Hợp đồng)
        '[]' AS [JsonPhatSinh],

        -- 5. Thông tin chi tiết hợp đồng gốc
        h.QuyMoBanTu,
        h.QuyMoBanDen,
        h.Giabanman AS DonGiaBanTiec,
        h.SoNguoiTrenBan AS SoKhachTrenBan,
        h.Sotiencochopdong AS ThanhToanDot2SoTien,
        h.HinhThucThanhToanDot2,
        h.HanThanhToanDot2,
        v.BenAChucVu AS BenAChucVu,
        h.Ngaytochuc AS NgayToChuc,
        h.Nhamngay,
        h.DichVuTinhPhiPhuLuc,
        h.ThoaThuanPhuLucKhac,

        -- Bổ sung đầy đủ thông tin phục vụ in ấn từ View v_DanhSachHopDong (hỗ trợ tất cả các biến thể đặt tên trong mẫu Word)
        v.BenANguoiDaiDien,
        v.BenADaiDien,
        v.BenADaiDien AS HNNguoiDaiDien,
        v.BenAChucVuDaiDien,
        v.BenAChucVu AS HNChucVuNguoiDaiDien,
        v.BenANhanVienPhuTrach,
        v.BenASDTNhanVien,
        v.BenADiaChi,
        v.HDDiaChi,
        v.BenAEmail,
        v.BenBEmail AS HDEmail,
        v.BenATenCongTy,
        v.HDTenCty,
        v.BenASDT,
        v.BenAMST,
        v.HDMaSoThue,
        v.BenBTenDaiDien,
        v.BenBTenChuTiec,
        v.BenBCCCD,
        v.BenBDiaChi,
        v.BenBDienThoai,
        v.BenBChucVu,
        v.SetupBatDau,
        v.SetupKetThuc,
        v.SetupNoiDung1,
        v.SetupNoiDung2,
        v.ToChucNoiDung,
        v.OutNoiDung,
        v.TiecGioBatDau,
        v.TiecGioKetThuc,
        v.SoKhachDiemDanh,
        v.SoKhachThamQuanDuKien,
        v.GioBatDauTrienLam,
        v.GioKetThucTrienLam,
        v.NgaySetupTrienLam,
        v.NgayTrienLam,
        v.LichTrinhThanhToan,
        v.DanhSachSanh,
        v.TiecNgayDL,
        v.TiecThangDL,
        v.TiecNamDL,
        v.TiecNgayAL,
        v.TiecThangAL,
        v.TiecNamAL,
        v.TenSanhTiec,
        v.DiaDiemTrienLam,
        v.DiaDiemTiec,
        v.BuoiTiec,
        v.PhiThueSanhNgoaiGio,
        v.SanhQuyMoMin,
        v.SanhQuyMoMax,
        v.TiecLoaiTiec,
        v.NgayLapHD,
        v.ThangLapHD,
        v.NamLapHD,
        v.MenuMan,
        v.MenuChay,
        v.MenuTongCongMan,
        v.MenuTongCongChay,
        v.DichVuTinhPhi,
        v.TongGiaTriTamTinh,
        v.TongGiaTriTamTinhBangChu,
        v.CocNgay,
        v.CocThang,
        v.CocNam,
        v.CocLan1SoTien,
        v.CocLan1BangChu,
        v.TiecSoBanChinhThuc,
        v.TiecSoBanTang,
        v.TiecSoBanDuPhong,
        v.TiecSoKhach1Ban,
        v.TiecSanhTiec
    FROM tbmk_Hopdong h
    LEFT JOIN [dbo].[v_DanhSachHopDong] v ON h.Sohopdong = v.Sohopdong
    WHERE h.Sohopdong = @Sohopdong;
END;
GO

DELETE FROM WA_API WHERE List = 'frmHopDong' AND Func = 'GetDetails';
INSERT INTO WA_API (List, Func, [SQL], Para)
VALUES ('frmHopDong', 'GetDetails', 'API_LayChiTietHopDong', '@Sohopdong=N''{Keyword}''');
GO
