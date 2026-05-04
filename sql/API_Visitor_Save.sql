USE [QLTiec]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- API: Thêm mới / Cập nhật Khách Tham Quan (Visitor)
-- =============================================
CREATE PROCEDURE [dbo].[API_Visitor_Save]
    @DocumentID VARCHAR(50) = NULL,
    @Makh VARCHAR(50) = NULL,
    @Tenkh NVARCHAR(200) = NULL,
    @Dienthoai VARCHAR(50) = NULL,
    @Ngaytochuc DATE = NULL,
    @Nhamngay NVARCHAR(100) = NULL,
    @Loaitiecid VARCHAR(50) = NULL,
    @Thoigianid VARCHAR(50) = NULL,
    @SobanMan INT = 0,
    @SobanChay INT = 0,
    @Ghichu NVARCHAR(500) = NULL,
    @JsonSanhTiec NVARCHAR(MAX) = '[]' -- JSON array danh sách sảnh: [{"Sanhtiecid": "S01"}]
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @IsNew INT = 0;
    
    -- 1. Nếu chưa có DocumentID -> Sinh mã mới (Theo logic thực tế dự án, ví dụ TQYYMM/XXX)
    -- Ở đây giả định dùng HÀM sinh mã hoặc tự tạo chuỗi tạm. 
    -- Bạn nhớ điều chỉnh lại hàm phát sinh mã theo chuẩn của dự án nhé (ví dụ: dbo.GetNewDocumentID('TQ'))
    IF @DocumentID IS NULL OR @DocumentID = '' OR @DocumentID = 'TQ-AUTO'
    BEGIN
        SET @DocumentID = 'TQ' + FORMAT(GETDATE(), 'yyMM') + '/' + RIGHT('000' + CAST((ABS(CHECKSUM(NEWID())) % 1000) AS VARCHAR), 3);
        SET @IsNew = 1;
    END

    -- 2. Xử lý khách hàng (Nếu truyền Tenkh/Dienthoai mà không có Makh -> Tạo khách hàng mới)
    IF (@Makh IS NULL OR @Makh = '') AND (@Tenkh IS NOT NULL)
    BEGIN
        SET @Makh = 'KH' + FORMAT(GETDATE(), 'yyMM') + RIGHT('0000' + CAST((ABS(CHECKSUM(NEWID())) % 10000) AS VARCHAR), 4);
        INSERT INTO dmkhachhang (Makh, Tenkh, Dienthoai) 
        VALUES (@Makh, @Tenkh, @Dienthoai);
    END
    ELSE IF (@Makh IS NOT NULL AND @Makh <> '')
    BEGIN
        -- Cập nhật sđt/tên cho khách cũ nếu có thay đổi
        UPDATE dmkhachhang 
        SET Tenkh = ISNULL(@Tenkh, Tenkh), Dienthoai = ISNULL(@Dienthoai, Dienthoai)
        WHERE Makh = @Makh;
    END

    -- 3. Lưu Khách Tham Quan (Insert hoặc Update)
    IF @IsNew = 1
    BEGIN
        INSERT INTO tbmk_Khachthamquan (
            DocumentID, DocumentDate, Makh, Ngaytochuc, Nhamngay, Loaitiecid, Thoigianid, 
            SobanMan, SobanChay, TongsoBan, Ghichu, IsKetthuc, IsHuy
        ) VALUES (
            @DocumentID, GETDATE(), @Makh, @Ngaytochuc, @Nhamngay, @Loaitiecid, @Thoigianid,
            @SobanMan, @SobanChay, (@SobanMan + @SobanChay), @Ghichu, 0, 0
        );
    END
    ELSE
    BEGIN
        UPDATE tbmk_Khachthamquan SET
            Makh = @Makh,
            Ngaytochuc = @Ngaytochuc,
            Nhamngay = @Nhamngay,
            Loaitiecid = @Loaitiecid,
            Thoigianid = @Thoigianid,
            SobanMan = @SobanMan,
            SobanChay = @SobanChay,
            TongsoBan = (@SobanMan + @SobanChay),
            Ghichu = @Ghichu
        WHERE DocumentID = @DocumentID;
    END

    -- 4. Xử lý Sảnh Tiệc (Xóa cũ, Insert mới từ JSON)
    IF @JsonSanhTiec IS NOT NULL AND @JsonSanhTiec <> '[]'
    BEGIN
        DELETE FROM tbmk_Khachthamquansanhtiec WHERE DocumentID = @DocumentID;
        
        INSERT INTO tbmk_Khachthamquansanhtiec (DocumentID, Sanhtiecid)
        SELECT @DocumentID, JSON_VALUE(value, '$.Sanhtiecid')
        FROM OPENJSON(@JsonSanhTiec);
    END

    -- Trả về mã chứng từ để giao diện biết
    SELECT @DocumentID AS DocumentID;
END
GO
