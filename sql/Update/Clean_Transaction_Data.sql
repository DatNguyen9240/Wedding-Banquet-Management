USE [QLTiec]
GO

-- Bắt đầu TRANSACTION để đảm bảo tính toàn vẹn dữ liệu
BEGIN TRANSACTION;
BEGIN TRY

    PRINT N'1. Đang dọn dẹp dữ liệu Quyết toán / Biên bản nghiệm thu (Phần thu)...';
    IF OBJECT_ID('tbmk_Phieuthubantiec', 'U') IS NOT NULL
        DELETE FROM tbmk_Phieuthubantiec;
    IF OBJECT_ID('tbmk_Phieuthuthucuong', 'U') IS NOT NULL
        DELETE FROM tbmk_Phieuthuthucuong;
    IF OBJECT_ID('tbmk_PhieuthuDichvu', 'U') IS NOT NULL
        DELETE FROM tbmk_PhieuthuDichvu;
    IF OBJECT_ID('tbmk_Phieuthuphatsinh', 'U') IS NOT NULL
        DELETE FROM tbmk_Phieuthuphatsinh;
    IF OBJECT_ID('tbmk_Phieuthu', 'U') IS NOT NULL
        DELETE FROM tbmk_Phieuthu;

    PRINT N'2. Đang dọn dẹp dữ liệu Phụ lục thay đổi bổ sung...';
    IF OBJECT_ID('tbmk_Thaydoithucdonman', 'U') IS NOT NULL
        DELETE FROM tbmk_Thaydoithucdonman;
    IF OBJECT_ID('tbmk_Thaydoithucdonchay', 'U') IS NOT NULL
        DELETE FROM tbmk_Thaydoithucdonchay;
    IF OBJECT_ID('tbmk_Thaydoithucuong', 'U') IS NOT NULL
        DELETE FROM tbmk_Thaydoithucuong;
    IF OBJECT_ID('tbmk_Thaydoidichvu', 'U') IS NOT NULL
        DELETE FROM tbmk_Thaydoidichvu;
    IF OBJECT_ID('tbmk_Thaydoi', 'U') IS NOT NULL
        DELETE FROM tbmk_Thaydoi;

    PRINT N'3. Đang dọn dẹp dữ liệu Báo giá & Hợp đồng (gồm cả BEO)...';
    IF OBJECT_ID('tbmk_Hopdongsanhtiec', 'U') IS NOT NULL
        DELETE FROM tbmk_Hopdongsanhtiec;
    IF OBJECT_ID('tbmk_Hopdongthucdonman', 'U') IS NOT NULL
        DELETE FROM tbmk_Hopdongthucdonman;
    IF OBJECT_ID('tbmk_Hopdongthucdonchay', 'U') IS NOT NULL
        DELETE FROM tbmk_Hopdongthucdonchay;
    IF OBJECT_ID('tbmk_Hopdongthucuong', 'U') IS NOT NULL
        DELETE FROM tbmk_Hopdongthucuong;
    IF OBJECT_ID('tbmk_Hopdongdichvu', 'U') IS NOT NULL
        DELETE FROM tbmk_Hopdongdichvu;
    IF OBJECT_ID('tbmk_Hopdong', 'U') IS NOT NULL
        DELETE FROM tbmk_Hopdong;

    PRINT N'4. Đang dọn dẹp dữ liệu Biên nhận cọc chỗ (Đặt cọc)...';
    IF OBJECT_ID('tbmk_Biennhancocchosanhtiec', 'U') IS NOT NULL
        DELETE FROM tbmk_Biennhancocchosanhtiec;
    IF OBJECT_ID('tbmk_Biennhancoccho', 'U') IS NOT NULL
        DELETE FROM tbmk_Biennhancoccho;

    PRINT N'5. Đang dọn dẹp dữ liệu Khách tham quan...';
    IF OBJECT_ID('tbmk_Khachden', 'U') IS NOT NULL
        DELETE FROM tbmk_Khachden;
    IF OBJECT_ID('tbmk_Khachthamquansanhtiec', 'U') IS NOT NULL
        DELETE FROM tbmk_Khachthamquansanhtiec;
    IF OBJECT_ID('tbmk_Khachthamquan', 'U') IS NOT NULL
        DELETE FROM tbmk_Khachthamquan;

    PRINT N'6. Đang dọn dẹp danh sách Khách hàng được tạo tự động (mã KH*)...';
    IF OBJECT_ID('dmkhachhang', 'U') IS NOT NULL
        DELETE FROM dmkhachhang WHERE Makh LIKE 'KH%';

    COMMIT TRANSACTION;
    PRINT N'>> ĐÃ CLEAN TOÀN BỘ DỮ LIỆU GIAO GIAO DỊCH CỦA CÁC TRANG THÀNH CÔNG!';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT N'Lỗi xảy ra trong quá trình clean dữ liệu: ' + ERROR_MESSAGE();
END CATCH
GO
