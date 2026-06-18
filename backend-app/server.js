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
// Sử dụng cors middleware của Express để luôn tự động thêm headers CORS đầy đủ
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
let SQL_API_BASE;
const SQL_API_USER = 'admin';

// Tự động tải API_BASE từ env.js (Bắt buộc)
try {
    const possiblePaths = [
        path.join(__dirname, '../env.js'),
        path.join(__dirname, 'env.js'),
        '/env.js',
        '/app/env.js'
    ];
    let envJsPath = null;
    for (const p of possiblePaths) {
        if (fs.existsSync(p)) {
            envJsPath = p;
            break;
        }
    }
    if (!envJsPath) {
        throw new Error(`Không tìm thấy file env.js ở bất kỳ đường dẫn nào: ${possiblePaths.join(', ')}`);
    }
    const envContent = fs.readFileSync(envJsPath, 'utf8');
    const matchBase = envContent.match(/API_BASE\s*:\s*['"`](.*?)['"`]/);
    if (!matchBase || !matchBase[1]) {
        throw new Error('Không tìm thấy API_BASE trong file env.js!');
    }
    SQL_API_BASE = matchBase[1].trim();
    console.log(`[CONFIG] Đã tải SQL_API_BASE từ env.js (${envJsPath}): ${SQL_API_BASE}`);
} catch (err) {
    console.error('[CRITICAL] Không thể chạy server vì thiếu cấu hình env.js:', err.message);
    process.exit(1);
}

/** Giải mã username từ token hoặc fallback */
function extractUserName(req) {
    const authHeader = req.headers.authorization;
    if (authHeader) {
        try {
            const token = authHeader.startsWith('Bearer ') ? authHeader.substring(7) : authHeader;
            const parts = token.split('.');
            if (parts.length === 3) {
                const payload = JSON.parse(Buffer.from(parts[1], 'base64').toString('utf8'));
                const user = payload.UserName || payload.username || payload.unique_name || payload.name || payload.sub;
                if (user) return user;
            }
        } catch (e) {
            console.error('[AUTH] Lỗi giải mã JWT:', e.message);
        }
    }
    return req.body?.UserName || req.query?.UserName || req.headers?.username || 'system';
}

// Cache thông tin nhà hàng (tránh gọi API nhiều lần)
let _setupCache = null;
let _setupCacheTime = 0;
const SETUP_CACHE_TTL = 5 * 60 * 1000; // 5 phút

/** Helper function to execute axios requests with retries */
async function axiosGetWithRetry(url, config = {}, retries = 3, delay = 1000) {
    for (let i = 0; i < retries; i++) {
        try {
            return await axios.get(url, config);
        } catch (err) {
            if (i === retries - 1) throw err;
            console.warn(`[HTTP RETRY] Lần thử ${i + 1} thất bại cho ${url}: ${err.message}. Thử lại sau ${delay}ms...`);
            await new Promise(resolve => setTimeout(resolve, delay));
        }
    }
}

/** Lấy thông tin nhà hàng từ API_LayGiaTriSetup (có cache) */
async function fetchSetupInfo(authToken) {
    const now = Date.now();
    if (_setupCache && (now - _setupCacheTime) < SETUP_CACHE_TTL) return _setupCache;
    try {
        const url = `${SQL_API_BASE}/api/API_LayGiaTriSetup`;
        const headers = {};
        if (authToken) headers['Authorization'] = authToken;
        const resp = await axiosGetWithRetry(url, { headers, timeout: 8000 }, 3, 1000);
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
    try {
        const resp = await axiosGetWithRetry(url, { headers, timeout: 10000 }, 3, 1000);
        const json = resp.data;
        if (json && json.records && json.records.length > 0) return json.records[0];
        if (json && json.code === 0) return json;
    } catch (err) {
        console.error(`[SQL API] Lỗi khi gọi ${listName}:`, err.message);
    }
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
 * Lấy danh sách Mẫu gốc (Templates)
 */
app.get('/api/documents/templates', (req, res) => {
    try {
        let results = [];
        const scanDir = (dir) => {
            if (!fs.existsSync(dir)) return;
            const files = fs.readdirSync(dir);
            for (const file of files) {
                const fullPath = path.join(dir, file);
                const stat = fs.statSync(fullPath);
                if (stat.isDirectory()) {
                    scanDir(fullPath);
                } else if (file.endsWith('.docx') || file.endsWith('.html')) {
                    // Trả về tên file và đường dẫn tương đối để dễ hiển thị
                    results.push({
                        fileName: file,
                        relPath: path.relative(SAMPLES_DIR, fullPath).replace(/\\/g, '/'),
                        size: (stat.size / 1024).toFixed(2) + ' KB',
                        updatedAt: stat.mtime
                    });
                }
            }
        };
        scanDir(SAMPLES_DIR);
        res.json({ success: true, data: results });
    } catch (error) {
        console.error('[API] Lỗi lấy danh sách template:', error.message);
        res.status(500).json({ success: false, message: 'Lỗi server khi lấy template.' });
    }
});

/**
 * 1.5 Lấy danh sách các biến dữ liệu cho một loại mẫu
 */
app.get('/api/documents/fields/:listName', async (req, res) => {
    try {
        const listName = req.params.listName;

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
        if (!sqlListName) return res.status(400).json({ success: false, message: 'Thiếu sqlListName để truy vấn.' });
        if (!outputFileName) outputFileName = 'Generated_' + templateType;
        // Lọc bỏ tất cả ký tự đặc biệt, dấu ngoặc, dấu cộng để ONLYOFFICE không bị lỗi 400 Bad Request
        outputFileName = outputFileName.replace(/[\/\\:*?"<>|()+]/g, '_').replace(/\s+/g, '_');
        
        // ── 0. Tải cấu hình tài liệu động ───────────────────────────
        const docConfig = getDocumentConfig();
        
        // ── 1. Lấy thông tin nhà hàng từ Setup API ──────────────────────────
        const setup = await fetchSetupInfo(req.headers.authorization).catch(() => ({}));
 
        // ── 2. Map data từ rowData (frontend) hoặc SQL API ─────────
        let dataMap = { ...setup };
 
        let dbRow = null;
        if (customerId) {
            try {
                dbRow = await fetchFromSQLAPI(sqlListName, customerId, req.headers.authorization);
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
 
        // Tự động parse JSON từ CSDL (kể cả JSON lồng nhau — menu/dịch vụ docx)
        dataMap = deepParseJsonStrings(dataMap);
 
        // Format array of services to text string for fields that are converted to XML
        const arrayToStringFields = docConfig.arrayToStringFields || [];
        arrayToStringFields.forEach(key => {
            const foundKey = Object.keys(dataMap).find(k => k.toLowerCase() === key.toLowerCase());
            if (foundKey && Array.isArray(dataMap[foundKey])) {
                dataMap[foundKey] = dataMap[foundKey].map(item => formatArrayItem(item, docConfig)).filter(Boolean).join('\n');
            }
        });
 
        // Xác định danh sách các trường cần chuyển đổi thành XML Word (sẽ được tự động bổ sung khi quét template)
        let fieldsToConvert = Array.isArray(convertFields) ? [...convertFields] : [];
 
        console.log('[GENERATE] dataMap:', JSON.stringify(dataMap));

        // ── 3. Đọc template DOCX (Tìm kiếm đệ quy) ───────────────────────────
        const docxTemplatePath = findTemplatePath(SAMPLES_DIR, templateType);
        if (!docxTemplatePath) {
            return res.status(404).json({
                success: false,
                message: `Không tìm thấy template '${templateType}' trong samples/ hoặc các thư mục con.`
            });
        }

        if (docxTemplatePath.toLowerCase().endsWith('.doc')) {
            return res.status(400).json({
                success: false,
                message: `Mẫu biểu '${templateType}' đang là định dạng legacy (.doc). Vui lòng lưu thành định dạng .docx trước khi chạy!`
            });
        }

        const content = fs.readFileSync(docxTemplatePath, "binary");

        // ── 4. Khởi tạo docxtemplater và bơm dữ liệu ─────────────────────────
        const zip = new PizZip(content);

        // --- CHUẨN HÓA ĐƯỜNG DẪN ZIP (HỖ TRỢ ĐƯỜNG DẪN WINDOWS) ---
        // Một số file .docx được nén trên Windows sử dụng dấu gạch chéo ngược (\) thay vì (/)
        // Làm docxtemplater và xml cleaner không tìm thấy các file như word/document.xml
        try {
            const fileNames = Object.keys(zip.files);
            for (const name of fileNames) {
                if (name.includes('\\')) {
                    const normalizedName = name.replace(/\\/g, '/');
                    zip.files[normalizedName] = zip.files[name];
                    if (zip.files[normalizedName]) {
                        zip.files[normalizedName].name = normalizedName;
                    }
                    delete zip.files[name];
                }
            }
        } catch (normErr) {
            console.warn('[GENERATE] ⚠️ Không thể chuẩn hóa đường dẫn trong ZIP:', normErr.message);
        }

        // --- TỰ ĐỘNG LÀM SẠCH TAG TRONG WORD (XML CLEANER) ---
        // Word thường tự chèn các thẻ <w:t> làm nát tag {Ten_Bien} thành {Te<w:t>n_Bi</w:t>en}
        // Đoạn code này sẽ tìm và nối chúng lại trước khi Docxtemplater xử lý.
        try {
            const docXmlFile = zip.file("word/document.xml");
            if (docXmlFile) {
                let xmlContent = docXmlFile.asText();
                // Regex tìm các khối { ... } có chứa thẻ XML bên trong
                // sau đó loại bỏ toàn bộ thẻ XML (<...>) nhưng giữ lại nội dung text
                xmlContent = xmlContent.replace(/\{[^{}]*?<[^>]+>[^{}]*?\}/g, (match) => {
                    return match.replace(/<[^>]+>/g, "");
                });
                zip.file("word/document.xml", xmlContent);
            }
        } catch (cleanErr) {
            console.warn('[GENERATE] ⚠️ Không thể làm sạch XML tags:', cleanErr.message);
        }

        // --- TỰ ĐỘNG PHÁT HIỆN VÀ CHUẨN HÓA CÁC TAG RAW XML TRONG TẤT CẢ FILE XML ---
        try {
            const fileNames = Object.keys(zip.files);
            const rawTagsFound = new Set();
            const rawTagRegex = /\{@\s*([a-zA-Z0-9_#]+)\s*\}/g;
            
            for (const name of fileNames) {
                if (name.endsWith('.xml')) {
                    const xmlFile = zip.file(name);
                    if (xmlFile) {
                        const xmlContent = xmlFile.asText();
                        let match;
                        while ((match = rawTagRegex.exec(xmlContent)) !== null) {
                            rawTagsFound.add(match[1]);
                        }
                    }
                }
            }
            
            if (rawTagsFound.size > 0) {
                console.log('[GENERATE] Phát hiện các tag raw XML trong template:', Array.from(rawTagsFound));
                rawTagsFound.forEach(tag => {
                    if (!fieldsToConvert.some(f => f.toLowerCase() === tag.toLowerCase())) {
                        fieldsToConvert.push(tag);
                    }
                });
            }
        } catch (scanErr) {
            console.warn('[GENERATE] ⚠️ Lỗi quét raw XML tags từ template:', scanErr.message);
        }

        // --- CHUYỂN ĐỔI CÁC TRƯỜNG CẦN THIẾT SANG WORD XML ---
        fieldsToConvert.forEach(key => {
            const foundKey = Object.keys(dataMap).find(k => k.toLowerCase() === key.toLowerCase());
            if (foundKey) {
                let value = dataMap[foundKey];
                // Nếu giá trị là Array (chưa được format thành string ở trên), hãy format nó
                if (Array.isArray(value)) {
                    value = value.map(item => formatArrayItem(item, docConfig)).filter(Boolean).join('\n');
                } else if (value && typeof value === 'object') {
                    value = JSON.stringify(value);
                }
                
                // Đảm bảo kết quả là string và chuyển đổi sang Word XML
                if (value !== undefined && value !== null) {
                    dataMap[foundKey] = convertTextToWordXML(String(value), foundKey, docConfig);
                } else {
                    dataMap[foundKey] = "";
                }
            } else {
                // Nếu không có trong dataMap, set giá trị mặc định là chuỗi rỗng để tránh lỗi undefined cho raw XML
                dataMap[key] = "";
            }
        });

        const doc = new Docxtemplater(zip, {
            paragraphLoop: true,
            linebreaks: true,
            parser: function(tag) {
                return {
                    get: function(scope) {
                        if (tag === '.') return scope;
                        let val = "";
                        if (scope && typeof scope === 'object') {
                            if (scope[tag] !== undefined && scope[tag] !== null) {
                                val = scope[tag];
                            } else {
                                const cleanTag = tag.toLowerCase().replace(/_/g, '');
                                const foundKey = Object.keys(scope).find(k => {
                                    const cleanKey = k.toLowerCase().replace(/_/g, '');
                                    return cleanKey === cleanTag;
                                });
                                if (foundKey && scope[foundKey] !== undefined && scope[foundKey] !== null) {
                                    val = scope[foundKey];
                                }
                            }
                        }
                        // Trả về đối tượng/mảng nguyên bản cho các tag loop
                        if (val && typeof val === 'object') {
                            return val;
                        }
                        // Tránh trả về null/undefined cho raw XML hoặc text tag
                        return val === null || val === undefined ? "" : String(val);
                    }
                };
            },
            nullGetter() {
                return "";
            }
        });

        // Đổ toàn bộ dataMap vào template Word
        try {
            doc.render(dataMap);
            console.log('[GENERATE] ✅ Render dữ liệu vào template thành công');
        } catch (renderErr) {
            console.error('[GENERATE] ❌ Lỗi render:', renderErr.message);
            if (renderErr.properties && renderErr.properties.errors) {
                console.error('[GENERATE] Chi tiết:', JSON.stringify(renderErr.properties.errors));
            }
            throw renderErr;
        }

        let buf;
        try {
            const docZip = doc.getZip();
            if (!docZip) {
                throw new Error('getZip() trả về null lúc generate');
            }
            buf = docZip.generate({
                type: "nodebuffer",
                compression: "DEFLATE",
            });
        } catch (genErr) {
            console.error('[GENERATE] ❌ Lỗi generate ZIP:', genErr.message);
            throw genErr;
        }

        // ── 5. Lưu file .docx đã sinh ra ──────────────
        const finalFileName = `${outputFileName}_${Date.now()}.docx`;
        const outputPath = path.join(UPLOADS_DIR, finalFileName);
        fs.writeFileSync(outputPath, buf);

        // ── 6. Ghi Log vào Tiec_Documents (Sổ lưu trữ) ───────────────────────
        try {
            // Tính toán mã băm SHA-256 từ nội dung file vật lý
            const fileHash = crypto.createHash('sha256').update(buf).digest('hex');

            // Tìm mã tiệc case-insensitive từ dataMap hoặc customerId làm fallback
            const tiecId = dataMap.Sohopdong || dataMap.SoHopDong || dataMap.sohopdong || customerId || '';

            const userName = extractUserName(req);
            const docData = {
                TiecID: tiecId,
                DocType: templateType,
                VersionNo: 1,
                FilePath: finalFileName,
                FileHash: fileHash,
                Status: 'ACTIVE',
                GeneratedBy: userName
            };
            const payload = {
                List: 'Tiec_Documents',
                Func: 'Save',
                UserName: userName,
                JsonData: JSON.stringify(docData)
            };
            const headers = {};
            if (req.headers && req.headers.authorization) {
                headers['Authorization'] = req.headers.authorization;
            }
            await axios.post(`${SQL_API_BASE}/api/API_Gateway_Router`, payload, { headers });
            console.log(`[AUDIT] ✅ Đã lưu vết Sổ lưu trữ cho file ${finalFileName}`);
        } catch (err) {
            console.error(`[AUDIT] ❌ Lỗi ghi log:`, err.message);
        }

        console.log(`[GENERATE] ✅ Tạo thành công: ${finalFileName}`);
        return res.json({ success: true, message: 'Tạo tài liệu thành công!', fileName: finalFileName });

    } catch (error) {
        console.error('[API] Lỗi generate:', error);
        if (error.properties && error.properties.errors) {
            console.error('[API] Chi tiết lỗi docxtemplater:', JSON.stringify(error.properties.errors));
            const details = error.properties.errors.map(e => e.message + (e.properties && e.properties.explanation ? ': ' + e.properties.explanation : '')).join('; ');
            return res.status(500).json({ success: false, message: 'Lỗi Docxtemplater: ' + details });
        }
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
                // Thử phân tách tên file để lấy TiecID và DocType phòng khi file chưa có trong CSDL
                // Định dạng chuẩn: {DocType}_{TiecID}_{Timestamp}.docx
                let parsedTiecID = 'UNKNOWN';
                let parsedDocType = 'UNKNOWN';
                
                const nameWithoutExt = fileName.replace(/\.[^/.]+$/, "");
                const parts = nameWithoutExt.split('_');
                if (parts.length >= 3) {
                    const timestamp = parts[parts.length - 1];
                    if (/^\d+$/.test(timestamp)) {
                        parsedTiecID = parts[parts.length - 2];
                        parsedDocType = parts.slice(0, parts.length - 2).join('_');
                    }
                }

                const userName = extractUserName(req);
                const payload = {
                    List: 'Tiec_Documents',
                    Func: 'Edit', // Cập nhật lại Status
                    UserName: userName,
                    JsonData: JSON.stringify({
                        FilePath: fileName, // Dùng FilePath làm khóa tìm kiếm
                        TiecID: parsedTiecID,
                        DocType: parsedDocType,
                        Status: 'DELETED',
                        DeletedBy: userName,
                        DeletedAt: new Date().toISOString()
                    })
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

const CONFIG_FILE_PATH = path.join(__dirname, 'document-config.json');

function getDocumentConfig() {
    try {
        if (fs.existsSync(CONFIG_FILE_PATH)) {
            const fileContent = fs.readFileSync(CONFIG_FILE_PATH, 'utf8');
            return JSON.parse(fileContent);
        }
    } catch (err) {
        console.warn('[CONFIG] ⚠️ Lỗi đọc file document-config.json:', err.message);
    }
    return {};
}

function escapeRegExp(string) {
    return string.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
}

function formatArrayItem(item, docConfig) {
    if (!item) return '';
    if (typeof item !== 'object') return String(item);
    
    const itemFieldNames = docConfig.itemFieldNames || [];
    const itemPriceNames = docConfig.itemPriceNames || [];
    const itemNoteNames = docConfig.itemNoteNames || [];
    const currencySuffix = docConfig.currencySuffix || '';
    
    let name = '';
    for (const fName of itemFieldNames) {
        const foundNameKey = Object.keys(item).find(k => k.toLowerCase() === fName.toLowerCase());
        if (foundNameKey && item[foundNameKey]) {
            name = item[foundNameKey];
            break;
        }
    }
    if (!name) {
        // Fallback: nếu không cấu hình trường tên, dùng trường đầu tiên có giá trị chuỗi
        const firstStringKey = Object.keys(item).find(k => typeof item[k] === 'string' && item[k]);
        if (firstStringKey) name = item[firstStringKey];
        else return String(item);
    }
    
    let price = '';
    for (const pName of itemPriceNames) {
        const foundPriceKey = Object.keys(item).find(k => k.toLowerCase() === pName.toLowerCase());
        if (foundPriceKey && item[foundPriceKey]) {
            price = item[foundPriceKey];
            break;
        }
    }
    
    if (price && currencySuffix) {
        const cleanSuffix = currencySuffix.trim().toUpperCase();
        if (!String(price).toUpperCase().endsWith(cleanSuffix) && !String(price).toUpperCase().endsWith('VND') && !String(price).toUpperCase().endsWith('VNĐ')) {
            price = price + currencySuffix;
        }
    }
    
    let note = '';
    for (const nName of itemNoteNames) {
        const foundNoteKey = Object.keys(item).find(k => k.toLowerCase() === nName.toLowerCase());
        if (foundNoteKey && item[foundNoteKey]) {
            note = item[foundNoteKey];
            break;
        }
    }
    
    return `- ${name}${price ? ': ' + price : ''}${note ? ' (' + note + ')' : ''}`;
}

function convertTextToWordXML(text, fieldName = '', docConfig = getDocumentConfig()) {
    if (!text) return "";
    const lines = text.split(/\r?\n/);
    let xml = "";
    
    const setupFieldName = docConfig.setupFieldName || '';
    const isSetupField = fieldName && setupFieldName && fieldName === setupFieldName;
    
    const headerKeywords = docConfig.headerKeywords || [];
    const warningKeywords = docConfig.warningKeywords || [];
    
    const xmlStyles = docConfig.xmlStyles || {};
    const fontName = xmlStyles.fontFamily || 'Times New Roman';
    const fontSize = xmlStyles.fontSize || 20;
    const warningColor = xmlStyles.warningColor || 'FF0000';
    const headerColor = xmlStyles.headerColor || 'FF0000';
    
    const hasHeaderKeywords = headerKeywords.length > 0;
    const headerRegex = hasHeaderKeywords ? new RegExp(headerKeywords.map(escapeRegExp).join('|'), 'i') : null;
    
    const hasWarningKeywords = warningKeywords.length > 0;
    const warningRegex = hasWarningKeywords ? new RegExp(warningKeywords.map(escapeRegExp).join('|'), 'i') : null;
    
    for (let i = 0; i < lines.length; i++) {
        const line = lines[i].trim();
        if (!line) continue;
        
        const isHeader = !/^[-\*\+\•\d]/.test(line) && (line.endsWith(':') || (headerRegex && headerRegex.test(line)));
        
        const escapedLine = line
            .replace(/&/g, "&amp;")
            .replace(/</g, "&lt;")
            .replace(/>/g, "&gt;")
            .replace(/"/g, "&quot;")
            .replace(/'/g, "&apos;");
            
        const isWarningLine = warningRegex && warningRegex.test(line);
        
        if (isHeader) {
            if (isSetupField) {
                xml += `<w:r><w:rPr><w:rFonts w:ascii="${fontName}" w:hAnsi="${fontName}"/><w:b/><w:u w:val="single"/><w:sz w:val="${fontSize}"/></w:rPr><w:t>${escapedLine}</w:t></w:r>`;
            } else {
                xml += `<w:r><w:rPr><w:rFonts w:ascii="${fontName}" w:hAnsi="${fontName}"/><w:b/><w:u w:val="single"/><w:color w:val="${headerColor}"/><w:sz w:val="${fontSize}"/></w:rPr><w:t>${escapedLine}</w:t></w:r>`;
            }
        } else if (isWarningLine) {
            xml += `<w:r><w:rPr><w:rFonts w:ascii="${fontName}" w:hAnsi="${fontName}"/><w:u w:val="single"/><w:color w:val="${warningColor}"/><w:sz w:val="${fontSize}"/></w:rPr><w:t>${escapedLine}</w:t></w:r>`;
        } else {
            xml += `<w:r><w:rPr><w:rFonts w:ascii="${fontName}" w:hAnsi="${fontName}"/><w:sz w:val="${fontSize}"/></w:rPr><w:t>${escapedLine}</w:t></w:r>`;
        }
        
        if (i < lines.length - 1) {
            xml += `<w:r><w:br/></w:r>`;
        }
    }
    return `<w:p>${xml}</w:p>`;
}

/** Parse đệ quy mọi chuỗi JSON trong object/array (không hardcode field menu/dịch vụ). */
function deepParseJsonStrings(value) {
    if (typeof value === 'string') {
        const val = value.trim();
        if ((val.startsWith('[') && val.endsWith(']')) || (val.startsWith('{') && val.endsWith('}'))) {
            try {
                return deepParseJsonStrings(JSON.parse(val));
            } catch (e) {
                return value;
            }
        }
        return value;
    }
    if (Array.isArray(value)) {
        return value.map(item => deepParseJsonStrings(item));
    }
    if (value && typeof value === 'object') {
        const out = {};
        for (const key in value) {
            out[key] = deepParseJsonStrings(value[key]);
        }
        return out;
    }
    return value;
}

function findTemplatePath(baseDir, templateName) {
    const cleanName = templateName.replace(/\.docx?$/i, '');
    const findRecursive = (dir) => {
        const entries = fs.readdirSync(dir, { withFileTypes: true });
        for (const entry of entries) {
            const fullPath = path.join(dir, entry.name);
            if (entry.isDirectory()) {
                const found = findRecursive(fullPath);
                if (found) return found;
            } else if (entry.isFile()) {
                const entryBaseName = entry.name.replace(/\.docx?$/i, '');
                if (entryBaseName.normalize().toLowerCase() === cleanName.normalize().toLowerCase()) {
                    return fullPath;
                }
            }
        }
        return null;
    };
    return findRecursive(baseDir);
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
