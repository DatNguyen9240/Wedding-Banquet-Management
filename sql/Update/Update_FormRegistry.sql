USE [QLTiec]
GO

/*
  Form registry: the only place where a menu form is mapped to its data
  source and write contract. SY_FmtFldTbl/SY_FmatTbl/SY_FrmDrdwTbl remain the
  field/display metadata; this table supplies the missing form-level facts.
*/
SET XACT_ABORT ON
GO

IF OBJECT_ID(N'dbo.SY_FormTbl', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.SY_FormTbl
    (
        FormKey         VARCHAR(50)  NOT NULL,
        DataSource      SYSNAME      NOT NULL,
        WriteObject     SYSNAME      NULL,
        PrimaryKey      SYSNAME      NOT NULL,
        SaveProcedure   SYSNAME      NULL,
        DeleteProcedure SYSNAME      NULL,
        DeleteIdsParameter SYSNAME  NOT NULL CONSTRAINT DF_SY_FormTbl_DeleteIdsParameter DEFAULT ('Ids'),
        IsPaged         BIT          NOT NULL CONSTRAINT DF_SY_FormTbl_IsPaged DEFAULT (0),
        CanAdd          BIT          NOT NULL CONSTRAINT DF_SY_FormTbl_CanAdd DEFAULT (0),
        CanEdit         BIT          NOT NULL CONSTRAINT DF_SY_FormTbl_CanEdit DEFAULT (0),
        CanDelete       BIT          NOT NULL CONSTRAINT DF_SY_FormTbl_CanDelete DEFAULT (0),
        CanPrint        BIT          NOT NULL CONSTRAINT DF_SY_FormTbl_CanPrint DEFAULT (0),
        DocumentTemplate NVARCHAR(255) NULL,
        DocumentListName SYSNAME       NULL,
        DocumentIdField  SYSNAME       NULL,
        IsActive        BIT          NOT NULL CONSTRAINT DF_SY_FormTbl_IsActive DEFAULT (1),
        CONSTRAINT PK_SY_FormTbl PRIMARY KEY (FormKey)
    );
END;

IF COL_LENGTH(N'dbo.SY_FormTbl', N'DeleteIdsParameter') IS NULL
    ALTER TABLE dbo.SY_FormTbl
        ADD DeleteIdsParameter SYSNAME NOT NULL
            CONSTRAINT DF_SY_FormTbl_DeleteIdsParameter DEFAULT ('Ids');

IF COL_LENGTH(N'dbo.SY_FormTbl', N'CanPrint') IS NULL
    ALTER TABLE dbo.SY_FormTbl
        ADD CanPrint BIT NOT NULL
            CONSTRAINT DF_SY_FormTbl_CanPrint DEFAULT (0);

IF COL_LENGTH(N'dbo.SY_FormTbl', N'DocumentTemplate') IS NULL
    ALTER TABLE dbo.SY_FormTbl ADD DocumentTemplate NVARCHAR(255) NULL;

IF COL_LENGTH(N'dbo.SY_FormTbl', N'DocumentListName') IS NULL
    ALTER TABLE dbo.SY_FormTbl ADD DocumentListName SYSNAME NULL;

IF COL_LENGTH(N'dbo.SY_FormTbl', N'DocumentIdField') IS NULL
    ALTER TABLE dbo.SY_FormTbl ADD DocumentIdField SYSNAME NULL;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @Forms TABLE
    (
        FormKey VARCHAR(50) NOT NULL PRIMARY KEY,
        DataSource SYSNAME NOT NULL,
        WriteObject SYSNAME NULL,
        PrimaryKey SYSNAME NOT NULL,
        SaveProcedure SYSNAME NULL,
        DeleteProcedure SYSNAME NULL,
        DeleteIdsParameter SYSNAME NOT NULL,
        IsPaged BIT NOT NULL,
        CanAdd BIT NOT NULL,
        CanEdit BIT NOT NULL,
        CanDelete BIT NOT NULL,
        CanPrint BIT NOT NULL,
        DocumentTemplate NVARCHAR(255) NULL,
        DocumentListName SYSNAME NULL,
        DocumentIdField SYSNAME NULL
    );

    INSERT INTO @Forms
        (FormKey, DataSource, WriteObject, PrimaryKey, SaveProcedure, DeleteProcedure, DeleteIdsParameter, IsPaged, CanAdd, CanEdit, CanDelete, CanPrint, DocumentTemplate, DocumentListName, DocumentIdField)
    VALUES
        ('0510', 'dmkhachhang',                'dmkhachhang',          'Makh',       NULL,                NULL,               'Ids',         0, 1, 1, 1, 0, NULL,                NULL,                    NULL),
        ('0520', 'v_DanhSachBaoGia',           NULL,                    'Sohopdong',  NULL,                NULL,               'Ids',         0, 0, 0, 0, 1, N'bao_gia',        'frmBaoGia',            'Sohopdong'),
        ('0530', 'v_DanhSachKhachThamQuan',    NULL,                    'MaPhieu',    NULL,                NULL,               'Ids',         0, 0, 0, 0, 0, NULL,                NULL,                    NULL),
        ('0540', 'v_DanhSachHopDong',          'tbmk_Hopdong',         'Sohopdong',  'API_LuuHopDong',   'API_XoaHopDong',  'Ids',         0, 1, 1, 1, 1, N'hop_dong',       'API_DanhSachHopDong', 'Sohopdong'),
        ('0544', 'v_DanhSachPhieuCoc',         'tbmk_Biennhancoccho',  'DocumentID',  'API_LuuPhieuCoc',  'API_XoaPhieuCoc', 'DocumentIDs', 0, 1, 1, 1, 1, N'phieu_thu',      'API_DanhSachPhieuCoc','DocumentID'),
        ('0550', 'v_DanhSachPhuLuc',           'tbmk_Thaydoi',         'Sothaydoi',   'API_LuuThayDoi',   'API_XoaThayDoi',  'Ids',         0, 1, 1, 1, 1, N'phu_luc_hop_dong','frmPhuLucHopDong',    'Sothaydoi'),
        ('0560', 'v_DanhSachBEO',              NULL,                    'Sohopdong',  NULL,                NULL,               'Ids',         0, 0, 0, 0, 1, N'beo_tiec_cuoi',  'frmBEO',               'Sohopdong'),
        ('0567', 'v_DanhSachQuyetToan',        'tbmk_Phieuthu',        'DocumentID',  'API_LuuQuyenToan', 'API_XoaPhieuThu', 'Ids',         0, 1, 1, 1, 1, N'quyet_toan',    'frmQuyetToan',         'Sohopdong');

    IF EXISTS
    (
        SELECT 1
        FROM @Forms F
        WHERE OBJECT_ID(F.DataSource) IS NULL
           OR OBJECTPROPERTY(OBJECT_ID(F.DataSource), 'IsUserTable') = 0
              AND OBJECTPROPERTY(OBJECT_ID(F.DataSource), 'IsView') = 0
    )
        THROW 51110, 'A SY_FormTbl DataSource must be an existing table or view.', 1;

    IF EXISTS
    (
        SELECT 1
        FROM @Forms F
        WHERE F.WriteObject IS NOT NULL
          AND OBJECTPROPERTY(OBJECT_ID(F.WriteObject), 'IsUserTable') = 0
    )
        THROW 51111, 'A SY_FormTbl WriteObject must be an existing user table.', 1;

    IF EXISTS
    (
        SELECT 1
        FROM @Forms F
        WHERE (F.SaveProcedure IS NOT NULL AND OBJECT_ID(N'dbo.' + F.SaveProcedure, N'P') IS NULL)
           OR (F.DeleteProcedure IS NOT NULL AND OBJECT_ID(N'dbo.' + F.DeleteProcedure, N'P') IS NULL)
    )
        THROW 51112, 'A configured form procedure does not exist.', 1;

    IF EXISTS
    (
        SELECT 1
        FROM @Forms
        WHERE CanPrint = 1
          AND (NULLIF(DocumentTemplate, N'') IS NULL
            OR NULLIF(DocumentListName, N'') IS NULL
            OR NULLIF(DocumentIdField, N'') IS NULL)
    )
        THROW 51113, 'A printable form must define DocumentTemplate, DocumentListName and DocumentIdField.', 1;

    MERGE dbo.SY_FormTbl AS Target
    USING @Forms AS Source ON Source.FormKey = Target.FormKey
    WHEN MATCHED THEN UPDATE SET
        DataSource = Source.DataSource,
        WriteObject = Source.WriteObject,
        PrimaryKey = Source.PrimaryKey,
        SaveProcedure = Source.SaveProcedure,
        DeleteProcedure = Source.DeleteProcedure,
        DeleteIdsParameter = Source.DeleteIdsParameter,
        IsPaged = Source.IsPaged,
        CanAdd = Source.CanAdd,
        CanEdit = Source.CanEdit,
        CanDelete = Source.CanDelete,
        CanPrint = Source.CanPrint,
        DocumentTemplate = Source.DocumentTemplate,
        DocumentListName = Source.DocumentListName,
        DocumentIdField = Source.DocumentIdField,
        IsActive = 1
    WHEN NOT MATCHED THEN INSERT
        (FormKey, DataSource, WriteObject, PrimaryKey, SaveProcedure, DeleteProcedure, DeleteIdsParameter, IsPaged, CanAdd, CanEdit, CanDelete, CanPrint, DocumentTemplate, DocumentListName, DocumentIdField)
    VALUES
        (Source.FormKey, Source.DataSource, Source.WriteObject, Source.PrimaryKey, Source.SaveProcedure, Source.DeleteProcedure, Source.DeleteIdsParameter, Source.IsPaged, Source.CanAdd, Source.CanEdit, Source.CanDelete, Source.CanPrint, Source.DocumentTemplate, Source.DocumentListName, Source.DocumentIdField);

    UPDATE M
    SET M.FormKey = F.FormKey,
        M.FormName = F.DataSource
    FROM dbo.WA_Menu M
    INNER JOIN @Forms F ON F.FormKey = M.MenuID;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO
