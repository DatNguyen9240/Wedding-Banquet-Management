USE [QLTiec]
GO

PRINT N'Đang cập nhật định tuyến nút Xóa (Delete) cho các phân hệ chính trong WA_API...';

-- ==========================================================
-- 1. Định tuyến Xóa Hợp đồng (frmHopDong) -> API_XoaHopDong
-- ==========================================================
IF EXISTS (SELECT 1 FROM WA_API WHERE List = 'frmHopDong' AND Func = 'Delete')
BEGIN
    UPDATE WA_API
    SET SQL = 'API_XoaHopDong',
        Para = '@Ids=N''{Sohopdong}'', @UserName=N''{User}'''
    WHERE List = 'frmHopDong' AND Func = 'Delete';
END
ELSE
BEGIN
    INSERT INTO WA_API (List, Func, [SQL], Para)
    VALUES ('frmHopDong', 'Delete', 'API_XoaHopDong', '@Ids=N''{Sohopdong}'', @UserName=N''{User}''');
END

-- ==========================================================
-- 2. Định tuyến Xóa Phụ lục Thay đổi (frmThayDoiBoSung) -> API_XoaThayDoi
-- ==========================================================
IF EXISTS (SELECT 1 FROM WA_API WHERE List = 'frmThayDoiBoSung' AND Func = 'Delete')
BEGIN
    UPDATE WA_API
    SET SQL = 'API_XoaThayDoi',
        Para = '@Ids=N''{Sothaydoi}'', @UserName=N''{UserName}'''
    WHERE List = 'frmThayDoiBoSung' AND Func = 'Delete';
END
ELSE
BEGIN
    INSERT INTO WA_API (List, Func, [SQL], Para)
    VALUES ('frmThayDoiBoSung', 'Delete', 'API_XoaThayDoi', '@Ids=N''{Sothaydoi}'', @UserName=N''{UserName}''');
END

-- ==========================================================
-- 3. Định tuyến Xóa Phiếu Cọc (frmBiennhancoccho) -> API_XoaPhieuCoc
-- ==========================================================
IF EXISTS (SELECT 1 FROM WA_API WHERE List = 'frmBiennhancoccho' AND Func = 'Delete')
BEGIN
    UPDATE WA_API
    SET SQL = 'API_XoaPhieuCoc',
        Para = '@DocumentIDs=N''{DocumentID}'', @UserName=N''{UserName}'''
    WHERE List = 'frmBiennhancoccho' AND Func = 'Delete';
END
ELSE
BEGIN
    INSERT INTO WA_API (List, Func, [SQL], Para)
    VALUES ('frmBiennhancoccho', 'Delete', 'API_XoaPhieuCoc', '@DocumentIDs=N''{DocumentID}'', @UserName=N''{UserName}''');
END

-- ==========================================================
-- 4. Định tuyến Xóa Phiếu Thu / Quyết toán (frmPhieuThu / tbmk_Phieuthu) -> API_XoaPhieuThu
-- ==========================================================
-- Cấu hình cho cả frmPhieuThu và các định danh phiếu thu khác nếu có
IF EXISTS (SELECT 1 FROM WA_API WHERE List = 'frmPhieuThu' AND Func = 'Delete')
BEGIN
    UPDATE WA_API
    SET SQL = 'API_XoaPhieuThu',
        Para = '@Ids=N''{DocumentID}'', @UserName=N''{UserName}'''
    WHERE List = 'frmPhieuThu' AND Func = 'Delete';
END
ELSE
BEGIN
    INSERT INTO WA_API (List, Func, [SQL], Para)
    VALUES ('frmPhieuThu', 'Delete', 'API_XoaPhieuThu', '@Ids=N''{DocumentID}'', @UserName=N''{UserName}''');
END

IF EXISTS (SELECT 1 FROM WA_API WHERE List = 'tbmk_Phieuthu' AND Func = 'Delete')
BEGIN
    UPDATE WA_API
    SET SQL = 'API_XoaPhieuThu',
        Para = '@Ids=N''{DocumentID}'', @UserName=N''{UserName}'''
    WHERE List = 'tbmk_Phieuthu' AND Func = 'Delete';
END
ELSE
BEGIN
    INSERT INTO WA_API (List, Func, [SQL], Para)
    VALUES ('tbmk_Phieuthu', 'Delete', 'API_XoaPhieuThu', '@Ids=N''{DocumentID}'', @UserName=N''{UserName}''');
END

PRINT N'Cập nhật định tuyến nút Xóa chuyên dụng thành công!';
GO
