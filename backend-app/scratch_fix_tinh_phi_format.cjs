const fs = require('fs');
const path = require('path');
const PizZip = require('pizzip');

const samplesDir = 'samples';
const files = [
    'BEO TIEC CTY - Chua Thay Doi.docx',
    'BEO TIEC CTY - Thay Doi.docx'
];

files.forEach(fileName => {
    const templatePath = path.join(samplesDir, fileName);
    if (!fs.existsSync(templatePath)) {
        console.warn(`File does not exist: ${templatePath}`);
        return;
    }

    const content = fs.readFileSync(templatePath, 'binary');
    const zip = new PizZip(content);
    let xml = zip.files['word/document.xml'].asText();

    // Regex to find:
    // Group 1: The paragraph containing {#DichVuTinhPhi}
    // Group 2: The paragraph containing the format text (which can have runs with TenDichVu, SoLuongText, etc.)
    // Group 3: The paragraph containing {/DichVuTinhPhi}
    const regex = /(<w:p\b[^>]*>(?:(?!<w:p\b).)*?\{#DichVuTinhPhi\}(?:(?!<w:p\b).)*?<\/w:p>)(\s*<w:p\b[^>]*>.*?<\/w:p>)(\s*<w:p\b[^>]*>(?:(?!<w:p\b).)*?\{\/DichVuTinhPhi\}(?:(?!<w:p\b).)*?<\/w:p>)/gs;

    const match = regex.exec(xml);
    if (match) {
        console.log(`Found DichVuTinhPhi paragraph loop in XML of: ${fileName}`);
        
        // Replace the format paragraph with {DichVuText}
        const cleanParagraph = `<w:p><w:pPr><w:spacing w:before="15"/><w:rPr><w:sz w:val="20"/><w:lang w:val="en-US"/></w:rPr></w:pPr><w:r><w:rPr><w:sz w:val="20"/><w:lang w:val="en-US"/></w:rPr><w:t>{DichVuText}</w:t></w:r></w:p>`;
        
        xml = xml.replace(regex, `$1${cleanParagraph}$3`);
        zip.file('word/document.xml', xml);
        
        const outputBuffer = zip.generate({ type: 'nodebuffer' });
        fs.writeFileSync(templatePath, outputBuffer);
        console.log(`Successfully updated ${fileName} with {DichVuText}!`);
    } else {
        console.log(`Could not match DichVuTinhPhi paragraph loop in XML of: ${fileName}`);
    }
});
