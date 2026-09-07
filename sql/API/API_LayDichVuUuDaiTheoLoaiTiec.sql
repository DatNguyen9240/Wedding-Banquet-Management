USE [QLTiec]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =========================================================================
-- Mô tả: API Lấy danh sách dịch vụ ưu đãi dựa trên Loại hình tiệc và Số lượng bàn
-- Tham số: 
--   - @Loaitiecid: Mã loại hình tiệc (ví dụ: 'TC' - Tiệc Cưới)
--   - @Soluongban: Số lượng bàn tiệc thực tế để đối chiếu mốc ưu đãi
--   - @Nhahangid: Mã chi nhánh / nhà hàng (Tùy chọn)
--   - @Ngaytochuc: Ngày tổ chức tiệc (Tùy chọn)
-- =========================================================================
IF OBJECT_ID(N'[dbo].[API_LayDichVuUuDaiTheoLoaiTiec]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[API_LayDichVuUuDaiTheoLoaiTiec];
GO

CREATE PROCEDURE [dbo].[API_LayDichVuUuDaiTheoLoaiTiec]
    @Loaitiecid varchar(10),
    @Soluongban int,
    @Nhahangid varchar(50) = NULL,
    @Ngaytochuc datetime = NULL,
    @TatCa bit = 0
AS
BEGIN
    SET NOCOUNT ON;
    SET @Nhahangid = NULLIF(LTRIM(RTRIM(@Nhahangid)), '');

    SELECT 
        ct.UserAutoID,
        ct.DocumentID,
        ct.Mahang,
        h.Tenhang,
        ct.Soluong,
        ct.Dongia,
        ct.Sotien,
        ct.STT,
        ct.IsNTL,
        ct.IsTTS
    FROM tbmk_Banuudaict ct
    LEFT JOIN dmHanghoa h ON ct.Mahang = h.Mahang
    WHERE ct.DocumentID IN (
        SELECT TOP (CASE WHEN @TatCa = 1 THEN 2147483647 ELSE 1 END) DocumentID
        FROM tbmk_Banuudai
        WHERE Loaitiecid = @Loaitiecid
          AND @Soluongban >= Tusoluongban 
          AND @Soluongban <= Densoluongban
          AND (IsKetthuc IS NULL OR IsKetthuc = 0)
          AND (@Nhahangid IS NULL OR Nhahangid = @Nhahangid OR BranchID = @Nhahangid)
          AND (@Ngaytochuc IS NOT NULL AND (
                (Tungay IS NULL OR Tungay <= @Ngaytochuc) AND
                (Denngay IS NULL OR Denngay >= @Ngaytochuc)
              ))
        ORDER BY Tusoluongban DESC, Tungay DESC
    )
    ORDER BY ct.STT ASC;
END
GO

-- =========================================================================
-- ĐĂNG KÝ ĐỊNH TUYẾN TRONG WA_API
-- =========================================================================
DELETE FROM WA_API WHERE List = 'API_LayDichVuUuDaiTheoLoaiTiec' AND Func = 'View';
GO
INSERT INTO WA_API (List, Func, [SQL], Para)
VALUES (
    'API_LayDichVuUuDaiTheoLoaiTiec',
    'View',
    'API_LayDichVuUuDaiTheoLoaiTiec',
    '@Loaitiecid=''{Loaitiecid}'', @Soluongban=''{Soluongban}'', @Nhahangid=''{Nhahangid}'', @Ngaytochuc=''{Ngaytochuc}'', @TatCa=''{TatCa}'''
);
GO
