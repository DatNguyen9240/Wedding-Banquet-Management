USE [QLTiec]
GO

/****** Object:  StoredProcedure [dbo].[API_WA_LuuQuyenCuaNhom] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[API_WA_LuuQuyenCuaNhom]
    @NhomNguoiDangThaoTac NVARCHAR(50), -- BẮT BUỘC THÊM: Truyền Session Nhóm của người ĐANG BẤM NÚT LƯU
    @UserGroupID NVARCHAR(50),          -- Nhóm BỊ gán quyền
    @MenuID NVARCHAR(50),               -- Form BỊ gán quyền
    @IsRun BIT,                         
    @IsAdd BIT,                         
    @IsUpdate BIT,                      
    @IsDelete BIT                       
AS
BEGIN
    SET NOCOUNT ON;

    -- =======================================================
    -- BƯỚC 1: CẢNH VỆ HỆ THỐNG - CHỈ SUPER ADMIN MỚI ĐƯỢC CHẠY
    -- Khoá cứng điều kiện: Mã nhóm thao tác bắt buộc phải là 'Admin'
    -- (Nếu công ty bạn lưu mã Admin là ký hiệu khác như 'G01' hay 'QuanTri' thì bạn thay tên vào nhé)
    -- =======================================================
    IF (@NhomNguoiDangThaoTac != 'Admin')
    BEGIN
        -- Hất văng Request ngay tắp lự, đá lỗi đỏ (Mã 16) về cho C# xử lý
        RAISERROR (N'Lỗi Bảo Mật: Bạn không phải Giám đốc Server, cấm sửa Phân Quyền!', 16, 1);
        RETURN; 
    END

    -- =======================================================
    -- BƯỚC 2: CẬP NHẬT DATABASE
    -- =======================================================
    UPDATE WA_UserGroupPermisstion
    SET 
        IsRun = @IsRun,
        IsAdd = @IsAdd,
        IsUpdate = @IsUpdate,
        IsDelete = @IsDelete
    WHERE UserGroupID = @UserGroupID 
      AND MenuID = @MenuID;

END
GO
