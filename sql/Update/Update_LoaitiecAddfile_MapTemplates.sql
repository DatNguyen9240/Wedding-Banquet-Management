-- =========================================================================
-- SCRIPT CHUẨN HÓA VÀ CẬP NHẬT TOÀN BỘ MAPPING FILE MẪU WORD (DOCX)
-- =========================================================================

TRUNCATE TABLE tbmk_LoaitiecAddfile;
GO

-- 1. BIÊN NHẬN CỌC TRƯỚC (frmBiennhancoccho) -> phieu_thu.docx
INSERT INTO tbmk_LoaitiecAddfile (FormName, Loaitiecid, TemplateFile, GhiChu) VALUES 
('frmBiennhancoccho', 'BLT000001', N'phieu_thu.docx', N'Phiếu thu chung'),
('frmBiennhancoccho', 'BLT000002', N'phieu_thu.docx', N'Phiếu thu chung'),
('frmBiennhancoccho', 'BLT000003', N'phieu_thu.docx', N'Phiếu thu chung'),
('frmBiennhancoccho', 'BLT000004', N'phieu_thu.docx', N'Phiếu thu chung'),
('frmBiennhancoccho', 'BLT000005', N'phieu_thu.docx', N'Phiếu thu chung');

-- 2. HỢP ĐỒNG GỐC (frmHopDong) -> Các mẫu in theo loại tiệc
INSERT INTO tbmk_LoaitiecAddfile (FormName, Loaitiecid, TemplateFile, GhiChu) VALUES 
('frmHopDong', 'BLT000001', N'hop_dong.docx', N'Mẫu in hợp đồng Tiệc Cưới'),
('frmHopDong', 'BLT000002', N'2.1 MAU HDONG - 0406 (TRIỂN LÃM + TIỆC).docx', N'Mẫu in hợp đồng Triển lãm + Tiệc'),
('frmHopDong', 'BLT000003', N'2.2 MAU HDONG - 0406 (TRIỂN LÃM).docx', N'Mẫu in hợp đồng Triển lãm'),
('frmHopDong', 'BLT000004', N'3.1 MAU HDONG - 0406 (HỘI NGHỊ + TIỆC-TEABREAK).docx', N'Mẫu in hợp đồng Hội nghị + Break Tea'),
('frmHopDong', 'BLT000005', N'3.2 MAU HDONG - 0406 (HỘI NGHỊ).docx', N'Mẫu in hợp đồng Hội nghị'),
('frmHopDong_MenuNgay', 'BLT000001', N'hop_dong_menu_ngay.docx', N'Mẫu in hợp đồng Tiệc Cưới (Chọn ngay menu)');

-- 3. BEO (frmBEO) -> BEO lần 1 (chưa thay đổi)
INSERT INTO tbmk_LoaitiecAddfile (FormName, Loaitiecid, TemplateFile, GhiChu) VALUES 
('frmBEO', 'BLT000001', N'BEO_Tiec_Cuoi.docx',                N'BEO Tiệc Cưới - Lần 1'),
('frmBEO', 'BLT000002', N'BEO TIEC CTY - Chua Thay Doi.docx', N'BEO Tiệc CTY / Hội Nghị - Lần 1'),
('frmBEO', 'BLT000003', N'BEO TIEC CTY - Chua Thay Doi.docx', N'BEO Tiệc CTY / Hội Nghị - Lần 1'),
('frmBEO', 'BLT000004', N'BEO TIEC CTY - Chua Thay Doi.docx', N'BEO Tiệc CTY / Hội Nghị - Lần 1'),
('frmBEO', 'BLT000005', N'BEO TIEC CTY - Chua Thay Doi.docx', N'BEO Tiệc CTY / Hội Nghị - Lần 1');

