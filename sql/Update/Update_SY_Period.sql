USE [QLTiec]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

PRINT N'=== BẮT ĐẦU CẬP NHẬT CSDL CHO KỲ KẾ TOÁN (SY_Period) ===';
GO

-- =========================================================================
-- 1. ĐĂNG KÝ HỆ THỐNG MẪU BIỂU (SY_FrmLstTbl)
-- =========================================================================
PRINT N'1. Đăng ký SY_Period vào hệ thống mẫu biểu SY_FrmLstTbl (nếu chưa có)...';
GO

IF NOT EXISTS (SELECT 1 FROM SY_FrmLstTbl WHERE FormID = 'SY_Period')
BEGIN
    INSERT INTO SY_FrmLstTbl (FormID, CaptionVN, TableName, SaveTableName, PrimaryKey)
    VALUES ('SY_Period', N'Kỳ Kế Toán / Năm Sử Dụng', 'SY_Period', 'SY_Period', 'PeriodID');
    PRINT N'  + Đã đăng ký SY_Period vào SY_FrmLstTbl';
END
ELSE
BEGIN
    PRINT N'  + SY_Period đã được đăng ký trong SY_FrmLstTbl';
END
GO

-- =========================================================================
-- 2. CẬP NHẬT HOẶC TẠO MỚI STORED PROCEDURE API_SY_Period_Edit
-- =========================================================================
PRINT N'2. Cập nhật hoặc tạo mới Stored Procedure API_SY_Period_Edit...';
GO

IF OBJECT_ID('API_SY_Period_Edit', 'P') IS NOT NULL
    DROP PROCEDURE API_SY_Period_Edit;
GO

CREATE PROCEDURE [dbo].[API_SY_Period_Edit]
    @PeriodID VARCHAR(10),
    @isLock INT
AS
BEGIN
    SET NOCOUNT ON;
    
    IF EXISTS (SELECT 1 FROM SY_Period WHERE PeriodID = @PeriodID)
    BEGIN
        UPDATE SY_Period
        SET isLock = @isLock,
            IsLockData = @isLock
        WHERE PeriodID = @PeriodID;
        
        SELECT 0 AS code, N'Lưu thành công!' AS msg;
    END
    ELSE
    BEGIN
        SELECT -1 AS code, N'Lỗi: Không tìm thấy kỳ kế toán ' + @PeriodID AS msg;
    END
END
GO
PRINT N'  + Đã tạo/cập nhật Stored Procedure: API_SY_Period_Edit';
GO

-- =========================================================================
-- 3. ĐĂNG KÝ API EDIT CHO SY_Period VÀO BẢNG ĐỊNH TUYẾN WA_API
-- =========================================================================
PRINT N'3. Đăng ký API Edit cho SY_Period vào bảng định tuyến WA_API...';
GO

IF EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'WA_API') AND type in (N'U'))
BEGIN
    DELETE FROM WA_API WHERE List = 'SY_Period' AND Func = 'Edit';
    INSERT INTO WA_API (List, Func, [SQL], Para)
    VALUES ('SY_Period', 'Edit', 'API_SY_Period_Edit', '@PeriodID=N''{PeriodID}'', @isLock={isLock}');
    PRINT N'  + Đã đăng ký API Edit cho SY_Period vào WA_API';
END
ELSE
BEGIN
    PRINT N'  + Bảng định tuyến WA_API không tồn tại';
END
GO

PRINT N'=== HOÀN THÀNH CẬP NHẬT CSDL CHO KỲ KẾ TOÁN ===';
GO
