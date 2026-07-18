USE [QLTiec]
GO

CREATE OR ALTER PROCEDURE dbo.API_LuuForm
    @FormKey VARCHAR(50),
    @Data NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @WriteObject SYSNAME;
    DECLARE @SaveProcedure SYSNAME;

    SELECT
        @WriteObject = WriteObject,
        @SaveProcedure = SaveProcedure
    FROM dbo.SY_FormTbl
    WHERE FormKey = @FormKey
      AND IsActive = 1
      AND (CanAdd = 1 OR CanEdit = 1);

    IF @WriteObject IS NULL AND @SaveProcedure IS NULL
    BEGIN
        SELECT -1 AS code, N'Form is not writable: ' + ISNULL(@FormKey, '') AS msg;
        RETURN;
    END;

    IF @Data IS NULL OR ISJSON(@Data) <> 1
    BEGIN
        SELECT -1 AS code, N'Data must be a JSON object.' AS msg;
        RETURN;
    END;

    -- A normal table form stays fully generic.
    IF @SaveProcedure IS NULL
    BEGIN
        EXEC dbo.API_LuuDong @List = @WriteObject, @Data = @Data;
        RETURN;
    END;

    /*
      Procedure-backed form: bind JSON properties to identically named stored
      procedure parameters. The registry selects the procedure; no form name,
      payload map, or endpoint is encoded in the frontend.
    */
    DECLARE @ProcedureId INT = OBJECT_ID(N'dbo.' + @SaveProcedure, N'P');
    IF @ProcedureId IS NULL
    BEGIN
        SELECT -1 AS code, N'Configured save procedure does not exist.' AS msg;
        RETURN;
    END;

    DECLARE @Declarations NVARCHAR(MAX) = N'';
    DECLARE @Arguments NVARCHAR(MAX) = N'';
    DECLARE @Sql NVARCHAR(MAX);

    ;WITH BoundParameters AS
    (
        SELECT
            P.parameter_id,
            P.name,
            P.is_output,
            T.name AS TypeName,
            P.max_length,
            P.precision,
            P.scale,
            J.[value],
            J.[type]
        FROM sys.parameters P
        INNER JOIN sys.types T ON T.user_type_id = P.user_type_id
        INNER JOIN OPENJSON(@Data) J
            ON J.[key] COLLATE DATABASE_DEFAULT = SUBSTRING(P.name, 2, 4000) COLLATE DATABASE_DEFAULT
        WHERE P.object_id = @ProcedureId
          AND P.parameter_id > 0
    ), TypedParameters AS
    (
        SELECT *,
            CASE
                WHEN TypeName IN ('varchar', 'char', 'varbinary', 'binary')
                    THEN TypeName + '(' + CASE WHEN max_length = -1 THEN 'max' ELSE CONVERT(VARCHAR(10), max_length) END + ')'
                WHEN TypeName IN ('nvarchar', 'nchar')
                    THEN TypeName + '(' + CASE WHEN max_length = -1 THEN 'max' ELSE CONVERT(VARCHAR(10), max_length / 2) END + ')'
                WHEN TypeName IN ('decimal', 'numeric')
                    THEN TypeName + '(' + CONVERT(VARCHAR(10), precision) + ',' + CONVERT(VARCHAR(10), scale) + ')'
                WHEN TypeName IN ('datetime2', 'datetimeoffset', 'time')
                    THEN TypeName + '(' + CONVERT(VARCHAR(10), scale) + ')'
                ELSE TypeName
            END AS SqlType
        FROM BoundParameters
    )
    SELECT * INTO #TypedParameters FROM TypedParameters;

    SELECT @Declarations = STUFF((
        SELECT N' DECLARE @out_' + CONVERT(VARCHAR(10), parameter_id) + N' ' + SqlType
            + N' = ' + CASE WHEN [type] = 0 OR NULLIF([value], N'') IS NULL
                THEN N'NULL'
                ELSE N'CAST(N''' + REPLACE([value], '''', '''''') + N''' AS ' + SqlType + N')'
              END + N';'
        FROM #TypedParameters
        WHERE is_output = 1
        ORDER BY parameter_id
        FOR XML PATH(''), TYPE
    ).value('.', 'NVARCHAR(MAX)'), 1, 1, N'');

    SELECT @Arguments = STUFF((
        SELECT N', ' + name + N' = '
            + CASE WHEN is_output = 1
                THEN N'@out_' + CONVERT(VARCHAR(10), parameter_id) + N' OUTPUT'
                WHEN [type] = 0 THEN N'NULL'
                ELSE N'N''' + REPLACE([value], '''', '''''') + N''''
              END
        FROM #TypedParameters
        ORDER BY parameter_id
        FOR XML PATH(''), TYPE
    ).value('.', 'NVARCHAR(MAX)'), 1, 2, N'');

    SET @Sql = ISNULL(@Declarations, N'')
        + N' EXEC dbo.' + QUOTENAME(@SaveProcedure)
        + CASE WHEN NULLIF(@Arguments, N'') IS NULL THEN N'' ELSE N' ' + @Arguments END + N';';

    BEGIN TRY
        EXEC sp_executesql @Sql;
    END TRY
    BEGIN CATCH
        SELECT -1 AS code, ERROR_MESSAGE() AS msg;
    END CATCH
END
GO
