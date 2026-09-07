import assert from 'node:assert/strict';
import fs from 'node:fs';
import PizZip from 'pizzip';
import Docxtemplater from 'docxtemplater';

const root = new URL('./samples/', import.meta.url);
const directory = fs.readdirSync(root).find(n => n.startsWith('FILE MAU'));
const dir = new URL(directory + '/', root);
for (const name of fs.readdirSync(dir).filter(n => /^[23]\.[12] /.test(n))) {
    for (const buoi of ['trưa', 'tối', '']) {
        const data = buoi ? {
            Sohopdong: 'HD-2026-123', NgayLapHD: '05', ThangLapHD: '09', NamLapHD: '2026',
            BenANguoiGiaoDich: 'Trần Minh', BenAChucVuGiaoDich: 'Chuyên viên kinh doanh',
            BenANhanVienPhuTrach: 'SALES-OTHER', BenAChucVu: 'Giám đốc',
            NoiDungXuatHoaDon: 'Nội dung thỏa thuận riêng & dịch vụ',
            HDTenCty: 'Công ty Khách Hàng', BenATenCongTy: 'Công ty Nhà Hàng',
            SoKhachHoiNghi: 437, SoKhachDiemDanh: 1200,
            DiaDiemHoiNghi: 'Sảnh A', DiaDiemTiec: 'Sảnh B', BuoiTiec: buoi,
            SetupHoiNghi: 'Chữ U', SetupTiec: 'Cocktail',
            CaHoiNghi: '08:00 - 11:00', CaTiec: buoi === 'trưa' ? '12:00 - 14:00' : '18:00 - 22:00',
            NgaySetupSuKien: '14/10/2026', NgaySuKien: '15/10/2026',
            Dot1SoTien: '30.000.000 VNĐ', PhiThueSanhNgoaiGio: '0VNĐ++/giờ/sảnh',
        } : { Sohopdong: 'HD-EMPTY', NgayLapHD: '05', ThangLapHD: '09', NamLapHD: '2026' };
        const doc = new Docxtemplater(new PizZip(fs.readFileSync(new URL(name, dir))), {
            paragraphLoop: true, linebreaks: true, nullGetter: () => '',
        });
        doc.render(data);
        const xml = doc.getZip().file('word/document.xml').asText();
        const text = xml.replace(/<[^>]+>/g, '').replace(/&amp;/g, '&');
        assert.ok(!text.includes('/CTY-HHKH/2025'));
        assert.ok(!text.includes('VNĐ VNĐ'));
        assert.ok(!text.includes('70%'));
        if (name.startsWith('3.')) {
            assert.ok(text.includes('an toàn lao động'));
            assert.ok(!text.includes('lao đồng'));
            assert.ok(text.includes('Biên bản nghiệm thu và quyết toán dịch vụ'));
        }
        assert.ok(!/\{[^}]+\}/.test(text));
        if (buoi) {
            assert.ok(text.includes('Người phụ trách giao dịch: Trần Minh'));
            assert.ok(text.includes('Chức vụ: Chuyên viên kinh doanh'));
            assert.ok(text.includes('Nội dung xuất: ' + data.NoiDungXuatHoaDon));
        } else {
            assert.ok(text.includes('theo HĐ số HD-EMPTY ký ngày 05/09/2026'));
        }
        if (name.startsWith('3.2')) {
            assert.ok(text.includes('thống nhất ký Hợp đồng hội nghị với các điều khoản'));
            assert.ok(text.includes('Bên B có nhu cầu thuê địa điểm để tổ chức hội nghị và Bên A đồng ý cung cấp dịch vụ cho thuê địa điểm theo yêu cầu của Bên B, với nội dung chi tiết như sau:'));
            assert.ok(!text.includes('khăn trải bàn màu'));
            assert.ok(!text.includes('1200 khách'));
            if (buoi) {
                for (const expected of ['Địa điểm hội nghị: Sảnh A', 'Set up bàn ghế: Chữ U',
                    'Số lượng khách tham dự hội nghị: 437 khách', '14/10/2026',
                    '08:00 - 11:00, ngày 15/10/2026']) assert.ok(text.includes(expected), expected);
                for (const lan of [1, 2]) assert.ok(text.includes(`Nội dung chuyển khoản lần ${lan}: Công ty Khách Hàng, Mã HĐ: HD-2026-123, ngày sự kiện 15/10/2026`));
            }
        }
        if (name.startsWith('3.1')) {
            assert.ok(!text.includes('17.500.000'));
            assert.ok(!text.includes('khăn trải bàn màu'));
            if (buoi) {
                for (const expected of ['Địa điểm hội nghị: Sảnh A', `Địa điểm tiệc ${buoi}: Sảnh B`,
                    'Set up bàn ghế: Chữ U', 'Set up bàn tiệc: Cocktail',
                    'Số lượng khách tham dự hội nghị: 437 khách', '14/10/2026',
                    '08:00 - 11:00, ngày 15/10/2026', `${data.CaTiec}, ngày 15/10/2026`,
                    '0VNĐ++/giờ/sảnh']) assert.ok(text.includes(expected), expected);
            }
        }
    }
    console.log('PASS lunch + dinner + empty:', name);
}
