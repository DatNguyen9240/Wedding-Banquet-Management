-- =========================================================================
-- SCRIPT IMPORT CHƯƠNG TRÌNH KHUYẾN MÃI TIỆC CÔNG TY (HỘI NGHỊ)
-- Tự động xác định mã loại tiệc từ dmLoaihinhtiec (thường là 'BLT000004')
-- =========================================================================
USE [QLTiec]
GO

-- 1. Tìm mã Loại hình tiệc tương ứng với Hội Nghị / Tiệc Công Ty
DECLARE @LoaiTiecID varchar(10);
SELECT TOP 1 @LoaiTiecID = Loaitiecid 
FROM dmLoaihinhtiec 
WHERE Tenloaitiec LIKE N'%Hội Nghị%' 
   OR Tenloaitiec LIKE N'%Công Ty%' 
   OR Loaitiecid = 'BLT000004';

IF @LoaiTiecID IS NULL SET @LoaiTiecID = 'BLT000004'; -- Fallback mặc định

PRINT N'Đang cấu hình ưu đãi cho loại tiệc mã: ' + @LoaiTiecID;

-- 1.1 Tìm hoặc gán giá trị mặc định cho cột GoiThucDonID (cột bắt buộc NOT NULL ở DB khách hàng)
DECLARE @DefaultGoiThucDonID varchar(50);
SELECT TOP 1 @DefaultGoiThucDonID = GoiThucDonID FROM dmHanghoa WHERE GoiThucDonID IS NOT NULL AND GoiThucDonID <> '';
IF @DefaultGoiThucDonID IS NULL SELECT TOP 1 @DefaultGoiThucDonID = GoiThucDonID FROM tbmk_Banuudai WHERE GoiThucDonID IS NOT NULL AND GoiThucDonID <> '';
IF @DefaultGoiThucDonID IS NULL SET @DefaultGoiThucDonID = ''; -- fallback nếu trống hoàn toàn

PRINT N'Sử dụng GoiThucDonID mặc định: ' + @DefaultGoiThucDonID;

-- 2. Thêm danh mục các mặt hàng/dịch vụ quà tặng vào dmHanghoa (nếu chưa tồn tại)
-- Để tránh bị lỗi khóa ngoại khi JOIN
IF NOT EXISTS (SELECT 1 FROM dmHanghoa WHERE Mahang = 'MH_CT_01') 
    INSERT INTO dmHanghoa (Mahang, Tenhang, GoiThucDonID, DateCreate) VALUES ('MH_CT_01', N'Sân khấu tiêu chuẩn (7.2m x 3.6m x 0.8m)', @DefaultGoiThucDonID, GETDATE());
IF NOT EXISTS (SELECT 1 FROM dmHanghoa WHERE Mahang = 'MH_CT_02') 
    INSERT INTO dmHanghoa (Mahang, Tenhang, GoiThucDonID, DateCreate) VALUES ('MH_CT_02', N'Âm thanh ánh sáng tiêu chuẩn + 02 Micro', @DefaultGoiThucDonID, GETDATE());
IF NOT EXISTS (SELECT 1 FROM dmHanghoa WHERE Mahang = 'MH_CT_03') 
    INSERT INTO dmHanghoa (Mahang, Tenhang, GoiThucDonID, DateCreate) VALUES ('MH_CT_03', N'Bục phát biểu + micro cổ cò', @DefaultGoiThucDonID, GETDATE());
IF NOT EXISTS (SELECT 1 FROM dmHanghoa WHERE Mahang = 'MH_CT_04') 
    INSERT INTO dmHanghoa (Mahang, Tenhang, GoiThucDonID, DateCreate) VALUES ('MH_CT_04', N'Hoa tươi bàn lễ tân đón khách', @DefaultGoiThucDonID, GETDATE());
IF NOT EXISTS (SELECT 1 FROM dmHanghoa WHERE Mahang = 'MH_CT_05') 
    INSERT INTO dmHanghoa (Mahang, Tenhang, GoiThucDonID, DateCreate) VALUES ('MH_CT_05', N'Hoa tươi bàn tiệc', @DefaultGoiThucDonID, GETDATE());
