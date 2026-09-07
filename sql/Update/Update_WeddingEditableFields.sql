USE [QLTiec]
GO
IF COL_LENGTH('dbo.tbmk_Hopdong', 'DieuKhoanBoSung') IS NULL
    ALTER TABLE dbo.tbmk_Hopdong ADD DieuKhoanBoSung NVARCHAR(MAX) NULL;
GO
DECLARE @Fields TABLE (FieldName VARCHAR(100), Caption NVARCHAR(255), FormatID VARCHAR(20));
INSERT @Fields VALUES
('PhiPhucVuTyLe', N'Phí phục vụ (%) — nhập 0 để miễn', 'N2'),
('DSKhuyenMai', N'Chương trình khuyến mãi đã chọn', 't'),
('DieuKhoanBoSung', N'Điều khoản bổ sung theo hợp đồng', 't');
UPDATE ff SET CaptionVN = f.Caption, FormatID = f.FormatID
FROM dbo.SY_FmtFldTbl ff JOIN @Fields f ON ff.FieldName = f.FieldName
WHERE ff.FormName = 'v_DanhSachHopDong';
INSERT dbo.SY_FmtFldTbl (FormName, FieldName, CaptionVN, FormatID)
SELECT 'v_DanhSachHopDong', f.FieldName, f.Caption, f.FormatID FROM @Fields f
WHERE NOT EXISTS (SELECT 1 FROM dbo.SY_FmtFldTbl x WHERE x.FormName = 'v_DanhSachHopDong' AND x.FieldName = f.FieldName);
DECLARE @Field VARCHAR(100);
DECLARE fields CURSOR LOCAL FAST_FORWARD FOR SELECT FieldName FROM @Fields;
OPEN fields;
FETCH NEXT FROM fields INTO @Field;
WHILE @@FETCH_STATUS = 0
BEGIN
    UPDATE dbo.SY_FrmLstTbl
    SET AddNewColumnArr = CASE WHEN NULLIF(AddNewColumnArr, '') IS NULL OR CHARINDEX(';'+@Field+';', ';'+AddNewColumnArr+';') > 0 THEN AddNewColumnArr ELSE AddNewColumnArr+';'+@Field END,
        EditorColumnArr = CASE WHEN NULLIF(EditorColumnArr, '') IS NULL OR CHARINDEX(';'+@Field+';', ';'+EditorColumnArr+';') > 0 THEN EditorColumnArr ELSE EditorColumnArr+';'+@Field END
    WHERE FormID IN ('v_DanhSachHopDong', 'frmHopDong');
    FETCH NEXT FROM fields INTO @Field;
END
CLOSE fields;
DEALLOCATE fields;
GO
