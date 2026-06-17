USE [QLTiec]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =========================================================================
-- 1. STORED PROCEDURE XEM DANH SÁCH TÀI KHOẢN (VIEW API)
-- =========================================================================
CREATE OR ALTER PROCEDURE [dbo].[API_DanhSachTaiKhoan]
    @Keyword NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        UserName,
        HoTen,
        TenNgan,
        Password,
        UserGroupID,
        Disable,
        EmployeeID,
        Manager,
        IsBaocongno,
        IsBackupDatabase,
        IsFormBaocao,
        IsPhieuchi,
        IsBaococcho,
        IsBaotiec,
        IsBaoTrungSanh,
        IsBaoHopDong,
        IsBaoLichTiec,
        IsDuyetDeXuat,
        StartupForm,
        DisableAutoBackup
    FROM SY_User
    WHERE (@Keyword IS NULL OR @Keyword = '' 
           OR UserName LIKE '%' + @Keyword + '%'
           OR HoTen LIKE N'%' + @Keyword + '%'
           OR TenNgan LIKE N'%' + @Keyword + '%')
    ORDER BY UserName ASC;
END
GO

-- =========================================================================
-- 2. STORED PROCEDURE LƯU TÀI KHOẢN (SAVE API)
-- =========================================================================
CREATE OR ALTER PROCEDURE [dbo].[API_LuuTaiKhoan]
    @UserName NVARCHAR(50),
    @HoTen NVARCHAR(100) = NULL,
    @TenNgan NVARCHAR(100) = NULL,
    @Password NVARCHAR(255) = NULL,
    @UserGroupID VARCHAR(50) = NULL,
    @Disable BIT = 0,
    @EmployeeID VARCHAR(50) = NULL,
    @Manager BIT = 0,
    @IsBaocongno BIT = 0,
    @IsBackupDatabase BIT = 0,
    @IsFormBaocao BIT = 0,
    @IsPhieuchi BIT = 0,
    @IsBaococcho BIT = 0,
    @IsBaotiec BIT = 0,
    @IsBaoTrungSanh BIT = 0,
    @IsBaoHopDong BIT = 0,
    @IsBaoLichTiec BIT = 0,
    @IsDuyetDeXuat BIT = 0,
    @StartupForm VARCHAR(100) = NULL,
    @DisableAutoBackup BIT = 0,
    
    -- Các tham số hệ thống bổ sung
    @FormName VARCHAR(50) = NULL,
    @User VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    IF EXISTS (SELECT 1 FROM SY_User WHERE UserName = @UserName)
    BEGIN
        -- Cập nhật tài khoản hiện có
        UPDATE SY_User
        SET HoTen = ISNULL(@HoTen, HoTen),
            TenNgan = ISNULL(@TenNgan, TenNgan),
            Password = ISNULL(@Password, Password),
            UserGroupID = ISNULL(@UserGroupID, UserGroupID),
            Disable = ISNULL(@Disable, Disable),
            EmployeeID = ISNULL(@EmployeeID, EmployeeID),
            Manager = ISNULL(@Manager, Manager),
            IsBaocongno = ISNULL(@IsBaocongno, IsBaocongno),
            IsBackupDatabase = ISNULL(@IsBackupDatabase, IsBackupDatabase),
            IsFormBaocao = ISNULL(@IsFormBaocao, IsFormBaocao),
            IsPhieuchi = ISNULL(@IsPhieuchi, IsPhieuchi),
            IsBaococcho = ISNULL(@IsBaococcho, IsBaococcho),
            IsBaotiec = ISNULL(@IsBaotiec, IsBaotiec),
            IsBaoTrungSanh = ISNULL(@IsBaoTrungSanh, IsBaoTrungSanh),
            IsBaoHopDong = ISNULL(@IsBaoHopDong, IsBaoHopDong),
            IsBaoLichTiec = ISNULL(@IsBaoLichTiec, IsBaoLichTiec),
            IsDuyetDeXuat = ISNULL(@IsDuyetDeXuat, IsDuyetDeXuat),
            StartupForm = ISNULL(@StartupForm, StartupForm),
            DisableAutoBackup = ISNULL(@DisableAutoBackup, DisableAutoBackup)
        WHERE UserName = @UserName;
    END
    ELSE
    BEGIN
        -- Thêm mới tài khoản
        INSERT INTO SY_User (
            UserName, HoTen, TenNgan, Password, UserGroupID, Disable, EmployeeID, Manager,
            IsBaocongno, IsBackupDatabase, IsFormBaocao, IsPhieuchi, IsBaococcho, IsBaotiec,
            IsBaoTrungSanh, IsBaoHopDong, IsBaoLichTiec, IsDuyetDeXuat, StartupForm, DisableAutoBackup
        )
        VALUES (
            @UserName, @HoTen, @TenNgan, ISNULL(@Password, '123456'), @UserGroupID, ISNULL(@Disable, 0), @EmployeeID, ISNULL(@Manager, 0),
            ISNULL(@IsBaocongno, 0), ISNULL(@IsBackupDatabase, 0), ISNULL(@IsFormBaocao, 0), ISNULL(@IsPhieuchi, 0), ISNULL(@IsBaococcho, 0), ISNULL(@IsBaotiec, 0),
            ISNULL(@IsBaoTrungSanh, 0), ISNULL(@IsBaoHopDong, 0), ISNULL(@IsBaoLichTiec, 0), ISNULL(@IsDuyetDeXuat, 0), @StartupForm, ISNULL(@DisableAutoBackup, 0)
        );
    END
    
    -- Trả về dòng dữ liệu vừa lưu
    SELECT 
        UserName, HoTen, TenNgan, Password, UserGroupID, Disable, EmployeeID, Manager,
        IsBaocongno, IsBackupDatabase, IsFormBaocao, IsPhieuchi, IsBaococcho, IsBaotiec,
        IsBaoTrungSanh, IsBaoHopDong, IsBaoLichTiec, IsDuyetDeXuat, StartupForm, DisableAutoBackup
    FROM SY_User
    WHERE UserName = @UserName;
