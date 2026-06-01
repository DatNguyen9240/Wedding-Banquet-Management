USE [QLTiec]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- API: Thêm mới / Cập nhật Khách Tham Quan (Visitor)
-- =============================================
CREATE PROCEDURE [dbo].[API_LuuKhachDen]
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
    @GoiThucDonID VARCHAR(50) = '',
    @SanhTiec VARCHAR(50) = NULL,
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

    -- 2. Xử lý khách hàng — tìm theo SĐT trước, không có mới tạo mới
    IF (@Makh IS NULL OR @Makh = '') AND (@Tenkh IS NOT NULL)
    BEGIN
        -- Tìm khách hàng cũ theo SĐT
        IF (@Dienthoai IS NOT NULL AND @Dienthoai <> '')
        BEGIN
            SELECT TOP 1 @Makh = Makh
            FROM dmkhachhang
            WHERE Dienthoai = @Dienthoai
            ORDER BY DateCreate ASC;   -- Lấy record gốc cũ nhất
        END

        -- Không tìm thấy → tạo mới
        IF (@Makh IS NULL OR @Makh = '')
        BEGIN
            SET @Makh = 'KH' + FORMAT(GETDATE(), 'yyMM') + RIGHT('0000' + CAST((ABS(CHECKSUM(NEWID())) % 10000) AS VARCHAR), 4);
            INSERT INTO dmkhachhang (Makh, Tenkh, Dienthoai, IsKhachhang, DateCreate)
            VALUES (@Makh, @Tenkh, @Dienthoai, 1, GETDATE());
        END
        ELSE
        BEGIN
            -- Tìm thấy → cập nhật tên nếu trống
            UPDATE dmkhachhang
            SET Tenkh = ISNULL(NULLIF(@Tenkh, ''), Tenkh)
            WHERE Makh = @Makh;
        END
    END
    ELSE IF (@Makh IS NOT NULL AND @Makh <> '')
    BEGIN
        -- Cập nhật sđt/tên cho khách cũ nếu có thay đổi
        UPDATE dmkhachhang 
        SET Tenkh = ISNULL(@Tenkh, Tenkh), Dienthoai = ISNULL(@Dienthoai, Dienthoai)
        WHERE Makh = @Makh;
    END

    -- 3. Xử lý fallback cho Gói Thực Đơn nếu FE truyền lên rỗng (để tránh lỗi FK do không sửa DB)
    IF ISNULL(@GoiThucDonID, '') = ''
    BEGIN
        SELECT TOP 1 @GoiThucDonID = GoiThucDonID FROM dmGoiThucDon;
    END

    -- 4. Lưu Khách Tham Quan (Insert hoặc Update)
    IF @IsNew = 1
    BEGIN
        INSERT INTO tbmk_Khachthamquan (
            DocumentID, DocumentDate, Makh, Ngaytochuc, Nhamngay, Loaitiecid, Thoigianid, 
            SobanMan, SobanChay, TongsoBan, Ghichu, IsKetthuc, IsHuy, GoiThucDonID
        ) VALUES (
            @DocumentID, GETDATE(), @Makh, @Ngaytochuc, @Nhamngay, @Loaitiecid, @Thoigianid,
            @SobanMan, @SobanChay, (@SobanMan + @SobanChay), @Ghichu, 0, 0, @GoiThucDonID
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
            Ghichu = @Ghichu,
            GoiThucDonID = @GoiThucDonID
        WHERE DocumentID = @DocumentID;
    END

    -- 4. Xử lý Sảnh Tiệc
    IF @SanhTiec IS NOT NULL AND @SanhTiec <> ''
    BEGIN
        -- Xử lý Sảnh Tiệc dạng đơn (1 lựa chọn từ Dropdown)
        DELETE FROM tbmk_Khachthamquansanhtiec WHERE DocumentID = @DocumentID;
        
        INSERT INTO tbmk_Khachthamquansanhtiec (DocumentID, Sanhtiecid)
        VALUES (@DocumentID, @SanhTiec);
    END
    ELSE IF @JsonSanhTiec IS NOT NULL AND @JsonSanhTiec <> '[]'
    BEGIN
        -- Xử lý Sảnh Tiệc từ JSON (hỗ trợ lưu nhiều sảnh 1 lúc)
        DELETE FROM tbmk_Khachthamquansanhtiec WHERE DocumentID = @DocumentID;
        
        INSERT INTO tbmk_Khachthamquansanhtiec (DocumentID, Sanhtiecid)
        SELECT @DocumentID, JSON_VALUE(value, '$.Sanhtiecid')
        FROM OPENJSON(@JsonSanhTiec);
    END

    -- Trả về mã chứng từ để giao diện biết
    SELECT @DocumentID AS DocumentID;
END
GO
