GO

/****** Object:  StoredProcedure [dbo].[API_Shift_List] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[API_Shift_List]
AS
BEGIN
    SET NOCOUNT ON;

    -- Truy vấn danh sách Ca Tiệc từ bảng dmThoigian
    SELECT 
        Thoigianid = ISNULL(Thoigianid, ''),
        Thoigian = ISNULL(Thoigian, ''),       -- Tên hiển thị (VD: 11h - 14h)
        GioBatDau = ISNULL(GhiBatDau, 0),      -- Đổi tên thành GioBatDau khi trả về JSON cho dễ dùng
        GioKetThuc = ISNULL(GioKetThuc, 0),
        IsTiecCuoi = ISNULL(IsTiecCuoi, 0)
    FROM 
        dmThoigian
    ORDER BY 
        GhiBatDau ASC;

END
GO
