import express from 'express';
import cors from 'cors';
import axios from 'axios';
import fs from 'fs';
import path from 'path';
import PizZip from 'pizzip';
import Docxtemplater from 'docxtemplater';
import { fileURLToPath } from 'url';

// Thiết lập __dirname cho ES Modules
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();
const PORT = process.env.PORT || 5000;

// ==========================================
// THIẾT LẬP THƯ MỤC
// ==========================================
const UPLOADS_DIR = path.join(__dirname, 'uploads');
const SAMPLES_DIR = path.join(__dirname, 'samples');

// Tự động tạo thư mục nếu chưa tồn tại
[UPLOADS_DIR, SAMPLES_DIR].forEach(dir => {
    if (!fs.existsSync(dir)) {
        fs.mkdirSync(dir, { recursive: true });
    }
});

// ==========================================
// MIDDLEWARE
// ==========================================
app.use(cors());

// Phân tích JSON body
app.use(express.json());

// Bắt lỗi khi parse JSON (Rất quan trọng cho ONLYOFFICE Callback)
// Nếu ONLYOFFICE gửi payload hỏng, ta vẫn phải trả về {error: 0} để ngắt vòng lặp retry của nó
app.use((err, req, res, next) => {
    if (err instanceof SyntaxError && err.status === 400 && 'body' in err) {
        console.error('[EXPRESS] Lỗi parse JSON payload!');
        // Trả về error: 0 để ONLYOFFICE dừng gửi lại
        return res.json({ error: 0, message: 'Invalid JSON payload' });
    }
    next();
});

// Phục vụ file tĩnh để ONLYOFFICE có thể tải về Word Editor
app.use('/uploads', express.static(UPLOADS_DIR));

// ==========================================
// API: QUẢN LÝ TÀI LIỆU
// ==========================================

/**
 * 1. Lấy danh sách tài liệu
 */
app.get('/api/documents', (req, res) => {
    try {
        const files = fs.readdirSync(UPLOADS_DIR);
        const fileList = files
            .filter(file => file.endsWith('.docx') || file.endsWith('.xlsx'))
            .map(file => {
                const stats = fs.statSync(path.join(UPLOADS_DIR, file));
                return {
                    fileName: file,
                    size: (stats.size / 1024).toFixed(2) + ' KB',
                    createdAt: stats.birthtime,
                    updatedAt: stats.mtime
                };
            });

        res.json({ success: true, data: fileList });
    } catch (error) {
        console.error('[API] Lỗi lấy danh sách:', error.message);
        res.status(500).json({ success: false, message: 'Lỗi server khi lấy danh sách file.' });
    }
});

/**
 * 2. Tạo tài liệu mới (Tạo từ mẫu chuẩn chỉnh)
 */
app.post('/api/documents/create', async (req, res) => {
    try {
        let { fileName, templateType } = req.body;
        if (!fileName) {
            return res.status(400).json({ success: false, message: "Vui lòng cung cấp tên file (fileName)." });
        }
        if (!templateType) {
            return res.status(400).json({ success: false, message: "Vui lòng chọn loại form (templateType) để tạo tài liệu." });
        }

        if (!fileName.endsWith('.docx')) fileName += '.docx';

        const targetPath = path.join(UPLOADS_DIR, fileName);

        if (fs.existsSync(targetPath)) {
            return res.status(400).json({ success: false, message: "Tên file đã tồn tại trong hệ thống!" });
        }

        // Chọn file mẫu tương ứng với templateType
        const localSamplePath = path.join(SAMPLES_DIR, `${templateType}.docx`);

        if (fs.existsSync(localSamplePath)) {
            // Copy từ file mẫu chuẩn ở local
            fs.copyFileSync(localSamplePath, targetPath);
            return res.json({ success: true, message: `Tạo tài liệu thành công từ mẫu ${templateType}!`, fileName });
        } else {
            // Fallback: Nếu không có file mẫu ở server, tải một file mẫu từ internet để làm base
            const sampleUrl = "https://raw.githubusercontent.com/open-xml-templating/docxtemplater/master/examples/tag-example.docx";

            const response = await axios({
                method: 'GET',
                url: sampleUrl,
                responseType: 'stream'
            });

            const writer = fs.createWriteStream(targetPath);
            response.data.pipe(writer);

            await new Promise((resolve, reject) => {
                writer.on('finish', resolve);
                writer.on('error', reject);
            });

            // Lưu lại một bản sao vào SAMPLES_DIR để dùng cho các lần sau, không cần tải lại internet
            fs.copyFileSync(targetPath, localSamplePath);

            return res.json({ success: true, message: "Tạo tài liệu thành công (tải từ internet & lưu mẫu)!", fileName });
        }
    } catch (error) {
        console.error('[API] Lỗi tạo file:', error.message);
        res.status(500).json({ success: false, message: 'Lỗi server khi tạo file.' });
    }
});

