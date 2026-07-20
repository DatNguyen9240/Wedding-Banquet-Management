USE [QLTiec]
GO

/* Sửa các FormatID NULL/rỗng hoặc không tồn tại trong SY_FmatTbl. */
SET XACT_ABORT ON
GO

BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @Formats TABLE (
        FieldName SYSNAME NOT NULL PRIMARY KEY,
        FormatID VARCHAR(20) NOT NULL
    );

    /* Ưu tiên kiểu dữ liệu thực tế xuất hiện nhiều nhất trong các object SQL. */
    ;WITH Candidates AS (
        SELECT
            dictionary.FieldName,
            CASE
                WHEN columnInfo.system_type_id = 104 THEN 'sw'
                WHEN columnInfo.system_type_id IN (40, 42, 43, 58, 61) THEN 'D'
                WHEN columnInfo.system_type_id = 41 THEN 'H'
                WHEN columnInfo.system_type_id IN (48, 52, 56, 59, 60, 62, 106, 108, 122, 127) THEN 'N0'
                ELSE 't'
            END AS FormatID,
            COUNT(*) AS TypeCount,
            ROW_NUMBER() OVER (
                PARTITION BY dictionary.FieldName
                ORDER BY COUNT(*) DESC,
                         CASE
                             WHEN columnInfo.system_type_id = 104 THEN 5
                             WHEN columnInfo.system_type_id IN (40, 42, 43, 58, 61) THEN 4
                             WHEN columnInfo.system_type_id = 41 THEN 3
                             WHEN columnInfo.system_type_id IN (48, 52, 56, 59, 60, 62, 106, 108, 122, 127) THEN 2
                             ELSE 1
                         END DESC
            ) AS RowNo
        FROM dbo.SY_FmtFldTbl dictionary
        INNER JOIN sys.columns columnInfo
            ON columnInfo.name = dictionary.FieldName
        GROUP BY dictionary.FieldName, columnInfo.system_type_id
    )
    INSERT INTO @Formats (FieldName, FormatID)
    SELECT FieldName, FormatID
    FROM Candidates
    WHERE RowNo = 1;

    /* Các field không còn object vật lý: suy luận an toàn theo quy ước tên. */
    INSERT INTO @Formats (FieldName, FormatID)
    SELECT dictionary.FieldName,
           CASE
               WHEN dictionary.FieldName LIKE 'Is%'
                 OR dictionary.FieldName LIKE 'is%' THEN 'sw'
               WHEN dictionary.FieldName LIKE 'Ngay%'
                 OR dictionary.FieldName LIKE 'Date%'
                 OR dictionary.FieldName LIKE '%Ngay%' THEN 'D'
               WHEN dictionary.FieldName LIKE 'Gio%'
                 OR dictionary.FieldName LIKE '%Gio%' THEN 'H'
               ELSE 't'
           END
    FROM dbo.SY_FmtFldTbl dictionary
    WHERE NOT EXISTS (
        SELECT 1 FROM @Formats known WHERE known.FieldName = dictionary.FieldName
    );

    UPDATE dictionary
    SET dictionary.FormatID = formats.FormatID
    FROM dbo.SY_FmtFldTbl dictionary
    INNER JOIN @Formats formats ON formats.FieldName = dictionary.FieldName
    WHERE NULLIF(LTRIM(RTRIM(dictionary.FormatID)), '') IS NULL
       OR NOT EXISTS (
           SELECT 1
           FROM dbo.SY_FmatTbl formatDefinition
           WHERE formatDefinition.FormatID = dictionary.FormatID
       );

    DECLARE @UpdatedRows INT = @@ROWCOUNT;

    COMMIT TRANSACTION;

    SELECT @UpdatedRows AS UpdatedRows;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO
