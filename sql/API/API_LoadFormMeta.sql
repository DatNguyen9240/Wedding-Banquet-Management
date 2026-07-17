USE [QLTiec]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =========================================================================
-- [API_LoadFormMeta] - TẢI METADATA GIAO DIỆN DỰA TRÊN DB HỆ THỐNG
-- Quét trực tiếp các cột từ sys.columns của bảng vật lý @FormName.
-- Kết hợp thông tin cấu hình hiển thị có sẵn từ SY_FmtFldTbl, SY_FrmDrdwTbl, và SY_FmatTbl.
-- Không yêu cầu thay đổi cấu trúc bảng SY_FmtFldTbl gốc.
-- =========================================================================
IF OBJECT_ID('dbo.API_LoadFormMeta', 'P') IS NOT NULL
    DROP PROCEDURE dbo.API_LoadFormMeta;
GO
CREATE PROCEDURE [dbo].[API_LoadFormMeta]
    @FormName VARCHAR(100) = NULL -- Tên bảng vật lý trong database (Vd: 'dmkhachhang')
AS
BEGIN
    SET NOCOUNT ON;

    -- Phương án 2: Tên Form chính là tên View hoặc Bảng vật lý thật trong CSDL
    DECLARE @ViewName VARCHAR(100) = @FormName;
    DECLARE @SaveTable VARCHAR(100) = '';
    
    -- Tự động tìm bảng vật lý gốc mà View này tham chiếu tới (Nếu ViewName là View)
    SELECT TOP 1 @SaveTable = LTRIM(RTRIM(referenced_entity_name))
    FROM sys.dm_sql_referenced_entities('dbo.' + @ViewName, 'OBJECT')
    WHERE referenced_minor_id = 0;
    
    -- Nếu không phải View (hoặc không tìm thấy tham chiếu), SaveTable chính là ViewName
    IF @SaveTable IS NULL OR @SaveTable = ''
    BEGIN
        SET @SaveTable = @ViewName;
    END;
    
    -- Kiểm tra đối tượng có tồn tại không (bảng hoặc view)
    IF OBJECT_ID(@ViewName) IS NULL
    BEGIN
        SELECT TOP 0 '' AS [name];
        RETURN;
    END

    -- 1. Tự động tìm Primary Key từ hệ thống (trên bảng vật lý SaveTable)
    DECLARE @PrimaryKey VARCHAR(100) = '';
    SELECT TOP 1 @PrimaryKey = c.name
    FROM sys.indexes i
    JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
    JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
    WHERE i.is_primary_key = 1
      AND i.object_id = OBJECT_ID(@SaveTable);

    -- 2. Truy vấn metadata kết hợp thông tin cấu hình từ các bảng có sẵn
    SELECT 
        -- A. Thông tin cột từ DB kết hợp hiển thị từ SY_FmtFldTbl
        c.name AS [name],
        
        -- Nhãn hiển thị: Cấu hình nhãn -> Tên cột
        ISNULL(f.CaptionVN, c.name) AS [label],
        
        f.CaptionEN AS [labelEN],
        f.CaptionCH AS [labelCH],
        
        -- Căn lề và độ rộng
        f.AlignX AS [align],
        f.MinWidth AS [minWidth],
        f.MaxWidth AS [maxWidth],
        
        -- Thứ tự hiển thị: từ SY_FmtFldTbl nếu có, fallback theo column_id
        ISNULL(f.OrderNo, c.column_id) AS [orderNo],
        
        -- Vị trí: từ SY_FmtFldTbl nếu có, fallback theo FormatID
        ISNULL(f.FormPosition, 
            CASE 
                WHEN f.FormatID IN ('js', 'ta') THEN '12'
                ELSE '6'
            END
        ) AS [position],
        
        -- Trường bắt buộc: từ SY_FmtFldTbl nếu có, fallback theo NOT NULL
        ISNULL(f.IsRequired,
            CASE 
                WHEN c.is_nullable = 0 AND c.is_identity = 0 AND c.is_computed = 0 THEN 1 
                ELSE 0 
            END
        ) AS [required],
        
        -- Cờ hiển thị: ưu tiên từ SY_FmtFldTbl, sau đó SY_FrmDrdwTbl, cuối cùng fallback
        ISNULL(f.ShowInGrid, CASE WHEN dd.isInvisible = 1 THEN 0 ELSE 1 END) AS [showInGrid],
        ISNULL(f.ShowInAdd,
            CASE 
                WHEN dd.isInvisible = 1 THEN 0
                WHEN c.name = @PrimaryKey AND c.is_identity = 1 THEN 0 
                ELSE 1 
            END
        ) AS [showInAdd],
        ISNULL(f.ShowInEdit,
            CASE 
                WHEN dd.isInvisible = 1 THEN 0
                ELSE 1 
            END
        ) AS [showInEdit],
        ISNULL(f.IsReadOnlyAdd,
            CASE 
                WHEN dd.isLock = 1 THEN 1
                WHEN c.name = @PrimaryKey AND c.is_identity = 1 THEN 1 
                ELSE 0 
            END
        ) AS [isReadOnlyAdd],
        ISNULL(f.IsReadOnlyEdit,
            CASE 
                WHEN dd.isLock = 1 THEN 1
                WHEN c.name = @PrimaryKey THEN 1 
                ELSE 0 
            END
        ) AS [isReadOnlyEdit],
        ISNULL(f.ShowInFilter, 0) AS [showInFilter],
        
        -- Khóa chính của bảng
        @PrimaryKey AS [primaryKey],

        -- B. Cấu hình định dạng dữ liệu (từ SY_FmatTbl)
        ISNULL(f.FormatID, '') AS [renderRule],
        t.name AS [dataType],
        
        -- Các rule bổ trợ từ SY_FmtFldTbl
        ISNULL(f.ValidateRule, '') AS [validateRule],
        ISNULL(f.DependsOn,    '') AS [dependsOn],
        ISNULL(f.VisibleRule,  '') AS [visibleRule],
        
        fm.FormatString AS [formatString],
        fm.MaskString AS [maskString],
        fm.NumberDecimal AS [numberDecimal],
        fm.MaxLength AS [maxLength],
        fm.Type AS [formatType],
        fm.MinValue AS [minValue],
        fm.MaxValue AS [maxValue],
        
        -- C. Cấu hình Dropdown / Lookup (từ SY_FrmDrdwTbl)
        ISNULL(dd.Source, '') AS [dataSource],
        ISNULL(dd.Type, '') AS [dropdownType],
        dd.ValueColumn AS [dropdownValueColumn],
        dd.DisplayColumn AS [dropdownDisplayColumn],
        dd.ColumnArr AS [dropdownColumnArr],
        dd.WidthArr AS [dropdownWidthArr],
        dd.IsMultiSelect AS [dropdownIsMultiSelect],
        dd.IsNotInList AS [dropdownIsNotInList],
        dd.DisableAddNew AS [dropdownDisableAddNew]
        
    FROM sys.columns c
    JOIN sys.types t ON c.user_type_id = t.user_type_id
     -- Khớp cấu hình hiển thị cột có sẵn
    LEFT JOIN dbo.SY_FmtFldTbl f ON f.FormName = @FormName AND f.FieldName = c.name
    -- Khớp cấu hình định dạng chi tiết
    LEFT JOIN dbo.SY_FmatTbl fm ON f.FormatID = fm.FormatID
    -- Khớp cấu hình dropdown
    LEFT JOIN dbo.SY_FrmDrdwTbl dd ON dd.FormID = @FormName AND dd.ColumnID = c.name
    
    WHERE c.object_id = OBJECT_ID(@ViewName)
    ORDER BY c.column_id ASC;
END
GO