IF NOT EXISTS (SELECT 1 FROM dmHanghoa WHERE Mahang = 'MH_CT_06') 
    INSERT INTO dmHanghoa (Mahang, Tenhang, GoiThucDonID, DateCreate) VALUES ('MH_CT_06', N'Hoa tươi bàn đại biểu, bục phát biểu', @DefaultGoiThucDonID, GETDATE());
IF NOT EXISTS (SELECT 1 FROM dmHanghoa WHERE Mahang = 'MH_CT_07') 
    INSERT INTO dmHanghoa (Mahang, Tenhang, GoiThucDonID, DateCreate) VALUES ('MH_CT_07', N'Pháo hoa kim tuyến (01 lần/ 2 viên)', @DefaultGoiThucDonID, GETDATE());
IF NOT EXISTS (SELECT 1 FROM dmHanghoa WHERE Mahang = 'MH_CT_08') 
    INSERT INTO dmHanghoa (Mahang, Tenhang, GoiThucDonID, DateCreate) VALUES ('MH_CT_08', N'Nước ngọt, nước suối suốt tiệc', @DefaultGoiThucDonID, GETDATE());
IF NOT EXISTS (SELECT 1 FROM dmHanghoa WHERE Mahang = 'MH_CT_09') 
    INSERT INTO dmHanghoa (Mahang, Tenhang, GoiThucDonID, DateCreate) VALUES ('MH_CT_09', N'Thi công backdrop chụp hình', @DefaultGoiThucDonID, GETDATE());
IF NOT EXISTS (SELECT 1 FROM dmHanghoa WHERE Mahang = 'MH_CT_10') 
    INSERT INTO dmHanghoa (Mahang, Tenhang, GoiThucDonID, DateCreate) VALUES ('MH_CT_10', N'Thi công backdrop sân khấu', @DefaultGoiThucDonID, GETDATE());
IF NOT EXISTS (SELECT 1 FROM dmHanghoa WHERE Mahang = 'MH_CT_11') 
    INSERT INTO dmHanghoa (Mahang, Tenhang, GoiThucDonID, DateCreate) VALUES ('MH_CT_11', N'Thêm 02 micro (tổng 04 cái)', @DefaultGoiThucDonID, GETDATE());
IF NOT EXISTS (SELECT 1 FROM dmHanghoa WHERE Mahang = 'MH_CT_12') 
    INSERT INTO dmHanghoa (Mahang, Tenhang, GoiThucDonID, DateCreate) VALUES ('MH_CT_12', N'Bia Tiger chai nâu nhỏ (330ml) trong tiệc 2.5h', @DefaultGoiThucDonID, GETDATE());
IF NOT EXISTS (SELECT 1 FROM dmHanghoa WHERE Mahang = 'MH_CT_13') 
    INSERT INTO dmHanghoa (Mahang, Tenhang, GoiThucDonID, DateCreate) VALUES ('MH_CT_13', N'Tặng rehearsal 2 giờ trước sự kiện không máy lạnh (ATAS + Led)', @DefaultGoiThucDonID, GETDATE());
IF NOT EXISTS (SELECT 1 FROM dmHanghoa WHERE Mahang = 'MH_CT_14') 
    INSERT INTO dmHanghoa (Mahang, Tenhang, GoiThucDonID, DateCreate) VALUES ('MH_CT_14', N'Màn hình LED 18m2 (6m x 3m)/ show', @DefaultGoiThucDonID, GETDATE());
IF NOT EXISTS (SELECT 1 FROM dmHanghoa WHERE Mahang = 'MH_CT_15') 
    INSERT INTO dmHanghoa (Mahang, Tenhang, GoiThucDonID, DateCreate) VALUES ('MH_CT_15', N'Tặng rehearsal 2 giờ trước sự kiện có máy lạnh (ATAS + Led)', @DefaultGoiThucDonID, GETDATE());
IF NOT EXISTS (SELECT 1 FROM dmHanghoa WHERE Mahang = 'MH_CT_16') 
    INSERT INTO dmHanghoa (Mahang, Tenhang, GoiThucDonID, DateCreate) VALUES ('MH_CT_16', N'Tặng phí Setup nửa ngày trước sự kiện (04 tiếng)', @DefaultGoiThucDonID, GETDATE());
