IF OBJECT_ID('API_LuuDong', 'P') IS NOT NULL
    DROP PROCEDURE API_LuuDong;
GO

CREATE PROCEDURE [dbo].[API_LuuDong]
    @List VARCHAR(50),
    @Data NVARCHAR(MAX) -- Chuỗi JSON chứa dữ liệu cần lưu
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @TableName VARCHAR(100);
    DECLARE @PrimaryKey VARCHAR(100);
    
    -- Phương án 2: Tên Form chính là tên View hoặc Bảng vật lý thật trong CSDL
    SET @TableName = @List;
    SET @PrimaryKey = '';

    -- Tìm Primary Key từ hệ thống nếu chưa map tĩnh
    IF @PrimaryKey IS NULL OR @PrimaryKey = ''
    BEGIN
        SELECT TOP 1 @PrimaryKey = c.name
        FROM sys.indexes i
        JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
        JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
        WHERE i.is_primary_key = 1
          AND i.object_id = OBJECT_ID(@TableName);
    END

    IF @TableName IS NULL OR @TableName = ''
    BEGIN
        SELECT -1 AS code, N'Chưa cấu hình TableName cho form ' + @List AS msg;
        RETURN;
    END

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
              FROM sys.columns 
              WHERE object_id = OBJECT_ID(@TableName) 
                AND name = [key] COLLATE DATABASE_DEFAULT
          );
        
        -- TỰ ĐỘNG SINH KHÓA CHÍNH NẾU ĐỂ TRỐNG (INSERT MODE)
        IF @IsEdit = 0 AND COLUMNPROPERTY(OBJECT_ID(@TableName), @PrimaryKey, 'IsIdentity') = 0
        BEGIN
            DECLARE @ExistingPKVal NVARCHAR(MAX) = '';
            SELECT @ExistingPKVal = ColumnValue FROM #JsonData WHERE ColumnName = @PrimaryKey;
            
            -- Nếu là Insert nhưng khóa chính đã có giá trị, kiểm tra xem đã tồn tại trong DB chưa để tự động chuyển sang Update
            IF @ExistingPKVal IS NOT NULL AND LTRIM(RTRIM(@ExistingPKVal)) <> ''
            BEGIN
                DECLARE @CheckSQL NVARCHAR(MAX) = 'IF EXISTS (SELECT 1 FROM ' + QUOTENAME(@TableName) + ' WHERE ' + QUOTENAME(@PrimaryKey) + ' = @PKVal) SET @Exists = 1;';
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
                
                IF @TableName = 'dmSanhtiec'
                BEGIN
                    SELECT @NextID = 'ST' + RIGHT('000' + CAST(ISNULL(MAX(TRY_CAST(SUBSTRING(Sanhtiecid, 3, 10) AS INT)), 0) + 1 AS VARCHAR), 3)
                    FROM dmSanhtiec
                    WHERE Sanhtiecid LIKE 'ST%';
                END
                ELSE IF @TableName = 'dmThoigian'
                BEGIN
                    SELECT @NextID = 'CA' + RIGHT('00' + CAST(ISNULL(MAX(TRY_CAST(SUBSTRING(Thoigianid, 3, 10) AS INT)), 0) + 1 AS VARCHAR), 2)
                    FROM dmThoigian
                    WHERE Thoigianid LIKE 'CA%';
                END
                ELSE IF @TableName = 'tbmk_Hopdong'
                BEGIN
                    SET @NextID = 'HD' + FORMAT(GETDATE(), 'yyMMddHHmmss');
                END
                ELSE IF @TableName = 'dmkhachhang'
                BEGIN
                    SET @NextID = 'KH' + FORMAT(GETDATE(), 'yyMMddHHmmss');
                END
                ELSE IF @TableName = 'dmLoaihinhtiec'
                BEGIN
                    SELECT @NextID = 'BLT' + RIGHT('000000' + CAST(ISNULL(MAX(TRY_CAST(SUBSTRING(Loaitiecid, 4, 10) AS INT)), 0) + 1 AS VARCHAR), 6)
                    FROM dmLoaihinhtiec
                    WHERE Loaitiecid LIKE 'BLT%';
                END
                ELSE
                BEGIN
                    SET @NextID = NEWID();
                END
                
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

            SET @SQL = 'INSERT INTO ' + QUOTENAME(@TableName) + ' (' + @Cols + ') VALUES (' + @Vals + ');';
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

            SET @SQL = 'UPDATE ' + QUOTENAME(@TableName) + ' SET ' + @UpdateSet + 
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
