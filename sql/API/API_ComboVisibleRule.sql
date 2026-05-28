USE [QLTiec]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- API: Lấy danh sách gợi ý Quy tắc hiển thị (Visible Rule)
-- =============================================
CREATE PROCEDURE [dbo].[API_ComboVisibleRule]
    @Keyword NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Đẩy dữ liệu tĩnh vào bảng tạm
    SELECT * INTO #TempVisible FROM (
        VALUES 
            ('', N'Luôn hiển thị (Mặc định)'),
            ('FieldA=1',  N'Hiện khi FieldA = 1 (Mẫu)'),
            ('FieldA!=1',  N'Hiện khi FieldA Khác 1 (Mẫu)'),
            ('FieldA=1|2',  N'Hiện khi FieldA = 1 HOẶC 2 (Mẫu)'),
            ('FieldA=1&FieldB=2',  N'Hiện khi A=1 VÀ B=2 (Mẫu)')
    ) AS RuleList(MaQuyTac, TenQuyTac)

    -- Trả về kết quả và xử lý tìm kiếm
    SELECT 
        MaQuyTac,
        TenQuyTac
    FROM #TempVisible
    WHERE 
        (@Keyword IS NULL OR @Keyword = '')
        OR TenQuyTac LIKE N'%' + @Keyword + '%'
        OR MaQuyTac LIKE N'%' + @Keyword + '%';
        
    DROP TABLE #TempVisible;
END
GO
