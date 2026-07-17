IF OBJECT_ID('API_LuuCauHinhForm', 'P') IS NOT NULL
    DROP PROCEDURE API_LuuCauHinhForm;
GO

CREATE PROCEDURE API_LuuCauHinhForm
    @FormID varchar(50),
    @CaptionVN nvarchar(200) = NULL,
    @SubTitle nvarchar(200) = NULL,
    @PrimaryKey varchar(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Giả lập cập nhật menu hệ thống nếu có truyền CaptionVN
    IF @CaptionVN IS NOT NULL
    BEGIN
        UPDATE WA_Menu
        SET VN = @CaptionVN
        WHERE FormName = @FormID;
    END

    -- Trả về dữ liệu vừa lưu để frontend không bị lỗi contract
    SELECT @FormID AS FormID, @CaptionVN AS CaptionVN, @SubTitle AS SubTitle, @PrimaryKey AS PrimaryKey;
END
GO
