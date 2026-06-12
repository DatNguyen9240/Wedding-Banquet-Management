USE [QLTiec]
GO

-- =========================================================================
-- UPDATE_DOCX_MENUDICHVU_ALLINONE.SQL
-- Triển khai bộ hàm fn_DOCX_* dùng chung cho xuất Word (menu / dịch vụ)
-- Chạy file này TRƯỚC khi chạy Update_frmHopDong / BEO / PhuLuc / QuyetToan
-- =========================================================================

PRINT N'=== TRIỂN KHAI fn_DOCX_* (MENU & DỊCH VỤ CHO DOCX) ===';
GO

-- Nội dung hàm: sql/Functions/fn_DOCX_MenuDichVu.sql
-- (giữ một nguồn duy nhất — deploy bằng cách chạy file Functions trực tiếp)

IF OBJECT_ID(N'dbo.fn_DOCX_DanhSachMenu', N'FN') IS NULL
BEGIN
    RAISERROR(N'Chưa có fn_DOCX_DanhSachMenu. Hãy chạy sql/Functions/fn_DOCX_MenuDichVu.sql trước.', 16, 1);
END
ELSE
BEGIN
    PRINT N'✓ Bộ hàm fn_DOCX_* đã sẵn sàng.';
END
GO

PRINT N'=== HOÀN TẤT KIỂM TRA fn_DOCX_* ===';
GO
