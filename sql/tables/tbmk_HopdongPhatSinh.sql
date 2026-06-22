CREATE TABLE [dbo].[tbmk_HopdongPhatSinh] (
    [UserAutoid] varchar(50) NOT NULL,
    [Sohopdong] varchar(50) NOT NULL,
    [Mahang] varchar(50) NULL,
    [Soluong] decimal(18,2) NULL,
    [Dongia] decimal(18,2) NULL,
    [Sotien] decimal(18,2) NULL,
    [GhiChuPhatSinh] nvarchar(500) NULL,
    [UserCreate] varchar(50) NULL,
    [DateCreate] datetime NULL,
    CONSTRAINT [PK_tbmk_HopdongPhatSinh] PRIMARY KEY CLUSTERED ([UserAutoid] ASC)
);
GO
