import fs from 'fs';
import PizZip from 'pizzip';

const srcPath = 'samples/BEO TIEC CTY - Chua Thay Doi.docx';
const destPath = 'samples/BEO TIEC CTY - Thay Doi.docx';

console.log('--- ĐANG TIẾN HÀNH SAO CHÉP & TỰ ĐỘNG TIÊM BIẾN SO SÁNH _CU ---');

if (!fs.existsSync(srcPath)) {
    console.error(`Lỗi: Không tìm thấy file gốc ${srcPath}`);
    process.exit(1);
}

// 1. Sao chép file gốc đè lên file thay đổi
fs.copyFileSync(srcPath, destPath);
console.log(`✅ Đã copy đè: ${srcPath} -> ${destPath}`);

// 2. Đọc file vừa copy để sửa XML chèn các biến _Cu gạch đỏ
const content = fs.readFileSync(destPath);
const zip = new PizZip(content);

// Chuẩn hóa backslash
const fileNames = Object.keys(zip.files);
for (const name of fileNames) {
    if (name.includes('\\')) {
        const n = name.replace(/\\/g, '/');
        zip.files[n] = zip.files[name];
        delete zip.files[name];
    }
}

// Danh sách các trường cần chèn so sánh giá trị cũ gạch đỏ bên cạnh
const targetFields = [
    'SoBanChinhThuc',
    'SoBanDuPhong',
    'BanTang',
    'DonGiaBanTiec',
    'SoKhachTrenBan',
    'QuyMoBanTu',
    'QuyMoBanDen',
    'SoLuongText',
    'DichVuKhuyenMai'
];

let docXml = zip.files['word/document.xml'].asText();

// Làm sạch các tag Word bị phân mảnh trong dấu ngoặc trước
docXml = docXml.replace(/\{[^{}]*?\}/g, (match) => {
    return match.replace(/<[^>]+>/g, "");
});

let modified = false;

for (const field of targetFields) {
    let targetPlaceholder = `{${field}}`;
    let isHtml = false;
    
    if (!docXml.includes(targetPlaceholder) && docXml.includes(`{@${field}}`)) {
        targetPlaceholder = `{@${field}}`;
        isHtml = true;
    }
    
    // Đoạn XML định dạng chữ màu đỏ (color w:val="FF0000") kèm gạch ngang (strike)
    // chứa lệnh của docxtemplater: nếu có giá trị cũ thì in ra dạng ~~GiáTrịCũ~~
    const valTag = isHtml ? `{@${field}_Cu}` : `{${field}_Cu}`;
    const comparisonXml = (field === 'DichVuKhuyenMai')
        ? `<w:r><w:rPr><w:strike w:val="true"/><w:color w:val="FF0000"/></w:rPr><w:t xml:space="preserve"> ${valTag}</w:t></w:r>`
        : `<w:r><w:rPr><w:strike w:val="true"/><w:color w:val="FF0000"/></w:rPr><w:t xml:space="preserve"> {#${field}_Cu}~~${valTag}~~{/${field}_Cu}</w:t></w:r>`;
    
    if (docXml.includes(targetPlaceholder)) {
        console.log(`Tiêm biến so sánh cho: ${targetPlaceholder}`);
        
        // Vì targetPlaceholder đang nằm trong một thẻ text, ta phải đóng thẻ text hiện tại, 
        // chèn run đỏ-gạch-ngang mới, rồi mở lại thẻ text tiếp theo
        const replacement = `</w:t></w:r>${comparisonXml}<w:r><w:t xml:space="preserve">`;
        
        docXml = docXml.split(targetPlaceholder).join(targetPlaceholder + replacement);
        modified = true;
    }
}

if (modified) {
    zip.file('word/document.xml', docXml);
    const buffer = zip.generate({ type: 'nodebuffer' });
    fs.writeFileSync(destPath, buffer);
    console.log(`✅ Đã lưu vết và tiêm so sánh thành công vào: ${destPath}`);
} else {
    console.log('ℹ️ Không tìm thấy các trường phù hợp để tiêm.');
}

console.log('--- HOÀN TẤT ---');
