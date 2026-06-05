USE [QLTiec]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
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
    
    ISNULL(k.Dienthoai, ISNULL(k.DTchure, k.DTcodau)) AS [DienThoai],
    h.Ngaytochuc AS [NgayToChuc],
    
    ISNULL(h.TongSoBan, 0) AS [SoBan],
    
    (
        SELECT TOP 1 s.Tensanhtiec 
        FROM tbmk_Hopdongsanhtiec hs 
        INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid 
        WHERE hs.Sohopdong = h.Sohopdong
    ) AS [SanhDat],
    
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
    h.Thoigianid,
    h.SobanManchinhthuc,
    h.SobanManduphong,
    h.SobanChaychinhthuc,
    h.SobanChayduphong,
    h.Sotiencoccho AS DaCocVND,
    h.Sotiencochopdong,
    h.Tongtiencoc,
    h.Ghichu,
    (
        SELECT TOP 1 hs.Sanhtiecid 
        FROM tbmk_Hopdongsanhtiec hs 
        WHERE hs.Sohopdong = h.Sohopdong 
        ORDER BY hs.IsSanhchinh DESC
    ) AS [JsonSanhTiec],
    
    -- ==========================================
    -- CÁC CỘT DỮ LIỆU ĐƯỢC FORMAT SẴN CHO IN ẤN 
    -- Dùng để binding vào file hop_dong.docx (docxtemplater)
    -- ==========================================
    -- (Đã có sẵn h.Sohopdong ở trên nên không cần tạo SoHopDong nữa, trong Word sẽ dùng biến {Sohopdong})
    RIGHT('0' + CAST(DAY(h.Ngayhopdong) AS VARCHAR), 2) AS [NgayLapHD],
    RIGHT('0' + CAST(MONTH(h.Ngayhopdong) AS VARCHAR), 2) AS [ThangLapHD],
    CAST(YEAR(h.Ngayhopdong) AS VARCHAR) AS [NamLapHD],

    -- Thông tin Bên A
    (SELECT TOP 1 CodeValue FROM [dbo].[SY_Setup] WHERE CodeID = 'HNNguoiDaiDien') AS [BenA_NguoiDaiDien],
    (SELECT TOP 1 CodeValue FROM [dbo].[SY_Setup] WHERE CodeID = 'HNChucVuNguoiDaiDien') AS [BenA_ChucVu],
    ISNULL(h.UserCreate, '...') AS [BenA_NhanVienPhuTrach],
    (SELECT TOP 1 CodeValue FROM [dbo].[SY_Setup] WHERE CodeID = 'Com3') AS [BenA_SDT_NhanVien],

    -- Thông tin Bên B
    CASE 
        WHEN k.Tenchure IS NOT NULL AND k.Tencodau IS NOT NULL AND k.Tenchure <> '' AND k.Tencodau <> ''
            THEN k.Tenchure + ' & ' + k.Tencodau
        ELSE ISNULL(k.Tenkh, N'Khách vãng lai')
    END AS [BenB_TenDaiDien],
    ISNULL(h.NguoinhanTT, CASE WHEN k.Tenchure <> '' AND k.Tencodau <> '' THEN k.Tenchure + ' & ' + k.Tencodau ELSE ISNULL(k.Tenkh, N'Khách vãng lai') END) AS [BenB_TenChuTiec],
    ISNULL(NULLIF(k.CMNDDaiDien, ''), ISNULL(NULLIF(k.CMNDnguoidd, ''), ISNULL(NULLIF(k.CMNDchure, ''), '...'))) AS [BenB_CCCD],
    ISNULL(k.Diachi, '...') AS [BenB_DiaChi],
    ISNULL(k.Dienthoai, ISNULL(k.DTchure, k.DTcodau)) AS [BenB_DienThoai],
    '' AS [BenB_ChucVu],

    -- Thông tin Tiệc
    ISNULL(h.GioDienRaSuKien, '...') AS [Tiec_GioBatDau],
    RIGHT('0' + CAST(DAY(h.Ngaytochuc) AS VARCHAR), 2) AS [Tiec_NgayDL],
    RIGHT('0' + CAST(MONTH(h.Ngaytochuc) AS VARCHAR), 2) AS [Tiec_ThangDL],
    CAST(YEAR(h.Ngaytochuc) AS VARCHAR) AS [Tiec_NamDL],
    CASE 
        WHEN CHARINDEX('/', h.Nhamngay) > 0 
            THEN SUBSTRING(h.Nhamngay, 1, CHARINDEX('/', h.Nhamngay) - 1)
        ELSE ISNULL(h.Nhamngay, '...')
    END AS [Tiec_NgayAL],
    CASE 
        WHEN CHARINDEX('/', h.Nhamngay) > 0 
            THEN CASE 
                WHEN CHARINDEX('/', h.Nhamngay, CHARINDEX('/', h.Nhamngay) + 1) > 0 
                    THEN SUBSTRING(h.Nhamngay, CHARINDEX('/', h.Nhamngay) + 1, CHARINDEX('/', h.Nhamngay, CHARINDEX('/', h.Nhamngay) + 1) - CHARINDEX('/', h.Nhamngay) - 1)
                ELSE SUBSTRING(h.Nhamngay, CHARINDEX('/', h.Nhamngay) + 1, LEN(h.Nhamngay))
            END
        ELSE '...'
    END AS [Tiec_ThangAL],
    CASE 
        WHEN CHARINDEX('/', h.Nhamngay) > 0 AND CHARINDEX('/', h.Nhamngay, CHARINDEX('/', h.Nhamngay) + 1) > 0
            THEN SUBSTRING(h.Nhamngay, CHARINDEX('/', h.Nhamngay, CHARINDEX('/', h.Nhamngay) + 1) + 1, LEN(h.Nhamngay))
        ELSE '...'
    END AS [Tiec_NamAL],
    
    (SELECT TOP 1 s.Tensanhtiec FROM tbmk_Hopdongsanhtiec hs INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid WHERE hs.Sohopdong = h.Sohopdong) AS [Tiec_SanhTiec],
    (SELECT TOP 1 s.SLBanMin FROM tbmk_Hopdongsanhtiec hs INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid WHERE hs.Sohopdong = h.Sohopdong) AS [Sanh_QuyMoMin],
    (SELECT TOP 1 s.SLBanMax FROM tbmk_Hopdongsanhtiec hs INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid WHERE hs.Sohopdong = h.Sohopdong) AS [Sanh_QuyMoMax],
    
    -- Tên loại hình tiệc (computed từ dmLoaihinhtiec, dùng cho in ấn Word)
    ISNULL((SELECT TOP 1 lt.Tenloaitiec FROM dmLoaihinhtiec lt WHERE lt.Loaitiecid = h.Loaitiecid), '') AS [Tiec_LoaiTiec],
    
    ISNULL(h.SobanManchinhthuc, 0) + ISNULL(h.SobanChaychinhthuc, 0) AS [Tiec_SoBanChinhThuc],
    ISNULL(h.SoBanTang, 0) AS [Tiec_SoBanTang],
    ISNULL(h.SobanManduphong, 0) + ISNULL(h.SobanChayduphong, 0) AS [Tiec_SoBanDuPhong],
    ISNULL(h.SoNguoiTrenBan, 10) AS [Tiec_SoKhach1Ban],
    
    -- Thông tin Cọc & Khuyến mãi
    FORMAT(ISNULL(h.Sotiencoccho, 0), 'N0', 'vi-VN') AS [Coc_Lan1_SoTien],
    [dbo].[fn_DocTienBangChu](ISNULL(h.Sotiencoccho, 0)) AS [Coc_Lan1_BangChu],
    FORMAT(ISNULL(h.Sotiencochopdong, 0), 'N0', 'vi-VN') AS [Coc_Lan2_SoTien],
    [dbo].[fn_DocTienBangChu](ISNULL(h.Sotiencochopdong, 0)) AS [Coc_Lan2_BangChu],
    RIGHT('0' + CAST(DAY(h.Ngayhopdong) AS VARCHAR), 2) AS [Coc_Ngay],
    RIGHT('0' + CAST(MONTH(h.Ngayhopdong) AS VARCHAR), 2) AS [Coc_Thang],
    CAST(YEAR(h.Ngayhopdong) AS VARCHAR) AS [Coc_Nam],
    
    ISNULL(h.Ghichu, '') AS [DieuKhoanBoSung],
    ISNULL(h.Noidunguudai, '') AS [DS_KhuyenMai]
    
