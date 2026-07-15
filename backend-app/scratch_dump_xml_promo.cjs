const fs = require('fs');
const PizZip = require('pizzip');

const content = fs.readFileSync('samples/BEO TIEC CTY - Chua Thay Doi.docx', 'binary');
const zip = new PizZip(content);
const xml = zip.files['word/document.xml'].asText();

const tag = 'DichVuKhuyenMai';
const idx = xml.indexOf(tag);
if (idx !== -1) {
    console.log('=== RAW XML CONTEXT ===');
    console.log(xml.substring(idx - 250, idx + 250));
    console.log('=======================');
} else {
    console.log('Tag not found in XML!');
}
