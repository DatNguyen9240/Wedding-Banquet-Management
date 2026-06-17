USE [QLTiec]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:      Antigravity
-- Create date: 2026-06-15
-- Description: API Lưu / Cập nhật trạng thái (Bia mộ) tài liệu xuất ra hệ thống
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[API_LuuTiecDocuments]
    @DocumentID INT = NULL,
    @TiecID VARCHAR(50) = NULL,
    @DocType VARCHAR(50) = NULL,
    @VersionNo INT = NULL,
    @FilePath NVARCHAR(500) = NULL,
    @FileHash VARCHAR(255) = NULL,
    @TemplateVersion VARCHAR(50) = NULL,
    @Status VARCHAR(20) = NULL,
    @GeneratedBy VARCHAR(50) = NULL,
    @DeletedBy VARCHAR(50) = NULL,
    @DeletedAt NVARCHAR(100) = NULL,
    @UserName VARCHAR(50) = 'system',
    @JsonData NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Now DATETIME = GETDATE();

    -- Nếu có truyền @JsonData, ưu tiên parse từ @JsonData
    IF ISNULL(@JsonData, '') <> '' AND ISJSON(@JsonData) = 1
    BEGIN
        SELECT 
            @DocumentID = CASE WHEN JSON_VALUE(@JsonData, '$.DocumentID') IS NULL THEN @DocumentID ELSE CAST(JSON_VALUE(@JsonData, '$.DocumentID') AS INT) END,
            @TiecID = ISNULL(JSON_VALUE(@JsonData, '$.TiecID'), @TiecID),
            @DocType = ISNULL(JSON_VALUE(@JsonData, '$.DocType'), @DocType),
            @VersionNo = CASE WHEN JSON_VALUE(@JsonData, '$.VersionNo') IS NULL THEN @VersionNo ELSE CAST(JSON_VALUE(@JsonData, '$.VersionNo') AS INT) END,
            @FilePath = ISNULL(JSON_VALUE(@JsonData, '$.FilePath'), @FilePath),
            @FileHash = ISNULL(JSON_VALUE(@JsonData, '$.FileHash'), @FileHash),
            @TemplateVersion = ISNULL(JSON_VALUE(@JsonData, '$.TemplateVersion'), @TemplateVersion),
            @Status = ISNULL(JSON_VALUE(@JsonData, '$.Status'), @Status),
            @GeneratedBy = ISNULL(JSON_VALUE(@JsonData, '$.GeneratedBy'), @GeneratedBy),
            @DeletedBy = ISNULL(JSON_VALUE(@JsonData, '$.DeletedBy'), @DeletedBy),
            @DeletedAt = ISNULL(JSON_VALUE(@JsonData, '$.DeletedAt'), @DeletedAt);
    END

    -- Phân tích định dạng ngày xóa nếu có
    DECLARE @DeletedAtParsed DATETIME = NULL;
    IF @DeletedAt IS NOT NULL AND @DeletedAt <> ''
    BEGIN
        SET @DeletedAtParsed = TRY_CAST(@DeletedAt AS DATETIME);
        IF @DeletedAtParsed IS NULL SET @DeletedAtParsed = TRY_CONVERT(DATETIME, @DeletedAt, 126); -- ISO 8601
    END

    -- Kiểm tra xem tài liệu đã tồn tại trong CSDL chưa (FilePath là khóa tìm kiếm chính xác)
    IF EXISTS (SELECT 1 FROM Tiec_Documents WHERE FilePath = @FilePath)
    BEGIN
        -- Cập nhật thông tin file (Bia mộ khi xóa)
        UPDATE Tiec_Documents
        SET 
            TiecID = ISNULL(@TiecID, TiecID),
            DocType = ISNULL(@DocType, DocType),
            VersionNo = ISNULL(@VersionNo, VersionNo),
            FileHash = ISNULL(@FileHash, FileHash),
            TemplateVersion = ISNULL(@TemplateVersion, TemplateVersion),
            Status = ISNULL(@Status, Status),
            DeletedBy = CASE WHEN @Status = 'DELETED' THEN ISNULL(@DeletedBy, @UserName) ELSE DeletedBy END,
            DeletedAt = CASE WHEN @Status = 'DELETED' THEN ISNULL(@DeletedAtParsed, @Now) ELSE DeletedAt END
        WHERE FilePath = @FilePath;

        SELECT 1 AS [Success], N'Cập nhật tài liệu thành công!' AS [Message];
    END
    ELSE
    BEGIN
        -- Thêm mới file
        -- Tự động tính VersionNo: lấy VersionNo lớn nhất của TiecID + DocType rồi + 1
        IF @VersionNo IS NULL OR @VersionNo <= 0
        BEGIN
            SELECT @VersionNo = ISNULL(MAX(VersionNo), 0) + 1 
            FROM Tiec_Documents 
            WHERE TiecID = @TiecID AND DocType = @DocType;
        END

        INSERT INTO Tiec_Documents (
            TiecID, DocType, VersionNo, FilePath, FileHash, TemplateVersion, Status, GeneratedBy, GeneratedAt, DeletedBy, DeletedAt
        )
        VALUES (
            @TiecID, @DocType, ISNULL(@VersionNo, 1), @FilePath, @FileHash, @TemplateVersion, ISNULL(@Status, 'ACTIVE'), ISNULL(@GeneratedBy, @UserName), @Now,
            CASE WHEN @Status = 'DELETED' THEN ISNULL(@DeletedBy, @UserName) ELSE NULL END,
            CASE WHEN @Status = 'DELETED' THEN ISNULL(@DeletedAtParsed, @Now) ELSE NULL END
        );

        SELECT 1 AS [Success], N'Thêm mới tài liệu thành công!' AS [Message];
    END
END
GO
