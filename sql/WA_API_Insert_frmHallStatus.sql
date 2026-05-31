-- =============================================
-- Mô tả: API lấy trạng thái Sảnh theo Ngày Tổ Chức
-- Endpoint: frmHallStatus - View
-- =============================================

IF NOT EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'API_LayTrangThaiSanhNgay')
BEGIN
    EXEC('CREATE PROCEDURE [dbo].[API_LayTrangThaiSanhNgay] AS BEGIN SET NOCOUNT ON; END')
END
GO

ALTER PROCEDURE [dbo].[API_LayTrangThaiSanhNgay]
    @NgayToChuc VARCHAR(20) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    IF @NgayToChuc IS NULL OR @NgayToChuc = ''
    BEGIN
        SET @NgayToChuc = CONVERT(VARCHAR(10), GETDATE(), 120);
    END

    -- Mock Data Hoặc Query Thật:
    -- Dưới đây là Query nối bảng SanhTiec và HopDong
    -- Để trả về Trạng thái thật của các sảnh trong 1 ngày cụ thể
    
    SELECT 
        s.MaSanh AS id,
        s.TenSanh AS name,
        s.Tang AS floor,
        s.SucChuaToiDa AS capacity,
        -- Logic Trạng thái: Nếu có Hợp đồng -> DA_KY, nếu có Phiếu Đặt Cọc -> DA_COC, nếu bảo trì -> BAO_TRI, còn lại -> TRONG
        CASE 
            WHEN hd.TrangThai = 'DA_KY' THEN 'DA_KY'
            WHEN hd.TrangThai = 'DA_COC' THEN 'DA_COC'
            WHEN s.TrangThai = 'BAO_TRI' THEN 'BAO_TRI'
            ELSE 'TRONG'
        END AS status,
        hd.MaHopDong AS contractId,
        hd.TenKhachHang AS customerName,
        hd.SoBanThucTe AS tables
    FROM 
        SanhTiec s
    LEFT JOIN 
        HopDongTiec hd ON s.MaSanh = hd.MaSanh AND CONVERT(VARCHAR(10), hd.NgayToChuc, 120) = @NgayToChuc
    WHERE 
        s.DaXoa = 0;
END
GO

-- Đăng ký API vào hệ thống Gateway
DELETE FROM WA_API WHERE APIID = 'frmHallStatus_View';
INSERT INTO WA_API (APIID, APIName, StoreName, Params, NeedToken, IsActive)
VALUES (
    'frmHallStatus_View',
    N'Lấy Trạng thái sảnh tiệc theo ngày',
    'API_LayTrangThaiSanhNgay',
    'NgayToChuc',
    1,
    1
);
GO
