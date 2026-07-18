USE [QLTiec]
GO

CREATE OR ALTER PROCEDURE dbo.API_XoaForm
    @FormKey VARCHAR(50),
    @Ids NVARCHAR(MAX),
    @UserName VARCHAR(50) = 'System'
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @WriteObject SYSNAME;
    DECLARE @DeleteProcedure SYSNAME;
    DECLARE @DeleteIdsParameter SYSNAME;

    SELECT
        @WriteObject = WriteObject,
        @DeleteProcedure = DeleteProcedure,
        @DeleteIdsParameter = DeleteIdsParameter
    FROM dbo.SY_FormTbl
    WHERE FormKey = @FormKey
      AND IsActive = 1
      AND CanDelete = 1;

    IF @WriteObject IS NULL AND @DeleteProcedure IS NULL
    BEGIN
        SELECT -1 AS code, N'Form cannot be deleted: ' + ISNULL(@FormKey, '') AS msg;
        RETURN;
    END;

    IF NULLIF(LTRIM(RTRIM(@Ids)), '') IS NULL
    BEGIN
        SELECT -1 AS code, N'Ids is required.' AS msg;
        RETURN;
    END;

    IF @DeleteProcedure IS NULL
    BEGIN
        EXEC dbo.API_XoaDong @List = @WriteObject, @Ids = @Ids, @UserName = @UserName;
        RETURN;
    END;

    DECLARE @ProcedureId INT = OBJECT_ID(N'dbo.' + @DeleteProcedure, N'P');
    IF @ProcedureId IS NULL
    BEGIN
        SELECT -1 AS code, N'Configured delete procedure does not exist.' AS msg;
        RETURN;
    END;

    IF NOT EXISTS
    (
        SELECT 1
        FROM sys.parameters
        WHERE object_id = @ProcedureId
          AND name = N'@' + @DeleteIdsParameter
    )
    BEGIN
        SELECT -1 AS code, N'Configured delete id parameter does not exist.' AS msg;
        RETURN;
    END;

    DECLARE @Sql NVARCHAR(MAX) = N'EXEC dbo.' + QUOTENAME(@DeleteProcedure)
        + N' @' + @DeleteIdsParameter + N' = @pIds, @UserName = @pUserName;';

    BEGIN TRY
        EXEC sp_executesql @Sql,
            N'@pIds NVARCHAR(MAX), @pUserName VARCHAR(50)',
            @pIds = @Ids,
            @pUserName = @UserName;
    END TRY
    BEGIN CATCH
        SELECT -1 AS code, ERROR_MESSAGE() AS msg;
    END CATCH
END
GO
