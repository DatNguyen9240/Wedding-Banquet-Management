IF EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[v_DanhSachHopDong]'))
    DROP VIEW [dbo].[v_DanhSachHopDong]
GO
CREATE VIEW [dbo].[v_DanhSachHopDong] AS
SELECT 
    h.Sohopdong AS [Id], -- Đóng vai trò là PrimaryKey cho Frontend

    h.Sohopdong AS [Sohopdong], -- Cột khoá chính thật
    h.Sobiennhan,
    h.Makh,
    
    -- Lấy thông tin khách hàng từ dmkhachhang
    CASE 
        WHEN k.Tenchure IS NOT NULL AND k.Tencodau IS NOT NULL AND k.Tenchure <> '' AND k.Tencodau <> ''
            THEN k.Tenchure + ' & ' + k.Tencodau
        ELSE ISNULL(k.Tenkh, N'Khách vãng lai')
    END AS [TenKhachHang],
    
    CASE 
        WHEN k.Tenchure IS NOT NULL AND k.Tencodau IS NOT NULL AND k.Tenchure <> '' AND k.Tencodau <> ''
            THEN k.Tenchure + ' & ' + k.Tencodau
        ELSE ISNULL(k.Tenkh, N'Khách vãng lai')
    END AS [TenCongTy],
    
    CASE 
        WHEN ISNULL((SELECT MAX(td.LanThayDoi) FROM tbmk_Thaydoi td WHERE td.Sohopdong = h.Sohopdong AND ISNULL(td.IsDeleted, 0) = 0), 0) = 0
            THEN N'PHIẾU ĐẶT TIỆC'
        ELSE N'PHIẾU ĐẶT TIỆC THAY ĐỔI LẦN ' + CAST((SELECT MAX(td.LanThayDoi) FROM tbmk_Thaydoi td WHERE td.Sohopdong = h.Sohopdong AND ISNULL(td.IsDeleted, 0) = 0) AS NVARCHAR(10))
    END AS [TieuDePhieu],
    
    ISNULL(k.Dienthoai, ISNULL(k.DTchure, k.DTcodau)) AS [DienThoai],
    h.Ngaytochuc AS [NgayToChuc],
    h.TuNgaySetup AS [TuNgaySetup],
    h.NgayTraSanhDV AS [NgayTraSanhDV],
    
    ISNULL(h.TongSoBan, 0) AS [SoBan],
    
    (
        SELECT TOP 1 s.Tensanhtiec 
        FROM tbmk_Hopdongsanhtiec hs 
        INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid 
        WHERE hs.Sohopdong = h.Sohopdong
        ORDER BY hs.IsSanhchinh DESC, hs.Sanhtiecid
    ) AS [SanhDat],
    ISNULL((
        SELECT s.Tensanhtiec 
        FROM tbmk_Hopdongsanhtiec hs 
        INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid 
        WHERE hs.Sohopdong = h.Sohopdong 
        ORDER BY hs.IsSanhchinh DESC, hs.Sanhtiecid
        OFFSET 1 ROWS FETCH NEXT 1 ROWS ONLY
    ), '') AS [SanhDat2],
    
    ISNULL(h.Tongtienhopdong, 0) AS [TongTien],
    
    CASE
        WHEN h.IsHuy = 1 THEN N'Đã Hủy'
        WHEN h.IsKetthuc = 1 THEN N'Đã Quyết Toán'
        ELSE N'Đã Ký'
    END AS [TrangThai],

    -- CÁC TRƯỜNG THÊM MỚI ĐỂ PHỤC VỤ NHẬP LIỆU/SỬA HỢP ĐỒNG (ShowInForm = 1, ShowInGrid = 0)
    k.Tenchure,
    k.Tencodau,
    k.Diachi,
    k.Mail,
    h.Ngayhopdong,
    h.Nhamngay,
    h.Loaitiecid,
    (SELECT TOP 1 tm.TemplateFile FROM tbmk_LoaitiecAddfile tm WHERE tm.FormName = 'frmHopDong' AND tm.Loaitiecid = h.Loaitiecid) AS [TemplateFile],
    h.Thoigianid,
    h.SobanManchinhthuc,
    h.SobanManduphong,
    h.SobanChaychinhthuc,
    h.SobanChayduphong,
    h.Sotiencoccho AS DaCocVND,
    h.Sotiencochopdong,
    h.Giabanman,
    h.Tongtiencoc,
    h.Ghichu,
    h.JsonLichTrinh,
    (
        SELECT 
            hs.Sanhtiecid AS [Sanhtiecid],
            CAST(ISNULL(hs.IsSanhchinh, 0) AS BIT) AS [IsSanhchinh],
            hs.KieuSetup AS [KieuSetup],
            hs.Ghichuct AS [Ghichuct]
        FROM tbmk_Hopdongsanhtiec hs 
        WHERE hs.Sohopdong = h.Sohopdong 
        ORDER BY hs.IsSanhchinh DESC, hs.Sanhtiecid ASC
        FOR JSON PATH
    ) AS [JsonSanhTiec],
    
    -- ==========================================
    -- CÁC CỘT DỮ LIỆU ĐƯỢC FORMAT SẴN CHO IN ẤN 
    -- Dùng để binding vào file hop_dong.docx (docxtemplater)
    -- ==========================================
    RIGHT('0' + CAST(DAY(h.Ngayhopdong) AS VARCHAR), 2) AS [NgayLapHD],
    RIGHT('0' + CAST(MONTH(h.Ngayhopdong) AS VARCHAR), 2) AS [ThangLapHD],
    CAST(YEAR(h.Ngayhopdong) AS VARCHAR) AS [NamLapHD],

    -- 1. Bên A (Thông tin nhà hàng) - Thường lấy từ bảng Setup hoặc Hardcode tùy dự án
    N'TRUNG TÂM HỘI NGHỊ TIỆC CƯỚI BIỂN NHỚ' AS [BenATenCongTy],
    N'01 Nguyễn Tất Thành, Phường 12, Quận 4, TP. HCM' AS [BenADiaChi],
    N'028 3943 1234' AS [BenASDT],
    N'info@biennho.vn' AS [BenAEmail],
    N'0312345678' AS [BenAMST],
    N'Ông Nguyễn Văn A' AS [BenANguoiDaiDien],
    N'Giám đốc' AS [BenAChucVu],

    -- 2. Bên B (Thông tin khách hàng)
    k.Tenkh AS [BenBTenDaiDien],
    ISNULL(k.Tenchure, '') + ' & ' + ISNULL(k.Tencodau, '') AS [BenBTenChuTiec],
    k.CMND AS [BenBCCCD],
    k.Diachi AS [BenBDiaChi],
    k.Dienthoai AS [BenBDienThoai],
    N'Khách hàng' AS [BenBChucVu],
    k.Mail AS [BenBEmail],

    -- 3. Thông tin tiệc
    FORMAT(h.Ngaytochuc, 'HH:mm') AS [TiecGioBatDau],
    RIGHT('0' + CAST(DAY(h.Ngaytochuc) AS VARCHAR), 2) AS [TiecNgayDL],
    RIGHT('0' + CAST(MONTH(h.Ngaytochuc) AS VARCHAR), 2) AS [TiecThangDL],
    CAST(YEAR(h.Ngaytochuc) AS VARCHAR) AS [TiecNamDL],
    h.Nhamngay AS [TiecNgayAL], -- Giả sử Nhamngay đã chứa chuỗi ngày âm

    -- 4. Quy mô bàn
    h.SobanManchinhthuc AS [TiecSoBanChinhThuc],
    h.SobanManduphong AS [TiecSoBanDuPhong],
    ISNULL(h.SobanChaychinhthuc, 0) + ISNULL(h.SobanChayduphong, 0) AS [TiecSoBanTang],
    10 AS [TiecSoKhach1Ban], -- Mặc định 10 khách/bàn

    -- 5. Thực đơn & Dịch vụ (Dạng JSON lồng nhau cho Table)
    (
        SELECT 
            ROW_NUMBER() OVER(ORDER BY td.Thucdonid) AS [STT],
            m.Tenmon AS [TenMon],
            td.Soluong AS [SL],
            td.Dongia AS [DG],
            td.Soluong * td.Dongia AS [ThanhTien]
        FROM tbmk_Hopdongthucdon td
        INNER JOIN dmMonan m ON td.Monanid = m.Monanid
        WHERE td.Sohopdong = h.Sohopdong
        FOR JSON PATH
    ) AS [DanhSachThucDon],

    (
        SELECT 
            ROW_NUMBER() OVER(ORDER BY dv.Dichvuid) AS [STT],
            d.Tendichvu AS [TenDichVu],
            dv.Soluong AS [SL],
            dv.Dongia AS [DG],
            dv.Thanhtien AS [ThanhTien],
            dv.Ghichu AS [GhiChu]
        FROM tbmk_Hopdongdichvu dv
        INNER JOIN dmDichvu d ON dv.Dichvuid = d.Dichvuid
        WHERE dv.Sohopdong = h.Sohopdong AND dv.Dongia > 0
        FOR JSON PATH
    ) AS [DichVuTinhPhi],

    (
        SELECT 
            d.Tendichvu AS [TenKhuyenMai],
            dv.Ghichu AS [GhiChu]
        FROM tbmk_Hopdongdichvu dv
        INNER JOIN dmDichvu d ON dv.Dichvuid = d.Dichvuid
        WHERE dv.Sohopdong = h.Sohopdong AND (dv.Dongia = 0 OR dv.Dongia IS NULL)
        FOR JSON PATH
    ) AS [DSKhuyenMai],

    -- 6. Thanh toán & Đặt cọc
    FORMAT(h.Sotiencoccho, 'N0', 'vi-VN') AS [CocLan1SoTien],
    [dbo].[fn_DocTienBangChu](ISNULL(h.Sotiencoccho, 0)) AS [CocLan1BangChu],
    FORMAT(h.Sotiencochopdong, 'N0', 'vi-VN') AS [CocLan2SoTien],
    [dbo].[fn_DocTienBangChu](ISNULL(h.Sotiencochopdong, 0)) AS [CocLan2BangChu],

    -- 7. Danh sách ngày tổ chức (Dành cho tiệc nhiều ngày)
    (
        SELECT 
            FORMAT(h.Ngaytochuc, 'dd/MM/yyyy') AS [Ngay],
            h.Nhamngay AS [AmLich],
            (SELECT TOP 1 s.Tensanhtiec FROM dmSanhtiec s WHERE s.Sanhtiecid = (SELECT TOP 1 hs.Sanhtiecid FROM tbmk_Hopdongsanhtiec hs WHERE hs.Sohopdong = h.Sohopdong)) AS [Sanh]
        FOR JSON PATH
    ) AS [DanhSachNgay],

    -- 8. Tổng cộng
    FORMAT(h.Tongtienhopdong, 'N0', 'vi-VN') AS [TongThanhTien],
    [dbo].[fn_DocTienBangChu](ISNULL(h.Tongtienhopdong, 0)) AS [TongTienBangChu],

    -- 3. Tổng giá trị tạm tính bằng chữ
    [dbo].[fn_DocTienBangChu](ISNULL(h.Tongtienhopdong, 0)) AS [TongGiaTriTamTinhBangChu],
    FORMAT(ISNULL(h.Tongtienhopdong, 0), 'N0', 'vi-VN') AS [TongGiaTriTamTinh]
    
FROM tbmk_Hopdong h
LEFT JOIN dmkhachhang k ON h.Makh = k.Makh
WHERE ISNULL(h.IsDeleted, 0) = 0;
GO
