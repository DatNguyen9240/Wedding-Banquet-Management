-- =====================================================================
-- SQL KIỂM TRA CẤU HÌNH WA_API VÀ FORMATFIELDS CHO ĐẶT CỌC & HỢP ĐỒNG
-- =====================================================================

-- 1. Xem cấu hình Form chính trong hệ thống No-Code
SELECT FormID, FormType, CaptionVN, TableName, PrimaryKey, TableDetail, TableDetailLeftJoinField
FROM SY_FrmLstTbl 
WHERE FormID IN ('frmBiennhancoccho', 'frmHopDong');

-- 2. Xem các trường cấu hình giao diện UI (FormFields)
SELECT FormName, FieldName, CaptionVN, FormatID, FormPosition, IsRequired, OrderNo, DataSource, ValidateRule
FROM SY_FormatFields 
WHERE FormName IN ('frmBiennhancoccho', 'frmHopDong')
ORDER BY FormName, OrderNo;

-- 3. Xem cấu hình định tuyến API Gateway Router (WA_API)
SELECT *
FROM WA_API 
WHERE List IN (
    'API_DanhSachPhieuCoc', 
    'API_LuuPhieuCoc', 
    'API_HuyPhieuCoc', 
    'API_XoaPhieuCoc', 
    'API_DanhSachHopDong', 
    'API_LuuHopDong'
)
OR List LIKE '%PhieuCoc%' 
OR List LIKE '%HopDong%'
ORDER BY List, Func;
