USE [QLTiec]
GO

CREATE OR ALTER PROCEDURE dbo.API_XoaForm
    @FormKey VARCHAR(50),
    @Ids NVARCHAR(MAX),
    @UserName VARCHAR(50) = 'System'
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.SY_User U
        INNER JOIN dbo.WA_UserGroupPermisstion P ON P.UserGroupID = U.UserGroupID
        INNER JOIN dbo.WA_Menu M ON M.MenuID = P.MenuID
        WHERE U.UserName = @UserName
          AND M.FormKey = @FormKey
          AND P.IsRun = 1
          AND P.IsDelete = 1
    )
    BEGIN
        SELECT -1 AS code, N'You do not have permission to delete this form.' AS msg;
        RETURN;
    END;

    DECLARE @TableName SYSNAME;
    SELECT @TableName = TableName
    FROM dbo.SY_FrmLstTbl
    WHERE FormID = @FormKey;

    IF @TableName IS NULL
    BEGIN
        SELECT -1 AS code, N'Form is not configured: ' + ISNULL(@FormKey, '') AS msg;
        RETURN;
    END;

    IF NULLIF(LTRIM(RTRIM(@Ids)), '') IS NULL
    BEGIN
        SELECT -1 AS code, N'Ids is required.' AS msg;
        RETURN;
    END;

    EXEC dbo.API_XoaDong @List = @TableName, @Ids = @Ids, @UserName = @UserName;
END
GO
