import express from 'express';
import cors from 'cors';
import axios from 'axios';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import PizZip from 'pizzip';
import Docxtemplater from 'docxtemplater';
import crypto from 'crypto';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();
const PORT = process.env.PORT || 8081;

// ==========================================
// THIẾT LẬP THƯ MỤC
// ==========================================
const UPLOADS_DIR = path.join(__dirname, 'uploads');
const SAMPLES_DIR = path.join(__dirname, 'samples');

[UPLOADS_DIR, SAMPLES_DIR].forEach(dir => {
    if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
});

// ==========================================
// MIDDLEWARE
// ==========================================
app.use(cors({ origin: '*' }));

app.use('/uploads', function (req, res, next) {
    res.header('Access-Control-Allow-Origin', '*');
    res.header('Access-Control-Allow-Headers', '*');
    next();
}, express.static(UPLOADS_DIR));

app.use('/samples', function (req, res, next) {
    res.header('Access-Control-Allow-Origin', '*');
    res.header('Access-Control-Allow-Headers', '*');
    next();
}, express.static(SAMPLES_DIR));

app.use(express.json());

app.use((err, req, res, next) => {
    if (err instanceof SyntaxError && err.status === 400 && 'body' in err) {
        console.error('[EXPRESS] Lỗi parse JSON payload!');
        return res.json({ error: 0, message: 'Invalid JSON payload' });
    }
    next();
});

// ==========================================
// API GATEWAY CHÍNH (SQL Server)
// ==========================================
const SQL_API_BASE = 'https://qlt.bms79.com';
const SQL_API_USER = 'admin';

// Cache thông tin nhà hàng (tránh gọi API nhiều lần)
let _setupCache = null;
let _setupCacheTime = 0;
const SETUP_CACHE_TTL = 5 * 60 * 1000; // 5 phút

/** Lấy thông tin nhà hàng từ API_LayGiaTriSetup (có cache) */
async function fetchSetupInfo(authToken) {
    const now = Date.now();
    if (_setupCache && (now - _setupCacheTime) < SETUP_CACHE_TTL) return _setupCache;
    try {
        const url = `${SQL_API_BASE}/api/API_LayGiaTriSetup`;
        const headers = {};
        if (authToken) headers['Authorization'] = authToken;
        const resp = await axios.get(url, { headers, timeout: 8000 });
        const json = resp.data;
        // API_LayGiaTriSetup trả về rows có CodeID + CodeValue (xem SQL)
        const rows = json.records || (Array.isArray(json) ? json : []);
        const setup = {};
        rows.forEach(r => {
            // Field name thực tế theo SQL: CodeID, CodeValue
            const key = r.CodeID || r.codeID || r.codeid || r.MaSetup;
            const val = r.CodeValue || r.codeValue || r.GiaTri || r.Value || '';
            if (key) setup[key] = val;
        });
        _setupCache = setup;
        _setupCacheTime = now;
        console.log('[SETUP] Keys:', Object.keys(setup).join(', '), '| Raw setup:', JSON.stringify(setup));
        return setup;
    } catch (err) {
        console.error('[SETUP] Lỗi gọi API_LayGiaTriSetup:', err.message);
        return _setupCache || {};
    }
}

/** Gọi API Gateway để lấy record theo List + Keyword */
async function fetchFromSQLAPI(listName, keyword, authToken) {
    const payload = {
        List: listName, Func: 'View', UserName: SQL_API_USER,
        Keyword: keyword || '', Page: 1, Limit: 1
    };
    const qs = encodeURIComponent(JSON.stringify(payload));
    const url = `${SQL_API_BASE}/api/API_Gateway_Router?q=${qs}`;
    console.log(`[SQL API] Gọi: ${listName} | Keyword: ${keyword}`);
    const headers = {};
    if (authToken) headers['Authorization'] = authToken;
    const resp = await axios.get(url, { headers, timeout: 10000 });
    const json = resp.data;
    if (json && json.records && json.records.length > 0) return json.records[0];
    if (json && json.code === 0) return json;
    return null;
}

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
            .filter(file => file.endsWith('.docx') || file.endsWith('.xlsx') || file.endsWith('.doc'))
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
 * 1.5 Lấy danh sách các biến dữ liệu cho một loại mẫu
 */
