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
        SELECT STUFF((
            SELECT ', ' + ISNULL(s.Tensanhtiec, hs.Sanhtiecid)
            FROM tbmk_Hopdongsanhtiec hs 
            LEFT JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid 
            WHERE hs.Sohopdong = h.Sohopdong
            ORDER BY hs.IsSanhchinh DESC, hs.Sanhtiecid
            FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 2, '')
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

    -- CÁC TRƯỜNG THÊM MỚI ĐỂ PHỤC VỤ NHẬP LIỆU/SỬA HỢP ĐỒNG (FormPosition = 'hidden')
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

    -- Thực đơn & Dịch vụ (JSON cho form sửa hợp đồng — đọc từ bảng chi tiết)
    ISNULL((
        SELECT
            items.Mahang,
            items.TenHang,
            items.DvtID,
            items.Soluong,
            items.Dongia,
            items.IsChay
        FROM (
            SELECT
                td.Mahang,
                ISNULL(hh.Tenhang, td.Mahang) AS TenHang,
                ISNULL(hh.DVTID, N'Đĩa') AS DvtID,
                CAST(1 AS DECIMAL(18, 2)) AS Soluong,
                ISNULL(td.Dongia, 0) AS Dongia,
                CAST(0 AS BIT) AS IsChay,
                ISNULL(td.STTmon, 0) AS SortOrder,
                1 AS TableType
            FROM tbmk_Hopdongthucdonman td
            LEFT JOIN dmHanghoa hh ON td.Mahang = hh.Mahang
            WHERE td.Sohopdong = h.Sohopdong

            UNION ALL

            SELECT
                td.Mahang,
                ISNULL(hh.Tenhang, td.Mahang),
                ISNULL(hh.DVTID, N'Đĩa'),
                CAST(1 AS DECIMAL(18, 2)),
                ISNULL(td.Dongia, 0),
                CAST(1 AS BIT),
                ISNULL(td.STTmon, 0),
                2
            FROM tbmk_Hopdongthucdonchay td
            LEFT JOIN dmHanghoa hh ON td.Mahang = hh.Mahang
            WHERE td.Sohopdong = h.Sohopdong
        ) items
        ORDER BY items.TableType, items.SortOrder, items.Mahang
        FOR JSON PATH
    ), '[]') AS [JsonBanTiec],

    ISNULL((
        SELECT
            tu.Mahang,
            ISNULL(hh.Tenhang, tu.Mahang) AS TenHang,
            ISNULL(tu.Dvt, hh.DVTID) AS DvtID,
            ISNULL(tu.IsKhuyenmai, 0) AS IsKhuyenmai,
            ISNULL(tu.Soluong, 0) AS Soluong,
            ISNULL(tu.Dongia, 0) AS Dongia,
            CAST(0 AS DECIMAL(18, 2)) AS Soluongle,
            CAST(0 AS DECIMAL(18, 2)) AS Dongiale,
            ISNULL(tu.Ghichuthucuong, N'') AS Ghichuthucuong
        FROM tbmk_Hopdongthucuong tu
        LEFT JOIN dmHanghoa hh ON tu.Mahang = hh.Mahang
        WHERE tu.Sohopdong = h.Sohopdong
        ORDER BY tu.STT, tu.Mahang
        FOR JSON PATH
    ), '[]') AS [JsonThucUong],

    ISNULL((
        SELECT
            dv.Mahang,
            ISNULL(hh.Tenhang, dv.Mahang) AS TenHang,
            ISNULL(hh.DVTID, N'') AS DvtID,
            ISNULL(dv.Soluong, 0) AS Soluong,
            ISNULL(dv.Dongia, 0) AS Dongia,
            ISNULL(dv.Ghichudichvu, N'') AS Ghichudichvu
        FROM tbmk_Hopdongdichvu dv
        LEFT JOIN dmHanghoa hh ON dv.Mahang = hh.Mahang
        WHERE dv.Sohopdong = h.Sohopdong
        ORDER BY dv.STT, dv.Mahang
        FOR JSON PATH
    ), '[]') AS [JsonDichVu],

    CAST('[]' AS NVARCHAR(MAX)) AS [JsonPhatSinh],

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

    -- 1. Bên A (Thông tin nhà hàng) - Lấy từ bảng Setup
    (SELECT TOP 1 CodeValue FROM [dbo].[SY_Setup] WHERE CodeID = 'BenATenCongTy') AS [BenATenCongTy],
    (SELECT TOP 1 CodeValue FROM [dbo].[SY_Setup] WHERE CodeID = 'BenADiaChi') AS [BenADiaChi],
    (SELECT TOP 1 CodeValue FROM [dbo].[SY_Setup] WHERE CodeID = 'BenASDT') AS [BenASDT],
    (SELECT TOP 1 CodeValue FROM [dbo].[SY_Setup] WHERE CodeID = 'BenAEmail')  AS [BenAEmail],
    (SELECT TOP 1 CodeValue FROM [dbo].[SY_Setup] WHERE CodeID = 'BenAMST') AS [BenAMST],
    (SELECT TOP 1 CodeValue FROM [dbo].[SY_Setup] WHERE CodeID = 'HNNguoiDaiDien') AS [BenANguoiDaiDien],
    (SELECT TOP 1 CodeValue FROM [dbo].[SY_Setup] WHERE CodeID = 'HNNguoiDaiDien') AS [BenADaiDien],
    (SELECT TOP 1 CodeValue FROM [dbo].[SY_Setup] WHERE CodeID = 'HNChucVuNguoiDaiDien') AS [BenAChucVu],

    -- 2. Bên B (Thông tin khách hàng)
    k.Tenkh AS [BenBTenDaiDien],
    ISNULL(k.Tenchure, '') + ' & ' + ISNULL(k.Tencodau, '') AS [BenBTenChuTiec],
    ISNULL(NULLIF(k.CMNDDaiDien, ''), ISNULL(NULLIF(k.CMNDnguoidd, ''), ISNULL(NULLIF(k.CMNDchure, ''), '...'))) AS [BenBCCCD],
    k.Diachi AS [BenBDiaChi],
    k.Dienthoai AS [BenBDienThoai],
    N'Khách hàng' AS [BenBChucVu],
    k.Mail AS [BenBEmail],

    -- 3. Thông tin tiệc
    FORMAT(h.Ngaytochuc, 'HH:mm') AS [TiecGioBatDau],
    ISNULL(FORMAT(h.NgayTraSanhDV, 'HH:mm'), '') AS [TiecGioKetThuc],
    ISNULL(h.TongSoBan * 10, 0) AS [SoKhachDiemDanh],
    RIGHT('0' + CAST(DAY(h.Ngaytochuc) AS VARCHAR), 2) AS [TiecNgayDL],
    RIGHT('0' + CAST(MONTH(h.Ngaytochuc) AS VARCHAR), 2) AS [TiecThangDL],
    CAST(YEAR(h.Ngaytochuc) AS VARCHAR) AS [TiecNamDL],
    h.Nhamngay AS [TiecNgayAL], -- Giả sử Nhamngay đã chứa chuỗi ngày âm

    ISNULL(h.SobanManchinhthuc, 0) + ISNULL(h.SobanChaychinhthuc, 0) AS [TiecSoBanChinhThuc],
    ISNULL(h.SoBanTang, 0) AS [TiecSoBanTang],
    ISNULL(h.SobanManduphong, 0) + ISNULL(h.SobanChayduphong, 0) AS [TiecSoBanDuPhong],
    ISNULL(h.SoNguoiTrenBan, 10) AS [TiecSoKhach1Ban],

    -- 5. Thực đơn & Dịch vụ (cho in ấn docx)
    [dbo].[fn_DOCX_DanhSachMenu](h.Sohopdong) AS [DanhSachThucDon],
    NULL AS [DichVuTinhPhi],
    ISNULL(h.Noidunguudai, '') AS [DSKhuyenMai],

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

    -- 9. Tổng giá trị tạm tính bằng chữ
    [dbo].[fn_DocTienBangChu](ISNULL(h.Tongtienhopdong, 0)) AS [TongGiaTriTamTinhBangChu],
    FORMAT(ISNULL(h.Tongtienhopdong, 0), 'N0', 'vi-VN') AS [TongGiaTriTamTinh],

    -- 10. Thông tin xuất hóa đơn GTGT (tự động lấy từ KH nếu chưa điền riêng)
    ISNULL(NULLIF(h.TenCtyHoaDon, ''),    ISNULL(k.Tenkh,  N'...')) AS [HDTenCty],
    ISNULL(NULLIF(h.DiaChiCtyHoaDon, ''), ISNULL(k.Diachi, N'...')) AS [HDDiaChi],
    ISNULL(NULLIF(h.MaSoThueHoaDon, ''),  N'...') AS [HDMaSoThue],
    ISNULL(k.Mail, N'...') AS [HDEmail],

    -- Placeholders mapping for hop_dong.docx and other contracts
    ISNULL((SELECT TOP 1 nv.Tennv FROM dmNhanvienView nv WHERE nv.Manv = h.Manv), ISNULL(h.UserCreate, h.Manv)) AS [BenA_NhanVienPhuTrach],
    (SELECT TOP 1 CodeValue FROM [dbo].[SY_Setup] WHERE CodeID = 'Com3') AS [BenA_SDT_NhanVien],
    N'Khách hàng' AS [BenB_ChucVu],
    ISNULL(k.Dienthoai, ISNULL(k.DTchure, k.DTcodau)) AS [BenB_DienThoai],
    ISNULL(h.Noidunguudai, '') AS [DS_KhuyenMai],
    CAST(YEAR(h.Ngaytochuc) AS VARCHAR) AS [Tiec_NamDL]

    -- , AS [DanhSachDV], AS [GhiChuChiTiet], AS [KhungGio], AS [TenDichVu], AS [TenMonAn], AS [TenNhomNgay], AS [ThanhTien], AS [UuDai]
    
FROM tbmk_Hopdong h
LEFT JOIN dmkhachhang k ON h.Makh = k.Makh
WHERE ISNULL(h.IsDeleted, 0) = 0;
GO
