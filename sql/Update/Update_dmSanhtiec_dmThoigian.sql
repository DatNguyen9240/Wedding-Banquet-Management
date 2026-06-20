USE [QLTiec]
GO

-- =========================================================================
-- 1. ĐĂNG KÝ HỆ THỐNG MẪU BIỂU (SY_FrmLstTbl) CHO dmSanhtiec, dmThoigian, API_DanhSachCaLam
-- =========================================================================
PRINT N'1. Đang đăng ký các form vào SY_FrmLstTbl...';
GO

IF NOT EXISTS (SELECT 1 FROM SY_FrmLstTbl WHERE FormID = 'dmSanhtiec')
BEGIN
    INSERT INTO SY_FrmLstTbl (FormID, CaptionVN, TableName, SaveTableName, PrimaryKey)
    VALUES ('dmSanhtiec', N'Danh mục Sảnh Tiệc', 'dmSanhtiec', 'dmSanhtiec', 'Sanhtiecid');
END
ELSE
BEGIN
    UPDATE SY_FrmLstTbl 
    SET TableName = 'dmSanhtiec', SaveTableName = 'dmSanhtiec', PrimaryKey = 'Sanhtiecid'
    WHERE FormID = 'dmSanhtiec';
END

IF NOT EXISTS (SELECT 1 FROM SY_FrmLstTbl WHERE FormID = 'dmThoigian')
BEGIN
    INSERT INTO SY_FrmLstTbl (FormID, CaptionVN, TableName, SaveTableName, PrimaryKey)
    VALUES ('dmThoigian', N'Danh mục Ca Làm / Khung Giờ', 'dmThoigian', 'dmThoigian', 'Thoigianid');
END
ELSE
BEGIN
    UPDATE SY_FrmLstTbl 
    SET TableName = 'dmThoigian', SaveTableName = 'dmThoigian', PrimaryKey = 'Thoigianid'
    WHERE FormID = 'dmThoigian';
END

IF NOT EXISTS (SELECT 1 FROM SY_FrmLstTbl WHERE FormID = 'API_DanhSachCaLam')
BEGIN
    INSERT INTO SY_FrmLstTbl (FormID, CaptionVN, TableName, SaveTableName, PrimaryKey)
    VALUES ('API_DanhSachCaLam', N'Danh mục Ca Làm / Khung Giờ', 'dmThoigian', 'dmThoigian', 'Thoigianid');
END
ELSE
BEGIN
    UPDATE SY_FrmLstTbl 
    SET TableName = 'dmThoigian', SaveTableName = 'dmThoigian', PrimaryKey = 'Thoigianid'
    WHERE FormID = 'API_DanhSachCaLam';
END
GO

-- =========================================================================
-- 2. ĐĂNG KÝ ĐỊNH TUYẾN WA_API (Save & View)
-- =========================================================================
PRINT N'2. Đang đăng ký API cho dmSanhtiec, dmThoigian, API_DanhSachCaLam...';
GO

-- dmSanhtiec
DELETE FROM WA_API WHERE List = 'dmSanhtiec' AND Func IN ('Save', 'View');
INSERT INTO WA_API (List, Func, [SQL], Para)
VALUES 
('dmSanhtiec', 'Save', 'API_LuuDong', '@List=N''dmSanhtiec'', @Data=N''{JsonData}'''),
('dmSanhtiec', 'View', 'API_TruyVanDong', '@List=N''dmSanhtiec'', @Keyword=N''{Keyword}''');

-- dmThoigian
DELETE FROM WA_API WHERE List = 'dmThoigian' AND Func IN ('Save', 'View');
INSERT INTO WA_API (List, Func, [SQL], Para)
VALUES 
('dmThoigian', 'Save', 'API_LuuDong', '@List=N''dmThoigian'', @Data=N''{JsonData}'''),
('dmThoigian', 'View', 'API_TruyVanDong', '@List=N''dmThoigian'', @Keyword=N''{Keyword}''');

-- API_DanhSachCaLam
DELETE FROM WA_API WHERE List = 'API_DanhSachCaLam' AND Func = 'Save';
INSERT INTO WA_API (List, Func, [SQL], Para)
VALUES 
('API_DanhSachCaLam', 'Save', 'API_LuuDong', '@List=N''API_DanhSachCaLam'', @Data=N''{JsonData}''');

-- SY_FrmLstTbl (Đăng ký để FE có thể xem tiêu đề các form)
IF NOT EXISTS (SELECT 1 FROM SY_FrmLstTbl WHERE FormID = 'SY_FrmLstTbl')
BEGIN
    INSERT INTO SY_FrmLstTbl (FormID, CaptionVN, TableName, SaveTableName, PrimaryKey)
    VALUES ('SY_FrmLstTbl', N'Danh sách Form Hệ thống', 'SY_FrmLstTbl', 'SY_FrmLstTbl', 'FormID');
