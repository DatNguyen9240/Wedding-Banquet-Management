import fs from 'fs';
import PizZip from 'pizzip';

const files = [
    'd:/LamViec/Wedding-Banquet-Management/backend-app/samples/BEO TIEC CTY - Chua Thay Doi.docx',
    'd:/LamViec/Wedding-Banquet-Management/backend-app/samples/BEO TIEC CTY - Thay Doi.docx',
    'd:/LamViec/Wedding-Banquet-Management/backend-app/samples/BEO_Tiec_Cuoi.docx',
];

for (const docxPath of files) {
    if (!fs.existsSync(docxPath)) { console.log(`SKIP (not found): ${docxPath}`); continue; }
    const content = fs.readFileSync(docxPath);
    const zip = new PizZip(content);
    const fileNames = Object.keys(zip.files);
    for (const name of fileNames) {
        if (name.includes('\\')) {
            const n = name.replace(/\\/g, '/');
            zip.files[n] = zip.files[name];
            if (zip.files[n]) zip.files[n].name = n;
            delete zip.files[name];
        }
    }
    let allPlaceholders = [];
    for (const name of fileNames) {
        if (name.startsWith('word/') && name.endsWith('.xml')) {
            const xml = zip.files[name].asText();
            const cleanText = xml.replace(/<[^>]+>/g, '');
            const raw = [...cleanText.matchAll(/\{([^{}]+)\}/g)].map(m => m[0].trim());
            allPlaceholders.push(...raw);
        }
    }
    const unique = [...new Set(allPlaceholders)].sort();
    console.log(`\n=== ${docxPath.split('/').pop()} ===`);
    console.log(unique.join('\n'));

    // Bổ sung: In đoạn text XML xung quanh {#DichVuTinhPhi} và {#LichTrinhThanhToan} để check tên cột trong bảng
    if (docxPath.endsWith('BEO_Tiec_Cuoi.docx')) {
        console.log('\n--- BẢNG CHI TIẾT LOOP TRONG BEO_Tiec_Cuoi.docx ---');
        const docXml = zip.files['word/document.xml'].asText();
        const cleanDocXml = docXml.replace(/<[^>]+>/g, ' ');
        const matches = cleanDocXml.match(/\{#[A-Za-z0-9_]+\}.*?\{\/[A-Za-z0-9_]+\}/g);
        if (matches) {
            matches.forEach(m => console.log('BLOCK:', m.replace(/\s+/g, ' ')));
        }
    }
}
