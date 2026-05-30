IF OBJECT_ID('API_LuuDong', 'P') IS NOT NULL
    DROP PROCEDURE API_LuuDong;
GO

CREATE PROCEDURE [dbo].[API_LuuDong]
    @FormName VARCHAR(50),
    @Data NVARCHAR(MAX) -- Chuỗi JSON chứa dữ liệu cần lưu
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @TableName VARCHAR(100);
    DECLARE @PrimaryKey VARCHAR(100);
    
    -- Lấy thông tin Bảng và Khóa chính
    -- Nâng cấp: Dùng SaveTableName (Bảng gốc) để GHI, nếu không có thì xài TableName (View)
    SELECT 
        @TableName = COALESCE(SaveTableName, TableName),
        @PrimaryKey = PrimaryKey
    FROM SY_FrmLstTbl 
    WHERE FormID = @FormName;

    IF @TableName IS NULL OR @TableName = ''
    BEGIN
        SELECT -1 AS code, N'Chưa cấu hình TableName cho form ' + @FormName AS msg;
        RETURN;
    END

    BEGIN TRY
        DECLARE @IsEdit INT = ISNULL(CAST(JSON_VALUE(@Data, '$.IsEdit') AS INT), 0);
        DECLARE @SQL NVARCHAR(MAX) = '';
        
        -- Lọc các cột hợp lệ từ JSON (Bỏ qua các cột hệ thống do FE đẩy xuống)
        SELECT [key] COLLATE DATABASE_DEFAULT AS ColumnName, CAST([value] AS NVARCHAR(MAX)) AS ColumnValue
        INTO #JsonData
        FROM OPENJSON(@Data)
        WHERE [key] COLLATE DATABASE_DEFAULT NOT IN ('IsEdit', 'UserName', 'UserCreate', 'List', 'Func', 'Keyword', 'Page', 'Limit', 'JsonData')
          AND [key] COLLATE DATABASE_DEFAULT NOT LIKE '\_%' ESCAPE '\' -- Bỏ qua các key hệ thống (VD: _SortColumn)
          -- BƯỚC ĐỘT PHÁ 2: Chỉ lấy những cột thực sự tồn tại trong bảng vật lý!
          -- Giúp loại bỏ tự động các cột tính toán (derived) như SoHopDong, SoLanThamQuan từ UI đẩy xuống
          AND EXISTS (
              SELECT 1 
              FROM sys.columns 
              WHERE object_id = OBJECT_ID(@TableName) 
                AND name = [key] COLLATE DATABASE_DEFAULT
          );
        
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