FROM tbmk_Hopdong h
LEFT JOIN dmkhachhang k ON h.Makh = k.Makh
WHERE ISNULL(h.IsDeleted, 0) = 0;
GO

-- 1. Cập nhật Form Hợp Đồng chọc vào View này
UPDATE SY_FrmLstTbl 
SET TableName = 'v_DanhSachHopDong', PrimaryKey = 'Sohopdong'
WHERE FormID = 'frmHopDong';
GO

-- 2. Đồng bộ lại cấu hình các cột giao diện từ View
EXEC API_DongBoTruongGiaoDien @FormName = 'frmHopDong', @ObjectName = 'v_DanhSachHopDong';
GO

-- 3. Đăng ký định tuyến Save trong WA_API
DELETE FROM WA_API WHERE List = 'frmHopDong' AND Func = 'Save';
INSERT INTO WA_API (List, Func, [SQL], Para)
VALUES (
    'frmHopDong',
    'Save',
    'API_LuuHopDong',
    '@Sohopdong=N''{Sohopdong}'', @Sobiennhan=N''{Sobiennhan}'', @Makh=N''{Makh}'', @Tenchure=N''{Tenchure}'', @Tencodau=N''{Tencodau}'', @Dienthoai=N''{DienThoai}'', @Diachi=N''{Diachi}'', @Mail=N''{Mail}'', @BenB_CCCD=N''{BenB_CCCD}'', @Ngayhopdong=N''{Ngayhopdong}'', @Ngaytochuc=N''{NgayToChuc}'', @Nhamngay=N''{Nhamngay}'', @Loaitiecid=N''{Loaitiecid}'', @Thoigianid=N''{Thoigianid}'', @SobanManchinhthuc=N''{SobanManchinhthuc}'', @SobanManduphong=N''{SobanManduphong}'', @SobanChaychinhthuc=N''{SobanChaychinhthuc}'', @SobanChayduphong=N''{SobanChayduphong}'', @TongSoBan=N''{SoBan}'', @Tongtienhopdong=N''{TongTien}'', @Sotiencoccho=N''{DaCocVND}'', @Sotiencochopdong=N''{Sotiencochopdong}'', @Tongtiencoc=N''{Tongtiencoc}'', @Ghichu=N''{Ghichu}'', @JsonSanhTiec=N''{JsonSanhTiec}'''
);
GO

