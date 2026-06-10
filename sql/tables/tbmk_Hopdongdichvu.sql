CREATE TABLE [dbo].[tbmk_Hopdongdichvu] (
    [UserAutoid] varchar(50) NOT NULL,
    [Sohopdong] varchar(50) NOT NULL,
    [Mahang] varchar(50) NULL,
    [Soluong] decimal(18,2) NULL,
    [Dongia] decimal(18,2) NULL,
    [Sotien] decimal(18,2) NULL,
    [UserCreate] varchar(50) NULL,
    [UserUpdate] varchar(50) NULL,
    [DateCreate] datetime NULL,
    [DateUpdate] datetime NULL,
    [IsKhuyenmai] bit NULL,
    [Ghichudichvu] nvarchar(500) NULL,
    [STT] int NULL,
    CONSTRAINT [PK_tbmk_Hopdongdichvu] PRIMARY KEY CLUSTERED ([UserAutoid] ASC)
);
GO
