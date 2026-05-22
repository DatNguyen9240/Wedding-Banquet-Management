CREATE OR ALTER PROCEDURE [dbo].[API_LayCacTruongGiaoDien]
    @FormName VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        FieldName AS [name], 
        CaptionVN AS [label],
        ISNULL(IsRequired, 0) AS [required], 
        ISNULL(FormPosition, 'grid') AS [position],
        ISNULL(ShowInForm, 1) AS [showInForm],
        ISNULL(FormatID, '') AS [renderRule],
        ISNULL(CaptionEN, '') AS [dataSource]
    FROM SY_FormatFields ff
    WHERE (@FormName IS NULL OR ff.FormName = @FormName);
END
GO

-- Lệnh chạy thử:
-- EXEC [dbo].[API_LayCacTruongGiaoDien] @FormName = 'frmCustomer';
