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

// Setup directories
const UPLOADS_DIR = path.join(__dirname, 'uploads');
const SAMPLES_DIR = path.join(__dirname, 'samples');

[UPLOADS_DIR, SAMPLES_DIR].forEach(dir => {
    if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
});

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

let SQL_API_BASE = process.env.SQL_API_BASE || process.env.API_BASE;
const SQL_API_USER = process.env.SQL_API_USER || 'admin';

if (SQL_API_BASE) {
    console.log(`[CONFIG] Đã tải SQL_API_BASE từ biến môi trường (process.env): ${SQL_API_BASE}`);
} else {
    // Load env.js config
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
}

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

let _setupCache = null;
let _setupCacheTime = 0;
const SETUP_CACHE_TTL = 5 * 60 * 1000;

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

async function fetchSetupInfo(authToken) {
    const now = Date.now();
    if (_setupCache && (now - _setupCacheTime) < SETUP_CACHE_TTL) return _setupCache;
    try {
        const url = `${SQL_API_BASE}/api/API_LayGiaTriSetup`;
        const headers = {};
        if (authToken) headers['Authorization'] = authToken;
        const resp = await axiosGetWithRetry(url, { headers, timeout: 8000 }, 3, 1000);
        const json = resp.data;
        const rows = json.records || (Array.isArray(json) ? json : []);
        const setup = {};
        rows.forEach(r => {
            const key = r.CodeID || r.codeID || r.codeid || r.MaSetup;
            const val = r.CodeValue || r.codeValue || r.GiaTri || r.Value || '';
            if (key) setup[key] = val;
        });
        _setupCache = setup;
        _setupCacheTime = now;
        console.log('[SETUP] Keys:', Object.keys(setup).join(', '));
        return setup;
    } catch (err) {
        console.error('[SETUP] Lỗi gọi API_LayGiaTriSetup:', err.message);
        return _setupCache || {};
    }
}

async function fetchFromSQLAPI(listName, keyword, authToken, funcName = 'View', extraParams = null) {
    const payload = {
        List: listName, Func: funcName, UserName: SQL_API_USER,
        Keyword: keyword || '', Page: 1, Limit: 1,
        ...(extraParams || {})
    };
    const url = `${SQL_API_BASE}/api/API_Gateway_Router`;
    console.log(`[SQL API] Gọi: ${listName} | Func: ${funcName} | Keyword: ${keyword}`);
    console.log(`[SQL API URL] POST ${url}`);
    const headers = { 'Content-Type': 'application/json' };
    if (authToken) headers['Authorization'] = authToken;
    try {
        const resp = await axios.post(url, payload, { headers, timeout: 10000 });
        const json = resp.data;
        console.log(`[SQL API RESPONSE] ${JSON.stringify(json).substring(0, 1000)}`);
        if (json && json.records && json.records.length > 0) {
            return json.records[0];
        }
    } catch (err) {
        console.error(`[SQL API] Lỗi khi gọi ${listName} (${funcName}):`, err.message);
    }
    return null;
}

