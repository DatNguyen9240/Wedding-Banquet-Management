USE [QLTiec]
GO

/*
  Register the complete contract read-model schema in the canonical global
  dictionary. This runs during SQL deployment only; the frontend never invents
  labels or formats at runtime. Grid visibility belongs to
  SY_FrmLstTbl.HideColumnArr and is not written here.
*/
SET XACT_ABORT ON
GO

BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @ObjectId INT = OBJECT_ID(N'dbo.v_DanhSachHopDong', N'V');
    IF @ObjectId IS NULL
        THROW 51080, 'View dbo.v_DanhSachHopDong does not exist.', 1;

    IF EXISTS (
        SELECT 1
        FROM (VALUES ('t'), ('D'), ('H'), ('N0'), ('sw')) requiredFormat(FormatID)
        WHERE NOT EXISTS (
            SELECT 1 FROM dbo.SY_FmatTbl fm WHERE fm.FormatID = requiredFormat.FormatID
        )
    )
        THROW 51081, 'Contract read model requires FormatID t, D, H, N0 and sw.', 1;

    DECLARE @Columns TABLE (
        FieldName VARCHAR(128) NOT NULL PRIMARY KEY,
        CaptionVN NVARCHAR(255) NOT NULL,
        FormatID VARCHAR(20) NOT NULL
    );

    INSERT INTO @Columns (FieldName, CaptionVN, FormatID)
    SELECT
        c.name,
        CONVERT(NVARCHAR(255), c.name),
        CASE
            WHEN c.system_type_id = 104 THEN 'sw'
            WHEN c.system_type_id IN (40, 42, 43, 58, 61) THEN 'D'
            WHEN c.system_type_id = 41 THEN 'H'
            WHEN c.system_type_id IN (48, 52, 56, 59, 60, 62, 106, 108, 122, 127) THEN 'N0'
            ELSE 't'
        END
    FROM sys.columns c
    WHERE c.object_id = @ObjectId;

    UPDATE dictionary
    SET FormatID = CASE
            WHEN EXISTS (
                SELECT 1
                FROM dbo.SY_FmatTbl existingFormat
                WHERE existingFormat.FormatID = dictionary.FormatID
            ) THEN dictionary.FormatID
            ELSE schemaColumn.FormatID
        END,
        CaptionVN = CASE
            WHEN NULLIF(LTRIM(RTRIM(dictionary.CaptionVN)), '') IS NULL THEN schemaColumn.CaptionVN
            ELSE dictionary.CaptionVN
        END
    FROM dbo.SY_FmtFldTbl dictionary
    INNER JOIN @Columns schemaColumn ON schemaColumn.FieldName = dictionary.FieldName;

    INSERT INTO dbo.SY_FmtFldTbl (FormName, FieldName, CaptionVN, FormatID)
    SELECT 'v_DanhSachHopDong', schemaColumn.FieldName, schemaColumn.CaptionVN, schemaColumn.FormatID
    FROM @Columns schemaColumn
    WHERE NOT EXISTS (
        SELECT 1 FROM dbo.SY_FmtFldTbl dictionary WHERE dictionary.FieldName = schemaColumn.FieldName
    );

    IF EXISTS (
        SELECT 1
        FROM sys.columns c
        LEFT JOIN dbo.SY_FmtFldTbl dictionary ON dictionary.FieldName = c.name
        LEFT JOIN dbo.SY_FmatTbl formatDefinition ON formatDefinition.FormatID = dictionary.FormatID
        WHERE c.object_id = @ObjectId
          AND (
              dictionary.FieldName IS NULL
              OR NULLIF(LTRIM(RTRIM(dictionary.CaptionVN)), '') IS NULL
              OR formatDefinition.FormatID IS NULL
          )
    )
        THROW 51082, 'Contract read-model metadata is incomplete after synchronization.', 1;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO
