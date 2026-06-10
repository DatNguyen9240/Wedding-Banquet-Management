CREATE TABLE [dbo].[tbmk_Hopdongthucdonman] (
    [UserAutoid] varchar(50) NOT NULL,
    [Sohopdong] varchar(50) NOT NULL,
    [STTmon] tinyint NULL,
    [Mahang] varchar(50) NULL,
    [Dongia] decimal(18,2) NULL,
    [UserCreate] varchar(50) NULL,
    [UserUpdate] varchar(50) NULL,
    [DateCreate] datetime NULL,
    [DateUpdate] datetime NULL,
    [Ghichuthucdonman] nvarchar(500) NULL,
    [IsKhaividaugio] bit NULL,
    CONSTRAINT [PK_tbmk_Hopdongthucdonman] PRIMARY KEY CLUSTERED ([UserAutoid] ASC)
);
GO