app.get('/api/documents', (req, res) => {
    try {
        res.setHeader('Cache-Control', 'no-store, no-cache, must-revalidate, private');
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

app.get('/api/documents/templates', (req, res) => {
    try {
        res.setHeader('Cache-Control', 'no-store, no-cache, must-revalidate, private');
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

app.get('/api/documents/fields/:listName', async (req, res) => {
    try {
        const listName = req.params.listName;
        let sqlListName = null;
        try {
            const formResult = await fetchFromSQLAPI('tbmk_GetForm', listName, req.headers.authorization);
            if (formResult && (formResult.FormName || formResult.formname)) {
                sqlListName = formResult.FormName || formResult.formname;
            }
        } catch (e) {
            console.log(`[FIELDS] Không lấy được FormName từ CSDL cho '${listName}':`, e.message);
        }

        if (!sqlListName) {
            return res.status(404).json({
                success: false,
                message: `Không tìm thấy biểu mẫu (FormName) tương ứng với mẫu in '${listName}' trong CSDL.`
            });
        }

        console.log(`[FIELDS] Ánh xạ file mẫu '${listName}' -> Bảng CSDL '${sqlListName}'`);

        let formFields = [];
        try {
            const fieldsUrl = `${SQL_API_BASE}/api/API_DanhSachTruongGiaoDien`;
            const payload = { FormName: sqlListName, Username: 'admin', Limit: 1000 };
            const headers = {};
            if (req.headers.authorization) headers['Authorization'] = req.headers.authorization;
            const fieldsResp = await axios.post(fieldsUrl, payload, { headers, timeout: 5000 });
            if (fieldsResp.data && fieldsResp.data.records) {
                formFields = fieldsResp.data.records.map(r => r.FieldName || r.fieldName || r.fieldname).filter(Boolean);
            }
        } catch (fieldsErr) {
            console.warn(`[FIELDS] Lỗi lấy trường từ API_DanhSachTruongGiaoDien cho '${sqlListName}':`, fieldsErr.message);
        }

        let sampleRow = {};
        try {
            const sqlRow = await fetchFromSQLAPI(sqlListName, '', req.headers.authorization);
            if (sqlRow) sampleRow = sqlRow;
        } catch (e) { }

        const setup = await fetchSetupInfo(req.headers.authorization).catch(() => ({}));

        const allFieldsSet = new Set([
            ...Object.keys(setup),
            ...formFields,
            ...Object.keys(sampleRow)
        ]);

        const excludeFields = [
            'id', 'code', 'msg', 'records', 'autoid', 'formname', 'fieldname',
            'status', 'createdby', 'createdat', 'updatedby', 'updatedat'
        ];
        const fields = Array.from(allFieldsSet).filter(f => !excludeFields.includes(f.toLowerCase()));

        const formattedFields = fields.map(f => `{${f}}`);
        res.json({ success: true, fields: formattedFields });
    } catch (error) {
        console.error('[API] Lỗi lấy danh sách biến:', error);
        res.status(500).json({ success: false, message: 'Lỗi server: ' + error.message });
    }
});

app.post('/api/documents/generate', async (req, res) => {
    try {
        let { outputFileName, templateType, customerId, rowData, sqlListName } = req.body;
        if (!templateType) return res.status(400).json({ success: false, message: 'Thiếu templateType.' });
        if (!sqlListName) return res.status(400).json({ success: false, message: 'Thiếu sqlListName để truy vấn.' });
        if (!outputFileName) outputFileName = 'Generated_' + templateType;
        outputFileName = outputFileName.replace(/[\/\\:*?"<>|()+]/g, '_').replace(/\s+/g, '_');

        const setup = await fetchSetupInfo(req.headers.authorization).catch(() => ({}));
        let dataMap = { ...setup };

        let dbRow = null;
        if (customerId) {
            try {
                // Thử lấy qua Func GetDetails trước để lấy dữ liệu chi tiết và format đầy đủ
                dbRow = await fetchFromSQLAPI(sqlListName, customerId, req.headers.authorization, 'GetDetails', { Sothaydoi: customerId });
                if (dbRow && dbRow.code !== -1 && dbRow.error === undefined) {
                    console.log('[GENERATE] ✅ Lấy dữ liệu chi tiết từ SQL API (GetDetails) thành công');
                } else {
                    dbRow = null;
                }
            } catch (e) {
                dbRow = null;
            }

            if (!dbRow) {
                try {
                    dbRow = await fetchFromSQLAPI(sqlListName, customerId, req.headers.authorization, 'View');
                    if (dbRow) {
                        console.log('[GENERATE] ✅ Lấy dữ liệu chi tiết từ SQL API (View) thành công');
                    } else {
                        console.log('[GENERATE] ❌ Lấy dữ liệu chi tiết từ SQL API (View) trả về rỗng/thất bại');
                    }
                } catch (e) {
                    console.error('[GENERATE] Lỗi SQL API (View):', e.message);
                }
            }
        }

        if (rowData && typeof rowData === 'object') {
            dataMap = { ...dataMap, ...rowData };
        }
        if (dbRow) {
            dataMap = { ...dataMap, ...dbRow };
        }

        // Tự động parse JSON từ CSDL — SQL đã trả JSON array sẵn, server không cần biết tên field
        dataMap = deepParseJsonStrings(dataMap);

        // Inject STT vào các mảng loop: nếu SQL đã cung cấp STT thì giữ nguyên, nếu không thì tự đánh idx+1
        const _injectSTT = (arr) => {
            if (!Array.isArray(arr) || arr.length === 0) return arr;
            return arr.map((item, idx) => {
                const existingSTT = item.STT !== undefined && item.STT !== null && item.STT !== '' ? item.STT : null;
                return { ...item, STT: existingSTT !== null ? existingSTT : (idx + 1) };
            });
        };
        // Áp dụng cho tất cả field là array trong dataMap
        for (const key of Object.keys(dataMap)) {
            if (Array.isArray(dataMap[key])) {
                // Tự động tiêm [{}] cho mảng rỗng để tránh bị xóa hàng bảng biểu
                if (dataMap[key].length === 0) {
                    dataMap[key] = [{}];
                }
                dataMap[key] = _injectSTT(dataMap[key]);
            }
        }



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
        const zip = new PizZip(content);

        // Chuẩn hóa đường dẫn ZIP
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

        // Tự động làm sạch tag trong Word (XML CLEANER)
        try {
            const docXmlFile = zip.file("word/document.xml");
            if (docXmlFile) {
                let xmlContent = docXmlFile.asText();
                // Bước 1: Xóa XML tags lẫn trong placeholders (Word split tags)
                xmlContent = xmlContent.replace(/\{[^{}]*?\}/g, (match) => {
                    return match.replace(/<[^>]+>/g, "");
                });

                // Bước 2: Tự động đóng unclosed loop tags {#tag} / {/tag}
                // Scan tất cả {#tag} và {/tag} để phát hiện mismatch
                const openTags = [...xmlContent.matchAll(/\{#([^}]+)\}/g)].map(m => m[1]);
                const closeTags = [...xmlContent.matchAll(/\{\/([^}]+)\}/g)].map(m => m[1]);
                const openSet = new Set(openTags);
                const closeSet = new Set(closeTags);

                // Tìm {#tag} không có {/tag} tương ứng
                for (const tag of openSet) {
                    if (!closeSet.has(tag)) {
                        console.warn(`[XML-FIX] Loop chưa đóng: {#${tag}} -> Tự động thêm {/${tag}}`);
                        // Tìm vị trí </w:p> ngay sau {#tag} và thêm paragraph đóng
                        const openMarker = `{#${tag}}`;
                        const closeMarker = `{/${tag}}`;
                        const idx = xmlContent.indexOf(openMarker);
                        if (idx >= 0) {
                            const paraEnd = xmlContent.indexOf('</w:p>', idx);
                            if (paraEnd >= 0) {
                                const insertAt = paraEnd + '</w:p>'.length;
                                const closePara = `<w:p><w:r><w:t xml:space="preserve">${closeMarker}</w:t></w:r></w:p>`;
                                xmlContent = xmlContent.substring(0, insertAt) + closePara + xmlContent.substring(insertAt);
                            }
                        }
                    }
                }

                // Tìm {/tag} không có {#tag} tương ứng
                for (const tag of closeSet) {
                    if (!openSet.has(tag)) {
                        console.warn(`[XML-FIX] Loop chưa mở: {/${tag}} -> Tự động thêm {#${tag}}`);
                        const closeMarker = `{/${tag}}`;
                        const openMarker = `{#${tag}}`;
                        const idx = xmlContent.indexOf(closeMarker);
                        if (idx >= 0) {
                            const paraStart = xmlContent.lastIndexOf('<w:p', idx);
                            if (paraStart >= 0) {
                                const openPara = `<w:p><w:r><w:t xml:space="preserve">${openMarker}</w:t></w:r></w:p>`;
                                xmlContent = xmlContent.substring(0, paraStart) + openPara + xmlContent.substring(paraStart);
                            }
                        }
                    }
                }

                // Tự động làm sạch các ngoặc đơn rỗng "()" hoặc " ()" phát sinh khi trường Ghi chú trống
                // Để làm triệt để nhất, ta sửa trực tiếp các pattern "( {GhiChu} )" hoặc similar thành dạng điều kiện {#GhiChu}({GhiChu}){/GhiChu}
                // Điều này giúp docxtemplater tự động ẩn dấu ngoặc đi nếu GhiChu rỗng
                xmlContent = xmlContent.replace(/\(\s*\{GhiChu\}\s*\)/gi, '{#GhiChu}({GhiChu}){/GhiChu}');
                xmlContent = xmlContent.replace(/\(\s*\{GhiChuPhuLuc\}\s*\)/gi, '{#GhiChuPhuLuc}({GhiChuPhuLuc}){/GhiChuPhuLuc}');

                // Tự động tiêm placeholder {STT} vào ngay sau loop mở nếu cột đầu thiếu STT
                xmlContent = xmlContent.replace(/\{#MenuTiec\}(?!\s*\{STT\})/gi, '{#MenuTiec}{STT}');
                xmlContent = xmlContent.replace(/\{#DanhSachChiPhi\}(?!\s*\{STT\})/gi, '{#DanhSachChiPhi}{STT}');

                zip.file("word/document.xml", xmlContent);
            }
        } catch (cleanErr) {
            console.warn('[GENERATE] ⚠️ Không thể làm sạch XML tags:', cleanErr.message);
        }

        const doc = new Docxtemplater(zip, {
            paragraphLoop: true,
            linebreaks: true,
            parser: function (tag) {
                return {
                    get: function (scope, context) {
                        if (tag === '.') return scope;
                        let val = undefined;
                        
                        // Duyệt động từ scope hiện tại ngược lên scope cha gốc
                        const scopeList = (context && context.scopeList) ? context.scopeList : [scope];
                        for (let i = scopeList.length - 1; i >= 0; i--) {
                            const currentScope = scopeList[i];
                            if (currentScope && typeof currentScope === 'object') {
                                if (currentScope[tag] !== undefined && currentScope[tag] !== null) {
                                    val = currentScope[tag];
                                    break;
                                } else {
                                    const cleanTag = tag.toLowerCase().replace(/_/g, '');
                                    const foundKey = Object.keys(currentScope).find(k => {
                                        const cleanKey = k.toLowerCase().replace(/_/g, '');
                                        return cleanKey === cleanTag;
                                        });
                                    if (foundKey && currentScope[foundKey] !== undefined && currentScope[foundKey] !== null) {
                                        val = currentScope[foundKey];
                                        break;
                                    }
                                }
                            }
                        }
                        
                        if (val && typeof val === 'object') {
                            return val;
                        }
                        return val === null || val === undefined ? "" : String(val);
                    }
                };
            },
            nullGetter() {
                return "";
            }
        });

        try {
            doc.render(dataMap);
            console.log('[GENERATE] ✅ Render dữ liệu vào template thành công');

            // Hậu xử lý: Dọn dẹp các ngoặc đơn rỗng "()" hoặc " ()" phát sinh sau khi render các biến rỗng
            const docZip = doc.getZip();
            if (docZip) {
                let xmlContent = docZip.file("word/document.xml").asText();
                xmlContent = xmlContent.replace(/\s*\(\s*\)/g, '');
                docZip.file("word/document.xml", xmlContent);
            }
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

        const finalFileName = `${outputFileName}_${Date.now()}.docx`;
        const outputPath = path.join(UPLOADS_DIR, finalFileName);
        fs.writeFileSync(outputPath, buf);

        // Ghi Log vào Tiec_Documents
        try {
            const fileHash = crypto.createHash('sha256').update(buf).digest('hex');
            const tiecId = dataMap.Sohopdong || dataMap.SoHopDong || dataMap.sohopdong || customerId || '';
            const userName = extractUserName(req);
            const lanTaiLieu = parseInt(dataMap.LanTaiLieu, 10) || null;
            const docType = dataMap.TemplateFile?.trim() || templateType;
            const docData = {
                TiecID: tiecId,
                DocType: docType,
                VersionNo: lanTaiLieu,
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
            const details = error.properties.errors.map(e => e.message + (e.properties && e.properties.explanation ? ': ' + e.properties.explanation : '')).join('; ');
            return res.status(500).json({ success: false, message: 'Lỗi Docxtemplater: ' + details });
        }
        res.status(500).json({ success: false, message: 'Lỗi server: ' + (error.message || 'Unknown') });
    }
});

app.delete('/api/documents/:fileName', async (req, res) => {
    try {
        const fileName = req.params.fileName;
        const filePath = path.join(UPLOADS_DIR, fileName);
        if (fs.existsSync(filePath)) {
            fs.unlinkSync(filePath);
            try {
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
                    Func: 'Edit',
                    UserName: userName,
                    JsonData: JSON.stringify({
                        FilePath: fileName,
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

app.post('/api/upload-logo', (req, res) => {
    try {
        const { base64, fileName } = req.body;
        if (!base64) return res.status(400).json({ success: false, message: 'Thiếu dữ liệu base64' });

        const matches = base64.match(/^data:([A-Za-z-+\/]+);base64,(.+)$/);
        let imageBuffer = null;
        if (matches && matches.length === 3) {
            imageBuffer = Buffer.from(matches[2], 'base64');
        } else {
            imageBuffer = Buffer.from(base64, 'base64');
        }

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
            if (!downloadUri) return respondSuccess();

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
