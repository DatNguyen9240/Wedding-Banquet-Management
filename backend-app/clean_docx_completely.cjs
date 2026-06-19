const PizZip = require('pizzip');
const fs = require('fs');

function makeXmlRegex(str) {
    return str.split('').map(c => {
        if (['+', '*', '?', '(', ')', '[', ']', '{', '}', '^', '$', '|', '\\', '.', '/'].includes(c)) return '\\' + c;
        return c;
    }).join('(?:<[^>]*>)*');
}

function replaceRegex(xml, regex, replaceStr) {
    let count = 0;
    const res = xml.replace(regex, () => { count++; return replaceStr; });
    return { xml: res, count };
}

function generateNestedTimelineTable() {
    return `<w:tbl>
        <w:tblPr>
            <w:tblW w:w="5270" w:type="dxa"/>
            <w:tblBorders>
                <w:top w:val="single" w:sz="4" w:space="0" w:color="D3D3D3"/>
                <w:left w:val="single" w:sz="4" w:space="0" w:color="D3D3D3"/>
                <w:bottom w:val="single" w:sz="4" w:space="0" w:color="D3D3D3"/>
                <w:right w:val="single" w:sz="4" w:space="0" w:color="D3D3D3"/>
                <w:insideH w:val="single" w:sz="4" w:space="0" w:color="D3D3D3"/>
                <w:insideV w:val="single" w:sz="4" w:space="0" w:color="D3D3D3"/>
            </w:tblBorders>
            <w:tblCellMar>
                <w:top w:w="60" w:type="dxa"/>
                <w:bottom w:w="60" w:type="dxa"/>
                <w:left w:w="100" w:type="dxa"/>
                <w:right w:w="100" w:type="dxa"/>
            </w:tblCellMar>
        </w:tblPr>
        <w:tblGrid>
            <w:gridCol w:w="1200"/>
            <w:gridCol w:w="1200"/>
            <w:gridCol w:w="1200"/>
            <w:gridCol w:w="1670"/>
        </w:tblGrid>
        <w:tr>
            <w:trPr><w:tblHeader/></w:trPr>
            <w:tc>
                <w:tcPr><w:tcW w:w="1200" w:type="dxa"/><w:shd w:val="clear" w:color="auto" w:fill="F1F1F1"/></w:tcPr>
                <w:p><w:pPr><w:jc w:val="center"/><w:rPr><w:b/><w:sz w:val="18"/></w:rPr></w:pPr><w:r><w:rPr><w:b/><w:sz w:val="18"/></w:rPr><w:t>BẮT ĐẦU</w:t></w:r></w:p>
            </w:tc>
            <w:tc>
                <w:tcPr><w:tcW w:w="1200" w:type="dxa"/><w:shd w:val="clear" w:color="auto" w:fill="F1F1F1"/></w:tcPr>
                <w:p><w:pPr><w:jc w:val="center"/><w:rPr><w:b/><w:sz w:val="18"/></w:rPr></w:pPr><w:r><w:rPr><w:b/><w:sz w:val="18"/></w:rPr><w:t>KẾT THÚC</w:t></w:r></w:p>
            </w:tc>
            <w:tc>
                <w:tcPr><w:tcW w:w="1200" w:type="dxa"/><w:shd w:val="clear" w:color="auto" w:fill="F1F1F1"/></w:tcPr>
                <w:p><w:pPr><w:jc w:val="center"/><w:rPr><w:b/><w:sz w:val="18"/></w:rPr></w:pPr><w:r><w:rPr><w:b/><w:sz w:val="18"/></w:rPr><w:t>VỊ TRÍ</w:t></w:r></w:p>
            </w:tc>
            <w:tc>
                <w:tcPr><w:tcW w:w="1670" w:type="dxa"/><w:shd w:val="clear" w:color="auto" w:fill="F1F1F1"/></w:tcPr>
                <w:p><w:pPr><w:jc w:val="center"/><w:rPr><w:b/><w:sz w:val="18"/></w:rPr></w:pPr><w:r><w:rPr><w:b/><w:sz w:val="18"/></w:rPr><w:t>LOẠI TIỆC / NỘI DUNG</w:t></w:r></w:p>
            </w:tc>
        </w:tr>
        <w:tr>
            <w:tc>
                <w:tcPr><w:tcW w:w="5270" w:type="dxa"/><w:gridSpan w:val="4"/><w:shd w:val="clear" w:color="auto" w:fill="E6F2FF"/></w:tcPr>
                <w:p><w:pPr><w:rPr><w:b/><w:sz w:val="18"/></w:rPr></w:pPr><w:r><w:rPr><w:b/><w:sz w:val="18"/></w:rPr><w:t>{#LichTrinh}{Ngay}</w:t></w:r></w:p>
            </w:tc>
        </w:tr>
        <w:tr>
            <w:tc>
                <w:tcPr><w:tcW w:w="1200" w:type="dxa"/></w:tcPr>
                <w:p><w:pPr><w:jc w:val="center"/><w:rPr><w:sz w:val="18"/></w:rPr></w:pPr><w:r><w:rPr><w:sz w:val="18"/></w:rPr><w:t>{#ChiTietLichTrinh}{BatDau}</w:t></w:r></w:p>
            </w:tc>
            <w:tc>
                <w:tcPr><w:tcW w:w="1200" w:type="dxa"/></w:tcPr>
                <w:p><w:pPr><w:jc w:val="center"/><w:rPr><w:sz w:val="18"/></w:rPr></w:pPr><w:r><w:rPr><w:sz w:val="18"/></w:rPr><w:t>{KetThuc}</w:t></w:r></w:p>
            </w:tc>
            <w:tc>
                <w:tcPr><w:tcW w:w="1200" w:type="dxa"/></w:tcPr>
                <w:p><w:pPr><w:jc w:val="center"/><w:rPr><w:sz w:val="18"/></w:rPr></w:pPr><w:r><w:rPr><w:sz w:val="18"/></w:rPr><w:t>{Sanh}</w:t></w:r></w:p>
            </w:tc>
            <w:tc>
                <w:tcPr><w:tcW w:w="1670" w:type="dxa"/></w:tcPr>
                <w:p><w:pPr><w:rPr><w:sz w:val="18"/></w:rPr></w:pPr><w:r><w:rPr><w:sz w:val="18"/></w:rPr><w:t>{NoiDung}{/ChiTietLichTrinh}</w:t></w:r></w:p>
            </w:tc>
        </w:tr>
        <w:tr>
            <w:tc>
                <w:tcPr><w:tcW w:w="5270" w:type="dxa"/><w:gridSpan w:val="4"/></w:tcPr>
                <w:p><w:r><w:t>{/LichTrinh}</w:t></w:r></w:p>
            </w:tc>
        </w:tr>
    </w:tbl>`;
}