IF NOT EXISTS (SELECT 1 FROM dmHanghoa WHERE Mahang = 'MH_CT_17') 
    INSERT INTO dmHanghoa (Mahang, Tenhang, GoiThucDonID, DateCreate) VALUES ('MH_CT_17', N'Tặng Karaoke 2 tiếng', @DefaultGoiThucDonID, GETDATE());
IF NOT EXISTS (SELECT 1 FROM dmHanghoa WHERE Mahang = 'MH_CT_18') 
    INSERT INTO dmHanghoa (Mahang, Tenhang, GoiThucDonID, DateCreate) VALUES ('MH_CT_18', N'Bia Tiger lon xanh (330ml) trong tiệc 2.5h', @DefaultGoiThucDonID, GETDATE());
IF NOT EXISTS (SELECT 1 FROM dmHanghoa WHERE Mahang = 'MH_CT_19') 
    INSERT INTO dmHanghoa (Mahang, Tenhang, GoiThucDonID, DateCreate) VALUES ('MH_CT_19', N'Màn hình LED 24m2 (8m x 3m)/ show', @DefaultGoiThucDonID, GETDATE());

-- 3. Xóa các cấu hình ưu đãi cũ của Loại tiệc này để nạp mới hoàn toàn
DELETE FROM tbmk_Banuudaict 
WHERE DocumentID IN (SELECT DocumentID FROM tbmk_Banuudai WHERE Loaitiecid = @LoaiTiecID);

DELETE FROM tbmk_Banuudai 
WHERE Loaitiecid = @LoaiTiecID;

-- 4. Thêm các mốc số bàn (Bảng Cha)
INSERT INTO tbmk_Banuudai (DocumentID, Tenuudai, Tusoluongban, Densoluongban, Loaitiecid, GoiThucDonID, DateCreate) VALUES 
('KM_HN_10', N'Mốc 10 Bàn Tiệc Công Ty', 10, 14, @LoaiTiecID, @DefaultGoiThucDonID, GETDATE()),
('KM_HN_15', N'Mốc 15 Bàn Tiệc Công Ty', 15, 24, @LoaiTiecID, @DefaultGoiThucDonID, GETDATE()),
('KM_HN_25', N'Mốc 25 Bàn Tiệc Công Ty', 25, 34, @LoaiTiecID, @DefaultGoiThucDonID, GETDATE()),
('KM_HN_35', N'Mốc 35 Bàn Tiệc Công Ty', 35, 44, @LoaiTiecID, @DefaultGoiThucDonID, GETDATE()),
('KM_HN_45', N'Mốc 45 Bàn Tiệc Công Ty', 45, 54, @LoaiTiecID, @DefaultGoiThucDonID, GETDATE()),
('KM_HN_55', N'Mốc 55 Bàn Tiệc Công Ty', 55, 64, @LoaiTiecID, @DefaultGoiThucDonID, GETDATE()),
('KM_HN_65', N'Mốc 65 Bàn Tiệc Công Ty', 65, 999, @LoaiTiecID, @DefaultGoiThucDonID, GETDATE());

-- 5. Thêm chi tiết quà tặng lũy tiến theo từng mốc (Bảng Con)
INSERT INTO tbmk_Banuudaict (UserAutoID, DocumentID, Mahang, Soluong, STT) VALUES 

-- ====== MỐC 10 BÀN ======
('ID_HN_10_01', 'KM_HN_10', 'MH_CT_01', 1, 1),
('ID_HN_10_02', 'KM_HN_10', 'MH_CT_02', 1, 2),
('ID_HN_10_03', 'KM_HN_10', 'MH_CT_03', 1, 3),
('ID_HN_10_04', 'KM_HN_10', 'MH_CT_04', 1, 4),
('ID_HN_10_05', 'KM_HN_10', 'MH_CT_05', 1, 5),
('ID_HN_10_06', 'KM_HN_10', 'MH_CT_06', 1, 6),
('ID_HN_10_07', 'KM_HN_10', 'MH_CT_07', 1, 7),

