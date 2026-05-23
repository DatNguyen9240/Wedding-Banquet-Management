IF OBJECT_ID('API_LuuNhanVien', 'P') IS NOT NULL
    DROP PROCEDURE API_LuuNhanVien;
GO

CREATE PROCEDURE API_LuuNhanVien
    @NHANVIENID varchar(50) = NULL,
    @TENNHANVIEN nvarchar(255) = NULL,
    @IsGioitinh bit = 0,
    @DIENTHOAI varchar(50) = NULL,
    @NGAYSINH datetime = NULL,
    @DIACHI nvarchar(255) = NULL,
    @NGAYVAOLAM datetime = NULL,
    @ISDANGHI bit = 0,
    @Bophanid varchar(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Xử lý sinh mã tự động nếu truyền vào rỗng
    IF (@NHANVIENID IS NULL OR @NHANVIENID = '')
    BEGIN
        -- Sinh mã tự động tạm thời (NV + Số ngẫu nhiên)
        -- Chú ý: Ở hệ thống thực tế có thể dùng hàm sinh mã theo quy tắc riêng
        SET @NHANVIENID = 'NV' + RIGHT(REPLACE(NEWID(), '-', ''), 6);
        
        INSERT INTO DMNHANVIEN (
            NHANVIENID, TENNHANVIEN, IsGioitinh, DIENTHOAI, 
            NGAYSINH, DIACHI, NGAYVAOLAM, ISDANGHI, Bophanid,
            USERCREATE, DATECREATE
        )
        VALUES (
            @NHANVIENID, @TENNHANVIEN, @IsGioitinh, @DIENTHOAI, 
            @NGAYSINH, @DIACHI, @NGAYVAOLAM, @ISDANGHI, @Bophanid,
            'admin', GETDATE()
        );
    END
    ELSE
    BEGIN
        UPDATE DMNHANVIEN
        SET 
            TENNHANVIEN = @TENNHANVIEN,
            IsGioitinh = @IsGioitinh,
            DIENTHOAI = @DIENTHOAI,
            NGAYSINH = @NGAYSINH,
            DIACHI = @DIACHI,
            NGAYVAOLAM = @NGAYVAOLAM,
            ISDANGHI = @ISDANGHI,
            Bophanid = @Bophanid,
            USERUPDATE = 'admin',
            DATEUPDATE = GETDATE()
        WHERE NHANVIENID = @NHANVIENID;
    END
    
    -- API Wrapper yêu cầu trả về cục data vừa mới lưu để Update lên UI
    SELECT 
        NHANVIENID, TENNHANVIEN, IsGioitinh, DIENTHOAI, 
        NGAYSINH, DIACHI, NGAYVAOLAM, ISDANGHI, Bophanid
    FROM DMNHANVIEN
    WHERE NHANVIENID = @NHANVIENID;
END
GO
