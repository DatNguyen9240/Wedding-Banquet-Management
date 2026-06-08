-- =====================================================================
-- SQL CẤU HÌNH WA_API CHO QUYẾT TOÁN (CHECKOUT)
-- Đảm bảo CSDL gánh hết luồng xử lý định tuyến
-- =====================================================================

-- 1. Xóa cấu hình cũ (nếu có) để tránh trùng lặp
DELETE FROM WA_API 
WHERE (List = 'frmQuyetToan' AND Func IN ('View', 'Save'));

-- 2. Cấu hình định tuyến cho Danh sách Quyết toán (frmQuyetToan)
INSERT INTO WA_API (List, Func, [SQL], Para)
VALUES 
(
    'frmQuyetToan', 
    'View', 
    'API_DanhSachQuyetToan', 
    '@Keyword=N''{Keyword}'', @DocumentID=N''{DocumentID}'', @Sohopdong=N''{Sohopdong}'''
),
(
    'frmQuyetToan', 
    'Save', 
    'API_LuuQuyenToan', 
    '@DocumentID=N''{DocumentID}'', @DocumentDate=N''{DocumentDate}'', @Sohopdong=N''{Sohopdong}'', @Nguoinop=N''{Nguoinop}'', @Tongtiencoc=N''{Tongtiencoc}'', @TongtienHoaDon=N''{TongtienHoaDon}'', @Thanhtoan=N''{Thanhtoan}'', @Conlai=N''{Conlai}'', @IsKetthuc=N''{IsKetthuc}'', @Ghichu=N''{Ghichu}'', @User=N''{UserName}'''
);
GO
