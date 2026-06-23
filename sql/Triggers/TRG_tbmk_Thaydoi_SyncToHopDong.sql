USE [QLTiec]
GO

IF OBJECT_ID('[dbo].[TRG_tbmk_Thaydoi_SyncToHopDong]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRG_tbmk_Thaydoi_SyncToHopDong];
GO
CREATE TRIGGER [dbo].[TRG_tbmk_Thaydoi_SyncToHopDong]
ON [dbo].[tbmk_Thaydoi]
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Đồng bộ ngay lập tức khi có thay đổi Phụ lục (không cần đợi ký duyệt)
    IF EXISTS (
        SELECT 1 
        FROM inserted i
        WHERE ISNULL(i.IsDeleted, 0) = 0
    )
    BEGIN
        -- Xóa dữ liệu chi tiết cũ trên Hợp đồng
        DELETE td FROM tbmk_Hopdongthucdonman td INNER JOIN inserted i ON td.Sohopdong = i.Sohopdong;
        DELETE tc FROM tbmk_Hopdongthucdonchay tc INNER JOIN inserted i ON tc.Sohopdong = i.Sohopdong;
        DELETE tu FROM tbmk_Hopdongthucuong tu INNER JOIN inserted i ON tu.Sohopdong = i.Sohopdong;
        DELETE dv FROM tbmk_Hopdongdichvu dv INNER JOIN inserted i ON dv.Sohopdong = i.Sohopdong;

        -- Thêm chi tiết thực đơn mặn
        INSERT INTO tbmk_Hopdongthucdonman (UserAutoid, Sohopdong, STTmon, Mahang, Dongia, Ghichuthucdonman, IsKhaividaugio, UserCreate, DateCreate)
        SELECT NEWID(), i.Sohopdong, ROW_NUMBER() OVER(PARTITION BY i.Sohopdong ORDER BY (SELECT NULL)), j.Mahang, j.Dongia, NULL, 0, i.UserCreate, GETDATE()
        FROM inserted i
        CROSS APPLY OPENJSON(i.JsonBanTiec) WITH (Mahang VARCHAR(50), TenHang NVARCHAR(255), Dongia DECIMAL(18,2)) j
        LEFT JOIN dmHanghoa hh ON j.Mahang = hh.Mahang
        WHERE i.JsonBanTiec IS NOT NULL AND i.JsonBanTiec <> '[]'
          AND ISNULL(hh.Tenhang, j.TenHang) NOT LIKE N'%chay%';

        -- Thêm chi tiết thực đơn chay
        INSERT INTO tbmk_Hopdongthucdonchay (UserAutoid, Sohopdong, STTmon, Mahang, Dongia, Ghichuthucdonchay, IsKhaividaugio, UserCreate, DateCreate)
        SELECT NEWID(), i.Sohopdong, ROW_NUMBER() OVER(PARTITION BY i.Sohopdong ORDER BY (SELECT NULL)), j.Mahang, j.Dongia, NULL, 0, i.UserCreate, GETDATE()
        FROM inserted i
        CROSS APPLY OPENJSON(i.JsonBanTiec) WITH (Mahang VARCHAR(50), TenHang NVARCHAR(255), Dongia DECIMAL(18,2)) j
        LEFT JOIN dmHanghoa hh ON j.Mahang = hh.Mahang
        WHERE i.JsonBanTiec IS NOT NULL AND i.JsonBanTiec <> '[]'
          AND ISNULL(hh.Tenhang, j.TenHang) LIKE N'%chay%';

        -- Thêm chi tiết thức uống
        INSERT INTO tbmk_Hopdongthucuong (UserAutoid, Sohopdong, Mahang, Soluong, Dongia, Sotien, IsKhuyenmai, Ghichuthucuong, Giamgia, STT, UserCreate, DateCreate)
        SELECT NEWID(), i.Sohopdong, j.Mahang, j.Soluong, j.Dongia, (j.Soluong * j.Dongia), ISNULL(j.IsKhuyenmai, 0), j.Ghichuthucuong, ISNULL(j.Giamgia, 0), ROW_NUMBER() OVER(PARTITION BY i.Sohopdong ORDER BY (SELECT NULL)), i.UserCreate, GETDATE()
        FROM inserted i
        CROSS APPLY OPENJSON(i.JsonThucUong)
        WITH (Mahang VARCHAR(50), Dvt NVARCHAR(50), DvtID NVARCHAR(50), Soluong DECIMAL(18,2), Dongia DECIMAL(18,2), IsKhuyenmai BIT, Ghichuthucuong NVARCHAR(500), Giamgia DECIMAL(18,2)) j
        WHERE i.JsonThucUong IS NOT NULL AND i.JsonThucUong <> '[]';

        -- Thêm chi tiết dịch vụ
        INSERT INTO tbmk_Hopdongdichvu (UserAutoid, Sohopdong, Mahang, Soluong, Dongia, Sotien, IsKhuyenmai, Ghichudichvu, STT, UserCreate, DateCreate)
        SELECT NEWID(), i.Sohopdong, j.Mahang, j.Soluong, j.Dongia, (j.Soluong * j.Dongia), ISNULL(j.IsKhuyenmai, 0), j.Ghichudichvu, ROW_NUMBER() OVER(PARTITION BY i.Sohopdong ORDER BY (SELECT NULL)), i.UserCreate, GETDATE()
        FROM inserted i
        CROSS APPLY OPENJSON(i.JsonDichVu)
        WITH (Mahang VARCHAR(50), Soluong DECIMAL(18,2), Dongia DECIMAL(18,2), IsKhuyenmai BIT, Ghichudichvu NVARCHAR(500)) j
        WHERE i.JsonDichVu IS NOT NULL AND i.JsonDichVu <> '[]';

        -- Cập nhật thông tin mới nhất từ tbmk_Thaydoi sang tbmk_Hopdong
        ;WITH LatestChanges AS (
            SELECT 
                i.Sohopdong,
                i.NgayToChucTD, i.ThoiGianIDTD, i.NhamNgayTD, i.LoaiTiecIDTD,
                i.SobanManchinhthuc, i.SobanManduphong, i.GiabanManTD,
                i.SobanChaychinhthuc, i.SobanChayduphong, i.GiabanChayTD,
                i.Ghichu, i.TongtienBanmanTD, i.TongtienBanchayTD,
                i.Tongtienthucuong, i.TongtienDichvuTD, i.TongtienHopdongTD,
                i.ConLaiTD, i.SoluongKhachTD, i.TongTienPhanChayTD, i.SoBanTang,
                i.SoNguoiTrenBanTD, i.TongSoBanTD, i.SoBanTinhPhiPhucVuTD,
                i.PhiPhucVuTD, i.TongTienPhiPhucVuTD,
                i.TienTTSTD, i.GiamGiaTTSTD, i.TongTienTTSTD,
                i.TienNTLTD, i.GiamGiaNTLTD, i.TongTienNTLTD,
                i.HinhThucSapSepIDTD, i.PhongSanKhauIDTD, i.PhiBuSanhTD,
                i.TenTrenPhongSanKhauTD, i.GhiChuThongBaoTiecTD, i.PhiBuBanTangTD,
                i.MauNoTD, i.DiaDiemToChucTD, i.TuNgaySetupTD, i.DenNgaySetupTD,
                i.TuGioDenGioSetupTD, i.DenGioSetupTD, i.TuNgayThuDonTD, i.DenNgayThuDonTD,
                i.GioKetThucThuDonTD, i.DenGioKetThucThuDonTD, i.GioDienRaSuKienTD,
                i.ChuongTrinhUuDaiTD, i.SoNgayToChucTD, i.GioBanGiaoSanhTiecCuoiTD,
                i.GioTraSanhTiecCuoiTD, i.GioKetThucSuKienTD, i.NgayBanGiaoSanhDVTD,
                i.GioBanGiaoSanhDVTD, i.NgayTraSanhDVTD, i.GioTraSanhDVTD, i.GoiThucDonIDTD,
                
                -- Đồng bộ các cột mới bổ sung
                i.QuyMoBanTuTD, i.QuyMoBanDenTD, i.TenDotThanhToanTD,
                i.ThanhToanDot2SoTienTD, i.HinhThucThanhToanDot2TD, i.HanThanhToanDot2TD,
                i.DichVuTinhPhiPhuLucTD, i.ThoaThuanPhuLucKhacTD, i.DanhSachChiPhiTD,
                i.BenAChucVuDaiDienTD, i.DonGiaBanTiecTD, i.SoKhachTrenBanTD,
                
                ROW_NUMBER() OVER (PARTITION BY i.Sohopdong ORDER BY i.LanThayDoi DESC, i.Ngaythaydoi DESC, i.Sothaydoi DESC) as rn
            FROM tbmk_Thaydoi i
            WHERE ISNULL(i.IsDeleted, 0) = 0
              AND i.Sohopdong IN (SELECT Sohopdong FROM inserted)
        )
        UPDATE h
        SET 
            h.Ngaytochuc = COALESCE(lc.NgayToChucTD, h.Ngaytochuc),
            h.Thoigianid = COALESCE(NULLIF(lc.ThoiGianIDTD, ''), h.Thoigianid),
            h.Nhamngay = COALESCE(NULLIF(lc.NhamNgayTD, ''), h.Nhamngay),
            h.Loaitiecid = COALESCE(NULLIF(lc.LoaiTiecIDTD, ''), h.Loaitiecid),
            h.SobanManchinhthuc = COALESCE(NULLIF(lc.SobanManchinhthuc, 0), h.SobanManchinhthuc),
            h.SobanManduphong = COALESCE(NULLIF(lc.SobanManduphong, 0), h.SobanManduphong),
            h.Giabanman = COALESCE(NULLIF(lc.GiabanManTD, 0), h.Giabanman),
            h.SobanChaychinhthuc = COALESCE(NULLIF(lc.SobanChaychinhthuc, 0), h.SobanChaychinhthuc),
            h.SobanChayduphong = COALESCE(NULLIF(lc.SobanChayduphong, 0), h.SobanChayduphong),
            h.Giabanchay = COALESCE(NULLIF(lc.GiabanChayTD, 0), h.Giabanchay),
            h.Ghichu = COALESCE(NULLIF(lc.Ghichu, ''), h.Ghichu),
            h.Tongtienbanman = COALESCE(NULLIF(lc.TongtienBanmanTD, 0), h.Tongtienbanman),
            h.Tongtienbanchay = COALESCE(NULLIF(lc.TongtienBanchayTD, 0), h.Tongtienbanchay),
            h.Tongtienthucuong = COALESCE(NULLIF(lc.Tongtienthucuong, 0), h.Tongtienthucuong),
            h.Tongtiendichvu = COALESCE(NULLIF(lc.TongtienDichvuTD, 0), h.Tongtiendichvu),
            h.Tongtienhopdong = COALESCE(NULLIF(lc.TongtienHopdongTD, 0), h.Tongtienhopdong),
            h.Conlai = COALESCE(NULLIF(lc.ConLaiTD, 0), h.Conlai),
            h.Soluongkhach = COALESCE(NULLIF(lc.SoluongKhachTD, 0), h.Soluongkhach),
            h.Tongtienphanchay = COALESCE(NULLIF(lc.TongTienPhanChayTD, 0), h.Tongtienphanchay),
            h.SoBanTang = COALESCE(NULLIF(lc.SoBanTang, 0), h.SoBanTang),
            h.SoNguoiTrenBan = COALESCE(NULLIF(lc.SoNguoiTrenBanTD, 0), h.SoNguoiTrenBan),
            h.TongSoBan = COALESCE(NULLIF(lc.TongSoBanTD, 0), h.TongSoBan),
            h.SoBanTinhPhiPhucVu = COALESCE(NULLIF(lc.SoBanTinhPhiPhucVuTD, 0), h.SoBanTinhPhiPhucVu),
            h.PhiPhucVu = COALESCE(NULLIF(lc.PhiPhucVuTD, 0), h.PhiPhucVu),
            h.TongTienPhiPhucVu = COALESCE(NULLIF(lc.TongTienPhiPhucVuTD, 0), h.TongTienPhiPhucVu),
            h.TienTTS = COALESCE(NULLIF(lc.TienTTSTD, 0), h.TienTTS),
            h.GiamGiaTTS = COALESCE(NULLIF(lc.GiamGiaTTSTD, 0), h.GiamGiaTTS),
            h.TongTienTTS = COALESCE(NULLIF(lc.TongTienTTSTD, 0), h.TongTienTTS),
            h.TienNTL = COALESCE(NULLIF(lc.TienNTLTD, 0), h.TienNTL),
            h.GiamGiaNTL = COALESCE(NULLIF(lc.GiamGiaNTLTD, 0), h.GiamGiaNTL),
            h.TongTienNTL = COALESCE(NULLIF(lc.TongTienNTLTD, 0), h.TongTienNTL),
            h.HinhThucSapSepID = COALESCE(NULLIF(lc.HinhThucSapSepIDTD, ''), h.HinhThucSapSepID),
            h.PhongSanKhauID = COALESCE(NULLIF(lc.PhongSanKhauIDTD, ''), h.PhongSanKhauID),
            h.PhiBuSanh = COALESCE(NULLIF(lc.PhiBuSanhTD, 0), h.PhiBuSanh),
            h.TenTrenPhongSanKhau = COALESCE(NULLIF(lc.TenTrenPhongSanKhauTD, ''), h.TenTrenPhongSanKhau),
            h.GhiChuThongBaoTiec = COALESCE(NULLIF(lc.GhiChuThongBaoTiecTD, ''), h.GhiChuThongBaoTiec),
            h.PhiBuBanTang = COALESCE(NULLIF(lc.PhiBuBanTangTD, 0), h.PhiBuBanTang),
            h.MauNo = COALESCE(NULLIF(lc.MauNoTD, ''), h.MauNo),
            h.DiaDiemToChuc = COALESCE(NULLIF(lc.DiaDiemToChucTD, ''), h.DiaDiemToChuc),
            h.TuNgaySetup = COALESCE(lc.TuNgaySetupTD, h.TuNgaySetup),
            h.DenNgaySetup = COALESCE(lc.DenNgaySetupTD, h.DenNgaySetup),
            h.TuGioDenGioSetup = COALESCE(NULLIF(lc.TuGioDenGioSetupTD, ''), h.TuGioDenGioSetup),
            h.DenGioSetup = COALESCE(NULLIF(lc.DenGioSetupTD, ''), h.DenGioSetup),
            h.TuNgayThuDon = COALESCE(lc.TuNgayThuDonTD, h.TuNgayThuDon),
            h.DenNgayThuDon = COALESCE(lc.DenNgayThuDonTD, h.DenNgayThuDon),
            h.GioKetThucThuDon = COALESCE(NULLIF(lc.GioKetThucThuDonTD, ''), h.GioKetThucThuDon),
            h.DenGioKetThucThuDon = COALESCE(NULLIF(lc.DenGioKetThucThuDonTD, ''), h.DenGioKetThucThuDon),
            h.GioDienRaSuKien = COALESCE(NULLIF(lc.GioDienRaSuKienTD, ''), h.GioDienRaSuKien),
            h.ChuongTrinhUuDai = COALESCE(NULLIF(lc.ChuongTrinhUuDaiTD, ''), h.ChuongTrinhUuDai),
            h.SoNgayToChuc = COALESCE(NULLIF(lc.SoNgayToChucTD, 0), h.SoNgayToChuc),
            h.GioBanGiaoSanhTiecCuoi = COALESCE(NULLIF(lc.GioBanGiaoSanhTiecCuoiTD, ''), h.GioBanGiaoSanhTiecCuoi),
            h.GioTraSanhTiecCuoi = COALESCE(NULLIF(lc.GioTraSanhTiecCuoiTD, ''), h.GioTraSanhTiecCuoi),
            h.GioKetThucSuKien = COALESCE(NULLIF(lc.GioKetThucSuKienTD, ''), h.GioKetThucSuKien),
            h.NgayBanGiaoSanhDV = COALESCE(lc.NgayBanGiaoSanhDVTD, h.NgayBanGiaoSanhDV),
            h.GioBanGiaoSanhDV = COALESCE(NULLIF(lc.GioBanGiaoSanhDVTD, ''), h.GioBanGiaoSanhDV),
            h.NgayTraSanhDV = COALESCE(lc.NgayTraSanhDVTD, h.NgayTraSanhDV),
            h.GioTraSanhDV = COALESCE(NULLIF(lc.GioTraSanhDVTD, ''), h.GioTraSanhDV),
            h.GoiThucDonID = COALESCE(NULLIF(lc.GoiThucDonIDTD, ''), h.GoiThucDonID),
            
            -- Đồng bộ các cột mới bổ sung
            h.QuyMoBanTu = COALESCE(NULLIF(lc.QuyMoBanTuTD, 0), h.QuyMoBanTu),
            h.QuyMoBanDen = COALESCE(NULLIF(lc.QuyMoBanDenTD, 0), h.QuyMoBanDen),
            h.TenDotThanhToan = COALESCE(NULLIF(lc.TenDotThanhToanTD, ''), h.TenDotThanhToan),
            h.ThanhToanDot2SoTien = COALESCE(NULLIF(lc.ThanhToanDot2SoTienTD, 0), h.ThanhToanDot2SoTien),
            h.HinhThucThanhToanDot2 = COALESCE(NULLIF(lc.HinhThucThanhToanDot2TD, ''), h.HinhThucThanhToanDot2),
            h.HanThanhToanDot2 = COALESCE(lc.HanThanhToanDot2TD, h.HanThanhToanDot2),
            h.DichVuTinhPhiPhuLuc = COALESCE(NULLIF(lc.DichVuTinhPhiPhuLucTD, ''), h.DichVuTinhPhiPhuLuc),
            h.ThoaThuanPhuLucKhac = COALESCE(NULLIF(lc.ThoaThuanPhuLucKhacTD, ''), h.ThoaThuanPhuLucKhac),
            h.DanhSachChiPhi = COALESCE(NULLIF(lc.DanhSachChiPhiTD, ''), h.DanhSachChiPhi),
            h.BenAChucVuDaiDien = COALESCE(NULLIF(lc.BenAChucVuDaiDienTD, ''), h.BenAChucVuDaiDien),
            h.DonGiaBanTiec = COALESCE(NULLIF(lc.DonGiaBanTiecTD, 0), h.DonGiaBanTiec),
            h.SoKhachTrenBan = COALESCE(NULLIF(lc.SoKhachTrenBanTD, 0), h.SoKhachTrenBan),
            
            -- Đồng bộ cọc lần 2 và tổng tiền cọc tương ứng
            h.Sotiencochopdong = COALESCE(NULLIF(lc.ThanhToanDot2SoTienTD, 0), h.Sotiencochopdong),
            h.Tongtiencoc = ISNULL(h.Sotiencoccho, 0) + COALESCE(NULLIF(lc.ThanhToanDot2SoTienTD, 0), ISNULL(h.Sotiencochopdong, 0))
        FROM tbmk_Hopdong h
        INNER JOIN LatestChanges lc ON h.Sohopdong = lc.Sohopdong
        WHERE lc.rn = 1;
    END
END
GO
