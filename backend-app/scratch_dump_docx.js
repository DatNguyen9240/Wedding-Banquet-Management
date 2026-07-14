import fs from 'fs';
import PizZip from 'pizzip';

const files = [
    { src: 'd:/LamViec/Wedding-Banquet-Management/backend-app/samples/BEO TIEC CTY - Chua Thay Doi.docx', dest: 'd:/LamViec/Wedding-Banquet-Management/backend-app/BEO_Tiec_Cty_ChuaThayDoi.md' },
    { src: 'd:/LamViec/Wedding-Banquet-Management/backend-app/samples/BEO TIEC CTY - Thay Doi.docx', dest: 'd:/LamViec/Wedding-Banquet-Management/backend-app/BEO_Tiec_Cty_ThayDoi.md' },
    { src: 'd:/LamViec/Wedding-Banquet-Management/backend-app/samples/BEO_Tiec_Cuoi.docx', dest: 'd:/LamViec/Wedding-Banquet-Management/backend-app/BEO_Tiec_Cuoi.md' }
];

for (const f of files) {
    if (!fs.existsSync(f.src)) {
        console.log(`SKIP (not found): ${f.src}`);
        continue;
    }
    const content = fs.readFileSync(f.src);
    const zip = new PizZip(content);
    
    // Sửa lỗi đường dẫn backslash trong zip của một số môi trường Windows
    const fileNames = Object.keys(zip.files);
    for (const name of fileNames) {
        if (name.includes('\\')) {
            const n = name.replace(/\\/g, '/');
            zip.files[n] = zip.files[name];
            if (zip.files[n]) zip.files[n].name = n;
            delete zip.files[name];
        }
    }
    
    const xml = zip.files['word/document.xml'].asText();

    // Parser regex đơn giản chuyển đổi XML của Word thành văn bản Markdown dễ đọc
    let text = xml;
    text = text.replace(/<w:tc[ >]/g, ' | ');      // Thêm cột bảng
    text = text.replace(/<\/w:tr>/g, '\n');        // Thống nhất dòng bảng
    text = text.replace(/<\/w:p>/g, '\n\n');       // Ngắt đoạn paragraph
    text = text.replace(/<[^>]+>/g, '');           // Bỏ sạch tag XML
    
    // Chuẩn hóa khoảng trắng và dòng trống dư thừa
    text = text.replace(/^[ \t]+/gm, '');          // Bỏ khoảng trắng đầu dòng
    text = text.replace(/ \+ /g, ' + ');           // Làm đẹp dấu cộng
    text = text.replace(/\n{3,}/g, '\n\n');        // Giới hạn tối đa 2 dòng trống liên tiếp
    
    fs.writeFileSync(f.dest, `# Nội dung của ${f.src.split('/').pop()}\n\n` + text.trim());
    console.log(`Đã xuất văn bản: ${f.dest}`);
}
