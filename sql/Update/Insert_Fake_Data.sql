USE [QLTiec]
GO

PRINT N'=== BẮT ĐẦU CHÈN DỮ LIỆU GIẢ LẬP (FAKE DATA) DYNAMIC ===';
GO

-- 1. CHÈN DANH MỤC MẪU (NẾU CHƯA CÓ)
PRINT N'1. Kiểm tra và chèn dữ liệu danh mục cơ bản...';

-- Khách hàng
IF NOT EXISTS (SELECT 1 FROM dmkhachhang WHERE Makh = 'KH001')
    INSERT INTO dmkhachhang (Makh, Tenkh, Dienthoai) VALUES ('KH001', N'Nguyễn Văn Nam', '0912345678');
IF NOT EXISTS (SELECT 1 FROM dmkhachhang WHERE Makh = 'KH002')
    INSERT INTO dmkhachhang (Makh, Tenkh, Dienthoai) VALUES ('KH002', N'Trần Thị Mai', '0987654321');
IF NOT EXISTS (SELECT 1 FROM dmkhachhang WHERE Makh = 'KH003')
    INSERT INTO dmkhachhang (Makh, Tenkh, Dienthoai) VALUES ('KH003', N'Lê Hoàng Long', '0905123456');

-- Nhân viên (Sửa cột Manv -> Nhanvienid, Tennv -> Tennhanvien)
IF NOT EXISTS (SELECT 1 FROM dmnhanvien WHERE Nhanvienid = 'NV001')
    INSERT INTO dmnhanvien (Nhanvienid, Tennhanvien) VALUES ('NV001', N'Lê Thanh Sơn');

-- Sảnh tiệc
IF NOT EXISTS (SELECT 1 FROM dmSanhtiec WHERE Sanhtiecid = 'ST001')
    INSERT INTO dmSanhtiec (Sanhtiecid, Tensanhtiec) VALUES ('ST001', N'Sảnh Kim Cương (Diamond)');
IF NOT EXISTS (SELECT 1 FROM dmSanhtiec WHERE Sanhtiecid = 'ST002')
    INSERT INTO dmSanhtiec (Sanhtiecid, Tensanhtiec) VALUES ('ST002', N'Sảnh Hồng Ngọc (Ruby)');
IF NOT EXISTS (SELECT 1 FROM dmSanhtiec WHERE Sanhtiecid = 'ST003')
    INSERT INTO dmSanhtiec (Sanhtiecid, Tensanhtiec) VALUES ('ST003', N'Sảnh Lam Ngọc (Sapphire)');

-- Ca tiệc
IF NOT EXISTS (SELECT 1 FROM dmThoigian WHERE Thoigianid = 'CA01')
    INSERT INTO dmThoigian (Thoigianid, Thoigian) VALUES ('CA01', N'Ca Trưa (11:00 - 14:00)');
IF NOT EXISTS (SELECT 1 FROM dmThoigian WHERE Thoigianid = 'CA02')
    INSERT INTO dmThoigian (Thoigianid, Thoigian) VALUES ('CA02', N'Ca Tối (17:30 - 21:30)');

-- Loại hình tiệc (Đã được định nghĩa chuẩn bằng BLT000001 -> BLT000005)

-- Gói thực đơn
IF NOT EXISTS (SELECT 1 FROM dmGoiThucDon WHERE GoiThucDonID = 'TD01')
    INSERT INTO dmGoiThucDon (GoiThucDonID, TenGoiThucDon) VALUES ('TD01', N'Gói Thực Đơn Vàng (Gold)');

GO

-- 2. DỌN SẠCH DỮ LIỆU GIAO DỊCH CŨ (ĐỂ TRÁNH TRÙNG LẶP KHI CHẠY NHIỀU LẦN)
PRINT N'2. Dọn dẹp dữ liệu giao dịch cũ để chèn mới...';
DELETE FROM tbmk_Phieuthu WHERE Sohopdong LIKE 'HD_FAKE%';
DELETE FROM tbmk_Hopdongsanhtiec WHERE Sohopdong LIKE 'HD_FAKE%';
DELETE FROM tbmk_Hopdong WHERE Sohopdong LIKE 'HD_FAKE%';
DELETE FROM tbmk_Biennhancoccho WHERE DocumentID LIKE 'CC_FAKE%';
GO