-- ====== MỐC 15 BÀN ======
('ID_HN_15_01', 'KM_HN_15', 'MH_CT_01', 1, 1),
('ID_HN_15_02', 'KM_HN_15', 'MH_CT_02', 1, 2),
('ID_HN_15_03', 'KM_HN_15', 'MH_CT_03', 1, 3),
('ID_HN_15_04', 'KM_HN_15', 'MH_CT_04', 1, 4),
('ID_HN_15_05', 'KM_HN_15', 'MH_CT_05', 1, 5),
('ID_HN_15_06', 'KM_HN_15', 'MH_CT_06', 1, 6),
('ID_HN_15_07', 'KM_HN_15', 'MH_CT_07', 1, 7),
('ID_HN_15_08', 'KM_HN_15', 'MH_CT_08', 1, 8),
('ID_HN_15_09', 'KM_HN_15', 'MH_CT_09', 1, 9),
('ID_HN_15_10', 'KM_HN_15', 'MH_CT_10', 1, 10),

-- ====== MỐC 25 BÀN ======
('ID_HN_25_01', 'KM_HN_25', 'MH_CT_01', 1, 1),
('ID_HN_25_02', 'KM_HN_25', 'MH_CT_02', 1, 2),
('ID_HN_25_03', 'KM_HN_25', 'MH_CT_03', 1, 3),
('ID_HN_25_04', 'KM_HN_25', 'MH_CT_04', 1, 4),
('ID_HN_25_05', 'KM_HN_25', 'MH_CT_05', 1, 5),
('ID_HN_25_06', 'KM_HN_25', 'MH_CT_06', 1, 6),
('ID_HN_25_07', 'KM_HN_25', 'MH_CT_07', 1, 7),
('ID_HN_25_08', 'KM_HN_25', 'MH_CT_08', 1, 8),
('ID_HN_25_09', 'KM_HN_25', 'MH_CT_09', 1, 9),
('ID_HN_25_10', 'KM_HN_25', 'MH_CT_10', 1, 10),
('ID_HN_25_11', 'KM_HN_25', 'MH_CT_11', 1, 11),
('ID_HN_25_12', 'KM_HN_25', 'MH_CT_12', 1, 12),

-- ====== MỐC 35 BÀN ======
('ID_HN_35_01', 'KM_HN_35', 'MH_CT_01', 1, 1),
('ID_HN_35_02', 'KM_HN_35', 'MH_CT_02', 1, 2),
('ID_HN_35_03', 'KM_HN_35', 'MH_CT_03', 1, 3),
('ID_HN_35_04', 'KM_HN_35', 'MH_CT_04', 1, 4),
('ID_HN_35_05', 'KM_HN_35', 'MH_CT_05', 1, 5),
('ID_HN_35_06', 'KM_HN_35', 'MH_CT_06', 1, 6),
('ID_HN_35_07', 'KM_HN_35', 'MH_CT_07', 1, 7),
('ID_HN_35_08', 'KM_HN_35', 'MH_CT_08', 1, 8),
('ID_HN_35_09', 'KM_HN_35', 'MH_CT_09', 1, 9),
('ID_HN_35_10', 'KM_HN_35', 'MH_CT_10', 1, 10),
('ID_HN_35_11', 'KM_HN_35', 'MH_CT_11', 1, 11),
('ID_HN_35_12', 'KM_HN_35', 'MH_CT_12', 1, 12),
('ID_HN_35_13', 'KM_HN_35', 'MH_CT_13', 1, 13),
('ID_HN_35_14', 'KM_HN_35', 'MH_CT_14', 1, 14),

-- ====== MỐC 45 BÀN ======
('ID_HN_45_01', 'KM_HN_45', 'MH_CT_01', 1, 1),
('ID_HN_45_02', 'KM_HN_45', 'MH_CT_02', 1, 2),
('ID_HN_45_03', 'KM_HN_45', 'MH_CT_03', 1, 3),
('ID_HN_45_04', 'KM_HN_45', 'MH_CT_04', 1, 4),
('ID_HN_45_05', 'KM_HN_45', 'MH_CT_05', 1, 5),
('ID_HN_45_06', 'KM_HN_45', 'MH_CT_06', 1, 6),
('ID_HN_45_07', 'KM_HN_45', 'MH_CT_07', 1, 7),
('ID_HN_45_08', 'KM_HN_45', 'MH_CT_08', 1, 8),
('ID_HN_45_09', 'KM_HN_45', 'MH_CT_09', 1, 9),
('ID_HN_45_10', 'KM_HN_45', 'MH_CT_10', 1, 10),
('ID_HN_45_11', 'KM_HN_45', 'MH_CT_11', 1, 11),
('ID_HN_45_12', 'KM_HN_45', 'MH_CT_12', 1, 12),
('ID_HN_45_13', 'KM_HN_45', 'MH_CT_13', 1, 13),
('ID_HN_45_14', 'KM_HN_45', 'MH_CT_14', 1, 14),
('ID_HN_45_15', 'KM_HN_45', 'MH_CT_15', 1, 15),
('ID_HN_45_16', 'KM_HN_45', 'MH_CT_16', 1, 16),
('ID_HN_45_17', 'KM_HN_45', 'MH_CT_17', 1, 17),