END
GO

-- =========================================================================
-- 3. ĐĂNG KÝ MODULE VÀO HỆ THỐNG METADATA (SY_FrmLstTbl & WA_API)
-- =========================================================================
PRINT N'Đang đăng ký form frmTaiKhoan...';

IF NOT EXISTS (SELECT 1 FROM SY_FrmLstTbl WHERE FormID = 'frmTaiKhoan')
BEGIN
    INSERT INTO SY_FrmLstTbl (FormID, CaptionVN, TableName, PrimaryKey)
    VALUES ('frmTaiKhoan', N'Danh sách Tài khoản', 'SY_User', 'UserName');
END
ELSE
BEGIN
    UPDATE SY_FrmLstTbl 
    SET TableName = 'SY_User', PrimaryKey = 'UserName', CaptionVN = N'Danh sách Tài khoản'
    WHERE FormID = 'frmTaiKhoan';
END
GO

-- Cấu hình định tuyến API Gateway Router
DELETE FROM WA_API WHERE List = 'frmTaiKhoan';
INSERT INTO WA_API (List, Func, [SQL], Para)
VALUES 
('frmTaiKhoan', 'View', 'API_DanhSachTaiKhoan', '@Keyword=N''{Keyword}'''),
('frmTaiKhoan', 'Save', 'API_LuuTaiKhoan', '@UserName=N''{UserName}'', @HoTen=N''{HoTen}'', @TenNgan=N''{TenNgan}'', @Password=N''{Password}'', @UserGroupID=N''{UserGroupID}'', @Disable=N''{Disable}'', @EmployeeID=N''{EmployeeID}'', @Manager=N''{Manager}'', @IsBaocongno=N''{IsBaocongno}'', @IsBackupDatabase=N''{IsBackupDatabase}'', @IsFormBaocao=N''{IsFormBaocao}'', @IsPhieuchi=N''{IsPhieuchi}'', @IsBaococcho=N''{IsBaococcho}'', @IsBaotiec=N''{IsBaotiec}'', @IsBaoTrungSanh=N''{IsBaoTrungSanh}'', @IsBaoHopDong=N''{IsBaoHopDong}'', @IsBaoLichTiec=N''{IsBaoLichTiec}'', @IsDuyetDeXuat=N''{IsDuyetDeXuat}'', @StartupForm=N''{StartupForm}'', @DisableAutoBackup=N''{DisableAutoBackup}''');
GO