-- 3. CHÈN HỢP ĐỒNG GIẢ LẬP ĐỘNG (DỰA TRÊN NGÀY HIỆN TẠI)
PRINT N'3. Chèn các hợp đồng tiệc giả lập...';

-- A. Các tiệc diễn ra HÔM NAY (Hôm nay là GETDATE())
-- Tiệc 1: Đã tổ chức xong (IsKetthuc = 1)
INSERT INTO tbmk_Hopdong (Sohopdong, Ngayhopdong, Makh, Thoigianid, Ngaytochuc, Loaitiecid, GoiThucDonID, Tongtienhopdong, Sotiencoccho, Sotiencochopdong, Tongsoban, Soluongkhach, IsHuy, IsKetthuc, UserCreate)
VALUES ('HD_FAKE_01', GETDATE(), 'KH001', 'CA01', GETDATE(), 'BLT000001', 'TD01', 120000000, 20000000, 20000000, 30, 300, 0, 1, 'admin');

-- Tiệc 2: Đang diễn ra (IsKetthuc = 0)
INSERT INTO tbmk_Hopdong (Sohopdong, Ngayhopdong, Makh, Thoigianid, Ngaytochuc, Loaitiecid, GoiThucDonID, Tongtienhopdong, Sotiencoccho, Sotiencochopdong, Tongsoban, Soluongkhach, IsHuy, IsKetthuc, GioDienRaSuKien, UserCreate)
VALUES ('HD_FAKE_02', GETDATE(), 'KH002', 'CA02', GETDATE(), 'BLT000001', 'TD01', 150000000, 30000000, 30000000, 40, 400, 0, 0, '18:00', 'admin');

-- Tiệc 3: Sắp diễn ra hôm nay (IsKetthuc = 0)
INSERT INTO tbmk_Hopdong (Sohopdong, Ngayhopdong, Makh, Thoigianid, Ngaytochuc, Loaitiecid, GoiThucDonID, Tongtienhopdong, Sotiencoccho, Sotiencochopdong, Tongsoban, Soluongkhach, IsHuy, IsKetthuc, GioDienRaSuKien, UserCreate)
VALUES ('HD_FAKE_03', GETDATE(), 'KH003', 'CA02', GETDATE(), 'BLT000005', 'TD01', 80000000, 15000000, 15000000, 20, 200, 0, 0, '19:30', 'admin');


-- B. Các tiệc diễn ra trong TUẦN NÀY (nhưng khác hôm nay)
-- Tiệc 4: Ngày mai
INSERT INTO tbmk_Hopdong (Sohopdong, Ngayhopdong, Makh, Thoigianid, Ngaytochuc, Loaitiecid, GoiThucDonID, Tongtienhopdong, Sotiencoccho, Sotiencochopdong, Tongsoban, Soluongkhach, IsHuy, IsKetthuc, UserCreate)
VALUES ('HD_FAKE_04', GETDATE(), 'KH001', 'CA01', DATEADD(day, 1, GETDATE()), 'BLT000001', 'TD01', 160000000, 30000000, 30000000, 35, 350, 0, 0, 'admin');

-- Tiệc 5: Ngày kia
INSERT INTO tbmk_Hopdong (Sohopdong, Ngayhopdong, Makh, Thoigianid, Ngaytochuc, Loaitiecid, GoiThucDonID, Tongtienhopdong, Sotiencoccho, Sotiencochopdong, Tongsoban, Soluongkhach, IsHuy, IsKetthuc, UserCreate)
VALUES ('HD_FAKE_05', GETDATE(), 'KH002', 'CA02', DATEADD(day, 2, GETDATE()), 'BLT000004', 'TD01', 45000000, 10000000, 10000000, 10, 100, 0, 0, 'admin');


-- C. Các tiệc diễn ra trong THÁNG NÀY (nhưng tuần sau)
-- Tiệc 6: Sau 7 ngày
INSERT INTO tbmk_Hopdong (Sohopdong, Ngayhopdong, Makh, Thoigianid, Ngaytochuc, Loaitiecid, GoiThucDonID, Tongtienhopdong, Sotiencoccho, Sotiencochopdong, Tongsoban, Soluongkhach, IsHuy, IsKetthuc, UserCreate)
VALUES ('HD_FAKE_06', GETDATE(), 'KH003', 'CA01', DATEADD(day, 7, GETDATE()), 'BLT000001', 'TD01', 110000000, 20000000, 20000000, 25, 250, 0, 0, 'admin');

