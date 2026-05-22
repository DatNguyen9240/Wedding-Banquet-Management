-- 1. Thêm 2 cột mới ShowInAdd và ShowInEdit
ALTER TABLE SY_FormatFields ADD ShowInAdd BIT DEFAULT 1;
ALTER TABLE SY_FormatFields ADD ShowInEdit BIT DEFAULT 1;
GO

-- 2. Cập nhật dữ liệu cũ từ ShowInForm sang 2 cột mới
UPDATE SY_FormatFields 
SET ShowInAdd = ISNULL(ShowInForm, 1), 
    ShowInEdit = ISNULL(ShowInForm, 1);
GO

PRINT N'Đã thêm và cập nhật thành công 2 cột ShowInAdd, ShowInEdit cho bảng SY_FormatFields!';