-- 3b. BEO sau thay đổi (frmBEO_ThayDoi) -> BEO lần 2, 3, 4...
INSERT INTO tbmk_LoaitiecAddfile (FormName, Loaitiecid, TemplateFile, GhiChu) VALUES 
('frmBEO_ThayDoi', 'BLT000001', N'BEO_Tiec_Cuoi.docx',           N'BEO Tiệc Cưới - Lần 2+'),
('frmBEO_ThayDoi', 'BLT000002', N'BEO TIEC CTY - Thay Doi.docx', N'BEO Tiệc CTY - Lần 2+'),
('frmBEO_ThayDoi', 'BLT000003', N'BEO TIEC CTY - Thay Doi.docx', N'BEO Tiệc CTY - Lần 2+'),
('frmBEO_ThayDoi', 'BLT000004', N'BEO TIEC CTY - Thay Doi.docx', N'BEO Tiệc CTY - Lần 2+'),
('frmBEO_ThayDoi', 'BLT000005', N'BEO TIEC CTY - Thay Doi.docx', N'BEO Tiệc CTY - Lần 2+');

-- 4. BÁO GIÁ (frmBaoGia) -> bao_gia.docx
INSERT INTO tbmk_LoaitiecAddfile (FormName, Loaitiecid, TemplateFile, GhiChu) VALUES 
('frmBaoGia', 'BLT000001', N'bao_gia.docx', N'Mẫu Báo Giá'),
('frmBaoGia', 'BLT000002', N'bao_gia.docx', N'Mẫu Báo Giá'),
('frmBaoGia', 'BLT000003', N'bao_gia.docx', N'Mẫu Báo Giá'),
('frmBaoGia', 'BLT000004', N'bao_gia.docx', N'Mẫu Báo Giá'),
('frmBaoGia', 'BLT000005', N'bao_gia.docx', N'Mẫu Báo Giá');

-- 5. PHỤ LỤC HỢP ĐỒNG (frmPhuLucHopDong) -> phu_luc_hop_dong.docx
INSERT INTO tbmk_LoaitiecAddfile (FormName, Loaitiecid, TemplateFile, GhiChu) VALUES 
('frmPhuLucHopDong', 'BLT000001', N'phu_luc_hop_dong.docx', N'Phụ lục Hợp đồng'),
('frmPhuLucHopDong', 'BLT000002', N'phu_luc_hop_dong.docx', N'Phụ lục Hợp đồng'),
('frmPhuLucHopDong', 'BLT000003', N'phu_luc_hop_dong.docx', N'Phụ lục Hợp đồng'),
('frmPhuLucHopDong', 'BLT000004', N'phu_luc_hop_dong.docx', N'Phụ lục Hợp đồng'),
('frmPhuLucHopDong', 'BLT000005', N'phu_luc_hop_dong.docx', N'Phụ lục Hợp đồng');

-- 6. ĐỀ NGHỊ THAY ĐỔI / PHỤ LỤC KHÁC (frmThayDoiBoSung) -> de_nghi_thay_doi.docx
INSERT INTO tbmk_LoaitiecAddfile (FormName, Loaitiecid, TemplateFile, GhiChu) VALUES 
('frmThayDoiBoSung', 'BLT000001', N'de_nghi_thay_doi.docx', N'Đề nghị thay đổi bổ sung tiệc'),
('frmThayDoiBoSung', 'BLT000002', N'de_nghi_thay_doi.docx', N'Đề nghị thay đổi bổ sung tiệc'),
('frmThayDoiBoSung', 'BLT000003', N'de_nghi_thay_doi.docx', N'Đề nghị thay đổi bổ sung tiệc'),
('frmThayDoiBoSung', 'BLT000004', N'de_nghi_thay_doi.docx', N'Đề nghị thay đổi bổ sung tiệc'),
('frmThayDoiBoSung', 'BLT000005', N'de_nghi_thay_doi.docx', N'Đề nghị thay đổi bổ sung tiệc');

