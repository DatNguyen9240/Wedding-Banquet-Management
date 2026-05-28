USE [QLTiec]
GO

-- =========================================================================================
-- TOOL: ĐĂNG KÝ FORM MỚI VÀO HỆ THỐNG NO-CODE
-- Chạy script này mỗi khi anh muốn tạo một màn hình Quản lý mới (ví dụ frmStaff)
-- =========================================================================================

DECLARE @NewFormID VARCHAR(50) = 'frmStaff'; 
DECLARE @TableName VARCHAR(100) = 'dmNhanvienView'; -- View để Đọc
DECLARE @SaveTableName VARCHAR(100) = 'dmnhanvien'; -- Bảng gốc để Ghi/Xóa
DECLARE @PrimaryKey VARCHAR(50) = 'NHANVIENID'; -- Khóa chính

-- 1. Đăng ký Form vào SY_FrmLstTbl (Nếu chưa có)
IF NOT EXISTS (SELECT 1 FROM SY_FrmLstTbl WHERE FormID = @NewFormID)
BEGIN
    INSERT INTO SY_FrmLstTbl (FormID, TableName, SaveTableName, PrimaryKey)
    VALUES (@NewFormID, @TableName, @SaveTableName, @PrimaryKey);
    PRINT N'Đã thêm cấu hình Form vào SY_FrmLstTbl';
END
ELSE
BEGIN
    UPDATE SY_FrmLstTbl 
    SET TableName = @TableName, SaveTableName = @SaveTableName, PrimaryKey = @PrimaryKey
    WHERE FormID = @NewFormID;
    PRINT N'Đã cập nhật cấu hình Form trong SY_FrmLstTbl';
END

-- 2. Đăng ký 3 đường dẫn (Route) chuẩn xác vào WA_API cho Form này
-- Xóa cũ nếu có để nạp lại cho sạch
DELETE FROM WA_API WHERE list = @NewFormID AND func IN ('View', 'Save', 'Delete');

-- Bơm 3 hàm cốt lõi vào
INSERT INTO WA_API (list, func, [SQL], Para)
VALUES 
(@NewFormID, 'View',   'API_TruyVanDong', '@FormName=''{List}'', @FilterJSON=''{JsonData}'', @UserName=''{User}'', @SortColumn=''{SortColumn}'', @SortDir=''{SortDir}'', @Page={Page}, @Limit={Limit}'),
(@NewFormID, 'Save',   'API_LuuDong',     '@FormName=''{List}'', @Data=''{JsonData}'''),
(@NewFormID, 'Delete', 'API_XoaDong',     '@FormName=''{List}'', @IDs=''{IDs}''');

PRINT N'Đã đăng ký 3 API (View, Save, Delete) thành công vào WA_API cho form: ' + @NewFormID;
GO
