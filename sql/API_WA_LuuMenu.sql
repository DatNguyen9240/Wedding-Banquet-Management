USE [QLTiec]
GO

/****** Object:  StoredProcedure [dbo].[API_WA_LuuMenu] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[API_WA_LuuMenu]
    @NhomNguoiDangThaoTac NVARCHAR(50) = '',
    @MenuID NVARCHAR(50),
    @OldMenuID NVARCHAR(50) = '',
    @ParentID NVARCHAR(50) = '',
    @Label NVARCHAR(250),
    @EN NVARCHAR(250) = '',
    @FormName NVARCHAR(250) = '',
    @Icon NVARCHAR(100) = '',
    @IsDisable BIT = 0,
    @IsEdit BIT = 0
AS
BEGIN
    SET NOCOUNT ON;

    IF (@IsEdit = 1)
    BEGIN
        -- Đổi ID nếu cần thiết
        IF (@OldMenuID <> '' AND @OldMenuID <> @MenuID)
        BEGIN
            UPDATE WA_Menu SET MenuID = @MenuID WHERE MenuID = @OldMenuID;
            UPDATE WA_UserGroupPermisstion SET MenuID = @MenuID WHERE MenuID = @OldMenuID;
            UPDATE WA_UserPermisstion SET MenuID = @MenuID WHERE MenuID = @OldMenuID;
        END

        UPDATE WA_Menu 
        SET 
            Parent = @ParentID,
            VN = @Label,
            EN = @EN,
            FormName = @FormName,
            IconClass = @Icon,
            isDisable = @IsDisable
        WHERE MenuID = @MenuID;
    END
    ELSE
    BEGIN
        IF EXISTS (SELECT 1 FROM WA_Menu WHERE MenuID = @MenuID)
        BEGIN
            RAISERROR (N'Lỗi: Menu ID này đã tồn tại trong hệ thống!', 16, 1);
            RETURN;
        END

        INSERT INTO WA_Menu (MenuID, Parent, VN, EN, FormName, IconClass, isDisable)
        VALUES (@MenuID, @ParentID, @Label, @EN, @FormName, @Icon, @IsDisable);
    END
END
GO
