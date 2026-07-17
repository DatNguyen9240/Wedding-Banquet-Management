USE [QLTiec]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =========================================================================
-- [API_Gateway_Router] - TRẠM ĐỊNH TUYẾN TRUNG TÂM (DYNAMIC AUTO-MAPPING GATEWAY)
-- 1. Tìm StoreName trong WA_API dựa vào @List và @Func.
-- 2. Tự động truy vấn danh sách tham số của Stored Procedure đích qua sys.parameters.
-- 3. Tự động trích xuất và ánh xạ các tham số từ:
--    - Payload JSON (@JsonData) gửi từ Frontend (không phân biệt chữ hoa/thường).
--    - Thông tin hệ thống / Context (@UserName, @BranchID, @UserGroup, @EmployeeID...).
--    - Tham số chung của yêu cầu (@Keyword, @Page, @Limit, @SortColumn...).
-- 4. Thực thi thủ tục mục tiêu mà không cần cấu hình danh sách tham số tĩnh.
-- =========================================================================
CREATE OR ALTER PROCEDURE [dbo].[API_Gateway_Router]
    @List VARCHAR(50),               -- Ví dụ: 'Customer', 'frmKhachHang'
    @Func VARCHAR(50) = 'View',      -- Ví dụ: 'View' (hoặc 'List'), 'Save', 'Delete'
    @UserName VARCHAR(50) = '',      -- Tên tài khoản đang đăng nhập
    @Keyword NVARCHAR(200) = '',     -- Tìm kiếm chung toàn cục
    @Page INT = 1,
    @Limit INT = 20,
    @JsonData NVARCHAR(MAX) = '',    -- Dữ liệu payload JSON từ Frontend
    @SortColumn VARCHAR(50) = '',    -- Cột cần sắp xếp
    @SortDir VARCHAR(10) = ''        -- Hướng sắp xếp (ASC/DESC)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @StoreName NVARCHAR(200);
    
    -- 1. Tra cứu Stored Procedure đích từ bảng cấu hình WA_API
    SELECT @StoreName = LTRIM(RTRIM([SQL]))
    FROM dbo.WA_API
    WHERE list = @List AND func = @Func;

    -- Kiểm tra nếu API chưa được cấu hình định tuyến
    IF @StoreName IS NULL OR @StoreName = ''
    BEGIN
        SELECT -1 AS code, N'Lỗi: Chưa định nghĩa API [' + @List + '] - Hành động: [' + @Func + '] trong bảng WA_API!' AS msg;
        RETURN;
    END

    -- 2. Lấy Context hệ thống bảo mật dựa trên UserName
    DECLARE @UserGroup VARCHAR(50) = '';
    DECLARE @BranchID VARCHAR(50) = '';
    DECLARE @ManagerID VARCHAR(50) = '';
    DECLARE @EmployeeID VARCHAR(50) = '';
    
    IF ISNULL(@UserName, '') <> ''
    BEGIN
        SELECT 
            @UserGroup = UserGroupID, 
            @BranchID = BranchID,
            @ManagerID = ManagerID,
            @EmployeeID = EmployeeID
        FROM dbo.SY_User 
        WHERE UserName = @UserName;
    END

    -- 3. Nạp dữ liệu JSON vào bảng tạm để ánh xạ Case-Insensitive (Không phân biệt chữ hoa/thường)
    DECLARE @JsonTable TABLE (
        JsonKey NVARCHAR(100) COLLATE DATABASE_DEFAULT,
        JsonValue NVARCHAR(MAX) COLLATE DATABASE_DEFAULT
    );
    
    IF ISNULL(@JsonData, '') <> '' AND ISJSON(@JsonData) = 1
    BEGIN
        INSERT INTO @JsonTable (JsonKey, JsonValue)
        SELECT [key], [value]
        FROM OPENJSON(@JsonData);
    END

    -- 4. Đọc danh sách các tham số mà Stored Procedure đích mong muốn nhận
    DECLARE @ParaList NVARCHAR(MAX) = '';
    
    DECLARE @ParamName NVARCHAR(100);
    DECLARE @KeyName NVARCHAR(100);
    DECLARE @DataType NVARCHAR(50);
    
    DECLARE param_cursor CURSOR LOCAL FORWARD_ONLY STATIC READ_ONLY FOR
    SELECT 
        p.name,
        SUBSTRING(p.name, 2, LEN(p.name)), -- Cắt bỏ tiền tố '@'
        t.name
    FROM sys.parameters p
    JOIN sys.types t ON p.user_type_id = t.user_type_id
    WHERE p.object_id = OBJECT_ID(@StoreName)
      AND p.is_output = 0; -- Chỉ map tham số Input
    
    OPEN param_cursor;
    FETCH NEXT FROM param_cursor INTO @ParamName, @KeyName, @DataType;
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        DECLARE @Val NVARCHAR(MAX) = NULL;
        DECLARE @IsMapped BIT = 0;
        
        -- A. Ưu tiên 1: Lấy từ JSON data (Case-Insensitive)
        SELECT TOP 1 @Val = JsonValue, @IsMapped = 1
        FROM @JsonTable
        WHERE LOWER(JsonKey) = LOWER(@KeyName);
        
        -- B. Ưu tiên 2: Nếu JSON không có, kiểm tra Context / Biến Hệ Thống
        IF @IsMapped = 0
        BEGIN
            IF LOWER(@KeyName) IN ('username', 'user', 'usercreate', 'userupdate') 
                BEGIN SET @Val = @UserName; SET @IsMapped = 1; END
            ELSE IF LOWER(@KeyName) IN ('usergroup', 'usergroupid', 'nhomnguoidangthaotac') 
                BEGIN SET @Val = @UserGroup; SET @IsMapped = 1; END
            ELSE IF LOWER(@KeyName) = 'branchid' 
                BEGIN SET @Val = @BranchID; SET @IsMapped = 1; END
            ELSE IF LOWER(@KeyName) = 'managerid' 
                BEGIN SET @Val = @ManagerID; SET @IsMapped = 1; END
            ELSE IF LOWER(@KeyName) = 'employeeid' 
                BEGIN SET @Val = @EmployeeID; SET @IsMapped = 1; END
            ELSE IF LOWER(@KeyName) = 'keyword' 
                BEGIN SET @Val = @Keyword; SET @IsMapped = 1; END
            ELSE IF LOWER(@KeyName) = 'page' 
                BEGIN SET @Val = CAST(@Page AS NVARCHAR(50)); SET @IsMapped = 1; END
            ELSE IF LOWER(@KeyName) = 'limit' 
                BEGIN SET @Val = CAST(@Limit AS NVARCHAR(50)); SET @IsMapped = 1; END
            ELSE IF LOWER(@KeyName) = 'sortcolumn' 
                BEGIN SET @Val = @SortColumn; SET @IsMapped = 1; END
            ELSE IF LOWER(@KeyName) = 'sortdir' 
                BEGIN SET @Val = @SortDir; SET @IsMapped = 1; END
            ELSE IF LOWER(@KeyName) = 'list' 
                BEGIN SET @Val = @List; SET @IsMapped = 1; END
            ELSE IF LOWER(@KeyName) = 'func' 
                BEGIN SET @Val = @Func; SET @IsMapped = 1; END
            -- Generic CRUD procedures historically use either @JsonData or @Data.
            -- Both must receive the JSON payload posted by the frontend.
            ELSE IF LOWER(@KeyName) IN ('jsondata', 'data')
                BEGIN SET @Val = @JsonData; SET @IsMapped = 1; END
        END
        
        -- C. Ráp giá trị vào câu lệnh SQL dạng Literal
        IF @IsMapped = 1 AND @Val IS NOT NULL
        BEGIN
            DECLARE @Literal NVARCHAR(MAX) = '';
            
            IF @DataType IN ('varchar', 'nvarchar', 'char', 'nchar', 'text', 'ntext')
            BEGIN
                SET @Literal = 'N''' + REPLACE(@Val, '''', '''''') + '''';
            END
            ELSE IF @DataType IN ('date', 'datetime', 'datetime2', 'smalldatetime', 'time')
            BEGIN
                -- Kiểm tra nếu là chuỗi rỗng thì truyền NULL cho cột kiểu ngày giờ
                IF LTRIM(RTRIM(@Val)) = ''
                    SET @Literal = 'NULL';
                ELSE
                    SET @Literal = '''' + REPLACE(@Val, '''', '''''') + '''';
            END
            ELSE -- Kiểu số (int, decimal, float...) hoặc Boolean (bit)
            BEGIN
                IF LTRIM(RTRIM(@Val)) = ''
                    SET @Literal = 'NULL';
                ELSE
                    SET @Literal = @Val;
            END
            
            -- Ghi nhận tham số cần truyền
            SET @ParaList = @ParaList + CASE WHEN @ParaList = '' THEN '' ELSE ', ' END 
                            + @ParamName + ' = ' + @Literal;
        END
        
        FETCH NEXT FROM param_cursor INTO @ParamName, @KeyName, @DataType;
    END
    
    CLOSE param_cursor;
    DEALLOCATE param_cursor;

    -- 5. Thực thi Stored Procedure bằng Dynamic SQL
    DECLARE @FinalSQL NVARCHAR(MAX);
    IF @ParaList <> ''
        SET @FinalSQL = 'EXEC ' + QUOTENAME(@StoreName) + ' ' + @ParaList;
    ELSE
        SET @FinalSQL = 'EXEC ' + QUOTENAME(@StoreName);

    -- PRINT @FinalSQL; -- Có thể uncomment dòng này để debug câu lệnh chạy thực tế

    BEGIN TRY
        EXEC(@FinalSQL);
    END TRY
    BEGIN CATCH
        SELECT -1 AS code, ERROR_MESSAGE() + N' [SQL: ' + ISNULL(@FinalSQL, '') + N']' AS msg, ERROR_LINE() AS error_line;
    END CATCH
END
GO