-- 4. Cấu hình hiển thị và định dạng cho các trường nhập liệu Hợp đồng trong SY_FormatFields
UPDATE SY_FormatFields
SET ShowInForm = 1, ShowInAdd = 1, ShowInEdit = 1, ShowInFilter = 0, FormPosition = '6'
WHERE FormName = 'frmHopDong'
  AND FieldName IN (
    'Tenchure', 'Tencodau', 'Diachi', 'Mail',
    'Ngayhopdong', 'Nhamngay', 'Loaitiecid', 'Thoigianid', 'JsonSanhTiec',
    'SobanManchinhthuc', 'SobanManduphong', 'SobanChaychinhthuc', 'SobanChayduphong',
    'DaCocVND', 'Sotiencochopdong', 'Tongtiencoc'
  );

-- Số CCCD Bên B hiển thị ở cả Grid và Form (FormPosition = 'grid')
UPDATE SY_FormatFields
SET ShowInForm = 1, ShowInAdd = 1, ShowInEdit = 1, ShowInFilter = 0, FormPosition = 'grid'
WHERE FormName = 'frmHopDong' AND FieldName = 'BenB_CCCD';

-- Ghi chú bổ sung
UPDATE SY_FormatFields
SET ShowInForm = 1, ShowInAdd = 1, ShowInEdit = 1, ShowInFilter = 0, FormPosition = 'form'
WHERE FormName = 'frmHopDong' AND FieldName = 'Ghichu';

