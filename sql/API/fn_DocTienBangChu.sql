USE [QLTiec]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Helper 1: Đọc nhóm 3 chữ số tiếng Việt
-- =============================================
CREATE OR ALTER FUNCTION [dbo].[fn_Doc3ChuSo]
(
    @Baso INT,
    @Daydu BIT
)
RETURNS NVARCHAR(255)
AS
BEGIN
    DECLARE @Result NVARCHAR(255) = N'';
    DECLARE @Tram INT = @Baso / 100;
    DECLARE @Chuc INT = (@Baso % 100) / 10;
    DECLARE @Donvi INT = @Baso % 10;

    DECLARE @Chuso TABLE (So INT, Chu NVARCHAR(10));
    INSERT INTO @Chuso VALUES 
    (0, N'không'), (1, N'một'), (2, N'hai'), (3, N'ba'), (4, N'bốn'),
    (5, N'năm'), (6, N'sáu'), (7, N'bảy'), (8, N'tám'), (9, N'chín');

    IF @Tram = 0 AND @Chuc = 0 AND @Donvi = 0
        RETURN N'';

    -- Đọc hàng trăm
    IF @Tram > 0 OR @Daydu = 1
    BEGIN
        SELECT @Result = @Result + Chu + N' trăm ' FROM @Chuso WHERE So = @Tram;
    END

    -- Đọc hàng chục
    IF @Chuc = 0
    BEGIN
        IF @Donvi > 0 AND (@Tram > 0 OR @Daydu = 1)
            SET @Result = @Result + N'lẻ ';
    END
    ELSE IF @Chuc = 1
    BEGIN
        SET @Result = @Result + N'mười ';
    END
    ELSE
    BEGIN
        SELECT @Result = @Result + Chu + N' mươi ' FROM @Chuso WHERE So = @Chuc;
    END

    -- Đọc hàng đơn vị
    IF @Donvi > 0
    BEGIN
        IF @Donvi = 1 AND @Chuc > 1
        BEGIN
            SET @Result = @Result + N'mốt';
        END
        ELSE IF @Donvi = 5 AND @Chuc > 0
        BEGIN
            SET @Result = @Result + N'lăm';
        END
        ELSE IF @Donvi = 4 AND @Chuc > 1
        BEGIN
            SET @Result = @Result + N'tư';
        END
        ELSE
        BEGIN
            SELECT @Result = @Result + Chu FROM @Chuso WHERE So = @Donvi;
        END
    END

    RETURN LTRIM(RTRIM(@Result));
END
GO

-- =============================================
-- Helper 2: Đọc tiền bằng chữ
-- =============================================
CREATE OR ALTER FUNCTION [dbo].[fn_DocTienBangChu]
(
    @Sotien DECIMAL(18, 2)
)
RETURNS NVARCHAR(1000)
AS
BEGIN
    IF @Sotien = 0
        RETURN N'Không đồng';

    DECLARE @AbsoluteSotien BIGINT = CAST(ABS(@Sotien) AS BIGINT);
    DECLARE @Result NVARCHAR(1000) = N'';
    
    DECLARE @Ty BIGINT = @AbsoluteSotien / 1000000000;
    DECLARE @Temp BIGINT = @AbsoluteSotien % 1000000000;
    DECLARE @Trieu INT = @Temp / 1000000;
    DECLARE @Nghin INT = (@Temp % 1000000) / 1000;
    DECLARE @Dong INT = @Temp % 1000;

    DECLARE @Daydu BIT = 0;

    -- Đọc phần Tỷ
    IF @Ty > 0
    BEGIN
        IF @Ty < 1000
        BEGIN
            SET @Result = [dbo].[fn_Doc3ChuSo](CAST(@Ty AS INT), 0) + N' tỷ ';
        END
        ELSE
        BEGIN
            SET @Result = [dbo].[fn_Doc3ChuSo](CAST(@Ty / 1000 AS INT), 0) + N' nghìn '
                        + CASE WHEN (@Ty % 1000) > 0 THEN [dbo].[fn_Doc3ChuSo](CAST(@Ty % 1000 AS INT), 1) ELSE N'' END
                        + N' tỷ ';
        END
        SET @Daydu = 1;
    END

    -- Đọc phần Triệu
    IF @Trieu > 0
    BEGIN
        SET @Result = @Result + [dbo].[fn_Doc3ChuSo](@Trieu, @Daydu) + N' triệu ';
        SET @Daydu = 1;
    END
    ELSE IF @Daydu = 1 AND (@Nghin > 0 OR @Dong > 0)
    BEGIN
        SET @Result = @Result + N'không trăm triệu ';
    END

    -- Đọc phần Nghìn
    IF @Nghin > 0
    BEGIN
        SET @Result = @Result + [dbo].[fn_Doc3ChuSo](@Nghin, @Daydu) + N' nghìn ';
        SET @Daydu = 1;
    END
    ELSE IF @Daydu = 1 AND @Dong > 0
    BEGIN
        SET @Result = @Result + N'không trăm nghìn ';
    END

    -- Đọc phần Đồng
    IF @Dong > 0
    BEGIN
        SET @Result = @Result + [dbo].[fn_Doc3ChuSo](@Dong, @Daydu);
    END

    -- Dọn dẹp khoảng trắng
    SET @Result = LTRIM(RTRIM(@Result)) + N' đồng';
    
    -- Viết hoa chữ cái đầu tiên
    IF LEN(@Result) > 0
    BEGIN
        SET @Result = UPPER(SUBSTRING(@Result, 1, 1)) + SUBSTRING(@Result, 2, LEN(@Result) - 1);
    END

    -- Nếu số tiền âm
    IF @Sotien < 0
        SET @Result = N'Âm ' + LOWER(@Result);

    RETURN @Result;
END
GO
