USE [QLTiec]
GO

-- ==============================================================
-- BƯỚC 1: KÍCH HOẠT QUÁ TRÌNH TỰ CHỮA LÀNH (AUTO-HEAL)
-- Lệnh này sẽ quét cấu hình và "tiêm" các biến mới vào API_TruyVanDong
-- ==============================================================
EXEC dbo.AutoHeal_API_TruyVanDong;
GO

-- ==============================================================
-- BƯỚC 2: TEST CÂU LỆNH TỪ GIAO DIỆN (ĐÃ HẾT LỖI)
-- Lệnh dưới đây trước kia báo lỗi "Too many arguments", 
-- nay đã chạy mượt mà và tự ghép WHERE Tenkh LIKE '%Hoàng Dân%'
-- ==============================================================
EXEC [dbo].[API_TruyVanDong] 
    @FormName = 'frmCustomer',
    @Keyword = '',
    @UserName = 'admin',
    @SortColumn = '',
    @SortDir = '',
    @Page = 1,
    @Limit = 15,
    
    -- Biến lọc động truyền từ UI:
    @Tenkh = N'Hoàng Dân',
    @Makh = NULL,
    @DTcodau = '';
GO
