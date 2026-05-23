IF OBJECT_ID('API_LuuTruongGiaoDien', 'P') IS NOT NULL
    DROP PROCEDURE API_LuuTruongGiaoDien;
GO

CREATE PROCEDURE API_LuuTruongGiaoDien
    @FormName varchar(50) = NULL,
    @FieldName varchar(50) = NULL,
    @CaptionVN nvarchar(255) = NULL,
    @FormatID varchar(2) = NULL,
    @CaptionEN nvarchar(200) = NULL,
    @DataSource nvarchar(500) = NULL,
    @IsRequired bit = 0,
    @FormPosition varchar(50) = NULL,
    @ShowInAdd bit = 1,
    @ShowInEdit bit = 1,
    @IsReadOnlyEdit bit = 0,
    @IsReadOnlyAdd bit = 0,
    @ValidateRule nvarchar(500) = NULL,
    @DependsOn varchar(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Lưu thông tin cơ bản vào SY_FormatFields
    IF EXISTS (SELECT 1 FROM SY_FormatFields WHERE FieldName = @FieldName AND FormName = @FormName)
    BEGIN
        UPDATE SY_FormatFields
        SET CaptionVN = ISNULL(@CaptionVN, CaptionVN),
            FormatID = ISNULL(@FormatID, FormatID),
            CaptionEN = ISNULL(@CaptionEN, CaptionEN),
            DataSource = ISNULL(@DataSource, DataSource),
            IsRequired = ISNULL(@IsRequired, IsRequired),
            FormPosition = ISNULL(@FormPosition, FormPosition),
            ValidateRule = ISNULL(@ValidateRule, ValidateRule),
            DependsOn = ISNULL(@DependsOn, DependsOn)
        WHERE FieldName = @FieldName AND FormName = @FormName;
    END
    ELSE
    BEGIN
        INSERT INTO SY_FormatFields (FormName, FieldName, CaptionVN, FormatID, CaptionEN, DataSource, IsRequired, FormPosition, ValidateRule, DependsOn)
        VALUES (@FormName, @FieldName, @CaptionVN, @FormatID, @CaptionEN, @DataSource, @IsRequired, @FormPosition, @ValidateRule, @DependsOn);
    END

    -- 2. Xử lý Mảng (Array) bên bảng SY_FrmLstTbl
    -- Đảm bảo FormID tồn tại trong SY_FrmLstTbl
    IF NOT EXISTS (SELECT 1 FROM SY_FrmLstTbl WHERE FormID = @FormName)
    BEGIN
        INSERT INTO SY_FrmLstTbl (FormID, AddNewColumnArr, HideColumnArr, LockColumnArr, LockAddColumnArr)
        VALUES (@FormName, '', '', '', '');
    END

    DECLARE @AddArr varchar(max), @HideArr varchar(max), @LockArr varchar(max), @LockAddArr varchar(max);
    SELECT @AddArr = ISNULL(AddNewColumnArr, ''), 
           @HideArr = ISNULL(HideColumnArr, ''), 
           @LockArr = ISNULL(LockColumnArr, ''),
           @LockAddArr = ISNULL(LockAddColumnArr, '')
    FROM SY_FrmLstTbl WHERE FormID = @FormName;

    -- ShowInAdd = 1 (Hiện lúc thêm) -> Có mặt trong AddNewColumnArr
    IF @ShowInAdd = 1
    BEGIN
        IF CHARINDEX(',' + @FieldName + ',', ',' + @AddArr + ',') = 0
            SET @AddArr = @AddArr + CASE WHEN LEN(@AddArr) > 0 THEN ',' ELSE '' END + @FieldName;
    END
    ELSE
    BEGIN
        SET @AddArr = REPLACE(',' + @AddArr + ',', ',' + @FieldName + ',', ',');
        IF LEFT(@AddArr, 1) = ',' SET @AddArr = SUBSTRING(@AddArr, 2, LEN(@AddArr));
        IF RIGHT(@AddArr, 1) = ',' SET @AddArr = LEFT(@AddArr, LEN(@AddArr) - 1);
    END

    -- ShowInEdit = 0 (Ẩn lúc sửa) -> Có mặt trong HideColumnArr
    IF @ShowInEdit = 0
    BEGIN
        IF CHARINDEX(',' + @FieldName + ',', ',' + @HideArr + ',') = 0
            SET @HideArr = @HideArr + CASE WHEN LEN(@HideArr) > 0 THEN ',' ELSE '' END + @FieldName;
    END
    ELSE
    BEGIN
        SET @HideArr = REPLACE(',' + @HideArr + ',', ',' + @FieldName + ',', ',');
        IF LEFT(@HideArr, 1) = ',' SET @HideArr = SUBSTRING(@HideArr, 2, LEN(@HideArr));
        IF RIGHT(@HideArr, 1) = ',' SET @HideArr = LEFT(@HideArr, LEN(@HideArr) - 1);
    END

    -- IsReadOnlyEdit = 1 (Khóa lúc sửa) -> Có mặt trong LockColumnArr
    IF @IsReadOnlyEdit = 1
    BEGIN
        IF CHARINDEX(',' + @FieldName + ',', ',' + @LockArr + ',') = 0
            SET @LockArr = @LockArr + CASE WHEN LEN(@LockArr) > 0 THEN ',' ELSE '' END + @FieldName;
    END
    ELSE
    BEGIN
        SET @LockArr = REPLACE(',' + @LockArr + ',', ',' + @FieldName + ',', ',');
        IF LEFT(@LockArr, 1) = ',' SET @LockArr = SUBSTRING(@LockArr, 2, LEN(@LockArr));
        IF RIGHT(@LockArr, 1) = ',' SET @LockArr = LEFT(@LockArr, LEN(@LockArr) - 1);
    END

    -- IsReadOnlyAdd = 1 (Khóa lúc thêm) -> Có mặt trong LockAddColumnArr
    IF @IsReadOnlyAdd = 1
    BEGIN
        IF CHARINDEX(',' + @FieldName + ',', ',' + @LockAddArr + ',') = 0
            SET @LockAddArr = @LockAddArr + CASE WHEN LEN(@LockAddArr) > 0 THEN ',' ELSE '' END + @FieldName;
    END
    ELSE
    BEGIN
        SET @LockAddArr = REPLACE(',' + @LockAddArr + ',', ',' + @FieldName + ',', ',');
        IF LEFT(@LockAddArr, 1) = ',' SET @LockAddArr = SUBSTRING(@LockAddArr, 2, LEN(@LockAddArr));
        IF RIGHT(@LockAddArr, 1) = ',' SET @LockAddArr = LEFT(@LockAddArr, LEN(@LockAddArr) - 1);
    END

    -- Cập nhật lại vào DB
    UPDATE SY_FrmLstTbl
    SET AddNewColumnArr = @AddArr,
        HideColumnArr = @HideArr,
        LockColumnArr = @LockArr,
        LockAddColumnArr = @LockAddArr
    WHERE FormID = @FormName;

    -- Trả về dữ liệu vừa lưu
    SELECT FormName, FieldName, CaptionVN, FormatID, CaptionEN, DataSource, IsRequired, FormPosition, ValidateRule, DependsOn,
           @ShowInAdd AS ShowInAdd, @ShowInEdit AS ShowInEdit, @IsReadOnlyEdit AS IsReadOnlyEdit, @IsReadOnlyAdd AS IsReadOnlyAdd
    FROM SY_FormatFields 
    WHERE FieldName = @FieldName;
END
GO
