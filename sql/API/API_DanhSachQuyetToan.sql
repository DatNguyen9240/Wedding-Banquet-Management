CREATE OR ALTER PROCEDURE [dbo].[API_DanhSachQuyetToan]
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

        -- Cột dùng cho in ấn (placeholders)
        kh.Tenkh AS [KhachHang],
        ISNULL((SELECT TOP 1 Tenloaitiec FROM dmLoaihinhtiec WHERE Loaitiecid = hd.Loaitiecid), N'TIỆC CƯỚI') AS [LoaiHinhSK],
        (SELECT TOP 1 nv.Tennv FROM dmNhanvienView nv WHERE nv.NHANVIENID = pt.Manv OR nv.Manv = pt.Manv) AS [NVKD],
        
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

        -- BBNT bàn tiệc
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
                hh.Tenhang AS [TenPhatSinh],
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
                COALESCE(t.RowNum, n.n) AS [STT],
                ISNULL(t.[DienGiai], N'') AS [DienGiai],
                ISNULL(t.[DVT], N'') AS [DVT],
                ISNULL(CAST(t.[SoLuong] AS NVARCHAR(50)), N'') AS [SoLuong],
                ISNULL(t.[DonGia], N'') AS [DonGia],
                ISNULL(t.[ThanhTien], N'-') AS [ThanhTien]
            FROM (SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3) n
            FULL OUTER JOIN (
                SELECT 
                    ROW_NUMBER() OVER (ORDER BY sort_order, [DienGiai]) AS RowNum,
                    [DienGiai], [DVT], [SoLuong], [DonGia], [ThanhTien]
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
                    WHERE ISNULL(hd.Tongtienbanman, 0) > 0 AND NOT EXISTS (SELECT 1 FROM tbmk_Phieuthubantiec WHERE SPthu = pt.SPthu)
                    
                    UNION ALL
                    
                    SELECT N'Bàn tiệc chay' AS [DienGiai], N'Bàn' AS [DVT], ISNULL(hd.SobanChaychinhthuc, 0) AS [SoLuong], FORMAT(ISNULL(hd.Giabanchay, 0), 'N0', 'vi-VN') AS [DonGia], FORMAT(ISNULL(hd.Tongtienbanchay, 0), 'N0', 'vi-VN') AS [ThanhTien], ISNULL(hd.Tongtienbanchay, 0) AS val, 2 AS sort_order
                    WHERE ISNULL(hd.SobanChaychinhthuc, 0) > 0 AND NOT EXISTS (SELECT 1 FROM tbmk_Phieuthubantiec WHERE SPthu = pt.SPthu)
                    
                    UNION ALL
                    
                    SELECT N'Thức uống' AS [DienGiai], N'Gói' AS [DVT], 1 AS [SoLuong], FORMAT(ISNULL(hd.Tongtienthucuong, 0), 'N0', 'vi-VN') AS [DonGia], FORMAT(ISNULL(hd.Tongtienthucuong, 0), 'N0', 'vi-VN') AS [ThanhTien], ISNULL(hd.Tongtienthucuong, 0) AS val, 3 AS sort_order
                    WHERE ISNULL(hd.Tongtienthucuong, 0) > 0 AND NOT EXISTS (SELECT 1 FROM tbmk_Phieuthuthucuong WHERE SPthu = pt.SPthu)
                    
                    UNION ALL
                    
                    SELECT N'Dịch vụ cưới & Trang trí' AS [DienGiai], N'Gói' AS [DVT], 1 AS [SoLuong], FORMAT(ISNULL(hd.Tongtiendichvu, 0), 'N0', 'vi-VN') AS [DonGia], FORMAT(ISNULL(hd.Tongtiendichvu, 0), 'N0', 'vi-VN') AS [ThanhTien], ISNULL(hd.Tongtiendichvu, 0) AS val, 4 AS sort_order
                    WHERE ISNULL(hd.Tongtiendichvu, 0) > 0 AND NOT EXISTS (SELECT 1 FROM tbmk_PhieuthuDichvu WHERE SPthu = pt.SPthu)
                ) sub
            ) t ON n.n = t.RowNum
            ORDER BY [STT]
            FOR JSON PATH
        ) AS [DanhSachDichVu],

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
                        ISNULL(GhiChuPhatSinh, N'Phát sinh thực tế') AS [DienGiai], 
                        N'Lần' AS [DVT], 
                        ISNULL(Soluong, 1) AS [SoLuong], 
                        FORMAT(ISNULL(Dongia, 0), 'N0', 'vi-VN') AS [DonGia], 
                        FORMAT(ISNULL(Sotien, 0), 'N0', 'vi-VN') AS [ThanhTien], 
                        ISNULL(Sotien, 0) AS val, 
                        1 AS sort_order
                    FROM tbmk_Phieuthuphatsinh
                    WHERE SPthu = pt.SPthu

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
