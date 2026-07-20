USE [QLTiec]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
  Generic delete contract
  @List normally names a physical user table. Known read-model views are
  explicitly mapped to their write table before validation.
*/
CREATE OR ALTER PROCEDURE dbo.API_XoaDong
    @List SYSNAME,
    @Ids NVARCHAR(MAX),
    @UserName VARCHAR(50) = 'System'
AS
BEGIN
    SET NOCOUNT ON;

    /* Form đọc dùng view, nhưng xóa phải đi vào bảng vật lý. */
    IF @List = N'v_DanhSachHopDong'
        SET @List = N'tbmk_Hopdong';

    DECLARE @ObjectId INT = OBJECT_ID(@List, 'U');
    DECLARE @PrimaryKey SYSNAME;
    DECLARE @QualifiedTable NVARCHAR(517);
    DECLARE @Sql NVARCHAR(MAX);
    DECLARE @HasIsDeleted BIT = 0;
    DECLARE @HasDeletedAt BIT = 0;
    DECLARE @HasDeletedBy BIT = 0;
    DECLARE @PrimaryKeyCount INT = 0;
    DECLARE @RowsAffected INT = 0;

    IF @ObjectId IS NULL
    BEGIN
        SELECT -1 AS code, N'List must be an existing user table: ' + ISNULL(@List, '') AS msg;
        RETURN;
    END;

    IF NULLIF(LTRIM(RTRIM(@Ids)), '') IS NULL
    BEGIN
        SELECT -1 AS code, N'Ids is required.' AS msg;
        RETURN;
    END;

    SELECT @PrimaryKeyCount = COUNT(*)
    FROM sys.indexes i
    INNER JOIN sys.index_columns ic ON ic.object_id = i.object_id AND ic.index_id = i.index_id
    WHERE i.object_id = @ObjectId AND i.is_primary_key = 1;

    IF @PrimaryKeyCount <> 1
    BEGIN
        SELECT -1 AS code, N'Generic delete requires exactly one primary-key column.' AS msg;
        RETURN;
    END;

    SELECT @PrimaryKey = c.name
    FROM sys.indexes i
    INNER JOIN sys.index_columns ic ON ic.object_id = i.object_id AND ic.index_id = i.index_id
    INNER JOIN sys.columns c ON c.object_id = ic.object_id AND c.column_id = ic.column_id
    WHERE i.object_id = @ObjectId AND i.is_primary_key = 1;

    SET @QualifiedTable = QUOTENAME(OBJECT_SCHEMA_NAME(@ObjectId)) + N'.' + QUOTENAME(OBJECT_NAME(@ObjectId));
    SET @HasIsDeleted = CASE WHEN COL_LENGTH(@List, 'IsDeleted') IS NULL THEN 0 ELSE 1 END;
    SET @HasDeletedAt = CASE WHEN COL_LENGTH(@List, 'DeletedAt') IS NULL THEN 0 ELSE 1 END;
    SET @HasDeletedBy = CASE WHEN COL_LENGTH(@List, 'DeletedBy') IS NULL THEN 0 ELSE 1 END;

    BEGIN TRY
        IF @HasIsDeleted = 1
        BEGIN
            SET @Sql = N'UPDATE ' + @QualifiedTable + N' SET [IsDeleted] = 1'
                + CASE WHEN @HasDeletedAt = 1 THEN N', [DeletedAt] = SYSUTCDATETIME()' ELSE N'' END
                + CASE WHEN @HasDeletedBy = 1 THEN N', [DeletedBy] = @UserName' ELSE N'' END
                + N' WHERE CONVERT(NVARCHAR(MAX), ' + QUOTENAME(@PrimaryKey)
                + N') IN (SELECT LTRIM(RTRIM(value)) FROM string_split(@Ids, '','')); SET @RowsAffected = @@ROWCOUNT;';
        END
        ELSE
        BEGIN
            SET @Sql = N'DELETE FROM ' + @QualifiedTable
                + N' WHERE CONVERT(NVARCHAR(MAX), ' + QUOTENAME(@PrimaryKey)
                + N') IN (SELECT LTRIM(RTRIM(value)) FROM string_split(@Ids, '','')); SET @RowsAffected = @@ROWCOUNT;';
        END;

        EXEC sp_executesql @Sql,
            N'@Ids NVARCHAR(MAX), @UserName VARCHAR(50), @RowsAffected INT OUTPUT',
            @Ids = @Ids,
            @UserName = @UserName,
            @RowsAffected = @RowsAffected OUTPUT;
        SELECT 0 AS code, N'Deleted ' + CONVERT(NVARCHAR(20), @RowsAffected) + N' row(s).' AS msg;
    END TRY
    BEGIN CATCH
        SELECT -1 AS code, ERROR_MESSAGE() AS msg;
    END CATCH
END
GO
