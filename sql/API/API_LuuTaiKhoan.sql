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

    -- Các tham số hệ thống
    @FormName VARCHAR(50) = NULL,
    @User VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM SY_User WHERE UserName = @UserName)
    BEGIN
        -- Update
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
        -- Insert
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

    -- Trả về dữ liệu vừa lưu để Frontend cập nhật Lưới
    SELECT 
        UserName, HoTen, TenNgan, Password, UserGroupID, Disable, EmployeeID, Manager,
        IsBaocongno, IsBackupDatabase, IsFormBaocao, IsPhieuchi, IsBaococcho, IsBaotiec,
        IsBaoTrungSanh, IsBaoHopDong, IsBaoLichTiec, IsDuyetDeXuat, StartupForm, DisableAutoBackup
    FROM SY_User
    WHERE UserName = @UserName;

END
GO

