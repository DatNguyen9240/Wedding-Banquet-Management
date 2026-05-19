USE [QLTiec]
GO

/****** Object:  StoredProcedure [dbo].[API_ThucDon_List] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
  API Lấy danh sách Món Ăn (Thực đơn Mặn / Chay / Nước uống)
  Sử dụng dữ liệu thật từ DB: dmHanghoa, dmHanghoadg, dmNhomhang
*/
CREATE PROCEDURE [dbo].[API_ThucDon_List]
    @Keyword NVARCHAR(100) = '',
    @PhanLoai NVARCHAR(50) = '', 
    @IsChay INT = -1             
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        h.Mahang AS MaMon,
        h.Tenhang AS TenMon,
        ISNULL(n.Tennhomhang, N'Khác') AS PhanLoai,
        ISNULL(dg.Dongia, 0) AS DonGia,
        -- Tạm thời giả định món Chay nếu tên có chữ 'Chay' (vì DB không có cột IsChay)
        CASE WHEN h.Tenhang LIKE N'%chay%' THEN 1 ELSE 0 END AS IsChay,
        ISNULL(h.IsMacDinhHopDong, 0) AS IsMacDinhHopDong,
        1 AS TrangThai
    FROM 
        [dbo].[dmHanghoa] h
    LEFT JOIN 
        [dbo].[dmNhomhang] n ON h.Nhomhangid = n.NhomhangID
    OUTER APPLY (
        -- Lấy đơn giá mới nhất của mặt hàng
        SELECT TOP 1 Dongia 
        FROM [dbo].[dmHanghoadg] 
        WHERE Mahang = h.Mahang 
        ORDER BY Ngay DESC, DateCreate DESC
    ) dg
    WHERE 
        ISNULL(h.IsNgungSuDung, 0) = 0
        AND (@Keyword = '' OR h.Tenhang LIKE N'%' + @Keyword + '%' OR h.Mahang LIKE '%' + @Keyword + '%')
        AND (@PhanLoai = '' OR n.Tennhomhang = @PhanLoai)
        -- Lọc mặn/chay nếu có yêu cầu
        AND (@IsChay = -1 
             OR (@IsChay = 1 AND h.Tenhang LIKE N'%chay%') 
             OR (@IsChay = 0 AND h.Tenhang NOT LIKE N'%chay%'))
    ORDER BY 
        -- Ưu tiên sắp xếp theo nhóm hàng
        CASE 
            WHEN n.Tennhomhang LIKE N'%Khai vị%' THEN 1
            WHEN n.Tennhomhang LIKE N'%Món chính%' OR n.Tennhomhang LIKE N'%Cơm%' OR n.Tennhomhang LIKE N'%Lẩu%' THEN 2
            WHEN n.Tennhomhang LIKE N'%Tráng miệng%' THEN 3
            WHEN n.Tennhomhang LIKE N'%Bia%' OR n.Tennhomhang LIKE N'%Nước%' THEN 4
            ELSE 5 
        END ASC,
        h.Tenhang ASC;
END
GO
