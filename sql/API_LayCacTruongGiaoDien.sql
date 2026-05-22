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
        ISNULL(ShowInAdd, 1) AS [showInAdd],
        ISNULL(ShowInEdit, 1) AS [showInEdit],
        ISNULL(FormatID, '') AS [renderRule],
        ISNULL(DataSource, '') AS [dataSource],
        ISNULL(OrderNo, 0) AS [orderNo]
    FROM SY_FormatFields ff
    WHERE (@FormName IS NULL OR ff.FormName = @FormName)
    ORDER BY ISNULL(OrderNo, 0) ASC, FieldName ASC;
END
GO

-- Lệnh chạy thử:
-- EXEC [dbo].[API_LayCacTruongGiaoDien] @FormName = 'frmCustomer';
