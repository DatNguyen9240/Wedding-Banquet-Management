USE [QLTiec]
GO

IF OBJECT_ID('dbo.AutoHeal_API_TruyVanDong', 'P') IS NOT NULL
    DROP PROCEDURE dbo.AutoHeal_API_TruyVanDong;
GO

CREATE PROCEDURE dbo.AutoHeal_API_TruyVanDong
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Signature NVARCHAR(MAX) = '';
    DECLARE @DynamicWhere NVARCHAR(MAX) = '';
    DECLARE @ExecParamsDef NVARCHAR(MAX) = N'@Offset INT, @Limit INT, @kw NVARCHAR(200)';
    DECLARE @ExecParamsPass NVARCHAR(MAX) = N'@Offset = @Offset, @Limit = @Limit, @kw = @Keyword';

    -- Dùng con trỏ để duyệt qua tất cả các trường có ShowInFilter = 1 trong toàn bộ hệ thống
    DECLARE @FieldName VARCHAR(100);
    
    DECLARE cur CURSOR FOR 
        SELECT DISTINCT FieldName 
        FROM SY_FormatFields 
        WHERE ShowInFilter = 1 AND FieldName IS NOT NULL AND FieldName <> '';

    OPEN cur;
    FETCH NEXT FROM cur INTO @FieldName;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- 1. Thêm biến vào chữ ký (Signature)
        SET @Signature = @Signature + '@' + @FieldName + ' NVARCHAR(MAX) = NULL, ';

        -- 2. Thêm định nghĩa biến cho sp_executesql
        SET @ExecParamsDef = @ExecParamsDef + ', @' + @FieldName + ' NVARCHAR(MAX)';

        -- 3. Thêm truyền biến cho sp_executesql
        SET @ExecParamsPass = @ExecParamsPass + ', @' + @FieldName + ' = @' + @FieldName;

        -- 4. Thêm logic ghép Where động (Dùng heuristic: Mã/ID thì dùng =, còn lại dùng LIKE)
        DECLARE @Condition NVARCHAR(MAX);
        IF @FieldName LIKE 'Ma%' OR @FieldName LIKE '%ID'
            SET @Condition = ' AND ' + QUOTENAME(@FieldName) + ' = @' + @FieldName;
        ELSE
            SET @Condition = ' AND ' + QUOTENAME(@FieldName) + ' LIKE N''''%'''' + @' + @FieldName + ' + ''''%''''';

        SET @DynamicWhere = @DynamicWhere + '
    IF @' + @FieldName + ' IS NOT NULL AND @' + @FieldName + ' <> ''''
    BEGIN
        -- Cần check xem bảng hiện tại (đang query) CÓ CỘT NÀY KHÔNG trước khi ghép Where
        IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(@TableName) AND name = ''' + @FieldName + ''')
        BEGIN
            SET @whereClause = @whereClause + ''' + @Condition + ''';
        END
    END
        ';

        FETCH NEXT FROM cur INTO @FieldName;
    END

    CLOSE cur;
    DEALLOCATE cur;

    -- =========================================================================================
    -- BẮT ĐẦU TẠO CHUỖI LỆNH ĐỂ GEN RA THẰNG API_TruyVanDong MỚI
    -- =========================================================================================
    DECLARE @SQL NVARCHAR(MAX) = '
ALTER PROCEDURE [dbo].[API_TruyVanDong]
    @FormName VARCHAR(50),
    @Keyword NVARCHAR(200) = '''',
    @UserName VARCHAR(50) = '''',
    @Page INT = 1,
    @Limit INT = 15,
    @SortColumn VARCHAR(50) = '''',
    @SortDir VARCHAR(10) = '''',
    ' + @Signature + '
    @_Healer INT = 0
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

    IF @TableName IS NULL OR @TableName = ''''
    BEGIN
        SELECT -1 AS code, N''Chưa cấu hình TableName cho form '' + @FormName AS msg;
        RETURN;
    END
    
    -- Xử lý an toàn Sort
    IF @SortColumn = '''' SET @SortColumn = ISNULL(@PrimaryKey, '''');
    IF @SortDir = '''' SET @SortDir = ''DESC'';

    -- Tính toán phân trang
    DECLARE @Offset INT = (@Page - 1) * @Limit;

    DECLARE @sql NVARCHAR(MAX);
    DECLARE @whereClause NVARCHAR(MAX) = '' WHERE 1=1'';

    -- 1. TỰ ĐỘNG NỐI CÁC ĐIỀU KIỆN LỌC ĐỘNG TỪ GIAO DIỆN XUỐNG
    ' + @DynamicWhere + '

    -- 2. Thêm điều kiện tìm kiếm Keyword (Dynamic Search siêu cấp cũ)
    IF ISNULL(@Keyword, '''') <> ''''
    BEGIN
        DECLARE @searchCols NVARCHAR(MAX);
        SELECT @searchCols = STUFF((
            SELECT '' OR '' + QUOTENAME(c.name) + '' LIKE ''''%'''' + @kw + ''''%''''''
            FROM sys.columns c
            JOIN sys.objects t ON c.object_id = t.object_id
            JOIN sys.types ty ON c.system_type_id = ty.system_type_id
            WHERE t.name = @TableName 
              AND ty.name IN (''varchar'', ''nvarchar'', ''char'', ''nchar'', ''text'', ''ntext'')
            FOR XML PATH(''''), TYPE).value(''.'', ''NVARCHAR(MAX)''), 1, 4, '''');

        IF @searchCols IS NOT NULL AND @searchCols <> ''''
        BEGIN
            SET @whereClause = @whereClause + '' AND ('' + @searchCols + '')'';
        END
    END

    -- Xử lý ORDER BY
    DECLARE @OrderByClause NVARCHAR(MAX);
    IF @SortColumn = ''''
        SET @OrderByClause = '' ORDER BY (SELECT 1) '';
    ELSE
        SET @OrderByClause = '' ORDER BY '' + QUOTENAME(@SortColumn) + '' '' + @SortDir + '' '';

    -- Lấy danh sách cột
    DECLARE @ColumnList NVARCHAR(MAX);
    SELECT @ColumnList = STUFF((
        SELECT '', '' + QUOTENAME(FieldName)
        FROM SY_FormatFields
        WHERE FormName = @FormName
        FOR XML PATH(''''), TYPE).value(''.'', ''NVARCHAR(MAX)''), 1, 2, '''');
        
    IF @ColumnList IS NULL OR @ColumnList = ''''
        SET @ColumnList = ''*'';

    -- Sinh câu SQL động query dữ liệu có phân trang
    SET @sql = ''SELECT '' + @ColumnList + '' '' +
               '' FROM '' + QUOTENAME(@TableName) + @whereClause +
               @OrderByClause +
               '' OFFSET @Offset ROWS FETCH NEXT @Limit ROWS ONLY;'';
    
    -- Chạy lệnh
    EXEC sp_executesql @sql, N''' + @ExecParamsDef + ''', ' + @ExecParamsPass + ';
END
';

    -- Thực thi chuỗi SQL để đè lại hàm API_TruyVanDong
    EXEC sp_executesql @SQL;

    PRINT N'Đã Auto-Heal thành công API_TruyVanDong! Hãy chạy thử chức năng lọc trên Web.';
END
GO
