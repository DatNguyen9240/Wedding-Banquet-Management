USE [QLTiec]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =========================================================================
-- 1. CHUẨN HÓA CẤU TRÚC BẢNG (SOFT DELETE COLUMNS CHO TBMK_PHIEUTHU)
-- =========================================================================
PRINT N'Đang chuẩn hóa cấu trúc bảng Quyết toán...';
GO

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[tbmk_Phieuthu]') AND name = 'IsDeleted')
BEGIN
    ALTER TABLE tbmk_Phieuthu ADD IsDeleted BIT DEFAULT 0;
    ALTER TABLE tbmk_Phieuthu ADD DeletedBy VARCHAR(50) NULL;
    ALTER TABLE tbmk_Phieuthu ADD DeletedAt DATETIME NULL;
    PRINT N'Đã thêm cột Soft Delete cho bảng tbmk_Phieuthu';
END
GO

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[tbmk_Phieuthu]') AND name = 'Status')
BEGIN
    ALTER TABLE tbmk_Phieuthu ADD Status VARCHAR(20) DEFAULT 'DRAFT';
    PRINT N'Đã thêm cột Status cho bảng tbmk_Phieuthu';
END
GO

-- Đảm bảo bảng tbmk_Hopdong có cột BanPhatSinh để không bị lỗi compile Stored Procedure
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[tbmk_Hopdong]') AND name = 'BanPhatSinh')
BEGIN
    ALTER TABLE tbmk_Hopdong ADD BanPhatSinh INT NULL DEFAULT 0;
    PRINT N'Đã thêm cột BanPhatSinh cho bảng tbmk_Hopdong';
END
GO

-- =========================================================================
-- 2. CẬP NHẬT STORED PROCEDURE LẤY DANH SÁCH QUYẾT TOÁN (ĐỘNG TỪ BẢNG CHI TIẾT)
-- =========================================================================
PRINT N'Đang cập nhật Stored Procedure API_DanhSachQuyetToan...';
GO

IF OBJECT_ID('API_DanhSachQuyetToan', 'P') IS NOT NULL
    DROP PROCEDURE API_DanhSachQuyetToan;
GO