END

DELETE FROM WA_API WHERE List = 'SY_FrmLstTbl' AND Func = 'View';
INSERT INTO WA_API (List, Func, [SQL], Para)
VALUES ('SY_FrmLstTbl', 'View', 'API_TruyVanDong', '@List=N''SY_FrmLstTbl'', @Keyword=N''{Keyword}''');
GO

-- =========================================================================
-- 3. ĐỒNG BỘ CỘT TỰ ĐỘNG (API_DongBoTruongGiaoDien)
-- =========================================================================
PRINT N'3. Đang đồng bộ các cột từ bảng vật lý...';
GO

EXEC API_DongBoTruongGiaoDien @FormName = 'dmSanhtiec', @ObjectName = 'dmSanhtiec';
EXEC API_DongBoTruongGiaoDien @FormName = 'dmThoigian', @ObjectName = 'dmThoigian';
EXEC API_DongBoTruongGiaoDien @FormName = 'API_DanhSachCaLam', @ObjectName = 'dmThoigian';
GO

-- =========================================================================
-- 4. CẤU HÌNH NHÃN TIẾNG VIỆT VÀ ĐỊNH DẠNG (SY_FormatFields)
-- =========================================================================
PRINT N'4. Đang cấu hình chi tiết hiển thị cho dmSanhtiec...';
GO

UPDATE SY_FormatFields SET CaptionVN = N'Mã Sảnh', FormatID = 't', FormPosition = 'hidden', OrderNo = 1, ShowInAdd = 0, ShowInEdit = 0, IsReadOnlyAdd = 0, IsReadOnlyEdit = 1, IsRequired = 0 WHERE FormName = 'dmSanhtiec' AND FieldName = 'Sanhtiecid';
UPDATE SY_FormatFields SET CaptionVN = N'Tên Sảnh', FormatID = 't', FormPosition = '6', OrderNo = 2, ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0, IsRequired = 1 WHERE FormName = 'dmSanhtiec' AND FieldName = 'Tensanhtiec';
UPDATE SY_FormatFields SET CaptionVN = N'Sức Chứa (Người)', FormatID = 'n', FormPosition = '6', OrderNo = 3, ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0 WHERE FormName = 'dmSanhtiec' AND FieldName = 'Succhua';
UPDATE SY_FormatFields SET CaptionVN = N'Đơn Giá Sảnh', FormatID = 'mn', FormPosition = '6', OrderNo = 4, ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0 WHERE FormName = 'dmSanhtiec' AND FieldName = 'Dongia';
UPDATE SY_FormatFields SET CaptionVN = N'Số Bàn Tối Thiểu', FormatID = 'n', FormPosition = '6', OrderNo = 5, ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0 WHERE FormName = 'dmSanhtiec' AND FieldName = 'SLBanMin';
UPDATE SY_FormatFields SET CaptionVN = N'Số Bàn Tối Đa', FormatID = 'n', FormPosition = '6', OrderNo = 6, ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0 WHERE FormName = 'dmSanhtiec' AND FieldName = 'SLBanMax';
UPDATE SY_FormatFields SET CaptionVN = N'Tạm Ngưng', FormatID = 'sw', FormPosition = '6', OrderNo = 7, ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0 WHERE FormName = 'dmSanhtiec' AND FieldName = 'IsTamngung';
UPDATE SY_FormatFields SET CaptionVN = N'Là Sảnh Hoạt Động', FormatID = 'sw', FormPosition = 'hidden', OrderNo = 8, ShowInAdd = 0, ShowInEdit = 0, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0 WHERE FormName = 'dmSanhtiec' AND FieldName = 'isSanh';
UPDATE SY_FormatFields SET CaptionVN = N'Ghi Chú', FormatID = 'ta', FormPosition = '12', OrderNo = 9, ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0 WHERE FormName = 'dmSanhtiec' AND FieldName = 'GhiChuSanh';

-- Ẩn tất cả các cột hệ thống/kỹ thuật khác ngoài 8 trường chính để giao diện gọn gàng
UPDATE SY_FormatFields SET ShowInAdd = 0, ShowInEdit = 0, FormPosition = 'hidden' 
WHERE FormName = 'dmSanhtiec' 
  AND FieldName NOT IN ('Sanhtiecid', 'Tensanhtiec', 'Succhua', 'Dongia', 'SLBanMin', 'SLBanMax', 'IsTamngung', 'GhiChuSanh');
GO

PRINT N'5. Đang cấu hình chi tiết hiển thị cho dmThoigian và API_DanhSachCaLam...';
GO

