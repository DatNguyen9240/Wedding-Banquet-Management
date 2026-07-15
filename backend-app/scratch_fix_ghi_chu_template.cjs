const fs = require('fs');
const path = require('path');
const PizZip = require('pizzip');

const samplesDir = 'samples';
const files = [
    'BEO TIEC CTY - Chua Thay Doi.docx',
    'BEO TIEC CTY - Thay Doi.docx',
    'BEO_Tiec_Cuoi.docx'
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

    // 1. Tìm và ẩn tạm thời các block loop có chứa {GhiChu}
    const menuRegex = /(<w:p\b[^>]*>(?:(?!<w:p\b).)*?\{#DanhSachMenu\}(?:(?!<w:p\b).)*?<\/w:p>.*?<w:p\b[^>]*>(?:(?!<w:p\b).)*?\{\/DanhSachMenu\}(?:(?!<w:p\b).)*?<\/w:p>)/gs;
    const drinksRegex = /(<w:p\b[^>]*>(?:(?!<w:p\b).)*?\{#DanhSachThucUong\}(?:(?!<w:p\b).)*?<\/w:p>.*?<w:p\b[^>]*>(?:(?!<w:p\b).)*?\{\/DanhSachThucUong\}(?:(?!<w:p\b).)*?<\/w:p>)/gs;

    let menuBlock = null;
    let drinksBlock = null;

    xml = xml.replace(menuRegex, (match) => {
        menuBlock = match;
        return '___MENU_BLOCK_PLACEHOLDER___';
    });

    xml = xml.replace(drinksRegex, (match) => {
        drinksBlock = match;
        return '___DRINKS_BLOCK_PLACEHOLDER___';
    });

    // 2. Thay thế tag {GhiChu} ở ngoài các block (tức là ô Lưu ý) thành {LuuY}
    // GhiChu có thể nằm trong một thẻ <w:t>GhiChu</w:t> hoặc {GhiChu}
    // Chúng ta tìm tag {GhiChu} trong XML để thay thế an toàn
    const ghiChuRegex = /\{GhiChu\}/g;
    if (ghiChuRegex.test(xml)) {
        console.log(`Found parent GhiChu in XML of: ${fileName}`);
        xml = xml.replace(ghiChuRegex, '{LuuY}');
    }

    // 3. Khôi phục lại các block loop
    if (menuBlock) {
        xml = xml.replace('___MENU_BLOCK_PLACEHOLDER___', menuBlock);
    }
    if (drinksBlock) {
        xml = xml.replace('___DRINKS_BLOCK_PLACEHOLDER___', drinksBlock);
    }

    zip.file('word/document.xml', xml);
    const outputBuffer = zip.generate({ type: 'nodebuffer' });
    fs.writeFileSync(templatePath, outputBuffer);
    console.log(`Successfully updated ${fileName}: changed parent {GhiChu} to {LuuY}`);
});
