GO

/****** Object:  StoredProcedure [dbo].[API_DanhSachCaLam] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER PROCEDURE [dbo].[API_DanhSachCaLam]
AS
BEGIN
    SET NOCOUNT ON;

    -- Truy vấn danh sách Ca Tiệc từ bảng dmThoigian
    SELECT 
        Thoigianid,
        Thoigian
    FROM 
        dmThoigian
    ORDER BY 
        GhiBatDau ASC;

END
GO
