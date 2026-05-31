CREATE TABLE [dbo].[tbKhuyenmai](
	[Khuyenmaiid] [varchar](20) NOT NULL,
	[Ngaykhuyenmai] [datetime] NULL,
	[Tungay] [datetime] NULL,
	[Denngay] [datetime] NULL,
	[Giobatdau] [int] NULL,
	[Gioketthuc] [int] NULL,
	[Manv] [varchar](20) NULL,
	[Mahang] [varchar](30) NULL,
	[Soluong] [int] NULL,
	[IsLoaikm] [bit] NULL,
	[Ghichu] [nvarchar](254) NULL,
	[UserCreate] [varchar](20) NULL,
	[UserUpdate] [varchar](20) NULL,
	[DateCreate] [datetime] NULL,
	[DateUpdate] [datetime] NULL,
	[Nhahangid] [varchar](50) NULL,
 CONSTRAINT [PK_tbKhuyenmai] PRIMARY KEY CLUSTERED 
(
	[Khuyenmaiid] ASC
)
)
GO
