CREATE TABLE [dbo].[tbmk_Banuudaict] (
    [UserAutoID] varchar(50) NOT NULL,
    [DocumentID] varchar(20) NULL,
    [Mahang] varchar(30) NULL,
    [Soluong] float NULL,
    [Dongia] float NULL,
    [Sotien] float NULL,
    [UserCreate] varchar(20) NULL,
    [UserUpdate] varchar(20) NULL,
    [DateCreate] datetime NULL,
    [DateUpdate] datetime NULL,
    [STT] int NULL,
    [IsNTL] bit NULL,
    [IsTTS] bit NULL,
    PRIMARY KEY ([UserAutoID])
);
GO
