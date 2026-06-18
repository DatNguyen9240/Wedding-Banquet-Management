USE [QLTiec]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

PRINT N'=== BẮT ĐẦU CẬP NHẬT DỮ LIỆU KHUYẾN MÃI TIỆC CƯỚI VÀ TIỆC CÔNG TY ===';
GO

-- =========================================================================
-- I. ĐẢM BẢO DANH MỤC HÀNG HÓA/DỊCH VỤ CƯỚI ĐẦY ĐỦ TRONG dmHanghoa
-- =========================================================================
PRINT N'1. Đang đồng bộ danh mục dịch vụ khuyến mãi Tiệc Cưới vào dmHanghoa...';

IF NOT EXISTS (SELECT 1 FROM dmNhomhang WHERE NhomhangID = 'DV')
    INSERT INTO dmNhomhang (NhomhangID, Tennhomhang, IsHanghoa, IsQuyetToan) VALUES ('DV', N'Dịch vụ', 1, 1);
IF NOT EXISTS (SELECT 1 FROM dmNhomhang WHERE NhomhangID = 'TU')
    INSERT INTO dmNhomhang (NhomhangID, Tennhomhang, IsHanghoa, IsQuyetToan) VALUES ('TU', N'Thức uống', 1, 1);

-- Khai báo các biến đơn vị tính động để lấy chính xác DVTID từ database (thích ứng lỗi font như L?n, Ðia...)
DECLARE @DvtLan NVARCHAR(50), @DvtBan NVARCHAR(50), @DvtGoi NVARCHAR(50), @DvtDia NVARCHAR(50), @DvtChai NVARCHAR(50), @DvtLon NVARCHAR(50), @DvtKhach NVARCHAR(50);
SELECT TOP 1 @DvtLan = DVTID FROM dmDVT WHERE DVTID LIKE 'L%n';
SELECT TOP 1 @DvtBan = DVTID FROM dmDVT WHERE DVTID LIKE 'B%n';
SELECT TOP 1 @DvtGoi = DVTID FROM dmDVT WHERE DVTID LIKE 'G%i';
SELECT TOP 1 @DvtDia = DVTID FROM dmDVT WHERE DVTID LIKE '%ia';
SELECT TOP 1 @DvtChai = DVTID FROM dmDVT WHERE DVTID LIKE 'chai%';
SELECT TOP 1 @DvtLon = DVTID FROM dmDVT WHERE DVTID LIKE 'lon%';
SELECT TOP 1 @DvtKhach = DVTID FROM dmDVT WHERE DVTID LIKE 'Kh%ch%';

-- Fallback nếu không quét được
SET @DvtLan = ISNULL(@DvtLan, N'L?n');
SET @DvtBan = ISNULL(@DvtBan, N'Bàn');
SET @DvtGoi = ISNULL(@DvtGoi, N'Gói');
SET @DvtDia = ISNULL(@DvtDia, N'Ðia');
SET @DvtChai = ISNULL(@DvtChai, N'chai');
SET @DvtLon = ISNULL(@DvtLon, N'lon');
SET @DvtKhach = ISNULL(@DvtKhach, N'Khách');

-- Đảm bảo có ít nhất một gói thực đơn hợp lệ để tránh lỗi khóa ngoại FK_dmHanghoa_dmGoiThucDon
IF NOT EXISTS (SELECT 1 FROM dmGoiThucDon)
    INSERT INTO dmGoiThucDon (GoiThucDonID, TenGoiThucDon) VALUES ('Default', N'Gói mặc định');

-- Khai báo bảng tạm chứa danh sách 38 dịch vụ cưới
DECLARE @DVCuoi TABLE (
    Mahang VARCHAR(30),
    Tenhang NVARCHAR(250),
    Nhomhangid VARCHAR(50),
    DVTID NVARCHAR(50)
);

