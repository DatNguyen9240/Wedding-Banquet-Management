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
    
    -- Ánh xạ động từ FormID sang Bảng vật lý
    SET @TableName = CASE @List
        WHEN 'frmKhachHang' THEN 'dmkhachhang'
        WHEN 'frmKhachThamQuan' THEN 'tbmk_Khachthamquan'
        WHEN 'frmTaiKhoan' THEN 'SY_User'
        WHEN 'frmQuyetToan' THEN 'tbmk_Quyettoan'
        WHEN 'dmSanhtiec' THEN 'dmSanhtiec'
        WHEN 'dmThoigian' THEN 'dmThoigian'
        WHEN 'API_DanhSachCaLam' THEN 'dmThoigian'
        WHEN 'frmFormBuilder' THEN 'SY_FmtFldTbl'
        WHEN 'Tiec_Documents' THEN 'Tiec_Documents'
        WHEN 'SY_Period' THEN 'SY_Period'
        WHEN 'frmThayDoiBoSung' THEN 'tbmk_Thaydoi'
        WHEN 'frmPhuLucHopDong' THEN 'tbmk_Hopdong'
        WHEN 'tbmk_Thaydoi' THEN 'tbmk_Thaydoi'
        WHEN 'frmKhuyenMai' THEN 'tbmk_Banuudai'
        WHEN 'frmBiennhancoccho' THEN 'tbmk_Phieucoc'
        WHEN 'frmCustomer' THEN 'dmkhachhang'
        WHEN 'frmHopDong' THEN 'tbmk_Hopdong'
        WHEN 'frmKho' THEN 'dmKho'
        WHEN 'frmHanghoa' THEN 'dmHangHoa'
        WHEN 'frmHanghoadinhluong' THEN 'dmHanghoadinhluong'
        WHEN 'frmNhapKho' THEN 'tbNhaphang'
        WHEN 'frmXuatKho' THEN 'tbXuatnvl'
        WHEN 'frmBaoGia' THEN 'tbmk_Hopdong'
        WHEN 'frmBEO' THEN 'tbmk_Hopdong'
        WHEN 'dmLoaihinhtiec' THEN 'dmLoaihinhtiec'
        ELSE @List
    END;

    SET @PrimaryKey = CASE @List
        WHEN 'frmKhachHang' THEN 'Makh'
        WHEN 'frmKhachThamQuan' THEN 'DocumentID'
        WHEN 'frmTaiKhoan' THEN 'UserName'
        WHEN 'frmQuyetToan' THEN 'DocumentID'
        WHEN 'dmSanhtiec' THEN 'Sanhtiecid'
        WHEN 'dmThoigian' THEN 'Thoigianid'
        WHEN 'API_DanhSachCaLam' THEN 'Thoigianid'
        WHEN 'frmFormBuilder' THEN 'FieldName'
        WHEN 'Tiec_Documents' THEN 'DocumentID'
        WHEN 'SY_Period' THEN 'PeriodID'
        WHEN 'frmThayDoiBoSung' THEN 'Sothaydoi'
        WHEN 'frmPhuLucHopDong' THEN 'SoPhuLuc'
        WHEN 'tbmk_Thaydoi' THEN 'Sothaydoi'
        WHEN 'frmKhuyenMai' THEN 'DocumentID'
        WHEN 'frmBiennhancoccho' THEN 'DocumentID'
        WHEN 'frmCustomer' THEN 'Makh'
        WHEN 'frmHopDong' THEN 'DocumentID'
        WHEN 'frmKho' THEN 'Khoid'
        WHEN 'frmHanghoa' THEN 'Mahang'
        WHEN 'frmHanghoadinhluong' THEN 'UserAutoID'
        WHEN 'frmNhapKho' THEN 'DocumentID'
        WHEN 'frmXuatKho' THEN 'DocumentID'
        WHEN 'frmBaoGia' THEN 'Sohopdong'
        WHEN 'frmBEO' THEN 'Sohopdong'
        WHEN 'dmLoaihinhtiec' THEN 'Loaitiecid'
        ELSE ''
    END;

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

    IF @PrimaryKey IS NULL OR @PrimaryKey = ''
    BEGIN
        SELECT -1 AS code, N'Chưa cấu hình PrimaryKey cho form ' + @List AS msg;
        RETURN;
    END

    -- ==========================================================
    -- XỬ LÝ XÓA ĐỘNG CHUNG CHO TẤT CẢ CÁC BẢNG KHÁC (TỰ ĐỘNG NHẬN DIỆN SOFT/HARD DELETE)
    -- ==========================================================
    BEGIN TRY
        -- Kiểm tra xem bảng có chứa cột IsDeleted hay không để tự động áp dụng Soft Delete
        DECLARE @HasIsDeleted BIT = 0;
        DECLARE @HasDeletedAt BIT = 0;
        DECLARE @HasDeletedBy BIT = 0;

        IF EXISTS (
            SELECT 1 
            FROM sys.columns 
            WHERE object_id = OBJECT_ID(@TableName) 
              AND name = 'IsDeleted'
        )
        BEGIN
            SET @HasIsDeleted = 1;
        END

        IF EXISTS (
            SELECT 1 
            FROM sys.columns 
            WHERE object_id = OBJECT_ID(@TableName) 
              AND name = 'DeletedAt'
        )
        BEGIN
            SET @HasDeletedAt = 1;
        END

        IF EXISTS (
            SELECT 1 
            FROM sys.columns 
            WHERE object_id = OBJECT_ID(@TableName) 
              AND name = 'DeletedBy'
        )
        BEGIN
            SET @HasDeletedBy = 1;
        END

        DECLARE @sql NVARCHAR(MAX) = '';

        IF @HasIsDeleted = 1
        BEGIN
            -- Thực hiện Soft Delete động
            SET @sql = 'UPDATE ' + QUOTENAME(@TableName) + ' SET IsDeleted = 1';
            
            IF @HasDeletedAt = 1
                SET @sql = @sql + ', DeletedAt = GETDATE()';
                
            IF @HasDeletedBy = 1
                SET @sql = @sql + ', DeletedBy = @User';
                
            SET @sql = @sql + ' WHERE ' + QUOTENAME(@PrimaryKey) + ' IN (SELECT LTRIM(RTRIM(value)) FROM string_split(@DeleteIds, '',''))';
                       
            EXEC sp_executesql @sql, N'@DeleteIds NVARCHAR(MAX), @User VARCHAR(50)', @DeleteIds = @Ids, @User = @UserName;
            
            DECLARE @RowsSoft INT = @@ROWCOUNT;
            SELECT 0 AS code, N'Xóa thành công (Soft Delete) ' + CAST(@RowsSoft AS VARCHAR) + N' dòng khỏi bảng ' + @TableName AS msg;
        END
        ELSE
        BEGIN
            -- Thực hiện Hard Delete động (xóa cứng)
            SET @sql = 'DELETE FROM ' + QUOTENAME(@TableName) + 
                       ' WHERE ' + QUOTENAME(@PrimaryKey) + ' IN (SELECT LTRIM(RTRIM(value)) FROM string_split(@DeleteIds, '',''))';
                       
            EXEC sp_executesql @sql, N'@DeleteIds NVARCHAR(MAX)', @DeleteIds = @Ids;
            
            DECLARE @RowsHard INT = @@ROWCOUNT;
            SELECT 0 AS code, N'Xóa thành công ' + CAST(@RowsHard AS VARCHAR) + N' dòng khỏi bảng ' + @TableName AS msg;
        END
    END TRY
    BEGIN CATCH
        SELECT -1 AS code, N'Lỗi xóa dữ liệu: ' + ERROR_MESSAGE() AS msg;
    END CATCH
END
GO
