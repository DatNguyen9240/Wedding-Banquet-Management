USE [QLTiec]
GO

/****** Object:  StoredProcedure [dbo].[API_DongBoQuyenTruyCap] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[API_DongBoQuyenTruyCap]
AS
BEGIN
    -- Triệt tiêu dòng báo "N rows affected" để tăng hiệu năng xử lý
    SET NOCOUNT ON;

    -- ====================================================================
    -- PHẦN 1: XỬ LÝ PHÂN QUYỀN CHO NHÓM (USER GROUP PERMISSION)
    -- ====================================================================

    -- 1.1 DỌN RÁC: Xóa các quyền bị rỗng MenuID
    DELETE FROM WA_UserGroupPermisstion 
    WHERE COALESCE(MenuID, '') = '';

    -- 1.2 DỌN RÁC: Xóa các quyền thuộc về những Menu không có Form Giao diện (FormName trống)
    DELETE FROM WA_UserGroupPermisstion 
    WHERE MenuID IN ( 
        SELECT COALESCE(MenuID, '') FROM WA_Menu WHERE COALESCE(FormName, '') = '' 
    );

    -- 1.3 DỌN RÁC: Xóa dữ liệu thừa của những Nhóm đã bị xóa khỏi hệ thống
    DELETE FROM WA_UserGroupPermisstion 
    WHERE UserGroupID NOT IN ( SELECT UserGroupID FROM SY_UserGroup );

    -- 1.4 DỌN RÁC: Xóa dữ liệu thừa của những Menu đã bị xóa khỏi hệ thống
    DELETE FROM WA_UserGroupPermisstion 
    WHERE MenuID NOT IN ( SELECT MenuID FROM WA_Menu );

    -- 1.5 TỰ ĐỘNG BƠM QUYỀN MỚI: Nhân chéo Nhóm x Menu, nếu thiếu thì Insert mặc định
    -- Bảo mật: Chỉ Admin mới được full quyền mặc định (IsRun=1), các nhóm khác phải admin cấp riêng
    INSERT INTO WA_UserGroupPermisstion (UserGroupID, MenuID, IsRun, IsAdd, IsUpdate, IsDelete, isManager, isAdmin, isAutoLock, isHideAmount, isLockDoc, isUnLockDoc, isExportExcel)
    SELECT 
        A.UserGroupID,
        A.MenuID,
        CASE WHEN A.UserGroupID = 'Admin' THEN 1 ELSE 0 END, -- IsRun
        CASE WHEN A.UserGroupID = 'Admin' THEN 1 ELSE 0 END, -- IsAdd
        CASE WHEN A.UserGroupID = 'Admin' THEN 1 ELSE 0 END, -- IsUpdate
        CASE WHEN A.UserGroupID = 'Admin' THEN 1 ELSE 0 END, -- IsDelete
        CASE WHEN A.UserGroupID = 'Admin' THEN 1 ELSE 0 END, -- isManager
        CASE WHEN A.UserGroupID = 'Admin' THEN 1 ELSE 0 END, -- isAdmin
        CASE WHEN A.UserGroupID = 'Admin' THEN 1 ELSE 0 END, -- isAutoLock
        CASE WHEN A.UserGroupID = 'Admin' THEN 1 ELSE 0 END, -- isHideAmount
        CASE WHEN A.UserGroupID = 'Admin' THEN 1 ELSE 0 END, -- isLockDoc
        CASE WHEN A.UserGroupID = 'Admin' THEN 1 ELSE 0 END, -- isUnLockDoc
        CASE WHEN A.UserGroupID = 'Admin' THEN 1 ELSE 0 END  -- isExportExcel
    FROM (
        SELECT UserGroupID, MenuID  
        FROM SY_UserGroup, WA_Menu
        WHERE COALESCE(FormName, '') <> ''
    ) A
    LEFT JOIN ( 
        SELECT DISTINCT UserGroupID + MenuID AS Key01 FROM WA_UserGroupPermisstion 
    ) B ON A.UserGroupID + A.MenuID = B.Key01
    WHERE B.Key01 IS NULL;


    -- ====================================================================
    -- PHẦN 2: XỬ LÝ PHÂN QUYỀN CÁ NHÂN (USER PERMISSION CỤ THỂ TỪNG NGƯỜI)
    -- ====================================================================

    -- 2.1 DỌN RÁC: Xóa các quyền rỗng MenuID của cá nhân
    DELETE FROM WA_UserPermisstion 
    WHERE COALESCE(MenuID, '') = '';

    -- 2.2 DỌN RÁC: Xóa các quyền cá nhân thuộc về Menu không có Form
    DELETE FROM WA_UserPermisstion 
    WHERE MenuID IN ( 
        SELECT COALESCE(MenuID, '') FROM WA_Menu WHERE COALESCE(FormName, '') = '' 
    );

    -- 2.3 DỌN RÁC: Xóa dữ liệu thừa của những nhân viên (UserName) đã nghỉ việc/bị xóa
    DELETE FROM WA_UserPermisstion 
    WHERE UserName NOT IN ( SELECT UserName FROM SY_User );

    -- 2.4 DỌN RÁC: Xóa dữ liệu thừa của những Menu đã bị xóa khỏi hệ thống
    DELETE FROM WA_UserPermisstion 
    WHERE MenuID NOT IN ( SELECT MenuID FROM WA_Menu );

    -- 2.5 TỰ ĐỘNG BƠM QUYỀN MỚI CHO USER KHI CÓ MENU MỚI (Tắt tất cả quyền kể cả IsRun=0 để bảo mật)
    INSERT INTO WA_UserPermisstion (UserName, MenuID, IsRun, IsAdd, IsUpdate, IsDelete, isManager, isAdmin, isAutoLock, isHideAmount, isLockDoc, isUnLockDoc, isExportExcel)
    SELECT UserName, MenuID, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 
    FROM (
        SELECT UserName, MenuID  
        FROM SY_User, WA_Menu
        WHERE COALESCE(FormName, '') <> ''
    ) A
    LEFT JOIN ( 
        SELECT DISTINCT UserName + MenuID AS Key01 FROM WA_UserPermisstion 
    ) B ON A.UserName + A.MenuID = B.Key01
    WHERE B.Key01 IS NULL;

END
GO