-- ====== MỐC 55 BÀN ======
('ID_HN_55_01', 'KM_HN_55', 'MH_CT_01', 1, 1),
('ID_HN_55_02', 'KM_HN_55', 'MH_CT_02', 1, 2),
('ID_HN_55_03', 'KM_HN_55', 'MH_CT_03', 1, 3),
('ID_HN_55_04', 'KM_HN_55', 'MH_CT_04', 1, 4),
('ID_HN_55_05', 'KM_HN_55', 'MH_CT_05', 1, 5),
('ID_HN_55_06', 'KM_HN_55', 'MH_CT_06', 1, 6),
('ID_HN_55_07', 'KM_HN_55', 'MH_CT_07', 1, 7),
('ID_HN_55_08', 'KM_HN_55', 'MH_CT_08', 1, 8),
('ID_HN_55_09', 'KM_HN_55', 'MH_CT_09', 1, 9),
('ID_HN_55_10', 'KM_HN_55', 'MH_CT_10', 1, 10),
('ID_HN_55_11', 'KM_HN_55', 'MH_CT_11', 1, 11),
('ID_HN_55_12', 'KM_HN_55', 'MH_CT_12', 1, 12),
('ID_HN_55_13', 'KM_HN_55', 'MH_CT_13', 1, 13),
('ID_HN_55_14', 'KM_HN_55', 'MH_CT_14', 1, 14),
('ID_HN_55_15', 'KM_HN_55', 'MH_CT_15', 1, 15),
('ID_HN_55_16', 'KM_HN_55', 'MH_CT_16', 1, 16),
('ID_HN_55_17', 'KM_HN_55', 'MH_CT_17', 1, 17),
('ID_HN_55_18', 'KM_HN_55', 'MH_CT_18', 1, 18),

-- ====== MỐC 65 BÀN ======
('ID_HN_65_01', 'KM_HN_65', 'MH_CT_01', 1, 1),
('ID_HN_65_02', 'KM_HN_65', 'MH_CT_02', 1, 2),
('ID_HN_65_03', 'KM_HN_65', 'MH_CT_03', 1, 3),
('ID_HN_65_04', 'KM_HN_65', 'MH_CT_04', 1, 4),
('ID_HN_65_05', 'KM_HN_65', 'MH_CT_05', 1, 5),
('ID_HN_65_06', 'KM_HN_65', 'MH_CT_06', 1, 6),
('ID_HN_65_07', 'KM_HN_65', 'MH_CT_07', 1, 7),
('ID_HN_65_08', 'KM_HN_65', 'MH_CT_08', 1, 8),
('ID_HN_65_09', 'KM_HN_65', 'MH_CT_09', 1, 9),
('ID_HN_65_10', 'KM_HN_65', 'MH_CT_10', 1, 10),
('ID_HN_65_11', 'KM_HN_65', 'MH_CT_11', 1, 11),
('ID_HN_65_12', 'KM_HN_65', 'MH_CT_12', 1, 12),
('ID_HN_65_13', 'KM_HN_65', 'MH_CT_13', 1, 13),
('ID_HN_65_14', 'KM_HN_65', 'MH_CT_14', 1, 14),
('ID_HN_65_15', 'KM_HN_65', 'MH_CT_15', 1, 15),
('ID_HN_65_16', 'KM_HN_65', 'MH_CT_16', 1, 16),
('ID_HN_65_17', 'KM_HN_65', 'MH_CT_17', 1, 17),
('ID_HN_65_18', 'KM_HN_65', 'MH_CT_18', 1, 18),
('ID_HN_65_19', 'KM_HN_65', 'MH_CT_19', 1, 19);

PRINT N'Đã hoàn tất nạp ma trận ưu đãi cho Tiệc Công Ty / Hội Nghị!';
GO