-- Ẩn các cột chỉ dùng để IN ẤN khỏi giao diện Grid/Form
UPDATE SY_FormatFields
SET ShowInForm = 0, ShowInEdit = 0, ShowInAdd = 0, ShowInFilter = 0, FormPosition = 'hidden'
WHERE FormName = 'frmHopDong' 
  AND FieldName IN (
    'NgayLapHD', 'ThangLapHD', 'NamLapHD',
    'BenA_NhanVienPhuTrach', 'BenA_SDT_NhanVien',
    'BenB_TenDaiDien', 'BenB_TenChuTiec', 'BenB_DiaChi', 'BenB_DienThoai', 'BenB_ChucVu',
    'Tiec_GioBatDau', 'Tiec_NgayDL', 'Tiec_ThangDL', 'Tiec_NamDL',
    'Tiec_NgayAL', 'Tiec_ThangAL', 'Tiec_NamAL',
    'Tiec_SanhTiec', 'Tiec_LoaiTiec', 'Sanh_QuyMoMin', 'Sanh_QuyMoMax',
    'Tiec_SoBanChinhThuc', 'Tiec_SoBanTang', 'Tiec_SoBanDuPhong', 'Tiec_SoKhach1Ban',
    'Coc_Lan1_SoTien', 'Coc_Lan1_BangChu', 'Coc_Ngay', 'Coc_Thang', 'Coc_Nam',
    'Coc_Lan2_SoTien', 'Coc_Lan2_BangChu',
    'DieuKhoanBoSung', 'DS_KhuyenMai'
  );

-- Ẩn các trường tính toán tự động khỏi Form (chỉ hiện trên Grid lưới) hoặc cấu hình Read-Only khi sửa
UPDATE SY_FormatFields
SET ShowInAdd = 0, ShowInEdit = 0
WHERE FormName = 'frmHopDong' AND FieldName = 'TenKhachHang';

UPDATE SY_FormatFields
SET ShowInAdd = 0, ShowInEdit = 1, IsReadOnlyEdit = 1
WHERE FormName = 'frmHopDong' AND FieldName IN ('Makh', 'SoBan', 'SanhDat', 'TongTien', 'TrangThai', 'Sohopdong');

-- CCCD Bên B: lấy từ dmkhachhang, chỉ nhập được khi Thêm mới (lần đầu), khoá khi Sửa
UPDATE SY_FormatFields
SET ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 1
WHERE FormName = 'frmHopDong' AND FieldName = 'BenB_CCCD';

-- Bên A (thông tin nhà hàng): lấy từ SY_Setup - không cho phép nhập/sửa trực tiếp trên form HĐ
UPDATE SY_FormatFields
SET ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 1, IsReadOnlyEdit = 1
WHERE FormName = 'frmHopDong' AND FieldName IN ('BenA_NguoiDaiDien', 'BenA_ChucVu');

-- Cấu hình định dạng (FormatID) cho các trường
UPDATE SY_FormatFields SET FormatID = 't' WHERE FormName = 'frmHopDong' AND FieldName IN ('Tenchure', 'Tencodau', 'Diachi', 'Mail', 'BenB_CCCD', 'Nhamngay', 'Ghichu');
UPDATE SY_FormatFields SET FormatID = 'd' WHERE FormName = 'frmHopDong' AND FieldName IN ('Ngayhopdong');
UPDATE SY_FormatFields SET FormatID = 'sl' WHERE FormName = 'frmHopDong' AND FieldName IN ('Loaitiecid', 'Thoigianid', 'JsonSanhTiec');
UPDATE SY_FormatFields SET FormatID = 'n' WHERE FormName = 'frmHopDong' AND FieldName IN ('SobanManchinhthuc', 'SobanManduphong', 'SobanChaychinhthuc', 'SobanChayduphong', 'DaCocVND', 'Sotiencochopdong', 'Tongtiencoc');