-- =========================================================================
-- 4. ĐỒNG BỘ VÀ CẤU HÌNH GIAO DIỆN FORM (SY_FormatFields)
-- =========================================================================
PRINT N'Đang đồng bộ giao diện cho frmTaiKhoan...';

DELETE FROM SY_FormatFields WHERE FormName = 'frmTaiKhoan';
GO

EXEC API_DongBoTruongGiaoDien @FormName = 'frmTaiKhoan', @ObjectName = 'SY_User';
GO

-- 4.1. Ẩn tất cả các trường không cần thiết/ngoài danh mục quản lý
UPDATE SY_FormatFields
SET ShowInAdd = 0, ShowInEdit = 0, ShowInFilter = 0, FormPosition = 'hidden'
WHERE FormName = 'frmTaiKhoan';
GO

-- 4.2. Cấu hình các trường hiển thị trên Grid danh sách & Form nhập liệu (Vị trí = con số)
UPDATE SY_FormatFields
SET CaptionVN = N'Tên đăng nhập', FormatID = 't', FormPosition = '6', OrderNo = 1, IsRequired = 1, ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyEdit = 1, ShowInFilter = 1
WHERE FormName = 'frmTaiKhoan' AND FieldName = 'UserName';

UPDATE SY_FormatFields
SET CaptionVN = N'Họ và tên', FormatID = 't', FormPosition = '6', OrderNo = 2, IsRequired = 1, ShowInAdd = 1, ShowInEdit = 1, ShowInFilter = 1
WHERE FormName = 'frmTaiKhoan' AND FieldName = 'HoTen';

UPDATE SY_FormatFields
SET CaptionVN = N'Nhóm quyền', FormatID = 'sl', DataSource = '/api/API_Gateway_Router?List=API_LayDanhSachNhom&Func=View', FormPosition = '6', OrderNo = 3, ShowInAdd = 1, ShowInEdit = 1, ShowInFilter = 1
WHERE FormName = 'frmTaiKhoan' AND FieldName = 'UserGroupID';

UPDATE SY_FormatFields
SET CaptionVN = N'Khóa tài khoản', FormatID = 'sw', FormPosition = '6', OrderNo = 4, ShowInAdd = 1, ShowInEdit = 1, ShowInFilter = 1
WHERE FormName = 'frmTaiKhoan' AND FieldName = 'Disable';

-- 4.3. Cấu hình các trường chỉ xuất hiện trong Modal Form nhập liệu (Vị trí = 'hidden')
UPDATE SY_FormatFields
SET CaptionVN = N'Tên hiển thị (Tên ngắn)', FormatID = 't', FormPosition = 'hidden', OrderNo = 5, ShowInAdd = 1, ShowInEdit = 1
WHERE FormName = 'frmTaiKhoan' AND FieldName = 'TenNgan';

UPDATE SY_FormatFields
SET CaptionVN = N'Mật khẩu', FormatID = 't', FormPosition = 'hidden', OrderNo = 6, ShowInAdd = 1, ShowInEdit = 1
WHERE FormName = 'frmTaiKhoan' AND FieldName = 'Password';

UPDATE SY_FormatFields
SET CaptionVN = N'Nhân viên liên kết', FormatID = 'sl', DataSource = '/api/API_Gateway_Router?List=API_ComboNhanVien&Func=View', FormPosition = 'hidden', OrderNo = 7, ShowInAdd = 1, ShowInEdit = 1
WHERE FormName = 'frmTaiKhoan' AND FieldName = 'EmployeeID';

UPDATE SY_FormatFields
SET CaptionVN = N'Tài khoản Quản lý', FormatID = 'sw', FormPosition = 'hidden', OrderNo = 8, ShowInAdd = 1, ShowInEdit = 1
WHERE FormName = 'frmTaiKhoan' AND FieldName = 'Manager';

