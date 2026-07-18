USE [QLTiec]
GO

/* Explicit global dictionary registration for the generic WA_Menu CRUD page. */
SET XACT_ABORT ON
GO

BEGIN TRY
    BEGIN TRANSACTION;

    IF NOT EXISTS (SELECT 1 FROM dbo.SY_FmatTbl WHERE FormatID = 't')
       OR NOT EXISTS (SELECT 1 FROM dbo.SY_FmatTbl WHERE FormatID = 'sw')
        THROW 51040, 'WA_Menu requires canonical FormatID t and sw in SY_FmatTbl.', 1;

    /* NCHAR keeps Vietnamese captions correct even when the SQL editor is ANSI. */
    DECLARE @Fields TABLE (
        FieldName VARCHAR(128) NOT NULL PRIMARY KEY,
        CaptionVN NVARCHAR(255) NOT NULL,
        FormatID VARCHAR(20) NOT NULL
    );

    INSERT INTO @Fields (FieldName, CaptionVN, FormatID)
    VALUES
        ('MenuID', N'M' + NCHAR(227) + N' menu', 't'),
        ('VN', N'T' + NCHAR(234) + N'n ti' + NCHAR(7871) + N'ng Vi' + NCHAR(7879) + N't', 't'),
        ('EN', N'T' + NCHAR(234) + N'n ti' + NCHAR(7871) + N'ng Anh', 't'),
        ('CH', N'T' + NCHAR(234) + N'n ti' + NCHAR(7871) + N'ng Hoa', 't'),
        ('Parent', N'Menu cha', 't'),
        ('IconClass', N'L' + NCHAR(7899) + N'p bi' + NCHAR(7875) + N'u t' + NCHAR(432) + N'' + NCHAR(7907) + N'ng', 't'),
        ('FormKey', N'Kh' + NCHAR(243) + N'a form', 't'),
        ('FormName', N'T' + NCHAR(234) + N'n form', 't'),
        ('URLPara', N'' + NCHAR(272) + N'' + NCHAR(432) + N'' + NCHAR(7901) + N'ng d' + NCHAR(7851) + N'n', 't'),
        ('isDisable', N'Ng' + NCHAR(7915) + N'ng s' + NCHAR(7917) + N' d' + NCHAR(7909) + N'ng', 'sw'),
        ('isNotCheckPermission', N'B' + NCHAR(7887) + N' ki' + NCHAR(7875) + N'm tra quy' + NCHAR(7873) + N'n', 'sw'),
        ('Sticky', N'Ghim menu', 'sw'),
        ('isImageMenu', N'D' + NCHAR(249) + N'ng ' + NCHAR(7843) + N'nh menu', 'sw'),
        ('ImageURL', N'' + NCHAR(272) + N'' + NCHAR(432) + N'' + NCHAR(7901) + N'ng d' + NCHAR(7851) + N'n ' + NCHAR(7843) + N'nh', 't'),
        ('NotifyIconSQLCmd', N'C' + NCHAR(226) + N'u l' + NCHAR(7879) + N'nh bi' + NCHAR(7875) + N'u t' + NCHAR(432) + N'' + NCHAR(7907) + N'ng th' + NCHAR(244) + N'ng b' + NCHAR(225) + N'o', 't'),
        ('NotifyIconClass', N'L' + NCHAR(7899) + N'p bi' + NCHAR(7875) + N'u t' + NCHAR(432) + N'' + NCHAR(7907) + N'ng th' + NCHAR(244) + N'ng b' + NCHAR(225) + N'o', 't'),
        ('SubTitle', N'Ti' + NCHAR(234) + N'u ' + NCHAR(273) + N'' + NCHAR(7873) + N' ph' + NCHAR(7909) + N'', 't');

    IF EXISTS (
        SELECT 1
        FROM dbo.SY_FmtFldTbl f
        INNER JOIN @Fields w ON w.FieldName = f.FieldName
        GROUP BY f.FieldName
        HAVING COUNT(*) > 1
    )
        THROW 51041, 'A WA_Menu field has duplicate global dictionary records.', 1;

    UPDATE f
    SET CaptionVN = w.CaptionVN,
        FormatID = w.FormatID
    FROM dbo.SY_FmtFldTbl f
    INNER JOIN @Fields w ON w.FieldName = f.FieldName;

    INSERT INTO dbo.SY_FmtFldTbl (FormName, FieldName, CaptionVN, FormatID)
    SELECT 'WA_Menu', w.FieldName, w.CaptionVN, w.FormatID
    FROM @Fields w
    WHERE NOT EXISTS (
        SELECT 1
        FROM dbo.SY_FmtFldTbl f
        WHERE f.FieldName = w.FieldName
    );

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO
