import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import PizZip from 'pizzip';
import Docxtemplater from 'docxtemplater';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const SAMPLES_DIR = path.join(__dirname, 'samples');

function findTemplates(dir) {
    let results = [];
    const list = fs.readdirSync(dir);
    list.forEach(file => {
        const fullPath = path.join(dir, file);
        const stat = fs.statSync(fullPath);
        if (stat && stat.isDirectory()) {
            results = results.concat(findTemplates(fullPath));
        } else if (file.endsWith('.docx') && !file.startsWith('~$')) {
            results.push(fullPath);
        }
    });
    return results;
}

const templates = findTemplates(SAMPLES_DIR);
console.log(`Found ${templates.length} templates to test.`);

const mockData = {
    // Basic contract info
    Sohopdong: 'HD260904001',
    SoPhuLuc: 'PL001',
    SoThayDoi: 'TD001',
    Ngayhopdong: '2026-09-04',
    Ngaytochuc: '2026-10-15',
    NgayLapHD: '04',
    ThangLapHD: '09',
    NamLapHD: '2026',
    TiecNgay: '15',
    TiecThang: '10',
    TiecNam: '2026',
    TiecNgayAL: '05',
    TiecThangAL: '09',
    TiecNamAL: 'Bính Ngọ',
    TiecGioBatDau: '18:00',
    TiecGioKetThuc: '21:30',
    CaTiec: 'Tối',
    ThoiGianToChuc: '18:00 - 21:30',
    
    // Parties info
    BenATenCongTy: 'CÔNG TY TNHH TRUNG TÂM HỘI NGHỊ TIỆC CƯỚI QUEEN PLAZA KỲ HOÀ',
    BenADiaChi: '16A Lê Hồng Phong (nối dài), Phường 12, Quận 10, TP.HCM',
    BenASDT: '028 3862 8899',
    BenAMST: '0312345678',
    BenADaiDien: 'Bà Nguyễn Thị Mai',
    BenAChucVu: 'Giám Đốc Điều Hành',
    BenANhanVienPhuTrach: 'Trần Văn Hùng',
    BenASDTNhanVien: '0909123456',
    BenAEmailNhanVien: 'hung.tv@queenplaza.com.vn',
    
    BenBTenCongTy: 'CÔNG TY CỔ PHẦN CÔNG NGHỆ VÀ TRUYỀN THÔNG Á CHÂU',
    BenBDiaChi: '123 Nguyễn Huệ, Phường Bến Nghé, Quận 1, TP.HCM',
    BenBDienThoai: '0918888999',
    BenBMST: '0398765432',
    BenBDaiDien: 'Ông Lê Hoàng Nam',
    BenBChucVu: 'Tổng Giám Đốc',
    BenBTenChuRe: 'Lê Hoàng Nam',
    BenBTenCoDau: 'Phạm Quỳnh Chi',
    Tenchure: 'Lê Hoàng Nam',
    Tencodau: 'Phạm Quỳnh Chi',
    
    // Halls & Venue
    TenSanhTiec: 'Diamond',
    TenSanhTiecPhu: 'Ruby',
    DiaDiemHoiNghi: 'Sảnh Diamond - Lầu 1',
    DiaDiemTiec: 'Sảnh Ruby - Lầu 2',
    DiaDiemTrienLam: 'Sảnh Diamond',
    SanhQuyMoMin: 20,
    SanhQuyMoMax: 50,
    KichThuocSanKhau: '8m x 4m x 0.8m',
    KichThuocSanKhauPhu: '6m x 3m x 0.6m',
    SetupBanGhe: 'Bàn tròn (Banquet)',
    KieuSetup: 'ClassRoom',
    
    // Tables & Food
    SoBanChinhThuc: 30,
    BanChinhThuc: 30,
    TiecSoBanChinhThuc: 30,
    SoBanDuPhong: 3,
    TiecSoBanDuPhong: 3,
    SoBanTang: 1,
    TiecSoBanTang: 1,
    SoBanManChinhThuc: 28,
    SoBanChayChinhThuc: 2,
    SoBanManDuPhong: 3,
    SoBanChayDuPhong: 0,
    TongSoBan: 34,
    SoBanPhatSinh: 2,
    TiecSoKhach1Ban: 10,
    SoKhachThamQuanDuKien: 600,
    
    // Decor & Promotion
    TenMauTrangTri: 'Rustic Flora Theme',
    DonGiaMauTrangTri: '5.000.000 VNĐ',
    DanhSachUuDai: '- Tặng 01 bàn tiệc chính thức\n- Tặng backdrop chụp ảnh hoa tươi\n- Miễn phí màn hình LED suốt tiệc',
    DieuKhoanBoSung: '- Cho phép setup sớm trước 02 tiếng.',
    
    // Financials
    GiaBanTiec: '4.500.000 VNĐ',
    TongThanhTien: '135.000.000 VNĐ',
    MucPhiPhucVu: '5%',
    PhiPhucVu: '6.750.000 VNĐ',
    TongCongChuaVAT: '141.750.000 VNĐ',
    VAT: '14.175.000 VNĐ',
    TongTienSauVAT: '155.925.000 VNĐ',
    TongTienBangChu: 'Một trăm năm mươi lăm triệu chín trăm hai mươi lăm ngàn đồng chẵn',
    
    Dot1SoTien: '46.777.500 VNĐ',
    Dot1BangChu: 'Bốn mươi sáu triệu bảy trăm bảy mươi bảy ngàn năm trăm đồng',
    Dot1Ngay: '04/09/2026',
    Dot1HinhThuc: 'Chuyển khoản',
    
    Dot2SoTien: '77.962.500 VNĐ',
    Dot2BangChu: 'Bảy mươi bảy triệu chín trăm sáu mươi hai ngàn năm trăm đồng',
    
    SoTienDaDatCoc: '46.777.500 VNĐ',
    SoTienConLai: '109.147.500 VNĐ',
    SoTienConLaiBangChu: 'Một trăm lẻ chín triệu một trăm bốn mươi bảy ngàn năm trăm đồng',
    
    // Loops
    DanhSachSanh: [
        { STT: 1, TenSanh: 'Diamond', KieuSetup: 'ClassRoom', SucchuaMax: 400, GioBatDau: '08:00', GioKetThuc: '12:00', DonGia: '15.000.000 VNĐ', KTSanKhau: '8m x 4m' },
        { STT: 2, TenSanh: 'Ruby', KieuSetup: 'Bàn tròn (Banquet)', SucchuaMax: 300, GioBatDau: '12:00', GioKetThuc: '14:30', DonGia: '12.000.000 VNĐ', KTSanKhau: '6m x 3m' }
    ],
    MenuTiec: [
        { STT: 1, TenHang: 'Gỏi tiến vua tôm thịt', DonGia: '350.000 VNĐ', DVT: 'Dĩa' },
        { STT: 2, TenHang: 'Súp vi cá bào ngư', DonGia: '450.000 VNĐ', DVT: 'Thố' },
        { STT: 3, TenHang: 'Cá chẽm hấp Hong Kong', DonGia: '500.000 VNĐ', DVT: 'Con' },
        { STT: 4, TenHang: 'Bò né sốt tiêu đen kèm bánh mì', DonGia: '480.000 VNĐ', DVT: 'Phần' },
        { STT: 5, TenHang: 'Cơm chiên hải sản Hoàng Kim', DonGia: '320.000 VNĐ', DVT: 'Dĩa' },
        { STT: 6, TenHang: 'Chè hạt sen long nhãn', DonGia: '250.000 VNĐ', DVT: 'Thố' }
    ],
    MenuMan: [
        { STT: 1, TenHang: 'Gỏi tiến vua tôm thịt', DonGia: '350.000 VNĐ' },
        { STT: 2, TenHang: 'Súp vi cá bào ngư', DonGia: '450.000 VNĐ' },
        { STT: 3, TenHang: 'Cá chẽm hấp Hong Kong', DonGia: '500.000 VNĐ' }
    ],
    MenuChay: [
        { STT: 1, TenHang: 'Gỏi ngó sen ngũ sắc chay', DonGia: '250.000 VNĐ' },
        { STT: 2, TenHang: 'Súp nấm đông cô hạt sen chay', DonGia: '280.000 VNĐ' }
    ],
    DanhSachDichVu: [
        { STT: 1, TenHang: 'Âm thanh ánh sáng sân khấu biểu diễn', SoLuong: 1, DonGia: '10.000.000 VNĐ', ThanhTien: '10.000.000 VNĐ' },
        { STT: 2, TenHang: 'Màn hình LED P3', SoLuong: 1, DonGia: '5.000.000 VNĐ', ThanhTien: '5.000.000 VNĐ' }
    ],
    DanhSachPhatSinh: [
        { STT: 1, TenHang: 'Bia Heineken (thùng)', SoLuong: 5, DonGia: '480.000 VNĐ', ThanhTien: '2.400.000 VNĐ' }
    ],
    DanhSachDoiMon: [
        { STT: 1, MonGoc: 'Gỏi củ hũ dừa', MonMoi: 'Gỏi tiến vua tôm thịt', DonGiaGoc: '300.000', DonGiaMoi: '350.000', ChenhLech: '50.000', SoLuong: 30, ThanhTien: '1.500.000 VNĐ' }
    ]
};

let successCount = 0;
let failCount = 0;

templates.forEach(tPath => {
    const relPath = path.relative(SAMPLES_DIR, tPath);
    try {
        const content = fs.readFileSync(tPath, 'binary');
        const zip = new PizZip(content);
        const doc = new Docxtemplater(zip, {
            paragraphLoop: true,
            linebreaks: true,
            nullGetter: () => ''
        });
        doc.render(mockData);
        console.log(`[PASS] ${relPath}`);
        successCount++;
    } catch (err) {
        console.error(`[FAIL] ${relPath}: ${err.message}`);
        if (err.properties && err.properties.errors) {
            err.properties.errors.forEach(e => console.error(`   -> ${e.message}`));
        }
        failCount++;
    }
});

console.log(`\nResults: ${successCount} passed, ${failCount} failed.`);
if (failCount > 0) process.exit(1);
