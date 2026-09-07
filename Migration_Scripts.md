# Canonical metadata and CRUD deployment

## Wedding source fixes 2026-09-05 (not deployed)

Apply `sql/Update/Update_WeddingEditableFields.sql` before refreshing contract source. Then refresh `sql/Functions/fn_DOCX_MenuDichVu.sql`, `sql/View/v_DanhSachHopDong.sql`, `sql/API/API_LuuHopDong.sql`, `sql/Update/Update_frmHopDong_GetDetails.sql`, `sql/API/API_LayDichVuUuDaiTheoLoaiTiec.sql`, `sql/Update/Update_PhuLuc_AllInOne.sql`, and finally `sql/Update/Update_frmPhuLucHopDong_GetDetails.sql`. Use the existing procedure-update workflow for files declaring CREATE PROCEDURE. The all-in-one appendix script contains its existing migration/trigger operations; review these before database deployment.

Deploy the changed DOCX templates, backend `wedding-template-routing.js`/`server.js`, and rebuilt frontend bundle together. Routing uses the linked, non-cancelled deposit receipt's DocumentDate with positive SoTienCocCho; missing receipt dates do not fall back to today or contract date. Fees remain percentage-based: PhiPhucVuTyLe is the editable percentage, 0 means free. Promotion selection stores the chosen content in Noidunguudai; it does not keep a catalog foreign key.

`Seed_SY_Setup_BenA.sql` now preserves all existing values unless a confirmed address is explicitly supplied. The address has not yet been confirmed in this session; do not seed the old sample address or tax ID.

## Source changes 2026-09-05 — conference, contact and invoice (not deployed)

Before applying the updated contract view/API, run `sql/Update/Update_ContractContactInvoice.sql` to add the four nullable input columns and their generic form metadata. Keep existing contract data unchanged. Then apply `sql/View/v_DanhSachHopDong.sql`, the updated definition of `sql/API/API_LuuHopDong.sql`, and `sql/Update/Update_frmHopDong_GetDetails.sql`. The API source uses `CREATE PROCEDURE`; use the existing procedure-update workflow if already installed.

Setup output also depends on `sql/Update/Update_dmKieuSetup.sql` and hall rows having `LoaiDiaDiem` and `KieuSetup`. Templates 2.1/2.2/3.1/3.2 and the new data fields should be deployed together. No SQL Server changes were executed in this source-fix session.

Run the SQL files in this order:

1. `sql/Update/Report_CrudReadiness.sql` (read-only audit)
2. `sql/Update/Report_ActiveCrudMetadataGaps.sql` (read-only: exact gaps for generic tables)
3. `sql/Update/Report_FieldDictionaryClassification.sql` (read-only: legacy dictionary cleanup backlog)
4. `sql/Update/Update_MetadataDictionary_Dedupe.sql`
5. `sql/Update/Update_WA_Menu_Metadata.sql`
6. Resolve any remaining row reported by `Report_ActiveCrudMetadataGaps.sql` explicitly.
7. If the metadata preflight reports 51004, run `sql/Update/Report_DropdownDuplicateKeys.sql` and resolve those controls explicitly.
8. `sql/Update/Update_DropdownDuplicateCleanup.sql` (the four reviewed current duplicates)
9. `sql/Update/Update_MetadataCore.sql`
10. `sql/Update/Update_FormRegistry.sql`
11. `sql/API/API_LoadFormMeta.sql`
12. `sql/API/API_TruyVanDong.sql`
13. `sql/API/API_LuuDong.sql`
14. `sql/API/API_XoaDong.sql`
15. `sql/API/API_TruyVanForm.sql`
16. `sql/API/API_LuuForm.sql`
17. `sql/API/API_XoaForm.sql`

`Update_MetadataCore.sql` is intentionally a preflight. It stops on duplicate
field names, duplicate format IDs, or
duplicate UI controls with the same `FormID + GridName + ColumnID`. It
normalizes a blank `GridName` to `NULL`, and replaces the previous incorrect
two-part dropdown index with the three-part UI-control key. Resolve reported
dictionary records explicitly. The runtime validates only the dictionary
records of the requested table; it never assigns a generic text format merely
to make the validation pass.

