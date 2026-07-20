USE [QLTiec]
GO

/*
  Chỉ cho modal hợp đồng hiển thị các cột dữ liệu thật của tbmk_Hopdong.
  Các cột Json..., LichTrinh..., DanhSach... là read-model dùng cho in/đọc,
  không nằm trong danh sách thêm/sửa nên sẽ không xuất hiện trong modal.
*/
SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

DECLARE @ColumnArr VARCHAR(MAX);
DECLARE @WantedColumns TABLE
(
    OrderNo INT NOT NULL PRIMARY KEY,
    FieldName SYSNAME NOT NULL UNIQUE
);

INSERT INTO @WantedColumns (OrderNo, FieldName)
VALUES
    (10, N'Sohopdong'), (20, N'Sobiennhan'), (30, N'Makh'), (40, N'Ngaytochuc'),
    (50, N'Ngayhopdong'), (60, N'Nhamngay'), (70, N'Loaitiecid'),
    (80, N'Thoigianid'), (90, N'Tentiec'), (100, N'GoiThucDonID'),
    (110, N'SobanManchinhthuc'), (120, N'SobanManduphong'), (130, N'Giabanman'),
    (140, N'SobanChaychinhthuc'), (150, N'SobanChayduphong'), (160, N'Giabanchay'),
    (190, N'SoBanTang'), (200, N'SoNguoiTrenBan'), (210, N'TongSoBan'),
    (220, N'Soluongkhach'),
    (240, N'Tongtienhopdong'), (250, N'Sotiencoccho'), (260, N'Sotiencochopdong'),
    (270, N'Tongtiencoc'), (280, N'Conlai'), (290, N'PhiPhucVu'),
    (310, N'TongTienHopDongChuaVAT'),
    (320, N'PTThueVAT'), (330, N'TienThueVAT'),
    (370, N'DiaDiemToChuc'), (380, N'GioDienRaSuKien'), (390, N'GioKetThucSuKien'),
    (480, N'TenCtyHoaDon'), (500, N'MaSoThueHoaDon'),
    (540, N'IsHoaDon'), (550, N'Ghichu'), (580, N'IsHuy'), (590, N'Lydohuy'),
    (600, N'IsDoingay'), (610, N'Lydodoi'), (620, N'Ngaydoitiec'),
    (630, N'Ngaytiecmoi'), (640, N'IsKetthuc');

SELECT @ColumnArr = STUFF((
    SELECT N';' + wanted.FieldName
    FROM @WantedColumns wanted
    WHERE EXISTS (
        SELECT 1
        FROM sys.columns c
        WHERE c.object_id = OBJECT_ID(N'dbo.tbmk_Hopdong', N'U')
          AND c.name = wanted.FieldName
    )
    ORDER BY wanted.OrderNo
    FOR XML PATH(''), TYPE
).value('.', 'VARCHAR(MAX)'), 1, 1, '');

IF NULLIF(LTRIM(RTRIM(@ColumnArr)), '') IS NULL
    THROW 51120, 'Không lấy được danh sách cột dbo.tbmk_Hopdong.', 1;

/* Caption rõ nghĩa cho các cặp field có cùng nhãn hiển thị cũ. */
UPDATE fieldConfig
SET CaptionVN = CASE fieldConfig.FieldName
    WHEN N'SobanManchinhthuc' THEN N'Bàn mặn chính thức'
    WHEN N'SobanManduphong' THEN N'Bàn mặn dự phòng'
    WHEN N'Giabanman' THEN N'Giá bàn mặn'
    WHEN N'SobanChaychinhthuc' THEN N'Bàn chay chính thức'
    WHEN N'SobanChayduphong' THEN N'Bàn chay dự phòng'
    WHEN N'Giabanchay' THEN N'Giá bàn chay'
    ELSE fieldConfig.CaptionVN
END
FROM dbo.SY_FmtFldTbl fieldConfig
WHERE fieldConfig.FieldName IN
    (N'SobanManchinhthuc', N'SobanManduphong', N'Giabanman',
     N'SobanChaychinhthuc', N'SobanChayduphong', N'Giabanchay');

UPDATE formConfig
SET formConfig.PrimaryKey = N'Sohopdong',
    formConfig.AddNewColumnArr = @ColumnArr,
    formConfig.EditorColumnArr = @ColumnArr
FROM dbo.SY_FrmLstTbl formConfig
WHERE formConfig.TableName = N'v_DanhSachHopDong'
  AND formConfig.FormID IN (N'0540', N'frmBEO', N'frmHopDong');

SELECT @@ROWCOUNT AS UpdatedRows;
GO
