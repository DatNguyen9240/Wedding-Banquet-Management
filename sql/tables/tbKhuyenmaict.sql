CREATE TABLE [dbo].[tbKhuyenmaict](
	[UserAutoID] [varchar](40) NOT NULL,
	[Khuyenmaiid] [varchar](20) NOT NULL,
	[Mahang] [varchar](30) NOT NULL,
	[Soluongkm] [float] NULL,
	[UserCreate] [varchar](20) NULL,
	[UserUpdate] [varchar](20) NULL,
	[DateCreate] [datetime] NULL,
	[DateUpdate] [datetime] NULL,
 CONSTRAINT [PK_tbKhuyenmaict] PRIMARY KEY CLUSTERED 
(
	[UserAutoID] ASC
)
)
GO
