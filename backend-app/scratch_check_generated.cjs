const fs = require('fs');
const path = require('path');
const PizZip = require('pizzip');

// Check the template in relative samples/
const templatePath = 'samples/BEO TIEC CTY - Chua Thay Doi.docx';
if (fs.existsSync(templatePath)) {
    console.log('Template exists at:', templatePath);
    const content = fs.readFileSync(templatePath, 'binary');
    const zip = new PizZip(content);
    const xml = zip.files['word/document.xml'].asText();
    
    console.log('=== TEMPLATE CHECK ===');
    const regex = /\{[^{}]*?Khuyen[^{}]*?\}/gi;
    let match;
    while ((match = regex.exec(xml)) !== null) {
        console.log('Found tag in template:', match[0]);
    }
} else {
    console.log('Template does not exist at:', templatePath);
}

// Check the generated files in relative uploads/
const uploadsDir = 'uploads';
if (fs.existsSync(uploadsDir)) {
    const files = fs.readdirSync(uploadsDir);
    const targetFile = files
        .filter(f => f.toLowerCase().includes('hd260629115628'))
        .sort((a, b) => fs.statSync(path.join(uploadsDir, b)).mtimeMs - fs.statSync(path.join(uploadsDir, a)).mtimeMs)[0];

    if (targetFile) {
        const filePath = path.join(uploadsDir, targetFile);
        console.log('Checking generated file:', filePath);

        const content = fs.readFileSync(filePath, 'binary');
        const zip = new PizZip(content);
        const xml = zip.files['word/document.xml'].asText();

        console.log('=== GENERATED FILE CHECK ===');
        console.log('Does XML contain "75 - 84 bàn"?', xml.includes('75 - 84 bàn'));
        console.log('Does XML contain "Mốc 65 Bàn"?', xml.includes('Mốc 65 Bàn'));
        console.log('Does XML contain "DichVuKhuyenMai"?', xml.includes('DichVuKhuyenMai'));

        const labelIdx = xml.indexOf('DỊCH VỤ ƯU ĐÃI');
        if (labelIdx !== -1) {
            console.log('Context around "DỊCH VỤ ƯU ĐÃI":', xml.substring(labelIdx - 200, labelIdx + 500));
        }
    } else {
        console.log('No generated file found in uploads matching contract!');
    }
} else {
    console.log('Uploads directory does not exist at uploads');
}