INSERT INTO @DVCuoi (Mahang, Tenhang, Nhomhangid, DVTID) VALUES
('MH_TC_01', N'Sân khấu tiêu chuẩn (7.2m x 3.6m x 0.8m)', 'DV', @DvtLan),
('MH_TC_02', N'Catwalk theo kích thước tiêu chuẩn', 'DV', @DvtLan),
('MH_TC_03', N'Hệ thống âm thanh - ánh sáng tiêu chuẩn', 'DV', @DvtLan),
('MH_TC_04', N'Phông màn sân khấu tiêu chuẩn: Tên CD & CR (Chữ cái)', 'DV', @DvtLan),
('MH_TC_05', N'Bàn ký tên hoa lụa cao cấp: Bút, liễn ký tên, khung hình', 'DV', @DvtLan),
('MH_TC_06', N'Trang trí hoa lụa bàn tiệc cao cấp', 'DV', @DvtLan),
('MH_TC_07', N'Trang trí lối đi sân khấu (Đèn + hoa lụa cao cấp).', 'DV', @DvtLan),
('MH_TC_08', N'Tháp ly hoa lụa cao cấp (Đá khói + 2 chai champage).', 'DV', @DvtLan),
('MH_TC_09', N'Bánh cưới 5 tầng hoa lụa cao cấp', 'DV', @DvtLan),
('MH_TC_10', N'Phòng trang điểm CD-CR', 'DV', @DvtLan),
('MH_TC_11', N'Lễ Tân hướng dẫn khách', 'DV', @DvtLan),
('MH_TC_12', N'Nước ngọt, nước suối suốt tiệc: 2.5h trong tiệc', 'TU', @DvtLan),
('MH_TC_13', N'Backdrop chụp hình hoa lụa cao cấp', 'DV', @DvtLan),
('MH_TC_14', N'Ăn nhẹ trước tiệc cho Bố Mẹ, CD-CR (Súp,cơm/mì: 06 khách)', 'DV', @DvtLan),
('MH_TC_15', N'Pháo hoa kim tuyến 2 lần (1 lần/2 viên)', 'DV', @DvtLan),
('MH_TC_16', N'Máy chiếu màn hình đầu tiệc', 'DV', @DvtLan),
('MH_TC_17', N'MC Lễ khai tiệc (Tiếng Việt)', 'DV', @DvtLan),
('MH_TC_18', N'Màn hình Led đầu tiệc (không bao gồm màn hình máy chiếu đầu tiệc)', 'DV', @DvtLan),
('MH_TC_19', N'Bánh khai vị Danish Ham Chesse đầu giờ', 'DV', @DvtLan),
('MH_TC_20', N'Bia Tiger chai nâu nhỏ (330ml) trong tiệc 2.5 giờ', 'TU', @DvtLan),
('MH_TC_21', N'Ăn nhẹ trước tiệc cho Bố Mẹ, CD-CR (Súp,cơm/mì: 10 khách)', 'DV', @DvtLan),
('MH_TC_22', N'Chương trình múa đôi khai tiệc: 2.000.000đ/show', 'DV', @DvtLan),
('MH_TC_23', N'Màn hình Led 12m2 suốt tiệc (không bao gồm màn hình máy chiếu)', 'DV', @DvtLan),
('MH_TC_24', N'Ban nhạc điện tử 4 nhạc công 2 tiếng gồm: Guita solo, Guita Bass, Organ, Drum', 'DV', @DvtLan),
('MH_TC_25', N'Tặng trang trí hoa tươi trị giá: 10.000.000đ (Bao gồm: Bàn Gallery, Backdrop, lối đi sân khấu mẫu nhà hàng) & không bao gồm trang trí hoa lụa trên', 'DV', @DvtLan),
('MH_TC_26', N'Hoa tươi bàn tiệc mẫu nhà hàng', 'DV', @DvtLan),
('MH_TC_27', N'01 Ca sỹ hát 03 bài', 'DV', @DvtLan),
('MH_TC_28', N'Chương trình Múa khai tiệc 06 người: 3.000.000đ(Không bao gồm chương trình múa trên).', 'DV', @DvtLan),
('MH_TC_29', N'Bia Tiger lon xanh (330ml) 2.5h (không bao gồm bia Tiger chai nhỏ)', 'TU', @DvtLan),
('MH_TC_30', N'Trọn gói trang trí hoa tươi cao cấp: Background + Bàn Gallery trị giá 22.000.000đ (Không bao gồm tặng trang trí hoa tươi 10.000.000đ)', 'DV', @DvtLan),
('MH_TC_31', N'Bàn ăn thử 10 khách', 'DV', @DvtBan),
('MH_TC_32', N'Băng đăng thiên nga điêu khắc', 'DV', @DvtLan),
('MH_TC_33', N'Chương trình Múa khai tiệc (6 người): 5.000.000đ/show (Không bao gồm chương trình múa trên)', 'DV', @DvtLan),
('MH_TC_34', N'Ban nhạc đón khách (Piano + Violon)', 'DV', @DvtLan),
('MH_TC_35', N'Trang trí hoa tươi đặc biệt 2 bàn gia đình', 'DV', @DvtLan),
('MH_TC_36', N'Trọn gói trang trí hoa tươi cao cấp: Background + Bàn Gallery + Catwalk + Sân khấu trị giá 30.000.000đ (Không bao gồm các gói trang trí hoa tươi và hoa lụa được tặng trên)', 'DV', @DvtLan),
('MH_TC_37', N'Bong bóng bay kích nổ (4 quả)', 'DV', @DvtLan),
('MH_TC_38', N'Bia Heineken lon xanh (330ml) trong 2.5h (không bao gồm bia tặng trên)', 'TU', @DvtLan);

