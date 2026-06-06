USE [QLTiec]
GO

-- 1. TẠO STORED PROCEDURE LƯU VẾT TÀI LIỆU
IF OBJECT_ID('API_Tiec_Documents_Save', 'P') IS NOT NULL
    DROP PROCEDURE API_Tiec_Documents_Save;
GO

CREATE PROCEDURE [dbo].[API_Tiec_Documents_Save]
    @TiecID VARCHAR(50),
    @DocType VARCHAR(50),
    @FilePath NVARCHAR(500),
    @FileHash VARCHAR(255) = NULL,
    @TemplateVersion VARCHAR(50) = NULL,
    @Status VARCHAR(20) = 'ACTIVE',
    @GeneratedBy VARCHAR(50) = 'system'
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Tự động tăng VersionNo nếu đã có file cùng TiecID và DocType
    DECLARE @MaxVersion INT = 0;
    SELECT @MaxVersion = ISNULL(MAX(VersionNo), 0)
    FROM Tiec_Documents
    WHERE TiecID = @TiecID AND DocType = @DocType;
    
    DECLARE @VersionNo INT = @MaxVersion + 1;

    INSERT INTO Tiec_Documents (
        TiecID, DocType, VersionNo, FilePath, FileHash, TemplateVersion, Status, GeneratedBy, GeneratedAt
    )
    VALUES (
        @TiecID, @DocType, @VersionNo, @FilePath, @FileHash, @TemplateVersion, @Status, @GeneratedBy, GETDATE()
    );

    SELECT 0 AS code, N'Lưu tài liệu thành công!' AS msg;
END
GO

-- 2. TẠO STORED PROCEDURE CẬP NHẬT TRẠNG THÁI / BIA MỘ TÀI LIỆU
IF OBJECT_ID('API_Tiec_Documents_Edit', 'P') IS NOT NULL
    DROP PROCEDURE API_Tiec_Documents_Edit;
GO

CREATE PROCEDURE [dbo].[API_Tiec_Documents_Edit]
    @FilePath NVARCHAR(500),
    @Status VARCHAR(20),
    @DeletedBy VARCHAR(50) = NULL,
    @DeletedAt VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE Tiec_Documents
    SET Status = @Status,
        DeletedBy = CASE WHEN @Status = 'DELETED' THEN ISNULL(@DeletedBy, 'system') ELSE DeletedBy END,
        DeletedAt = CASE WHEN @Status = 'DELETED' THEN GETDATE() ELSE DeletedAt END
    WHERE FilePath = @FilePath;

    SELECT 0 AS code, N'Cập nhật trạng thái tài liệu thành công!' AS msg;
END
GO

-- 3. ĐỒNG BỘ ĐỊNH TUYẾN WA_API
DELETE FROM WA_API WHERE List = 'Tiec_Documents';
GO

INSERT INTO WA_API (List, Func, [SQL], Para)
VALUES 
('Tiec_Documents', 'Save', 'API_Tiec_Documents_Save', '@TiecID=N''{TiecID}'', @DocType=N''{DocType}'', @FilePath=N''{FilePath}'', @FileHash=N''{FileHash}'', @Status=N''{Status}'', @GeneratedBy=N''{GeneratedBy}'''),
('Tiec_Documents', 'Edit', 'API_Tiec_Documents_Edit', '@FilePath=N''{FilePath}'', @Status=N''{Status}'', @DeletedBy=N''{DeletedBy}'', @DeletedAt=N''{DeletedAt}''');
GO

PRINT '>> DA DONG BO API CHO BANG Tiec_Documents.';
GO
