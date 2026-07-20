USE [QLTiec]
GO

/*
  Dữ liệu hiển thị cho các field của v_DanhSachHopDong.
  SY_FmtFldTbl là từ điển dùng chung: chỉ cập nhật CaptionVN, FormatID và
  kích thước cột; không đụng dữ liệu hợp đồng và không dùng isInvisible để ẩn
  cột lưới (ẩn lưới vẫn nằm ở SY_FrmLstTbl.HideColumnArr).
*/
SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

DECLARE @Fields TABLE
(
    FieldName SYSNAME NOT NULL PRIMARY KEY,
    CaptionVN NVARCHAR(255) NOT NULL,
    FormatID VARCHAR(20) NOT NULL,
    MinWidth INT NULL,
    MaxWidth INT NULL
);

INSERT INTO @Fields (FieldName, CaptionVN, FormatID, MinWidth, MaxWidth)
VALUES
    (N'Id', N'Mã hợp đồng', 't', 130, 180),
    (N'Sohopdong', N'Số hợp đồng', 't', 140, 190),
    (N'Sobiennhan', N'Số biên nhận', 't', 140, 190),
    (N'Makh', N'Mã khách hàng', 't', 130, 170),
    (N'Manv', N'Nhân viên phụ trách', 't', 150, 220),
    (N'Thoigianid', N'Ca tiệc', 't', 130, 200),
    (N'Loaitiecid', N'Loại tiệc', 't', 150, 230),
    (N'GoiThucDonID', N'Gói thực đơn', 't', 160, 240),
    (N'TenKhachHang', N'Tên khách hàng', 't', 180, 280),
    (N'DienThoai', N'Điện thoại', 't', 120, 160),
    (N'NgayToChuc', N'Ngày tổ chức', 'D', 120, 150),
    (N'SoBan', N'Số bàn', 'N0', 90, 120),
    (N'SanhDat', N'Sảnh đặt', 't', 180, 300),
    (N'TongTien', N'Tổng tiền', 'N0', 140, 180),
    (N'TrangThai', N'Trạng thái', 't', 130, 180),
    (N'CocNgay', N'Ngày đặt cọc', 'D', 130, 170),
    (N'CocThang', N'Tháng đặt cọc', 'N0', 90, 120),
    (N'CocNam', N'Năm đặt cọc', 'N0', 90, 120),
    (N'CocLan1SoTien', N'Tiền cọc lần 1', 'N0', 150, 210),
    (N'CocLan2SoTien', N'Tiền cọc lần 2', 'N0', 150, 210),
    (N'Tongtiencoc', N'Tổng tiền cọc', 'N0', 150, 210),
    (N'Dot1SoTien', N'Số tiền thanh toán đợt 1', 'N0', 160, 220),
    (N'Dot1Ngay', N'Ngày thanh toán đợt 1', 'D', 140, 180),
    (N'Dot1HinhThuc', N'Hình thức thanh toán đợt 1', 't', 180, 260),
    (N'Dot2SoTien', N'Số tiền thanh toán đợt 2', 'N0', 160, 220),
    (N'Dot2HinhThuc', N'Hình thức thanh toán đợt 2', 't', 180, 260),
    (N'DotCuoiGhiChu', N'Ghi chú đợt cuối', 't', 180, 320),
    (N'TongThanhTien', N'Tổng thành tiền', 'N0', 150, 210),
    (N'MucPhiPhucVu', N'Mức phí phục vụ', 'N0', 120, 160),
    (N'PhiPhucVu', N'Phí phục vụ', 'N0', 140, 190),
    (N'TongCongChuaVAT', N'Tổng cộng chưa VAT', 'N0', 160, 220),
    (N'VAT8', N'Thuế VAT 8%', 'N0', 130, 180),
    (N'VAT10', N'Thuế VAT 10%', 'N0', 130, 180),
    (N'TongTienFormat', N'Tổng tiền hiển thị', 't', 160, 240),
    (N'SoTienDaDatCoc', N'Số tiền đã đặt cọc', 'N0', 150, 210),
    (N'SoTienConLai', N'Số tiền còn lại', 'N0', 150, 210),
    (N'TongGiaTriTamTinh', N'Tổng giá trị tạm tính', 'N0', 170, 230),
    (N'TongGiaTriQuyetToan', N'Tổng giá trị quyết toán', 'N0', 170, 230),
    (N'DieuKhoanBoSung', N'Điều khoản bổ sung', 't', 220, 420),
    (N'DSKhuyenMai', N'Danh sách khuyến mãi', 't', 220, 420),
    (N'Ghichu', N'Ghi chú', 't', 180, 360),
    (N'TemplateFile', N'Mẫu in', 't', 180, 320);

IF EXISTS (
    SELECT 1
    FROM @Fields wanted
    WHERE NOT EXISTS (SELECT 1 FROM dbo.SY_FmatTbl formatDefinition WHERE formatDefinition.FormatID = wanted.FormatID)
)
    THROW 51110, 'Thiếu FormatID cần thiết trong SY_FmatTbl.', 1;

UPDATE dictionary
SET dictionary.CaptionVN = wanted.CaptionVN,
    dictionary.FormatID = wanted.FormatID,
    dictionary.MinWidth = wanted.MinWidth,
    dictionary.MaxWidth = wanted.MaxWidth
FROM dbo.SY_FmtFldTbl dictionary
INNER JOIN @Fields wanted ON wanted.FieldName = dictionary.FieldName;

SELECT @@ROWCOUNT AS UpdatedRows;
GO
