Add-Type -AssemblyName System.IO.Compression.FileSystem
$docx = 'd:\Dat\Wedding-Banquet-Management\backend-app\samples\FILE MAU HOP DONG CÒN LẠI\3.1 MAU HDONG - 0406 (HỘI NGHỊ + TIỆC-TEABREAK).docx'
$zip = [System.IO.Compression.ZipFile]::OpenRead($docx)
$entry = $zip.Entries | Where-Object { $_.FullName -eq 'word/document.xml' }
$stream = $entry.Open()
$reader = New-Object System.IO.StreamReader($stream)
$xml = $reader.ReadToEnd()
$reader.Close()
$stream.Close()
$zip.Dispose()

$text = $xml -replace '<[^>]+>', ''

Write-Host '--- Noi dung text xung quanh PhiPhucVu ---'
[regex]::Matches($text, '.{0,80}(PhiPhucVu|VAT|TongTien).{0,80}') | ForEach-Object { $_.Value }