For every dynamic CRUD menu, `WA_Menu.FormKey` identifies a row in
`SY_FrmLstTbl` by `FormID`. `TableName` defines the read/write source and
`PrimaryKey` defines the row identity; CRUD authorization comes only from
`WA_UserGroupPermisstion`. Register every column
exposed by the read source in `SY_FmtFldTbl` with `CaptionVN` and an existing
`FormatID`; add a `SY_FrmDrdwTbl` row only when that form/grid-column needs
lookup or behaviour configuration. `SY_FrmDrdwTbl.FormID` is the UI form key,
not a database-object name.

Then rebuild the frontend bundle with `./build.ps1` and verify list, add,
edit, delete, lookup, and a newly registered column.

## Shared engine for custom read models

The quotation and visitor menus use the same `DynamicFormEngine` shell as a
generic CRUD table. Their `FormKey` maps only the data contract: a physical
read-model view for schema/metadata and the dedicated list procedure for data.
Run these files before opening `#/baogia` or `#/visitor`:

1. `sql/View/v_DanhSachKhachThamQuan.sql`
2. `sql/View/v_DanhSachBaoGia.sql`
3. `sql/Update/Update_CustomReadModelMetadata.sql`

Those two list pages are deliberately read-only until their existing
multi-table save/delete procedures are bound as explicit engine actions. They
are not separate frontend pages and do not use a fabricated reload toolbar.

For the contract list, run `sql/Update/Update_ContractReadModelMetadata.sql`
after the view exists. It registers every view column in the global dictionary
and limits the grid to its ten explicit list columns.

## Existing dynamic menu pages

Do not rerun legacy `*_AllInOne.sql` files for a page converted to generic
CRUD: those scripts still target form aliases, views, and `WA_API`. Use a
small explicit menu mapping to the physical CRUD table, then run
`Report_ActiveCrudMetadataGaps.sql` and register every reported dictionary
field. For Customers, run `sql/Update/Update_Customer_GenericCrud.sql`; it
maps menu `0510` from legacy `frmKhachHang` to `dmkhachhang`.
Then run `sql/Update/Update_dmKhachHang_Metadata.sql` to register the current
customer-table fields before opening `#/customers`.

## Feature updates & New catalogs (2026)

Run these scripts for modern event setup layouts, banquet hall role division, decoration catalog, and food replacement features:

1. `sql/Update/Update_dmKieuSetup.sql` (Creates `dmKieuSetup`, alters `tbmk_Hopdongsanhtiec` with `KieuSetup`, `LoaiDiaDiem`, `Thoigianid`, `Giatiensanh`, and registers WA_API & dropdowns)
2. `sql/Update/Update_dmMauTrangTri_DoiMon.sql` (Creates `dmMauTrangTri`, `tbmk_HopdongDoiMon`, alters `tbmk_Hopdong.MauTrangTriID`, and registers WA_API procedures)
3. `sql/Functions/fn_DOCX_MenuDichVu.sql` (Deploys `fn_DOCX_MenuMan`, `fn_DOCX_MenuChay`, `fn_DOCX_MenuTongCongChay`)
4. `sql/View/v_DanhSachHopDong.sql` (Updates contract view with multi-sảnh separation, overtime fee formula, setup styles, and auto-routing for wedding menu ngay)
5. `sql/Update/Update_PhuLuc_AllInOne.sql` and `sql/Update/Update_frmPhuLucHopDong_GetDetails.sql` (Updates addendum view & detail procedure with vegetarian menu separation and full table count fields)
6. `sql/Update/Seed_SY_Setup_BenA.sql` (Seeds canonical Party A corporate setup details: name, address, phone, tax code, representative)
7. `sql/Update/Update_QuyetToan_AllInOne.sql` (Integrates food replacement price diff `tbmk_HopdongDoiMon` into final settlement and reports)
8. `sql/API/API_LuuHopDong.sql` (Supports saving decor theme ID, exhibition parameters, and individual hall pricing/types)
9. `sql/API/API_LayDichVuUuDaiTheoLoaiTiec.sql` (Filters promotions based on event organization date and validity range)