-- 7. QUYẾT TOÁN / THANH LÝ (frmQuyetToan) -> quyet_toan.docx hoặc Biên bản nghiệm thu dịch vụ
INSERT INTO tbmk_LoaitiecAddfile (FormName, Loaitiecid, TemplateFile, GhiChu) VALUES 
('frmQuyetToan', 'BLT000001', N'quyet_toan.docx', N'Thanh lý / Quyết toán Tiệc Cưới'),
('frmQuyetToan', 'BLT000002', N'4. BBNT VÀ QUYẾT TOÁN DỊCH VỤ - 0406 (DÙNG CHUNG CHO 2.1,2.2,3.1,3.2).docx', N'BBNT Hội Nghị - Triển Lãm'),
('frmQuyetToan', 'BLT000003', N'4. BBNT VÀ QUYẾT TOÁN DỊCH VỤ - 0406 (DÙNG CHUNG CHO 2.1,2.2,3.1,3.2).docx', N'BBNT Hội Nghị - Triển Lãm'),
('frmQuyetToan', 'BLT000004', N'4. BBNT VÀ QUYẾT TOÁN DỊCH VỤ - 0406 (DÙNG CHUNG CHO 2.1,2.2,3.1,3.2).docx', N'BBNT Hội Nghị - Triển Lãm'),
('frmQuyetToan', 'BLT000005', N'4. BBNT VÀ QUYẾT TOÁN DỊCH VỤ - 0406 (DÙNG CHUNG CHO 2.1,2.2,3.1,3.2).docx', N'BBNT Hội Nghị - Triển Lãm');

-- 8. BIÊN BẢN GIAO MÓN PHÁT SINH (frmPhatSinh) -> phat_sinh.docx
INSERT INTO tbmk_LoaitiecAddfile (FormName, Loaitiecid, TemplateFile, GhiChu) VALUES 
('frmPhatSinh', 'BLT000001', N'phat_sinh.docx', N'Biên bản phát sinh Tiệc Cưới'),
('frmPhatSinh', 'BLT000002', N'phat_sinh.docx', N'Biên bản phát sinh Hội Nghị - Triển Lãm'),
('frmPhatSinh', 'BLT000003', N'phat_sinh.docx', N'Biên bản phát sinh Hội Nghị - Triển Lãm'),
('frmPhatSinh', 'BLT000004', N'phat_sinh.docx', N'Biên bản phát sinh Hội Nghị - Triển Lãm'),
('frmPhatSinh', 'BLT000005', N'phat_sinh.docx', N'Biên bản phát sinh Hội Nghị - Triển Lãm');

GO
PRINT '>> Đã xóa dữ liệu cũ và cập nhật lại toàn bộ File Mẫu (Template) thành công!';
GO

-- =========================================================================
-- 9. TẠO STORED PROCEDURE ĐỂ HỖ TRỢ TRUY VẤN DÂN DỤNG
-- =========================================================================
IF OBJECT_ID('[dbo].[API_tbmk_GetForm]', 'P') IS NOT NULL
    DROP PROCEDURE [dbo].[API_tbmk_GetForm];
GO

CREATE PROCEDURE [dbo].[API_tbmk_GetForm]
    @Keyword NVARCHAR(250) = N''
AS
BEGIN
    SET NOCOUNT ON;
    SELECT TOP 1 FormName 
    FROM dbo.tbmk_LoaitiecAddfile 
    WHERE TemplateFile LIKE '%' + @Keyword + '%' 
       OR @Keyword LIKE '%' + TemplateFile + '%';
END
GO

PRINT '>> Đã tạo Stored Procedure API_tbmk_GetForm thành công!';
GO

-- =========================================================================
-- 10. ĐĂNG KÝ ROUTING GATEWAY VÀO WA_API ĐỂ BACKEND TRUY VẤN
-- =========================================================================
DELETE FROM dbo.WA_API WHERE list IN ('tbmk_LoaitiecAddfile', 'tbmk_GetForm');
GO

INSERT INTO dbo.WA_API (list, func, [SQL], Para)
VALUES 
('tbmk_LoaitiecAddfile', 'View', 'API_TruyVanDong', '@List=N''tbmk_LoaitiecAddfile'', @Keyword=N''{Keyword}'', @SortColumn=N''{SortColumn}'', @SortDir=N''{SortDir}'', @Data=N''{JsonData}'''),
('tbmk_GetForm', 'View', 'API_tbmk_GetForm', '@Keyword=N''{Keyword}''');
GO

PRINT '>> Đã đăng ký routing cho tbmk_LoaitiecAddfile và tbmk_GetForm vào WA_API thành công!';
GO
