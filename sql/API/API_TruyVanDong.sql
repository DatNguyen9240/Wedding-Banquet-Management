CREATE OR ALTER PROCEDURE [dbo].[API_TruyVanDong]
    @FormName VARCHAR(50),
    @Keyword NVARCHAR(200) = '',
    @FilterJSON NVARCHAR(MAX) = NULL,
    @UserName VARCHAR(50) = '',
    @Page INT = 1,
    @Limit INT = 15,
    @SortColumn VARCHAR(50) = '',
    @SortDir VARCHAR(10) = ''
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @TableName VARCHAR(100);
    DECLARE @PrimaryKey VARCHAR(50);
    
    -- Lấy thông tin Bảng vật lý và Khóa chính từ cấu hình form
    SELECT 
        @TableName = LTRIM(RTRIM(TableName)),
        @PrimaryKey = LTRIM(RTRIM(PrimaryKey))
    FROM SY_FrmLstTbl 
    WHERE FormID = @FormName;

    IF @TableName IS NULL OR @TableName = ''
    BEGIN
        SELECT -1 AS code, N'Chưa cấu hình TableName cho form ' + @FormName AS msg;
        RETURN;
    END
    
    -- Xử lý an toàn Sort
    IF @SortColumn = '' SET @SortColumn = ISNULL(@PrimaryKey, '');
    IF @SortDir = '' SET @SortDir = 'DESC';

    -- Tính toán phân trang
    DECLARE @Offset INT = (@Page - 1) * @Limit;

    -- Biến chứa SQL động
    DECLARE @sql NVARCHAR(MAX);
    DECLARE @whereClause NVARCHAR(MAX) = ' WHERE 1=1';

    -- =========================================================================
    -- MAGIC: RÃ JSON RA ĐỂ GHÉP ĐIỀU KIỆN TÌM KIẾM ĐỘNG
    -- =========================================================================
    IF ISNULL(@FilterJSON, '') <> ''
    BEGIN
        SELECT @whereClause = @whereClause + 
            CASE 
                -- Nếu tên cột là Mã/ID thì dùng '='
                WHEN [key] LIKE 'Ma%' OR [key] LIKE '%ID' THEN ' AND ' + QUOTENAME([key]) + ' = N''' + REPLACE(CAST([value] AS NVARCHAR(MAX)), '''', '''''') + ''''
                -- Còn lại dùng LIKE
                ELSE ' AND ' + QUOTENAME([key]) + ' LIKE N''%' + REPLACE(CAST([value] AS NVARCHAR(MAX)), '''', '''''') + '%'''
            END
        FROM OPENJSON(@FilterJSON)
        WHERE CAST([value] AS NVARCHAR(MAX)) <> ''; -- Bỏ qua các key có value rỗng
    END

    -- Thêm điều kiện tìm kiếm nếu có Keyword (Tìm kiếm toàn cục)
    IF ISNULL(@Keyword, '') <> ''
    BEGIN
        DECLARE @searchCols NVARCHAR(MAX);
        
        -- Dùng sys.columns để lấy danh sách cột text
        SELECT @searchCols = STUFF((
            SELECT ' OR ' + QUOTENAME(c.name) + ' LIKE ''%'' + @kw + ''%'''
            FROM sys.columns c
            JOIN sys.objects t ON c.object_id = t.object_id
            JOIN sys.types ty ON c.system_type_id = ty.system_type_id
            WHERE t.name = @TableName 
              AND ty.name IN ('varchar', 'nvarchar', 'char', 'nchar', 'text', 'ntext')
            FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 4, '');

        IF @searchCols IS NOT NULL AND @searchCols <> ''
        BEGIN
            SET @whereClause = @whereClause + ' AND (' + @searchCols + ')';
        END
    END

    -- Xử lý ORDER BY
    DECLARE @OrderByClause NVARCHAR(MAX);
    IF @SortColumn = ''
        SET @OrderByClause = ' ORDER BY (SELECT 1) ';
    ELSE
        SET @OrderByClause = ' ORDER BY ' + QUOTENAME(@SortColumn) + ' ' + @SortDir + ' ';

    -- Lấy danh sách cột
    DECLARE @ColumnList NVARCHAR(MAX);
    SELECT @ColumnList = STUFF((
        SELECT ', ' + QUOTENAME(FieldName)
        FROM SY_FormatFields
        WHERE FormName = @FormName
        FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 2, '');
        
    IF @ColumnList IS NULL OR @ColumnList = ''
        SET @ColumnList = '*';

    -- Sinh câu SQL động query dữ liệu có phân trang
    SET @sql = 'SELECT ' + @ColumnList + ' ' +
               ' FROM ' + QUOTENAME(@TableName) + @whereClause +
               @OrderByClause +
               ' OFFSET @Offset ROWS FETCH NEXT @Limit ROWS ONLY;';
    
    -- Chạy lệnh
    EXEC sp_executesql @sql, N'@Offset INT, @Limit INT, @kw NVARCHAR(200)', @Offset = @Offset, @Limit = @Limit, @kw = @Keyword;
END
GO
