IF OBJECT_ID('API_LuuCauHinhForm', 'P') IS NOT NULL
    DROP PROCEDURE API_LuuCauHinhForm;
GO

CREATE PROCEDURE API_LuuCauHinhForm
    @FormID varchar(50),
    @AddNewColumnArr varchar(max) = NULL,
    @HideColumnArr varchar(max) = NULL,
    @LockColumnArr varchar(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Kiểm tra xem FormID đã tồn tại trong SY_FrmLstTbl chưa
    IF EXISTS (SELECT 1 FROM SY_FrmLstTbl WHERE FormID = @FormID)
    BEGIN
        -- Cập nhật mảng cấu hình
        UPDATE SY_FrmLstTbl
        SET 
            AddNewColumnArr = ISNULL(@AddNewColumnArr, AddNewColumnArr),
            HideColumnArr = ISNULL(@HideColumnArr, HideColumnArr),
            LockColumnArr = ISNULL(@LockColumnArr, LockColumnArr)
        WHERE FormID = @FormID;
    END
    ELSE
    BEGIN
        -- Nếu là Form Web mới tinh (ví dụ: frmCustomer), tạo dòng mới
        INSERT INTO SY_FrmLstTbl (FormID, AddNewColumnArr, HideColumnArr, LockColumnArr)
        VALUES (@FormID, @AddNewColumnArr, @HideColumnArr, @LockColumnArr);
    END

    -- Trả về dữ liệu vừa lưu
    SELECT FormID, AddNewColumnArr, HideColumnArr, LockColumnArr
    FROM SY_FrmLstTbl 
    WHERE FormID = @FormID;
END
GO
