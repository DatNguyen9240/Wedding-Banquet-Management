const fs = require('fs');
const path = require('path');
const PizZip = require('pizzip');

const uploadsDir = 'uploads';
const files = fs.readdirSync(uploadsDir);

// Find the absolute latest generated file in uploads/
const targetFile = files
    .filter(f => f.endsWith('.docx') && f.includes('_178'))
    .sort((a, b) => fs.statSync(path.join(uploadsDir, b)).mtimeMs - fs.statSync(path.join(uploadsDir, a)).mtimeMs)[0];

if (!targetFile) {
    console.log('No generated file found in uploads!');
    process.exit(1);
}

const filePath = path.join(uploadsDir, targetFile);
console.log('Checking generated file:', filePath);

const content = fs.readFileSync(filePath, 'binary');
const zip = new PizZip(content);
const xml = zip.files['word/document.xml'].asText();

console.log('=== GENERATED FILE CHECK ===');
console.log('Does XML contain "75 - 84 bàn"?', xml.includes('75 - 84 bàn'));
console.log('Does XML contain "Mốc 55 Bàn"?', xml.includes('Mốc 55 Bàn'));
console.log('Does XML contain "DichVuKhuyenMai"?', xml.includes('DichVuKhuyenMai'));

const labelIdx = xml.indexOf('DỊCH VỤ ƯU ĐÃI');
if (labelIdx !== -1) {
    console.log('Context around "DỊCH VỤ ƯU ĐÃI":', xml.substring(labelIdx - 200, labelIdx + 800));
} else {
    console.log('"DỊCH VỤ ƯU ĐÃI" label not found in XML!');
}
