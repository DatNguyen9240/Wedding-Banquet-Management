import fs from 'fs';
import PizZip from 'pizzip';

const files = [
    'd:/LamViec/Wedding-Banquet-Management/backend-app/samples/BEO TIEC CTY - Chua Thay Doi.docx',
    'd:/LamViec/Wedding-Banquet-Management/backend-app/samples/BEO TIEC CTY - Thay Doi.docx',
    'd:/LamViec/Wedding-Banquet-Management/backend-app/samples/BEO_Tiec_Cuoi.docx',
];

// Bản đồ ánh xạ thay thế (Từ placeholder cũ -> placeholder mới)
const replacements = {
    'BenBDienChi': 'BenBDiaChi',
    'BenBDiaChiTemplate': 'BenBDiaChi',
    'GhiChuMenu': 'GhiChu',
    'GhiChuThucUong': 'GhiChu',
    'GhiChuChiTiet': 'GhiChu',
    'LuuY': 'GhiChu',
    'BieuNguCR': 'Tenchure',
    'BieuNguCD': 'Tencodau',
    'SanhDat': 'Sanh'
};

console.log('--- ĐANG TỰ ĐỘNG SỬA PLACEHOLDER TRONG CÁC FILE WORD (.DOCX) ---');

for (const docxPath of files) {
    if (!fs.existsSync(docxPath)) {
        console.log(`SKIP (Không tìm thấy): ${docxPath}`);
        continue;
    }
    
    const content = fs.readFileSync(docxPath);
    const zip = new PizZip(content);
    
    // Sửa lỗi backslash trong zip
    const fileNames = Object.keys(zip.files);
    for (const name of fileNames) {
        if (name.includes('\\')) {
            const n = name.replace(/\\/g, '/');
            zip.files[n] = zip.files[name];
            if (zip.files[n]) zip.files[n].name = n;
            delete zip.files[name];
        }
    }
    
    let modifiedAny = false;

    // Quét qua toàn bộ các file XML (document, headers, footers...)
    for (const name of Object.keys(zip.files)) {
        if (name.startsWith('word/') && name.endsWith('.xml')) {
            let xml = zip.files[name].asText();
            let isDocXmlModified = false;

            // Tìm tất cả các đoạn {...} bao gồm cả các tag XML định dạng xen kẽ
            // Dùng thuật toán duyệt ký tự để tránh lỗi regex khi thẻ quá phức tạp
            let newXml = '';
            let i = 0;
            while (i < xml.length) {
                if (xml[i] === '{') {
                    // Tìm dấu đóng ngoặc }
                    let j = i + 1;
                    let bracketDepth = 1;
                    let buffer = '{';
                    while (j < xml.length && bracketDepth > 0) {
                        buffer += xml[j];
                        if (xml[j] === '{') bracketDepth++;
                        if (xml[j] === '}') bracketDepth--;
                        j++;
                    }
                    
                    if (bracketDepth === 0) {
                        // Tìm thấy block {...}
                        // Lọc bỏ XML tags để lấy chuỗi chữ thuần bên trong
                        const cleanPlaceholder = buffer.replace(/<[^>]+>/g, '').slice(1, -1).trim();
                        
                        // Xem cleanPlaceholder có thuộc danh sách cần thay thế không
                        // Hỗ trợ cả khi placeholder có prefix # hoặc / hoặc @
                        let prefix = '';
                        let cleanName = cleanPlaceholder;
                        if (['#', '/', '@'].includes(cleanPlaceholder[0])) {
                            prefix = cleanPlaceholder[0];
                            cleanName = cleanPlaceholder.slice(1);
                        }

                        if (replacements[cleanName]) {
                            const newPlaceholder = `{${prefix}${replacements[cleanName]}}`;
                            console.log(`[${docxPath.split('/').pop()}] Thay thế: ${buffer.replace(/<[^>]+>/g, '')} -> ${newPlaceholder}`);
                            newXml += newPlaceholder;
                            isDocXmlModified = true;
                        } else {
                            newXml += buffer;
                        }
                    } else {
                        newXml += buffer;
                    }
                    i = j;
                } else {
                    newXml += xml[i];
                    i++;
                }
            }

            if (isDocXmlModified) {
                zip.file(name, newXml);
                modifiedAny = true;
            }
        }
    }
    
    if (modifiedAny) {
        // Ghi đè lại file docx
        const buffer = zip.generate({ type: 'nodebuffer' });
        fs.writeFileSync(docxPath, buffer);
        console.log(`✅ Đã cập nhật thành công: ${docxPath}`);
    } else {
        console.log(`ℹ️ Không có placeholder nào cần sửa trong: ${docxPath}`);
    }
}

console.log('--- HOÀN TẤT ---');
