USE [QLTiec]
GO

/****** Object: StoredProcedure [dbo].[API_LayQuyenNhomDayDu] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[API_LayQuyenNhomDayDu]
    @NhomNguoiDangThaoTac NVARCHAR(50), -- ID Nhóm của người gọi API
    @UserGroupID           NVARCHAR(50)  -- ID Nhóm cần xem quyền
AS
BEGIN
    SET NOCOUNT ON;

    -- Chỉ cho phép: tự soi chính mình HOẶC Admin soi người khác
    IF (@NhomNguoiDangThaoTac != @UserGroupID) AND (@NhomNguoiDangThaoTac != 'Admin')
    BEGIN
        RAISERROR (N'Lỗi: Bạn không có thẩm quyền xem phân quyền của nhóm này!', 16, 1);
        RETURN;
    END

    -- VẾ 1: Tất cả MENU LÁ (có FormName) + quyền hiện tại (dù IsRun=0 hay 1)
    -- Dùng LEFT JOIN để menu chưa có trong bảng quyền vẫn hiện với giá trị 0
    SELECT
        M.MenuID        AS [id],
        M.Parent        AS [parent],
        M.VN            AS [label],
        M.IconClass     AS [icon],
        M.FormName      AS [formName],
        ISNULL(P.IsRun,        0) AS IsRun,
        ISNULL(P.IsAdd,        0) AS IsAdd,
        ISNULL(P.IsUpdate,     0) AS IsUpdate,
        ISNULL(P.IsDelete,     0) AS IsDelete,
        ISNULL(P.isManager,    0) AS isManager,
        ISNULL(P.isAdmin,      0) AS isAdmin,
        ISNULL(P.isAutoLock,   0) AS isAutoLock,
        ISNULL(P.isHideAmount, 0) AS isHideAmount,
        ISNULL(P.isLockDoc,    0) AS isLockDoc,
        ISNULL(P.isUnLockDoc,  0) AS isUnLockDoc,
        ISNULL(P.isExportExcel,0) AS isExportExcel
    FROM WA_Menu M
    LEFT JOIN WA_UserGroupPermisstion P
        ON M.MenuID = P.MenuID AND P.UserGroupID = @UserGroupID
    WHERE COALESCE(M.isDisable, 0) = 0
      AND COALESCE(M.FormName,  '') <> ''

    UNION ALL

    -- VẾ 2: Các THƯ MỤC CHA (không có FormName) để dựng cây
    SELECT
        M.MenuID    AS [id],
        M.Parent    AS [parent],
        M.VN        AS [label],
        M.IconClass AS [icon],
        M.FormName  AS [formName],
        1 AS IsRun, 0 AS IsAdd, 0 AS IsUpdate, 0 AS IsDelete,
        0 AS isManager, 0 AS isAdmin, 0 AS isAutoLock, 0 AS isHideAmount,
        0 AS isLockDoc, 0 AS isUnLockDoc, 0 AS isExportExcel
    FROM WA_Menu M
    WHERE COALESCE(M.isDisable, 0) = 0
      AND COALESCE(M.FormName, '') = ''
      AND M.MenuID IN (
          SELECT DISTINCT Parent FROM WA_Menu
          WHERE COALESCE(isDisable, 0) = 0
            AND COALESCE(FormName, '') <> ''
            AND Parent IS NOT NULL AND Parent <> ''
      )

    ORDER BY [id];
END
GO
