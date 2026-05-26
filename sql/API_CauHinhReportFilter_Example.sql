-- ═══════════════════════════════════════════════════════════
-- Cấu hình filter cho báo cáo "Bảng kê hóa đơn"
-- FormName = 'frmReportFilter_BangKeHoaDon'
-- Bảng SY_FormatFields — đúng schema thực tế
-- ═══════════════════════════════════════════════════════════

DELETE FROM SY_FormatFields WHERE FormName = 'frmReportFilter_BangKeHoaDon';

INSERT INTO SY_FormatFields
  (FormName, FieldName, CaptionVN, FormatID, DataSource, IsRequired, OrderNo, ShowInForm)
VALUES
  ('frmReportFilter_BangKeHoaDon', 'KyBaoCao',   N'Kỳ báo cáo',    'sl', N'STATIC:Hôm nay=today,Hôm qua=yesterday,Tuần này=week,Tháng này=month,Quý này=quarter,Tùy chọn=custom', 0, 1, 1),
  ('frmReportFilter_BangKeHoaDon', 'NgayLap',    N'Từ ngày',        'dr', NULL,                          0, 2, 1),
  ('frmReportFilter_BangKeHoaDon', 'HinhThucPV', N'Hình thức PV',   'sl', '/api/API_DanhSachHinhThucPV', 0, 3, 1),
  ('frmReportFilter_BangKeHoaDon', 'KhuVuc',     N'Khu vực',        'sl', '/api/API_DanhSachKhuVuc',     0, 4, 1),
  ('frmReportFilter_BangKeHoaDon', 'DTGH',       N'ĐTGH/Sàn TMĐT', 'sl', '/api/API_DanhSachDTGH',       0, 5, 1),
  ('frmReportFilter_BangKeHoaDon', 'NVThuNgan',  N'NV Thu ngân',    'sl', '/api/API_DanhSachNhanVien',   0, 6, 1),
  ('frmReportFilter_BangKeHoaDon', 'NVPhucVu',   N'NV Phục vụ',     'sl', '/api/API_DanhSachNhanVien',   0, 7, 1),
  ('frmReportFilter_BangKeHoaDon', 'KhachHang',  N'Khách hàng',     'sr', '/api/API_DanhSachKhachHang',  0, 8, 1);

-- ═══════════════════════════════════════════════════════════
-- Ví dụ 2: "Doanh thu theo ngày" — filter đơn giản
-- ═══════════════════════════════════════════════════════════

DELETE FROM SY_FormatFields WHERE FormName = 'frmReportFilter_DoanhThuNgay';

INSERT INTO SY_FormatFields
  (FormName, FieldName, CaptionVN, FormatID, DataSource, IsRequired, OrderNo, ShowInForm)
VALUES
  ('frmReportFilter_DoanhThuNgay', 'NgayLap',  N'Từ ngày',    'dr', NULL,                            0, 1, 1),
  ('frmReportFilter_DoanhThuNgay', 'KhuVuc',   N'Khu vực',    'sl', '/api/API_DanhSachKhuVuc',       0, 2, 1),
  ('frmReportFilter_DoanhThuNgay', 'NhomHang', N'Nhóm hàng',  'sl', '/api/API_DanhSachNhomHang',     0, 3, 1);
