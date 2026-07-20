USE [QLTiec]
GO

CREATE OR ALTER PROCEDURE dbo.API_TruyVanForm
    @FormKey VARCHAR(50),
    @Keyword NVARCHAR(200) = '',
    @SortColumn VARCHAR(50) = '',
    @SortDir VARCHAR(10) = '',
    @Data NVARCHAR(MAX) = ''
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @TableName SYSNAME;

    SELECT @TableName = TableName
    FROM dbo.SY_FrmLstTbl
    WHERE FormID = @FormKey;

    IF @TableName IS NULL
    BEGIN
        SELECT -1 AS code, N'Unknown or inactive FormKey: ' + ISNULL(@FormKey, '') AS msg;
        RETURN;
    END;

    EXEC dbo.API_TruyVanDong
        @List = @TableName,
        @Keyword = @Keyword,
        @SortColumn = @SortColumn,
        @SortDir = @SortDir,
        @Data = @Data;
END
GO