app.get('/api/documents/fields/:type', async (req, res) => {
    try {
        const type = req.params.type;
        const API_MAP = {
            'hop_dong': 'frmHopDong',
            'phieu_thu': 'frmPhieuThu',
            'de_nghi_thay_doi': 'tbmk_Thaydoi',
            'quyet_toan': 'frmQuyetToan',
            'BEO_Hoi_Nghi': 'frmHopDong',
            'BEO_Tiec_Cuoi': 'frmHopDong',
        };
        const listName = API_MAP[type];
        if (!listName) return res.status(400).json({ success: false, message: 'Invalid type' });

        // Lấy 1 dòng dữ liệu mẫu từ SQL API để quét tự động 100% cột
        let sampleRow = {};
        try {
            const sqlRow = await fetchFromSQLAPI(listName, '', req.headers.authorization);
            if (sqlRow) sampleRow = sqlRow;
        } catch (e) {
            console.log('[FIELDS] Không lấy được data mẫu từ DB, dùng object rỗng');
        }

        const setup = await fetchSetupInfo(req.headers.authorization).catch(() => ({}));
        const finalData = { ...setup, ...sampleRow };
        const fields = Object.keys(finalData);

        const formattedFields = fields.map(f => `{${f}}`);
        res.json({ success: true, fields: formattedFields });
    } catch (error) {
        console.error('[API] Lỗi lấy danh sách biến:', error);
        res.status(500).json({ success: false, message: 'Lỗi server: ' + error.message });
    }
});

