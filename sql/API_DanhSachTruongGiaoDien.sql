IF OBJECT_ID('API_DanhSachTruongGiaoDien', 'P') IS NOT NULL
    DROP PROCEDURE API_DanhSachTruongGiaoDien;
GO

CREATE PROCEDURE API_DanhSachTruongGiaoDien
    @Keyword nvarchar(100) = NULL,
    @FormName nvarchar(100) = NULL,
    @UserName nvarchar(100) = NULL,
    @SortColumn nvarchar(100) = NULL,
    @SortDir nvarchar(10) = NULL,
    @Page int = 1,
    @Limit int = 15
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        COUNT(*) OVER() AS TotalRecords,
        ff.AutoID, 
        ff.FormName, 
        ff.FieldName, 
        ff.CaptionVN, 
        ff.FormatID, 
        ff.CaptionEN, 
        ff.DataSource,
        ff.IsRequired, 
        ff.FormPosition, 
        ff.ShowInForm,
        ff.ValidateRule,
        ff.DependsOn,
        ff.VisibleRule,
        
        -- Tính toán động showInAdd từ AddNewColumnArr
        CASE 
            WHEN l.FormID IS NULL THEN 1
            WHEN CHARINDEX(',' + ff.FieldName + ',', ',' + ISNULL(l.AddNewColumnArr, '') + ',') > 0 THEN 1 
            ELSE 0 
        END AS ShowInAdd,

        -- Tính toán động showInEdit từ HideColumnArr
        CASE 
            WHEN l.FormID IS NULL THEN 1
            WHEN CHARINDEX(',' + ff.FieldName + ',', ',' + ISNULL(l.HideColumnArr, '') + ',') > 0 THEN 0 
            ELSE 1 
        END AS ShowInEdit,

        -- Tính toán động isReadOnlyEdit từ LockColumnArr
        CASE 
            WHEN l.FormID IS NULL THEN 0
            WHEN CHARINDEX(',' + ff.FieldName + ',', ',' + ISNULL(l.LockColumnArr, '') + ',') > 0 THEN 1 
            ELSE 0 
        END AS IsReadOnlyEdit,

        -- Tính toán động isReadOnlyAdd từ LockAddColumnArr
        CASE 
            WHEN l.FormID IS NULL THEN 0
            WHEN CHARINDEX(',' + ff.FieldName + ',', ',' + ISNULL(l.LockAddColumnArr, '') + ',') > 0 THEN 1 
            ELSE 0 
        END AS IsReadOnlyAdd

    FROM SY_FormatFields ff
    LEFT JOIN SY_FrmLstTbl l ON ff.FormName = l.FormID
    WHERE (@Keyword IS NULL OR @Keyword = '' 
           OR ff.FormName LIKE '%' + @Keyword + '%' 
           OR ff.FieldName LIKE '%' + @Keyword + '%'
           OR ff.CaptionVN LIKE N'%' + @Keyword + '%')
      AND (@FormName IS NULL OR @FormName = '' OR @FormName = 'frmFormBuilder' OR ff.FormName = @FormName)
    ORDER BY ff.FormName ASC, ff.FieldName ASC
    OFFSET (ISNULL(@Page, 1) - 1) * ISNULL(@Limit, 15) ROWS
    FETCH NEXT ISNULL(@Limit, 15) ROWS ONLY;
END
GO