/**
 * 2b. TẠO & ĐIỀN DATA VÀO TÀI LIỆU (DATA-BINDING)
 */
app.post('/api/documents/generate', async (req, res) => {
    try {
        let { outputFileName, templateType, customerId } = req.body;
        if (!templateType) return res.status(400).json({ success: false, message: "Thiếu templateType." });
        if (!outputFileName) outputFileName = `Generated_${templateType}`;

        // 1. Lấy dữ liệu khách hàng (Mô phỏng gọi API/Database bằng customerId)
        const mockDatabase = {
            'hop_dong': { last_name: 'Nguyễn', first_name: 'Văn Khách', phone: '0901234567', table_count: 50, menu_type: 'VIP Hoàng Gia', total_price: '50,000,000' },
            'dat_coc': { last_name: 'Trần', first_name: 'Thị Cô Dâu', date: '28/05/2026', deposit_amount: '10,000,000', deposit_amount_words: 'Mười triệu đồng chẵn' },
            'quyet_toan': { last_name: 'Lê', first_name: 'Văn Chú Rể', date: '30/05/2026', total_amount: '60,000,000', paid_amount: '10,000,000', remaining_amount: '50,000,000' }
        };
        const dataToFill = mockDatabase[templateType] || mockDatabase['hop_dong'];

        // 2. Đọc file mẫu tương ứng
        const templatePath = path.join(SAMPLES_DIR, `${templateType}.docx`);
        if (!fs.existsSync(templatePath)) {
            return res.status(404).json({ success: false, message: 'Không tìm thấy file mẫu trong thư mục samples/' });
        }

        const content = fs.readFileSync(templatePath, 'binary');

        // 3. Khởi tạo engine thay thế (Data-Binding)
        const zip = new PizZip(content);
        const doc = new Docxtemplater(zip, { paragraphLoop: true, linebreaks: true });

        // Tiến hành ghi đè dữ liệu vào các biến {last_name}, {phone}...
        doc.render(dataToFill);

        // 4. Lưu ra thành 1 file .docx hoàn chỉnh mới
        const buf = doc.getZip().generate({ type: 'nodebuffer', compression: 'DEFLATE' });
        const finalFileName = `${outputFileName}_${Date.now()}.docx`;
        const outputPath = path.join(UPLOADS_DIR, finalFileName);
        
        fs.writeFileSync(outputPath, buf);

        // Trả về tên file để Frontend có thể gọi openEditor() hiển thị lên OnlyOffice
        return res.json({ success: true, message: "Đã đổ dữ liệu thành công!", fileName: finalFileName });

    } catch (error) {
        console.error('[API] Lỗi generate file:', error);
        res.status(500).json({ success: false, message: 'Lỗi server khi render file Word.' });
    }
});

/**
 * 3. Xóa tài liệu
 */
app.delete('/api/documents/:fileName', (req, res) => {
    try {
        const fileName = req.params.fileName;
        const filePath = path.join(UPLOADS_DIR, fileName);

        if (fs.existsSync(filePath)) {
            fs.unlinkSync(filePath);
            res.json({ success: true, message: "Xóa thành công!" });
        } else {
            res.status(404).json({ success: false, message: "Không tìm thấy file để xóa!" });
        }
    } catch (error) {
        console.error('[API] Lỗi xóa file:', error.message);
        res.status(500).json({ success: false, message: 'Lỗi server khi xóa file.' });
    }
});

// ==========================================
// API: ONLYOFFICE CALLBACK
// ==========================================
/**
 * Chuẩn chỉnh xử lý Callback từ OnlyOffice Document Server.
 * LUÔN LUÔN phải trả về {"error": 0} cuối cùng để Document Server biết ta đã xử lý.
 */
app.post('/api/documents/callback', async (req, res) => {
    // Hàm phản hồi tiêu chuẩn cho OnlyOffice
    const respondSuccess = () => res.json({ error: 0 });

    try {
        const data = req.body;
        const docId = req.query.docId || 'unknown';
        const fileName = req.query.fileName || `${docId}.docx`;
        const status = data.status;

        console.log(`[ONLYOFFICE] Nhận Callback - DocID: ${docId}, Tên file: ${fileName}, Trạng thái: ${status}`);

        /* 
           Ý nghĩa các Status (theo chuẩn ONLYOFFICE):
           1 - Đang chỉnh sửa (Document is being edited)
           2 - Đã đóng & Sẵn sàng lưu (Document is ready for saving)
           3 - Lỗi khi lưu (Document saving error)
           4 - Đóng không có thay đổi (Document is closed with no changes)
           6 - Forcesave (Document is being edited, but the current state is saved)
           7 - Lỗi Forcesave (Error has occurred while force saving)
        */

        if (status === 2 || status === 6) {
            const downloadUri = data.url;

            if (!downloadUri) {
                console.warn('[ONLYOFFICE] CẢNH BÁO: Không tìm thấy URL tải file trong callback!');
                return respondSuccess();
            }

            console.log(`[ONLYOFFICE] Đang tải & lưu file bản ghi mới nhất... (${status === 2 ? 'Save' : 'Forcesave'})`);

            const filePath = path.join(UPLOADS_DIR, fileName);

            // Sử dụng stream tải file an toàn & tối ưu bộ nhớ
            const response = await axios({
                method: 'GET',
                url: downloadUri,
                responseType: 'stream'
            });

            const writer = fs.createWriteStream(filePath);
            response.data.pipe(writer);

            await new Promise((resolve, reject) => {
                writer.on('finish', resolve);
                writer.on('error', reject);
            });

            console.log(`[ONLYOFFICE] ✅ Đã lưu file thành công: ${fileName}`);
        }

        // Báo cho OnlyOffice biết server đã xử lý callback
        return respondSuccess();

    } catch (error) {
        console.error('[ONLYOFFICE] ❌ Lỗi nghiêm trọng khi xử lý Callback:', error.message);
        // Ngay cả khi xảy ra lỗi code server, vẫn trả về {error: 0} để ngắt vòng lặp gửi liên tục từ OnlyOffice
        return respondSuccess();
    }
});

// ==========================================
// ROOT ENDPOINT
// ==========================================
app.get('/', (req, res) => {
    res.json({
        service: 'Wedding Banquet Document API',
        status: '✅ Running smoothly',
        endpoints: {
            list: 'GET /api/documents',
            create: 'POST /api/documents/create',
            delete: 'DELETE /api/documents/:fileName',
            callback: 'POST /api/documents/callback'
        }
    });
});

// ==========================================
// KHỞI ĐỘNG SERVER
// ==========================================
app.listen(PORT, '0.0.0.0', () => {
    console.log('=======================================================');
    console.log('       ✨ BACKEND SERVER - WEDDING BANQUET MANGEMENT    ');
    console.log('=======================================================');
    console.log(`[🚀] Server đang chạy tại : http://localhost:${PORT}`);
    console.log(`[📁] Thư mục lưu tài liệu : ${UPLOADS_DIR}`);
    console.log(`[📁] Thư mục lưu mẫu (tpl): ${SAMPLES_DIR}`);
    console.log(`[🔗] ONLYOFFICE Callback  : http://localhost:${PORT}/api/documents/callback`);
    console.log('=======================================================');
});