-- Tiệc 7: Sau 12 ngày
INSERT INTO tbmk_Hopdong (Sohopdong, Ngayhopdong, Makh, Thoigianid, Ngaytochuc, Loaitiecid, GoiThucDonID, Tongtienhopdong, Sotiencoccho, Sotiencochopdong, Tongsoban, Soluongkhach, IsHuy, IsKetthuc, UserCreate)
VALUES ('HD_FAKE_07', GETDATE(), 'KH001', 'CA02', DATEADD(day, 12, GETDATE()), 'BLT000005', 'TD01', 95000000, 20000000, 20000000, 25, 250, 0, 0, 'admin');


-- D. Các tiệc diễn ra trong THÁNG TRƯỚC (để test so sánh tăng trưởng doanh thu)
-- Tiệc 8: Cách đây 30 ngày (đã hoàn thành)
INSERT INTO tbmk_Hopdong (Sohopdong, Ngayhopdong, Makh, Thoigianid, Ngaytochuc, Loaitiecid, GoiThucDonID, Tongtienhopdong, Sotiencoccho, Sotiencochopdong, Tongsoban, Soluongkhach, IsHuy, IsKetthuc, UserCreate)
VALUES ('HD_FAKE_08', DATEADD(day, -40, GETDATE()), 'KH002', 'CA01', DATEADD(day, -30, GETDATE()), 'BLT000001', 'TD01', 130000000, 20000000, 20000000, 30, 300, 0, 1, 'admin');

-- Tiệc 9: Cách đây 25 ngày (đã hoàn thành)
INSERT INTO tbmk_Hopdong (Sohopdong, Ngayhopdong, Makh, Thoigianid, Ngaytochuc, Loaitiecid, GoiThucDonID, Tongtienhopdong, Sotiencoccho, Sotiencochopdong, Tongsoban, Soluongkhach, IsHuy, IsKetthuc, UserCreate)
VALUES ('HD_FAKE_09', DATEADD(day, -35, GETDATE()), 'KH003', 'CA02', DATEADD(day, -25, GETDATE()), 'BLT000004', 'TD01', 50000000, 10000000, 10000000, 12, 120, 0, 1, 'admin');


-- E. Hợp đồng bị hủy hôm nay
INSERT INTO tbmk_Hopdong (Sohopdong, Ngayhopdong, Makh, Thoigianid, Ngaytochuc, Loaitiecid, GoiThucDonID, Tongtienhopdong, Sotiencoccho, Sotiencochopdong, Tongsoban, Soluongkhach, IsHuy, Lydohuy, Ngayhuy, IsKetthuc, UserCreate)
VALUES ('HD_FAKE_10', GETDATE(), 'KH001', 'CA01', DATEADD(day, 5, GETDATE()), 'BLT000001', 'TD01', 140000000, 20000000, 20000000, 30, 300, 1, N'Khách đổi địa điểm', GETDATE(), 0, 'admin');

GO

