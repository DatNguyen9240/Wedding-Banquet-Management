# Canonical metadata and CRUD deployment

Run the SQL files in this order:

1. `sql/Update/Update_MetadataCore.sql`
2. `sql/API/API_LoadFormMeta.sql`
3. `sql/API/API_TruyVanDong.sql`
4. `sql/API/API_LuuDong.sql`
5. `sql/API/API_XoaDong.sql`

`Update_MetadataCore.sql` is intentionally a preflight. It stops on duplicate
field names, duplicate format IDs, duplicate form-column lookup records, or an
invalid metadata reference. Resolve the reported records explicitly; do not
delete or merge rows automatically.

For every dynamic CRUD menu, `FormName` must be the actual user table name.
The table must have exactly one primary-key column. Register every physical
column in `SY_FmtFldTbl` with `CaptionVN` and an existing `FormatID`; add a
`SY_FrmDrdwTbl` row only when that form-column needs lookup or behaviour
configuration.

Then rebuild the frontend bundle with `./build.ps1` and verify list, add,
edit, delete, lookup, and a newly registered column.
