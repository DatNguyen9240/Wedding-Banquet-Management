CREATE OR ALTER PROCEDURE [dbo].[API_DanhSachQuyetToan]
    @Keyword NVARCHAR(100) = NULL,
    @DocumentID VARCHAR(50) = NULL,
    @Sohopdong VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        -- Original Columns (for Grid/UI compatibility)
        pt.DocumentID,
        pt.DocumentDate,
        pt.Sohopdong,
        hd.Tentiec,
        kh.Tenkh,
        pt.Nguoinop,
        pt.Manv,
        pt.TongtienHoaDon,
        pt.Tongtiencoc,
        pt.Thanhtoan,
        pt.Conlai,
        pt.IsKetthuc,
        pt.IsHoaDon,
        pt.IsXacNhanKeToan,
        pt.Ghichu,

        -- Standardized Spaced, Accented Vietnamese Columns (for Print placeholders)
        pt.DocumentID AS [Mã chứng từ],
        pt.Sohopdong AS [Số hợp đồng],
        kh.Tenkh AS [Khách hàng],
        ISNULL((SELECT TOP 1 Tenloaitiec FROM dmLoaihinhtiec WHERE Loaitiecid = hd.Loaitiecid), N'TIỆC CƯỚI') AS [Loại hình SK],
        ISNULL((SELECT TOP 1 nv.Tennv FROM dmNhanvienView nv WHERE nv.Manv = pt.Manv), pt.Manv) AS [NVKD],
        
        -- Số lượng khách & Sảnh tiệc & Ngày tổ chức
        CAST(ISNULL(hd.TongSoBan, 0) AS VARCHAR) + N' BÀN (' + CAST(ISNULL(hd.TongSoBan * 10, 0) AS VARCHAR) + N' KHÁCH)' AS [Số lượng khách],
        (SELECT TOP 1 s.Tensanhtiec FROM tbmk_Hopdongsanhtiec hs INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid WHERE hs.Sohopdong = pt.Sohopdong) AS [Sảnh tiệc],
        CONVERT(VARCHAR(10), hd.Ngaytochuc, 103) AS [Ngày tổ chức],
        ISNULL(hd.GioDienRaSuKien, N'Chưa xác định') AS [Thời gian],

        -- Ngày/Tháng/Năm Quyết toán
        RIGHT('0' + CAST(DAY(ISNULL(pt.DocumentDate, GETDATE())) AS VARCHAR), 2) AS [Ngày quyết toán],
        RIGHT('0' + CAST(MONTH(ISNULL(pt.DocumentDate, GETDATE())) AS VARCHAR), 2) AS [Tháng quyết toán],
        YEAR(ISNULL(pt.DocumentDate, GETDATE())) AS [Năm quyết toán],

        -- Bảng tổng hợp & tính toán chi tiết
        CASE WHEN (ISNULL(hd.Tongtienbanman, 0) + ISNULL(hd.Tongtienbanchay, 0) + ISNULL(hd.Tongtienthucuong, 0) + ISNULL(hd.Tongtiendichvu, 0)) = 0 THEN N'-' ELSE FORMAT((ISNULL(hd.Tongtienbanman, 0) + ISNULL(hd.Tongtienbanchay, 0) + ISNULL(hd.Tongtienthucuong, 0) + ISNULL(hd.Tongtiendichvu, 0)), 'N0', 'vi-VN') END AS [Cộng 1],
        CASE WHEN (ISNULL(pt.Sotienphatsinh, 0) + ISNULL(pt.PhiBuSanh, 0) + ISNULL(pt.PhiBuBanTang, 0) + ISNULL(pt.PhiBuTTS, 0) + ISNULL(pt.PhiBuNTL, 0)) = 0 THEN N'-' ELSE FORMAT((ISNULL(pt.Sotienphatsinh, 0) + ISNULL(pt.PhiBuSanh, 0) + ISNULL(pt.PhiBuBanTang, 0) + ISNULL(pt.PhiBuTTS, 0) + ISNULL(pt.PhiBuNTL, 0)), 'N0', 'vi-VN') END AS [Cộng 2],
        CASE WHEN ((ISNULL(hd.Tongtienbanman, 0) + ISNULL(hd.Tongtienbanchay, 0) + ISNULL(hd.Tongtienthucuong, 0) + ISNULL(hd.Tongtiendichvu, 0)) + (ISNULL(pt.Sotienphatsinh, 0) + ISNULL(pt.PhiBuSanh, 0) + ISNULL(pt.PhiBuBanTang, 0) + ISNULL(pt.PhiBuTTS, 0) + ISNULL(pt.PhiBuNTL, 0))) = 0 THEN N'-' ELSE FORMAT(((ISNULL(hd.Tongtienbanman, 0) + ISNULL(hd.Tongtienbanchay, 0) + ISNULL(hd.Tongtienthucuong, 0) + ISNULL(hd.Tongtiendichvu, 0)) + (ISNULL(pt.Sotienphatsinh, 0) + ISNULL(pt.PhiBuSanh, 0) + ISNULL(pt.PhiBuBanTang, 0) + ISNULL(pt.PhiBuTTS, 0) + ISNULL(pt.PhiBuNTL, 0))), 'N0', 'vi-VN') END AS [Tổng cộng 1 và 2],
        CASE WHEN ISNULL(pt.PhiPhucVu, 0) = 0 THEN N'-' ELSE FORMAT(pt.PhiPhucVu, 'N0', 'vi-VN') END AS [Phí phục vụ],
        CASE WHEN ((ISNULL(hd.Tongtienbanman, 0) + ISNULL(hd.Tongtienbanchay, 0) + ISNULL(hd.Tongtienthucuong, 0) + ISNULL(hd.Tongtiendichvu, 0)) + (ISNULL(pt.Sotienphatsinh, 0) + ISNULL(pt.PhiBuSanh, 0) + ISNULL(pt.PhiBuBanTang, 0) + ISNULL(pt.PhiBuTTS, 0) + ISNULL(pt.PhiBuNTL, 0)) + ISNULL(pt.PhiPhucVu, 0)) = 0 THEN N'-' ELSE FORMAT(((ISNULL(hd.Tongtienbanman, 0) + ISNULL(hd.Tongtienbanchay, 0) + ISNULL(hd.Tongtienthucuong, 0) + ISNULL(hd.Tongtiendichvu, 0)) + (ISNULL(pt.Sotienphatsinh, 0) + ISNULL(pt.PhiBuSanh, 0) + ISNULL(pt.PhiBuBanTang, 0) + ISNULL(pt.PhiBuTTS, 0) + ISNULL(pt.PhiBuNTL, 0)) + ISNULL(pt.PhiPhucVu, 0)), 'N0', 'vi-VN') END AS [Tổng cộng chưa VAT],
        CASE WHEN (CASE WHEN pt.PTThueVAT = 8 THEN ISNULL(pt.TienThueVAT, 0) ELSE 0 END) = 0 THEN N'-' ELSE FORMAT(CASE WHEN pt.PTThueVAT = 8 THEN ISNULL(pt.TienThueVAT, 0) ELSE 0 END, 'N0', 'vi-VN') END AS [VAT 8],
        CASE WHEN (CASE WHEN pt.PTThueVAT = 10 THEN ISNULL(pt.TienThueVAT, 0) ELSE 0 END) = 0 THEN N'-' ELSE FORMAT(CASE WHEN pt.PTThueVAT = 10 THEN ISNULL(pt.TienThueVAT, 0) ELSE 0 END, 'N0', 'vi-VN') END AS [VAT 10],
        CASE WHEN ISNULL(pt.TongtienHoaDon, 0) = 0 THEN N'-' ELSE FORMAT(pt.TongtienHoaDon, 'N0', 'vi-VN') END AS [Tổng tiền],
        CASE WHEN ISNULL(pt.Tongtiencoc, 0) = 0 THEN N'-' ELSE FORMAT(pt.Tongtiencoc, 'N0', 'vi-VN') END AS [Trừ cọc],
        CASE WHEN ISNULL(pt.Conlai, 0) = 0 THEN N'-' ELSE FORMAT(pt.Conlai, 'N0', 'vi-VN') END AS [Thanh toán còn lại],

        -- Dữ liệu mảng JSON cho Table Loops (docxtemplater)
        (
            SELECT 
                COALESCE(t.RowNum, n.n) AS [STT],
                ISNULL(t.[Diễn giải], N'') AS [Diễn giải],
                ISNULL(t.[ĐVT], N'') AS [ĐVT],
                ISNULL(CAST(t.[Số lượng] AS NVARCHAR(50)), N'') AS [Số lượng],
                ISNULL(t.[Đơn giá], N'') AS [Đơn giá],
                ISNULL(t.[Thành tiền], N'-') AS [Thành tiền]
            FROM (SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3) n
            FULL OUTER JOIN (
                SELECT 
                    ROW_NUMBER() OVER (ORDER BY sort_order) AS RowNum,
                    [Diễn giải], [ĐVT], [Số lượng], [Đơn giá], [Thành tiền]
                FROM (
                    -- Wedding items (only if greater than 0)
                    SELECT N'Bàn tiệc mặn' AS [Diễn giải], N'Bàn' AS [ĐVT], ISNULL(hd.SobanManchinhthuc, 0) AS [Số lượng], FORMAT(ISNULL(hd.Giabanman, 0), 'N0', 'vi-VN') AS [Đơn giá], FORMAT(ISNULL(hd.Tongtienbanman, 0), 'N0', 'vi-VN') AS [Thành tiền], ISNULL(hd.Tongtienbanman, 0) AS val, 1 AS sort_order
                    WHERE ISNULL(hd.Tongtienbanman, 0) > 0
                    UNION ALL
                    SELECT N'Bàn tiệc chay' AS [Diễn giải], N'Bàn' AS [ĐVT], ISNULL(hd.SobanChaychinhthuc, 0) AS [Số lượng], FORMAT(ISNULL(hd.Giabanchay, 0), 'N0', 'vi-VN') AS [Đơn giá], FORMAT(ISNULL(hd.Tongtienbanchay, 0), 'N0', 'vi-VN') AS [Thành tiền], ISNULL(hd.Tongtienbanchay, 0) AS val, 2 AS sort_order
                    WHERE ISNULL(hd.SobanChaychinhthuc, 0) > 0
                    UNION ALL
                    SELECT N'Thức uống' AS [Diễn giải], N'Gói' AS [ĐVT], 1 AS [Số lượng], FORMAT(ISNULL(hd.Tongtienthucuong, 0), 'N0', 'vi-VN') AS [Đơn giá], FORMAT(ISNULL(hd.Tongtienthucuong, 0), 'N0', 'vi-VN') AS [Thành tiền], ISNULL(hd.Tongtienthucuong, 0) AS val, 3 AS sort_order
                    WHERE ISNULL(hd.Tongtienthucuong, 0) > 0
                    UNION ALL
                    SELECT N'Dịch vụ cưới & Trang trí' AS [Diễn giải], N'Gói' AS [ĐVT], 1 AS [Số lượng], FORMAT(ISNULL(hd.Tongtiendichvu, 0), 'N0', 'vi-VN') AS [Đơn giá], FORMAT(ISNULL(hd.Tongtiendichvu, 0), 'N0', 'vi-VN') AS [Thành tiền], ISNULL(hd.Tongtiendichvu, 0) AS val, 4 AS sort_order
                    WHERE ISNULL(hd.Tongtiendichvu, 0) > 0
                    
                    -- Conference items (always included if no wedding items exist or as defaults)
                    UNION ALL
                    SELECT 
                        N'Phí thuê sảnh ' + ISNULL((SELECT TOP 1 s.Tensanhtiec FROM tbmk_Hopdongsanhtiec hs INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid WHERE hs.Sohopdong = pt.Sohopdong), N'Queen 1+2') AS [Diễn giải], 
                        N'Nửa ngày' AS [ĐVT], 
                        NULL AS [Số lượng], 
                        CASE WHEN ISNULL(pt.PhiBuSanh, 0) > 0 THEN FORMAT(pt.PhiBuSanh, 'N0', 'vi-VN') ELSE NULL END AS [Đơn giá], 
                        CASE WHEN ISNULL(pt.PhiBuSanh, 0) > 0 THEN FORMAT(pt.PhiBuSanh, 'N0', 'vi-VN') ELSE NULL END AS [Thành tiền],
                        1 AS val,
                        5 AS sort_order
                    UNION ALL
                    SELECT 
                        N'Phụ thu khách mang nước suối vào nhà hàng' AS [Diễn giải], 
                        N'Thùng' AS [ĐVT], 
                        NULL AS [Số lượng], 
                        NULL AS [Đơn giá], 
                        NULL AS [Thành tiền],
                        1 AS val,
                        6 AS sort_order
                    UNION ALL
                    SELECT 
                        N'Màn hình Led 24m2' AS [Diễn giải], 
                        N'Show' AS [ĐVT], 
                        NULL AS [Số lượng], 
                        NULL AS [Đơn giá], 
                        NULL AS [Thành tiền],
                        1 AS val,
                        7 AS sort_order
                ) sub
            ) t ON n.n = t.RowNum
            ORDER BY [STT]
            FOR JSON PATH
        ) AS [DanhSachDichVu],

        (
            SELECT 
                COALESCE(t.RowNum, n.n) AS [STT],
                ISNULL(t.[Diễn giải], N'') AS [Diễn giải],
                ISNULL(t.[ĐVT], N'') AS [ĐVT],
                ISNULL(CAST(t.[Số lượng] AS NVARCHAR(50)), N'') AS [Số lượng],
                ISNULL(t.[Đơn giá], N'') AS [Đơn giá],
                ISNULL(t.[Thành tiền], N'-') AS [Thành tiền]
            FROM (SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3) n
            FULL OUTER JOIN (
                SELECT 
                    ROW_NUMBER() OVER (ORDER BY sort_order) AS RowNum,
                    [Diễn giải], [ĐVT], [Số lượng], [Đơn giá], [Thành tiền]
                FROM (
                    SELECT N'Chi phí phát sinh' AS [Diễn giải], N'Lần' AS [ĐVT], 1 AS [Số lượng], FORMAT(ISNULL(pt.Sotienphatsinh, 0), 'N0', 'vi-VN') AS [Đơn giá], FORMAT(ISNULL(pt.Sotienphatsinh, 0), 'N0', 'vi-VN') AS [Thành tiền], ISNULL(pt.Sotienphatsinh, 0) AS val, 1 AS sort_order
                    UNION ALL
                    SELECT N'Phí bù sảnh' AS [Diễn giải], N'Lần' AS [ĐVT], 1 AS [Số lượng], FORMAT(ISNULL(pt.PhiBuSanh, 0), 'N0', 'vi-VN') AS [Đơn giá], FORMAT(ISNULL(pt.PhiBuSanh, 0), 'N0', 'vi-VN') AS [Thành tiền], ISNULL(pt.PhiBuSanh, 0) AS val, 2 AS sort_order
                    UNION ALL
                    SELECT N'Phí bù bàn tăng' AS [Diễn giải], N'Lần' AS [ĐVT], 1 AS [Số lượng], FORMAT(ISNULL(pt.PhiBuBanTang, 0), 'N0', 'vi-VN') AS [Đơn giá], FORMAT(ISNULL(pt.PhiBuBanTang, 0), 'N0', 'vi-VN') AS [Thành tiền], ISNULL(pt.PhiBuBanTang, 0) AS val, 3 AS sort_order
                    UNION ALL
                    SELECT N'Phí bù trang trí sảnh' AS [Diễn giải], N'Lần' AS [ĐVT], 1 AS [Số lượng], FORMAT(ISNULL(pt.PhiBuTTS, 0), 'N0', 'vi-VN') AS [Đơn giá], FORMAT(ISNULL(pt.PhiBuTTS, 0), 'N0', 'vi-VN') AS [Thành tiền], ISNULL(pt.PhiBuTTS, 0) AS val, 4 AS sort_order
                    UNION ALL
                    SELECT N'Phí bù nghi thức lễ' AS [Diễn giải], N'Lần' AS [ĐVT], 1 AS [Số lượng], FORMAT(ISNULL(pt.PhiBuNTL, 0), 'N0', 'vi-VN') AS [Đơn giá], FORMAT(ISNULL(pt.PhiBuNTL, 0), 'N0', 'vi-VN') AS [Thành tiền], ISNULL(pt.PhiBuNTL, 0) AS val, 5 AS sort_order
                ) sub
                WHERE val > 0
            ) t ON n.n = t.RowNum
            ORDER BY [STT]
            FOR JSON PATH
        ) AS [DichVuPhatSinh]

    FROM tbmk_Phieuthu pt
    LEFT JOIN tbmk_Hopdong hd ON pt.Sohopdong = hd.Sohopdong
    LEFT JOIN dmkhachhang kh ON hd.Makh = kh.Makh
    WHERE 
        (@DocumentID IS NULL OR @DocumentID = '' OR pt.DocumentID = @DocumentID)
        AND (@Sohopdong IS NULL OR @Sohopdong = '' OR pt.Sohopdong = @Sohopdong)
        AND (@Keyword IS NULL OR @Keyword = ''
             OR pt.DocumentID LIKE '%' + @Keyword + '%'
             OR pt.Sohopdong LIKE '%' + @Keyword + '%'
             OR pt.Nguoinop LIKE N'%' + @Keyword + '%'
             OR kh.Tenkh LIKE N'%' + @Keyword + '%')
    ORDER BY pt.DocumentDate DESC;
END
GO
