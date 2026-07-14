import fs from 'fs';
import PizZip from 'pizzip';

const docxPath = 'd:/LamViec/Wedding-Banquet-Management/backend-app/samples/BEO TIEC CTY - Chua Thay Doi.docx';
const content = fs.readFileSync(docxPath);
const zip = new PizZip(content);

// Normalise backslash
const fileNames = Object.keys(zip.files);
for (const name of fileNames) {
    if (name.includes('\\')) {
        const n = name.replace(/\\/g, '/');
        zip.files[n] = zip.files[name];
        delete zip.files[name];
    }
}

const xml = zip.files['word/document.xml'].asText();

// Hàm tìm kiếm thông minh: Tìm text trơn và trả về đoạn XML tương ứng
function findXmlAroundText(targetText, xmlString) {
    // Tạo danh sách ánh xạ index giữa plain text và xml
    let plainText = '';
    const indexMapping = []; // indexMapping[plainIndex] = xmlIndex
    
    let inTag = false;
    for (let i = 0; i < xmlString.length; i++) {
        if (xmlString[i] === '<') {
            inTag = true;
            continue;
        }
        if (xmlString[i] === '>') {
            inTag = false;
            continue;
        }
        if (!inTag) {
            plainText += xmlString[i];
            indexMapping.push(i);
        }
    }
    
    const plainIndex = plainText.toLowerCase().indexOf(targetText.toLowerCase());
    if (plainIndex === -1) {
        console.log(`Không tìm thấy text trơn: "${targetText}"`);
        return;
    }
    
    const startXmlIndex = indexMapping[plainIndex];
    const endXmlIndex = indexMapping[plainIndex + targetText.length - 1];
    
    console.log(`Tìm thấy "${targetText}" ở plain index ${plainIndex}.`);
    console.log('--- ĐOẠN XML XUNG QUANH ---');
    console.log(xmlString.substring(Math.max(0, startXmlIndex - 300), Math.min(xmlString.length, endXmlIndex + 300)));
}

findXmlAroundText('Rong Nho', xml);
