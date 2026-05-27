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
        ff.AutoID, 
        ff.FormName, 
        ff.FieldName, 
        ff.CaptionVN, 
        ff.FormatID, 
        ff.CaptionEN, 
        ff.DataSource,
        ff.IsRequired, 
        ff.FormPosition, 
        ff.ValidateRule,
        ff.DependsOn,
        ff.VisibleRule,
        ff.OrderNo,
        ISNULL(ff.ShowInAdd,      1) AS ShowInAdd,
        ISNULL(ff.ShowInEdit,     1) AS ShowInEdit,
        ISNULL(ff.IsReadOnlyEdit, 0) AS IsReadOnlyEdit,
        ISNULL(ff.IsReadOnlyAdd,  0) AS IsReadOnlyAdd,
        ISNULL(ff.ShowInFilter,   0) AS ShowInFilter

    FROM SY_FormatFields ff
    LEFT JOIN SY_FrmLstTbl l ON ff.FormName = l.FormID
    WHERE (@Keyword IS NULL OR @Keyword = '' 
           OR ff.FormName LIKE '%' + @Keyword + '%' 
           OR ff.FieldName LIKE '%' + @Keyword + '%'
           OR ff.CaptionVN LIKE N'%' + @Keyword + '%'
           OR l.CaptionVN LIKE N'%' + @Keyword + '%')
      AND (@FormName IS NULL OR @FormName = '' OR @FormName = 'frmFormBuilder' OR ff.FormName = @FormName)
    ORDER BY ff.FormName ASC, ff.FieldName ASC
    OFFSET (ISNULL(@Page, 1) - 1) * ISNULL(@Limit, 15) ROWS
    FETCH NEXT ISNULL(@Limit, 15) ROWS ONLY;
END
GO
