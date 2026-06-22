SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'API_LuuPhatSinhNhanh')
    DROP PROCEDURE [dbo].[API_LuuPhatSinhNhanh]
GO

CREATE PROCEDURE [dbo].[API_LuuPhatSinhNhanh]
    @Sohopdong VARCHAR(50),
    @JsonPhatSinh NVARCHAR(MAX),
    @UserName VARCHAR(50) = 'system'
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        IF (@JsonPhatSinh IS NOT NULL)
        BEGIN
            DELETE FROM tbmk_HopdongPhatSinh WHERE Sohopdong = @Sohopdong;
            INSERT INTO tbmk_HopdongPhatSinh (
                UserAutoid, Sohopdong, Mahang, Soluong, Dongia, Sotien,
                GhiChuPhatSinh, UserCreate, DateCreate
            )
            SELECT
                NEWID(), @Sohopdong, j.Mahang, j.Soluong, j.Dongia, (j.Soluong * j.Dongia),
                j.GhiChuPhatSinh, @UserName, GETDATE()
            FROM OPENJSON(@JsonPhatSinh)
            WITH (
                Mahang VARCHAR(50), Soluong DECIMAL(18,2), Dongia DECIMAL(18,2),
                GhiChuPhatSinh NVARCHAR(500)
            ) j;
        END

        COMMIT TRANSACTION;
        SELECT 1 AS [Success], N'Lưu Món Phát Sinh thành công!' AS [Message];
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SELECT 0 AS [Success], ERROR_MESSAGE() AS [Message];
    END CATCH
END
GO

DELETE FROM WA_API WHERE List='frmHopDong' AND Func='SavePhatSinh';
INSERT INTO WA_API (List, Func, [SQL], Para)
VALUES ('frmHopDong', 'SavePhatSinh', 'API_LuuPhatSinhNhanh', '@Sohopdong=N''{Sohopdong}'', @JsonPhatSinh=N''{JsonPhatSinh}'', @UserName=N''{UserName}''');
GO
