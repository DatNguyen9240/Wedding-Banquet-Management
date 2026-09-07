USE [QLTiec]
GO
-- Only use an address explicitly confirmed by the company. NULL preserves existing data.
DECLARE @BenADiaChi NVARCHAR(500) = NULL;
IF NULLIF(LTRIM(RTRIM(@BenADiaChi)), N'') IS NOT NULL
BEGIN
    IF EXISTS (SELECT 1 FROM dbo.SY_Setup WHERE CodeID = 'BenADiaChi')
        UPDATE dbo.SY_Setup SET CodeValue = @BenADiaChi WHERE CodeID = 'BenADiaChi';
    ELSE
        INSERT dbo.SY_Setup (CodeID, CodeValue, Description)
        VALUES ('BenADiaChi', @BenADiaChi, N'Địa chỉ Bên A đã xác nhận');
END
ELSE PRINT N'Chưa có địa chỉ đã xác nhận; giữ nguyên cấu hình Bên A.';
GO