-- Cấu hình DataSource cho các Dropdown
UPDATE SY_FormatFields
SET DataSource = '/api/API_Gateway_Router?List=API_DanhSachCaLam&Func=View'
WHERE FormName = 'frmHopDong' AND FieldName = 'Thoigianid';

UPDATE SY_FormatFields
SET DataSource = '/api/API_Gateway_Router?List=API_DanhSachLoaiHinhTiec&Func=View'
WHERE FormName = 'frmHopDong' AND FieldName = 'Loaitiecid';

UPDATE SY_FormatFields
SET DataSource = '/api/API_Gateway_Router?List=API_DanhSachSanh&Func=View'
WHERE FormName = 'frmHopDong' AND FieldName = 'JsonSanhTiec';

-- Cập nhật tên tiếng Việt thân thiện
UPDATE SY_FormatFields SET CaptionVN = N'Ngày lập HĐ' WHERE FormName = 'frmHopDong' AND FieldName = 'NgayLapHD';
UPDATE SY_FormatFields SET CaptionVN = N'Tháng lập HĐ' WHERE FormName = 'frmHopDong' AND FieldName = 'ThangLapHD';
UPDATE SY_FormatFields SET CaptionVN = N'Năm lập HĐ' WHERE FormName = 'frmHopDong' AND FieldName = 'NamLapHD';

UPDATE SY_FormatFields SET CaptionVN = N'Nhân viên phụ trách' WHERE FormName = 'frmHopDong' AND FieldName = 'BenA_NhanVienPhuTrach';
UPDATE SY_FormatFields SET CaptionVN = N'SĐT nhân viên' WHERE FormName = 'frmHopDong' AND FieldName = 'BenA_SDT_NhanVien';
UPDATE SY_FormatFields SET CaptionVN = N'Đại diện Bên A' WHERE FormName = 'frmHopDong' AND FieldName = 'BenA_NguoiDaiDien';
UPDATE SY_FormatFields SET CaptionVN = N'Chức vụ Bên A' WHERE FormName = 'frmHopDong' AND FieldName = 'BenA_ChucVu';

UPDATE SY_FormatFields SET CaptionVN = N'Đại diện Bên B' WHERE FormName = 'frmHopDong' AND FieldName = 'BenB_TenDaiDien';
UPDATE SY_FormatFields SET CaptionVN = N'Tên Chủ Tiệc' WHERE FormName = 'frmHopDong' AND FieldName = 'BenB_TenChuTiec';
UPDATE SY_FormatFields SET CaptionVN = N'Địa chỉ Bên B' WHERE FormName = 'frmHopDong' AND FieldName = 'BenB_DiaChi';
UPDATE SY_FormatFields SET CaptionVN = N'SĐT Bên B' WHERE FormName = 'frmHopDong' AND FieldName = 'BenB_DienThoai';
UPDATE SY_FormatFields SET CaptionVN = N'Chức vụ Bên B' WHERE FormName = 'frmHopDong' AND FieldName = 'BenB_ChucVu';
UPDATE SY_FormatFields SET CaptionVN = N'Số CCCD (Bên B)' WHERE FormName = 'frmHopDong' AND FieldName = 'BenB_CCCD';

UPDATE SY_FormatFields SET CaptionVN = N'Giờ bắt đầu' WHERE FormName = 'frmHopDong' AND FieldName = 'Tiec_GioBatDau';
UPDATE SY_FormatFields SET CaptionVN = N'Ngày đãi tiệc (DL)' WHERE FormName = 'frmHopDong' AND FieldName = 'Tiec_NgayDL';
UPDATE SY_FormatFields SET CaptionVN = N'Tháng đãi tiệc (DL)' WHERE FormName = 'frmHopDong' AND FieldName = 'Tiec_ThangDL';
UPDATE SY_FormatFields SET CaptionVN = N'Năm đãi tiệc (DL)' WHERE FormName = 'frmHopDong' AND FieldName = 'Tiec_NamDL';
UPDATE SY_FormatFields SET CaptionVN = N'Ngày đãi tiệc (AL)' WHERE FormName = 'frmHopDong' AND FieldName = 'Tiec_NgayAL';
UPDATE SY_FormatFields SET CaptionVN = N'Tháng đãi tiệc (AL)' WHERE FormName = 'frmHopDong' AND FieldName = 'Tiec_ThangAL';
UPDATE SY_FormatFields SET CaptionVN = N'Năm đãi tiệc (AL)' WHERE FormName = 'frmHopDong' AND FieldName = 'Tiec_NamAL';