app.post('/api/documents/generate', async (req, res) => {
    try {
        let { outputFileName, templateType, customerId, rowData, convertFields, sqlListName, mergeColumns } = req.body;
        if (!templateType) return res.status(400).json({ success: false, message: 'Thiếu templateType.' });
        if (!outputFileName) outputFileName = 'Generated_' + templateType;
        outputFileName = outputFileName.replace(/[\/\\:*?"<>|]/g, '_').replace(/\s+/g, '_');
        
        // ── 1. Lấy thông tin nhà hàng từ Setup API ──────────────────────────
        const setup = await fetchSetupInfo(req.headers.authorization).catch(() => ({}));

        // ── 2. Map data từ rowData (frontend) hoặc fallback SQL API ─────────
        const API_MAP = {
            'hop_dong': 'frmHopDong',
            'phieu_thu': 'frmPhieuThu',
            'de_nghi_thay_doi': 'tbmk_Thaydoi',
            'quyet_toan': 'frmQuyetToan',
            'BEO_Hoi_Nghi': 'frmHopDong',
            'BEO_Tiec_Cuoi': 'frmHopDong',
        };
        const listName = sqlListName || API_MAP[templateType];
        let dataMap = { ...setup };

        let dbRow = null;
        if (listName && customerId) {
            try {
                dbRow = await fetchFromSQLAPI(listName, customerId, req.headers.authorization);
                console.log('[GENERATE] ✅ Lấy dữ liệu chi tiết từ SQL API thành công');
            } catch (e) {
                console.error('[GENERATE] Lỗi SQL API:', e.message);
            }
        }

        // Merge dữ liệu: setup -> rowData từ frontend -> dbRow từ SQL API (ưu tiên cao nhất)
        if (rowData && typeof rowData === 'object') {
            dataMap = { ...dataMap, ...rowData };
        }
        if (dbRow) {
            dataMap = { ...dataMap, ...dbRow };
        }

        // Tự động phân tích các chuỗi JSON từ CSDL thành mảng/đối tượng JS
        for (const key in dataMap) {
            if (typeof dataMap[key] === 'string') {
                const val = dataMap[key].trim();
                if ((val.startsWith('[') && val.endsWith(']')) || (val.startsWith('{') && val.endsWith('}'))) {
                    try {
                        dataMap[key] = JSON.parse(val);
                    } catch (e) {
                        // ignore
                    }
                }
            }
        }

        if (!dataMap.DanhSachMenu) {
            dataMap.DanhSachMenu = [];
        }

        if (dataMap.DanhSachMenu && Array.isArray(dataMap.DanhSachMenu)) {
            dataMap.DanhSachMenu = dataMap.DanhSachMenu.map(menu => {
                let list = menu.DanhSachMon || menu.DanhSachMonAn || menu.DanhSachMón || [];
                if (typeof list === 'string') {
                    list = list.split(/\r?\n/).map(l => l.trim()).filter(Boolean).map((line, idx) => {
                        const cleanLine = line.replace(/^\d+[\s.\-:]+/, '');
                        return { STT: idx + 1, TenMon: cleanLine };
                    });
                }
                return {
                    TenMenu: menu.TenMenu || menu.TenMenuAn || 'Thực đơn',
                    GhiChuMenu: menu.GhiChuMenu || menu.GhiChu || menu.NoteMenu || '',
                    DanhSachMon: Array.isArray(list) ? list.map((item, idx) => ({
                        STT: item.STT || (idx + 1),
                        TenMon: item.TenMon || item.TenMonAn || item.TenMonAnChinh || (typeof item === 'string' ? item : '')
                    })) : []
                };
            });
        }

        if (!dataMap.DanhSachThucUong) {
            dataMap.DanhSachThucUong = [];
        }

        if (dataMap.DanhSachThucUong && Array.isArray(dataMap.DanhSachThucUong)) {
            dataMap.DanhSachThucUong = dataMap.DanhSachThucUong.map(menu => {
                let list = menu.DanhSachMonUong || menu.DanhSachMónUống || menu.DanhSachThucUong || [];
                if (typeof list === 'string') {
                    list = list.split(/\r?\n/).map(l => l.trim()).filter(Boolean).map((line, idx) => {
                        const cleanLine = line.replace(/^\d+[\s.\-:]+/, '');
                        return { STT: idx + 1, TenMonUong: cleanLine };
                    });
                }
                return {
                    TenThucUong: menu.TenThucUong || menu.TenMenuThucUong || 'Thức uống',
                    GhiChuThucUong: menu.GhiChuThucUong || menu.GhiChu || '',
                    DanhSachMonUong: Array.isArray(list) ? list.map((item, idx) => ({
                        STT: item.STT || (idx + 1),
                        TenMonUong: item.TenMonUong || item.TenThucUong || item.TenMon || (typeof item === 'string' ? item : '')
                    })) : []
                };
            });
        }

        // ── 2b. Chuẩn hóa và gộp lịch trình (LichTrinh) cho BEO Hội Nghị ──
        const formatDate = (val) => {
            if (!val) return null;
            if (val instanceof Date) {
                const d = val.getDate().toString().padStart(2, '0');
                const m = (val.getMonth() + 1).toString().padStart(2, '0');
                const y = val.getFullYear();
                return `${d}/${m}/${y}`;
            }
            if (typeof val === 'string') {
                const clean = val.trim();
                // Nếu đã là định dạng DD/MM/YYYY, giữ nguyên
                if (/^\d{2}\/\d{2}\/\d{4}$/.test(clean)) return clean;
                // Nếu là chuỗi ISO hoặc định dạng YYYY-MM-DD
                const parsed = new Date(clean);
                if (!isNaN(parsed.getTime())) {
                    const d = parsed.getDate().toString().padStart(2, '0');
                    const m = (parsed.getMonth() + 1).toString().padStart(2, '0');
                    const y = parsed.getFullYear();
                    return `${d}/${m}/${y}`;
                }
            }
            return val;
        };

        // Chuẩn hóa các ngày đơn lẻ
        dataMap.NgayToChuc = formatDate(dataMap.NgayToChuc);
        dataMap.NgaySetup = formatDate(dataMap.NgaySetup || dataMap.TuNgaySetup);
        dataMap.NgayOut = formatDate(dataMap.NgayOut || dataMap.NgayTraSanhDV);

        if (!dataMap.LichTrinh) {
            dataMap.LichTrinh = [];
        }


        // Xác định danh sách các trường cần chuyển đổi thành XML Word
        let fieldsToConvert = Array.isArray(convertFields) ? convertFields : [];
        
        fieldsToConvert.forEach(key => {
            if (dataMap[key] && typeof dataMap[key] === 'string') {
                dataMap[key] = convertTextToWordXML(dataMap[key]);
            }
        });

        console.log('[GENERATE] dataMap:', JSON.stringify(dataMap));

        // ── 3. Đọc template DOCX ─────────────────────────────────────────────
        const docxTemplatePath = path.join(SAMPLES_DIR, `${templateType}.docx`);
        if (!fs.existsSync(docxTemplatePath)) {
            return res.status(404).json({
                success: false,
                message: `Không tìm thấy template '${templateType}.docx' trong samples/. Vui lòng tạo file Word mẫu!`
            });
        }

        const content = fs.readFileSync(docxTemplatePath, "binary");

        // ── 4. Khởi tạo docxtemplater và bơm dữ liệu ─────────────────────────
        const zip = new PizZip(content);
        const doc = new Docxtemplater(zip, {
            paragraphLoop: true,
            linebreaks: true,
            nullGetter() {
                return "";
            }
        });

        // Đổ toàn bộ dataMap (Bên A + Bên B + Món ăn) vào template Word
        doc.render(dataMap);

        // HẬU XỬ LÝ XML: Tự động gộp dọc (vertical merge) các ô trùng tên sảnh ở các cột chỉ định
        try {
            let docXml = doc.getZip().file("word/document.xml").asText();
            
            let colsToMerge = [];
            if (Array.isArray(mergeColumns)) {
                colsToMerge = mergeColumns;
            } else if (typeof mergeColumns === 'string') {
                colsToMerge = [mergeColumns];
            } else {
                // Mặc định gộp cột "VỊ TRÍ" nếu không truyền để tương thích ngược
                colsToMerge = ["VỊ TRÍ"];
            }
            
            colsToMerge.forEach(colName => {
                docXml = mergeTableColumn(docXml, colName);
            });
            
            doc.getZip().file("word/document.xml", docXml);
            console.log(`[GENERATE] ✅ Đã tự động gộp dọc các ô trùng nhau ở cột: ${colsToMerge.join(', ')}`);
        } catch (xmlErr) {
            console.error('[GENERATE] Lỗi hậu xử lý XML gộp ô:', xmlErr.message);
        }

        const buf = doc.getZip().generate({
            type: "nodebuffer",
            compression: "DEFLATE",
        });

        // ── 5. Lưu file .docx đã sinh ra ──────────────
        const finalFileName = `${outputFileName}_${Date.now()}.docx`;
        const outputPath = path.join(UPLOADS_DIR, finalFileName);
        fs.writeFileSync(outputPath, buf);

        // ── 6. Ghi Log vào Tiec_Documents (Sổ lưu trữ) ───────────────────────
        try {
            // Tính toán mã băm SHA-256 từ nội dung file vật lý
            const fileHash = crypto.createHash('sha256').update(buf).digest('hex');

            const docData = {
                DocumentID: 'DOC_' + Date.now(),
                TiecID: dataMap.SoHopDong,
                FileName: finalFileName,
                FileType: templateType,
                VersionNo: 1,
                Status: 'SIGNED', // Vừa in xong chốt cứng luôn
                FileHash: fileHash // Lưu mã băm chống giả mạo
            };
            const payload = {
                List: 'Tiec_Documents',
                Func: 'Save',
                UserName: req.body.UserName || 'system',
                data: docData
            };
            await axios.post(`${SQL_API_BASE}/api/API_Gateway_Router`, payload);
            console.log(`[AUDIT] ✅ Đã lưu vết Sổ lưu trữ cho file ${finalFileName}`);
        } catch (err) {
            console.error(`[AUDIT] ❌ Lỗi ghi log:`, err.message);
        }

        console.log(`[GENERATE] ✅ Tạo thành công: ${finalFileName}`);
        return res.json({ success: true, message: 'Tạo tài liệu thành công!', fileName: finalFileName });

    } catch (error) {
        console.error('[API] Lỗi generate:', error.message || error);
        res.status(500).json({ success: false, message: 'Lỗi server: ' + (error.message || 'Unknown') });
    }
});

/**
 * 3. Xóa tài liệu
 */
app.delete('/api/documents/:fileName', async (req, res) => {
    try {
        const fileName = req.params.fileName;
        const filePath = path.join(UPLOADS_DIR, fileName);
        if (fs.existsSync(filePath)) {
            fs.unlinkSync(filePath); // Xóa file vật lý (Hard delete)

            // Cập nhật Bia mộ (Soft Delete) trong CSDL
            try {
                const payload = {
                    List: 'Tiec_Documents',
                    Func: 'Edit', // Cập nhật lại Status
                    UserName: req.body.UserName || 'system',
                    data: {
                        FileName: fileName, // Dùng tên file để tìm record
                        Status: 'DELETED',
                        IsDeleted: 1
                    }
                };
                await axios.post(`${SQL_API_BASE}/api/API_Gateway_Router`, payload);
                console.log(`[AUDIT] 🪦 Đã dán nhãn XÓA cho file ${fileName} trong CSDL`);
            } catch (err) {
                console.error(`[AUDIT] ❌ Lỗi cập nhật bia mộ:`, err.message);
            }

            res.json({ success: true, message: 'Xóa thành công!' });
        } else {
            res.status(404).json({ success: false, message: 'Không tìm thấy file để xóa!' });
        }
    } catch (error) {
        console.error('[API] Lỗi xóa file:', error.message);
        res.status(500).json({ success: false, message: 'Lỗi server khi xóa file.' });
    }
});

/**
 * 4. Upload Logo
 */
app.post('/api/upload-logo', (req, res) => {
    try {
        const { base64, fileName } = req.body;
        if (!base64) return res.status(400).json({ success: false, message: 'Thiếu dữ liệu base64' });

        // base64 có dạng: "data:image/jpeg;base64,/9j/4AA..."
        const matches = base64.match(/^data:([A-Za-z-+\/]+);base64,(.+)$/);
        let imageBuffer = null;
        if (matches && matches.length === 3) {
            imageBuffer = Buffer.from(matches[2], 'base64');
        } else {
            imageBuffer = Buffer.from(base64, 'base64');
        }

        // Mô phỏng lưu vào thư mục Qplaza\Logo theo yêu cầu TODO.md
        const logoDir = path.join(__dirname, '..', 'Qplaza', 'Logo');
        if (!fs.existsSync(logoDir)) fs.mkdirSync(logoDir, { recursive: true });

        const filePath = path.join(logoDir, fileName || 'logo.jpg');
        fs.writeFileSync(filePath, imageBuffer);

        console.log(`[UPLOAD] Đã lưu logo tại: ${filePath}`);
        res.json({ success: true, message: 'Upload logo thành công!', path: filePath });
    } catch (error) {
        console.error('[API] Lỗi upload logo:', error.message);
        res.status(500).json({ success: false, message: 'Lỗi server khi upload logo.' });
    }
});

// ==========================================
// API: ONLYOFFICE CALLBACK
// ==========================================
app.post('/api/documents/callback', async (req, res) => {
    const respondSuccess = () => res.json({ error: 0 });
    try {
        const data = req.body;
        const docId = req.query.docId || 'unknown';
        const fileName = req.query.fileName || `${docId}.docx`;
        const status = data.status;

        console.log(`[ONLYOFFICE] Callback — DocID: ${docId}, File: ${fileName}, Status: ${status}`);

        const isTemplate = req.query.isTemplate === '1';
        const targetDir = isTemplate ? SAMPLES_DIR : UPLOADS_DIR;

        if (status === 2 || status === 6) {
            const downloadUri = data.url;
            if (!downloadUri) { console.warn('[ONLYOFFICE] Không có URL tải file!'); return respondSuccess(); }

            console.log(`[ONLYOFFICE] Đang lưu file... (${status === 2 ? 'Save' : 'Forcesave'})`);
            const filePath = path.join(targetDir, fileName);
            const response = await axios({ method: 'GET', url: downloadUri, responseType: 'stream' });
            const writer = fs.createWriteStream(filePath);
            response.data.pipe(writer);
            await new Promise((resolve, reject) => { writer.on('finish', resolve); writer.on('error', reject); });
            console.log(`[ONLYOFFICE] ✅ Đã lưu: ${fileName} vào ${isTemplate ? 'samples' : 'uploads'}`);
        }
        return respondSuccess();
    } catch (error) {
        console.error('[ONLYOFFICE] ❌ Lỗi Callback:', error.message);
        return respondSuccess();
    }
});


// =========================================================================
// HELPER: Tự động gộp các ô có giá trị trùng nhau liên tiếp theo chiều dọc
// =========================================================================
function getTableRanges(xml) {
    const regex = /<w:tbl[\s>]|<\/w:tbl>/g;
    const matches = [];
    let match;
    while ((match = regex.exec(xml)) !== null) {
        matches.push({
            index: match.index,
            text: match[0],
            length: match[0].length
        });
    }

    const stack = [];
    const tables = [];

    for (const m of matches) {
        if (m.text.startsWith('<w:tbl')) {
            stack.push(m);
        } else if (m.text === '<\/w:tbl>') {
            if (stack.length > 0) {
                const startMatch = stack.pop();
                tables.push({
                    start: startMatch.index,
                    end: m.index + m.length,
                    depth: stack.length
                });
            }
        }
    }
    return tables;
}

function injectVMerge(cellXml, type) {
    const vMergeTag = type === 'restart' ? '<w:vMerge w:val="restart"/>' : '<w:vMerge/>';
    if (cellXml.match(/<w:tcPr>/)) {
        if (cellXml.match(/<w:vMerge[^>]*>/)) return cellXml;
        return cellXml.replace('<w:tcPr>', `<w:tcPr>${vMergeTag}`);
    } else {
        return cellXml.replace('<w:tc>', `<w:tc><w:tcPr>${vMergeTag}</w:tcPr>`);
    }
}

function mergeFlatTable(tblXml, headerName) {
    const rowRegex = /<w:tr(?:[^>]*)?>[\s\S]*?<\/w:tr>/g;
    const rows = tblXml.match(rowRegex);
    if (!rows || rows.length <= 1) return tblXml;

    const headerRow = rows[0];
    const cellsRegex = /<w:tc(?:[^>]*)?>[\s\S]*?<\/w:tc>/g;
    const headerCells = headerRow.match(cellsRegex);
    if (!headerCells) return tblXml;

    let colIdx = -1;
    for (let i = 0; i < headerCells.length; i++) {
        const cellText = headerCells[i].replace(/<[^>]*>/g, '').trim();
        if (cellText.toUpperCase() === headerName.toUpperCase()) {
            colIdx = i;
            break;
        }
    }

    if (colIdx === -1) return tblXml;

    let prevText = null;
    let groupStartIdx = -1;
    const rowCellsList = rows.map(row => row.match(cellsRegex) || []);

    for (let r = 1; r < rows.length; r++) {
        const cells = rowCellsList[r];
        if (colIdx >= cells.length) continue;

        const cellXml = cells[colIdx];
        const cellText = cellXml.replace(/<[^>]*>/g, '').trim();

        if (cells.length < headerCells.length || cellXml.includes('%%NESTED_TBL_')) {
            prevText = null;
            groupStartIdx = -1;
            continue;
        }

        if (cellText && cellText === prevText) {
            const startCells = rowCellsList[groupStartIdx];
            let startCell = startCells[colIdx];
            if (!startCell.includes('w:vMerge')) {
                startCell = injectVMerge(startCell, 'restart');
                startCells[colIdx] = startCell;
            }

            let currentCell = cellXml;
            currentCell = injectVMerge(currentCell, 'continue');
            cells[colIdx] = currentCell;
        } else {
            prevText = cellText;
            groupStartIdx = r;
        }
    }

    const updatedRows = rows.map((row, r) => {
        const cells = rowCellsList[r];
        let cIdx = 0;
        return row.replace(/<w:tc(?:[^>]*)?>[\s\S]*?<\/w:tc>/g, () => {
            return cells[cIdx++];
        });
    });

    const tblPrefix = tblXml.match(/^<w:tbl(?:[^>]*)?>[\s\S]*?(?=<w:tr(?:[^>]*)?>)/)[0];
    return tblPrefix + updatedRows.join('') + '</w:tbl>';
}

function processSingleTable(tblXml, headerName) {
    const nestedRanges = getTableRanges(tblXml);
    const children = nestedRanges.filter(r => r.depth === 1);

    const placeholders = [];
    children.sort((a, b) => b.start - a.start);
    let flatTblXml = tblXml;
    for (let i = 0; i < children.length; i++) {
        const child = children[i];
        const childXml = flatTblXml.substring(child.start, child.end);
        const processedChildXml = processSingleTable(childXml, headerName);
        
        const placeholder = `%%NESTED_TBL_${i}%%`;
        placeholders.push({ placeholder, content: processedChildXml });
        
        flatTblXml = flatTblXml.substring(0, child.start) + placeholder + flatTblXml.substring(child.end);
    }

    let mergedTblXml = mergeFlatTable(flatTblXml, headerName);

    for (const p of placeholders) {
        mergedTblXml = mergedTblXml.replace(p.placeholder, p.content);
    }

    return mergedTblXml;
}

function mergeTableColumn(xml, headerName) {
    const tables = getTableRanges(xml);
    const topLevelTables = tables.filter(t => t.depth === 0);

    topLevelTables.sort((a, b) => b.start - a.start);

    let resultXml = xml;
    for (const t of topLevelTables) {
        const tableXml = resultXml.substring(t.start, t.end);
        const processedTableXml = processSingleTable(tableXml, headerName);
        resultXml = resultXml.substring(0, t.start) + processedTableXml + resultXml.substring(t.end);
    }
    return resultXml;
}

function convertTextToWordXML(text, fieldName = '') {
    if (!text) return "";
    const lines = text.split(/\r?\n/);
    let xml = "";
    const isSetupField = fieldName === 'ThongTinSetup';
    
    for (let i = 0; i < lines.length; i++) {
        const line = lines[i].trim();
        if (!line) continue;
        
        // A line is considered a header if it doesn't start with a bullet character
        // and either ends with ":" or contains section keywords like Queen, Sảnh, Phía, Cổng, Lobby, v.v.
        const isHeader = !/^[-\*\+\•\d]/.test(line) && (line.endsWith(':') || /Queen|Sảnh|Sanh|Phía|Phia|Cổng|Cong|Lobby|Bảo vệ|Bao ve|Kỹ thuật|Ky thuat|Biểu ngữ|Bieu ngu|Setup|Sân khấu|San khau/i.test(line));
        
        // Escape XML entities
        const escapedLine = line
            .replace(/&/g, "&amp;")
            .replace(/</g, "&lt;")
            .replace(/>/g, "&gt;")
            .replace(/"/g, "&quot;")
            .replace(/'/g, "&apos;");
            
        // Check if the line contains warning keywords for red styling
        // Keywords: 'out', 'out hàng', 'out khach', 'gấp', 'gap', 'đặc biệt', 'dac biet', 'phạt', 'phat'
        const isWarningLine = /out|gấp|gap|đặc biệt|dac biet|phạt|phat/i.test(line);
        
        if (isHeader) {
            if (isSetupField) {
                // SẮP XẾP headers are Black, Bold, Underlined
                xml += `<w:r><w:rPr><w:rFonts w:ascii="Times New Roman" w:hAnsi="Times New Roman"/><w:b/><w:u w:val="single"/><w:sz w:val="20"/></w:rPr><w:t>${escapedLine}</w:t></w:r>`;
            } else {
                // LƯU Ý / other headers are Red, Bold, Underlined
                xml += `<w:r><w:rPr><w:rFonts w:ascii="Times New Roman" w:hAnsi="Times New Roman"/><w:b/><w:u w:val="single"/><w:color w:val="FF0000"/><w:sz w:val="20"/></w:rPr><w:t>${escapedLine}</w:t></w:r>`;
            }
        } else if (isWarningLine) {
            // Warning lines are Red, Underlined, and size 10pt (20 dxa)
            xml += `<w:r><w:rPr><w:rFonts w:ascii="Times New Roman" w:hAnsi="Times New Roman"/><w:u w:val="single"/><w:color w:val="FF0000"/><w:sz w:val="20"/></w:rPr><w:t>${escapedLine}</w:t></w:r>`;
        } else {
            // Normal lines are Black
            xml += `<w:r><w:rPr><w:rFonts w:ascii="Times New Roman" w:hAnsi="Times New Roman"/><w:sz w:val="20"/></w:rPr><w:t>${escapedLine}</w:t></w:r>`;
        }
        
        if (i < lines.length - 1) {
            xml += `<w:r><w:br/></w:r>`;
        }
    }
    return xml;
}


// ==========================================
// ROOT
// ==========================================
app.get('/', (req, res) => {
    res.json({
        service: 'Wedding Banquet Document API',
        status: '✅ Running smoothly',
        endpoints: {
            list: 'GET /api/documents',
            generate: 'POST /api/documents/generate',
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
    console.log('       ✨ BACKEND SERVER - WEDDING BANQUET MANAGEMENT   ');
    console.log('=======================================================');
    console.log(`[🚀] Server : http://localhost:${PORT}`);
    console.log(`[📁] Uploads: ${UPLOADS_DIR}`);
    console.log(`[📁] Samples: ${SAMPLES_DIR}`);
    console.log(`[🔗] SQL API: ${SQL_API_BASE}`);
    console.log('=======================================================');
});
