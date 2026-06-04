USE [QLTiec]
GO

IF OBJECT_ID('API_XoaDong', 'P') IS NOT NULL
    DROP PROCEDURE API_XoaDong;
GO

CREATE PROCEDURE [dbo].[API_XoaDong]
    @List VARCHAR(50),
    @Ids NVARCHAR(MAX), -- Chuỗi danh sách các ID cần xoá, ví dụ: 'ID1,ID2,ID3'
    @UserName VARCHAR(50) = 'System'
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
    WHERE FormID = @List;

    IF @TableName IS NULL OR @TableName = ''
    BEGIN
        SELECT -1 AS code, N'Chưa cấu hình TableName cho form ' + @List AS msg;
        RETURN;
    END

    IF @PrimaryKey IS NULL OR @PrimaryKey = ''
    BEGIN
        SELECT -1 AS code, N'Chưa cấu hình PrimaryKey cho form ' + @List AS msg;
        RETURN;
    END

    -- ==========================================================
    -- 1. BẢO VỆ CHẶT VÀ THỰC HIỆN SOFT DELETE CHO HỢP ĐỒNG (tbmk_Hopdong)
    -- ==========================================================
    IF LOWER(@TableName) = 'tbmk_hopdong'
    BEGIN
        -- Kiểm tra xem có hợp đồng nào đang ở trạng thái "Đã Ký" hoặc "Đã Quyết Toán" hoặc "Chốt cứng" không
        IF EXISTS (
            SELECT 1 
            FROM tbmk_Hopdong
            WHERE Sohopdong IN (SELECT LTRIM(RTRIM(value)) FROM string_split(@Ids, ','))
              AND (Status IN ('SIGNED', 'COMPLETED') OR IsKetthuc = 1 OR IsHuy = 1)
        )
        BEGIN
            SELECT -1 AS code, N'Lỗi: Tuyệt đối không được xóa hợp đồng đã chốt (Đã ký hoặc Quyết toán). Hệ thống yêu cầu lưu trữ chứng từ pháp lý!' AS msg;
            RETURN;
        END

        BEGIN TRY
            UPDATE tbmk_Hopdong
            SET IsDeleted = 1,
                DeletedAt = GETDATE(),
                DeletedBy = ISNULL(@UserName, 'System')
            WHERE Sohopdong IN (SELECT LTRIM(RTRIM(value)) FROM string_split(@Ids, ','));

            DECLARE @RowsHD INT = @@ROWCOUNT;
            IF @RowsHD > 0
                SELECT 0 AS code, N'Xóa thành công (Soft Delete) ' + CAST(@RowsHD AS VARCHAR) + N' hợp đồng.' AS msg;
            ELSE
                SELECT -1 AS code, N'Không tìm thấy hợp đồng phù hợp để xóa.' AS msg;
            RETURN;
        END TRY
        BEGIN CATCH
            SELECT -1 AS code, N'Lỗi xóa hợp đồng: ' + ERROR_MESSAGE() AS msg;
            RETURN;
        END CATCH
    END

    -- ==========================================================
    -- 2. BẢO VỆ CHẶT VÀ THỰC HIỆN SOFT DELETE CHO PHIẾU CỌC (tbmk_Biennhancoccho)
    -- ==========================================================
    IF LOWER(@TableName) = 'tbmk_biennhancoccho'
    BEGIN
        -- Kiểm tra xem có phiếu cọc nào đã chốt hoặc đã lên Hợp đồng không
        IF EXISTS (
            SELECT 1 
            FROM tbmk_Biennhancoccho
            WHERE DocumentID IN (SELECT LTRIM(RTRIM(value)) FROM string_split(@Ids, ','))
              AND (Status IN ('SIGNED', 'COMPLETED') OR IsKetthuc = 1 OR IsHuy = 1)
        )
        BEGIN
            SELECT -1 AS code, N'Lỗi: Tuyệt đối không được xóa phiếu cọc đã chốt hoặc đã lên Hợp đồng!' AS msg;
            RETURN;
        END

        BEGIN TRY
            UPDATE tbmk_Biennhancoccho
            SET IsDeleted = 1,
                DeletedAt = GETDATE(),
                DeletedBy = ISNULL(@UserName, 'System')
            WHERE DocumentID IN (SELECT LTRIM(RTRIM(value)) FROM string_split(@Ids, ','));

            DECLARE @RowsPC INT = @@ROWCOUNT;
            IF @RowsPC > 0
                SELECT 0 AS code, N'Xóa thành công (Soft Delete) ' + CAST(@RowsPC AS VARCHAR) + N' phiếu cọc.' AS msg;
            ELSE
                SELECT -1 AS code, N'Không tìm thấy phiếu cọc phù hợp để xóa.' AS msg;
            RETURN;
        END TRY
        BEGIN CATCH
            SELECT -1 AS code, N'Lỗi xóa phiếu cọc: ' + ERROR_MESSAGE() AS msg;
            RETURN;
        END CATCH
    END

    -- ==========================================================
    -- 3. BẢO VỆ CHẶT VÀ THỰC HIỆN SOFT DELETE CHO PHIẾU THU (tbPhieuthu / tbmk_Phieuthu)
    -- ==========================================================
    IF LOWER(@TableName) IN ('tbphieuthu', 'tbmk_phieuthu')
    BEGIN
        -- Sử dụng SQL động để kiểm tra nhằm tránh lỗi biên dịch tĩnh nếu cột Status chưa được tạo đầy đủ
        DECLARE @CheckStatusSQL NVARCHAR(MAX) = 
            N'IF EXISTS (SELECT 1 FROM ' + QUOTENAME(@TableName) + 
            N' WHERE DocumentID IN (SELECT LTRIM(RTRIM(value)) FROM string_split(@Ids, '','')) AND Status IN (''SIGNED'', ''COMPLETED''))
              SET @HasLocked = 1;';
              
        DECLARE @HasLocked INT = 0;
        
        BEGIN TRY
            EXEC sp_executesql @CheckStatusSQL, N'@Ids NVARCHAR(MAX), @HasLocked INT OUTPUT', @Ids = @Ids, @HasLocked = @HasLocked OUTPUT;
        END TRY
        BEGIN CATCH
            -- Nếu chưa có cột Status, bỏ qua bước kiểm tra Status khóa cứng
            SET @HasLocked = 0;
        END CATCH

        IF @HasLocked = 1
        BEGIN
            SELECT -1 AS code, N'Lỗi: Tuyệt đối không được xóa phiếu thu đã thanh toán hoặc đã chốt!' AS msg;
            RETURN;
        END

        BEGIN TRY
            -- Thực hiện soft delete sử dụng DocumentID
            DECLARE @UpdateSQL NVARCHAR(MAX) = 
                N'UPDATE ' + QUOTENAME(@TableName) + 
                N' SET IsDeleted = 1, DeletedAt = GETDATE(), DeletedBy = @User
                  WHERE DocumentID IN (SELECT LTRIM(RTRIM(value)) FROM string_split(@Ids, '',''))';
                  
            EXEC sp_executesql @UpdateSQL, N'@Ids NVARCHAR(MAX), @User VARCHAR(50)', @Ids = @Ids, @User = @UserName;

            DECLARE @RowsPT INT = @@ROWCOUNT;
            IF @RowsPT > 0
                SELECT 0 AS code, N'Xóa thành công (Soft Delete) ' + CAST(@RowsPT AS VARCHAR) + N' phiếu thu/quyết toán.' AS msg;
            ELSE
                SELECT -1 AS code, N'Không tìm thấy phiếu thu/quyết toán phù hợp để xóa.' AS msg;
            RETURN;
        END TRY
        BEGIN CATCH
            SELECT -1 AS code, N'Lỗi xóa phiếu thu: ' + ERROR_MESSAGE() AS msg;
            RETURN;
        END CATCH
    END

    -- ==========================================================
    -- 4. PHƯƠNG ÁN DỰ PHÒNG: XÓA CỨNG (DELETE FROM) CHO CÁC BẢNG HỆ THỐNG/DANH MỤC KHÁC
    -- ==========================================================
    BEGIN TRY
        -- Sinh câu SQL xoá động sử dụng IN (chỉ dành cho SQL Server >= 2016)
        DECLARE @sql NVARCHAR(MAX) = 
            'DELETE FROM ' + QUOTENAME(@TableName) + 
            ' WHERE ' + QUOTENAME(@PrimaryKey) + ' IN (SELECT value FROM string_split(@DeleteIds, '',''))';
            
        -- Chạy lệnh
        EXEC sp_executesql @sql, N'@DeleteIds NVARCHAR(MAX)', @DeleteIds = @Ids;
        
        DECLARE @RowsAffected INT = @@ROWCOUNT;
        
        IF @RowsAffected > 0
            SELECT 0 AS code, N'Xóa thành công ' + CAST(@RowsAffected AS VARCHAR) + N' dòng khỏi bảng ' + @TableName AS msg;
        ELSE
            SELECT -1 AS code, N'Không tìm thấy dữ liệu (ID: ' + @Ids + N') để xóa trong bảng ' + @TableName AS msg;
    END TRY
    BEGIN CATCH
        SELECT -1 AS code, N'Lỗi xóa dữ liệu: ' + ERROR_MESSAGE() AS msg;
    END CATCH
END
GO
