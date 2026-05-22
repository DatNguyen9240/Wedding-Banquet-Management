-- Thêm cột DataSource vào SY_FormatFields để thay thế cho CaptionEN
IF NOT EXISTS(SELECT 1 FROM sys.columns WHERE Name = N'DataSource' AND Object_ID = Object_ID(N'SY_FormatFields'))
BEGIN
    ALTER TABLE SY_FormatFields ADD DataSource NVARCHAR(500) NULL;
END
GO

-- Copy dữ liệu cũ từ CaptionEN sang DataSource (nếu CaptionEN có chứa API hoặc chữ STATIC:)
UPDATE SY_FormatFields 
SET DataSource = CaptionEN 
WHERE CaptionEN LIKE '/api/%' OR CaptionEN LIKE 'STATIC:%' OR CaptionEN LIKE 'http%';
GO

UPDATE SY_FormatFields 
SET DataSource = CaptionEN 
WHERE CaptionEN LIKE '/api/%' OR CaptionEN LIKE 'STATIC:%' OR CaptionEN LIKE 'http%';
GO
