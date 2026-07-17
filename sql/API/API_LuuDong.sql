IF OBJECT_ID('API_LuuDong', 'P') IS NOT NULL
    DROP PROCEDURE API_LuuDong;
GO

CREATE PROCEDURE [dbo].[API_LuuDong]
    @List SYSNAME,
    @Data NVARCHAR(MAX) -- Chuỗi JSON chứa dữ liệu cần lưu
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @TableName SYSNAME;
    DECLARE @PrimaryKey SYSNAME;
    DECLARE @ObjectId INT = OBJECT_ID(@List, 'U');
    DECLARE @QualifiedTable NVARCHAR(517);
    DECLARE @PrimaryKeyCount INT = 0;
    
    -- Phương án 2: Tên Form chính là tên View hoặc Bảng vật lý thật trong CSDL
    SET @TableName = OBJECT_NAME(@ObjectId);
    SET @PrimaryKey = '';

    IF @ObjectId IS NULL
    BEGIN
        SELECT -1 AS code, N'List must be an existing user table: ' + ISNULL(@List, '') AS msg;
        RETURN;
    END

    IF @Data IS NULL OR ISJSON(@Data) <> 1
    BEGIN
        SELECT -1 AS code, N'Invalid JsonData payload.' AS msg;
        RETURN;
    END

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

    IF @PrimaryKey IS NULL OR @PrimaryKey = ''
    BEGIN
        SELECT -1 AS code, N'No primary key found for table/view ' + @TableName AS msg;
        RETURN;
    END

    SELECT @PrimaryKeyCount = COUNT(*)
    FROM sys.indexes i
    INNER JOIN sys.index_columns ic ON ic.object_id = i.object_id AND ic.index_id = i.index_id
    WHERE i.object_id = @ObjectId AND i.is_primary_key = 1;

    IF @PrimaryKeyCount <> 1
    BEGIN
        SELECT -1 AS code, N'Generic save requires exactly one primary-key column.' AS msg;
        RETURN;
    END

    SET @QualifiedTable = QUOTENAME(OBJECT_SCHEMA_NAME(@ObjectId)) + N'.' + QUOTENAME(@TableName);

    BEGIN TRY
        DECLARE @IsEdit INT = ISNULL(CAST(JSON_VALUE(@Data, '$.IsEdit') AS INT), 0);
        DECLARE @SQL NVARCHAR(MAX) = '';
        
        -- Lọc các cột hợp lệ từ JSON (Bỏ qua các cột hệ thống do FE đẩy xuống)
        SELECT [key] COLLATE DATABASE_DEFAULT AS ColumnName, CAST([value] AS NVARCHAR(MAX)) AS ColumnValue
        INTO #JsonData
        FROM OPENJSON(@Data)
        WHERE [key] COLLATE DATABASE_DEFAULT NOT LIKE '\_%' ESCAPE '\' -- Bỏ qua các key hệ thống bắt đầu bằng dấu _ (VD: _SortColumn)
          -- Chỉ lấy những cột thực sự tồn tại trong bảng vật lý!
          -- Chặn đứng tự động các cột rác (IsEdit, UserCreate...) hoặc cột ảo từ Grid UI đẩy xuống
          AND EXISTS (
              SELECT 1 
            FROM sys.columns c
              WHERE c.object_id = @ObjectId
                AND c.name = [key] COLLATE DATABASE_DEFAULT
                AND c.is_identity = 0
                AND c.is_computed = 0
                AND c.system_type_id <> 189
          );
        
        -- TỰ ĐỘNG SINH KHÓA CHÍNH NẾU ĐỂ TRỐNG (INSERT MODE)
        IF @IsEdit = 0 AND COLUMNPROPERTY(@ObjectId, @PrimaryKey, 'IsIdentity') = 0
        BEGIN
            DECLARE @ExistingPKVal NVARCHAR(MAX) = '';
            SELECT @ExistingPKVal = ColumnValue FROM #JsonData WHERE ColumnName = @PrimaryKey;
            
            -- Nếu là Insert nhưng khóa chính đã có giá trị, kiểm tra xem đã tồn tại trong DB chưa để tự động chuyển sang Update
            IF @ExistingPKVal IS NOT NULL AND LTRIM(RTRIM(@ExistingPKVal)) <> ''
            BEGIN
                DECLARE @CheckSQL NVARCHAR(MAX) = 'IF EXISTS (SELECT 1 FROM ' + @QualifiedTable + ' WHERE ' + QUOTENAME(@PrimaryKey) + ' = @PKVal) SET @Exists = 1;';
                DECLARE @Exists BIT = 0;
                EXEC sp_executesql @CheckSQL, N'@PKVal NVARCHAR(MAX), @Exists BIT OUTPUT', @PKVal = @ExistingPKVal, @Exists = @Exists OUTPUT;
                
                IF @Exists = 1
                BEGIN
                    SET @IsEdit = 1;
                END
            END
            
            IF @IsEdit = 0 AND (@ExistingPKVal IS NULL OR LTRIM(RTRIM(@ExistingPKVal)) = '')
            BEGIN
                DECLARE @NextID NVARCHAR(50) = NULL;
                
                -- Only a GUID primary key is generated here. Other key policies belong
                -- to the database (DEFAULT/trigger) or must be supplied by the caller.
                IF EXISTS (
                    SELECT 1 FROM sys.columns
                    WHERE object_id = @ObjectId
                      AND name = @PrimaryKey
                      AND system_type_id = 36
                )
                    SET @NextID = CONVERT(VARCHAR(36), NEWID());
                
                IF @NextID IS NOT NULL
                BEGIN
                    DELETE FROM #JsonData WHERE ColumnName = @PrimaryKey;
                    INSERT INTO #JsonData (ColumnName, ColumnValue)
                    VALUES (@PrimaryKey, @NextID);
                END
            END
        END

        IF @IsEdit = 0 -- THÊM MỚI (INSERT)
        BEGIN
            DECLARE @Cols NVARCHAR(MAX) = '';
            DECLARE @Vals NVARCHAR(MAX) = '';
            
            SELECT 
                @Cols = @Cols + CASE WHEN @Cols = '' THEN '' ELSE ', ' END + QUOTENAME(ColumnName),
                @Vals = @Vals + CASE WHEN @Vals = '' THEN '' ELSE ', ' END + 
                        CASE WHEN ColumnValue IS NULL OR ColumnValue = '' THEN 'NULL' 
                             ELSE 'N''' + REPLACE(ColumnValue, '''', '''''') + '''' 
                        END
            FROM #JsonData
            -- Bỏ qua cột Khóa chính nếu dữ liệu rỗng (Thường là cột IDENTITY tự tăng)
            WHERE ColumnName <> @PrimaryKey OR (ColumnName = @PrimaryKey AND ISNULL(ColumnValue, '') <> '');

            IF @Cols = ''
                SET @SQL = 'INSERT INTO ' + @QualifiedTable + ' DEFAULT VALUES;';
            ELSE
                SET @SQL = 'INSERT INTO ' + @QualifiedTable + ' (' + @Cols + ') VALUES (' + @Vals + ');';
        END
        ELSE -- CẬP NHẬT (UPDATE)
        BEGIN
            DECLARE @UpdateSet NVARCHAR(MAX) = '';
            DECLARE @PKValue NVARCHAR(MAX) = '';
            
            SELECT @PKValue = ColumnValue FROM #JsonData WHERE ColumnName = @PrimaryKey;
            
            IF @PKValue IS NULL OR @PKValue = ''
            BEGIN
                SELECT -1 AS code, N'Không tìm thấy giá trị Khóa chính (' + @PrimaryKey + ') để cập nhật' AS msg;
                RETURN;
            END

            SELECT 
                @UpdateSet = @UpdateSet + CASE WHEN @UpdateSet = '' THEN '' ELSE ', ' END + 
                             QUOTENAME(ColumnName) + ' = ' + 
                             CASE WHEN ColumnValue IS NULL OR ColumnValue = '' THEN 'NULL' 
                                  ELSE 'N''' + REPLACE(ColumnValue, '''', '''''') + '''' 
                             END
            FROM #JsonData
            WHERE ColumnName <> @PrimaryKey;

            IF @UpdateSet = ''
            BEGIN
                SELECT 0 AS code, N'No writable fields supplied.' AS msg;
                RETURN;
            END

            SET @SQL = 'UPDATE ' + @QualifiedTable + ' SET ' + @UpdateSet +
                       ' WHERE ' + QUOTENAME(@PrimaryKey) + ' = N''' + REPLACE(@PKValue, '''', '''''') + ''';';
        END

        -- Chạy câu lệnh sinh ra
        EXEC sp_executesql @SQL;

        SELECT 0 AS code, N'Lưu thành công!' AS msg;
        DROP TABLE #JsonData;
    END TRY
    BEGIN CATCH
        -- Bẫy lỗi và in ra câu lệnh SQL để dễ debug
        DECLARE @ErrMsg NVARCHAR(MAX) = ERROR_MESSAGE();
        SELECT -1 AS code, N'Lỗi SQL: ' + @ErrMsg + N'. [SQL: ' + ISNULL(@SQL, '') + N']' AS msg;
    END CATCH
END
GO
