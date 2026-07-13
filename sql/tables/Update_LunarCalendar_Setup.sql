USE [QLTiec];
GO

-- =========================================================================
-- 1. TẠO HÀM CHUYỂN ĐỔI NGÀY DƯƠNG LỊCH SANG ÂM LỊCH
-- =========================================================================
IF OBJECT_ID('dbo.fn_SolarToLunar', 'FN') IS NOT NULL
    DROP FUNCTION dbo.fn_SolarToLunar;
GO

CREATE FUNCTION [dbo].[fn_SolarToLunar] (
    @SolarDate DATE
)
RETURNS NVARCHAR(50)
AS
BEGIN
    DECLARE @LunarDate NVARCHAR(50);
    
    SELECT TOP 1 @LunarDate = NgayLunar 
    FROM dbo.tbmk_LichAmDuong 
    WHERE NgaySolar = @SolarDate;
    
    RETURN ISNULL(@LunarDate, '');
END;
GO

-- =========================================================================
-- 2. TẠO STORED PROCEDURE ĐỂ TÍNH LỊCH ÂM QUA TRIGGER API (DÙNG JSON)
-- Giải quyết triệt để vấn đề phân biệt hoa/thường bằng cách đọc trực tiếp từ JSON
-- =========================================================================
IF OBJECT_ID('dbo.API_TinhLichAm', 'P') IS NOT NULL
    DROP PROCEDURE dbo.API_TinhLichAm;
GO

CREATE PROCEDURE [dbo].[API_TinhLichAm]
    @JsonData NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @NgayToChuc NVARCHAR(50) = NULL;
    
    -- Trích xuất ngày tổ chức từ JSON (hỗ trợ cả NgayToChuc, ngaytochuc, NgayDuKien, ngaydukien)
    IF @JsonData IS NOT NULL AND ISJSON(@JsonData) = 1
    BEGIN
        SELECT @NgayToChuc = COALESCE(
            JSON_VALUE(@JsonData, '$.NgayToChuc'),
            JSON_VALUE(@JsonData, '$.Ngaytochuc'),
            JSON_VALUE(@JsonData, '$.ngaytochuc'),
            JSON_VALUE(@JsonData, '$.NgayDuKien'),
            JSON_VALUE(@JsonData, '$.Ngaydukien'),
            JSON_VALUE(@JsonData, '$.ngaydukien')
        );
    END
    
    DECLARE @LunarDate NVARCHAR(50) = '';
    DECLARE @ParsedDate DATE = NULL;
    
    IF @NgayToChuc IS NOT NULL AND @NgayToChuc <> ''
    BEGIN
        -- 1. Nếu định dạng có dấu gạch chéo (/), thử parse theo kiểu dd/MM/yyyy (Style 103) trước
        IF @NgayToChuc LIKE '%/%/%'
        BEGIN
            SET @ParsedDate = TRY_CONVERT(DATE, @NgayToChuc, 103);
        END
        
        -- 2. Nếu thất bại hoặc không phải dạng /, thử cast trực tiếp (ISO YYYY-MM-DD)
        IF @ParsedDate IS NULL
        BEGIN
            SET @ParsedDate = TRY_CAST(@NgayToChuc AS DATE);
        END
        
        -- 3. Thử kiểu yyyy/MM/dd (Style 111)
        IF @ParsedDate IS NULL
        BEGIN
            SET @ParsedDate = TRY_CONVERT(DATE, @NgayToChuc, 111);
        END
    END
    
    IF @ParsedDate IS NOT NULL
    BEGIN
        SET @LunarDate = dbo.fn_SolarToLunar(@ParsedDate);
    END
    
    -- Trả về cả Nhamngay và NgayAmLich để tương thích với tất cả các biểu mẫu (frmHopDong, frmKhachThamQuan, v.v.)
    SELECT @LunarDate AS [Nhamngay], @LunarDate AS [NgayAmLich];
END;
GO

-- =========================================================================
-- 3. ĐĂNG KÝ ĐỊNH TUYẾN TRONG BẢNG WA_API
-- Truyền nguyên cục JsonData xuống để Procedure tự bóc tách
-- =========================================================================
DELETE FROM WA_API WHERE List = 'API_TinhLichAm' AND Func = 'View';
GO

INSERT INTO WA_API (List, Func, [SQL], Para)
VALUES (
    'API_TinhLichAm',
    'View',
    'API_TinhLichAm',
    '@JsonData=N''{JsonData}'''
);
GO

-- =========================================================================
-- 4. CẤU HÌNH DYNAMIC FORM ENGINE TRIGGER TRONG BẢNG SY_FormatFields
-- Kích hoạt trigger gọi API_TinhLichAm mỗi khi chọn Ngày tổ chức
-- =========================================================================

-- Cho Form Hợp Đồng (frmHopDong)
UPDATE SY_FormatFields
SET ValidateRule = 'trigger:/api/API_Gateway_Router?List=API_TinhLichAm&Func=View'
WHERE FormName = 'frmHopDong' AND FieldName = 'NgayToChuc';

-- Cho Form Biên Nhận Đặt Cọc (frmBiennhancoccho)
UPDATE SY_FormatFields
SET ValidateRule = 'trigger:/api/API_Gateway_Router?List=API_TinhLichAm&Func=View'
WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'Ngaytochuc';
GO
