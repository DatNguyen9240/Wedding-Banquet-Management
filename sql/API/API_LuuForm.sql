USE [QLTiec]
GO

CREATE OR ALTER PROCEDURE dbo.API_LuuForm
    @FormKey VARCHAR(50),
    @Data NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @TableName SYSNAME;
    DECLARE @UserName VARCHAR(50) = NULLIF(JSON_VALUE(@Data, '$.UserName'), '');
    DECLARE @IsEdit BIT = CASE WHEN JSON_VALUE(@Data, '$.IsEdit') IN ('1', 'true', 'TRUE') THEN 1 ELSE 0 END;

    IF @UserName IS NULL
    BEGIN
        SELECT -1 AS code, N'UserName is required.' AS msg;
        RETURN;
    END;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.SY_User U
        INNER JOIN dbo.WA_UserGroupPermisstion P ON P.UserGroupID = U.UserGroupID
        INNER JOIN dbo.WA_Menu M ON M.MenuID = P.MenuID
        WHERE U.UserName = @UserName
          AND M.FormKey = @FormKey
          AND P.IsRun = 1
          AND ((@IsEdit = 1 AND P.IsUpdate = 1) OR (@IsEdit = 0 AND P.IsAdd = 1))
    )
    BEGIN
        SELECT -1 AS code, N'You do not have permission to save this form.' AS msg;
        RETURN;
    END;

    SELECT @TableName = TableName
    FROM dbo.SY_FrmLstTbl
    WHERE FormID = @FormKey;

    IF @TableName IS NULL
    BEGIN
        SELECT -1 AS code, N'Form is not configured: ' + ISNULL(@FormKey, '') AS msg;
        RETURN;
    END;

    IF @Data IS NULL OR ISJSON(@Data) <> 1
    BEGIN
        SELECT -1 AS code, N'Data must be a JSON object.' AS msg;
        RETURN;
    END;

    EXEC dbo.API_LuuDong @List = @TableName, @Data = @Data;
END
GO
