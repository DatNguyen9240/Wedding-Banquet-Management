# BUILD SCRIPT - Gop CSS + JS thanh bundle
# Chay: .\build.ps1
# Khi nao them file moi: them vao mang ben duoi roi chay lai

$root = "$PSScriptRoot\src"

# ====== DANH SACH CSS ======
$cssFiles = @(
  "css\design-tokens.css",
  "css\global.css",
  "css\layouts\navbar.css",
  "css\layouts\dashboard.css",
  "components\accordion\accordion.css",
  "components\alert\alert.css",
  "components\badge\badge.css",
  "components\button\button.css",
  "components\calendar\calendar.css",
  "components\card\card.css",
  "components\chart\chart.css",
  "components\checkbox\checkbox.css",
  "components\data-combobox\combobox.css",
  "components\context-menu\context-menu.css",
  "components\empty-state\empty-state.css",
  "components\file-upload\file-upload.css",
  "components\filter\filter.css",
  "components\input\form.css",
  "components\grid-dropdown\grid-dropdown.css",
  "components\loading-spinner\loading-spinner.css",
  "components\modal\modal.css",
  "components\pagination\pagination.css",
  "components\popover\popover.css",
  "components\header\search-bar.css",
  "components\ui-utils\shared-dropdown.css",
  "components\skeleton\skeleton.css",
  "components\slider\slider.css",
  "components\stepper\stepper.css",
  "components\table\table.css",
  "components\tabs\tabs.css",
  "components\timeline\timeline.css",
  "components\toast\toast.css",
  "components\tooltip\tooltip.css",
  "components\total-bar\total-bar.css",
  "components\tree\tree.css",
  "components\user-profile\user-profile.css"
)

# ====== DANH SACH JS ======
$jsFiles = @(
  "js\data\mockData.js",
  "js\utils\permission.js",
  "js\core\KeyboardManager.js",
  "js\utils\FormatUtils.js",
  "js\utils\PrintUtils.js",
  "components\ui-utils\UIUtils.js",
  "components\navbar\Navbar.js",
  "components\checkbox\Checkbox.js",
  "components\data-combobox\DataComboBox.js",
  "components\grid-dropdown\GridDropdown.js",
  "components\loading-spinner\LoadingSpinner.js",
  "components\alert\Alert.js",
  "components\confirm-modal\ConfirmModal.js",
  "components\modal\Modal.js",
  "components\pagination\Pagination.js",
  "components\filter\FilterComponent.js",
  "components\input\Input.js",
  "components\button\Button.js",
  "components\icon\Icon.js",
  "components\action-toolbar\ActionToolbar.js",
  "components\card\Card.js",
  "components\table\Table.js",
  "components\tabs\Tabs.js",
  "components\tabs\NestedTabs.js",
  "components\total-bar\TotalBar.js",
  "components\badge\Badge.js",
  "components\chart\Chart.js",
  "components\stepper\Stepper.js",
  "components\timeline\Timeline.js",
  "components\empty-state\EmptyState.js",
  "components\file-upload\FileUpload.js",
  "components\context-menu\ContextMenu.js",
  "components\accordion\Accordion.js",
  "components\tree\TreeView.js",
  "components\calendar\Calendar.js",
  "components\slider\Slider.js",
  "components\toast\Toast.js",
  "components\popover\Popover.js",
  "components\header\Header.js",
  "components\sidebar\Sidebar.js"
)

# --- Build CSS ---
$css = ""
$count = 0
foreach ($f in $cssFiles) {
  $path = Join-Path $root $f
  if (Test-Path $path) {
    $name = Split-Path $f -Leaf
    $css += "/* --- $name --- */`r`n"
    $css += (Get-Content $path -Raw -Encoding UTF8)
    $css += "`r`n`r`n"
    $count++
  }
}
$cssOut = Join-Path $root "css\styles.bundle.css"
[System.IO.File]::WriteAllText($cssOut, $css, [System.Text.Encoding]::UTF8)
$cssKB = [math]::Round((Get-Item $cssOut).Length / 1024, 1)
Write-Host "CSS: $count files -> styles.bundle.css (${cssKB}KB)" -ForegroundColor Green

# --- Build JS ---
$js = ""
$count = 0
foreach ($f in $jsFiles) {
  $path = Join-Path $root $f
  if (Test-Path $path) {
    $name = Split-Path $f -Leaf
    $js += "/* --- $name --- */`r`n"
    $js += (Get-Content $path -Raw -Encoding UTF8)
    $js += "`r`n`r`n"
    $count++
  }
}
$jsOut = Join-Path $root "js\app.bundle.js"
[System.IO.File]::WriteAllText($jsOut, $js, [System.Text.Encoding]::UTF8)
$jsKB = [math]::Round((Get-Item $jsOut).Length / 1024, 1)
Write-Host "JS:  $count files -> app.bundle.js (${jsKB}KB)" -ForegroundColor Green

Write-Host "`nDone! F5 de xem thay doi." -ForegroundColor Cyan