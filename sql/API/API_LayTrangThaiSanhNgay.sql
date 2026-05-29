IF OBJECT_ID('API_LayTrangThaiSanhNgay', 'P') IS NOT NULL
    DROP PROCEDURE API_LayTrangThaiSanhNgay;
GO

CREATE PROCEDURE API_LayTrangThaiSanhNgay
    @NgayToChuc DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF @NgayToChuc IS NULL SET @NgayToChuc = GETDATE();

    SELECT 
        s.Sanhtiecid AS [id],
        s.Tensanhtiec AS [name],
        ISNULL(s.Succhua, s.SLBanMax) AS [capacity],
        -- Tính toán trạng thái: BAO_TRI > DA_KY > DA_COC > TRONG
        CASE 
            WHEN ISNULL(s.IsTamngung, 0) = 1 THEN 'BAO_TRI'
            WHEN hd.Sohopdong IS NOT NULL THEN 'DA_KY'
            WHEN bn.DocumentID IS NOT NULL THEN 'DA_COC'
            ELSE 'TRONG'
        END AS [status],
        -- Lấy tên khách hàng tương ứng
        CASE 
            WHEN hd.Sohopdong IS NOT NULL THEN ISNULL(kh_hd.Tenkh, kh_hd.Tenchure)
            WHEN bn.DocumentID IS NOT NULL THEN ISNULL(kh_bn.Tenkh, kh_bn.Tenchure)
            ELSE NULL
        END AS [customer],
        -- Lấy ca tiệc
        CASE 
            WHEN hd.Sohopdong IS NOT NULL THEN (SELECT TOP 1 Thoigian FROM dmThoigian WHERE Thoigianid = hd.Thoigianid)
            WHEN bn.DocumentID IS NOT NULL THEN (SELECT TOP 1 Thoigian FROM dmThoigian WHERE Thoigianid = bn.Thoigianid)
            ELSE NULL
        END AS [session]
    FROM dmSanhtiec s
    -- Dùng OUTER APPLY để chỉ lấy 1 Phiếu cọc hợp lệ nhất trong ngày cho sảnh này
    OUTER APPLY (
        SELECT TOP 1 b.DocumentID, b.Makh, b.Thoigianid
        FROM tbmk_Biennhancocchosanhtiec bs
        INNER JOIN tbmk_Biennhancoccho b ON bs.DocumentID = b.DocumentID
        WHERE bs.Sanhtiecid = s.Sanhtiecid 
          AND CAST(b.Ngaytochuc AS DATE) = @NgayToChuc
          AND ISNULL(b.IsHuy, 0) = 0 
          AND ISNULL(b.IsKetthuc, 0) = 0
        ORDER BY b.DateCreate DESC
    ) bn

    -- Dùng OUTER APPLY để chỉ lấy 1 Hợp đồng hợp lệ nhất trong ngày cho sảnh này
    OUTER APPLY (
        SELECT TOP 1 h.Sohopdong, h.Makh, h.Thoigianid
        FROM tbmk_Hopdongsanhtiec hs
        INNER JOIN tbmk_Hopdong h ON hs.Sohopdong = h.Sohopdong
        WHERE hs.Sanhtiecid = s.Sanhtiecid 
          AND CAST(h.Ngaytochuc AS DATE) = @NgayToChuc
          AND ISNULL(h.IsHuy, 0) = 0
        ORDER BY h.DateCreate DESC
    ) hd

    -- Lấy tên khách hàng
    LEFT JOIN dmkhachhang kh_bn ON bn.Makh = kh_bn.Makh
    LEFT JOIN dmkhachhang kh_hd ON hd.Makh = kh_hd.Makh
    ORDER BY s.Tensanhtiec ASC;
END
GO
