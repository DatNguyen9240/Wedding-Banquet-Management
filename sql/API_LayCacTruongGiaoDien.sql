CREATE OR ALTER PROCEDURE [dbo].[API_LayCacTruongGiaoDien]
    @FormName VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        ff.FieldName AS [name], 
        ff.CaptionVN AS [label],
        ISNULL(ff.IsRequired, 0) AS [required], 
        ISNULL(ff.FormPosition, 'grid') AS [position],
        
        -- Trả về thêm cấu hình cấp độ Form để loại bỏ hoàn toàn AppModules.js
        ISNULL(l.CaptionVN, '') AS [formTitle],
        ISNULL(l.SubTitle, '') AS [formSubtitle],
        ISNULL(l.PrimaryKey, '') AS [primaryKey],
        
        -- Tính toán động showInAdd từ AddNewColumnArr
        CASE 
            WHEN l.FormID IS NULL THEN 1 -- Nếu không map được Form thì mặc định hiện
            WHEN CHARINDEX(',' + ff.FieldName + ',', ',' + ISNULL(l.AddNewColumnArr, '') + ',') > 0 THEN 1 
            ELSE 0 
        END AS [showInAdd],

        -- Tính toán động showInEdit từ HideColumnArr
        CASE 
            WHEN l.FormID IS NULL THEN 1
            WHEN CHARINDEX(',' + ff.FieldName + ',', ',' + ISNULL(l.HideColumnArr, '') + ',') > 0 THEN 0 
            ELSE 1 
        END AS [showInEdit],

        -- Tính toán động isReadOnlyEdit từ LockColumnArr
        CASE 
            WHEN l.FormID IS NULL THEN 0
            WHEN CHARINDEX(',' + ff.FieldName + ',', ',' + ISNULL(l.LockColumnArr, '') + ',') > 0 THEN 1 
            ELSE 0 
        END AS [isReadOnlyEdit],

        -- Tính toán động isReadOnlyAdd từ LockAddColumnArr
        CASE 
            WHEN l.FormID IS NULL THEN 0
            WHEN CHARINDEX(',' + ff.FieldName + ',', ',' + ISNULL(l.LockAddColumnArr, '') + ',') > 0 THEN 1 
            ELSE 0 
        END AS [isReadOnlyAdd],

        ISNULL(ff.FormatID, '') AS [renderRule],
        ISNULL(ff.DataSource, '') AS [dataSource],
        ISNULL(ff.OrderNo, 0) AS [orderNo],
        ISNULL(ff.ValidateRule, '') AS [validateRule],
        ISNULL(ff.DependsOn, '') AS [dependsOn],
        ISNULL(ff.VisibleRule, '') AS [visibleRule]
    FROM SY_FormatFields ff
    LEFT JOIN SY_FrmLstTbl l ON ff.FormName = l.FormID
    WHERE (@FormName IS NULL OR ff.FormName = @FormName)
    ORDER BY ISNULL(ff.OrderNo, 0) ASC, ff.FieldName ASC;
END
GO

-- Lệnh chạy thử:
-- EXEC [dbo].[API_LayCacTruongGiaoDien] @FormName = 'frmCustomer';