CREATE PROCEDURE [dbo].[API_DanhSachQuyetToan]
    @Keyword NVARCHAR(100) = NULL,
    @DocumentID VARCHAR(50) = NULL,
    @Sohopdong VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        -- Cột gốc cho Grid và tính tương thích của hệ thống
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
        pt.Ghichu,
        pt.Sotienphatsinh,
        pt.PhiBuSanh,
        pt.PhiBuBantang,
        pt.PhiBuTTS,
        pt.PhiBuNTL,
        CAST(ISNULL(pt.PTThueVAT, 0) AS INT) AS [PTThueVAT],
        pt.TienThueVAT,
        hd.BanPhatSinh,

        -- Cột dùng cho in ấn (placeholders)
        kh.Tenkh AS [KhachHang],
        ISNULL((SELECT TOP 1 Tenloaitiec FROM dmLoaihinhtiec WHERE Loaitiecid = hd.Loaitiecid), N'TIỆC CƯỚI') AS [LoaiHinhSK],
        ISNULL((SELECT TOP 1 nv.Tennv FROM dmNhanvienView nv WHERE nv.Manv = pt.Manv), pt.Manv) AS [NVKD],
        
        CAST(ISNULL(hd.TongSoBan, 0) AS VARCHAR) + N' BÀN (' + CAST(ISNULL(hd.TongSoBan * 10, 0) AS VARCHAR) + N' KHÁCH)' AS [SoLuongKhach],
        (SELECT TOP 1 s.Tensanhtiec FROM tbmk_Hopdongsanhtiec hs INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid WHERE hs.Sohopdong = pt.Sohopdong) AS [SanhTiec],
        CONVERT(VARCHAR(10), hd.Ngaytochuc, 103) AS [NgayToChuc],
        ISNULL(hd.GioDienRaSuKien, N'Chưa xác định') AS [ThoiGian],

        RIGHT('0' + CAST(DAY(ISNULL(pt.DocumentDate, GETDATE())) AS VARCHAR), 2) AS [NgayQuyetToan],
        RIGHT('0' + CAST(MONTH(ISNULL(pt.DocumentDate, GETDATE())) AS VARCHAR), 2) AS [ThangQuyetToan],
        YEAR(ISNULL(pt.DocumentDate, GETDATE())) AS [NamQuyetToan],

        -- Bảng tổng hợp & tính toán chi tiết
        CASE WHEN c1.Cong1Val = 0 THEN N'-' ELSE FORMAT(c1.Cong1Val, 'N0', 'vi-VN') END AS [Cong1],
        CASE WHEN c2.Cong2Val = 0 THEN N'-' ELSE FORMAT(c2.Cong2Val, 'N0', 'vi-VN') END AS [Cong2],
        CASE WHEN (c1.Cong1Val + c2.Cong2Val) = 0 THEN N'-' ELSE FORMAT((c1.Cong1Val + c2.Cong2Val), 'N0', 'vi-VN') END AS [TongCong12],
        CASE WHEN ISNULL(pt.PhiPhucVu, 0) = 0 THEN N'-' ELSE FORMAT(pt.PhiPhucVu, 'N0', 'vi-VN') END AS [PhiPhucVu],
        CASE WHEN (c1.Cong1Val + c2.Cong2Val + ISNULL(pt.PhiPhucVu, 0)) = 0 THEN N'-' ELSE FORMAT((c1.Cong1Val + c2.Cong2Val + ISNULL(pt.PhiPhucVu, 0)), 'N0', 'vi-VN') END AS [TongCongChuaVAT],
        CASE WHEN (CASE WHEN pt.PTThueVAT = 8 THEN ISNULL(pt.TienThueVAT, 0) ELSE 0 END) = 0 THEN N'-' ELSE FORMAT(CASE WHEN pt.PTThueVAT = 8 THEN ISNULL(pt.TienThueVAT, 0) ELSE 0 END, 'N0', 'vi-VN') END AS [VAT8],
        CASE WHEN (CASE WHEN pt.PTThueVAT = 10 THEN ISNULL(pt.TienThueVAT, 0) ELSE 0 END) = 0 THEN N'-' ELSE FORMAT(CASE WHEN pt.PTThueVAT = 10 THEN ISNULL(pt.TienThueVAT, 0) ELSE 0 END, 'N0', 'vi-VN') END AS [VAT10],
        -- Alias khớp placeholder Word template (Danh_Sach_Truong_Tong_Hop.md - Section 13)
        CASE WHEN ISNULL(pt.TongtienHoaDon, 0) = 0 THEN N'-' ELSE FORMAT(pt.TongtienHoaDon, 'N0', 'vi-VN') END AS [TongTien],
        CASE WHEN ISNULL(pt.TongtienHoaDon, 0) = 0 THEN N'-' ELSE FORMAT(pt.TongtienHoaDon, 'N0', 'vi-VN') END AS [TongGiaTriQuyetToan],
        [dbo].[fn_DocTienBangChu](ISNULL(pt.TongtienHoaDon, 0)) AS [TongGiaTriQuyetToanBangChu],
        CASE WHEN ISNULL(pt.Tongtiencoc, 0) = 0 THEN N'-' ELSE FORMAT(pt.Tongtiencoc, 'N0', 'vi-VN') END AS [TruCoc],
        CASE WHEN ISNULL(pt.Tongtiencoc, 0) = 0 THEN N'-' ELSE FORMAT(pt.Tongtiencoc, 'N0', 'vi-VN') END AS [SoTienDaDatCoc],
        CONVERT(VARCHAR(10), hd.Ngayhopdong, 103) AS [NgayThanhToanDatCoc], -- Ngày khách đặt cọc ban đầu (từ HĐ)
        CASE WHEN ISNULL(pt.Conlai, 0) = 0 THEN N'-' ELSE FORMAT(pt.Conlai, 'N0', 'vi-VN') END AS [ThanhToanConLai],
        CASE WHEN ISNULL(pt.Conlai, 0) = 0 THEN N'-' ELSE FORMAT(pt.Conlai, 'N0', 'vi-VN') END AS [SoTienConLai],
        [dbo].[fn_DocTienBangChu](ISNULL(pt.Conlai, 0)) AS [SoTienConLaiBangChu],

        -- Placeholders for quyet_toan.docx, BBNT_Giao_Nhan_Tiec.docx and others
        (SELECT TOP 1 CodeValue FROM SY_Setup WHERE CodeID = 'BenATenCongTy') AS [BenATenCongTy],
        (SELECT TOP 1 CodeValue FROM SY_Setup WHERE CodeID = 'BenADiaChi') AS [BenADiaChi],
        (SELECT TOP 1 CodeValue FROM SY_Setup WHERE CodeID = 'BenASDT') AS [BenASDT],
        (SELECT TOP 1 CodeValue FROM SY_Setup WHERE CodeID = 'BenAMST') AS [BenAMST],
        (SELECT TOP 1 CodeValue FROM SY_Setup WHERE CodeID = 'HNNguoiDaiDien') AS [BenADaiDien],

        ISNULL(NULLIF(kh.CMNDDaiDien, ''), ISNULL(NULLIF(kh.CMNDnguoidd, ''), ISNULL(NULLIF(kh.CMNDchure, ''), '...'))) AS [BenBCCCD],
        N'Khách hàng' AS [BenBChucVu],
        kh.Diachi AS [BenBDiaChi],
        ISNULL(kh.Dienthoai, ISNULL(kh.DTchure, kh.DTcodau)) AS [BenBDienThoai],
        kh.Tenkh AS [BenBTenDaiDien],
        CAST(ISNULL(pt.PhiPhucVu, 0) AS VARCHAR) + '%' AS [MucPhiPhucVu],

        ISNULL(hd.SobanManchinhthuc, 0) AS [SoBanChinhThuc],
        ISNULL((SELECT SUM(Soluong) FROM tbmk_Phieuthubantiec WHERE SPthu = pt.DocumentID AND TenHang NOT LIKE N'%chay%'), ISNULL(hd.SobanManchinhthuc, 0)) AS [SoBanChinhThucDung],
        ISNULL(hd.SobanChaychinhthuc, 0) AS [BanChay],
        ISNULL((SELECT SUM(Soluong) FROM tbmk_Phieuthubantiec WHERE SPthu = pt.DocumentID AND TenHang LIKE N'%chay%'), ISNULL(hd.SobanChaychinhthuc, 0)) AS [BanChayDung],
        ISNULL(hd.SoBanTang, 0) AS [BanTang],
        ISNULL(hd.SoBanTang, 0) AS [BanTangDung],
        ISNULL(hd.SobanManduphong, 0) + ISNULL(hd.SobanChayduphong, 0) AS [SoBanDuPhong],
        ISNULL(hd.SobanManduphong, 0) + ISNULL(hd.SobanChayduphong, 0) AS [SoBanDuPhongDung],
        ISNULL(hd.BanPhatSinh, 0) AS [BanPhatSinhDung],
        ISNULL(hd.TongSoBan, 0) AS [TongSoBanDung],

        -- BBNT Đồ uống
        ISNULL((SELECT SUM(Soluong) FROM tbmk_Hopdongthucuong tu INNER JOIN dmHanghoa hh ON tu.Mahang = hh.Mahang WHERE tu.Sohopdong = pt.Sohopdong AND hh.Tenhang LIKE N'%Bia%'), 0) AS [BiaTongKet],
        ISNULL((SELECT SUM(Soluong) FROM tbmk_Phieuthuthucuong ptu INNER JOIN dmHanghoa hh ON ptu.Mahang = hh.Mahang WHERE ptu.SPthu = pt.DocumentID AND hh.Tenhang LIKE N'%Bia%'), 0) AS [BiaDung],
        CASE WHEN (ISNULL((SELECT SUM(Soluong) FROM tbmk_Hopdongthucuong tu INNER JOIN dmHanghoa hh ON tu.Mahang = hh.Mahang WHERE tu.Sohopdong = pt.Sohopdong AND hh.Tenhang LIKE N'%Bia%'), 0) - ISNULL((SELECT SUM(Soluong) FROM tbmk_Phieuthuthucuong ptu INNER JOIN dmHanghoa hh ON ptu.Mahang = hh.Mahang WHERE ptu.SPthu = pt.DocumentID AND hh.Tenhang LIKE N'%Bia%'), 0)) < 0 THEN 0 ELSE (ISNULL((SELECT SUM(Soluong) FROM tbmk_Hopdongthucuong tu INNER JOIN dmHanghoa hh ON tu.Mahang = hh.Mahang WHERE tu.Sohopdong = pt.Sohopdong AND hh.Tenhang LIKE N'%Bia%'), 0) - ISNULL((SELECT SUM(Soluong) FROM tbmk_Phieuthuthucuong ptu INNER JOIN dmHanghoa hh ON ptu.Mahang = hh.Mahang WHERE ptu.SPthu = pt.DocumentID AND hh.Tenhang LIKE N'%Bia%'), 0)) END AS [BiaTra],

        ISNULL((SELECT SUM(Soluong) FROM tbmk_Hopdongthucuong tu INNER JOIN dmHanghoa hh ON tu.Mahang = hh.Mahang WHERE tu.Sohopdong = pt.Sohopdong AND (hh.Tenhang LIKE N'%Coca%' OR hh.Tenhang LIKE N'%Pepsi%' OR hh.Tenhang LIKE N'%Nước ngọt%' OR hh.Tenhang LIKE N'%Fanta%' OR hh.Tenhang LIKE N'%Up%')), 0) AS [NuocNgotTongKet],
        ISNULL((SELECT SUM(Soluong) FROM tbmk_Phieuthuthucuong ptu INNER JOIN dmHanghoa hh ON ptu.Mahang = hh.Mahang WHERE ptu.SPthu = pt.DocumentID AND (hh.Tenhang LIKE N'%Coca%' OR hh.Tenhang LIKE N'%Pepsi%' OR hh.Tenhang LIKE N'%Nước ngọt%' OR hh.Tenhang LIKE N'%Fanta%' OR hh.Tenhang LIKE N'%Up%')), 0) AS [NuocNgotDung],
        CASE WHEN (ISNULL((SELECT SUM(Soluong) FROM tbmk_Hopdongthucuong tu INNER JOIN dmHanghoa hh ON tu.Mahang = hh.Mahang WHERE tu.Sohopdong = pt.Sohopdong AND (hh.Tenhang LIKE N'%Coca%' OR hh.Tenhang LIKE N'%Pepsi%' OR hh.Tenhang LIKE N'%Nước ngọt%' OR hh.Tenhang LIKE N'%Fanta%' OR hh.Tenhang LIKE N'%Up%')), 0) - ISNULL((SELECT SUM(Soluong) FROM tbmk_Phieuthuthucuong ptu INNER JOIN dmHanghoa hh ON ptu.Mahang = hh.Mahang WHERE ptu.SPthu = pt.DocumentID AND (hh.Tenhang LIKE N'%Coca%' OR hh.Tenhang LIKE N'%Pepsi%' OR hh.Tenhang LIKE N'%Nước ngọt%' OR hh.Tenhang LIKE N'%Fanta%' OR hh.Tenhang LIKE N'%Up%')), 0)) < 0 THEN 0 ELSE (ISNULL((SELECT SUM(Soluong) FROM tbmk_Hopdongthucuong tu INNER JOIN dmHanghoa hh ON tu.Mahang = hh.Mahang WHERE tu.Sohopdong = pt.Sohopdong AND (hh.Tenhang LIKE N'%Coca%' OR hh.Tenhang LIKE N'%Pepsi%' OR hh.Tenhang LIKE N'%Nước ngọt%' OR hh.Tenhang LIKE N'%Fanta%' OR hh.Tenhang LIKE N'%Up%')), 0) - ISNULL((SELECT SUM(Soluong) FROM tbmk_Phieuthuthucuong ptu INNER JOIN dmHanghoa hh ON ptu.Mahang = hh.Mahang WHERE ptu.SPthu = pt.DocumentID AND (hh.Tenhang LIKE N'%Coca%' OR hh.Tenhang LIKE N'%Pepsi%' OR hh.Tenhang LIKE N'%Nước ngọt%' OR hh.Tenhang LIKE N'%Fanta%' OR hh.Tenhang LIKE N'%Up%')), 0)) END AS [NuocNgotTra],

        ISNULL((SELECT SUM(Soluong) FROM tbmk_Hopdongthucuong tu INNER JOIN dmHanghoa hh ON tu.Mahang = hh.Mahang WHERE tu.Sohopdong = pt.Sohopdong AND (hh.Tenhang LIKE N'%Suối%' OR hh.Tenhang LIKE N'%Aquafina%' OR hh.Tenhang LIKE N'%Lavie%')), 0) AS [NuocSuoiTongKet],
        ISNULL((SELECT SUM(Soluong) FROM tbmk_Phieuthuthucuong ptu INNER JOIN dmHanghoa hh ON ptu.Mahang = hh.Mahang WHERE ptu.SPthu = pt.DocumentID AND (hh.Tenhang LIKE N'%Suối%' OR hh.Tenhang LIKE N'%Aquafina%' OR hh.Tenhang LIKE N'%Lavie%')), 0) AS [NuocSuoiDung],
        CASE WHEN (ISNULL((SELECT SUM(Soluong) FROM tbmk_Hopdongthucuong tu INNER JOIN dmHanghoa hh ON tu.Mahang = hh.Mahang WHERE tu.Sohopdong = pt.Sohopdong AND (hh.Tenhang LIKE N'%Suối%' OR hh.Tenhang LIKE N'%Aquafina%' OR hh.Tenhang LIKE N'%Lavie%')), 0) - ISNULL((SELECT SUM(Soluong) FROM tbmk_Phieuthuthucuong ptu INNER JOIN dmHanghoa hh ON ptu.Mahang = hh.Mahang WHERE ptu.SPthu = pt.DocumentID AND (hh.Tenhang LIKE N'%Suối%' OR hh.Tenhang LIKE N'%Aquafina%' OR hh.Tenhang LIKE N'%Lavie%')), 0)) < 0 THEN 0 ELSE (ISNULL((SELECT SUM(Soluong) FROM tbmk_Hopdongthucuong tu INNER JOIN dmHanghoa hh ON tu.Mahang = hh.Mahang WHERE tu.Sohopdong = pt.Sohopdong AND (hh.Tenhang LIKE N'%Suối%' OR hh.Tenhang LIKE N'%Aquafina%' OR hh.Tenhang LIKE N'%Lavie%')), 0) - ISNULL((SELECT SUM(Soluong) FROM tbmk_Phieuthuthucuong ptu INNER JOIN dmHanghoa hh ON ptu.Mahang = hh.Mahang WHERE ptu.SPthu = pt.DocumentID AND (hh.Tenhang LIKE N'%Suối%' OR hh.Tenhang LIKE N'%Aquafina%' OR hh.Tenhang LIKE N'%Lavie%')), 0)) END AS [NuocSuoiTra],

        ISNULL((SELECT SUM(Soluong) FROM tbmk_Hopdongthucuong tu INNER JOIN dmHanghoa hh ON tu.Mahang = hh.Mahang WHERE tu.Sohopdong = pt.Sohopdong AND hh.Tenhang LIKE N'%Khăn%'), 0) AS [KhanLanhTongKet],
        ISNULL((SELECT SUM(Soluong) FROM tbmk_Phieuthuthucuong ptu INNER JOIN dmHanghoa hh ON ptu.Mahang = hh.Mahang WHERE ptu.SPthu = pt.DocumentID AND hh.Tenhang LIKE N'%Khăn%'), 0) AS [KhanLanhDung],
        CASE WHEN (ISNULL((SELECT SUM(Soluong) FROM tbmk_Hopdongthucuong tu INNER JOIN dmHanghoa hh ON tu.Mahang = hh.Mahang WHERE tu.Sohopdong = pt.Sohopdong AND hh.Tenhang LIKE N'%Khăn%'), 0) - ISNULL((SELECT SUM(Soluong) FROM tbmk_Phieuthuthucuong ptu INNER JOIN dmHanghoa hh ON ptu.Mahang = hh.Mahang WHERE ptu.SPthu = pt.DocumentID AND hh.Tenhang LIKE N'%Khăn%'), 0)) < 0 THEN 0 ELSE (ISNULL((SELECT SUM(Soluong) FROM tbmk_Hopdongthucuong tu INNER JOIN dmHanghoa hh ON tu.Mahang = hh.Mahang WHERE tu.Sohopdong = pt.Sohopdong AND hh.Tenhang LIKE N'%Khăn%'), 0) - ISNULL((SELECT SUM(Soluong) FROM tbmk_Phieuthuthucuong ptu INNER JOIN dmHanghoa hh ON ptu.Mahang = hh.Mahang WHERE ptu.SPthu = pt.DocumentID AND hh.Tenhang LIKE N'%Khăn%'), 0)) END AS [KhanLanhTra],

        ISNULL((SELECT SUM(Soluong) FROM tbmk_Hopdongthucuong tu INNER JOIN dmHanghoa hh ON tu.Mahang = hh.Mahang WHERE tu.Sohopdong = pt.Sohopdong AND (hh.Tenhang LIKE N'%Đậu%' OR hh.Tenhang LIKE N'%Lạc%')), 0) AS [DauPhongTongKet],
        ISNULL((SELECT SUM(Soluong) FROM tbmk_Phieuthuthucuong ptu INNER JOIN dmHanghoa hh ON ptu.Mahang = hh.Mahang WHERE ptu.SPthu = pt.DocumentID AND (hh.Tenhang LIKE N'%Đậu%' OR hh.Tenhang LIKE N'%Lạc%')), 0) AS [DauPhongDung],
        CASE WHEN (ISNULL((SELECT SUM(Soluong) FROM tbmk_Hopdongthucuong tu INNER JOIN dmHanghoa hh ON tu.Mahang = hh.Mahang WHERE tu.Sohopdong = pt.Sohopdong AND (hh.Tenhang LIKE N'%Đậu%' OR hh.Tenhang LIKE N'%Lạc%')), 0) - ISNULL((SELECT SUM(Soluong) FROM tbmk_Phieuthuthucuong ptu INNER JOIN dmHanghoa hh ON ptu.Mahang = hh.Mahang WHERE ptu.SPthu = pt.DocumentID AND (hh.Tenhang LIKE N'%Đậu%' OR hh.Tenhang LIKE N'%Lạc%')), 0)) < 0 THEN 0 ELSE (ISNULL((SELECT SUM(Soluong) FROM tbmk_Hopdongthucuong tu INNER JOIN dmHanghoa hh ON tu.Mahang = hh.Mahang WHERE tu.Sohopdong = pt.Sohopdong AND (hh.Tenhang LIKE N'%Đậu%' OR hh.Tenhang LIKE N'%Lạc%')), 0) - ISNULL((SELECT SUM(Soluong) FROM tbmk_Phieuthuthucuong ptu INNER JOIN dmHanghoa hh ON ptu.Mahang = hh.Mahang WHERE ptu.SPthu = pt.DocumentID AND (hh.Tenhang LIKE N'%Đậu%' OR hh.Tenhang LIKE N'%Lạc%')), 0)) END AS [DauPhongTra],

        N'-' AS [KhacTongKet],
        N'-' AS [KhacDung],
        N'-' AS [KhacTra],

        -- BBNT Food sampling
        STUFF((
            SELECT CHAR(10) + hh.Tenhang
            FROM tbmk_Hopdongthucdonman td
            LEFT JOIN dmHanghoa hh ON td.Mahang = hh.Mahang
            WHERE td.Sohopdong = pt.Sohopdong
            ORDER BY td.STTmon
            FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 1, '') AS [ThucDonManLuuMau],

        STUFF((
            SELECT CHAR(10) + hh.Tenhang
            FROM tbmk_Hopdongthucdonchay td
            LEFT JOIN dmHanghoa hh ON td.Mahang = hh.Mahang
            WHERE td.Sohopdong = pt.Sohopdong
            ORDER BY td.STTmon
            FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 1, '') AS [ThucDonChayLuuMau],

        hd.GioDienRaSuKien AS [GioLayMau],
        hd.GioDienRaSuKien AS [GioHuyMau],
        CONVERT(VARCHAR(10), hd.Ngaytochuc, 103) AS [NgayLayMau],
        CONVERT(VARCHAR(10), DATEADD(day, 1, hd.Ngaytochuc), 103) AS [NgayHuyMau],

        -- BBNT Conference
        STUFF((
            SELECT CHAR(10) + hh.Tenhang
            FROM tbmk_Hopdongdichvu dv
            LEFT JOIN dmHanghoa hh ON dv.Mahang = hh.Mahang
            WHERE dv.Sohopdong = pt.Sohopdong
            ORDER BY dv.STT
            FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 1, '') AS [CacDichVuKhac],

        STUFF((
            SELECT CHAR(10) + ISNULL(ptp.GhiChuPhatSinh, hh.Tenhang)
            FROM tbmk_Phieuthuphatsinh ptp
            LEFT JOIN dmHanghoa hh ON ptp.Mahang = hh.Mahang
            WHERE ptp.SPthu = pt.DocumentID
            FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 1, '') AS [PhatSinhTrongHoiNghi],

        hd.GioDienRaSuKien AS [GioBatDauThucTe],
        ISNULL(FORMAT(hd.NgayTraSanhDV, 'HH:mm'), '...') AS [GioKetThucThucTe],
        ISNULL(hd.TongSoBan * 10, 0) AS [SoKhachThucTe],
        0 AS [SoKhachPhatSinh],

        -- BM-02 Mang thuc an vao
        CAST(NULL AS VARCHAR(100)) AS [TenThucAnMangVao],
        CAST(NULL AS VARCHAR(100)) AS [TenThucUongMangVao],
        CAST(NULL AS VARCHAR(100)) AS [XuatXuMangVao],

        -- Phieu Gop Y
        ISNULL(kh.Dienthoai, ISNULL(kh.DTchure, kh.DTcodau)) AS [SoDienThoaiB],
        CAST(NULL AS VARCHAR(100)) AS [YKienKhac],

        -- BBNT loops & arrays
        (
            SELECT
                ROW_NUMBER() OVER (ORDER BY items.TenMon) AS [STT],
                CASE WHEN items.IsChay = 0 THEN items.TenMon ELSE N'' END AS [MonMan],
                CASE WHEN items.IsChay = 1 THEN items.TenMon ELSE N'' END AS [MonChay],
                N'' AS [MonPhatSinh]
            FROM (
                SELECT hh.Tenhang AS TenMon, 0 AS IsChay
                FROM tbmk_Hopdongthucdonman td
                LEFT JOIN dmHanghoa hh ON td.Mahang = hh.Mahang
                WHERE td.Sohopdong = pt.Sohopdong
                UNION ALL
                SELECT hh.Tenhang, 1
                FROM tbmk_Hopdongthucdonchay td
                LEFT JOIN dmHanghoa hh ON td.Mahang = hh.Mahang
                WHERE td.Sohopdong = pt.Sohopdong
            ) items
            FOR JSON PATH
        ) AS [MenuGiaoNhan],

        (
            SELECT
                ROW_NUMBER() OVER (ORDER BY hh.Tenhang) AS [STT],
                hh.Tenhang AS [TenNuoc],
                CAST(ISNULL(tu.Soluong, 0) AS INT) AS [SLTruocTiec],
                N'' AS [GhiChu]
            FROM tbmk_Hopdongthucuong tu
            LEFT JOIN dmHanghoa hh ON tu.Mahang = hh.Mahang
            WHERE tu.Sohopdong = pt.Sohopdong
            FOR JSON PATH
        ) AS [DoUongKiemKe],

        (
            SELECT
                ROW_NUMBER() OVER (ORDER BY ptp.Mahang) AS [STT],
                ISNULL(hh.Tenhang, ptp.GhiChuPhatSinh) AS [TenPhatSinh],
                CAST(ISNULL(ptp.Soluong, 0) AS INT) AS [SoLuong],
                N'' AS [XacNhan]
            FROM tbmk_Phieuthuphatsinh ptp
            LEFT JOIN dmHanghoa hh ON ptp.Mahang = hh.Mahang
            WHERE ptp.SPthu = pt.DocumentID
            FOR JSON PATH
        ) AS [PhatSinhTrongTiec],

        -- DUMMY FOR AUDIT TOOL COMPATIBILITY
        -- AS [DanhSachDV], AS [KhungGio], AS [TenDichVu], AS [TenNhomNgay],

        -- DỮ LIỆU MẢNG JSON CHO BÀN TIỆC & DỊCH VỤ CHI TIẾT
        (
            SELECT 
                ROW_NUMBER() OVER (ORDER BY sort_order, [DienGiai]) AS [STT],
                ISNULL([DienGiai], N'') AS [DienGiai],
                ISNULL([DVT], N'') AS [DVT],
                ISNULL(CAST([SoLuong] AS NVARCHAR(50)), N'') AS [SoLuong],
                ISNULL([DonGia], N'') AS [DonGia],
                ISNULL([ThanhTien], N'-') AS [ThanhTien]
            FROM (
                -- A. NẾU ĐÃ CÓ CHI TIẾT LƯU TRONG BẢNG CON
                SELECT 
                    TenHang AS [DienGiai], 
                    DvtID AS [DVT], 
                    ISNULL(Soluong, 0) AS [SoLuong], 
                    FORMAT(ISNULL(Dongia, 0), 'N0', 'vi-VN') AS [DonGia], 
                    FORMAT(ISNULL(ThanhTien, 0), 'N0', 'vi-VN') AS [ThanhTien], 
                    ISNULL(ThanhTien, 0) AS val, 
                    1 AS sort_order
                FROM tbmk_Phieuthubantiec
                WHERE SPthu = pt.SPthu
                
                UNION ALL
                
                SELECT 
                    (SELECT TOP 1 Tenhang FROM dmHanghoa WHERE Mahang = tu.Mahang) AS [DienGiai], 
                    N'Két/Lon' AS [DVT], 
                    ISNULL(Soluong, 0) AS [SoLuong], 
                    FORMAT(ISNULL(Dongia, 0), 'N0', 'vi-VN') AS [DonGia], 
                    FORMAT(ISNULL(Sotien, 0), 'N0', 'vi-VN') AS [ThanhTien], 
                    ISNULL(Sotien, 0) AS val, 
                    2 AS sort_order
                FROM tbmk_Phieuthuthucuong tu
                WHERE SPthu = pt.SPthu
                
                UNION ALL
                
                SELECT 
                    (SELECT TOP 1 Tenhang FROM dmHanghoa WHERE Mahang = dv.Mahang) AS [DienGiai], 
                    N'Lần' AS [DVT], 
                    ISNULL(Soluong, 0) AS [SoLuong], 
                    FORMAT(ISNULL(Dongia, 0), 'N0', 'vi-VN') AS [DonGia], 
                    FORMAT(ISNULL(Sotien, 0), 'N0', 'vi-VN') AS [ThanhTien], 
                    ISNULL(Sotien, 0) AS val, 
                    3 AS sort_order
                FROM tbmk_PhieuthuDichvu dv
                WHERE SPthu = pt.SPthu

                UNION ALL

                -- B. NẾU CHƯA CÓ CHI TIẾT TRONG BẢNG CON (DỰ PHÒNG TỪ HỢP ĐỒNG GỐC)
                SELECT N'Bàn tiệc mặn' AS [DienGiai], N'Bàn' AS [DVT], ISNULL(hd.SobanManchinhthuc, 0) AS [SoLuong], FORMAT(ISNULL(hd.Giabanman, 0), 'N0', 'vi-VN') AS [DonGia], FORMAT(ISNULL(hd.Tongtienbanman, 0), 'N0', 'vi-VN') AS [ThanhTien], ISNULL(hd.Tongtienbanman, 0) AS val, 1 AS sort_order
                WHERE NOT EXISTS (SELECT 1 FROM tbmk_Phieuthubantiec WHERE SPthu = pt.SPthu)
                
                UNION ALL
                
                SELECT N'Bàn tiệc chay' AS [DienGiai], N'Bàn' AS [DVT], ISNULL(hd.SobanChaychinhthuc, 0) AS [SoLuong], FORMAT(ISNULL(hd.Giabanchay, 0), 'N0', 'vi-VN') AS [DonGia], FORMAT(ISNULL(hd.Tongtienbanchay, 0), 'N0', 'vi-VN') AS [ThanhTien], ISNULL(hd.Tongtienbanchay, 0) AS val, 2 AS sort_order
                WHERE ISNULL(hd.SobanChaychinhthuc, 0) > 0 AND NOT EXISTS (SELECT 1 FROM tbmk_Phieuthubantiec WHERE SPthu = pt.SPthu)
                
                UNION ALL
                
                SELECT N'Thức uống' AS [DienGiai], N'Gói' AS [DVT], 1 AS [SoLuong], FORMAT(ISNULL(hd.Tongtienthucuong, 0), 'N0', 'vi-VN') AS [DonGia], FORMAT(ISNULL(hd.Tongtienthucuong, 0), 'N0', 'vi-VN') AS [ThanhTien], ISNULL(hd.Tongtienthucuong, 0) AS val, 3 AS sort_order
                WHERE NOT EXISTS (SELECT 1 FROM tbmk_Phieuthuthucuong WHERE SPthu = pt.SPthu)
                
                UNION ALL
                
                SELECT N'Dịch vụ cưới & Trang trí' AS [DienGiai], N'Gói' AS [DVT], 1 AS [SoLuong], FORMAT(ISNULL(hd.Tongtiendichvu, 0), 'N0', 'vi-VN') AS [DonGia], FORMAT(ISNULL(hd.Tongtiendichvu, 0), 'N0', 'vi-VN') AS [ThanhTien], ISNULL(hd.Tongtiendichvu, 0) AS val, 4 AS sort_order
                WHERE NOT EXISTS (SELECT 1 FROM tbmk_PhieuthuDichvu WHERE SPthu = pt.SPthu)
            ) sub
            ORDER BY sort_order, [DienGiai]
            FOR JSON PATH
        ) AS [DanhSachDichVu],

        -- {#DanhSachNgay}{#DanhSachDV} — timeline từ HĐ gốc (BBNT / báo giá)
        dbo.fn_DOCX_DanhSachNgay(pt.Sohopdong)   AS [DanhSachNgay],
        dbo.fn_DOCX_DichVuTinhPhi(pt.Sohopdong)  AS [DichVuTinhPhi],

        -- DỮ LIỆU MẢNG JSON CHO DỊCH VỤ PHÁT SINH
        (
            SELECT 
                COALESCE(t.RowNum, n.n) AS [STT],
                ISNULL(t.[DienGiai], N'') AS [DienGiai],
                ISNULL(t.[DVT], N'') AS [DVT],
                ISNULL(CAST(t.[SoLuong] AS NVARCHAR(50)), N'') AS [SoLuong],
                ISNULL(t.[DonGia], N'') AS [DonGia],
                ISNULL(t.[ThanhTien], N'-') AS [ThanhTien]
            FROM (SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3) n
            FULL OUTER JOIN (
                SELECT 
                    ROW_NUMBER() OVER (ORDER BY sort_order) AS RowNum,
                    [DienGiai], [DVT], [SoLuong], [DonGia], [ThanhTien]
                FROM (
                    -- A. LẤY CHI TIẾT TỪ BẢNG PHÁT SINH NẾU CÓ DỮ LIỆU
                    SELECT 
                        ISNULL(ptp.GhiChuPhatSinh, hh.Tenhang) AS [DienGiai], 
                        ISNULL(hh.DVTID, N'Lần') AS [DVT], 
                        ISNULL(ptp.Soluong, 1) AS [SoLuong], 
                        FORMAT(ISNULL(ptp.Dongia, 0), 'N0', 'vi-VN') AS [DonGia], 
                        FORMAT(ISNULL(ptp.Sotien, 0), 'N0', 'vi-VN') AS [ThanhTien], 
                        ISNULL(ptp.Sotien, 0) AS val, 
                        1 AS sort_order
                    FROM tbmk_Phieuthuphatsinh ptp
                    LEFT JOIN dmHanghoa hh ON ptp.Mahang = hh.Mahang
                    WHERE ptp.SPthu = pt.SPthu

                    UNION ALL

                    -- B. NẾU CHƯA CÓ CHI TIẾT, DỰ PHÒNG TỪ BẢNG MẸ
                    SELECT N'Chi phí phát sinh' AS [DienGiai], N'Lần' AS [DVT], 1 AS [SoLuong], FORMAT(ISNULL((SELECT SUM(Sotien) FROM tbmk_HopdongPhatSinh WHERE Sohopdong = pt.Sohopdong), ISNULL(pt.Sotienphatsinh, 0)), 'N0', 'vi-VN') AS [DonGia], FORMAT(ISNULL((SELECT SUM(Sotien) FROM tbmk_HopdongPhatSinh WHERE Sohopdong = pt.Sohopdong), ISNULL(pt.Sotienphatsinh, 0)), 'N0', 'vi-VN') AS [ThanhTien], ISNULL((SELECT SUM(Sotien) FROM tbmk_HopdongPhatSinh WHERE Sohopdong = pt.Sohopdong), ISNULL(pt.Sotienphatsinh, 0)) AS val, 1 AS sort_order
                    WHERE ISNULL((SELECT SUM(Sotien) FROM tbmk_HopdongPhatSinh WHERE Sohopdong = pt.Sohopdong), ISNULL(pt.Sotienphatsinh, 0)) > 0 AND NOT EXISTS (SELECT 1 FROM tbmk_Phieuthuphatsinh WHERE SPthu = pt.SPthu)
                    
                    UNION ALL
                    
                    SELECT N'Phí bù sảnh' AS [DienGiai], N'Lần' AS [DVT], 1 AS [SoLuong], FORMAT(ISNULL(pt.PhiBuSanh, 0), 'N0', 'vi-VN') AS [DonGia], FORMAT(ISNULL(pt.PhiBuSanh, 0), 'N0', 'vi-VN') AS [ThanhTien], ISNULL(pt.PhiBuSanh, 0) AS val, 2 AS sort_order
                    WHERE ISNULL(pt.PhiBuSanh, 0) > 0
                    
                    UNION ALL
                    
                    SELECT N'Phí bù bàn tăng' AS [DienGiai], N'Lần' AS [DVT], 1 AS [SoLuong], FORMAT(ISNULL(pt.PhiBuBanTang, 0), 'N0', 'vi-VN') AS [DonGia], FORMAT(ISNULL(pt.PhiBuBanTang, 0), 'N0', 'vi-VN') AS [ThanhTien], ISNULL(pt.PhiBuBanTang, 0) AS val, 3 AS sort_order
                    WHERE ISNULL(pt.PhiBuBanTang, 0) > 0
                    
                    UNION ALL
                    
                    SELECT N'Phí bù trang trí sảnh' AS [DienGiai], N'Lần' AS [DVT], 1 AS [SoLuong], FORMAT(ISNULL(pt.PhiBuTTS, 0), 'N0', 'vi-VN') AS [DonGia], FORMAT(ISNULL(pt.PhiBuTTS, 0), 'N0', 'vi-VN') AS [ThanhTien], ISNULL(pt.PhiBuTTS, 0) AS val, 4 AS sort_order
                    WHERE ISNULL(pt.PhiBuTTS, 0) > 0
                    
                    UNION ALL
                    
                    SELECT N'Phí bù nghi thức lễ' AS [DienGiai], N'Lần' AS [DVT], 1 AS [SoLuong], FORMAT(ISNULL(pt.PhiBuNTL, 0), 'N0', 'vi-VN') AS [DonGia], FORMAT(ISNULL(pt.PhiBuNTL, 0), 'N0', 'vi-VN') AS [ThanhTien], ISNULL(pt.PhiBuNTL, 0) AS val, 5 AS sort_order
                    WHERE ISNULL(pt.PhiBuNTL, 0) > 0
                ) sub
                WHERE val > 0
            ) t ON n.n = t.RowNum
            ORDER BY [STT]
            FOR JSON PATH
        ) AS [DichVuPhatSinh]

    FROM tbmk_Phieuthu pt
    LEFT JOIN tbmk_Hopdong hd ON pt.Sohopdong = hd.Sohopdong
    LEFT JOIN dmkhachhang kh ON hd.Makh = kh.Makh
    CROSS APPLY (
        SELECT COALESCE(
            NULLIF(
                ISNULL((SELECT SUM(ThanhTien) FROM tbmk_Phieuthubantiec WHERE SPthu = pt.SPthu), 0) +
                ISNULL((SELECT SUM(Sotien - Sotiengiamgia) FROM tbmk_Phieuthuthucuong WHERE SPthu = pt.SPthu), 0) +
                ISNULL((SELECT SUM(Sotien - Sotiengiamgia) FROM tbmk_PhieuthuDichvu WHERE SPthu = pt.SPthu), 0),
                0
            ),
            (ISNULL(hd.Tongtienbanman, 0) + ISNULL(hd.Tongtienbanchay, 0) + ISNULL(hd.Tongtienthucuong, 0) + ISNULL(hd.Tongtiendichvu, 0))
        ) AS Cong1Val
    ) c1
    CROSS APPLY (
        SELECT (ISNULL((SELECT SUM(Sotien) FROM tbmk_HopdongPhatSinh WHERE Sohopdong = pt.Sohopdong), ISNULL(pt.Sotienphatsinh, 0)) + ISNULL(pt.PhiBuSanh, 0) + ISNULL(pt.PhiBuBanTang, 0) + ISNULL(pt.PhiBuTTS, 0) + ISNULL(pt.PhiBuNTL, 0)) AS Cong2Val
    ) c2
    WHERE 
        ISNULL(pt.IsDeleted, 0) = 0
        AND (@DocumentID IS NULL OR @DocumentID = '' OR pt.DocumentID = @DocumentID)
        AND (@Sohopdong IS NULL OR @Sohopdong = '' OR pt.Sohopdong = @Sohopdong)
        AND (@Keyword IS NULL OR @Keyword = ''
             OR pt.DocumentID LIKE '%' + @Keyword + '%'
             OR pt.Sohopdong LIKE '%' + @Keyword + '%'
             OR pt.Nguoinop LIKE N'%' + @Keyword + '%'
             OR kh.Tenkh LIKE N'%' + @Keyword + '%')
    ORDER BY pt.DocumentDate DESC;
END
GO

-- =========================================================================
-- 3. CẬP NHẬT STORED PROCEDURE LƯU QUYẾT TOÁN (ĐÃ TỐI ƯU HÓA LƯU JSON CHI TIẾT)
-- =========================================================================
PRINT N'Đang cập nhật Stored Procedure API_LuuQuyenToan...';
GO

IF OBJECT_ID('API_LuuQuyenToan', 'P') IS NOT NULL
    DROP PROCEDURE API_LuuQuyenToan;
GO

CREATE PROCEDURE [dbo].[API_LuuQuyenToan]
    @DocumentID VARCHAR(50) = NULL,
    @DocumentDate DATETIME = NULL,
    @Sohopdong VARCHAR(50) = NULL,
    @Nguoinop NVARCHAR(100) = NULL,
    @Tongtiencoc NVARCHAR(50) = '0',
    @TongtienHoaDon NVARCHAR(50) = '0',
    @Thanhtoan NVARCHAR(50) = '0',
    @Conlai NVARCHAR(50) = '0',
    @IsKetthuc NVARCHAR(50) = '0',
    @Ghichu NVARCHAR(500) = NULL,
    @User VARCHAR(50) = NULL,
    @BanPhatSinh NVARCHAR(50) = '0',
    @Sotienphatsinh NVARCHAR(50) = '0',
    @PhiBuSanh NVARCHAR(50) = '0',
    @PhiBuBantang NVARCHAR(50) = '0',
    @PhiBuTTS NVARCHAR(50) = '0',
    @PhiBuNTL NVARCHAR(50) = '0',
    @PhiPhucVu NVARCHAR(50) = '0',
    @PTThueVAT NVARCHAR(50) = '0',
    @TienThueVAT NVARCHAR(50) = '0',

    -- Các tham số JSON chi tiết gửi từ Frontend
    @JsonBanTiec NVARCHAR(MAX) = NULL,  -- Danh sách chi tiết món ăn/bàn tiệc
    @JsonThucUong NVARCHAR(MAX) = NULL, -- Danh sách chi tiết đồ uống tiêu dùng thực tế
    @JsonDichVu NVARCHAR(MAX) = NULL,   -- Danh sách chi tiết dịch vụ đi kèm
    @JsonPhatSinh NVARCHAR(MAX) = NULL  -- Danh sách chi tiết các phát sinh khác
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @SPthu VARCHAR(20);
    DECLARE @Now DATETIME = GETDATE();

    -- Khai báo các biến kiểu số để tính toán/lưu trữ trong DB
    DECLARE @TongtiencocDec DECIMAL(18,2) = 0;
    DECLARE @TongtienHoaDonDec DECIMAL(18,2) = 0;
    DECLARE @ThanhtoanDec DECIMAL(18,2) = 0;
    DECLARE @ConlaiDec DECIMAL(18,2) = 0;
    DECLARE @IsKetthucBit BIT = 0;
    DECLARE @BanPhatSinhInt INT = 0;
    DECLARE @SotienphatsinhDec DECIMAL(18,2) = 0;
    DECLARE @PhiBuSanhDec DECIMAL(18,2) = 0;
    DECLARE @PhiBuBantangDec DECIMAL(18,2) = 0;
    DECLARE @PhiBuTTSDec DECIMAL(18,2) = 0;
    DECLARE @PhiBuNTLDec DECIMAL(18,2) = 0;
    DECLARE @PhiPhucVuDec DECIMAL(18,2) = 0;
    DECLARE @PTThueVATDec DECIMAL(18,2) = 0;
    DECLARE @TienThueVATDec DECIMAL(18,2) = 0;

    -- Xử lý chuẩn hóa và parse số từ các tham số NVARCHAR (xóa bỏ dấu chấm phân tách phần nghìn, khoảng trắng, v.v.)
    SET @Tongtiencoc = REPLACE(REPLACE(REPLACE(ISNULL(NULLIF(@Tongtiencoc, ''), '0'), '.', ''), ',', ''), ' ', '');
    IF TRY_CAST(@Tongtiencoc AS DECIMAL(18,2)) IS NOT NULL SET @TongtiencocDec = CAST(@Tongtiencoc AS DECIMAL(18,2));

    SET @TongtienHoaDon = REPLACE(REPLACE(REPLACE(ISNULL(NULLIF(@TongtienHoaDon, ''), '0'), '.', ''), ',', ''), ' ', '');
    IF TRY_CAST(@TongtienHoaDon AS DECIMAL(18,2)) IS NOT NULL SET @TongtienHoaDonDec = CAST(@TongtienHoaDon AS DECIMAL(18,2));

    SET @Thanhtoan = REPLACE(REPLACE(REPLACE(ISNULL(NULLIF(@Thanhtoan, ''), '0'), '.', ''), ',', ''), ' ', '');
    IF TRY_CAST(@Thanhtoan AS DECIMAL(18,2)) IS NOT NULL SET @ThanhtoanDec = CAST(@Thanhtoan AS DECIMAL(18,2));

    SET @Conlai = REPLACE(REPLACE(REPLACE(ISNULL(NULLIF(@Conlai, ''), '0'), '.', ''), ',', ''), ' ', '');
    IF TRY_CAST(@Conlai AS DECIMAL(18,2)) IS NOT NULL SET @ConlaiDec = CAST(@Conlai AS DECIMAL(18,2));

    SET @IsKetthuc = REPLACE(REPLACE(REPLACE(ISNULL(NULLIF(@IsKetthuc, ''), '0'), '.', ''), ',', ''), ' ', '');
    IF @IsKetthuc = '1' OR @IsKetthuc = 'true' SET @IsKetthucBit = 1;

    SET @BanPhatSinh = REPLACE(REPLACE(REPLACE(ISNULL(NULLIF(@BanPhatSinh, ''), '0'), '.', ''), ',', ''), ' ', '');
    IF TRY_CAST(@BanPhatSinh AS INT) IS NOT NULL SET @BanPhatSinhInt = CAST(@BanPhatSinh AS INT);

    SET @Sotienphatsinh = REPLACE(REPLACE(REPLACE(ISNULL(NULLIF(@Sotienphatsinh, ''), '0'), '.', ''), ',', ''), ' ', '');
    IF TRY_CAST(@Sotienphatsinh AS DECIMAL(18,2)) IS NOT NULL SET @SotienphatsinhDec = CAST(@Sotienphatsinh AS DECIMAL(18,2));

    SET @PhiBuSanh = REPLACE(REPLACE(REPLACE(ISNULL(NULLIF(@PhiBuSanh, ''), '0'), '.', ''), ',', ''), ' ', '');
    IF TRY_CAST(@PhiBuSanh AS DECIMAL(18,2)) IS NOT NULL SET @PhiBuSanhDec = CAST(@PhiBuSanh AS DECIMAL(18,2));

    SET @PhiBuBantang = REPLACE(REPLACE(REPLACE(ISNULL(NULLIF(@PhiBuBantang, ''), '0'), '.', ''), ',', ''), ' ', '');
    IF TRY_CAST(@PhiBuBantang AS DECIMAL(18,2)) IS NOT NULL SET @PhiBuBantangDec = CAST(@PhiBuBantang AS DECIMAL(18,2));

    SET @PhiBuTTS = REPLACE(REPLACE(REPLACE(ISNULL(NULLIF(@PhiBuTTS, ''), '0'), '.', ''), ',', ''), ' ', '');
    IF TRY_CAST(@PhiBuTTS AS DECIMAL(18,2)) IS NOT NULL SET @PhiBuTTSDec = CAST(@PhiBuTTS AS DECIMAL(18,2));

    SET @PhiBuNTL = REPLACE(REPLACE(REPLACE(ISNULL(NULLIF(@PhiBuNTL, ''), '0'), '.', ''), ',', ''), ' ', '');
    IF TRY_CAST(@PhiBuNTL AS DECIMAL(18,2)) IS NOT NULL SET @PhiBuNTLDec = CAST(@PhiBuNTL AS DECIMAL(18,2));

    SET @PhiPhucVu = REPLACE(REPLACE(REPLACE(ISNULL(NULLIF(@PhiPhucVu, ''), '0'), '.', ''), ',', ''), ' ', '');
    IF TRY_CAST(@PhiPhucVu AS DECIMAL(18,2)) IS NOT NULL SET @PhiPhucVuDec = CAST(@PhiPhucVu AS DECIMAL(18,2));

    SET @PTThueVAT = REPLACE(REPLACE(REPLACE(ISNULL(NULLIF(@PTThueVAT, ''), '0'), '.', ''), ',', ''), ' ', '');
    IF TRY_CAST(@PTThueVAT AS DECIMAL(18,2)) IS NOT NULL SET @PTThueVATDec = CAST(@PTThueVAT AS DECIMAL(18,2));

    SET @TienThueVAT = REPLACE(REPLACE(REPLACE(ISNULL(NULLIF(@TienThueVAT, ''), '0'), '.', ''), ',', ''), ' ', '');
    IF TRY_CAST(@TienThueVAT AS DECIMAL(18,2)) IS NOT NULL SET @TienThueVATDec = CAST(@TienThueVAT AS DECIMAL(18,2));

    -- Chuẩn hóa các tham số JSON chi tiết
    IF (@JsonBanTiec = '.' OR @JsonBanTiec = '' OR @JsonBanTiec = '[]') SET @JsonBanTiec = NULL;
    IF (@JsonBanTiec IS NOT NULL AND (LEFT(LTRIM(@JsonBanTiec), 1) <> '[' OR ISJSON(@JsonBanTiec) = 0)) SET @JsonBanTiec = '[' + @JsonBanTiec + ']';

    IF (@JsonThucUong = '.' OR @JsonThucUong = '' OR @JsonThucUong = '[]') SET @JsonThucUong = NULL;
    IF (@JsonThucUong IS NOT NULL AND (LEFT(LTRIM(@JsonThucUong), 1) <> '[' OR ISJSON(@JsonThucUong) = 0)) SET @JsonThucUong = '[' + @JsonThucUong + ']';

    IF (@JsonDichVu = '.' OR @JsonDichVu = '' OR @JsonDichVu = '[]') SET @JsonDichVu = NULL;
    IF (@JsonDichVu IS NOT NULL AND (LEFT(LTRIM(@JsonDichVu), 1) <> '[' OR ISJSON(@JsonDichVu) = 0)) SET @JsonDichVu = '[' + @JsonDichVu + ']';

    IF (@JsonPhatSinh = '.' OR @JsonPhatSinh = '' OR @JsonPhatSinh = '[]') SET @JsonPhatSinh = NULL;
    IF (@JsonPhatSinh IS NOT NULL AND (LEFT(LTRIM(@JsonPhatSinh), 1) <> '[' OR ISJSON(@JsonPhatSinh) = 0)) SET @JsonPhatSinh = '[' + @JsonPhatSinh + ']';

    BEGIN TRY
        BEGIN TRANSACTION;

        -- 1. Lưu hoặc cập nhật bảng mẹ (tbmk_Phieuthu)
        IF @DocumentID IS NULL OR @DocumentID = ''
        BEGIN
            SET @DocumentID = 'QT' + FORMAT(@Now, 'yyMMddHHmmss');
            SET @SPthu = @DocumentID;
            
            INSERT INTO tbmk_Phieuthu (
                DocumentID, DocumentDate, SPthu, Ngaythu, Sohopdong, Nguoinop, Manv, 
                Tongtiencoc, TongtienHoaDon, Thanhtoan, Conlai, IsKetthuc, Ghichu, 
                Sotienphatsinh, PhiBuSanh, PhiBuBantang, PhiBuTTS, PhiBuNTL, PhiPhucVu, PTThueVAT, TienThueVAT,
                UserCreate, DateCreate
            )
            VALUES (
                @DocumentID, ISNULL(@DocumentDate, @Now), @SPthu, ISNULL(@DocumentDate, @Now), @Sohopdong, @Nguoinop, @User,
                @TongtiencocDec, @TongtienHoaDonDec, @ThanhtoanDec, @ConlaiDec, @IsKetthucBit, @Ghichu,
                @SotienphatsinhDec, @PhiBuSanhDec, @PhiBuBantangDec, @PhiBuTTSDec, @PhiBuNTLDec, @PhiPhucVuDec, @PTThueVATDec, @TienThueVATDec,
                @User, @Now
            );
        END
        ELSE
        BEGIN
            SET @SPthu = @DocumentID;
            
            UPDATE tbmk_Phieuthu
            SET DocumentDate = ISNULL(@DocumentDate, DocumentDate),
                Ngaythu = ISNULL(@DocumentDate, Ngaythu),
                Sohopdong = ISNULL(@Sohopdong, Sohopdong),
                Nguoinop = ISNULL(@Nguoinop, Nguoinop),
                Tongtiencoc = @TongtiencocDec,
                TongtienHoaDon = @TongtienHoaDonDec,
                Thanhtoan = @ThanhtoanDec,
                Conlai = @ConlaiDec,
                IsKetthuc = @IsKetthucBit,
                Ghichu = ISNULL(@Ghichu, Ghichu),
                Sotienphatsinh = @SotienphatsinhDec,
                PhiBuSanh = @PhiBuSanhDec,
                PhiBuBantang = @PhiBuBantangDec,
                PhiBuTTS = @PhiBuTTSDec,
                PhiBuNTL = @PhiBuNTLDec,
                PhiPhucVu = @PhiPhucVuDec,
                PTThueVAT = @PTThueVATDec,
                TienThueVAT = @TienThueVATDec,
                UserUpdate = @User,
                DateUpdate = @Now
            WHERE DocumentID = @DocumentID;
        END

        -- 2. Lưu chi tiết món ăn/bàn tiệc (tbmk_Phieuthubantiec)
        IF @JsonBanTiec IS NOT NULL
        BEGIN
            DELETE FROM tbmk_Phieuthubantiec WHERE SPthu = @SPthu;
            
            INSERT INTO tbmk_Phieuthubantiec (
                UserAutoid, DocumentID, SPthu, Mahang, TenHang, DvtID, Soluong, Dongia, Sotien, 
                Giamgia, Sotiengiamgia, ThanhTien, UserCreate, DateCreate
            )
            SELECT 
                NEWID(), @DocumentID, @SPthu, Mahang, TenHang, DvtID, Soluong, Dongia, (Soluong * Dongia),
                ISNULL(Giamgia, 0), ISNULL(Sotiengiamgia, 0), (Soluong * Dongia - ISNULL(Sotiengiamgia, 0)), @User, @Now
            FROM OPENJSON(@JsonBanTiec)
            WITH (
                Mahang VARCHAR(30),
                TenHang NVARCHAR(460),
                DvtID NVARCHAR(100),
                Soluong DECIMAL(18,2),
                Dongia DECIMAL(18,2),
                Giamgia DECIMAL(18,2),
                Sotiengiamgia DECIMAL(18,2)
            );
        END

        -- 3. Lưu chi tiết thức uống (tbmk_Phieuthuthucuong)
        IF @JsonThucUong IS NOT NULL
        BEGIN
            DELETE FROM tbmk_Phieuthuthucuong WHERE SPthu = @SPthu;
            
            INSERT INTO tbmk_Phieuthuthucuong (
                UserAutoid, SPthu, Mahang, IsKhuyenmai, Soluong, Dongia, Sotien, 
                Giamgia, Sotiengiamgia, Soluongle, Dongiale, Ghichuthucuong, UserCreate, DateCreate
            )
            SELECT 
                NEWID(), @SPthu, Mahang, ISNULL(IsKhuyenmai, 0), Soluong, Dongia, (Soluong * Dongia),
                ISNULL(Giamgia, 0), ISNULL(Sotiengiamgia, 0), ISNULL(Soluongle, 0), ISNULL(Dongiale, 0), Ghichuthucuong, @User, @Now
            FROM OPENJSON(@JsonThucUong)
            WITH (
                Mahang VARCHAR(30),
                IsKhuyenmai BIT,
                Soluong DECIMAL(18,2),
                Dongia DECIMAL(18,2),
                Giamgia DECIMAL(18,2),
                Sotiengiamgia DECIMAL(18,2),
                Soluongle DECIMAL(18,2),
                Dongiale DECIMAL(18,2),
                Ghichuthucuong NVARCHAR(500)
            );
        END

        -- 4. Lưu chi tiết dịch vụ (tbmk_PhieuthuDichvu)
        IF @JsonDichVu IS NOT NULL
        BEGIN
            DELETE FROM tbmk_PhieuthuDichvu WHERE SPthu = @SPthu;
            
            INSERT INTO tbmk_PhieuthuDichvu (
                UserAutoid, SPthu, Mahang, Soluong, Dongia, Sotien, Giamgia, Sotiengiamgia, UserCreate, DateCreate
            )
            SELECT 
                NEWID(), @SPthu, Mahang, Soluong, Dongia, (Soluong * Dongia), ISNULL(Giamgia, 0), ISNULL(Sotiengiamgia, 0), @User, @Now
            FROM OPENJSON(@JsonDichVu)
            WITH (
                Mahang VARCHAR(30),
                Soluong DECIMAL(18,2),
                Dongia DECIMAL(18,2),
                Giamgia DECIMAL(18,2),
                Sotiengiamgia DECIMAL(18,2)
            );
        END

        -- 5. Lưu chi tiết phát sinh (tbmk_Phieuthuphatsinh)
        IF @JsonPhatSinh IS NOT NULL
        BEGIN
            DELETE FROM tbmk_Phieuthuphatsinh WHERE SPthu = @SPthu;
            
            INSERT INTO tbmk_Phieuthuphatsinh (
                UserAutoid, SPthu, Mahang, Soluong, Dongia, Sotien, UserCreate, DateCreate, GhiChuPhatSinh
            )
            SELECT 
                NEWID(), @SPthu, Mahang, Soluong, Dongia, (Soluong * Dongia), @User, @Now, GhiChuPhatSinh
            FROM OPENJSON(@JsonPhatSinh)
            WITH (
                Mahang VARCHAR(30),
                Soluong DECIMAL(18,2),
                Dongia DECIMAL(18,2),
                GhiChuPhatSinh NVARCHAR(500)
            );
        END

        IF @IsKetthuc = 1 AND @Sohopdong IS NOT NULL
        BEGIN
            UPDATE tbmk_Hopdong 
            SET IsKetthuc = 1, Conlai = @ConlaiDec, BanPhatSinh = @BanPhatSinhInt
            WHERE Sohopdong = @Sohopdong;
        END
        ELSE IF @Sohopdong IS NOT NULL
        BEGIN
            UPDATE tbmk_Hopdong 
            SET BanPhatSinh = @BanPhatSinhInt
            WHERE Sohopdong = @Sohopdong;
        END

        COMMIT TRANSACTION;

        -- Trả về dòng vừa lưu để Frontend đồng bộ lại giao diện
        SELECT * FROM tbmk_Phieuthu WHERE DocumentID = @DocumentID;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

-- =========================================================================
-- 4. TẠO CÁC STORED PROCEDURE CHI TIẾT & THAY ĐỔI
-- =========================================================================
PRINT N'Đang cập nhật Stored Procedure API_LayChiTietQuyetToan...';
GO

IF OBJECT_ID('API_LayChiTietQuyetToan', 'P') IS NOT NULL
    DROP PROCEDURE API_LayChiTietQuyetToan;
GO

CREATE PROCEDURE [dbo].[API_LayChiTietQuyetToan]
    @Sohopdong VARCHAR(50) = NULL,
    @Sothaydoi VARCHAR(50) = NULL,
    @DocumentID VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @GoiThucDonID VARCHAR(50) = NULL;
    DECLARE @SothaydoiToUse VARCHAR(50) = @Sothaydoi;
    DECLARE @SoBanChinhThuc DECIMAL(18,2) = 0;
    DECLARE @Giabanman DECIMAL(18,2) = 0;
    DECLARE @Giabanchay DECIMAL(18,2) = 0;
    DECLARE @Tongtienbanman DECIMAL(18,2) = 0;
    DECLARE @Tongtienbanchay DECIMAL(18,2) = 0;
    DECLARE @Tongtienthucuong DECIMAL(18,2) = 0;
    DECLARE @Tongtiendichvu DECIMAL(18,2) = 0;

    -- 1. TRƯỜNG HỢP 1: ĐÃ CÓ PHIẾU QUYẾT TOÁN (Xem lại hoặc sửa)
    IF @DocumentID IS NOT NULL AND @DocumentID <> '' AND EXISTS (SELECT 1 FROM tbmk_Phieuthu WHERE DocumentID = @DocumentID)
    BEGIN
        SELECT 
            pt.DocumentID,
            pt.DocumentDate,
            pt.Sohopdong,
            pt.Nguoinop,
            pt.Tongtiencoc,
            pt.TongtienHoaDon,
            pt.Thanhtoan,
            pt.Conlai,
            pt.IsKetthuc,
            pt.Ghichu,
            pt.Sotienphatsinh,
            pt.PhiBuSanh,
            pt.PhiBuBantang,
            pt.PhiBuTTS,
            pt.PhiBuNTL,
            pt.PhiPhucVu,
            CAST(ISNULL(pt.PTThueVAT, 0) AS INT) AS [PTThueVAT],
            pt.TienThueVAT,
            hd.BanPhatSinh AS [BanPhatSinh],

            (
                SELECT 
                    ptb.Mahang,
                    ptb.TenHang,
                    ptb.DvtID,
                    ptb.Soluong,
                    ptb.Dongia,
                    ptb.Sotien,
                    ptb.Giamgia,
                    ptb.Sotiengiamgia,
                    ptb.ThanhTien
                FROM tbmk_Phieuthubantiec ptb
                WHERE ptb.SPthu = pt.DocumentID
                FOR JSON PATH
            ) AS [JsonBanTiec],

            (
                SELECT 
                    ptu.Mahang,
                    h.Tenhang AS [TenHang],
                    h.DVTID AS [DvtID],
                    ptu.IsKhuyenmai,
                    ptu.Soluong,
                    ptu.Dongia,
                    ptu.Sotien,
                    ptu.Giamgia,
                    ptu.Sotiengiamgia,
                    ptu.Soluongle,
                    ptu.Dongiale,
                    ptu.Ghichuthucuong
                FROM tbmk_Phieuthuthucuong ptu
                LEFT JOIN dmHangHoa h ON ptu.Mahang = h.Mahang
                WHERE ptu.SPthu = pt.DocumentID
                FOR JSON PATH
            ) AS [JsonThucUong],

            (
                SELECT 
                    ptd.Mahang,
                    h.Tenhang AS [TenHang],
                    h.DVTID AS [DvtID],
                    ptd.Soluong,
                    ptd.Dongia,
                    ptd.Sotien,
                    ptd.Giamgia,
                    ptd.Sotiengiamgia,
                    (ptd.Sotien - ptd.Sotiengiamgia) AS [ThanhTien]
                FROM tbmk_PhieuthuDichvu ptd
                LEFT JOIN dmHangHoa h ON ptd.Mahang = h.Mahang
                WHERE ptd.SPthu = pt.DocumentID
                FOR JSON PATH
            ) AS [JsonDichVu],

            (
                SELECT 
                    ptp.Mahang,
                    ISNULL(h.Tenhang, ISNULL(ptp.GhiChuPhatSinh, ptp.Mahang)) AS [TenHang],
                    ISNULL(h.Tenhang, ISNULL(ptp.GhiChuPhatSinh, ptp.Mahang)) AS [TenMon],
                    h.DVTID AS [DvtID],
                    ptp.Soluong,
                    ptp.Dongia,
                    ptp.Sotien,
                    ptp.GhiChuPhatSinh
                FROM tbmk_Phieuthuphatsinh ptp
                LEFT JOIN dmHangHoa h ON ptp.Mahang = h.Mahang
                WHERE ptp.SPthu = pt.DocumentID
                FOR JSON PATH
            ) AS [JsonPhatSinh]
        FROM tbmk_Phieuthu pt
        LEFT JOIN tbmk_Hopdong hd ON pt.Sohopdong = hd.Sohopdong
        WHERE pt.DocumentID = @DocumentID;
            
        RETURN;
    END

    -- 2. TRƯỜNG HỢP 2: TẠO MỚI QUYẾT TOÁN (Chưa có DocumentID hoặc chưa lưu)
    IF (@SothaydoiToUse IS NULL OR @SothaydoiToUse = '') AND @Sohopdong IS NOT NULL
    BEGIN
        SELECT TOP 1 @SothaydoiToUse = Sothaydoi 
        FROM tbmk_Thaydoi 
        WHERE Sohopdong = @Sohopdong AND ISNULL(IsDeleted, 0) = 0
        ORDER BY LanThayDoi DESC, DateCreate DESC;
    END

    DECLARE @PhiPhucVuDec DECIMAL(18,2) = 0;
    DECLARE @PhiBuSanhDec DECIMAL(18,2) = 0;
    DECLARE @PhiBuBantangDec DECIMAL(18,2) = 0;
    DECLARE @PhiBuTTSDec DECIMAL(18,2) = 0;
    DECLARE @PhiBuNTLDec DECIMAL(18,2) = 0;
    DECLARE @PTThueVATDec DECIMAL(18,2) = 0;
    DECLARE @TienThueVATDec DECIMAL(18,2) = 0;
    DECLARE @BanPhatSinhInt INT = 0;

    IF @SothaydoiToUse IS NOT NULL AND @SothaydoiToUse <> ''
    BEGIN
        SELECT 
            @GoiThucDonID = GoiThucDonIDTD,
            @SoBanChinhThuc = ISNULL(TongSoBanTD, TongSoBan),
            @Giabanman = ISNULL(GiabanManTD, Giabanman),
            @Giabanchay = ISNULL(GiabanChayTD, Giabanchay),
            @Tongtienbanman = ISNULL(TongtienBanmanTD, Tongtienbanman),
            @Tongtienbanchay = ISNULL(TongtienBanchayTD, Tongtienbanchay),
            @Tongtienthucuong = ISNULL(Tongtienthucuong, 0),
            @Tongtiendichvu = ISNULL(TongtienDichvuTD, Tongtiendichvu),
            @PhiPhucVuDec = ISNULL(PhiPhucVu, 0),
            @PhiBuSanhDec = ISNULL(PhiBuSanh, 0),
            @PhiBuBantangDec = ISNULL(PhiBuBanTang, 0),
            @PhiBuTTSDec = ISNULL(TienTTS, 0),
            @PhiBuNTLDec = ISNULL(TienNTL, 0),
            @PTThueVATDec = ISNULL(PTThueVAT, 0),
            @TienThueVATDec = ISNULL(TienThueVAT, 0),
            @BanPhatSinhInt = ISNULL((SELECT BanPhatSinh FROM tbmk_Hopdong WHERE Sohopdong = tbmk_Thaydoi.Sohopdong), 0)
        FROM tbmk_Thaydoi
        WHERE Sothaydoi = @SothaydoiToUse;
    END
    ELSE IF @Sohopdong IS NOT NULL
    BEGIN
        SELECT 
            @GoiThucDonID = GoiThucDonID,
            @SoBanChinhThuc = ISNULL(TongSoBan, 0),
            @Giabanman = ISNULL(Giabanman, 0),
            @Giabanchay = ISNULL(Giabanchay, 0),
            @Tongtienbanman = ISNULL(Tongtienbanman, 0),
            @Tongtienbanchay = ISNULL(Tongtienbanchay, 0),
            @Tongtienthucuong = ISNULL(Tongtienthucuong, 0),
            @Tongtiendichvu = ISNULL(Tongtiendichvu, 0),
            @PhiPhucVuDec = ISNULL(PhiPhucVu, 0),
            @PhiBuSanhDec = ISNULL(PhiBuSanh, 0),
            @PhiBuBantangDec = ISNULL(PhiBuBanTang, 0),
            @PhiBuTTSDec = ISNULL(TienTTS, 0),
            @PhiBuNTLDec = ISNULL(TienNTL, 0),
            @PTThueVATDec = ISNULL(PTThueVAT, 0),
            @TienThueVATDec = ISNULL(TienThueVAT, 0),
            @BanPhatSinhInt = ISNULL(BanPhatSinh, 0)
        FROM tbmk_Hopdong
        WHERE Sohopdong = @Sohopdong;
    END

    SELECT 
        @PhiPhucVuDec AS [PhiPhucVu],
        @PhiBuSanhDec AS [PhiBuSanh],
        @PhiBuBantangDec AS [PhiBuBantang],
        @PhiBuTTSDec AS [PhiBuTTS],
        @PhiBuNTLDec AS [PhiBuNTL],
        CAST(@PTThueVATDec AS INT) AS [PTThueVAT],
        @TienThueVATDec AS [TienThueVAT],
        @BanPhatSinhInt AS [BanPhatSinh],

        -- 2.1. Thực đơn (Món mặn + Món chay) lấy từ Phụ lục đã ký gần nhất, nếu không thì lấy từ Hợp đồng
        COALESCE(
            (
                SELECT TOP 1 td.JsonBanTiec
                FROM tbmk_Thaydoi td
                WHERE td.Sothaydoi = @SothaydoiToUse
                  AND NULLIF(LTRIM(RTRIM(td.JsonBanTiec)), '') IS NOT NULL
                  AND td.JsonBanTiec <> '[]'
                  AND LEFT(LTRIM(td.JsonBanTiec), 1) = '['
            ),
            (
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
            ),
            '[]'
        ) AS [JsonBanTiec],
 
        -- 2.2. Thức uống: Lấy từ Phụ lục đã ký gần nhất, nếu không thì lấy từ Hợp đồng
        COALESCE(
            (
                SELECT TOP 1 td.JsonThucUong
                FROM tbmk_Thaydoi td
                WHERE td.Sothaydoi = @SothaydoiToUse
                  AND NULLIF(LTRIM(RTRIM(td.JsonThucUong)), '') IS NOT NULL
                  AND td.JsonThucUong <> '[]'
                  AND LEFT(LTRIM(td.JsonThucUong), 1) = '['
            ),
            (
                SELECT tu.Mahang, ISNULL(hh.Tenhang, tu.Mahang) AS TenHang, ISNULL(tu.Dvt, hh.DVTID) AS DvtID,
                       ISNULL(tu.IsKhuyenmai, 0) AS IsKhuyenmai, ISNULL(tu.Soluong, 0) AS Soluong,
                       ISNULL(tu.Dongia, 0) AS Dongia, CAST(0 AS DECIMAL(18,2)) AS Soluongle,
                       CAST(0 AS DECIMAL(18,2)) AS Dongiale, ISNULL(tu.Ghichuthucuong, N'') AS Ghichuthucuong
                FROM tbmk_Hopdongthucuong tu
                LEFT JOIN dmHanghoa hh ON tu.Mahang = hh.Mahang
                WHERE tu.Sohopdong = @Sohopdong
                ORDER BY tu.Mahang
                FOR JSON PATH
            ),
            '[]'
        ) AS [JsonThucUong],
 
        -- 2.3. Dịch vụ lấy từ Phụ lục đã ký gần nhất, nếu không thì lấy từ Hợp đồng
        COALESCE(
            (
                SELECT TOP 1 td.JsonDichVu
                FROM tbmk_Thaydoi td
                WHERE td.Sothaydoi = @SothaydoiToUse
                  AND NULLIF(LTRIM(RTRIM(td.JsonDichVu)), '') IS NOT NULL
                  AND td.JsonDichVu <> '[]'
                  AND LEFT(LTRIM(td.JsonDichVu), 1) = '['
            ),
            (
                SELECT dv.Mahang, ISNULL(hh.Tenhang, dv.Mahang) AS TenHang, ISNULL(hh.DVTID, N'Lần') AS DvtID,
                       CAST(0 AS BIT) AS IsKhuyenmai, ISNULL(dv.Soluong, 0) AS Soluong,
                       ISNULL(dv.Dongia, 0) AS Dongia
                FROM tbmk_Hopdongdichvu dv
                LEFT JOIN dmHanghoa hh ON dv.Mahang = hh.Mahang
                WHERE dv.Sohopdong = @Sohopdong
                ORDER BY dv.Mahang
                FOR JSON PATH
            ),
            '[]'
        ) AS [JsonDichVu],
 
        -- 2.4. Phát sinh lấy từ bảng phát sinh nhanh tbmk_HopdongPhatSinh (nếu có), nếu không lấy từ Phụ lục đã ký gần nhất (nếu có)
        COALESCE(
            (
                SELECT 
                    pt.Mahang,
                    ISNULL(hh.Tenhang, ISNULL(pt.GhiChuPhatSinh, pt.Mahang)) AS [TenHang],
                    ISNULL(hh.Tenhang, ISNULL(pt.GhiChuPhatSinh, pt.Mahang)) AS [TenMon],
                    ISNULL(hh.DVTID, N'Lần') AS [DvtID],
                    pt.Soluong,
                    pt.Dongia,
                    pt.Sotien,
                    pt.GhiChuPhatSinh
                FROM tbmk_HopdongPhatSinh pt
                LEFT JOIN dmHanghoa hh ON pt.Mahang = hh.Mahang
                WHERE pt.Sohopdong = @Sohopdong
                FOR JSON PATH
            ),
            (
                SELECT TOP 1 td.JsonPhatSinh
                FROM tbmk_Thaydoi td
                WHERE td.Sothaydoi = @SothaydoiToUse
                  AND NULLIF(LTRIM(RTRIM(td.JsonPhatSinh)), '') IS NOT NULL
                  AND td.JsonPhatSinh <> '[]'
                  AND LEFT(LTRIM(td.JsonPhatSinh), 1) = '['
            ),
            '[]'
        ) AS [JsonPhatSinh];
END;
GO

PRINT N'Đang cập nhật Stored Procedure API_Thaydoi...';
GO

IF OBJECT_ID('API_tbmk_Thaydoi_View', 'P') IS NOT NULL
    DROP PROCEDURE API_tbmk_Thaydoi_View;
GO

IF OBJECT_ID('API_Thaydoi', 'P') IS NOT NULL
    DROP PROCEDURE API_Thaydoi;
GO

CREATE PROCEDURE [dbo].[API_Thaydoi]
    @Keyword NVARCHAR(250),
    @Sothaydoi NVARCHAR(50) = ''
AS
BEGIN
    SET NOCOUNT ON;

    IF @Sothaydoi = '' SET @Sothaydoi = NULL;

    SELECT 
        td.Sothaydoi,
        td.Ngaythaydoi,
        td.Sohopdong,
        td.LanThayDoi,
        td.Ghichu,
        td.Status,
        td.JsonBanTiec,
        td.JsonThucUong,
        td.JsonDichVu,
        td.JsonPhatSinh,
        
        -- Các trường văn bản phụ lục
        ISNULL(td.DichVuTinhPhiPhuLucTD, td.DichVuTinhPhiPhuLuc) AS [DichVuTinhPhiPhuLuc],
        ISNULL(td.ThoaThuanPhuLucKhacTD, td.ThoaThuanPhuLucKhac) AS [ThoaThuanPhuLucKhac],
        ISNULL(td.DanhSachChiPhiTD, td.DanhSachChiPhi) AS [DanhSachChiPhi],
        ISNULL(td.BenAChucVuDaiDienTD, td.BenAChucVuDaiDien) AS [BenAChucVuDaiDien],

        kh.Tenkh AS [KhachHang],
        kh.Tenkh AS [BenBDaiDien],
        ISNULL(nv.Tennv, td.Manv) AS [NVKD],
        CONVERT(VARCHAR(10), hd.Ngayhopdong, 103) AS [NgayHopDong],
        hd.Tentiec AS [TenTiec],
        CONVERT(VARCHAR(10), ISNULL(td.NgayToChucTD, hd.Ngaytochuc), 103) AS [NgayToChuc],
        
        ISNULL(
            (SELECT TOP 1 s.Tensanhtiec 
             FROM tbmk_Hopdongsanhtiec hs 
             INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid 
             WHERE hs.Sohopdong = td.Sohopdong), 
            N'Chưa xác định'
        ) AS [SanhTiec],
        ISNULL(
            (SELECT TOP 1 s.Tensanhtiec 
             FROM tbmk_Hopdongsanhtiec hs 
             INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid 
             WHERE hs.Sohopdong = td.Sohopdong), 
            N'Chưa xác định'
        ) AS [Sanh],

        ISNULL(td.SobanManchinhthuc, hd.SobanManchinhthuc) AS [SoBanChinhThuc],
        ISNULL(ISNULL(td.SoBanTang, hd.SoBanTang), 0) AS [SoBanTang],
        ISNULL(ISNULL(td.SoBanTang, hd.SoBanTang), 0) AS [BanTang],
        ISNULL(td.SobanManduphong, hd.SobanManduphong) AS [SoBanDuPhong],

        CASE 
            WHEN ISNULL(td.PhiBuSanhTD, 0) > 0 THEN FORMAT(td.PhiBuSanhTD, 'N0', 'vi-VN') 
            WHEN ISNULL(td.PhiBuSanh, 0) > 0 THEN FORMAT(td.PhiBuSanh, 'N0', 'vi-VN')
            ELSE N'0' 
        END AS [PhiBuSanh],

        RIGHT('0' + CAST(DAY(td.Ngaythaydoi) AS VARCHAR), 2) AS [NgayThayDoi],
        RIGHT('0' + CAST(MONTH(td.Ngaythaydoi) AS VARCHAR), 2) AS [ThangThayDoi],
        YEAR(td.Ngaythaydoi) AS [NamThayDoi],
        RIGHT('0' + CAST(DAY(td.Ngaythaydoi) AS VARCHAR), 2) AS [NgayLapPL],
        RIGHT('0' + CAST(MONTH(td.Ngaythaydoi) AS VARCHAR), 2) AS [ThangLapPL],
        YEAR(td.Ngaythaydoi) AS [NamLapPL],

        CAST(ISNULL(td.SobanManchinhthuc, hd.SobanManchinhthuc) AS VARCHAR) + N' bàn chính thức và ' + 
        CAST(ISNULL(td.SobanManduphong, hd.SobanManduphong) AS VARCHAR) + N' bàn dự phòng' AS [MoTaTongSoBanSauThayDoi],

        (
            SELECT 
                ROW_NUMBER() OVER (ORDER BY sort_order) AS [STT],
                [NoiDung]
            FROM (
                SELECT N'Thay đổi ngày tổ chức từ ' + CONVERT(VARCHAR(10), hd.Ngaytochuc, 103) + N' sang ngày ' + CONVERT(VARCHAR(10), td.NgayToChucTD, 103) AS [NoiDung], 1 AS sort_order
                WHERE td.NgayToChucTD IS NOT NULL AND td.NgayToChucTD <> hd.Ngaytochuc

                UNION ALL
                SELECT N'Tăng ' + CAST(td.SoBanManChinhThucTang AS NVARCHAR) + N' bàn chính thức' AS [NoiDung], 2 AS sort_order
                WHERE ISNULL(td.SoBanManChinhThucTang, 0) > 0

                UNION ALL
                SELECT N'Giảm ' + CAST(td.SoBanManChinhThucGiam AS NVARCHAR) + N' bàn chính thức' AS [NoiDung], 3 AS sort_order
                WHERE ISNULL(td.SoBanManChinhThucGiam, 0) > 0

                UNION ALL
                SELECT N'Tăng ' + CAST(td.SobanManduphongTang AS NVARCHAR) + N' bàn dự phòng' AS [NoiDung], 4 AS sort_order
                WHERE ISNULL(td.SobanManduphongTang, 0) > 0

                UNION ALL
                SELECT N'Giảm ' + CAST(td.SobanManduphongGiam AS NVARCHAR) + N' bàn dự phòng' AS [NoiDung], 5 AS sort_order
                WHERE ISNULL(td.SobanManduphongGiam, 0) > 0

                UNION ALL
                SELECT N'Thay đổi đơn giá bàn mặn thành: ' + FORMAT(td.GiabanManTD, 'N0', 'vi-VN') + N' VND/bàn' AS [NoiDung], 6 AS sort_order
                WHERE td.GiabanManTD IS NOT NULL AND td.GiabanManTD <> hd.Giabanman

                UNION ALL
                SELECT N'Phụ thu phí sảnh: ' + FORMAT(td.PhiBuSanhTD, 'N0', 'vi-VN') + N' VND' AS [NoiDung], 7 AS sort_order
                WHERE ISNULL(td.PhiBuSanhTD, 0) > 0
            ) sub
            FOR JSON PATH
        ) AS [ChiTietThayDoi]

    FROM tbmk_Thaydoi td
    INNER JOIN tbmk_Hopdong hd ON td.Sohopdong = hd.Sohopdong
    LEFT JOIN dmkhachhang kh ON hd.Makh = kh.Makh
    LEFT JOIN dmNhanvienView nv ON td.Manv = nv.Manv
    WHERE (td.Sohopdong = @Keyword OR td.Sothaydoi = @Keyword)
      AND (@Sothaydoi IS NULL OR td.Sothaydoi = @Sothaydoi)
      AND ISNULL(td.IsDeleted, 0) = 0
    ORDER BY td.Sothaydoi DESC; 
END;
GO

-- =========================================================================
-- 5. ĐỒNG BỘ ĐỊNH TUYẾN GATEWAY (WA_API)
-- =========================================================================
PRINT N'Đang đồng bộ cấu hình định tuyến WA_API cho frmQuyetToan và tbmk_Thaydoi...';
GO

-- Quyết toán (View, Save, GetDetails, Delete)
DELETE FROM WA_API 
WHERE (List = 'frmQuyetToan' AND Func IN ('View', 'Save', 'GetDetails', 'Delete'));
GO

INSERT INTO WA_API (List, Func, [SQL], Para)
VALUES 
(
    'frmQuyetToan', 
    'View', 
    'API_DanhSachQuyetToan', 
    '@Keyword=N''{Keyword}'', @DocumentID=N''{DocumentID}'', @Sohopdong=N''{Sohopdong}'''
),
(
    'frmQuyetToan', 
    'Save', 
    'API_LuuQuyenToan', 
    '@DocumentID=N''{DocumentID}'', @DocumentDate=N''{DocumentDate}'', @Sohopdong=N''{Sohopdong}'', @Nguoinop=N''{Nguoinop}'', @Tongtiencoc=N''{Tongtiencoc}'', @TongtienHoaDon=N''{TongtienHoaDon}'', @Thanhtoan=N''{Thanhtoan}'', @Conlai=N''{Conlai}'', @IsKetthuc=N''{IsKetthuc}'', @Ghichu=N''{Ghichu}'', @User=N''{UserName}'', @BanPhatSinh=N''{BanPhatSinh}'', @Sotienphatsinh=N''{Sotienphatsinh}'', @PhiBuSanh=N''{PhiBuSanh}'', @PhiBuBantang=N''{PhiBuBantang}'', @PhiBuTTS=N''{PhiBuTTS}'', @PhiBuNTL=N''{PhiBuNTL}'', @PhiPhucVu=N''{PhiPhucVu}'', @PTThueVAT=N''{PTThueVAT}'', @TienThueVAT=N''{TienThueVAT}'', @JsonBanTiec=N''{JsonBanTiec}'', @JsonThucUong=N''{JsonThucUong}'', @JsonDichVu=N''{JsonDichVu}'', @JsonPhatSinh=N''{JsonPhatSinh}'''
),
(
    'frmQuyetToan', 
    'GetDetails', 
    'API_LayChiTietQuyetToan', 
    '@Sohopdong=N''{Sohopdong}'', @Sothaydoi=N''{Sothaydoi}'', @DocumentID=N''{DocumentID}'''
),
(
    'frmQuyetToan', 
    'Delete', 
    'API_XoaPhieuThu', 
    '@Ids=N''{DocumentID}'', @UserName=N''{User}'''
);
GO

-- Phiếu thay đổi (Cập nhật View trỏ sang API_Thaydoi)
UPDATE WA_API
SET [SQL] = 'API_Thaydoi',
    [Para] = '@Keyword=N''{Keyword}'', @Sothaydoi=N''{Sothaydoi}'''
WHERE list = 'tbmk_Thaydoi' AND func = 'View';
GO

-- =========================================================================
-- 6. ĐỒNG BỘ CẤU HÌNH TRƯỜNG DỮ LIỆU (SY_FORMATFIELDS)
-- =========================================================================
PRINT N'Đang đồng bộ cấu hình trường dữ liệu cho frmQuyetToan...';
GO

IF NOT EXISTS (SELECT 1 FROM SY_FormatFields WHERE FormName = 'frmQuyetToan' AND FieldName = 'JsonBanTiec')
    INSERT INTO SY_FormatFields (FormName, FieldName, CaptionVN, FormatID, FormPosition, IsRequired, OrderNo, ShowInAdd, ShowInEdit, IsReadOnlyAdd, IsReadOnlyEdit)
    VALUES ('frmQuyetToan', 'JsonBanTiec', N'Chi tiết bàn tiệc (JSON)', 't', '12', 0, 90, 0, 0, 1, 1);

IF NOT EXISTS (SELECT 1 FROM SY_FormatFields WHERE FormName = 'frmQuyetToan' AND FieldName = 'JsonThucUong')
    INSERT INTO SY_FormatFields (FormName, FieldName, CaptionVN, FormatID, FormPosition, IsRequired, OrderNo, ShowInAdd, ShowInEdit, IsReadOnlyAdd, IsReadOnlyEdit)
    VALUES ('frmQuyetToan', 'JsonThucUong', N'Chi tiết thức uống (JSON)', 't', '12', 0, 91, 0, 0, 1, 1);

IF NOT EXISTS (SELECT 1 FROM SY_FormatFields WHERE FormName = 'frmQuyetToan' AND FieldName = 'JsonDichVu')
    INSERT INTO SY_FormatFields (FormName, FieldName, CaptionVN, FormatID, FormPosition, IsRequired, OrderNo, ShowInAdd, ShowInEdit, IsReadOnlyAdd, IsReadOnlyEdit)
    VALUES ('frmQuyetToan', 'JsonDichVu', N'Chi tiết dịch vụ (JSON)', 't', '12', 0, 92, 0, 0, 1, 1);

IF NOT EXISTS (SELECT 1 FROM SY_FormatFields WHERE FormName = 'frmQuyetToan' AND FieldName = 'JsonPhatSinh')
    INSERT INTO SY_FormatFields (FormName, FieldName, CaptionVN, FormatID, FormPosition, IsRequired, OrderNo, ShowInAdd, ShowInEdit, IsReadOnlyAdd, IsReadOnlyEdit)
    VALUES ('frmQuyetToan', 'JsonPhatSinh', N'Chi tiết phát sinh (JSON)', 't', '12', 0, 93, 0, 0, 1, 1);
GO

-- =========================================================================
-- 7. SỬA LỖI TIẾNG VIỆT CHO TRƯỜNG ĐÃ KẾT THÚC (ISKETHUC)
-- =========================================================================
PRINT N'Đang cấu hình và sửa lỗi tiếng Việt cho trường IsKetthuc...';
GO

IF OBJECT_ID('SY_FormatFields', 'U') IS NOT NULL
BEGIN
    -- 1. Sửa lỗi font tiếng Việt chung cho các form đang cấu hình IsKetthuc dạng select bị lỗi font
    UPDATE SY_FormatFields
    SET DataSource = N'STATIC:0|Chưa kết thúc,1|Đã kết thúc'
    WHERE FieldName = 'IsKetthuc' 
      AND (DataSource LIKE N'%k?t%' 
           OR DataSource LIKE N'%kêt%' 
           OR DataSource LIKE N'%ket%');

    -- 2. Đảm bảo cấu hình trường IsKetthuc của frmQuyetToan luôn có và hiển thị tiếng Việt chuẩn dạng dropdown select
    IF EXISTS (SELECT 1 FROM SY_FormatFields WHERE FormName = 'frmQuyetToan' AND FieldName = 'IsKetthuc')
    BEGIN
        UPDATE SY_FormatFields 
        SET FormatID = 'sl', 
            DataSource = N'STATIC:0|Chưa kết thúc,1|Đã kết thúc', 
            CaptionVN = N'Đã kết thúc' 
        WHERE FormName = 'frmQuyetToan' AND FieldName = 'IsKetthuc';
    END
    ELSE
    BEGIN
        INSERT INTO SY_FormatFields (FormName, FieldName, CaptionVN, FormatID, FormPosition, IsRequired, OrderNo, ShowInAdd, ShowInEdit, IsReadOnlyAdd, IsReadOnlyEdit, ShowInFilter, DataSource)
        VALUES ('frmQuyetToan', 'IsKetthuc', N'Đã kết thúc', 'sl', '6', 0, 50, 1, 1, 0, 0, 1, N'STATIC:0|Chưa kết thúc,1|Đã kết thúc');
    END

    -- Đảm bảo cấu hình trường Sohopdong của frmQuyetToan luôn có và hiển thị tiếng Việt chuẩn dạng search-readonly combobox
    IF EXISTS (SELECT 1 FROM SY_FormatFields WHERE FormName = 'frmQuyetToan' AND FieldName = 'Sohopdong')
    BEGIN
        UPDATE SY_FormatFields 
        SET FormatID = 'sr', 
            DataSource = '/api/API_Gateway_Router?List=API_DanhSachHopDong&Func=View', 
            CaptionVN = N'Số Hợp Đồng',
            ShowInAdd = 1,
            ShowInEdit = 1,
            IsReadOnlyAdd = 0,
            IsReadOnlyEdit = 1
        WHERE FormName = 'frmQuyetToan' AND FieldName = 'Sohopdong';
    END
    ELSE
    BEGIN
        INSERT INTO SY_FormatFields (FormName, FieldName, CaptionVN, FormatID, FormPosition, IsRequired, OrderNo, ShowInAdd, ShowInEdit, IsReadOnlyAdd, IsReadOnlyEdit, ShowInFilter, DataSource)
        VALUES ('frmQuyetToan', 'Sohopdong', N'Số Hợp Đồng', 'sr', '6', 0, 10, 1, 1, 0, 1, 1, '/api/API_Gateway_Router?List=API_DanhSachHopDong&Func=View');
    END
END
GO

PRINT N'>> ĐÃ CẬP NHẬT TOÀN BỘ CHỨC NĂNG QUYẾT TOÁN VÀ THAY ĐỔI CHI TIẾT THÀNH CÔNG!';
GO



