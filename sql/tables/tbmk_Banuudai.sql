CREATE TABLE [dbo].[tbmk_Banuudai] (
    [DocumentID] varchar(20) NOT NULL,
    [DocumentDate] datetime NULL,
    [Tenuudai] nvarchar(250) NULL,
    [Tungay] datetime NULL,
    [Denngay] datetime NULL,
    [Tusoluongban] int NULL,
    [Densoluongban] int NULL,
    [UserCreate] varchar(20) NULL,
    [UserUpdate] varchar(20) NULL,
    [DateUpdate] datetime NULL,
    [DateCreate] datetime NULL,
    [Ghichu] nvarchar(250) NULL,
    [Nhahangid] varchar(50) NULL,
    [Tongtien] float NULL,
    [Manv] varchar(20) NULL,
    [Giaban] float NULL,
    [IsKetthuc] bit NULL,
    [Loaitiecid] varchar(10) NULL,
    [GoiThucDonID] varchar(50) NULL,
    [BranchID] varchar(50) NULL,
    PRIMARY KEY ([DocumentID])
);
GO
