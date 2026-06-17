USE [QLTiec]
GO

-- 1. Tạo bảng Tiec_Documents nếu chưa tồn tại
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Tiec_Documents')
BEGIN
    CREATE TABLE Tiec_Documents (
        DocumentID INT IDENTITY(1,1) PRIMARY KEY,
        TiecID VARCHAR(50) NULL,            -- Mã Hợp đồng (Sohopdong) hoặc Mã chứng từ liên kết (Cho phép NULL để ghi vết file cũ)
        DocType VARCHAR(50) NULL,           -- Phân loại: HOP_DONG, BIEN_COC, QUYET_TOAN, PHU_LUC (Cho phép NULL để ghi vết file cũ)
        VersionNo INT DEFAULT 1,                -- Số thứ tự phiên bản xuất file
        FilePath NVARCHAR(500) NOT NULL,        -- Đường dẫn lưu file vật lý trên server
        FileHash VARCHAR(255),                  -- Chuỗi băm (MD5/SHA256) chống sửa file ngoài hệ thống
        TemplateVersion VARCHAR(50),            -- Ghi nhận dùng Mẫu (Template) nào để xuất
        Status VARCHAR(20) DEFAULT 'ACTIVE',    -- Trạng thái file: ACTIVE (Đang dùng), DELETED (Bị xóa - Bia mộ)
        GeneratedBy VARCHAR(50),                -- Nhân viên xuất file
        GeneratedAt DATETIME DEFAULT GETDATE(), -- Thời gian xuất file
        DeletedBy VARCHAR(50) NULL,             -- Người xóa file (Nếu có)
        DeletedAt DATETIME NULL                 -- Thời gian xóa file (Bia mộ)
    );
    
    CREATE NONCLUSTERED INDEX IX_TiecDocuments_TiecID ON Tiec_Documents(TiecID);
    PRINT '>> DA TAO BANG Tiec_Documents THANH CONG.';
END
ELSE
BEGIN
    -- Đảm bảo TiecID và DocType cho phép NULL để lưu vết file cũ/file rác không lỗi hệ thống
    ALTER TABLE Tiec_Documents ALTER COLUMN TiecID VARCHAR(50) NULL;
    ALTER TABLE Tiec_Documents ALTER COLUMN DocType VARCHAR(50) NULL;
    PRINT '>> BANG Tiec_Documents DA TON TAI. DA CAP NHAT CAC COT SANG NULLABLE.';
END
GO

-- 2. Đăng ký API Gateway Router cho Tiec_Documents
DELETE FROM WA_API WHERE List = 'Tiec_Documents';
INSERT INTO WA_API (List, Func, [SQL], Para)
VALUES
('Tiec_Documents', 'Save', 'API_LuuTiecDocuments', '@TiecID=N''{TiecID}'', @DocType=N''{DocType}'', @VersionNo=N''{VersionNo}'', @FilePath=N''{FilePath}'', @FileHash=N''{FileHash}'', @TemplateVersion=N''{TemplateVersion}'', @Status=N''{Status}'', @GeneratedBy=N''{GeneratedBy}'', @UserName=N''{User}'', @JsonData=N''{JsonData}'''),
('Tiec_Documents', 'Edit', 'API_LuuTiecDocuments', '@DocumentID=N''{DocumentID}'', @TiecID=N''{TiecID}'', @DocType=N''{DocType}'', @VersionNo=N''{VersionNo}'', @FilePath=N''{FilePath}'', @FileHash=N''{FileHash}'', @TemplateVersion=N''{TemplateVersion}'', @Status=N''{Status}'', @DeletedBy=N''{DeletedBy}'', @DeletedAt=N''{DeletedAt}'', @UserName=N''{User}'', @JsonData=N''{JsonData}'''),
('Tiec_Documents', 'View', 'API_TruyVanDong', '@List=N''Tiec_Documents'', @Keyword=N''{Keyword}'', @SortColumn=N''{SortColumn}'', @SortDir=N''{SortDir}'', @Data=N''{JsonData}''');
PRINT '>> DA DANG KY WA_API CHO Tiec_Documents THANH CONG.';
GO

-- 3. Đăng ký bảng cấu hình danh mục/form No-Code cho Tiec_Documents
DELETE FROM SY_FrmLstTbl WHERE FormID = 'Tiec_Documents';
INSERT INTO SY_FrmLstTbl (FormID, FormType, CaptionVN, TableName, PrimaryKey)
VALUES ('Tiec_Documents', 'LIST', N'Sổ Lưu Trữ Tài Liệu', 'Tiec_Documents', 'DocumentID');
PRINT '>> DA DANG KY SY_FrmLstTbl CHO Tiec_Documents THANH CONG.';
GO

-- 4. Đồng bộ các cột của bảng Tiec_Documents vào bảng thuộc tính giao diện SY_FormatFields
EXEC API_DongBoTruongGiaoDien @FormName = 'Tiec_Documents', @ObjectName = 'Tiec_Documents';
GO

-- Cấu hình lại nhãn tiếng Việt hiển thị đẹp mắt cho Tiec_Documents
UPDATE SY_FormatFields
SET CaptionVN = CASE FieldName
    WHEN 'DocumentID' THEN N'Mã Lưu Trữ'
    WHEN 'TiecID' THEN N'Mã Tiệc / Số Hợp Đồng'
    WHEN 'DocType' THEN N'Loại Tài Liệu'
    WHEN 'VersionNo' THEN N'Phiên Bản'
    WHEN 'FilePath' THEN N'Tên File'
    WHEN 'FileHash' THEN N'Mã Băm (Hash)'
    WHEN 'TemplateVersion' THEN N'Mẫu Sử Dụng'
    WHEN 'Status' THEN N'Trạng Thái'
    WHEN 'GeneratedBy' THEN N'Người Tạo'
    WHEN 'GeneratedAt' THEN N'Thời Gian Tạo'
    WHEN 'DeletedBy' THEN N'Người Xóa'
    WHEN 'DeletedAt' THEN N'Thời Gian Xóa'
    ELSE CaptionVN
END
WHERE FormName = 'Tiec_Documents';
PRINT '>> DA CAP NHAT NHAN TIENG VIET CHO CAC TRUONG GIAO DIEN Tiec_Documents.';
GO
