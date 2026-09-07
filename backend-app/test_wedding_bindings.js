import assert from 'node:assert/strict';
import fs from 'node:fs';
import PizZip from 'pizzip';
import Docxtemplater from 'docxtemplater';
import { chooseWeddingTemplate } from './wedding-template-routing.js';

for (const [date, expected] of [['2026-09-05',true],['2026-10-05',true],['2026-10-06',false],['2026-09-04',false],['',false],['2026-02-30',false]]) {
    assert.equal(chooseWeddingTemplate({NgayCocThucTe:'2026-09-05',Ngaytochuc:date}), expected?'hop_dong_menu_ngay':'hop_dong');
}
assert.equal(chooseWeddingTemplate({Ngayhopdong:'2026-09-05',Ngaytochuc:'2026-09-06'}),'hop_dong');
const samples = new URL('./samples/',import.meta.url);
for (const name of ['hop_dong.docx','hop_dong_menu_ngay.docx','phu_luc_hop_dong.docx']) {
    for (const kind of ['both','man','chay','empty']) {
        const data = {
            Sohopdong:'HD-TEST', SoPhuLuc:'PL-002', BenADiaChi:'ĐỊA CHỈ CẤU HÌNH',
            MucPhiPhucVu:'Miễn phí', DieuKhoanBoSung:'Điều khoản riêng ABC', DSKhuyenMai:'Ưu đãi đã chọn XYZ',
            SoBanChinhThuc:0, BanTang:0, SoBanDuPhong:0,
            NgayToChuc:'31/07/2026', ThangToChuc:'07', NamToChuc:'2026',
            MenuMan:kind==='both'||kind==='man'?[{STT:1,TenMonAn:'MÓN MẶN TEST',DonGia:'125.000'}]:[],
            MenuChay:kind==='both'||kind==='chay'?[{STT:1,TenMonAn:'MÓN CHAY TEST',DonGia:'75.000'}]:[],
            MenuTongCongMan:'125.000 VNĐ',MenuTongCongChay:'75.000 VNĐ',
        };
        const doc=new Docxtemplater(new PizZip(fs.readFileSync(new URL(name,samples))),{paragraphLoop:true,linebreaks:true,nullGetter:()=>''});
        doc.render(data);
        const text=doc.getZip().file('word/document.xml').asText().replace(/<[^>]+>/g,'');
        assert.ok(!/\{[^}]+\}/.test(text));
        assert.ok(text.includes(data.BenADiaChi));
        if(name!=='hop_dong.docx') {
            assert.ok(text.includes('THỰC ĐƠN MẶN')&&text.includes('THỰC ĐƠN CHAY'));
            assert.equal(text.includes('MÓN MẶN TEST'),data.MenuMan.length>0);
            assert.equal(text.includes('MÓN CHAY TEST'),data.MenuChay.length>0);
        }
        if(name==='phu_luc_hop_dong.docx') {
            assert.ok(text.includes('Số: PL-002'));
            assert.ok(text.includes('Số bàn chính thức: 0 bàn'));
            assert.ok(!text.includes('31/07/2026 tháng'));
        } else {
            assert.ok(text.includes('Phí phục vụ: Miễn phí'));
            assert.ok(text.includes('Điều khoản riêng ABC'));
            assert.ok(text.includes('Tất cả các chương trình khuyến mãi'));
            assert.ok(!text.includes('KM 01.10.2025'));
        }
        if(name==='hop_dong_menu_ngay.docx') assert.ok(!text.includes('Chậm nhất 30 ngày'));
    }
    console.log('PASS',name,'both/man/chay/empty');
}
console.log('PASS routing boundaries (0/30/31/negative/missing/invalid)');
