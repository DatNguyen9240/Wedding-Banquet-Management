CREATE TABLE [dbo].[tbmk_Hopdongthucdonchay] (
    [UserAutoid] varchar(50) NOT NULL,
    [Sohopdong] varchar(50) NOT NULL,
    [STTmon] tinyint NULL,
    [Mahang] varchar(50) NULL,
    [Dongia] decimal(18,2) NULL,
    [UserCreate] varchar(50) NULL,
    [UserUpdate] varchar(50) NULL,
    [DateCreate] datetime NULL,
    [DateUpdate] datetime NULL,
    [Ghichuthucdonchay] nvarchar(500) NULL,
    [IsKhaividaugio] bit NULL,
    [IsPhan] bit NULL,
    CONSTRAINT [PK_tbmk_Hopdongthucdonchay] PRIMARY KEY CLUSTERED ([UserAutoid] ASC)
);
GO
