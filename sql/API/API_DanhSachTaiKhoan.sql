USE [QLTiec]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =========================================================================
-- 1. STORED PROCEDURE XEM DANH SÁCH TÀI KHOẢN (VIEW API)
-- =========================================================================
IF OBJECT_ID('dbo.API_DanhSachTaiKhoan', 'P') IS NOT NULL
    DROP PROCEDURE dbo.API_DanhSachTaiKhoan;
GO
CREATE PROCEDURE [dbo].[API_DanhSachTaiKhoan]
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
IF OBJECT_ID('dbo.API_LuuTaiKhoan', 'P') IS NOT NULL
    DROP PROCEDURE dbo.API_LuuTaiKhoan;
GO
CREATE PROCEDURE [dbo].[API_LuuTaiKhoan]
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
-- 3. ĐĂNG KÝ MODULE VÀO HỆ THỐNG METADATA (WA_API)
-- =========================================================================
PRINT N'Đang đăng ký form frmTaiKhoan...';
GO

-- Cấu hình định tuyến API Gateway Router
DELETE FROM WA_API WHERE List = 'frmTaiKhoan';
INSERT INTO WA_API (List, Func, [SQL], Para)
VALUES 
('frmTaiKhoan', 'View', 'API_DanhSachTaiKhoan', '@Keyword=N''{Keyword}'''),
('frmTaiKhoan', 'Save', 'API_LuuTaiKhoan', '@UserName=N''{UserName}'', @HoTen=N''{HoTen}'', @TenNgan=N''{TenNgan}'', @Password=N''{Password}'', @UserGroupID=N''{UserGroupID}'', @Disable=N''{Disable}'', @EmployeeID=N''{EmployeeID}'', @Manager=N''{Manager}'', @IsBaocongno=N''{IsBaocongno}'', @IsBackupDatabase=N''{IsBackupDatabase}'', @IsFormBaocao=N''{IsFormBaocao}'', @IsPhieuchi=N''{IsPhieuchi}'', @IsBaococcho=N''{IsBaococcho}'', @IsBaotiec=N''{IsBaotiec}'', @IsBaoTrungSanh=N''{IsBaoTrungSanh}'', @IsBaoHopDong=N''{IsBaoHopDong}'', @IsBaoLichTiec=N''{IsBaoLichTiec}'', @IsDuyetDeXuat=N''{IsDuyetDeXuat}'', @StartupForm=N''{StartupForm}'', @DisableAutoBackup=N''{DisableAutoBackup}''');
GO

-- =========================================================================
-- 4. CẤU HÌNH GIAO DIỆN FORM (SY_FmtFldTbl & SY_FrmDrdwTbl)
-- =========================================================================
PRINT N'Đang đồng bộ giao diện cho frmTaiKhoan...';

DELETE FROM dbo.SY_FmtFldTbl WHERE FormName = 'frmTaiKhoan';
DELETE FROM dbo.SY_FrmDrdwTbl WHERE FormID = 'frmTaiKhoan';
GO

-- 4.1. Nhãn tiếng Việt và định dạng cột (FormatID) trong SY_FmtFldTbl
INSERT INTO dbo.SY_FmtFldTbl (FormName, FieldName, CaptionVN, FormatID)
VALUES 
('frmTaiKhoan', 'UserName', N'Tên đăng nhập', 't'),
('frmTaiKhoan', 'HoTen', N'Họ và tên', 't'),
('frmTaiKhoan', 'UserGroupID', N'Nhóm quyền', 'sl'),
('frmTaiKhoan', 'Disable', N'Khóa tài khoản', 'sw'),
('frmTaiKhoan', 'TenNgan', N'Tên hiển thị (Tên ngắn)', 't'),
('frmTaiKhoan', 'Password', N'Mật khẩu', 't'),
('frmTaiKhoan', 'EmployeeID', N'Nhân viên liên kết', 'sl'),
('frmTaiKhoan', 'Manager', N'Tài khoản Quản lý', 'sw'),
('frmTaiKhoan', 'StartupForm', N'Trang bắt đầu', 't'),
('frmTaiKhoan', 'IsBaocongno', N'Quyền xem Báo cáo Công nợ', 'sw'),
('frmTaiKhoan', 'IsBackupDatabase', N'Quyền Sao lưu Dữ liệu', 'sw'),
('frmTaiKhoan', 'IsFormBaocao', N'Quyền xem Báo cáo Doanh thu', 'sw'),
('frmTaiKhoan', 'IsPhieuchi', N'Quyền lập Phiếu chi', 'sw'),
('frmTaiKhoan', 'IsBaococcho', N'Quyền xem Báo cáo Cọc chỗ', 'sw'),
('frmTaiKhoan', 'IsBaotiec', N'Quyền xem Báo cáo Tiệc', 'sw'),
('frmTaiKhoan', 'IsBaoTrungSanh', N'Cảnh báo trùng sảnh', 'sw'),
('frmTaiKhoan', 'IsBaoHopDong', N'Quyền xem Báo cáo Hợp đồng', 'sw'),
('frmTaiKhoan', 'IsBaoLichTiec', N'Quyền xem Lịch tiệc', 'sw'),
('frmTaiKhoan', 'IsDuyetDeXuat', N'Quyền Duyệt Đề Xuất', 'sw'),
('frmTaiKhoan', 'DisableAutoBackup', N'Tắt tự động sao lưu', 'sw');
GO

-- 4.2. Cấu hình Dropdown trong SY_FrmDrdwTbl
INSERT INTO dbo.SY_FrmDrdwTbl (UserAutoID, FormID, ColumnID, Source, Type, ValueColumn, DisplayColumn)
VALUES
(LOWER(REPLACE(CAST(NEWID() AS VARCHAR(50)), '-', '')), 'frmTaiKhoan', 'UserGroupID', 'SELECT UserGroupID, UserGroupName FROM SY_UserGroup WHERE IsDisable = 0', 'API', 'UserGroupID', 'UserGroupName'),
(LOWER(REPLACE(CAST(NEWID() AS VARCHAR(50)), '-', '')), 'frmTaiKhoan', 'EmployeeID', 'SELECT NHANVIENID AS EmployeeID, Tennv AS EmployeeName FROM dmNhanvienView', 'API', 'EmployeeID', 'EmployeeName');
GO

PRINT N'Hoàn thành thiết lập All-In-One cho frmTaiKhoan!';
GO