INSERT INTO dmHanghoa (Mahang, Tenhang, Nhomhangid, DVTID, DateCreate, IsMacDinhHopDong, IsNgungSuDung, IsQuyetToanTiec, GoiThucDonID)
SELECT src.Mahang, src.Tenhang, src.Nhomhangid, src.DVTID, GETDATE(), 0, 0, 1, (SELECT TOP 1 GoiThucDonID FROM dmGoiThucDon)
FROM @DVCuoi src
LEFT JOIN dmHanghoa dest ON src.Mahang = dest.Mahang
WHERE dest.Mahang IS NULL;

PRINT N'>> Đã đồng bộ danh mục hàng hóa!';


-- =========================================================================
-- II. XÓA DỮ LIỆU KHUYẾN MÃI CŨ CỦA TIỆC CƯỚI (BLT000001)
-- =========================================================================
PRINT N'2. Đang xóa cấu hình khuyến mãi Tiệc Cưới cũ...';
DELETE FROM tbmk_Banuudaict WHERE DocumentID LIKE 'KM_TC_%';
DELETE FROM tbmk_Banuudai WHERE Loaitiecid = 'BLT000001' OR DocumentID LIKE 'KM_TC_%';

-- =========================================================================
-- III. THIẾT LẬP CHƯƠNG TRÌNH KHUYẾN MÃI TIỆC CƯỚI MỚI (tbmk_Banuudai)
-- =========================================================================
PRINT N'3. Đang chèn cấu hình Master ưu đãi Tiệc Cưới (11 mốc)...';
INSERT INTO tbmk_Banuudai (DocumentID, Tenuudai, Tusoluongban, Densoluongban, IsKetthuc, Loaitiecid, DateCreate, GoiThucDonID)
VALUES
('KM_TC_10', N'Tiệc cưới từ 10 - 14 bàn', 10, 14, 0, 'BLT000001', GETDATE(), (SELECT TOP 1 GoiThucDonID FROM dmGoiThucDon)),
('KM_TC_15', N'Tiệc cưới từ 15 - 19 bàn', 15, 19, 0, 'BLT000001', GETDATE(), (SELECT TOP 1 GoiThucDonID FROM dmGoiThucDon)),
('KM_TC_20', N'Tiệc cưới từ 20 - 24 bàn', 20, 24, 0, 'BLT000001', GETDATE(), (SELECT TOP 1 GoiThucDonID FROM dmGoiThucDon)),
('KM_TC_25', N'Tiệc cưới từ 25 - 34 bàn', 25, 34, 0, 'BLT000001', GETDATE(), (SELECT TOP 1 GoiThucDonID FROM dmGoiThucDon)),
('KM_TC_35', N'Tiệc cưới từ 35 - 44 bàn', 35, 44, 0, 'BLT000001', GETDATE(), (SELECT TOP 1 GoiThucDonID FROM dmGoiThucDon)),
('KM_TC_45', N'Tiệc cưới từ 45 - 54 bàn', 45, 54, 0, 'BLT000001', GETDATE(), (SELECT TOP 1 GoiThucDonID FROM dmGoiThucDon)),
('KM_TC_55', N'Tiệc cưới từ 55 - 64 bàn', 55, 64, 0, 'BLT000001', GETDATE(), (SELECT TOP 1 GoiThucDonID FROM dmGoiThucDon)),
('KM_TC_65', N'Tiệc cưới từ 65 - 74 bàn', 65, 74, 0, 'BLT000001', GETDATE(), (SELECT TOP 1 GoiThucDonID FROM dmGoiThucDon)),
('KM_TC_75', N'Tiệc cưới từ 75 - 84 bàn', 75, 84, 0, 'BLT000001', GETDATE(), (SELECT TOP 1 GoiThucDonID FROM dmGoiThucDon)),
('KM_TC_85', N'Tiệc cưới từ 85 - 94 bàn', 85, 94, 0, 'BLT000001', GETDATE(), (SELECT TOP 1 GoiThucDonID FROM dmGoiThucDon)),
('KM_TC_95', N'Tiệc cưới từ 95 bàn trở lên', 95, 999, 0, 'BLT000001', GETDATE(), (SELECT TOP 1 GoiThucDonID FROM dmGoiThucDon));