UPDATE SY_FormatFields SET CaptionVN = N'Sảnh đãi tiệc' WHERE FormName = 'frmHopDong' AND FieldName = 'Tiec_SanhTiec';
UPDATE SY_FormatFields SET CaptionVN = N'Quy mô tối thiểu' WHERE FormName = 'frmHopDong' AND FieldName = 'Sanh_QuyMoMin';
UPDATE SY_FormatFields SET CaptionVN = N'Quy mô tối đa' WHERE FormName = 'frmHopDong' AND FieldName = 'Sanh_QuyMoMax';

UPDATE SY_FormatFields SET CaptionVN = N'Số bàn chính thức' WHERE FormName = 'frmHopDong' AND FieldName = 'Tiec_SoBanChinhThuc';
UPDATE SY_FormatFields SET CaptionVN = N'Số bàn tặng' WHERE FormName = 'frmHopDong' AND FieldName = 'Tiec_SoBanTang';
UPDATE SY_FormatFields SET CaptionVN = N'Số bàn dự phòng' WHERE FormName = 'frmHopDong' AND FieldName = 'Tiec_SoBanDuPhong';
UPDATE SY_FormatFields SET CaptionVN = N'Số khách/Bàn' WHERE FormName = 'frmHopDong' AND FieldName = 'Tiec_SoKhach1Ban';

UPDATE SY_FormatFields SET CaptionVN = N'Tiền cọc lần 1' WHERE FormName = 'frmHopDong' AND FieldName = 'Coc_Lan1_SoTien';
UPDATE SY_FormatFields SET CaptionVN = N'Tiền cọc bằng chữ' WHERE FormName = 'frmHopDong' AND FieldName = 'Coc_Lan1_BangChu';
UPDATE SY_FormatFields SET CaptionVN = N'Tiền cọc lần 2' WHERE FormName = 'frmHopDong' AND FieldName = 'Coc_Lan2_SoTien';
UPDATE SY_FormatFields SET CaptionVN = N'Tiền cọc lần 2 bằng chữ' WHERE FormName = 'frmHopDong' AND FieldName = 'Coc_Lan2_BangChu';
UPDATE SY_FormatFields SET CaptionVN = N'Ngày cọc' WHERE FormName = 'frmHopDong' AND FieldName = 'Coc_Ngay';
UPDATE SY_FormatFields SET CaptionVN = N'Tháng cọc' WHERE FormName = 'frmHopDong' AND FieldName = 'Coc_Thang';
UPDATE SY_FormatFields SET CaptionVN = N'Năm cọc' WHERE FormName = 'frmHopDong' AND FieldName = 'Coc_Nam';

UPDATE SY_FormatFields SET CaptionVN = N'Điều khoản bổ sung' WHERE FormName = 'frmHopDong' AND FieldName = 'DieuKhoanBoSung';
UPDATE SY_FormatFields SET CaptionVN = N'Khuyến mãi' WHERE FormName = 'frmHopDong' AND FieldName = 'DS_KhuyenMai';

