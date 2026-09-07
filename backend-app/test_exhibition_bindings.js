import assert from 'node:assert/strict';
import fs from 'node:fs';
import PizZip from 'pizzip';
import Docxtemplater from 'docxtemplater';

const root = new URL('./samples/', import.meta.url);
const directory = fs.readdirSync(root).find(name => name.startsWith('FILE MAU'));
for (const name of fs.readdirSync(new URL(directory + '/', root)).filter(n => /^2\.[12] /.test(n))) {
    const file = new URL(directory + '/' + name, root);
    for (const empty of [false, true]) {
        const data = empty ? {} : {
            SoKhachThamQuanDuKien: 437, SoKhachDiemDanh: 1200,
            NgaySetupTrienLam: '14/10/2026', NgayTrienLam: '15/10/2026',
            GioBatDauTrienLam: '09:15', GioKetThucTrienLam: '16:45',
            SetupBatDau: '07:00', SetupKetThuc: '22:00',
            NgayLapHD: '01', ThangLapHD: '09', NamLapHD: '2026',
            TiecGioBatDau: '18:00', TiecGioKetThuc: '22:00',
            Dot1SoTien: '30.000.000 VNĐ', PhiThueSanhNgoaiGio: '2.000.000VNĐ++/giờ/sảnh',
            DiaDiemTrienLam: 'Sảnh A', DiaDiemTiec: 'Sảnh B', BuoiTiec: 'trưa',
        };
        const doc = new Docxtemplater(new PizZip(fs.readFileSync(file)), { paragraphLoop: true, linebreaks: true, nullGetter: () => '' });
        doc.render(data);
        const text = doc.getZip().file('word/document.xml').asText().replace(/<[^>]+>/g, '');
        const visitors = text.match(/Số lượng khách tham quan dự kiến: ([^<]*?) khách/)[1];
        assert.equal(visitors, empty ? '' : '437');
        assert.ok(!text.includes('VNĐ VNĐ'));
        assert.ok(!text.includes('70%'));
        if (!empty) {
            assert.ok(text.includes('14/10/2026'));
            assert.ok(text.includes('09:15 - 16:45 vào ngày 15/10/2026'));
            assert.ok(text.includes('30.000.000 VNĐ (Bằng chữ:'));
            assert.ok(text.includes('2.000.000VNĐ++/giờ/sảnh'));
        }
    }
    console.log('PASS populated + empty:', name);
}