UPDATE SY_FormatFields
SET CaptionVN = N'Trang bắt đầu', FormatID = 't', FormPosition = 'hidden', OrderNo = 9, ShowInAdd = 1, ShowInEdit = 1
WHERE FormName = 'frmTaiKhoan' AND FieldName = 'StartupForm';

-- 4.4. Cấu hình các Switch quyền hạn bổ sung (Chỉ hiện trong Modal)
UPDATE SY_FormatFields
SET CaptionVN = N'Quyền xem Báo cáo Công nợ', FormatID = 'sw', FormPosition = 'hidden', OrderNo = 10, ShowInAdd = 1, ShowInEdit = 1
WHERE FormName = 'frmTaiKhoan' AND FieldName = 'IsBaocongno';

UPDATE SY_FormatFields
SET CaptionVN = N'Quyền Sao lưu Dữ liệu', FormatID = 'sw', FormPosition = 'hidden', OrderNo = 11, ShowInAdd = 1, ShowInEdit = 1
WHERE FormName = 'frmTaiKhoan' AND FieldName = 'IsBackupDatabase';

UPDATE SY_FormatFields
SET CaptionVN = N'Quyền xem Báo cáo Doanh thu', FormatID = 'sw', FormPosition = 'hidden', OrderNo = 12, ShowInAdd = 1, ShowInEdit = 1
WHERE FormName = 'frmTaiKhoan' AND FieldName = 'IsFormBaocao';

UPDATE SY_FormatFields
SET CaptionVN = N'Quyền lập Phiếu chi', FormatID = 'sw', FormPosition = 'hidden', OrderNo = 13, ShowInAdd = 1, ShowInEdit = 1
WHERE FormName = 'frmTaiKhoan' AND FieldName = 'IsPhieuchi';

UPDATE SY_FormatFields
SET CaptionVN = N'Quyền xem Báo cáo Cọc chỗ', FormatID = 'sw', FormPosition = 'hidden', OrderNo = 14, ShowInAdd = 1, ShowInEdit = 1
WHERE FormName = 'frmTaiKhoan' AND FieldName = 'IsBaococcho';

UPDATE SY_FormatFields
SET CaptionVN = N'Quyền xem Báo cáo Tiệc', FormatID = 'sw', FormPosition = 'hidden', OrderNo = 15, ShowInAdd = 1, ShowInEdit = 1
WHERE FormName = 'frmTaiKhoan' AND FieldName = 'IsBaotiec';

UPDATE SY_FormatFields
SET CaptionVN = N'Cảnh báo trùng sảnh', FormatID = 'sw', FormPosition = 'hidden', OrderNo = 16, ShowInAdd = 1, ShowInEdit = 1
WHERE FormName = 'frmTaiKhoan' AND FieldName = 'IsBaoTrungSanh';

UPDATE SY_FormatFields
SET CaptionVN = N'Quyền xem Báo cáo Hợp đồng', FormatID = 'sw', FormPosition = 'hidden', OrderNo = 17, ShowInAdd = 1, ShowInEdit = 1
WHERE FormName = 'frmTaiKhoan' AND FieldName = 'IsBaoHopDong';

UPDATE SY_FormatFields
SET CaptionVN = N'Quyền xem Lịch tiệc', FormatID = 'sw', FormPosition = 'hidden', OrderNo = 18, ShowInAdd = 1, ShowInEdit = 1
WHERE FormName = 'frmTaiKhoan' AND FieldName = 'IsBaoLichTiec';

UPDATE SY_FormatFields
SET CaptionVN = N'Quyền Duyệt Đề Xuất', FormatID = 'sw', FormPosition = 'hidden', OrderNo = 19, ShowInAdd = 1, ShowInEdit = 1
WHERE FormName = 'frmTaiKhoan' AND FieldName = 'IsDuyetDeXuat';

UPDATE SY_FormatFields
SET CaptionVN = N'Tắt tự động sao lưu', FormatID = 'sw', FormPosition = 'hidden', OrderNo = 20, ShowInAdd = 1, ShowInEdit = 1
WHERE FormName = 'frmTaiKhoan' AND FieldName = 'DisableAutoBackup';
GO

PRINT N'Hoàn thành thiết lập All-In-One cho frmTaiKhoan!';
GO

