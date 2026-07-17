CREATE OR ALTER PROCEDURE [dbo].[API_TruyVanDong]
    @List SYSNAME,
    @Keyword NVARCHAR(200) = '',
    @SortColumn VARCHAR(50) = '',
    @SortDir VARCHAR(10) = '',
    @Data NVARCHAR(MAX) = '' -- Dùng @Data thay vì @FilterJSON để nhất quán với Gateway
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @TableName SYSNAME;
    DECLARE @PrimaryKey SYSNAME;
    DECLARE @ObjectId INT = OBJECT_ID(@List, 'U');
    DECLARE @QualifiedTable NVARCHAR(517);
    
    -- Ánh xạ động: Tên Form chính là tên View hoặc Bảng vật lý thật trong CSDL
    SET @TableName = OBJECT_NAME(@ObjectId);

    IF @ObjectId IS NULL
    BEGIN
        SELECT -1 AS code, N'List must be an existing user table: ' + ISNULL(@List, '') AS msg;
        RETURN;
    END

    SET @PrimaryKey = '';

    -- Tìm Primary Key từ hệ thống nếu chưa map tĩnh
    IF @PrimaryKey IS NULL OR @PrimaryKey = ''
    BEGIN
        SELECT TOP 1 @PrimaryKey = c.name
        FROM sys.indexes i
        JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
        JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
        WHERE i.is_primary_key = 1
          AND i.object_id = @ObjectId;
    END

    IF @TableName IS NULL OR @TableName = ''
    BEGIN
        SELECT -1 AS code, N'Chưa cấu hình TableName cho form ' + @List AS msg;
        RETURN;
    END
    
    -- Biến chứa SQL động
    SET @QualifiedTable = QUOTENAME(OBJECT_SCHEMA_NAME(@ObjectId)) + N'.' + QUOTENAME(@TableName);

    DECLARE @sql NVARCHAR(MAX);
    DECLARE @whereClause NVARCHAR(MAX) = ' WHERE 1=1';

    -- XỬ LÝ LỌC TỪ JSON (JsonData từ UI)
    IF ISNULL(@Data, '') <> '' AND ISJSON(@Data) > 0
    BEGIN
        DECLARE @jsonFilter NVARCHAR(MAX);
        SELECT @jsonFilter = STUFF((
            SELECT ' AND CONVERT(NVARCHAR(MAX), ' + QUOTENAME([key]) + ') LIKE N''%'' + ' +
                   'REPLACE(N''' + REPLACE([value], '''', '''''') + ''', ''\t'', '''')' + ' + ''%'''
            FROM OPENJSON(@Data)
            WHERE [value] IS NOT NULL AND CAST([value] AS NVARCHAR(MAX)) <> ''
              AND [key] COLLATE DATABASE_DEFAULT <> 'Keyword'
              AND EXISTS (
                  SELECT 1 FROM sys.columns 
                  WHERE object_id = @ObjectId AND name = [key] COLLATE DATABASE_DEFAULT
              )
            FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 0, '');

        IF @jsonFilter IS NOT NULL
        BEGIN
            SET @whereClause = @whereClause + @jsonFilter;
        END
    END




    -- Thêm điều kiện tìm kiếm nếu có Keyword (Tìm kiếm toàn cục)
    IF EXISTS (
        SELECT 1 FROM sys.columns
        WHERE object_id = @ObjectId AND name = 'IsDeleted'
    )
    BEGIN
        SET @whereClause = @whereClause + ' AND ISNULL(' + QUOTENAME('IsDeleted') + ', 0) = 0';
    END

    IF ISNULL(@Keyword, '') <> ''
    BEGIN
        DECLARE @searchCols NVARCHAR(MAX);
        
        -- Dùng sys.columns để lấy danh sách cột text
        SELECT @searchCols = STUFF((
            SELECT ' OR ' + QUOTENAME(c.name) + ' LIKE ''%'' + @kw + ''%'''
            FROM sys.columns c
            JOIN sys.objects t ON c.object_id = t.object_id
            JOIN sys.types ty ON c.system_type_id = ty.system_type_id
             WHERE t.object_id = @ObjectId
              AND ty.name IN ('varchar', 'nvarchar', 'char', 'nchar', 'text', 'ntext')
            FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 4, '');

        IF @searchCols IS NOT NULL AND @searchCols <> ''
        BEGIN
            SET @whereClause = @whereClause + ' AND (' + @searchCols + ')';
        END
    END

    -- Xử lý ORDER BY
    DECLARE @OrderByClause NVARCHAR(MAX);
    
    -- Nếu frontend truyền SortColumn thì ưu tiên dùng
    IF ISNULL(@SortColumn, '') <> ''
       AND EXISTS (
           SELECT 1 FROM sys.columns
           WHERE object_id = @ObjectId
             AND name = @SortColumn
       )
    BEGIN
        -- Mặc định ASC nếu không truyền SortDir hợp lệ
        IF ISNULL(@SortDir, '') NOT IN ('ASC', 'DESC', 'asc', 'desc')
            SET @SortDir = 'ASC';
            
        SET @OrderByClause = ' ORDER BY ' + QUOTENAME(@SortColumn) + ' ' + @SortDir;
    END
    -- Nếu không có SortColumn thì fallback về PrimaryKey
    ELSE IF @PrimaryKey IS NOT NULL AND @PrimaryKey <> ''
    BEGIN
        SET @OrderByClause = ' ORDER BY ' + QUOTENAME(@PrimaryKey) + ' DESC ';
    END
    ELSE
    BEGIN
        SET @OrderByClause = ' ORDER BY (SELECT 1) ';
    END

    -- Lấy danh sách cột
    -- Read columns from the actual table/view schema. SY_FmtFldTbl only controls UI presentation.
    -- This lets newly added database columns flow through to the UI without a separate registration step.
    DECLARE @ColumnList NVARCHAR(MAX);
    SELECT @ColumnList = STUFF((
        SELECT ', ' + QUOTENAME(c.name)
        FROM sys.columns c
        WHERE c.object_id = @ObjectId
        ORDER BY c.column_id
        FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 2, '');

    IF @ColumnList IS NULL OR @ColumnList = ''
    BEGIN
        SELECT -1 AS code, N'No columns found for table/view ' + @TableName AS msg;
        RETURN;
    END

    -- Sinh câu SQL động (Trả toàn bộ dữ liệu để C# Backend tự phân trang)
    SET @sql = 'SELECT ' + @ColumnList + ' ' +
               ' FROM ' + @QualifiedTable + @whereClause +
               @OrderByClause + ';';
    
    -- Chạy lệnh
    EXEC sp_executesql @sql, N'@kw NVARCHAR(200)', @kw = @Keyword;
END
GO