-- =========================================================================
-- IV. THIẾT LẬP CHI TIẾT DỊCH VỤ CHO TỪNG MỐC ƯU ĐÃI TIỆC CƯỚI (tbmk_Banuudaict)
-- =========================================================================
PRINT N'4. Đang chèn chi tiết dịch vụ ưu đãi Tiệc Cưới...';

DECLARE @Mappings TABLE (
    DocID VARCHAR(20),
    ItemNum INT
);

-- KM_TC_10: 1 -> 12
INSERT INTO @Mappings (DocID, ItemNum)
SELECT 'KM_TC_10', number FROM master..spt_values WHERE type = 'P' AND number BETWEEN 1 AND 12;

-- KM_TC_15: 1 -> 17
INSERT INTO @Mappings (DocID, ItemNum)
SELECT 'KM_TC_15', number FROM master..spt_values WHERE type = 'P' AND number BETWEEN 1 AND 17;

-- KM_TC_20: 1 -> 21
INSERT INTO @Mappings (DocID, ItemNum)
SELECT 'KM_TC_20', number FROM master..spt_values WHERE type = 'P' AND number BETWEEN 1 AND 21;

-- KM_TC_25: 1 -> 24
INSERT INTO @Mappings (DocID, ItemNum)
SELECT 'KM_TC_25', number FROM master..spt_values WHERE type = 'P' AND number BETWEEN 1 AND 24;

-- KM_TC_35: 1 -> 26
INSERT INTO @Mappings (DocID, ItemNum)
SELECT 'KM_TC_35', number FROM master..spt_values WHERE type = 'P' AND number BETWEEN 1 AND 26;

-- KM_TC_45: 1 -> 28
INSERT INTO @Mappings (DocID, ItemNum)
SELECT 'KM_TC_45', number FROM master..spt_values WHERE type = 'P' AND number BETWEEN 1 AND 28;

-- KM_TC_55: 1-19, 21-28, 29, 30 (Bỏ 20 do có Tiger lon xanh thay thế)
INSERT INTO @Mappings (DocID, ItemNum)
SELECT 'KM_TC_55', number FROM master..spt_values WHERE type = 'P' AND number BETWEEN 1 AND 19;
INSERT INTO @Mappings (DocID, ItemNum)
SELECT 'KM_TC_55', number FROM master..spt_values WHERE type = 'P' AND number BETWEEN 21 AND 28;
INSERT INTO @Mappings (DocID, ItemNum) VALUES ('KM_TC_55', 29), ('KM_TC_55', 30);

-- KM_TC_65: 1-19, 21-28, 29, 30, 31, 32
INSERT INTO @Mappings (DocID, ItemNum)
SELECT 'KM_TC_65', number FROM master..spt_values WHERE type = 'P' AND number BETWEEN 1 AND 19;
INSERT INTO @Mappings (DocID, ItemNum)
SELECT 'KM_TC_65', number FROM master..spt_values WHERE type = 'P' AND number BETWEEN 21 AND 28;
INSERT INTO @Mappings (DocID, ItemNum) VALUES ('KM_TC_65', 29), ('KM_TC_65', 30), ('KM_TC_65', 31), ('KM_TC_65', 32);

-- KM_TC_75: 1-19, 21-28, 29, 30, 31, 32, 33, 34, 35
INSERT INTO @Mappings (DocID, ItemNum)
SELECT 'KM_TC_75', number FROM master..spt_values WHERE type = 'P' AND number BETWEEN 1 AND 19;
INSERT INTO @Mappings (DocID, ItemNum)
SELECT 'KM_TC_75', number FROM master..spt_values WHERE type = 'P' AND number BETWEEN 21 AND 28;
INSERT INTO @Mappings (DocID, ItemNum)
SELECT 'KM_TC_75', number FROM master..spt_values WHERE type = 'P' AND number BETWEEN 29 AND 35;