function cleanHoiNghi(xml) {
    let mods = 0;
    let res;

    // First replace the welcome board text to {NoiDungBangChao} before replacing other substrings
    xml = xml.replace(new RegExp(makeXmlRegex('HỘI NGHỊ KHÁCH HÀNG 2026 - KHU VỰC MIỀN NAM'), 'g'), '{NoiDungBangChao}');

    // Split the timeline table and setup table into two separate tables
    const tbls = xml.split('<w:tbl>');
    const regexChinhThuc = new RegExp(makeXmlRegex('CHÍNH THỨC'), 'i');
    let targetTblIdx = -1;
    for (let i = 1; i < tbls.length; i++) {
        const tblContent = tbls[i].split('</w:tbl>')[0];
        if (regexChinhThuc.test(tblContent)) {
            targetTblIdx = i;
            const prMatch = tblContent.match(/^([\s\S]*?<w:tblGrid>[\s\S]*?<\/w:tblGrid>)/);
            if (prMatch) {
                const tblPrAndGrid = prMatch[1];
                const trRegex = new RegExp(`(<w:tr(?:[\\s>][^>]*)?>(?:(?!<w:tr[\\s>])[\\s\\S])*?${makeXmlRegex('CHÍNH THỨC')}(?:(?!<\\/w:tr>)[\\s\\S])*?<\\/w:tr>)`, 'i');
                const trMatch = tblContent.match(trRegex);
                if (trMatch) {
                    const trXml = trMatch[1];
                    const splitReplacement = `</w:tbl><w:p><w:pPr><w:pStyle w:val="Normal"/></w:pPr></w:p><w:tbl>${tblPrAndGrid}${trXml}`;
                    tbls[i] = tbls[i].replace(trXml, splitReplacement);
                    break;
                }
            }
        }
    }
    xml = tbls.join('<w:tbl>');

    // Inject nested timeline table into Row 10 and remove Rows 11-17
    const newTbls = xml.split('<w:tbl>');
    if (targetTblIdx !== -1 && targetTblIdx < newTbls.length) {
        let firstTblContent = newTbls[targetTblIdx].split('</w:tbl>')[0];
        const trs = firstTblContent.split('<w:tr>');
        
        if (trs.length > 17) {
            const newRow10 = `<w:tc>
    <w:tcPr>
        <w:tcW w:w="900" w:type="dxa"/>
        <w:shd w:val="clear" w:color="auto" w:fill="F1F1F1"/>
    </w:tcPr>
    <w:p>
        <w:pPr>
            <w:pStyle w:val="TableParagraph"/>
            <w:rPr><w:b/><w:sz w:val="20"/></w:rPr>
        </w:pPr>
        <w:r>
            <w:rPr><w:b/><w:sz w:val="20"/></w:rPr>
            <w:t>DỊCH VỤ ƯU ĐÃI</w:t>
        </w:r>
    </w:p>
</w:tc>
<w:tc>
    <w:tcPr>
        <w:tcW w:w="2875" w:type="dxa"/>
        <w:gridSpan w:val="4"/>
    </w:tcPr>
    <w:p>
        <w:r>
            <w:rPr><w:sz w:val="20"/></w:rPr>
            <w:t>{DichVuKhuyenMai}</w:t>
        </w:r>
    </w:p>
</w:tc>
<w:tc>
    <w:tcPr>
        <w:tcW w:w="5270" w:type="dxa"/>
        <w:gridSpan w:val="5"/>
    </w:tcPr>
    ${generateNestedTimelineTable()}
    <w:p/>
</w:tc>
</w:tr>`;

            const newTrs = trs.slice(0, 10);
            newTrs.push(newRow10);

            const updatedFirstTblContent = newTrs.join('<w:tr>');
            const restOfTbl = newTbls[targetTblIdx].substring(firstTblContent.length);
            newTbls[targetTblIdx] = updatedFirstTblContent + restOfTbl;
        }
    }
    xml = newTbls.join('<w:tbl>');

    // Make the setup table dynamic by duplicating rows using {#DanhSachSanh}
    const regexSetup = /<w:tr>(?:(?!<w:tr>)[\s\S])*?120(?:<[^>]*>)*\s*(?:<[^>]*>)*K(?:<[^>]*>)*h(?:<[^>]*>)*á(?:<[^>]*>)*c(?:<[^>]*>)*h(?:(?!<w:tr>)[\s\S])*?<\/w:tr>\s*<w:tr>(?:(?!<w:tr>)[\s\S])*?11(?:<[^>]*>)*\s*(?:<[^>]*>)*B(?:<[^>]*>)*à(?:<[^>]*>)*n(?:(?!<w:tr>)[\s\S])*?<\/w:tr>/i;
    xml = xml.replace(regexSetup, (matchedBlock) => {
        let row19 = matchedBlock.match(/<w:tr>[\s\S]*?<\/w:tr>/i)[0];
        row19 = row19.replace(/120(?:<[^>]*>)*\s*(?:<[^>]*>)*K(?:<[^>]*>)*h(?:<[^>]*>)*á(?:<[^>]*>)*c(?:<[^>]*>)*h/i, '{#DanhSachSanh}{SoKhachChinhThuc}');
        row19 = row19.replace(/<w:t>0<\/w:t>/, '<w:t>{SoBanDuPhong}</w:t>');
        row19 = row19.replace(/Q(?:<[^>]*>)*u(?:<[^>]*>)*e(?:<[^>]*>)*e(?:<[^>]*>)*n(?:<[^>]*>)* (?:<[^>]*>)*1/i, '{SanhDat}');
        
        row19 = row19.replace(/(<w:tc(?:[\s>][^>]*)?>(?:(?!<w:tc(?:[\s>][^>]*)?>)[\s\S])*?<w:t>Bố(?:(?!<\/w:tc>)[\s\S])*?<\/w:tc>)/i, 
            '<w:tc><w:tcPr><w:tcW w:w="2736" w:type="dxa"/><w:gridSpan w:val="2"/></w:tcPr><w:p><w:pPr><w:pStyle w:val="TableParagraph"/><w:ind w:left="18"/><w:rPr><w:b/><w:sz w:val="10"/></w:rPr></w:pPr><w:r><w:rPr><w:b/><w:sz w:val="10"/></w:rPr><w:t>{KieuSetup}{/DanhSachSanh}</w:t></w:r></w:p></w:tc>');
        return row19;
    });

    const reps = [
        { search: 'Nhựt Thủy', replace: '{BenANhanVienPhuTrach}' },
        { search: '44/CTY-HHKH/2026', replace: '{Sohopdong}' },
        { search: '08/05/2026', replace: '{NgayHopDong}' },
        { search: 'Ngày ra BEO: 13/05/2026', replace: 'Ngày ra BEO: {NgayRaBEO}' },
        { search: 'Ngày 13/05/2026', replace: 'Ngày {Dot1Ngay}' },
        { search: 'CÔNG TY TNHH MAKITA VIỆT NAM', replace: '{TenCongTy}' },
        { search: 'ĐƠN VỊ', replace: 'TÊN CÔNG TY' },
        { search: '18/05/2026', replace: '{NgayToChuc}' },
        { search: 'HỘI NGHỊ + TIỆC TỐI', replace: '{LoaiHinhSuKien}' },
        { search: 'Hội Nghị {SanhDat} + Tiệc tối {SanhDat2}', replace: '{LoaiHinhSuKien}' },
        { search: 'Khách hàng thường niên', replace: '{TieuSuKhachHang}' },
        { search: '17/05/2026', replace: '{NgaySetup}' },
        { search: '19/05/2026', replace: '{NgayOut}' },
        { search: '19/05', replace: '{NgayOutShort}' },
        { search: '89.675.555 VNĐ', replace: '{Dot1SoTien}' },
        { search: 'Thanh toán sau tiệc 07 ngày', replace: '{DotCuoiGhiChu}' },
        { search: 'bàn số 13', replace: 'bàn số {SobanTang}' },
        { search: 'PHIẾU ĐẶT TIỆC', replace: '{TieuDePhieu}' },
    ];

    for (const r of reps) {
        res = replaceRegex(xml, new RegExp(makeXmlRegex(r.search), 'g'), r.replace);
        xml = res.xml; mods += res.count;
    }



    if (!xml.includes('{BenASDTNhanVien}')) {
        res = replaceRegex(xml, new RegExp(makeXmlRegex('Tel:'), 'g'), 'Tel: {BenASDTNhanVien}');
        xml = res.xml; mods += res.count;
    }

    res = replaceRegex(xml, /\{#ThucDon\}(?:<[^>]*>)*\{TenMonAn\}(?:<[^>]*>)*\{\/ThucDon\}/g, '{ThucDon}');
    xml = res.xml; mods += res.count;

    res = replaceRegex(xml, /\{#DichVuTinhPhi\}(?:<[^>]*>)*\{TenDichVu\}(?:<[^>]*>)*:(?:<[^>]*>)* (?:<[^>]*>)*\{ThanhTien\}(?:<[^>]*>)*\{\/DichVuTinhPhi\}/g, '{DichVuTinhPhi}');
    xml = res.xml; mods += res.count;

    res = replaceRegex(xml, new RegExp(makeXmlRegex('{LuuY}'), 'g'), '{@LuuY}');
    xml = res.xml; mods += res.count;
    res = replaceRegex(xml, new RegExp(makeXmlRegex('{DichVuTinhPhi}'), 'g'), '{@DichVuTinhPhi}');
    xml = res.xml; mods += res.count;

    res = replaceRegex(xml, new RegExp(makeXmlRegex('{NoteKyThuat}'), 'g'), '{@NoteKyThuat}');
    xml = res.xml; mods += res.count;
    res = replaceRegex(xml, new RegExp(makeXmlRegex('{NoteBaoVe}'), 'g'), '{@NoteBaoVe}');
    xml = res.xml; mods += res.count;
    res = replaceRegex(xml, new RegExp(makeXmlRegex('{NoteBieuNgu}'), 'g'), '{@NoteBieuNgu}');
    xml = res.xml; mods += res.count;
    res = replaceRegex(xml, new RegExp(makeXmlRegex('{NoteLobby}'), 'g'), '{@NoteLobby}');
    xml = res.xml; mods += res.count;
    res = replaceRegex(xml, new RegExp(makeXmlRegex('{ThongTinSetup}'), 'g'), '{@ThongTinSetup}');
    xml = res.xml; mods += res.count;

    // Clean remaining Queen 1 and Queen 5 to SanhDat and SanhDat2 globally
    res = replaceRegex(xml, /Q(?:<[^>]*>)*u(?:<[^>]*>)*e(?:<[^>]*>)*e(?:<[^>]*>)*n(?:<[^>]*>)* (?:<[^>]*>)*1/g, '{SanhDat}');
    xml = res.xml; mods += res.count;
    res = replaceRegex(xml, /Q(?:<[^>]*>)*u(?:<[^>]*>)*e(?:<[^>]*>)*e(?:<[^>]*>)*n(?:<[^>]*>)* (?:<[^>]*>)*5/g, '{SanhDat2}');
    xml = res.xml; mods += res.count;

    xml = xml.replace(/<w:tc[^>]*>[\s\S]*?<\/w:tc>/g, (cellXml) => {
        // LOBBY cell
        if (cellXml.match(/đ(?:<[^>]*>)*ó(?:<[^>]*>)*n(?:(?!<\/w:tc>)[\s\S])*?k(?:<[^>]*>)*h(?:<[^>]*>)*á(?:<[^>]*>)*c(?:<[^>]*>)*h/i) && cellXml.includes('SanhDat')) {
            return cellXml.replace(/(<w:tc[^>]*>[\s\S]*?<w:tcPr>[\s\S]*?<\/w:tcPr>)[\s\S]*?(<\/w:tc>)/, '$1<w:p><w:r><w:t>{@NoteLobby}</w:t></w:r></w:p>$2');
        }
        // PHƯƠNG THỨC THANH TOÁN cell
        if (cellXml.includes('{Dot1_SoTien}') || cellXml.includes('LichTrinhThanhToan')) {
            return cellXml.replace(/(<w:tc[^>]*>[\s\S]*?<w:tcPr>[\s\S]*?<\/w:tcPr>)[\s\S]*?(<\/w:tc>)/, 
                '$1' +
                '<w:p><w:r><w:rPr><w:b/><w:sz w:val="20"/></w:rPr><w:t>Phương thức thanh toán:</w:t></w:r></w:p>' +
                '<w:p><w:r><w:t>{#LichTrinhThanhToan}</w:t></w:r></w:p>' +
                '<w:p>' +
                '<w:r><w:rPr><w:b/><w:sz w:val="20"/></w:rPr><w:t>Lần {STT}: </w:t></w:r>' +
                '<w:r><w:rPr><w:sz w:val="20"/></w:rPr><w:t>{SoTien} - {NoiDung}</w:t></w:r>' +
                '</w:p>' +
                '<w:p><w:r><w:t>{/LichTrinhThanhToan}</w:t></w:r></w:p>' +
                '$2'
            );
        }
        // BẢO VỆ cell
        if (cellXml.match(/Danh(?:<[^>]*>)* (?:<[^>]*>)*s(?:<[^>]*>)*á(?:<[^>]*>)*c(?:<[^>]*>)*h(?:(?!<\/w:tc>)[\s\S])*?ra(?:<[^>]*>)* (?:<[^>]*>)*h(?:<[^>]*>)*à(?:<[^>]*>)*n(?:<[^>]*>)*g/i)) {
            return cellXml.replace(/(<w:tc[^>]*>[\s\S]*?<w:tcPr>[\s\S]*?<\/w:tcPr>)[\s\S]*?(<\/w:tc>)/, '$1<w:p><w:r><w:t>{@NoteBaoVe}</w:t></w:r></w:p>$2');
        }
        // KỸ THUẬT / TRANG TRÍ cell
        if (cellXml.match(/c(?:<[^>]*>)*ổ(?:<[^>]*>)*n(?:<[^>]*>)*g(?:(?!<\/w:tc>)[\s\S])*?B(?:<[^>]*>)*a(?:<[^>]*>)*c(?:<[^>]*>)*k/i) || cellXml.includes('banner')) {
            return cellXml.replace(/(<w:tc[^>]*>[\s\S]*?<w:tcPr>[\s\S]*?<\/w:tcPr>)[\s\S]*?(<\/w:tc>)/, '$1<w:p><w:r><w:t>{@NoteKyThuat}</w:t></w:r></w:p>$2');
        }
        // BIỂU NGỮ SÂN KHẤU cell
        if (cellXml.match(/P(?:<[^>]*>)*h(?:<[^>]*>)*ố(?:<[^>]*>)*i(?:(?!<\/w:tc>)[\s\S])*?k(?:<[^>]*>)*h(?:<[^>]*>)*á(?:<[^>]*>)*c(?:<[^>]*>)*h/i)) {
            return cellXml.replace(/(<w:tc[^>]*>[\s\S]*?<w:tcPr>[\s\S]*?<\/w:tcPr>)[\s\S]*?(<\/w:tc>)/, '$1<w:p><w:r><w:t>{@NoteBieuNgu}</w:t></w:r></w:p>$2');
        }
        // SẮP XẾP cell
        if (cellXml.match(/P(?:<[^>]*>)*h(?:<[^>]*>)*í(?:<[^>]*>)*a(?:<[^>]*>)* (?:<[^>]*>)*F(?:<[^>]*>)*n(?:<[^>]*>)*B(?:<[^>]*>)*:/i)) {
            return cellXml.replace(/(<w:tc[^>]*>[\s\S]*?<w:tcPr>[\s\S]*?<\/w:tcPr>)[\s\S]*?(<\/w:tc>)/, '$1<w:p><w:r><w:t>{@ThongTinSetup}</w:t></w:r></w:p>$2');
        }
        // LƯU Ý cell
        if (cellXml.match(/P(?:<[^>]*>)*h(?:<[^>]*>)*í(?:<[^>]*>)* (?:<[^>]*>)*p(?:<[^>]*>)*h(?:<[^>]*>)*á(?:<[^>]*>)*t(?:<[^>]*>)* (?:<[^>]*>)*s(?:<[^>]*>)*i(?:<[^>]*>)*n(?:<[^>]*>)*h(?:<[^>]*>)* (?:<[^>]*>)*g(?:<[^>]*>)*h(?:<[^>]*>)*ế/i)) {
            return cellXml.replace(/(<w:tc[^>]*>[\s\S]*?<w:tcPr>[\s\S]*?<\/w:tcPr>)[\s\S]*?(<\/w:tc>)/, '$1<w:p><w:r><w:t>{@LuuY}</w:t></w:r></w:p>$2');
        }
        // THỰC ĐƠN cell
        if (cellXml.match(/X(?:<[^>]*>)*à(?:<[^>]*>)* (?:<[^>]*>)*L(?:<[^>]*>)*á(?:<[^>]*>)*c(?:<[^>]*>)*h(?:<[^>]*>)* (?:<[^>]*>)*T(?:<[^>]*>)*ô(?:<[^>]*>)*m/i)) {
            return cellXml.replace(/(<w:tc[^>]*>[\s\S]*?<w:tcPr>[\s\S]*?<\/w:tcPr>)[\s\S]*?(<\/w:tc>)/, 
                '$1' +
                '<w:p><w:r><w:t>{#DanhSachMenu}</w:t></w:r></w:p>' +
                '<w:p><w:pPr><w:pStyle w:val="TableParagraph"/></w:pPr><w:r><w:rPr><w:b/><w:sz w:val="10"/></w:rPr><w:t>THỰC ĐƠN: {TenMenu}</w:t></w:r></w:p>' +
                '<w:p><w:r><w:t>{#DanhSachMon}</w:t></w:r></w:p>' +
                '<w:p><w:pPr><w:pStyle w:val="TableParagraph"/></w:pPr><w:r><w:rPr><w:sz w:val="10"/></w:rPr><w:t>{STT}. {TenMon}</w:t></w:r></w:p>' +
                '<w:p><w:r><w:t>{/DanhSachMon}</w:t></w:r></w:p>' +
                '<w:p><w:pPr><w:pStyle w:val="TableParagraph"/></w:pPr><w:r><w:rPr><w:b/><w:i/><w:sz w:val="10"/></w:rPr><w:t>{GhiChuMenu}</w:t></w:r></w:p>' +
                '<w:p><w:r><w:t>{/DanhSachMenu}</w:t></w:r></w:p>' +
                '$2'
            );
        }
        // DỊCH VỤ TÍNH PHÍ cell
        if (cellXml.match(/P(?:<[^>]*>)*h(?:<[^>]*>)*í(?:<[^>]*>)* (?:<[^>]*>)*s(?:<[^>]*>)*e(?:<[^>]*>)*t(?:<[^>]*>)*u(?:<[^>]*>)*p/i)) {
            return cellXml.replace(/(<w:tc[^>]*>[\s\S]*?<w:tcPr>[\s\S]*?<\/w:tcPr>)[\s\S]*?(<\/w:tc>)/, '$1<w:p><w:r><w:t>{DichVuTinhPhi}</w:t></w:r></w:p>$2');
        }
        // THỨC UỐNG cell
        if (cellXml.match(/T(?:<[^>]*>)*H(?:<[^>]*>)*Ứ(?:<[^>]*>)*C(?:<[^>]*>)* (?:<[^>]*>)*U(?:<[^>]*>)*Ố(?:<[^>]*>)*N(?:<[^>]*>)*G/i) || cellXml.includes('Aquafina')) {
            return cellXml.replace(/(<w:tc[^>]*>[\s\S]*?<w:tcPr>[\s\S]*?<\/w:tcPr>)[\s\S]*?(<\/w:tc>)/, 
                '$1' +
                '<w:p><w:r><w:t>{#DanhSachThucUong}</w:t></w:r></w:p>' +
                '<w:p><w:pPr><w:pStyle w:val="TableParagraph"/></w:pPr><w:r><w:rPr><w:b/><w:sz w:val="10"/></w:rPr><w:t>THỨC UỐNG: {TenThucUong}</w:t></w:r></w:p>' +
                '<w:p><w:r><w:t>{#DanhSachMonUong}</w:t></w:r></w:p>' +
                '<w:p><w:pPr><w:pStyle w:val="TableParagraph"/></w:pPr><w:r><w:rPr><w:sz w:val="10"/></w:rPr><w:t>{STT}. {TenMonUong}</w:t></w:r></w:p>' +
                '<w:p><w:r><w:t>{/DanhSachMonUong}</w:t></w:r></w:p>' +
                '<w:p><w:pPr><w:pStyle w:val="TableParagraph"/></w:pPr><w:r><w:rPr><w:b/><w:i/><w:sz w:val="10"/></w:rPr><w:t>{GhiChuThucUong}</w:t></w:r></w:p>' +
                '<w:p><w:r><w:t>{/DanhSachThucUong}</w:t></w:r></w:p>' +
                '$2'
            );
        }
        return cellXml;
    });


    // Split merged signature cell under T.PKD and NVKD
    xml = xml.replace(
        '<w:tc><w:tcPr><w:tcW w:w="5270" w:type="dxa"/><w:gridSpan w:val="5"/></w:tcPr><w:p><w:pPr><w:pStyle w:val="TableParagraph"/><w:rPr><w:sz w:val="10"/></w:rPr></w:pPr></w:p></w:tc>',
        '<w:tc><w:tcPr><w:tcW w:w="2534" w:type="dxa"/><w:gridSpan w:val="3"/><w:tcBorders><w:left w:val="single" w:sz="4" w:space="0" w:color="000000"/><w:right w:val="single" w:sz="4" w:space="0" w:color="000000"/></w:tcBorders></w:tcPr><w:p><w:pPr><w:pStyle w:val="TableParagraph"/><w:rPr><w:sz w:val="10"/></w:rPr></w:pPr></w:p></w:tc><w:tc><w:tcPr><w:tcW w:w="2736" w:type="dxa"/><w:gridSpan w:val="2"/><w:tcBorders><w:left w:val="single" w:sz="4" w:space="0" w:color="000000"/><w:right w:val="single" w:sz="4" w:space="0" w:color="000000"/></w:tcBorders></w:tcPr><w:p><w:pPr><w:pStyle w:val="TableParagraph"/><w:rPr><w:sz w:val="10"/></w:rPr></w:pPr></w:p></w:tc>'
    );

    return xml;
}

function cleanTiecCuoi(xml) {
    let mods = 0;
    let res;

    const reps = [
        { search: 'Mộng Tuyền', replace: '{BenANhanVienPhuTrach}' },
        { search: 'Tel: : 0392 001 803', replace: 'Tel: {BenASDTNhanVien}' },
        { search: '01/11-HHKH2025', replace: '{Sohopdong}' },
        { search: '01/11/2025', replace: '{NgayHopDong}' },
        { search: '12/04/2026', replace: '{NgayRaBEO}' },
        { search: 'NGUYỄN PHƯƠNG DUY', replace: '{Tenchure}' },
        { search: 'NGUYỄN HỒ THU PHƯỢNG', replace: '{Tencodau}' },
        { search: '06.06.2026', replace: '{NgayToChuc}' },
        { search: '21/08/11 Lê Công Phép, P. An Lạc, TPHCM', replace: '{BenBDiaChi}' },
        { search: '0937 260 013', replace: '{Sdtchure}' },
        { search: '0398 401 671', replace: '{Sdtcodau}' },
        { search: 'Fanpage', replace: '{DoiTuongKhach}' },
        { search: '36 bàn mặn / 10 khách', replace: '{SobanManchinhthuc} bàn mặn / 10 khách' },
        { search: '02 bàn/ 10 khách', replace: '{SobanManduphong} bàn/ 10 khách' },
        { search: 'Ghế trắng - Nơ hồng', replace: '{SetupNoGhe}' },
        { search: 'Lần 1: 10.000.000 VNĐ - CK', replace: 'Lần 1: {Dot1SoTien} VNĐ - {Dot1HinhThuc}' },
        { search: 'Lần 2: 100.000.000 VNĐ - CK', replace: 'Lần 2: {Dot2SoTien} VNĐ - {Dot2HinhThuc}' },
        { search: 'Thanh toán cuối tiệc.', replace: '{DotCuoiGhiChu}' },
        { search: 'LỄ THÀNH HÔN', replace: '{TenLe}' },
        { search: 'PHƯƠNG DUY - THU PHƯỢNG', replace: '{BieuNguCR} - {BieuNguCD}' },
        { search: '17h00', replace: '{GioBatDau}' },
        { search: '22h00', replace: '{GioKetThuc}' },
        { search: 'QUEEN 02+03', replace: '{SanhDat}' },
        { search: '(36 bàn)', replace: '({SobanManchinhthuc} bàn)' },
        { search: 'PHIẾU ĐẶT TIỆC', replace: '{TieuDePhieu}' },
    ];

    for (const r of reps) {
        res = replaceRegex(xml, new RegExp(makeXmlRegex(r.search), 'g'), r.replace);
        xml = res.xml; mods += res.count;
    }

    xml = xml.replace(new RegExp(makeXmlRegex('{#ThucDon}{STT}/ {TenMonAn}{/ThucDon}'), 'g'), '{ThucDon}');
    xml = xml.replace(/\{#ThucDon\}/g, '');
    xml = xml.replace(/\{\/ThucDon\}/g, '');

    xml = xml.replace(new RegExp(makeXmlRegex('{#DichVuTinhPhi}{TenDichVu}: {ThanhTien}{/DichVuTinhPhi}'), 'g'), '{DichVuTinhPhi}');
    xml = xml.replace(/\{#DichVuTinhPhi\}/g, '');
    xml = xml.replace(/\{\/DichVuTinhPhi\}/g, '');

    res = replaceRegex(xml, new RegExp(makeXmlRegex('{LuuY}'), 'g'), '{@LuuY}');
    xml = res.xml; mods += res.count;
    res = replaceRegex(xml, new RegExp(makeXmlRegex('{DichVuTinhPhi}'), 'g'), '{@DichVuTinhPhi}');
    xml = res.xml; mods += res.count;

    // Safe cell replacements in Tiệc Cưới
    xml = xml.replace(/<w:tc[^>]*>[\s\S]*?<\/w:tc>/g, (cellXml) => {
        // PHƯƠNG THỨC THANH TOÁN cell
        if (cellXml.includes('{Dot1_SoTien}') || cellXml.includes('LichTrinhThanhToan')) {
            return cellXml.replace(/(<w:tc[^>]*>[\s\S]*?<w:tcPr>[\s\S]*?<\/w:tcPr>)[\s\S]*?(<\/w:tc>)/, 
                '$1' +
                '<w:p><w:r><w:rPr><w:b/><w:sz w:val="20"/></w:rPr><w:t>Phương thức thanh toán:</w:t></w:r></w:p>' +
                '<w:p><w:r><w:t>{#LichTrinhThanhToan}</w:t></w:r></w:p>' +
                '<w:p>' +
                '<w:r><w:rPr><w:b/><w:sz w:val="20"/></w:rPr><w:t>Lần {STT}: </w:t></w:r>' +
                '<w:r><w:rPr><w:sz w:val="20"/></w:rPr><w:t>{SoTien} - {NoiDung}</w:t></w:r>' +
                '</w:p>' +
                '<w:p><w:r><w:t>{/LichTrinhThanhToan}</w:t></w:r></w:p>' +
                '$2'
            );
        }
        // DỊCH VỤ KHUYẾN MÃI cell
        if (cellXml.match(/T(?:<[^>]*>)*r(?:<[^>]*>)*a(?:<[^>]*>)*n(?:<[^>]*>)*g(?:<[^>]*>)* (?:<[^>]*>)*t(?:<[^>]*>)*r(?:<[^>]*>)*í(?:<[^>]*>)* (?:<[^>]*>)*s(?:<[^>]*>)*ả(?:<[^>]*>)*n(?:<[^>]*>)*h/i)) {
            return cellXml.replace(/(<w:tc[^>]*>[\s\S]*?<w:tcPr>[\s\S]*?<\/w:tcPr>)[\s\S]*?(<\/w:tc>)/, '$1<w:p><w:r><w:t>{DichVuKhuyenMai}</w:t></w:r></w:p>$2');
        }
        // THỰC ĐƠN cell
        if (cellXml.match(/Ă(?:<[^>]*>)*n(?:<[^>]*>)* (?:<[^>]*>)*n(?:<[^>]*>)*h(?:<[^>]*>)*ẹ(?:<[^>]*>)* (?:<[^>]*>)*c(?:<[^>]*>)*h(?:<[^>]*>)*o(?:<[^>]*>)* (?:<[^>]*>)*b(?:<[^>]*>)*ố/i)) {
            return cellXml.replace(/(<w:tc[^>]*>[\s\S]*?<w:tcPr>[\s\S]*?<\/w:tcPr>)[\s\S]*?(<\/w:tc>)/, 
                '$1' +
                '<w:p><w:pPr><w:pStyle w:val="TableParagraph"/></w:pPr><w:r><w:rPr><w:sz w:val="10"/></w:rPr><w:t>{AnNheTruocTiec} Bánh mặn : {BanhManDauGio}</w:t></w:r></w:p>' +
                '<w:p><w:r><w:t>{#DanhSachMenu}</w:t></w:r></w:p>' +
                '<w:p><w:pPr><w:pStyle w:val="TableParagraph"/></w:pPr><w:r><w:rPr><w:b/><w:sz w:val="10"/></w:rPr><w:t>THỰC ĐƠN: {TenMenu}</w:t></w:r></w:p>' +
                '<w:p><w:r><w:t>{#DanhSachMon}</w:t></w:r></w:p>' +
                '<w:p><w:pPr><w:pStyle w:val="TableParagraph"/></w:pPr><w:r><w:rPr><w:sz w:val="10"/></w:rPr><w:t>{STT}. {TenMon}</w:t></w:r></w:p>' +
                '<w:p><w:r><w:t>{/DanhSachMon}</w:t></w:r></w:p>' +
                '<w:p><w:pPr><w:pStyle w:val="TableParagraph"/></w:pPr><w:r><w:rPr><w:b/><w:i/><w:sz w:val="10"/></w:rPr><w:t>{GhiChuMenu}</w:t></w:r></w:p>' +
                '<w:p><w:r><w:t>{/DanhSachMenu}</w:t></w:r></w:p>' +
                '$2'
            );
        }
        // DỊCH VỤ TÍNH PHÍ / LƯU Ý cell
        if (cellXml.match(/C(?:<[^>]*>)*á(?:<[^>]*>)*c(?:<[^>]*>)*h(?:<[^>]*>)* (?:<[^>]*>)*t(?:<[^>]*>)*í(?:<[^>]*>)*n(?:<[^>]*>)*h(?:<[^>]*>)* (?:<[^>]*>)*b(?:<[^>]*>)*à(?:<[^>]*>)*n/i)) {
            return cellXml.replace(/(<w:tc[^>]*>[\s\S]*?<w:tcPr>[\s\S]*?<\/w:tcPr>)[\s\S]*?(<\/w:tc>)/, '$1<w:p><w:r><w:t>{@DichVuTinhPhi}</w:t></w:r></w:p><w:p><w:r><w:t>{@LuuY}</w:t></w:r></w:p>$2');
        }
        // THỨC UỐNG cell
        const isThucUong = cellXml.match(/T(?:<[^>]*>)*H(?:<[^>]*>)*Ứ(?:<[^>]*>)*C(?:<[^>]*>)* (?:<[^>]*>)*U(?:<[^>]*>)*Ố(?:<[^>]*>)*N(?:<[^>]*>)*G/i)
            || cellXml.match(/s(?:<[^>]*>)*u(?:<[^>]*>)*ố(?:<[^>]*>)*t(?:<[^>]*>)*(?:(?:(?!<\/w:tc>)[\s\S])*?)t(?:<[^>]*>)*i(?:<[^>]*>)*ệ(?:<[^>]*>)*c/i)
            || cellXml.match(/T(?:<[^>]*>)*i(?:<[^>]*>)*g(?:<[^>]*>)*e(?:<[^>]*>)*r/i);
        if (isThucUong) {
            return cellXml.replace(/(<w:tc[^>]*>[\s\S]*?<w:tcPr>[\s\S]*?<\/w:tcPr>)[\s\S]*?(<\/w:tc>)/, 
                '$1' +
                '<w:p><w:r><w:t>{#DanhSachThucUong}</w:t></w:r></w:p>' +
                '<w:p><w:pPr><w:pStyle w:val="TableParagraph"/></w:pPr><w:r><w:rPr><w:b/><w:sz w:val="10"/></w:rPr><w:t>THỨC UỐNG: {TenThucUong}</w:t></w:r></w:p>' +
                '<w:p><w:r><w:t>{#DanhSachMonUong}</w:t></w:r></w:p>' +
                '<w:p><w:pPr><w:pStyle w:val="TableParagraph"/></w:pPr><w:r><w:rPr><w:sz w:val="10"/></w:rPr><w:t>{STT}. {TenMonUong}</w:t></w:r></w:p>' +
                '<w:p><w:r><w:t>{/DanhSachMonUong}</w:t></w:r></w:p>' +
                '<w:p><w:pPr><w:pStyle w:val="TableParagraph"/></w:pPr><w:r><w:rPr><w:b/><w:i/><w:sz w:val="10"/></w:rPr><w:t>{GhiChuThucUong}</w:t></w:r></w:p>' +
                '<w:p><w:r><w:t>{/DanhSachThucUong}</w:t></w:r></w:p>' +
                '$2'
            );
        }
        return cellXml;
    });


    return xml;
}

function process(file, cleanFn) {
    console.log(`\nCleaning ${file}...`);
    try {
        const content = fs.readFileSync(file, 'binary');
        const zip = new PizZip(content);
        
        // Normalize zip entries for Windows backslashes
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

        let xml = zip.file('word/document.xml').asText();
        
        xml = cleanFn(xml);
        
        xml = xml.replace(/\{\{([^}]+)\}\}/g, '{$1}');

        zip.file('word/document.xml', xml);
        const buf = zip.generate({type: 'nodebuffer', compression: 'DEFLATE'});
        
        try {
            fs.writeFileSync(file, buf);
            console.log(`Successfully cleaned and saved ${file}`);
        } catch (err) {
            console.error(`ERROR: Cannot write to ${file}: ${err.message}`);
        }
    } catch (e) {
        console.error(`Failed to process ${file}: ${e.message}`);
    }
}

function insertLabelsFirst() {
    const file = './samples/BEO_Hoi_Nghi.docx';
    try {
        const content = fs.readFileSync(file, 'binary');
        const zip = new PizZip(content);
        
        // Normalize zip entries for Windows backslashes
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

        let xml = zip.file('word/document.xml').asText();

        function insertAfterLabel(xml, labelStr, insertText) {
            const searchChars = labelStr.split('');
            const regexStr = searchChars.map(c => {
                if (['+', '*', '?', '(', ')', '[', ']', '{', '}', '^', '$', '|', '\\', '.', '/'].includes(c)) return '\\' + c;
                return c;
            }).join('(?:<[^>]*>)*');
            const regex = new RegExp(`(${regexStr}[\\s\\S]*?<\\/w:tc>\\s*<w:tc>[\\s\\S]*?<w:p[^>]*>)`, 'i');
            if (xml.match(regex)) {
                const checkRegex = new RegExp(`${regexStr}[\\s\\S]*?<\\/w:tc>\\s*<w:tc>[\\s\\S]*?${insertText.replace(/\{/g, '\\{').replace(/\}/g, '\\}')}`, 'i');
                if (!xml.match(checkRegex)) {
                    return xml.replace(regex, `$1<w:r><w:t>${insertText}</w:t></w:r>`);
                }
            }
            return xml;
        }

        xml = insertAfterLabel(xml, 'ĐƠN VỊ THI CÔNG', '{DonViThiCong}');
        xml = insertAfterLabel(xml, 'NGƯỜI GIAO DỊCH', '{NguoiGiaoDich}');
        xml = insertAfterLabel(xml, 'ĐỊA CHỈ', '{BenBDiaChi}');
        xml = insertAfterLabel(xml, 'ĐIỆN THOẠI', '{BenBDienThoai}');

        zip.file('word/document.xml', xml);
        const buf = zip.generate({type: 'nodebuffer', compression: 'DEFLATE'});
        fs.writeFileSync(file, buf);
    } catch(e) {
        console.log("Insert label error:", e.message);
    }
}

insertLabelsFirst();
process('./samples/BEO_Hoi_Nghi.docx', cleanHoiNghi);
process('./samples/BEO_Tiec_Cuoi.docx', cleanTiecCuoi);
