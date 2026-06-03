USE [QLTiec]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:      Antigravity
-- Create date: 2026-06-03
-- Description: API Tìm/Chọn người giao dịch (khách hàng) cho Combobox và Trigger Autofill
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[API_TimNguoiGiaoDich]
    @Keyword NVARCHAR(100) = NULL,
    @Nguoigd NVARCHAR(100) = NULL,
    @DienThoaiDaiDien NVARCHAR(50) = NULL,
    @DTchure NVARCHAR(50) = NULL,
    @DTcodau NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Nếu gọi từ Trigger (sự kiện Thay đổi SĐT / Tên trên Form, không truyền @Keyword)
    IF (ISNULL(@Keyword, '') = '') AND (ISNULL(@DienThoaiDaiDien, '') <> '' OR ISNULL(@DTchure, '') <> '' OR ISNULL(@DTcodau, '') <> '' OR ISNULL(@Nguoigd, '') <> '')
    BEGIN
        DECLARE @SearchPhone NVARCHAR(50) = ISNULL(NULLIF(@DienThoaiDaiDien, ''), ISNULL(NULLIF(@DTchure, ''), @DTcodau));
        DECLARE @SearchName NVARCHAR(100) = @Nguoigd;

        IF (ISNULL(@SearchPhone, '') <> '')
        BEGIN
            SELECT TOP 1 
                Tenkh = ISNULL(NULLIF(Nguoigd, ''), ISNULL(Tenchure, N'Khách vãng lai')),
                DienThoaiDaiDien = ISNULL(NULLIF(DienThoaiDaiDien, ''), ISNULL(DTchure, '')),
                Tenchure, Tencodau, DTchure, DTcodau, Diachi, Mail,
                Nguoigd = ISNULL(NULLIF(Nguoigd, ''), ISNULL(Tenchure, N'Khách vãng lai'))
            FROM dmkhachhang
            WHERE (Dienthoai = @SearchPhone OR DTchure = @SearchPhone OR DTcodau = @SearchPhone OR DienThoaiDaiDien = @SearchPhone)
            ORDER BY DateCreate DESC;
        END
        ELSE
        BEGIN
            SELECT TOP 1 
                Tenkh = ISNULL(NULLIF(Nguoigd, ''), ISNULL(Tenchure, N'Khách vãng lai')),
                DienThoaiDaiDien = ISNULL(NULLIF(DienThoaiDaiDien, ''), ISNULL(DTchure, '')),
                Tenchure, Tencodau, DTchure, DTcodau, Diachi, Mail,
                Nguoigd = ISNULL(NULLIF(Nguoigd, ''), ISNULL(Tenchure, N'Khách vãng lai'))
            FROM dmkhachhang
            WHERE (Tenkh LIKE N'%' + @SearchName + '%' OR Tenchure LIKE N'%' + @SearchName + '%' OR Tencodau LIKE N'%' + @SearchName + '%' OR Nguoigd LIKE N'%' + @SearchName + '%')
            ORDER BY DateCreate DESC;
        END
    END
    -- 2. Ngược lại là gọi từ Tìm kiếm danh sách thả xuống (Combobox Search)
    ELSE
    BEGIN
        SELECT 
            ISNULL(NULLIF(Nguoigd, ''), ISNULL(Tenchure, N'Khách vãng lai')) AS [Tenkh],
            ISNULL(NULLIF(DienThoaiDaiDien, ''), ISNULL(DTchure, '')) AS [DienThoaiDaiDien],
            Tenchure, Tencodau, DTchure, DTcodau, Diachi, Mail,
            Nguoigd = ISNULL(NULLIF(Nguoigd, ''), ISNULL(Tenchure, N'Khách vãng lai'))
        FROM dmkhachhang
        WHERE (@Keyword IS NULL OR @Keyword = '')
           OR Tenkh LIKE N'%' + @Keyword + '%'
           OR Tenchure LIKE N'%' + @Keyword + '%'
           OR Tencodau LIKE N'%' + @Keyword + '%'
           OR Dienthoai LIKE '%' + @Keyword + '%'
           OR Nguoigd LIKE N'%' + @Keyword + '%'
           OR DienThoaiDaiDien LIKE '%' + @Keyword + '%'
        ORDER BY DateCreate DESC;
    END
END
GO
