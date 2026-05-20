USE [QLTiec]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:      Antigravity
-- Create date: 2026-04-29
-- Description: API Hủy Phiếu Biên Nhận Cọc Chỗ
-- =============================================
CREATE PROCEDURE [dbo].[API_HuyPhieuCoc]
    @DocumentID VARCHAR(50),
    @Lydohuy NVARCHAR(500) = NULL,
    @UserUpdate VARCHAR(50) = 'System'
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM tbmk_Biennhancoccho WHERE DocumentID = @DocumentID)
        BEGIN
            SELECT 0 AS [Success], N'Không tìm thấy phiếu cọc cần hủy!' AS [Message];
            RETURN;
        END

        UPDATE tbmk_Biennhancoccho
        SET 
            IsHuy = 1,
            Ngayhuy = GETDATE(),
            Lydohuy = @Lydohuy,
            DateUpdate = GETDATE(),
            UserUpdate = @UserUpdate
        WHERE DocumentID = @DocumentID;

        SELECT 1 AS [Success], N'Đã hủy phiếu cọc thành công.' AS [Message];
    END TRY
    BEGIN CATCH
        SELECT 0 AS [Success], ERROR_MESSAGE() AS [Message];
    END CATCH
END
GO
