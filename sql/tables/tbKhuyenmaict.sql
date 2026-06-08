CREATE TABLE [dbo].[tbKhuyenmaict] (
    [UserAutoID] varchar(40) NOT NULL,
    [Khuyenmaiid] varchar(20) NULL,
    [Mahang] varchar(30) NULL,
    [Soluongkm] float NULL,
    [UserCreate] varchar(20) NULL,
    [UserUpdate] varchar(20) NULL,
    [DateCreate] datetime NULL,
    [DateUpdate] datetime NULL,
    PRIMARY KEY ([UserAutoID])
);
GO