-- Cấu hình dmThoigian
UPDATE SY_FormatFields SET CaptionVN = N'Mã Ca', FormatID = 't', FormPosition = 'hidden', OrderNo = 1, ShowInAdd = 0, ShowInEdit = 0, IsReadOnlyAdd = 0, IsReadOnlyEdit = 1, IsRequired = 0 WHERE FormName = 'dmThoigian' AND FieldName = 'Thoigianid';
UPDATE SY_FormatFields SET CaptionVN = N'Ca Tiệc / Giờ Tổ Chức', FormatID = 't', FormPosition = '6', OrderNo = 2, ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0, IsRequired = 1 WHERE FormName = 'dmThoigian' AND FieldName = 'Thoigian';
UPDATE SY_FormatFields SET CaptionVN = N'Giờ Bắt Đầu', FormatID = 'n', FormPosition = '6', OrderNo = 3, ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0 WHERE FormName = 'dmThoigian' AND FieldName = 'GhiBatDau';
UPDATE SY_FormatFields SET CaptionVN = N'Giờ Kết Thúc', FormatID = 'n', FormPosition = '6', OrderNo = 4, ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0 WHERE FormName = 'dmThoigian' AND FieldName = 'GioKetThuc';
UPDATE SY_FormatFields SET CaptionVN = N'Phục vụ Tiệc Cưới', FormatID = 'sw', FormPosition = '6', OrderNo = 5, ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0 WHERE FormName = 'dmThoigian' AND FieldName = 'IsTiecCuoi';
UPDATE SY_FormatFields SET CaptionVN = N'Phục vụ Hội Nghị', FormatID = 'sw', FormPosition = '6', OrderNo = 6, ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0 WHERE FormName = 'dmThoigian' AND FieldName = 'IsHoiNghi';

UPDATE SY_FormatFields SET ShowInAdd = 0, ShowInEdit = 0, FormPosition = 'hidden' 
WHERE FormName = 'dmThoigian' 
  AND FieldName IN ('UserCreate', 'UserUpdate', 'DateCreate', 'DateUpdate', 'Nhahangid', 'Tenngan', 'IsFullNgay', 'AMPM', 'NhomBCLichTiec');

-- Cấu hình API_DanhSachCaLam (sao chép giống hệt)
UPDATE SY_FormatFields SET CaptionVN = N'Mã Ca', FormatID = 't', FormPosition = 'hidden', OrderNo = 1, ShowInAdd = 0, ShowInEdit = 0, IsReadOnlyAdd = 0, IsReadOnlyEdit = 1, IsRequired = 0 WHERE FormName = 'API_DanhSachCaLam' AND FieldName = 'Thoigianid';
UPDATE SY_FormatFields SET CaptionVN = N'Ca Tiệc / Giờ Tổ Chức', FormatID = 't', FormPosition = '6', OrderNo = 2, ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0, IsRequired = 1 WHERE FormName = 'API_DanhSachCaLam' AND FieldName = 'Thoigian';
UPDATE SY_FormatFields SET CaptionVN = N'Giờ Bắt Đầu', FormatID = 'n', FormPosition = '6', OrderNo = 3, ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0 WHERE FormName = 'API_DanhSachCaLam' AND FieldName = 'GhiBatDau';
UPDATE SY_FormatFields SET CaptionVN = N'Giờ Kết Thúc', FormatID = 'n', FormPosition = '6', OrderNo = 4, ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0 WHERE FormName = 'API_DanhSachCaLam' AND FieldName = 'GioKetThuc';
UPDATE SY_FormatFields SET CaptionVN = N'Phục vụ Tiệc Cưới', FormatID = 'sw', FormPosition = '6', OrderNo = 5, ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0 WHERE FormName = 'API_DanhSachCaLam' AND FieldName = 'IsTiecCuoi';
UPDATE SY_FormatFields SET CaptionVN = N'Phục vụ Hội Nghị', FormatID = 'sw', FormPosition = '6', OrderNo = 6, ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0 WHERE FormName = 'API_DanhSachCaLam' AND FieldName = 'IsHoiNghi';

UPDATE SY_FormatFields SET ShowInAdd = 0, ShowInEdit = 0, FormPosition = 'hidden' 
WHERE FormName = 'API_DanhSachCaLam' 
  AND FieldName IN ('UserCreate', 'UserUpdate', 'DateCreate', 'DateUpdate', 'Nhahangid', 'Tenngan', 'IsFullNgay', 'AMPM', 'NhomBCLichTiec');
GO

PRINT N'=== HOÀN THÀNH CẤU HÌNH CHO SANH TIEC & CA LAM ===';
GO