-- KM_TC_85: 1-19, 21-28, 29, 30, 31, 32, 33, 34, 35, 36, 37
INSERT INTO @Mappings (DocID, ItemNum)
SELECT 'KM_TC_85', number FROM master..spt_values WHERE type = 'P' AND number BETWEEN 1 AND 19;
INSERT INTO @Mappings (DocID, ItemNum)
SELECT 'KM_TC_85', number FROM master..spt_values WHERE type = 'P' AND number BETWEEN 21 AND 28;
INSERT INTO @Mappings (DocID, ItemNum)
SELECT 'KM_TC_85', number FROM master..spt_values WHERE type = 'P' AND number BETWEEN 29 AND 37;

-- KM_TC_95: 1-19, 21-28, 30-37, 38 (Bỏ 29 do Heineken thay thế)
INSERT INTO @Mappings (DocID, ItemNum)
SELECT 'KM_TC_95', number FROM master..spt_values WHERE type = 'P' AND number BETWEEN 1 AND 19;
INSERT INTO @Mappings (DocID, ItemNum)
SELECT 'KM_TC_95', number FROM master..spt_values WHERE type = 'P' AND number BETWEEN 21 AND 28;
INSERT INTO @Mappings (DocID, ItemNum)
SELECT 'KM_TC_95', number FROM master..spt_values WHERE type = 'P' AND number BETWEEN 30 AND 38;

-- Thực hiện Insert
INSERT INTO tbmk_Banuudaict (UserAutoID, DocumentID, Mahang, Soluong, Dongia, Sotien, DateCreate, STT, IsNTL, IsTTS)
SELECT 
    LOWER(REPLACE(CAST(NEWID() AS VARCHAR(50)), '-', '')),
    m.DocID,
    'MH_TC_' + RIGHT('0' + CAST(m.ItemNum AS VARCHAR(2)), 2),
    1,
    0,
    0,
    GETDATE(),
    m.ItemNum,
    0,
    0
FROM @Mappings m;

PRINT N'>> Đã thiết lập chi tiết khuyến mãi Tiệc Cưới!';

-- =========================================================================
-- V. ĐỒNG BỘ KHUYẾN MÃI TIỆC CÔNG TY (Loaitiecid = 'BLT000002') TỪ HỘI NGHỊ
-- =========================================================================
PRINT N'5. Đang đồng bộ chương trình khuyến mãi Tiệc Công Ty (loại BLT000002)...';

-- Xóa dữ liệu khuyến mãi cũ của Tiệc Công Ty
DELETE FROM tbmk_Banuudaict WHERE DocumentID LIKE 'KM_CT_%';
DELETE FROM tbmk_Banuudai WHERE Loaitiecid = 'BLT000002' OR DocumentID LIKE 'KM_CT_%';

-- Clone dữ liệu Master từ loại hình Hội nghị + Break Tea (BLT000004) sang loại hình Triển lãm + Tiệc (BLT000002 - Tiệc công ty)
INSERT INTO tbmk_Banuudai (DocumentID, Tenuudai, Tusoluongban, Densoluongban, IsKetthuc, Loaitiecid, DateCreate, Tungay, Denngay, Nhahangid, BranchID, GoiThucDonID)
SELECT 
    REPLACE(DocumentID, 'KM_HN_', 'KM_CT_'),
    REPLACE(Tenuudai, N'Hội nghị + Tiệc Break Tea', N'Tiệc công ty'),
    Tusoluongban,
    Densoluongban,
    IsKetthuc,
    'BLT000002',
    GETDATE(),
    Tungay,
    Denngay,
    Nhahangid,
    BranchID,
    ISNULL(GoiThucDonID, (SELECT TOP 1 GoiThucDonID FROM dmGoiThucDon))
FROM tbmk_Banuudai
WHERE Loaitiecid = 'BLT000004';

-- Clone dữ liệu Detail tương ứng
INSERT INTO tbmk_Banuudaict (UserAutoID, DocumentID, Mahang, Soluong, Dongia, Sotien, DateCreate, STT, IsNTL, IsTTS)
SELECT 
    LOWER(REPLACE(CAST(NEWID() AS VARCHAR(50)), '-', '')),
    REPLACE(DocumentID, 'KM_HN_', 'KM_CT_'),
    Mahang,
    Soluong,
    Dongia,
    Sotien,
    GETDATE(),
    STT,
    IsNTL,
    IsTTS
FROM tbmk_Banuudaict
WHERE DocumentID LIKE 'KM_HN_%';

PRINT N'>> Đã đồng bộ dữ liệu khuyến mãi Tiệc Công Ty!';

PRINT N'=== HOÀN THÀNH CẬP NHẬT DỮ LIỆU KHUYẾN MÃI ===';
