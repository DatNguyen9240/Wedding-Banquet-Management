import express from 'express';
import cors from 'cors';
import axios from 'axios';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();
const PORT = process.env.PORT || 8080;

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
async function fetchSetupInfo() {
    const now = Date.now();
    if (_setupCache && (now - _setupCacheTime) < SETUP_CACHE_TTL) return _setupCache;
    try {
        const url = `${SQL_API_BASE}/api/API_LayGiaTriSetup`;
        const resp = await axios.get(url, { timeout: 8000 });
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

/**
 * Tạo object thông tin Bên A từ setup API
 * API_LayGiaTriSetup trả về: CodeID='Com1' → tên công ty
 */
function mapBenA(setup) {
    // 'Com1' = Tên công ty theo bảng SY_Setup
    const tenNhaHang = setup['Com1'] || setup.Com1 || setup.TenNhaHang || setup.TenCongTy || 'NHÀ HÀNG TIỆC CƯỚI';
    return {
        TenNhaHang: tenNhaHang,
        SlogenNhaHang: setup.Slogan || setup.SlogenNhaHang || '★ LUXURY WEDDING & EVENTS ★',
        DiaChiNhaHang: setup.DiaChi || setup.DiaChiNhaHang || setup.Com2 || '',
        DienThoaiNhaHang: setup.DienThoai || setup.DienThoaiNhaHang || setup.Com3 || '',
        HotlineNhaHang: setup.Hotline || setup.HotlineNhaHang || setup.Com4 || '',
    };
}

/** Gọi API Gateway để lấy record theo List + Keyword */
async function fetchFromSQLAPI(listName, keyword) {
    const payload = {
        List: listName, Func: 'View', UserName: SQL_API_USER,
        Keyword: keyword || '', Page: 1, Limit: 1
    };
    const qs = encodeURIComponent(JSON.stringify(payload));
    const url = `${SQL_API_BASE}/api/API_Gateway_Router?q=${qs}`;
    console.log(`[SQL API] Gọi: ${listName} | Keyword: ${keyword}`);
    const resp = await axios.get(url, { timeout: 10000 });
    const json = resp.data;
    if (json && json.records && json.records.length > 0) return json.records[0];
    if (json && json.code === 0) return json;
    return null;
}

/** Map HopDong API row → docx placeholder object */
function mapHopDong(row, setup) {
    const now = new Date();
    const d = String(now.getDate()).padStart(2, '0');
    const m = String(now.getMonth() + 1).padStart(2, '0');
    const y = now.getFullYear();
    return {
        // Bên A — từ setup
        ...mapBenA(setup),
        // Bên B + tiệc — từ API hợp đồng
        Sohopdong: row.Sohopdong || row.sohopdong || '',
        Sobiennhan: row.Sobiennhan || row.sobiennhan || '',
        TenKhachHang: row.TenKhachHang || row.tenkh || '',
        DienThoai: row.DienThoai || row.dienthoai || '',
        NgayToChuc: row.NgayToChuc || row.ngaytochuc || '',
        SoBan: row.SoBan || row.soban || '',
        SanhDat: row.SanhDat || row.sanhdat || '',
        TongTien: _formatMoney(row.TongTien || row.tongtien || '0'),
        TrangThai: row.TrangThai || row.trangthai || '',
        NgayKy: `${d}/${m}/${y}`,
        NhanVienPhuTrach: row.NhanVien || row.nhanvien || '',
    };
}

/**
 * Map DatCoc (PhieuCoc) API row → docx placeholder object
 * SQL API_DanhSachPhieuCoc trả về: MaChungTu, SoPhieu, TenKhachHang,
 * DienThoai, NgayToChuc, SoBan, SanhDat, DaCocVND (không phải SoTienCoc!)
 */
function mapDatCoc(row, setup) {
    const now = new Date();
    const d = String(now.getDate()).padStart(2, '0');
    const m = String(now.getMonth() + 1).padStart(2, '0');
    const y = now.getFullYear();
    // Field thực tế trong SQL là DaCocVND (xem API_DanhSachPhieuCoc.sql dòng 65)
    const soTien = row.DaCocVND || row.dacoc || row.SoTienCoc || row.Tongtien || row.tongtien || '0';
    return {
        // Bên A — từ setup
        ...mapBenA(setup),
        // Thông tin phiếu cọc — field name CHÍNH XÁC theo SQL
        MaChungTu: row.MaChungTu || row.DocumentID || row.SoPhieu || '',
        SoPhieu: row.SoPhieu || row.SoBN || '',
        TenKhachHang: row.TenKhachHang || '',
        DienThoai: row.DienThoai || '',
        NgayToChuc: row.NgayToChuc || '',
        SanhDat: row.SanhDat || '',
        SoBan: row.SoBan || String(row.SobanManchinhthuc || ''),
        SoTienCoc: _formatMoney(soTien),
        SoTienCocChu: _numberToWords(soTien),
        NgayLap: row.NgayLap || `${d}/${m}/${y}`,
        NhanVienLap: row.NhanVien || '',
        TrangThai: row.TrangThai || '',
    };
}

function _formatMoney(val) {
    const n = parseInt(String(val).replace(/[^0-9]/g, ''), 10);
    if (isNaN(n)) return String(val);
    return n.toLocaleString('vi-VN');
}

function _numberToWords(val) {
    const n = parseInt(String(val).replace(/[^0-9]/g, ''), 10);
    if (isNaN(n) || n === 0) return 'Không đồng';
    const units = ['', 'một', 'hai', 'ba', 'bốn', 'năm', 'sáu', 'bảy', 'tám', 'chín'];
    const levels = [{ v: 1e9, n: 'tỷ' }, { v: 1e6, n: 'triệu' }, { v: 1e3, n: 'nghìn' }, { v: 1, n: '' }];
    let result = '', rem = n;
    for (const lv of levels) {
        if (rem >= lv.v) {
            const q = Math.floor(rem / lv.v);
            rem -= q * lv.v;
            result += (q < 10 ? units[q] : q) + (lv.n ? ' ' + lv.n + ' ' : '');
        }
    }
    return result.trim().replace(/\s+/g, ' ') + ' đồng chẵn';
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
 * 2b. Generate tài liệu từ HTML template
 *
 * Cách hoạt động:
 *   1. Đọc file mẫu HTML  (samples/hop_dong.html  hoặc dat_coc.html)
 *   2. Thay tất cả {TenBien} bằng giá trị thật từ rowData
 *   3. Lưu ra file .doc (Word đọc được HTML)
 *
 * Tên biến trong template lấy từ:
 *   EXEC API_LayCacTruongGiaoDien @FormName = 'frmHopDong'
 *   → cột [name] = tên biến,  cột [label] = nhãn tiếng Việt
 */

/**
 * 1.5 Lấy danh sách các biến dữ liệu cho một loại mẫu
 */
app.get('/api/documents/fields/:type', (req, res) => {
    try {
        const type = req.params.type;
        let fields = [];
        const dummyRow = {};
        const dummySetup = {};

        if (type === 'hop_dong' || type === 'quyet_toan' || type === 'de_nghi_thay_doi') {
            fields = Object.keys(mapHopDong(dummyRow, dummySetup));
        } else if (type === 'dat_coc' || type === 'phieu_thu') {
            fields = Object.keys(mapDatCoc(dummyRow, dummySetup));
        } else {
            return res.status(400).json({ success: false, message: 'Invalid type' });
        }

        const formattedFields = fields.map(f => `{${f}}`);
        res.json({ success: true, fields: formattedFields });
    } catch (error) {
        console.error('[API] Lỗi lấy danh sách biến:', error);
        res.status(500).json({ success: false, message: 'Lỗi server: ' + error.message });
    }
});

app.post('/api/documents/generate', async (req, res) => {
    try {
        let { outputFileName, templateType, customerId, rowData } = req.body;
        if (!templateType) return res.status(400).json({ success: false, message: 'Thiếu templateType.' });
        if (!outputFileName) outputFileName = 'Generated_' + templateType;
        outputFileName = outputFileName.replace(/[\/\\:*?"<>|]/g, '_').replace(/\s+/g, '_');

        // ── 1. Lấy thông tin nhà hàng từ Setup API ──────────────────────────
        const setup = await fetchSetupInfo().catch(() => ({}));

        // ── 2. Map data từ rowData (frontend) hoặc fallback SQL API ─────────
        const API_MAP = {
            'hop_dong': { list: 'frmHopDong', mapFn: mapHopDong },
            'dat_coc': { list: 'frmBiennhancocchoancoccho', mapFn: mapDatCoc },
            'phieu_thu': { list: 'frmPhieuThu', mapFn: mapDatCoc },
            'de_nghi_thay_doi': { list: 'frmHopDong', mapFn: mapHopDong },
        };
        const apiCfg = API_MAP[templateType];
        let dataMap = mapBenA(setup);  // Luôn có thông tin nhà hàng

        if (rowData && typeof rowData === 'object') {
            // Frontend đã gửi kèm rowData (selected row từ DynamicFormEngine)
            dataMap = apiCfg ? apiCfg.mapFn(rowData, setup) : { ...dataMap, ...rowData };
            console.log('[GENERATE] ✅ Dùng rowData từ frontend');
        } else if (apiCfg && customerId) {
            // Fallback: gọi SQL API
            try {
                const row = await fetchFromSQLAPI(apiCfg.list, customerId);
                if (row) dataMap = apiCfg.mapFn(row, setup);
            } catch (e) {
                console.error('[GENERATE] Lỗi SQL API:', e.message);
            }
        }

        console.log('[GENERATE] dataMap:', JSON.stringify(dataMap));

        // ── 3. Đọc template HTML ─────────────────────────────────────────────
        const htmlTemplatePath = path.join(SAMPLES_DIR, `${templateType}.html`);
        if (!fs.existsSync(htmlTemplatePath)) {
            return res.status(404).json({
                success: false,
                message: `Không tìm thấy template '${templateType}.html' trong samples/`
            });
        }
        let html = fs.readFileSync(htmlTemplatePath, 'utf8');

        // ── 4. Thay thế tất cả {TenBien} bằng giá trị thật ─────────────────
        // Dùng regex để tìm toàn bộ {placeholder} và replace
        html = html.replace(/\{(\w+)\}/g, (match, key) => {
            const val = dataMap[key];
            return (val !== undefined && val !== null) ? String(val) : '';
        });

        // [FIX] Khắc phục lỗi OnlyOffice xuất file với line-height: 0.1pt gây đè dòng
        html = html.replace(/line-height:\s*0\.1pt;?/gi, 'line-height: 1.5;');
        html = html.replace(/margin-top:\s*56\.7pt;?/gi, 'margin-top: 10pt;');
        html = html.replace(/margin-bottom:\s*56\.7pt;?/gi, 'margin-bottom: 10pt;');

        // [FIX] Khắc phục lỗi chữ trắng trên nền trắng trong bảng
        html = html.replace(/color:#ffffff;mso-style-textfill-fill-color:#ffffff/gi, 'color:#8b0000;mso-style-textfill-fill-color:#8b0000');

        // ── 5. Lưu file .doc hoặc .xls (dựa theo loại mẫu) ──────────────
        const ext = (templateType === 'phieu_thu') ? '.xls' : '.doc';
        const finalFileName = `${outputFileName}_${Date.now()}${ext}`;
        const outputPath = path.join(UPLOADS_DIR, finalFileName);
        fs.writeFileSync(outputPath, html, 'utf8');

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
app.delete('/api/documents/:fileName', (req, res) => {
    try {
        const fileName = req.params.fileName;
        const filePath = path.join(UPLOADS_DIR, fileName);
        if (fs.existsSync(filePath)) {
            fs.unlinkSync(filePath);
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