-- Cập nhật tên tiếng Việt cho các trường mới
UPDATE SY_FormatFields SET CaptionVN = N'Tên chú rể' WHERE FormName = 'frmHopDong' AND FieldName = 'Tenchure';
UPDATE SY_FormatFields SET CaptionVN = N'Tên cô dâu' WHERE FormName = 'frmHopDong' AND FieldName = 'Tencodau';
UPDATE SY_FormatFields SET CaptionVN = N'Địa chỉ khách hàng' WHERE FormName = 'frmHopDong' AND FieldName = 'Diachi';
UPDATE SY_FormatFields SET CaptionVN = N'Email' WHERE FormName = 'frmHopDong' AND FieldName = 'Mail';
UPDATE SY_FormatFields SET CaptionVN = N'Ngày lập HĐ' WHERE FormName = 'frmHopDong' AND FieldName = 'Ngayhopdong';
UPDATE SY_FormatFields SET CaptionVN = N'Nhằm ngày âm lịch' WHERE FormName = 'frmHopDong' AND FieldName = 'Nhamngay';
UPDATE SY_FormatFields SET CaptionVN = N'Loại hình tiệc' WHERE FormName = 'frmHopDong' AND FieldName = 'Loaitiecid';
UPDATE SY_FormatFields SET CaptionVN = N'Ca đãi tiệc' WHERE FormName = 'frmHopDong' AND FieldName = 'Thoigianid';
UPDATE SY_FormatFields SET CaptionVN = N'Sảnh đãi tiệc' WHERE FormName = 'frmHopDong' AND FieldName = 'JsonSanhTiec';
UPDATE SY_FormatFields SET CaptionVN = N'Bàn mặn chính thức' WHERE FormName = 'frmHopDong' AND FieldName = 'SobanManchinhthuc';
UPDATE SY_FormatFields SET CaptionVN = N'Bàn mặn dự phòng' WHERE FormName = 'frmHopDong' AND FieldName = 'SobanManduphong';
UPDATE SY_FormatFields SET CaptionVN = N'Bàn chay chính thức' WHERE FormName = 'frmHopDong' AND FieldName = 'SobanChaychinhthuc';
UPDATE SY_FormatFields SET CaptionVN = N'Bàn chay dự phòng' WHERE FormName = 'frmHopDong' AND FieldName = 'SobanChayduphong';
UPDATE SY_FormatFields SET CaptionVN = N'Tiền cọc chỗ (Lần 1)' WHERE FormName = 'frmHopDong' AND FieldName = 'DaCocVND';
UPDATE SY_FormatFields SET CaptionVN = N'Tiền cọc hợp đồng (Lần 2)' WHERE FormName = 'frmHopDong' AND FieldName = 'Sotiencochopdong';
UPDATE SY_FormatFields SET CaptionVN = N'Tổng tiền cọc', ValidateRule = 'formula:{DaCocVND} + {Sotiencochopdong}' WHERE FormName = 'frmHopDong' AND FieldName = 'Tongtiencoc';
UPDATE SY_FormatFields SET CaptionVN = N'Ghi chú bổ sung' WHERE FormName = 'frmHopDong' AND FieldName = 'Ghichu';

-- Cập nhật tên tiếng Việt thân thiện cho các cột gốc (Grid mặc định)
UPDATE SY_FormatFields SET CaptionVN = N'Số hợp đồng' WHERE FormName = 'frmHopDong' AND FieldName = 'Sohopdong';
UPDATE SY_FormatFields SET CaptionVN = N'Số biên nhận' WHERE FormName = 'frmHopDong' AND FieldName = 'Sobiennhan';
UPDATE SY_FormatFields SET CaptionVN = N'Mã KH' WHERE FormName = 'frmHopDong' AND FieldName = 'Makh';
UPDATE SY_FormatFields SET CaptionVN = N'Tên khách hàng' WHERE FormName = 'frmHopDong' AND FieldName = 'TenKhachHang';
UPDATE SY_FormatFields SET CaptionVN = N'Điện thoại' WHERE FormName = 'frmHopDong' AND FieldName = 'DienThoai';
UPDATE SY_FormatFields SET CaptionVN = N'Ngày tổ chức' WHERE FormName = 'frmHopDong' AND FieldName = 'NgayToChuc';
UPDATE SY_FormatFields SET CaptionVN = N'Số bàn' WHERE FormName = 'frmHopDong' AND FieldName = 'SoBan';
UPDATE SY_FormatFields SET CaptionVN = N'Sảnh đặt' WHERE FormName = 'frmHopDong' AND FieldName = 'SanhDat';
UPDATE SY_FormatFields SET CaptionVN = N'Tổng tiền' WHERE FormName = 'frmHopDong' AND FieldName = 'TongTien';
UPDATE SY_FormatFields SET CaptionVN = N'Trạng thái' WHERE FormName = 'frmHopDong' AND FieldName = 'TrangThai';

