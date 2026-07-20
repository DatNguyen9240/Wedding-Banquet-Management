# Canonical metadata and CRUD deployment

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
