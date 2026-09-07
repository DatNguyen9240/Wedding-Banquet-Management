-- Chạy trước view/API hợp đồng; chỉ bổ sung cột, không ghi đè dữ liệu.
IF COL_LENGTH('dbo.tbmk_Hopdong', 'BenANguoiGiaoDich') IS NULL
    ALTER TABLE dbo.tbmk_Hopdong ADD BenANguoiGiaoDich NVARCHAR(255) NULL;
GO
IF COL_LENGTH('dbo.tbmk_Hopdong', 'BenAChucVuGiaoDich') IS NULL
    ALTER TABLE dbo.tbmk_Hopdong ADD BenAChucVuGiaoDich NVARCHAR(255) NULL;
GO
IF COL_LENGTH('dbo.tbmk_Hopdong', 'NoiDungXuatHoaDon') IS NULL
    ALTER TABLE dbo.tbmk_Hopdong ADD NoiDungXuatHoaDon NVARCHAR(MAX) NULL;
GO
IF COL_LENGTH('dbo.tbmk_Hopdong', 'SoKhachHoiNghi') IS NULL
    ALTER TABLE dbo.tbmk_Hopdong ADD SoKhachHoiNghi INT NULL;
GO

-- Mở nhập ở form generic hợp đồng. Chạy lại sau khi cập nhật view cũng an toàn.
IF EXISTS (SELECT 1 FROM dbo.SY_FmtFldTbl WHERE FieldName = 'BenANguoiGiaoDich')
    UPDATE dbo.SY_FmtFldTbl SET CaptionVN = N'Người phụ trách giao dịch bên A', FormatID = 't' WHERE FieldName = 'BenANguoiGiaoDich';
ELSE
    INSERT INTO dbo.SY_FmtFldTbl (FormName, FieldName, CaptionVN, FormatID)
    VALUES ('v_DanhSachHopDong', 'BenANguoiGiaoDich', N'Người phụ trách giao dịch bên A', 't');
UPDATE dbo.SY_FrmLstTbl
SET AddNewColumnArr = CASE WHEN NULLIF(AddNewColumnArr, '') IS NULL OR CHARINDEX(';BenANguoiGiaoDich;', ';'+AddNewColumnArr+';') > 0 THEN AddNewColumnArr ELSE AddNewColumnArr+';BenANguoiGiaoDich' END,
    EditorColumnArr = CASE WHEN NULLIF(EditorColumnArr, '') IS NULL OR CHARINDEX(';BenANguoiGiaoDich;', ';'+EditorColumnArr+';') > 0 THEN EditorColumnArr ELSE EditorColumnArr+';BenANguoiGiaoDich' END
WHERE FormID IN ('v_DanhSachHopDong', 'frmHopDong');
GO
IF EXISTS (SELECT 1 FROM dbo.SY_FmtFldTbl WHERE FieldName = 'BenAChucVuGiaoDich')
    UPDATE dbo.SY_FmtFldTbl SET CaptionVN = N'Chức vụ đầu mối giao dịch bên A', FormatID = 't' WHERE FieldName = 'BenAChucVuGiaoDich';
ELSE
    INSERT INTO dbo.SY_FmtFldTbl (FormName, FieldName, CaptionVN, FormatID)
    VALUES ('v_DanhSachHopDong', 'BenAChucVuGiaoDich', N'Chức vụ đầu mối giao dịch bên A', 't');
UPDATE dbo.SY_FrmLstTbl
SET AddNewColumnArr = CASE WHEN NULLIF(AddNewColumnArr, '') IS NULL OR CHARINDEX(';BenAChucVuGiaoDich;', ';'+AddNewColumnArr+';') > 0 THEN AddNewColumnArr ELSE AddNewColumnArr+';BenAChucVuGiaoDich' END,
    EditorColumnArr = CASE WHEN NULLIF(EditorColumnArr, '') IS NULL OR CHARINDEX(';BenAChucVuGiaoDich;', ';'+EditorColumnArr+';') > 0 THEN EditorColumnArr ELSE EditorColumnArr+';BenAChucVuGiaoDich' END
WHERE FormID IN ('v_DanhSachHopDong', 'frmHopDong');
GO
IF EXISTS (SELECT 1 FROM dbo.SY_FmtFldTbl WHERE FieldName = 'NoiDungXuatHoaDon')
    UPDATE dbo.SY_FmtFldTbl SET CaptionVN = N'Nội dung xuất hóa đơn', FormatID = 't' WHERE FieldName = 'NoiDungXuatHoaDon';
ELSE
    INSERT INTO dbo.SY_FmtFldTbl (FormName, FieldName, CaptionVN, FormatID)
    VALUES ('v_DanhSachHopDong', 'NoiDungXuatHoaDon', N'Nội dung xuất hóa đơn', 't');
UPDATE dbo.SY_FrmLstTbl
SET AddNewColumnArr = CASE WHEN NULLIF(AddNewColumnArr, '') IS NULL OR CHARINDEX(';NoiDungXuatHoaDon;', ';'+AddNewColumnArr+';') > 0 THEN AddNewColumnArr ELSE AddNewColumnArr+';NoiDungXuatHoaDon' END,
    EditorColumnArr = CASE WHEN NULLIF(EditorColumnArr, '') IS NULL OR CHARINDEX(';NoiDungXuatHoaDon;', ';'+EditorColumnArr+';') > 0 THEN EditorColumnArr ELSE EditorColumnArr+';NoiDungXuatHoaDon' END
WHERE FormID IN ('v_DanhSachHopDong', 'frmHopDong');
GO
IF EXISTS (SELECT 1 FROM dbo.SY_FmtFldTbl WHERE FieldName = 'SoKhachHoiNghi')
    UPDATE dbo.SY_FmtFldTbl SET CaptionVN = N'Số khách tham dự hội nghị', FormatID = 'N0' WHERE FieldName = 'SoKhachHoiNghi';
ELSE
    INSERT INTO dbo.SY_FmtFldTbl (FormName, FieldName, CaptionVN, FormatID)
    VALUES ('v_DanhSachHopDong', 'SoKhachHoiNghi', N'Số khách tham dự hội nghị', 'N0');
UPDATE dbo.SY_FrmLstTbl
SET AddNewColumnArr = CASE WHEN NULLIF(AddNewColumnArr, '') IS NULL OR CHARINDEX(';SoKhachHoiNghi;', ';'+AddNewColumnArr+';') > 0 THEN AddNewColumnArr ELSE AddNewColumnArr+';SoKhachHoiNghi' END,
    EditorColumnArr = CASE WHEN NULLIF(EditorColumnArr, '') IS NULL OR CHARINDEX(';SoKhachHoiNghi;', ';'+EditorColumnArr+';') > 0 THEN EditorColumnArr ELSE EditorColumnArr+';SoKhachHoiNghi' END
WHERE FormID IN ('v_DanhSachHopDong', 'frmHopDong');
GO