-- Cấu hình thứ tự hiển thị (OrderNo) trên Form
UPDATE SY_FormatFields SET OrderNo = 1 WHERE FormName = 'frmHopDong' AND FieldName = 'Sohopdong';
UPDATE SY_FormatFields SET OrderNo = 2 WHERE FormName = 'frmHopDong' AND FieldName = 'Sobiennhan';
UPDATE SY_FormatFields SET OrderNo = 3 WHERE FormName = 'frmHopDong' AND FieldName = 'Makh';
UPDATE SY_FormatFields SET OrderNo = 4 WHERE FormName = 'frmHopDong' AND FieldName = 'TenKhachHang';
UPDATE SY_FormatFields SET OrderNo = 5 WHERE FormName = 'frmHopDong' AND FieldName = 'Tenchure';
UPDATE SY_FormatFields SET OrderNo = 6 WHERE FormName = 'frmHopDong' AND FieldName = 'Tencodau';
UPDATE SY_FormatFields SET OrderNo = 7 WHERE FormName = 'frmHopDong' AND FieldName = 'DienThoai';
UPDATE SY_FormatFields SET OrderNo = 8 WHERE FormName = 'frmHopDong' AND FieldName = 'Mail';
UPDATE SY_FormatFields SET OrderNo = 9 WHERE FormName = 'frmHopDong' AND FieldName = 'Diachi';
UPDATE SY_FormatFields SET OrderNo = 10 WHERE FormName = 'frmHopDong' AND FieldName = 'Ngayhopdong';
UPDATE SY_FormatFields SET OrderNo = 11 WHERE FormName = 'frmHopDong' AND FieldName = 'NgayToChuc';
UPDATE SY_FormatFields SET OrderNo = 12 WHERE FormName = 'frmHopDong' AND FieldName = 'Nhamngay';
UPDATE SY_FormatFields SET OrderNo = 13 WHERE FormName = 'frmHopDong' AND FieldName = 'Loaitiecid';
UPDATE SY_FormatFields SET OrderNo = 14 WHERE FormName = 'frmHopDong' AND FieldName = 'Thoigianid';
UPDATE SY_FormatFields SET OrderNo = 15 WHERE FormName = 'frmHopDong' AND FieldName = 'JsonSanhTiec';
UPDATE SY_FormatFields SET OrderNo = 16 WHERE FormName = 'frmHopDong' AND FieldName = 'SoBan';
UPDATE SY_FormatFields SET OrderNo = 17 WHERE FormName = 'frmHopDong' AND FieldName = 'SobanManchinhthuc';
UPDATE SY_FormatFields SET OrderNo = 18 WHERE FormName = 'frmHopDong' AND FieldName = 'SobanManduphong';
UPDATE SY_FormatFields SET OrderNo = 19 WHERE FormName = 'frmHopDong' AND FieldName = 'SobanChaychinhthuc';
UPDATE SY_FormatFields SET OrderNo = 20 WHERE FormName = 'frmHopDong' AND FieldName = 'SobanChayduphong';
UPDATE SY_FormatFields SET OrderNo = 21 WHERE FormName = 'frmHopDong' AND FieldName = 'DaCocVND';
UPDATE SY_FormatFields SET OrderNo = 22 WHERE FormName = 'frmHopDong' AND FieldName = 'Sotiencochopdong';
UPDATE SY_FormatFields SET OrderNo = 23 WHERE FormName = 'frmHopDong' AND FieldName = 'Tongtiencoc';
UPDATE SY_FormatFields SET OrderNo = 24 WHERE FormName = 'frmHopDong' AND FieldName = 'TongTien';
UPDATE SY_FormatFields SET OrderNo = 25 WHERE FormName = 'frmHopDong' AND FieldName = 'TrangThai';
UPDATE SY_FormatFields SET OrderNo = 26 WHERE FormName = 'frmHopDong' AND FieldName = 'Ghichu';
GO
