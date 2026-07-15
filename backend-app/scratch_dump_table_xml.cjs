const fs = require('fs');
const PizZip = require('pizzip');

const content = fs.readFileSync('samples/BEO TIEC CTY - Chua Thay Doi.docx', 'binary');
const zip = new PizZip(content);
const xml = zip.files['word/document.xml'].asText();

const tag = 'DichVuKhuyenMai';
const tagIdx = xml.indexOf(tag);
if (tagIdx !== -1) {
    const tblStart = xml.lastIndexOf('<w:tbl>', tagIdx);
    const tblEnd = xml.indexOf('</w:tbl>', tagIdx) + '</w:tbl>'.length;
    
    if (tblStart !== -1 && tblEnd !== -1) {
        console.log('=== TABLE XML START ===');
        const tblXml = xml.substring(tblStart, tblEnd);
        console.log(tblXml);
        console.log('=== TABLE XML END ===');
        
        // Scan for any {# or {/ tags inside this table
        console.log('=== LOOP TAGS IN THIS TABLE ===');
        const regex = /\{[#\/][^{}]*?\}/g;
        let match;
        while ((match = regex.exec(tblXml)) !== null) {
            console.log('Found loop tag:', match[0]);
        }
        console.log('===============================');
    } else {
        console.log('Table boundaries not found!');
    }
} else {
    console.log('Tag not found!');
}
