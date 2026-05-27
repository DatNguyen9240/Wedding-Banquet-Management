USE [QLTiec]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =========================================================================
-- [API_Gateway_Router] - TRẠM ĐỊNH TUYẾN TRUNG TÂM
-- Đọc cấu hình từ bảng WA_API để gọi các thủ tục tương ứng.
-- =========================================================================
CREATE OR ALTER PROCEDURE [dbo].[API_Gateway_Router]
    @List VARCHAR(50),               -- Ví dụ: 'Customer', 'ComboNhanVien'
    @Func VARCHAR(50) = 'View',      -- Ví dụ: 'View', 'Save', 'Delete'
    @UserName VARCHAR(50) = '',      -- Tên user lấy từ Frontend/Session
    @Keyword NVARCHAR(200) = '',     -- Tham số tìm kiếm chung
    @Page INT = 1,
    @Limit INT = 20,
    @JsonData NVARCHAR(MAX) = ''     -- Dùng cho các hàm Save/Update có body phức tạp
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @TargetStore NVARCHAR(200);
    DECLARE @ParaTemplate NVARCHAR(500);
    
    -- 1. Tra cứu cấu hình từ bảng WA_API
    SELECT @TargetStore = LTRIM(RTRIM([SQL])), 
           @ParaTemplate = LTRIM(RTRIM(ISNULL(Para, '')))
    FROM WA_API
    WHERE list = @List AND func = @Func;

    -- Kiểm tra nếu API chưa được định nghĩa
    IF @TargetStore IS NULL OR @TargetStore = ''
    BEGIN
        SELECT -1 AS code, N'Lỗi: Chưa định nghĩa API [' + @List + '] - Hành động: [' + @Func + '] trong bảng WA_API!' AS msg;
        RETURN;
    END

    -- 2. Lấy Context của hệ thống dựa theo UserName (Phục vụ Phân quyền RLS)
    DECLARE @UserGroup VARCHAR(50) = '';
    DECLARE @BranchID VARCHAR(50) = '';
    DECLARE @ManagerID VARCHAR(50) = '';
    DECLARE @EmployeeID VARCHAR(50) = '';
    
    IF ISNULL(@UserName, '') <> ''
    BEGIN
        -- Móc toàn bộ thông tin ngữ cảnh từ bảng tài khoản cốt lõi (SY_User)
        SELECT 
            @UserGroup = UserGroupID, 
            @BranchID = BranchID,
            @ManagerID = ManagerID,
            @EmployeeID = EmployeeID
        FROM SY_User 
        WHERE UserName = @UserName;
    END

    -- 3. Xử lý Đắp tham số (Replace Placeholders)
    -- CHÚ Ý CẤU HÌNH TRONG DB: Nếu biến là chuỗi, phải có dấu nháy đơn bao quanh. Ví dụ: '{User}', N'{Keyword}', {Page}
    
    -- 3.1. Thay thế các biến Server-side Context (Bảo mật tuyệt đối, Frontend không can thiệp được)
    SET @ParaTemplate = REPLACE(@ParaTemplate, '{User}', ISNULL(@UserName, ''));
    SET @ParaTemplate = REPLACE(@ParaTemplate, '{UserGroup}', ISNULL(@UserGroup, ''));
    SET @ParaTemplate = REPLACE(@ParaTemplate, '{BranchID}', ISNULL(@BranchID, ''));
    SET @ParaTemplate = REPLACE(@ParaTemplate, '{ManagerID}', ISNULL(@ManagerID, ''));
    SET @ParaTemplate = REPLACE(@ParaTemplate, '{EmployeeID}', ISNULL(@EmployeeID, ''));
    
    -- 3.2. Thay thế các biến Request từ Frontend
    -- Replace {Keyword} an toàn, bọc gấp đôi nháy đơn để tránh lỗi SQL Injection (nếu có nháy đơn trong chữ)
    SET @ParaTemplate = REPLACE(@ParaTemplate, '{Keyword}', REPLACE(ISNULL(@Keyword, ''), '''', ''''''));
    SET @ParaTemplate = REPLACE(@ParaTemplate, '{Page}', CAST(@Page AS VARCHAR));
    SET @ParaTemplate = REPLACE(@ParaTemplate, '{Limit}', CAST(@Limit AS VARCHAR));
    
    -- Replace JSON Data (Dành cho chức năng Lưu)
    SET @ParaTemplate = REPLACE(@ParaTemplate, '{JsonData}', REPLACE(ISNULL(@JsonData, ''), '''', ''''''));

    -- 4. Chạy câu lệnh hoàn chỉnh
    DECLARE @FinalSQL NVARCHAR(MAX);
    
    -- Ráp lệnh EXEC
    IF @ParaTemplate <> ''
        SET @FinalSQL = 'EXEC ' + QUOTENAME(@TargetStore) + ' ' + @ParaTemplate;
    ELSE
        SET @FinalSQL = 'EXEC ' + QUOTENAME(@TargetStore);

    -- Dòng này dùng để debug khi anh test bằng SQL Management Studio (SSMS)
    -- PRINT N'Đang thực thi lệnh: ' + @FinalSQL;

    -- 5. Thực thi lệnh
    BEGIN TRY
        EXEC(@FinalSQL);
    END TRY
    BEGIN CATCH
        -- Bắt lỗi thông minh trả về Frontend
        SELECT -1 AS code, ERROR_MESSAGE() AS msg, ERROR_LINE() AS error_line;
    END CATCH
END
GO
