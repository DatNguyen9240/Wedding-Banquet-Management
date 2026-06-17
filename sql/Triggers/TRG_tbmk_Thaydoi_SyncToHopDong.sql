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

    -- Chỉ chạy đồng bộ khi có thay đổi liên quan đến các bản ghi được ký duyệt hoặc kết thúc
    IF EXISTS (
        SELECT 1 
        FROM inserted i
        WHERE (i.Status IN ('SIGNED', 'APPROVED') OR i.IsKetthuc = 1)
          AND ISNULL(i.IsDeleted, 0) = 0
    )
    BEGIN
        -- Cập nhật thông tin mới nhất từ tbmk_Thaydoi sang tbmk_Hopdong
        -- Chọn dòng có lần thay đổi (LanThayDoi) cao nhất, ngày thay đổi mới nhất hoặc mã thay đổi mới nhất làm đại diện
        ;WITH LatestChanges AS (
            SELECT 
                i.Sohopdong,
                i.NgayToChucTD,
                i.ThoiGianIDTD,
                i.NhamNgayTD,
                i.LoaiTiecIDTD,
                i.SobanManchinhthuc,
                i.SobanManduphong,
                i.GiabanManTD,
                i.SobanChaychinhthuc,
                i.SobanChayduphong,
                i.GiabanChayTD,
                i.Ghichu,
                i.TongtienBanmanTD,
                i.TongtienBanchayTD,
                i.Tongtienthucuong,
                i.TongtienDichvuTD,
                i.TongtienHopdongTD,
                i.ConLaiTD,
                i.SoluongKhachTD,
                i.TongTienPhanChayTD,
                i.SoBanTang,
                i.SoNguoiTrenBanTD,
                i.TongSoBanTD,
                i.SoBanTinhPhiPhucVuTD,
                i.PhiPhucVuTD,
                i.TongTienPhiPhucVuTD,
                i.TienTTSTD,
                i.GiamGiaTTSTD,
                i.TongTienTTSTD,
                i.TienNTLTD,
                i.GiamGiaNTLTD,
                i.TongTienNTLTD,
                i.HinhThucSapSepIDTD,
                i.PhongSanKhauIDTD,
                i.PhiBuSanhTD,
                i.TenTrenPhongSanKhauTD,
                i.GhiChuThongBaoTiecTD,
                i.PhiBuBanTangTD,
                i.MauNoTD,
                i.DiaDiemToChucTD,
                i.TuNgaySetupTD,
                i.DenNgaySetupTD,
                i.TuGioDenGioSetupTD,
                i.DenGioSetupTD,
                i.TuNgayThuDonTD,
                i.DenNgayThuDonTD,
                i.GioKetThucThuDonTD,
                i.DenGioKetThucThuDonTD,
                i.GioDienRaSuKienTD,
                i.ChuongTrinhUuDaiTD,
                i.SoNgayToChucTD,
                i.GioBanGiaoSanhTiecCuoiTD,
                i.GioTraSanhTiecCuoiTD,
                i.GioKetThucSuKienTD,
                i.NgayBanGiaoSanhDVTD,
                i.GioBanGiaoSanhDVTD,
                i.NgayTraSanhDVTD,
                i.GioTraSanhDVTD,
                i.GoiThucDonIDTD,
                
                -- Đồng bộ các cột mới bổ sung
                i.QuyMoBanTuTD,
                i.QuyMoBanDenTD,
                i.TenDotThanhToanTD,
                i.ThanhToanDot2SoTienTD,
                i.HinhThucThanhToanDot2TD,
                i.HanThanhToanDot2TD,
                i.DichVuTinhPhiPhuLucTD,
                i.ThoaThuanPhuLucKhacTD,
                i.DanhSachChiPhiTD,
                i.BenAChucVuDaiDienTD,
                i.DonGiaBanTiecTD,
                i.SoKhachTrenBanTD,
                
                ROW_NUMBER() OVER (PARTITION BY i.Sohopdong ORDER BY i.LanThayDoi DESC, i.Ngaythaydoi DESC, i.Sothaydoi DESC) as rn
            FROM tbmk_Thaydoi i
            WHERE (i.Status IN ('SIGNED', 'APPROVED') OR i.IsKetthuc = 1)
              AND ISNULL(i.IsDeleted, 0) = 0
              AND i.Sohopdong IN (SELECT Sohopdong FROM inserted)
        )
        UPDATE h
        SET 
            h.Ngaytochuc = COALESCE(lc.NgayToChucTD, h.Ngaytochuc),
            h.Thoigianid = COALESCE(lc.ThoiGianIDTD, h.Thoigianid),
            h.Nhamngay = COALESCE(lc.NhamNgayTD, h.Nhamngay),
            h.Loaitiecid = COALESCE(lc.LoaiTiecIDTD, h.Loaitiecid),
            h.SobanManchinhthuc = COALESCE(lc.SobanManchinhthuc, h.SobanManchinhthuc),
            h.SobanManduphong = COALESCE(lc.SobanManduphong, h.SobanManduphong),
            h.Giabanman = COALESCE(lc.GiabanManTD, h.Giabanman),
            h.SobanChaychinhthuc = COALESCE(lc.SobanChaychinhthuc, h.SobanChaychinhthuc),
            h.SobanChayduphong = COALESCE(lc.SobanChayduphong, h.SobanChayduphong),
            h.Giabanchay = COALESCE(lc.GiabanChayTD, h.Giabanchay),
            h.Ghichu = COALESCE(lc.Ghichu, h.Ghichu),
            h.Tongtienbanman = COALESCE(lc.TongtienBanmanTD, h.Tongtienbanman),
            h.Tongtienbanchay = COALESCE(lc.TongtienBanchayTD, h.Tongtienbanchay),
            h.Tongtienthucuong = COALESCE(lc.Tongtienthucuong, h.Tongtienthucuong),
            h.Tongtiendichvu = COALESCE(lc.TongtienDichvuTD, h.Tongtiendichvu),
            h.Tongtienhopdong = COALESCE(lc.TongtienHopdongTD, h.Tongtienhopdong),
            h.Conlai = COALESCE(lc.ConLaiTD, h.Conlai),
            h.Soluongkhach = COALESCE(lc.SoluongKhachTD, h.Soluongkhach),
            h.Tongtienphanchay = COALESCE(lc.TongTienPhanChayTD, h.Tongtienphanchay),
            h.SoBanTang = COALESCE(lc.SoBanTang, h.SoBanTang),
            h.SoNguoiTrenBan = COALESCE(lc.SoNguoiTrenBanTD, h.SoNguoiTrenBan),
            h.TongSoBan = COALESCE(lc.TongSoBanTD, h.TongSoBan),
            h.SoBanTinhPhiPhucVu = COALESCE(lc.SoBanTinhPhiPhucVuTD, h.SoBanTinhPhiPhucVu),
            h.PhiPhucVu = COALESCE(lc.PhiPhucVuTD, h.PhiPhucVu),
            h.TongTienPhiPhucVu = COALESCE(lc.TongTienPhiPhucVuTD, h.TongTienPhiPhucVu),
            h.TienTTS = COALESCE(lc.TienTTSTD, h.TienTTS),
            h.GiamGiaTTS = COALESCE(lc.GiamGiaTTSTD, h.GiamGiaTTS),
            h.TongTienTTS = COALESCE(lc.TongTienTTSTD, h.TongTienTTS),
            h.TienNTL = COALESCE(lc.TienNTLTD, h.TienNTL),
            h.GiamGiaNTL = COALESCE(lc.GiamGiaNTLTD, h.GiamGiaNTL),
            h.TongTienNTL = COALESCE(lc.TongTienNTLTD, h.TongTienNTL),
            h.HinhThucSapSepID = COALESCE(lc.HinhThucSapSepIDTD, h.HinhThucSapSepID),
            h.PhongSanKhauID = COALESCE(lc.PhongSanKhauIDTD, h.PhongSanKhauID),
            h.PhiBuSanh = COALESCE(lc.PhiBuSanhTD, h.PhiBuSanh),
            h.TenTrenPhongSanKhau = COALESCE(lc.TenTrenPhongSanKhauTD, h.TenTrenPhongSanKhau),
            h.GhiChuThongBaoTiec = COALESCE(lc.GhiChuThongBaoTiecTD, h.GhiChuThongBaoTiec),
            h.PhiBuBanTang = COALESCE(lc.PhiBuBanTangTD, h.PhiBuBanTang),
            h.MauNo = COALESCE(lc.MauNoTD, h.MauNo),
            h.DiaDiemToChuc = COALESCE(lc.DiaDiemToChucTD, h.DiaDiemToChuc),
            h.TuNgaySetup = COALESCE(lc.TuNgaySetupTD, h.TuNgaySetup),
            h.DenNgaySetup = COALESCE(lc.DenNgaySetupTD, h.DenNgaySetup),
            h.TuGioDenGioSetup = COALESCE(lc.TuGioDenGioSetupTD, h.TuGioDenGioSetup),
            h.DenGioSetup = COALESCE(lc.DenGioSetupTD, h.DenGioSetup),
            h.TuNgayThuDon = COALESCE(lc.TuNgayThuDonTD, h.TuNgayThuDon),
            h.DenNgayThuDon = COALESCE(lc.DenNgayThuDonTD, h.DenNgayThuDon),
            h.GioKetThucThuDon = COALESCE(lc.GioKetThucThuDonTD, h.GioKetThucThuDon),
            h.DenGioKetThucThuDon = COALESCE(lc.DenGioKetThucThuDonTD, h.DenGioKetThucThuDon),
            h.GioDienRaSuKien = COALESCE(lc.GioDienRaSuKienTD, h.GioDienRaSuKien),
            h.ChuongTrinhUuDai = COALESCE(lc.ChuongTrinhUuDaiTD, h.ChuongTrinhUuDai),
            h.SoNgayToChuc = COALESCE(lc.SoNgayToChucTD, h.SoNgayToChuc),
            h.GioBanGiaoSanhTiecCuoi = COALESCE(lc.GioBanGiaoSanhTiecCuoiTD, h.GioBanGiaoSanhTiecCuoi),
            h.GioTraSanhTiecCuoi = COALESCE(lc.GioTraSanhTiecCuoiTD, h.GioTraSanhTiecCuoi),
            h.GioKetThucSuKien = COALESCE(lc.GioKetThucSuKienTD, h.GioKetThucSuKien),
            h.NgayBanGiaoSanhDV = COALESCE(lc.NgayBanGiaoSanhDVTD, h.NgayBanGiaoSanhDV),
            h.GioBanGiaoSanhDV = COALESCE(lc.GioBanGiaoSanhDVTD, h.GioBanGiaoSanhDV),
            h.NgayTraSanhDV = COALESCE(lc.NgayTraSanhDVTD, h.NgayTraSanhDV),
            h.GioTraSanhDV = COALESCE(lc.GioTraSanhDVTD, h.GioTraSanhDV),
            h.GoiThucDonID = COALESCE(lc.GoiThucDonIDTD, h.GoiThucDonID),
            
            -- Đồng bộ các cột mới bổ sung
            h.QuyMoBanTu = COALESCE(lc.QuyMoBanTuTD, h.QuyMoBanTu),
            h.QuyMoBanDen = COALESCE(lc.QuyMoBanDenTD, h.QuyMoBanDen),
            h.TenDotThanhToan = COALESCE(lc.TenDotThanhToanTD, h.TenDotThanhToan),
            h.ThanhToanDot2SoTien = COALESCE(lc.ThanhToanDot2SoTienTD, h.ThanhToanDot2SoTien),
            h.HinhThucThanhToanDot2 = COALESCE(lc.HinhThucThanhToanDot2TD, h.HinhThucThanhToanDot2),
            h.HanThanhToanDot2 = COALESCE(lc.HanThanhToanDot2TD, h.HanThanhToanDot2),
            h.DichVuTinhPhiPhuLuc = COALESCE(lc.DichVuTinhPhiPhuLucTD, h.DichVuTinhPhiPhuLuc),
            h.ThoaThuanPhuLucKhac = COALESCE(lc.ThoaThuanPhuLucKhacTD, h.ThoaThuanPhuLucKhac),
            h.DanhSachChiPhi = COALESCE(lc.DanhSachChiPhiTD, h.DanhSachChiPhi),
            h.BenAChucVuDaiDien = COALESCE(lc.BenAChucVuDaiDienTD, h.BenAChucVuDaiDien),
            h.DonGiaBanTiec = COALESCE(lc.DonGiaBanTiecTD, h.DonGiaBanTiec),
            h.SoKhachTrenBan = COALESCE(lc.SoKhachTrenBanTD, h.SoKhachTrenBan)
        FROM tbmk_Hopdong h
        INNER JOIN LatestChanges lc ON h.Sohopdong = lc.Sohopdong
        WHERE lc.rn = 1;
    END
END
GO