-- 4. XẾP SẢNH CHO CÁC TIỆC (Sửa sinh UserAutoid bằng NEWID())
PRINT N'4. Xếp sảnh cho các tiệc giả lập...';
INSERT INTO tbmk_Hopdongsanhtiec (UserAutoid, Sohopdong, Sanhtiecid) VALUES (CAST(NEWID() AS VARCHAR(40)), 'HD_FAKE_01', 'ST001');
INSERT INTO tbmk_Hopdongsanhtiec (UserAutoid, Sohopdong, Sanhtiecid) VALUES (CAST(NEWID() AS VARCHAR(40)), 'HD_FAKE_02', 'ST002');
INSERT INTO tbmk_Hopdongsanhtiec (UserAutoid, Sohopdong, Sanhtiecid) VALUES (CAST(NEWID() AS VARCHAR(40)), 'HD_FAKE_03', 'ST003');
INSERT INTO tbmk_Hopdongsanhtiec (UserAutoid, Sohopdong, Sanhtiecid) VALUES (CAST(NEWID() AS VARCHAR(40)), 'HD_FAKE_04', 'ST001');
INSERT INTO tbmk_Hopdongsanhtiec (UserAutoid, Sohopdong, Sanhtiecid) VALUES (CAST(NEWID() AS VARCHAR(40)), 'HD_FAKE_05', 'ST002');
INSERT INTO tbmk_Hopdongsanhtiec (UserAutoid, Sohopdong, Sanhtiecid) VALUES (CAST(NEWID() AS VARCHAR(40)), 'HD_FAKE_06', 'ST001');
INSERT INTO tbmk_Hopdongsanhtiec (UserAutoid, Sohopdong, Sanhtiecid) VALUES (CAST(NEWID() AS VARCHAR(40)), 'HD_FAKE_07', 'ST003');
INSERT INTO tbmk_Hopdongsanhtiec (UserAutoid, Sohopdong, Sanhtiecid) VALUES (CAST(NEWID() AS VARCHAR(40)), 'HD_FAKE_08', 'ST002');
INSERT INTO tbmk_Hopdongsanhtiec (UserAutoid, Sohopdong, Sanhtiecid) VALUES (CAST(NEWID() AS VARCHAR(40)), 'HD_FAKE_09', 'ST003');
GO

-- 5. CHÈN BIÊN NHẬN CỌC CHỜ HÔM NAY (ĐỂ CÓ TIỀN THU CỌC CHỜ)
PRINT N'5. Chèn biên nhận cọc chờ giả lập...';
INSERT INTO tbmk_Biennhancoccho (DocumentID, SoBN, DocumentDate, Makh, Ngaytochuc, Thoigianid, GoiThucDonID, Tongtien, IsHuy, UserCreate)
VALUES ('CC_FAKE_01', 'BN_FAKE_01', GETDATE(), 'KH001', DATEADD(day, 30, GETDATE()), 'CA01', 'TD01', 15000000, 0, 'admin');
INSERT INTO tbmk_Biennhancoccho (DocumentID, SoBN, DocumentDate, Makh, Ngaytochuc, Thoigianid, GoiThucDonID, Tongtien, IsHuy, UserCreate)
VALUES ('CC_FAKE_02', 'BN_FAKE_02', GETDATE(), 'KH002', DATEADD(day, 45, GETDATE()), 'CA02', 'TD01', 25000000, 0, 'admin');
GO

-- 6. CHÈN PHIẾU THU THANH TOÁN (ĐỂ CÓ TIỀN THỰC THU)
PRINT N'6. Chèn phiếu thu/quyết toán giả lập...';

-- Thu tiền tiệc 1 hôm nay (đã quyết toán hôm nay)
INSERT INTO tbmk_Phieuthu (DocumentID, DocumentDate, SPthu, Ngaythu, SoBienNhan, Sohopdong, Thanhtoan, IsDeleted, UserCreate)
VALUES ('QT_FAKE_01', GETDATE(), 'PT_FAKE_01', GETDATE(), 'BN_PT_01', 'HD_FAKE_01', 100000000, 0, 'admin');

-- Thu tiền tiệc 8 tháng trước
INSERT INTO tbmk_Phieuthu (DocumentID, DocumentDate, SPthu, Ngaythu, SoBienNhan, Sohopdong, Thanhtoan, IsDeleted, UserCreate)
VALUES ('QT_FAKE_08', DATEADD(day, -30, GETDATE()), 'PT_FAKE_08', DATEADD(day, -30, GETDATE()), 'BN_PT_08', 'HD_FAKE_08', 110000000, 0, 'admin');

-- Thu tiền tiệc 9 tháng trước
INSERT INTO tbmk_Phieuthu (DocumentID, DocumentDate, SPthu, Ngaythu, SoBienNhan, Sohopdong, Thanhtoan, IsDeleted, UserCreate)
VALUES ('QT_FAKE_09', DATEADD(day, -25, GETDATE()), 'PT_FAKE_09', DATEADD(day, -25, GETDATE()), 'BN_PT_09', 'HD_FAKE_09', 40000000, 0, 'admin');

GO

PRINT N'=== HOÀN THÀNH CHÈN DỮ LIỆU GIẢ LẬP THÀNH CÔNG! ===';
GO
