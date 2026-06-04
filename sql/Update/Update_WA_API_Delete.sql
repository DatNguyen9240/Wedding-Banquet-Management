USE [QLTiec]
GO

-- 1. Cấu hình hành động Xóa (Delete) trong cổng API WA_API cho frmHopDong
-- Sử dụng API_XoaDong, ánh xạ tham số @Ids từ trường {id} tự sinh bởi DynamicFormEngine
DELETE FROM WA_API WHERE List = 'frmHopDong' AND Func = 'Delete';
INSERT INTO WA_API (List, Func, [SQL], Para)
VALUES (
    'frmHopDong', 
    'Delete', 
    'API_XoaDong', 
    '@List=N''frmHopDong'', @Ids=N''{id}'', @UserName=N''{User}'''
);
GO

-- 2. Cấu hình hành động Xóa (Delete) trong cổng API WA_API cho frmThayDoiBoSung
-- Sử dụng API_XoaDong, ánh xạ tham số @Ids từ trường {id} tự sinh bởi DynamicFormEngine
DELETE FROM WA_API WHERE List = 'frmThayDoiBoSung' AND Func = 'Delete';
INSERT INTO WA_API (List, Func, [SQL], Para)
VALUES (
    'frmThayDoiBoSung', 
    'Delete', 
    'API_XoaDong', 
    '@List=N''frmThayDoiBoSung'', @Ids=N''{id}'', @UserName=N''{User}'''
);
GO

-- 3. Cấu hình hành động Xóa (Delete) trong cổng API WA_API cho frmBiennhancoccho
-- Sử dụng API_XoaPhieuCoc, ánh xạ tham số @DocumentIDs từ trường {id} tự sinh bởi DynamicFormEngine
DELETE FROM WA_API WHERE List = 'frmBiennhancoccho' AND Func = 'Delete';
INSERT INTO WA_API (List, Func, [SQL], Para)
VALUES (
    'frmBiennhancoccho', 
    'Delete', 
    'API_XoaPhieuCoc', 
    '@DocumentIDs=N''{id}'', @UserName=N''{User}'''
);
GO

PRINT N'>> ĐÃ CẬP NHẬT CẤU HÌNH WA_API DELETE THÀNH CÔNG!';
GO
