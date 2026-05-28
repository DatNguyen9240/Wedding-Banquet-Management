USE [QLTiec]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- API: Lấy danh sách gợi ý Ràng buộc dữ liệu (Validate Rule)
-- =============================================
CREATE PROCEDURE [dbo].[API_ComboValidateRule]
    @Keyword NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Đẩy dữ liệu tĩnh vào bảng tạm
    SELECT * INTO #TempValidate FROM (
        VALUES 
            ('', N'Không ràng buộc'),
            ('email',  N'Định dạng Email hợp lệ'),
            ('regex:^(03|05|07|08|09|01[2|6|8|9])+([0-9]{8})$',  N'Số điện thoại (10-11 số)'),
            ('regex:^\\d+$',  N'Chỉ cho phép nhập số'),
            ('regex:^(https?://)?([\\da-z\\.-]+)\\.([a-z\\.]{2,6})([/\\w \\.-]*)*\\/?$',  N'Định dạng đường dẫn trang web'),
            ('regex:^\\d{9}(\\d{3})?$', N'Căn cước công dân (12 số)'),
            ('regex:^\\d{10}(-\\d{3})?$', N'Mã số thuế (10 hoặc 13 số)'),
            ('date', N'Định dạng ngày tháng hợp lệ'),
            ('min:5', N'Ít nhất 5 ký tự (Mẫu)'),
            ('max:50', N'Tối đa 50 ký tự (Mẫu)'),
            ('minval:1000', N'Giá trị >= 1000 (Mẫu)'),
            ('maxval:100', N'Giá trị <= 100 (Mẫu)')
    ) AS RuleList(MaRangBuoc, TenRangBuoc)

    -- Trả về kết quả và xử lý tìm kiếm
    SELECT 
        MaRangBuoc,
        TenRangBuoc
    FROM #TempValidate
    WHERE 
        (@Keyword IS NULL OR @Keyword = '')
        OR TenRangBuoc LIKE N'%' + @Keyword + '%'
        OR MaRangBuoc LIKE N'%' + @Keyword + '%';
        
    DROP TABLE #TempValidate;
END
GO
