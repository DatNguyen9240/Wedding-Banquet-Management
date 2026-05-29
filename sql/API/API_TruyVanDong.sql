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
    -- MAGIC: RÃ JSON VÀ XỬ LÝ TOÁN TỬ NÂNG CAO THEO CHUẨN API.MD ($gt, $in, $bt...)
    -- =========================================================================
    IF ISNULL(@FilterJSON, '') <> ''
    BEGIN
        DECLARE @Key NVARCHAR(MAX), @Val NVARCHAR(MAX);
        DECLARE @ColName NVARCHAR(MAX), @Operator NVARCHAR(50);
        
        DECLARE cur CURSOR FOR 
        SELECT [key], CAST([value] AS NVARCHAR(MAX))
        FROM OPENJSON(@FilterJSON)
        WHERE CAST([value] AS NVARCHAR(MAX)) <> '' 
          AND [key] NOT LIKE '\_%' ESCAPE '\' -- Bỏ qua các biến hệ thống có dấu _
          AND [key] NOT IN ('Page', 'Limit', 'SortColumn', 'SortDir', 'Keyword'); -- Bỏ qua các biến phân trang cứng
          
        OPEN cur;
        FETCH NEXT FROM cur INTO @Key, @Val;
        
        WHILE @@FETCH_STATUS = 0
        BEGIN
            -- Phân tách Column Name và Operator từ Key (VD: DocumentDate$gte -> ColName, gte)
            DECLARE @DollarPos INT = CHARINDEX('$', @Key);
            IF @DollarPos > 0
            BEGIN
                SET @ColName = SUBSTRING(@Key, 1, @DollarPos - 1);
                SET @Operator = SUBSTRING(@Key, @DollarPos + 1, LEN(@Key) - @DollarPos);
            END
            ELSE
            BEGIN
                SET @ColName = @Key;
                SET @Operator = 'default';
            END
            
            SET @Val = REPLACE(@Val, '''', ''''''); -- Chống SQL Injection
            DECLARE @Condition NVARCHAR(MAX) = '';
            DECLARE @LogicOp NVARCHAR(10) = ' AND ';
            
            IF @Operator = 'gt'  SET @Condition = ' > N''' + @Val + '''';
            ELSE IF @Operator = 'gte' SET @Condition = ' >= N''' + @Val + '''';
            ELSE IF @Operator = 'lt'  SET @Condition = ' < N''' + @Val + '''';
            ELSE IF @Operator = 'lte' SET @Condition = ' <= N''' + @Val + '''';
            ELSE IF @Operator = 'eq'  SET @Condition = ' = N''' + @Val + '''';
            ELSE IF @Operator = 'ne'  SET @Condition = ' <> N''' + @Val + '''';
            ELSE IF @Operator = 'lk'  SET @Condition = ' LIKE N''%' + @Val + '%''';
            ELSE IF @Operator = 'or'  
            BEGIN
                SET @LogicOp = ' OR ';
                SET @Condition = ' = N''' + @Val + '''';
            END
            ELSE IF @Operator = 'bt'
            BEGIN
                -- $bt: So sánh trong khoảng (Val1;Val2)
                DECLARE @SemiPos INT = CHARINDEX(';', @Val);
                IF @SemiPos > 0
                    SET @Condition = ' BETWEEN N''' + SUBSTRING(@Val, 1, @SemiPos - 1) + ''' AND N''' + SUBSTRING(@Val, @SemiPos + 1, LEN(@Val)) + '''';
                ELSE 
                    SET @Condition = ' = N''' + @Val + '''';
            END
            ELSE IF @Operator = 'in'
            BEGIN
                -- $in: Mảng giá trị A;B;C
                DECLARE @InList NVARCHAR(MAX) = REPLACE(@Val, ';', ''',''');
                SET @Condition = ' IN (N''' + @InList + ''')';
            END
            ELSE IF @Operator = 'ud'
            BEGIN
                -- $ud: User define (ví dụ: is null)
                SET @Condition = ' ' + @Val;
            END
            ELSE
            BEGIN
                -- Default behavior
                IF @ColName LIKE 'Ma%' OR @ColName LIKE '%ID'
                    SET @Condition = ' = N''' + @Val + '''';
                ELSE
                    SET @Condition = ' LIKE N''%' + @Val + '%''';
            END
            
            SET @whereClause = @whereClause + @LogicOp + QUOTENAME(@ColName) + @Condition;
            
            FETCH NEXT FROM cur INTO @Key, @Val;
        END
        
        CLOSE cur;
        DEALLOCATE cur;
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

    -- Sinh câu SQL động (Trả toàn bộ dữ liệu để C# Backend tự phân trang)
    SET @sql = 'SELECT ' + @ColumnList + ' ' +
               ' FROM ' + QUOTENAME(@TableName) + @whereClause +
               @OrderByClause + ';';
    
    -- Chạy lệnh
    EXEC sp_executesql @sql, N'@Offset INT, @Limit INT, @kw NVARCHAR(200)', @Offset = @Offset, @Limit = @Limit, @kw = @Keyword;
END
GO
