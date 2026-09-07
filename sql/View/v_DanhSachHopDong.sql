IF EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[v_DanhSachHopDong]'))
    DROP VIEW [dbo].[v_DanhSachHopDong]
GO
IF EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[v_DanhSachHopDong_Core]'))
    DROP VIEW [dbo].[v_DanhSachHopDong_Core]
GO
CREATE VIEW [dbo].[v_DanhSachHopDong_Core] AS
SELECT 
    h.Sohopdong AS [Id], -- Đóng vai trò là PrimaryKey cho Frontend

    h.Sohopdong AS [Sohopdong], -- Cột khóa chính thật
    h.Sobiennhan,
    (SELECT MIN(b.DocumentDate) FROM tbmk_Biennhancoccho b WHERE b.DocumentID = h.Sobiennhan AND ISNULL(b.IsHuy, 0) = 0 AND ISNULL(b.SoTienCocCho, 0) > 0) AS [NgayCocThucTe],
    h.PhiPhucVu AS [PhiPhucVuTyLe],
    h.BenANguoiGiaoDich,
    h.BenAChucVuGiaoDich,
    h.NoiDungXuatHoaDon,
    h.SoKhachHoiNghi,
    ISNULL((SELECT TOP 1 ks.TenKieuSetup
        + CASE WHEN NULLIF(hs.Ghichuct, '') IS NOT NULL THEN N' (' + hs.Ghichuct + N')' ELSE N'' END
        FROM tbmk_Hopdongsanhtiec hs
        LEFT JOIN dmKieuSetup ks ON ks.KieuSetupID = hs.KieuSetup
        WHERE hs.Sohopdong = h.Sohopdong AND hs.LoaiDiaDiem = 'HOI_NGHI'
        ORDER BY hs.Sanhtiecid), N'') AS [SetupHoiNghi],
    ISNULL((SELECT TOP 1 ks.TenKieuSetup
        + CASE WHEN NULLIF(hs.Ghichuct, '') IS NOT NULL THEN N' (' + hs.Ghichuct + N')' ELSE N'' END
        FROM tbmk_Hopdongsanhtiec hs
        LEFT JOIN dmKieuSetup ks ON ks.KieuSetupID = hs.KieuSetup
        WHERE hs.Sohopdong = h.Sohopdong AND hs.LoaiDiaDiem = 'TIEC'
        ORDER BY hs.Sanhtiecid), N'') AS [SetupTiec],
    ISNULL(CONVERT(VARCHAR(10), h.TuNgaySetup, 103), '') AS [NgaySetupSuKien],
    ISNULL(CONVERT(VARCHAR(10), h.Ngaytochuc, 103), '') AS [NgaySuKien],

    h.Makh,
    
    -- Lấy thông tin khách hàng từ dmkhachhang
    CASE 
        WHEN k.Tenchure IS NOT NULL AND k.Tencodau IS NOT NULL AND k.Tenchure <> '' AND k.Tencodau <> ''
            THEN k.Tenchure + ' & ' + k.Tencodau
        ELSE ISNULL(k.Tenkh, N'Khách vãng lai')
    END AS [TenKhachHang],
    
    CASE 
        WHEN k.Tenchure IS NOT NULL AND k.Tencodau IS NOT NULL AND k.Tenchure <> '' AND k.Tencodau <> ''
            THEN k.Tenchure + ' & ' + k.Tencodau
        ELSE ISNULL(k.Tenkh, N'Khách vãng lai')
    END AS [TenCongTy],
    
    CASE 
        WHEN ISNULL((SELECT MAX(td.LanThayDoi) FROM tbmk_Thaydoi td WHERE td.Sohopdong = h.Sohopdong AND ISNULL(td.IsDeleted, 0) = 0), 0) = 0
            THEN N'PHIẾU ĐẶT TIỆC'
        ELSE N'PHIẾU ĐẶT TIỆC THAY ĐỔI LẦN ' + CAST((SELECT MAX(td.LanThayDoi) FROM tbmk_Thaydoi td WHERE td.Sohopdong = h.Sohopdong AND ISNULL(td.IsDeleted, 0) = 0) AS NVARCHAR(10))
    END AS [TieuDePhieu],
    
    ISNULL(k.Dienthoai, ISNULL(k.DTchure, k.DTcodau)) AS [DienThoai],
    h.Ngaytochuc AS [NgayToChuc],
    h.TuNgaySetup AS [TuNgaySetup],
    h.NgayTraSanhDV AS [NgayTraSanhDV],
    
    ISNULL(h.TongSoBan, 0) AS [SoBan],
    
    STUFF((
        SELECT N', ' + s.Tensanhtiec
        FROM tbmk_Hopdongsanhtiec hs
        INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid
        WHERE hs.Sohopdong = h.Sohopdong
        ORDER BY hs.IsSanhchinh DESC, hs.Sanhtiecid
        FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 2, '') AS [SanhDat],
    ISNULL((
        SELECT s.Tensanhtiec 
        FROM tbmk_Hopdongsanhtiec hs 
        INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid 
        WHERE hs.Sohopdong = h.Sohopdong 
        ORDER BY hs.IsSanhchinh DESC, hs.Sanhtiecid
        OFFSET 1 ROWS FETCH NEXT 1 ROWS ONLY
    ), '') AS [SanhDat2],
    
    ISNULL(h.Tongtienhopdong, 0) AS [TongTien],
    
    CASE
        WHEN h.IsHuy = 1 THEN N'Đã Hủy'
        WHEN h.IsKetthuc = 1 THEN N'Đã Quyết Toán'
        ELSE N'Đã Ký'
    END AS [TrangThai],

    -- CÁC TRƯỜNG THÊM MỚI ĐỂ PHỤC VỤ NHẬP LIỆU/SỬA HỢP ĐỒNG
    k.Tenchure,
    k.Tencodau,
    k.Diachi,
    k.Mail,
    h.Ngayhopdong,
    h.Nhamngay,
    h.Loaitiecid,
    CASE 
        WHEN h.Loaitiecid = 'BLT000001' AND DATEDIFF(day, (SELECT MIN(b.DocumentDate) FROM tbmk_Biennhancoccho b WHERE b.DocumentID = h.Sobiennhan AND ISNULL(b.IsHuy, 0) = 0 AND ISNULL(b.SoTienCocCho, 0) > 0), h.Ngaytochuc) BETWEEN 0 AND 30
        THEN ISNULL((SELECT TOP 1 tm.TemplateFile FROM tbmk_LoaitiecAddfile tm WHERE tm.FormName = 'frmHopDong_MenuNgay' AND tm.Loaitiecid = h.Loaitiecid), N'hop_dong_menu_ngay.docx')
        ELSE (SELECT TOP 1 tm.TemplateFile FROM tbmk_LoaitiecAddfile tm WHERE tm.FormName = 'frmHopDong' AND tm.Loaitiecid = h.Loaitiecid)
    END AS [TemplateFile],
    h.Thoigianid,
    h.Sotiencoccho AS DaCocVND,
    h.Sotiencochopdong AS [Sotiencochopdong],
    h.Giabanman AS [Giabanman],
    h.Tongtiencoc AS [Tongtiencoc],
    h.Ghichu AS [Ghichu],
    h.JsonLichTrinh,

    -- Thực đơn & Dịch vụ: đọc duy nhất từ bảng chi tiết → JSON cho form
    ISNULL((
        SELECT items.Mahang, items.TenHang, items.DvtID, items.Soluong, items.Dongia,
               items.IsChay
        FROM (
            SELECT td.Mahang, ISNULL(hh.Tenhang, td.Mahang) AS TenHang, ISNULL(hh.DVTID, N'Đĩa') AS DvtID,
                   CAST(1 AS DECIMAL(18,2)) AS Soluong, ISNULL(td.Dongia, 0) AS Dongia,
                   CAST(0 AS BIT) AS IsChay, ISNULL(td.STTmon, 0) AS SortOrder, 1 AS TableType
            FROM tbmk_Hopdongthucdonman td
            LEFT JOIN dmHanghoa hh ON td.Mahang = hh.Mahang
            WHERE td.Sohopdong = h.Sohopdong
            UNION ALL
            SELECT td.Mahang, ISNULL(hh.Tenhang, td.Mahang), ISNULL(hh.DVTID, N'Đĩa'),
                   CAST(1 AS DECIMAL(18,2)), ISNULL(td.Dongia, 0),
                   CAST(1 AS BIT), ISNULL(td.STTmon, 0), 2
            FROM tbmk_Hopdongthucdonchay td
            LEFT JOIN dmHanghoa hh ON td.Mahang = hh.Mahang
            WHERE td.Sohopdong = h.Sohopdong
        ) items
        ORDER BY items.TableType, items.SortOrder, items.Mahang
        FOR JSON PATH
    ), '[]') AS [JsonBanTiec],

    ISNULL((
        SELECT tu.Mahang, ISNULL(hh.Tenhang, tu.Mahang) AS TenHang, ISNULL(tu.Dvt, hh.DVTID) AS DvtID,
               ISNULL(tu.IsKhuyenmai, 0) AS IsKhuyenmai, ISNULL(tu.Soluong, 0) AS Soluong,
               ISNULL(tu.Dongia, 0) AS Dongia, CAST(0 AS DECIMAL(18,2)) AS Soluongle,
               CAST(0 AS DECIMAL(18,2)) AS Dongiale, ISNULL(tu.Ghichuthucuong, N'') AS Ghichuthucuong
        FROM tbmk_Hopdongthucuong tu
        LEFT JOIN dmHanghoa hh ON tu.Mahang = hh.Mahang
        WHERE tu.Sohopdong = h.Sohopdong
        ORDER BY tu.STT, tu.Mahang
        FOR JSON PATH
    ), '[]') AS [JsonThucUong],

    ISNULL((
        SELECT dv.Mahang, ISNULL(hh.Tenhang, dv.Mahang) AS TenHang, ISNULL(hh.DVTID, N'') AS DvtID,
               ISNULL(dv.Soluong, 0) AS Soluong, ISNULL(dv.Dongia, 0) AS Dongia,
               ISNULL(dv.Ghichudichvu, N'') AS Ghichudichvu
        FROM tbmk_Hopdongdichvu dv
        LEFT JOIN dmHanghoa hh ON dv.Mahang = hh.Mahang
        WHERE dv.Sohopdong = h.Sohopdong
        ORDER BY dv.STT, dv.Mahang
        FOR JSON PATH
    ), '[]') AS [JsonDichVu],

    ISNULL((
        SELECT ps.Mahang, ISNULL(hh.Tenhang, ps.Mahang) AS TenHang, ISNULL(hh.DVTID, N'') AS DvtID,
               ISNULL(ps.Soluong, 0) AS Soluong, ISNULL(ps.Dongia, 0) AS Dongia,
               ISNULL(ps.GhiChuPhatSinh, N'') AS GhiChuPhatSinh
        FROM tbmk_HopdongPhatSinh ps
        LEFT JOIN dmHanghoa hh ON ps.Mahang = hh.Mahang
        WHERE ps.Sohopdong = h.Sohopdong
        FOR JSON PATH
    ), '[]') AS [JsonPhatSinh],
    (
        SELECT 
            hs.Sanhtiecid AS [Sanhtiecid],
            CAST(ISNULL(hs.IsSanhchinh, 0) AS BIT) AS [IsSanhchinh],
            hs.KieuSetup AS [KieuSetup],
            hs.LoaiDiaDiem AS [LoaiDiaDiem],
            hs.Thoigianid AS [Thoigianid],
            hs.Giatiensanh AS [Giatiensanh],
            hs.Ghichuct AS [Ghichuct]
        FROM tbmk_Hopdongsanhtiec hs 
        WHERE hs.Sohopdong = h.Sohopdong 
        ORDER BY hs.IsSanhchinh DESC, hs.Sanhtiecid ASC
        FOR JSON PATH
    ) AS [JsonSanhTiec],
    
    -- ==========================================
    -- CÁC CỘT DỮ LIỆU ĐƯỢC FORMAT SẴN CHO IN ẤN
    -- Dùng để binding vào file hop_dong.docx (docxtemplater)
    -- ==========================================
    RIGHT('0' + CAST(DAY(h.Ngayhopdong) AS VARCHAR), 2) AS [NgayLapHD],
    RIGHT('0' + CAST(MONTH(h.Ngayhopdong) AS VARCHAR), 2) AS [ThangLapHD],
    CAST(YEAR(h.Ngayhopdong) AS VARCHAR) AS [NamLapHD],

    -- Thông tin Bên A (có _ cho hop_dong.docx cũ)
    ISNULL(NULLIF((SELECT TOP 1 CodeValue FROM [dbo].[SY_Setup] WHERE CodeID = 'HNNguoiDaiDien'), ''), '') AS [BenANguoiDaiDien],
    ISNULL(NULLIF((SELECT TOP 1 CodeValue FROM [dbo].[SY_Setup] WHERE CodeID = 'HNNguoiDaiDien'), ''), '') AS [BenADaiDien],
    ISNULL(NULLIF(h.BenAChucVuDaiDien, ''), ISNULL((SELECT TOP 1 CodeValue FROM [dbo].[SY_Setup] WHERE CodeID = 'HNChucVuNguoiDaiDien'), '')) AS [BenAChucVu],
    (SELECT TOP 1 nv.Tennv FROM dmNhanvienView nv WHERE nv.NHANVIENID = h.Manv OR nv.Manv = h.Manv OR nv.USERNAME = h.Manv) AS [BenANhanVienPhuTrach],
    (SELECT TOP 1 nv.DIENTHOAI FROM dmNhanvienView nv WHERE nv.NHANVIENID = h.Manv OR nv.Manv = h.Manv OR nv.USERNAME = h.Manv) AS [BenASDTNhanVien],
    (SELECT TOP 1 CodeValue FROM [dbo].[SY_Setup] WHERE CodeID = 'BenADiaChi') AS [BenADiaChi],
    (SELECT TOP 1 CodeValue FROM [dbo].[SY_Setup] WHERE CodeID = 'BenAEmail')  AS [BenAEmail],
    (SELECT TOP 1 CodeValue FROM [dbo].[SY_Setup] WHERE CodeID = 'BenATenCongTy') AS [BenATenCongTy],
    (SELECT TOP 1 CodeValue FROM [dbo].[SY_Setup] WHERE CodeID = 'BenASDT') AS [BenASDT],
    (SELECT TOP 1 CodeValue FROM [dbo].[SY_Setup] WHERE CodeID = 'BenAMST') AS [BenAMST],


    -- Thông tin Bên B
    ISNULL(NULLIF(k.Nguoigd, ''), CASE 
        WHEN k.Tenchure IS NOT NULL AND k.Tencodau IS NOT NULL AND k.Tenchure <> '' AND k.Tencodau <> ''
            THEN k.Tenchure + ' & ' + k.Tencodau
        ELSE ISNULL(k.Tenkh, N'Khách vãng lai')
    END) AS [BenBTenDaiDien],
    ISNULL(h.NguoinhanTT, CASE WHEN k.Tenchure <> '' AND k.Tencodau <> '' THEN k.Tenchure + ' & ' + k.Tencodau ELSE ISNULL(k.Tenkh, N'Khách vãng lai') END) AS [BenBTenChuTiec],
    ISNULL(NULLIF(k.CMNDDaiDien, ''), ISNULL(NULLIF(k.CMNDnguoidd, ''), ISNULL(NULLIF(k.CMNDchure, ''), '...'))) AS [BenBCCCD],
    ISNULL(k.Diachi, '...') AS [BenBDiaChi],
    ISNULL(k.Dienthoai, ISNULL(k.DTchure, k.DTcodau)) AS [BenBDienThoai],
    N'Khách hàng' AS [BenBChucVu],

    -- Thông tin Tiệc
    ISNULL(h.TuGioDenGioSetup, '...') AS [SetupBatDau],
    ISNULL(h.DenGioSetup, '...') AS [SetupKetThuc],
    N'Vào hàng hóa' AS [SetupNoiDung1],
    ISNULL(h.GhiChuSetup, N'SETUP: Không máy lạnh') AS [SetupNoiDung2],
    N'RHS: Có ATAS, Led; không máy lạnh' AS [ToChucNoiDung],
    N'Ra hàng hóa' AS [OutNoiDung],
    ISNULL(h.GioDienRaSuKien, '...') AS [TiecGioBatDau],
    ISNULL(FORMAT(h.NgayTraSanhDV, 'HH:mm'), '') AS [TiecGioKetThuc],
    ISNULL(h.TongSoBan * 10, 0) AS [SoKhachDiemDanh],

    -- Các trường lịch trình động dạng JSON phục vụ in ấn BEO mới
    ISNULL(NULLIF(h.JsonLichTrinh, ''), '[]') AS [LichTrinh],
    
    (
        SELECT t.STT, t.SoTien, t.Ngay, t.NoiDung
        FROM (
            SELECT 
                1 AS STT, 
                FORMAT(ISNULL(h.Sotiencoccho, 0), 'N0', 'vi-VN') + ' VNĐ' AS SoTien, 
                ISNULL(CONVERT(VARCHAR(10), (SELECT TOP 1 b.DocumentDate FROM tbmk_Biennhancoccho b WHERE b.DocumentID = h.Sobiennhan), 103), '...') AS Ngay,
                N'Đặt cọc giữ chỗ' AS NoiDung
            WHERE ISNULL(h.Sotiencoccho, 0) > 0

            UNION ALL

            SELECT 
                2 AS STT, 
                FORMAT(ISNULL(h.Sotiencochopdong, 0), 'N0', 'vi-VN') + ' VNĐ' AS SoTien, 
                ISNULL(CONVERT(VARCHAR(10), h.Ngayhopdong, 103), '...') AS Ngay,
                N'Đặt cọc ký hợp đồng' AS NoiDung
            WHERE ISNULL(h.Sotiencochopdong, 0) > 0

            UNION ALL

            SELECT 
                CASE WHEN ISNULL(h.Sotiencochopdong, 0) > 0 THEN 3 ELSE 2 END AS STT, 
                N'Thanh toán còn lại' AS SoTien, 
                ISNULL(CONVERT(VARCHAR(10), h.Ngaytochuc, 103), '...') AS Ngay,
                ISNULL(NULLIF(h.Ghichu, ''), 
                    CASE 
                        WHEN (SELECT TOP 1 lt.Tenloaitiec FROM dmLoaihinhtiec lt WHERE lt.Loaitiecid = h.Loaitiecid) LIKE N'%Hội Nghị%' 
                            THEN N'Thanh toán sau tiệc 07 ngày' 
                            ELSE N'Thanh toán cuối tiệc.' 
                    END
                ) AS NoiDung
        ) t
        ORDER BY t.STT
        FOR JSON PATH
    ) AS [LichTrinhThanhToan],
    
    (
        SELECT 
            CASE WHEN hs.IsSanhchinh = 1 THEN N'Hội nghị / Tiệc chính' ELSE N'Tiệc' END AS [LoaiPhong],
            s.Tensanhtiec AS [TenSanh],
            ISNULL(CAST(s.ChieuRong AS NVARCHAR), '...') AS [ChieuRong],
            ISNULL(CAST(s.ChieuDai AS NVARCHAR), '...') AS [ChieuDai],
            ISNULL(CAST(s.ChieuCaoTran AS NVARCHAR), '...') AS [ChieuCaoTran],
            ISNULL(s.KTSanKhau, '...') AS [KTSanKhau],
            CASE 
                WHEN hs.KieuSetup = 'ClassRoom' THEN ISNULL(s.ClassRoom, 0)
                WHEN hs.KieuSetup = 'Theater' THEN ISNULL(s.Theater, 0)
                WHEN hs.KieuSetup = 'Cluster' THEN ISNULL(s.ClusterHalfRound, 0)
                ELSE ISNULL(s.SLBanMax * 10, 0)
            END AS [SucchuaMax],
            ISNULL(s.SLBanMin * 10, 0) AS [SucchuaMin],
            ISNULL(ks.TenKieuSetup, 
                CASE 
                    WHEN hs.KieuSetup = 'ClassRoom' THEN N'Bàn lớp học (Classroom)'
                    WHEN hs.KieuSetup = 'Theater' THEN N'Nhà hát (Theater)'
                    WHEN hs.KieuSetup = 'Cluster' THEN N'Cụm tròn bán nguyệt (Cluster Half Round)'
                    WHEN hs.KieuSetup = 'UShape' THEN N'Bàn chữ U (U-Shape)'
                    WHEN hs.KieuSetup = 'Boardroom' THEN N'Phòng họp hội đồng (Boardroom)'
                    WHEN hs.KieuSetup = 'Cocktail' THEN N'Tiệc đứng (Cocktail / Standing)'
                    ELSE N'Bàn tiệc tròn (Banquet)'
                END
            ) + 
            CASE 
                WHEN ISNULL(hs.Ghichuct, '') <> '' THEN N' (' + hs.Ghichuct + N')'
                ELSE N''
            END AS [SetupBanGhe]
        FROM tbmk_Hopdongsanhtiec hs
        INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid
        LEFT JOIN dmKieuSetup ks ON hs.KieuSetup = ks.KieuSetupID
        WHERE hs.Sohopdong = h.Sohopdong
        ORDER BY hs.IsSanhchinh DESC, hs.Sanhtiecid ASC
        FOR JSON PATH
    ) AS [DanhSachSanh],
    
    RIGHT('0' + CAST(DAY(h.Ngaytochuc) AS VARCHAR), 2) AS [TiecNgayDL],
    RIGHT('0' + CAST(MONTH(h.Ngaytochuc) AS VARCHAR), 2) AS [TiecThangDL],
    CAST(YEAR(h.Ngaytochuc) AS VARCHAR) AS [TiecNamDL],
    CASE 
        WHEN CHARINDEX('/', h.Nhamngay) > 0 
            THEN SUBSTRING(h.Nhamngay, 1, CHARINDEX('/', h.Nhamngay) - 1)
        ELSE ISNULL(h.Nhamngay, '...')
    END AS [TiecNgayAL],
    CASE 
        WHEN CHARINDEX('/', h.Nhamngay) > 0 
            THEN CASE 
                WHEN CHARINDEX('/', h.Nhamngay, CHARINDEX('/', h.Nhamngay) + 1) > 0 
                    THEN SUBSTRING(h.Nhamngay, CHARINDEX('/', h.Nhamngay) + 1, CHARINDEX('/', h.Nhamngay, CHARINDEX('/', h.Nhamngay) + 1) - CHARINDEX('/', h.Nhamngay) - 1)
                ELSE SUBSTRING(h.Nhamngay, CHARINDEX('/', h.Nhamngay) + 1, LEN(h.Nhamngay))
            END
        ELSE '...'
    END AS [TiecThangAL],
    CASE 
        WHEN CHARINDEX('/', h.Nhamngay) > 0 AND CHARINDEX('/', h.Nhamngay, CHARINDEX('/', h.Nhamngay) + 1) > 0
            THEN SUBSTRING(h.Nhamngay, CHARINDEX('/', h.Nhamngay, CHARINDEX('/', h.Nhamngay) + 1) + 1, LEN(h.Nhamngay))
        ELSE '...'
    END AS [TiecNamAL],
    
    ISNULL((SELECT TOP 1 s.Tensanhtiec FROM tbmk_Hopdongsanhtiec hs INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid WHERE hs.Sohopdong = h.Sohopdong ORDER BY CASE WHEN hs.LoaiDiaDiem IN ('TRIEN_LAM', 'HOI_NGHI') THEN 0 WHEN ISNULL(hs.IsSanhchinh, 0) = 1 THEN 1 ELSE 2 END, hs.Sanhtiecid), '') AS [TenSanhTiec],
    (SELECT TOP 1 s.SLBanMin FROM tbmk_Hopdongsanhtiec hs INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid WHERE hs.Sohopdong = h.Sohopdong ORDER BY CASE WHEN hs.LoaiDiaDiem IN ('TRIEN_LAM', 'HOI_NGHI') THEN 0 WHEN ISNULL(hs.IsSanhchinh, 0) = 1 THEN 1 ELSE 2 END, hs.Sanhtiecid) AS [SanhQuyMoMin],
    (SELECT TOP 1 s.SLBanMax FROM tbmk_Hopdongsanhtiec hs INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid WHERE hs.Sohopdong = h.Sohopdong ORDER BY CASE WHEN hs.LoaiDiaDiem IN ('TRIEN_LAM', 'HOI_NGHI') THEN 0 WHEN ISNULL(hs.IsSanhchinh, 0) = 1 THEN 1 ELSE 2 END, hs.Sanhtiecid) AS [SanhQuyMoMax],
    
    -- Tên loại hình tiệc
    ISNULL((SELECT TOP 1 lt.Tenloaitiec FROM dmLoaihinhtiec lt WHERE lt.Loaitiecid = h.Loaitiecid), '') AS [TiecLoaiTiec],
    ISNULL(h.LoaiHinhSuKien, ISNULL((
        SELECT 
            CASE 
                -- Nếu có sảnh 2 và loại hình tiệc có 2 phần
                WHEN ISNULL((SELECT s.Tensanhtiec FROM tbmk_Hopdongsanhtiec hs INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid WHERE hs.Sohopdong = h.Sohopdong ORDER BY hs.IsSanhchinh DESC, hs.Sanhtiecid OFFSET 1 ROWS FETCH NEXT 1 ROWS ONLY), '') <> '' 
                     AND CHARINDEX('+', lt.Tenloaitiec) > 0
                    THEN 
                        RTRIM(LTRIM(SUBSTRING(lt.Tenloaitiec, 1, CHARINDEX('+', lt.Tenloaitiec) - 1))) 
                        + ' ' 
                        + (SELECT TOP 1 s.Tensanhtiec FROM tbmk_Hopdongsanhtiec hs INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid WHERE hs.Sohopdong = h.Sohopdong ORDER BY hs.IsSanhchinh DESC, hs.Sanhtiecid)
                        + ' + ' 
                        + RTRIM(LTRIM(SUBSTRING(lt.Tenloaitiec, CHARINDEX('+', lt.Tenloaitiec) + 1, LEN(lt.Tenloaitiec)))) 
                        + ' ' 
                        + (SELECT s.Tensanhtiec FROM tbmk_Hopdongsanhtiec hs INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid WHERE hs.Sohopdong = h.Sohopdong ORDER BY hs.IsSanhchinh DESC, hs.Sanhtiecid OFFSET 1 ROWS FETCH NEXT 1 ROWS ONLY)
                ELSE 
                    lt.Tenloaitiec 
                    + ' ' 
                    + ISNULL((SELECT TOP 1 s.Tensanhtiec FROM tbmk_Hopdongsanhtiec hs INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid WHERE hs.Sohopdong = h.Sohopdong ORDER BY hs.IsSanhchinh DESC, hs.Sanhtiecid), '')
            END
        FROM dmLoaihinhtiec lt 
        WHERE lt.Loaitiecid = h.Loaitiecid
    ), '')) AS [LoaiHinhSuKien],
    
    ISNULL(h.SobanManchinhthuc, 0) + ISNULL(h.SobanChaychinhthuc, 0) AS [TiecSoBanChinhThuc],
    ISNULL(h.SobanManchinhthuc, 0) AS [SoBanManChinhThuc],
    ISNULL(h.SobanChaychinhthuc, 0) AS [SoBanChayChinhThuc],
    ISNULL(h.SoBanTang, 0) AS [TiecSoBanTang],
    ISNULL(h.SoBanTang, 0) AS [SoBanTang],
    ISNULL(h.SobanManduphong, 0) + ISNULL(h.SobanChayduphong, 0) AS [TiecSoBanDuPhong],
    ISNULL(h.SobanManduphong, 0) AS [SoBanManDuPhong],
    ISNULL(h.SobanChayduphong, 0) AS [SoBanChayDuPhong],
    ISNULL(h.Tongsoban, 0) AS [TongSoBan],
    ISNULL((SELECT SUM(ps.Soluong) FROM tbmk_HopdongPhatSinh ps WHERE ps.Sohopdong = h.Sohopdong AND (ps.Mahang LIKE '%BAN%' OR ps.GhiChuPhatSinh LIKE N'%bàn%')), 0) AS [SoBanPhatSinh],
    ISNULL(h.SoNguoiTrenBan, 10) AS [TiecSoKhach1Ban],
    
    -- Thông tin Cọc & Khuyến mãi
    FORMAT(ISNULL(h.Sotiencoccho, 0), 'N0', 'vi-VN') AS [CocLan1SoTien],
    [dbo].[fn_DocTienBangChu](ISNULL(h.Sotiencoccho, 0)) AS [CocLan1BangChu],
    FORMAT(ISNULL(h.Sotiencochopdong, 0), 'N0', 'vi-VN') AS [CocLan2SoTien],
    [dbo].[fn_DocTienBangChu](ISNULL(h.Sotiencochopdong, 0)) AS [CocLan2BangChu],
    RIGHT('0' + CAST(DAY(h.Ngayhopdong) AS VARCHAR), 2) AS [CocNgay],
    RIGHT('0' + CAST(MONTH(h.Ngayhopdong) AS VARCHAR), 2) AS [CocThang],
    CAST(YEAR(h.Ngayhopdong) AS VARCHAR) AS [CocNam],
    
    -- Các biến phục vụ hiển thị động Phương thức thanh toán (BEO)
    FORMAT(ISNULL(h.Sotiencoccho, 0), 'N0', 'vi-VN') + ' VNĐ' AS [Dot1SoTien],
    ISNULL(CONVERT(VARCHAR(10), (
        SELECT TOP 1 b.DocumentDate 
        FROM tbmk_Biennhancoccho b 
        WHERE b.DocumentID = h.Sobiennhan
    ), 103), '...') AS [Dot1Ngay],
    ISNULL((
        SELECT TOP 1 NULLIF(b.HinhThuc, '') 
        FROM tbmk_Biennhancoccho b 
        WHERE b.DocumentID = h.Sobiennhan
    ), N'Chuyển khoản') AS [Dot1HinhThuc],
    
    FORMAT(ISNULL(h.Sotiencochopdong, 0), 'N0', 'vi-VN') + ' VNĐ' AS [Dot2SoTien],
    N'Chuyển khoản' AS [Dot2HinhThuc],
    
    ISNULL(NULLIF(h.Ghichu, ''), 
        CASE 
            WHEN (SELECT TOP 1 lt.Tenloaitiec FROM dmLoaihinhtiec lt WHERE lt.Loaitiecid = h.Loaitiecid) LIKE N'%Hội Nghị%' 
                THEN N'Thanh toán sau tiệc 07 ngày' 
            ELSE N'Thanh toán cuối tiệc.' 
        END
    ) AS [DotCuoiGhiChu],
    
    -- Các biến tính tổng tiền
    FORMAT(c_chuavat.CalcChuaVAT - c_phiphucvu.CalcPhiPhucVu, 'N0', 'vi-VN') AS [TongThanhTien],
    CASE 
        WHEN ISNULL(h.PhiPhucVu, 0) > 0 THEN CAST(CAST(h.PhiPhucVu AS DECIMAL(18,2)) AS VARCHAR) + '%'
        WHEN ISNULL(c_phiphucvu.CalcPhiPhucVu, 0) > 0 THEN FORMAT(c_phiphucvu.CalcPhiPhucVu, 'N0', 'vi-VN') + N' VNĐ'
        ELSE N'Miễn phí'
    END AS [MucPhiPhucVu],
    FORMAT(c_phiphucvu.CalcPhiPhucVu, 'N0', 'vi-VN') AS [PhiPhucVu],
    FORMAT(c_chuavat.CalcChuaVAT, 'N0', 'vi-VN') AS [TongCongChuaVAT],
    FORMAT(CASE WHEN ISNULL(h.PTThueVAT, 0) = 8 OR (ISNULL(h.PTThueVAT, 0) = 0 AND c_vat.CalcTienThueVAT > 0 AND ABS((c_vat.CalcTienThueVAT * 100.0 / NULLIF(c_chuavat.CalcChuaVAT, 0)) - 8) < 1.0) THEN c_vat.CalcTienThueVAT ELSE 0 END, 'N0', 'vi-VN') AS [VAT8],
    FORMAT(CASE WHEN ISNULL(h.PTThueVAT, 0) = 10 OR (ISNULL(h.PTThueVAT, 0) = 0 AND c_vat.CalcTienThueVAT > 0 AND NOT (ABS((c_vat.CalcTienThueVAT * 100.0 / NULLIF(c_chuavat.CalcChuaVAT, 0)) - 8) < 1.0)) THEN c_vat.CalcTienThueVAT ELSE 0 END, 'N0', 'vi-VN') AS [VAT10],
    FORMAT(ISNULL(h.Tongtienhopdong, 0), 'N0', 'vi-VN') AS [TongTienFormat],

    ISNULL(h.DieuKhoanBoSung, N'') AS [DieuKhoanBoSung],
    ISNULL(h.Noidunguudai, N'') AS [DSKhuyenMai],

    ISNULL(NULLIF(h.TenCtyHoaDon, ''),    ISNULL(k.Tenkh,  N'...')) AS [HDTenCty],
    ISNULL(NULLIF(h.DiaChiCtyHoaDon, ''), ISNULL(k.Diachi, N'...')) AS [HDDiaChi],
    ISNULL(NULLIF(h.MaSoThueHoaDon, ''),  N'...') AS [HDMaSoThue],
    ISNULL(k.Mail, N'...') AS [Email],

    dbo.fn_DOCX_DanhSachMenu(h.Sohopdong)     AS [DanhSachMenu],
    dbo.fn_DOCX_DanhSachThucUong(h.Sohopdong) AS [DanhSachThucUong],
    dbo.fn_DOCX_MenuTiec(h.Sohopdong)         AS [MenuTiec],
    dbo.fn_DOCX_MenuMan(h.Sohopdong)          AS [MenuMan],
    dbo.fn_DOCX_MenuChay(h.Sohopdong)         AS [MenuChay],
    dbo.fn_DOCX_MenuTongCong(h.Sohopdong)     AS [MenuTongCong],
    dbo.fn_DOCX_MenuTongCong(h.Sohopdong) AS [MenuTongCongMan],
    dbo.fn_DOCX_MenuTongCongChay(h.Sohopdong) AS [MenuTongCongChay],
    dbo.fn_DOCX_DichVuTinhPhi(h.Sohopdong)    AS [DichVuTinhPhi],
    dbo.fn_DOCX_DanhSachNgay(h.Sohopdong)     AS [DanhSachNgay],
    dbo.fn_DOCX_DanhSachDichVu(h.Sohopdong)   AS [DanhSachDichVu],

    [dbo].[fn_DocTienBangChu](ISNULL(h.Tongtienhopdong, 0)) AS [TongGiaTriTamTinhBangChu],
    FORMAT(ISNULL(h.Tongtienhopdong, 0), 'N0', 'vi-VN') AS [TongGiaTriTamTinh],

    (SELECT TOP 1 s.Tensanhtiec FROM tbmk_Hopdongsanhtiec hs INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid WHERE hs.Sohopdong = h.Sohopdong ORDER BY CASE WHEN hs.LoaiDiaDiem = 'TIEC' THEN 0 WHEN ISNULL(hs.IsSanhchinh, 0) = 0 THEN 1 ELSE 2 END, hs.Sanhtiecid) AS [TiecSanhTiec],
    ISNULL(NULLIF(h.BenAChucVuDaiDien, ''), ISNULL((SELECT TOP 1 CodeValue FROM [dbo].[SY_Setup] WHERE CodeID = 'HNChucVuNguoiDaiDien'), '')) AS [BenAChucVuDaiDien],
    k.Mail AS [BenBEmail],
    [dbo].[fn_DocTienBangChu](ISNULL(h.Sotiencoccho, 0)) AS [Dot1BangChu],
    ISNULL((SELECT TOP 1 s.SLBanMin * ISNULL(h.SoNguoiTrenBan, 10) FROM tbmk_Hopdongsanhtiec hs INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid WHERE hs.Sohopdong = h.Sohopdong ORDER BY CASE WHEN hs.LoaiDiaDiem IN ('TRIEN_LAM', 'HOI_NGHI') THEN 0 WHEN ISNULL(hs.IsSanhchinh, 0) = 1 THEN 1 ELSE 2 END, hs.Sanhtiecid), 0) AS [KhachToiThieu],
    ISNULL((SELECT TOP 1 CAST(s.ChieuRong AS VARCHAR) + 'm x ' + CAST(s.ChieuDai AS VARCHAR) + 'm' FROM tbmk_Hopdongsanhtiec hs INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid WHERE hs.Sohopdong = h.Sohopdong ORDER BY CASE WHEN hs.LoaiDiaDiem IN ('TRIEN_LAM', 'HOI_NGHI') THEN 0 WHEN ISNULL(hs.IsSanhchinh, 0) = 1 THEN 1 ELSE 2 END, hs.Sanhtiecid), '...') AS [KichThuocSanh],
    ISNULL((SELECT TOP 1 CAST(s.ChieuRong AS VARCHAR) + 'm x ' + CAST(s.ChieuDai AS VARCHAR) + 'm' FROM tbmk_Hopdongsanhtiec hs INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid WHERE hs.Sohopdong = h.Sohopdong ORDER BY CASE WHEN hs.LoaiDiaDiem = 'TIEC' THEN 0 WHEN ISNULL(hs.IsSanhchinh, 0) = 0 THEN 1 ELSE 2 END, hs.Sanhtiecid), '...') AS [KichThuocSanhPhu],
    ISNULL((SELECT TOP 1 s.KTSanKhau FROM tbmk_Hopdongsanhtiec hs INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid WHERE hs.Sohopdong = h.Sohopdong ORDER BY CASE WHEN hs.LoaiDiaDiem IN ('TRIEN_LAM', 'HOI_NGHI') THEN 0 WHEN ISNULL(hs.IsSanhchinh, 0) = 1 THEN 1 ELSE 2 END, hs.Sanhtiecid), '...') AS [KichThuocSanKhau],
    ISNULL((SELECT TOP 1 s.KTSanKhau FROM tbmk_Hopdongsanhtiec hs INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid WHERE hs.Sohopdong = h.Sohopdong ORDER BY CASE WHEN hs.LoaiDiaDiem = 'TIEC' THEN 0 WHEN ISNULL(hs.IsSanhchinh, 0) = 0 THEN 1 ELSE 2 END, hs.Sanhtiecid), '...') AS [KichThuocSanKhauPhu],
    STUFF((
        SELECT N', ' + s.Tensanhtiec
        FROM tbmk_Hopdongsanhtiec hs
        INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid
        WHERE hs.Sohopdong = h.Sohopdong
        ORDER BY hs.IsSanhchinh DESC, hs.Sanhtiecid
        FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 2, '') AS [SanhTiec],
    ISNULL((SELECT TOP 1 s.Tensanhtiec FROM tbmk_Hopdongsanhtiec hs INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid WHERE hs.Sohopdong = h.Sohopdong ORDER BY CASE WHEN hs.LoaiDiaDiem = 'TRIEN_LAM' THEN 0 WHEN ISNULL(hs.IsSanhchinh, 0) = 1 THEN 1 ELSE 2 END, hs.Sanhtiecid), '') AS [DiaDiemTrienLam],
    ISNULL((SELECT TOP 1 s.Tensanhtiec FROM tbmk_Hopdongsanhtiec hs INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid WHERE hs.Sohopdong = h.Sohopdong ORDER BY CASE WHEN hs.LoaiDiaDiem = 'HOI_NGHI' THEN 0 WHEN ISNULL(hs.IsSanhchinh, 0) = 1 THEN 1 ELSE 2 END, hs.Sanhtiecid), '') AS [DiaDiemHoiNghi],
    ISNULL((SELECT TOP 1 s.Tensanhtiec FROM tbmk_Hopdongsanhtiec hs INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid WHERE hs.Sohopdong = h.Sohopdong ORDER BY CASE WHEN hs.LoaiDiaDiem = 'TIEC' THEN 0 WHEN ISNULL(hs.IsSanhchinh, 0) = 0 THEN 1 ELSE 2 END, hs.Sanhtiecid), '') AS [DiaDiemTiec],
    ISNULL((
        SELECT TOP 1 CASE
            WHEN UPPER(ISNULL(t.AMPM, '')) IN ('AM', 'SANG', 'SANG_TRUA') OR t.Thoigian LIKE N'%sáng%' OR t.Thoigian LIKE N'%trưa%' THEN N'trưa'
            WHEN UPPER(ISNULL(t.AMPM, '')) IN ('PM', 'CHIEU', 'TOI') OR t.Thoigian LIKE N'%chiều%' OR t.Thoigian LIKE N'%tối%' THEN N'tối'
            ELSE N''
        END
        FROM tbmk_Hopdongsanhtiec hs
        LEFT JOIN dmThoigian t ON t.Thoigianid = COALESCE(NULLIF(hs.Thoigianid, ''), h.Thoigianid)
        WHERE hs.Sohopdong = h.Sohopdong
        ORDER BY CASE WHEN hs.LoaiDiaDiem IN ('HOI_NGHI', 'TRIEN_LAM') THEN 0 WHEN ISNULL(hs.IsSanhchinh, 0) = 1 THEN 1 ELSE 2 END, hs.Sanhtiecid
    ), '') AS [BuoiHoiNghi],
    ISNULL((
        SELECT TOP 1 CASE
            WHEN UPPER(ISNULL(t.AMPM, '')) IN ('AM', 'SANG', 'SANG_TRUA') OR t.Thoigian LIKE N'%sáng%' OR t.Thoigian LIKE N'%trưa%' THEN N'trưa'
            WHEN UPPER(ISNULL(t.AMPM, '')) IN ('PM', 'CHIEU', 'TOI') OR t.Thoigian LIKE N'%chiều%' OR t.Thoigian LIKE N'%tối%' THEN N'tối'
            ELSE N''
        END
        FROM tbmk_Hopdongsanhtiec hs
        LEFT JOIN dmThoigian t ON t.Thoigianid = COALESCE(NULLIF(hs.Thoigianid, ''), h.Thoigianid)
        WHERE hs.Sohopdong = h.Sohopdong
        ORDER BY CASE WHEN hs.LoaiDiaDiem = 'TIEC' THEN 0 WHEN ISNULL(hs.IsSanhchinh, 0) = 0 THEN 1 ELSE 2 END, hs.Sanhtiecid
    ), '') AS [BuoiTiec],
    ISNULL((
        SELECT TOP 1 t.Thoigian
        FROM tbmk_Hopdongsanhtiec hs
        LEFT JOIN dmThoigian t ON t.Thoigianid = COALESCE(NULLIF(hs.Thoigianid, ''), h.Thoigianid)
        WHERE hs.Sohopdong = h.Sohopdong
        ORDER BY CASE WHEN hs.LoaiDiaDiem IN ('HOI_NGHI', 'TRIEN_LAM') THEN 0 WHEN ISNULL(hs.IsSanhchinh, 0) = 1 THEN 1 ELSE 2 END, hs.Sanhtiecid
    ), '') AS [CaHoiNghi],
    ISNULL((
        SELECT TOP 1 t.Thoigian
        FROM tbmk_Hopdongsanhtiec hs
        LEFT JOIN dmThoigian t ON t.Thoigianid = COALESCE(NULLIF(hs.Thoigianid, ''), h.Thoigianid)
        WHERE hs.Sohopdong = h.Sohopdong
        ORDER BY CASE WHEN hs.LoaiDiaDiem = 'TIEC' THEN 0 WHEN ISNULL(hs.IsSanhchinh, 0) = 0 THEN 1 ELSE 2 END, hs.Sanhtiecid
    ), '') AS [CaTiec],
    ISNULL((SELECT TOP 1 m.TenMau FROM dmMauTrangTri m WHERE m.MauTrangTriID = h.MauTrangTriID), N'Mẫu tiêu chuẩn') AS [TenMauTrangTri],
    ISNULL((SELECT TOP 1 FORMAT(ISNULL(m.DonGia, 0), 'N0', 'vi-VN') FROM dmMauTrangTri m WHERE m.MauTrangTriID = h.MauTrangTriID), '0') AS [DonGiaMauTrangTri],
    ISNULL((SELECT TOP 1 m.HinhAnhUrl FROM dmMauTrangTri m WHERE m.MauTrangTriID = h.MauTrangTriID), '') AS [HinhAnhMauTrangTri],
    h.SoKhachThamQuanDuKien AS [SoKhachThamQuanDuKien],
    ISNULL(h.GioBatDauTrienLam, N'') AS [GioBatDauTrienLam],
    ISNULL(h.GioKetThucTrienLam, N'') AS [GioKetThucTrienLam],
    ISNULL(CONVERT(VARCHAR(10), h.TuNgaySetup, 103), '') AS [NgaySetupTrienLam],
    ISNULL(CONVERT(VARCHAR(10), h.Ngaytochuc, 103), '') AS [NgayTrienLam],
    ISNULL((
        SELECT TOP 1
            FORMAT(CAST(ROUND(s.Dongia / 4.0, 0) AS DECIMAL(18,0)), 'N0', 'vi-VN')
            + N'VNĐ++/giờ/sảnh'
        FROM tbmk_Hopdongsanhtiec hs
        INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid
        WHERE hs.Sohopdong = h.Sohopdong
        ORDER BY CASE WHEN hs.LoaiDiaDiem = 'TRIEN_LAM' THEN 0 WHEN ISNULL(hs.IsSanhchinh, 0) = 1 THEN 1 ELSE 2 END, hs.Sanhtiecid
    ), N'Theo đơn giá sảnh tại thời điểm phát sinh') AS [PhiThueSanhNgoaiGio],
    ISNULL((SELECT TOP 1 CASE WHEN hs.KieuSetup = 'ClassRoom' THEN ISNULL(s.ClassRoom, 0) WHEN hs.KieuSetup = 'Theater' THEN ISNULL(s.Theater, 0) WHEN hs.KieuSetup = 'Cluster' THEN ISNULL(s.ClusterHalfRound, 0) ELSE ISNULL(s.SLBanMax * 10, 0) END FROM tbmk_Hopdongsanhtiec hs INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid WHERE hs.Sohopdong = h.Sohopdong ORDER BY CASE WHEN hs.LoaiDiaDiem IN ('TRIEN_LAM', 'HOI_NGHI') THEN 0 WHEN ISNULL(hs.IsSanhchinh, 0) = 1 THEN 1 ELSE 2 END, hs.Sanhtiecid), 0) AS [SucChuaToiDa],
    ISNULL((SELECT TOP 1 CASE WHEN hs.KieuSetup = 'ClassRoom' THEN ISNULL(s.ClassRoom, 0) WHEN hs.KieuSetup = 'Theater' THEN ISNULL(s.Theater, 0) WHEN hs.KieuSetup = 'Cluster' THEN ISNULL(s.ClusterHalfRound, 0) ELSE ISNULL(s.SLBanMax * 10, 0) END FROM tbmk_Hopdongsanhtiec hs INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid WHERE hs.Sohopdong = h.Sohopdong ORDER BY CASE WHEN hs.LoaiDiaDiem = 'TIEC' THEN 0 WHEN ISNULL(hs.IsSanhchinh, 0) = 0 THEN 1 ELSE 2 END, hs.Sanhtiecid), 0) AS [SucChuaToiDaPhu],
    ISNULL((SELECT TOP 1 ISNULL(s.SLBanMin * 10, 0) FROM tbmk_Hopdongsanhtiec hs INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid WHERE hs.Sohopdong = h.Sohopdong ORDER BY CASE WHEN hs.LoaiDiaDiem = 'TIEC' THEN 0 WHEN ISNULL(hs.IsSanhchinh, 0) = 0 THEN 1 ELSE 2 END, hs.Sanhtiecid), 0) AS [SucChuaToiThieuPhu],
    ISNULL((SELECT TOP 1 s.Tensanhtiec FROM tbmk_Hopdongsanhtiec hs INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid WHERE hs.Sohopdong = h.Sohopdong ORDER BY CASE WHEN hs.LoaiDiaDiem = 'TIEC' THEN 0 WHEN ISNULL(hs.IsSanhchinh, 0) = 0 THEN 1 ELSE 2 END, hs.Sanhtiecid), '') AS [TenSanhTiecPhu],
    ISNULL((SELECT TOP 1 s.KTSanKhau FROM tbmk_Hopdongsanhtiec hs INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid WHERE hs.Sohopdong = h.Sohopdong ORDER BY hs.IsSanhchinh DESC), '...') AS [TenSanKhau],
    ISNULL((SELECT s.KTSanKhau FROM tbmk_Hopdongsanhtiec hs INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid WHERE hs.Sohopdong = h.Sohopdong ORDER BY hs.IsSanhchinh DESC, hs.Sanhtiecid OFFSET 1 ROWS FETCH NEXT 1 ROWS ONLY), '...') AS [TenSanKhauPhu],
    FORMAT(ISNULL((SELECT SUM(ISNULL(hd.Sotien, 0)) FROM tbmk_Hopdongdichvu hd WHERE hd.Sohopdong = h.Sohopdong), 0), 'N0', 'vi-VN') AS [TongTienDichVu],
    ISNULL(CONVERT(VARCHAR(10), (SELECT TOP 1 b.DocumentDate FROM tbmk_Biennhancoccho b WHERE b.DocumentID = h.Sobiennhan), 103), '...') AS [NgayThanhToanDatCoc],
    (SELECT TOP 1 s.Tensanhtiec FROM tbmk_Hopdongsanhtiec hs INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid WHERE hs.Sohopdong = h.Sohopdong ORDER BY hs.IsSanhchinh DESC) AS [Sanh],
    FORMAT(ISNULL(h.Tongtienhopdong, 0) - ISNULL(h.Sotiencoccho, 0) - ISNULL(h.Sotiencochopdong, 0), 'N0', 'vi-VN') AS [SoTienConLai],
    [dbo].[fn_DocTienBangChu](ISNULL(h.Tongtienhopdong, 0) - ISNULL(h.Sotiencoccho, 0) - ISNULL(h.Sotiencochopdong, 0)) AS [SoTienConLaiBangChu],
    FORMAT(ISNULL(h.Sotiencoccho, 0) + ISNULL(h.Sotiencochopdong, 0), 'N0', 'vi-VN') AS [SoTienDaDatCoc],
    FORMAT(ISNULL(h.Tongtienhopdong, 0), 'N0', 'vi-VN') AS [TongGiaTriQuyetToan],
    [dbo].[fn_DocTienBangChu](ISNULL(h.Tongtienhopdong, 0)) AS [TongGiaTriQuyetToanBangChu]

FROM tbmk_Hopdong h
LEFT JOIN dmkhachhang k ON h.Makh = k.Makh
CROSS APPLY (
    SELECT ISNULL(NULLIF(h.TongTienHopDongChuaVAT, 0), 0) AS DbChuaVAT
) c_db
CROSS APPLY (
    SELECT (
        -- Món mặn
        ISNULL((SELECT SUM(ISNULL(td.Dongia, 0)) FROM tbmk_Hopdongthucdonman td WHERE td.Sohopdong = h.Sohopdong), 0) 
        * (ISNULL(h.SobanManchinhthuc, 0) + ISNULL(h.SobanManduphong, 0))
        -- Món chay
        + ISNULL((SELECT SUM(ISNULL(td.Dongia, 0)) FROM tbmk_Hopdongthucdonchay td WHERE td.Sohopdong = h.Sohopdong), 0) 
        * (ISNULL(h.SobanChaychinhthuc, 0) + ISNULL(h.SobanChayduphong, 0))
        -- Thức uống
        + ISNULL((SELECT SUM(ISNULL(tu.Sotien, 0)) FROM tbmk_Hopdongthucuong tu WHERE tu.Sohopdong = h.Sohopdong), 0)
        -- Dịch vụ
        + ISNULL((SELECT SUM(ISNULL(dv.Sotien, 0)) FROM tbmk_Hopdongdichvu dv WHERE dv.Sohopdong = h.Sohopdong), 0)
        -- Phát sinh
        + ISNULL((SELECT SUM(ISNULL(ps.Soluong * ps.Dongia, 0)) FROM tbmk_HopdongPhatSinh ps WHERE ps.Sohopdong = h.Sohopdong), 0)
    ) AS RawSubTotal
) c_raw
CROSS APPLY (
    SELECT CASE 
        WHEN c_raw.RawSubTotal > 0 THEN c_raw.RawSubTotal * (1 + ISNULL(h.PhiPhucVu, 0) / 100.0)
        WHEN c_db.DbChuaVAT > 0 THEN c_db.DbChuaVAT
        ELSE h.Tongtienhopdong / (1 + ISNULL(h.PTThueVAT, 0) / 100.0)
    END AS CalcChuaVAT
) c_chuavat
CROSS APPLY (
    SELECT CASE 
        WHEN h.PhiPhucVu = 0 THEN 0
        WHEN c_raw.RawSubTotal > 0 THEN c_raw.RawSubTotal * (ISNULL(h.PhiPhucVu, 0) / 100.0)
        WHEN c_db.DbChuaVAT > 0 THEN ISNULL(h.TongTienPhiPhucVu, 0)
        ELSE (h.Tongtienhopdong / (1 + ISNULL(h.PTThueVAT, 0) / 100.0)) * (ISNULL(h.PhiPhucVu, 0) / (100.0 + ISNULL(h.PhiPhucVu, 0)))
    END AS CalcPhiPhucVu
) c_phiphucvu
CROSS APPLY (
    SELECT CASE 
        WHEN ISNULL(h.TienThueVAT, 0) > 0 THEN h.TienThueVAT
        ELSE ISNULL(h.Tongtienhopdong, 0) - c_chuavat.CalcChuaVAT
    END AS CalcTienThueVAT
) c_vat
WHERE ISNULL(h.IsDeleted, 0) = 0;
GO

/*
  Giữ toàn bộ cột tính toán của read model và tự bổ sung các cột gốc của
  tbmk_Hopdong chưa có trong read model. Các tên đã tồn tại không được lặp lại.
*/
DECLARE @AdditionalColumns NVARCHAR(MAX) = N'';
DECLARE @CreateViewSql NVARCHAR(MAX);

SELECT @AdditionalColumns = (
    SELECT N', source.' + QUOTENAME(sourceColumn.name)
    FROM sys.columns sourceColumn
    WHERE sourceColumn.object_id = OBJECT_ID(N'dbo.tbmk_Hopdong')
      AND NOT EXISTS (
          SELECT 1
          FROM sys.columns coreColumn
          WHERE coreColumn.object_id = OBJECT_ID(N'dbo.v_DanhSachHopDong_Core')
            AND coreColumn.name = sourceColumn.name
      )
    ORDER BY sourceColumn.column_id
    FOR XML PATH(''), TYPE
).value('.', 'NVARCHAR(MAX)');

SET @CreateViewSql =
    N'CREATE VIEW dbo.v_DanhSachHopDong AS
      SELECT core.*' + ISNULL(@AdditionalColumns, N'') + N'
      FROM dbo.v_DanhSachHopDong_Core core
      INNER JOIN dbo.tbmk_Hopdong source
          ON source.Sohopdong = core.Sohopdong;';

EXEC sys.sp_executesql @CreateViewSql;
GO

/* Tự đăng ký metadata cơ bản cho mọi cột mới để API có thể trả schema. */
IF OBJECT_ID(N'dbo.SY_FmtFldTbl', N'U') IS NOT NULL
BEGIN
    UPDATE dictionary
    SET dictionary.FormatID = CASE
            WHEN viewColumn.system_type_id = 104 THEN 'sw'
            WHEN viewColumn.system_type_id IN (40, 42, 43, 58, 61) THEN 'D'
            WHEN viewColumn.system_type_id = 41 THEN 'H'
            WHEN viewColumn.system_type_id IN (48, 52, 56, 59, 60, 62, 106, 108, 122, 127) THEN 'N0'
            ELSE 't'
        END
    FROM dbo.SY_FmtFldTbl dictionary
    INNER JOIN sys.columns viewColumn
        ON viewColumn.object_id = OBJECT_ID(N'dbo.v_DanhSachHopDong')
       AND viewColumn.name = dictionary.FieldName
    WHERE NULLIF(LTRIM(RTRIM(dictionary.FormatID)), '') IS NULL
       OR NOT EXISTS (
           SELECT 1
           FROM dbo.SY_FmatTbl formatDefinition
           WHERE formatDefinition.FormatID = dictionary.FormatID
       );

    INSERT INTO dbo.SY_FmtFldTbl (FormName, FieldName, CaptionVN, FormatID)
    SELECT
        'v_DanhSachHopDong',
        viewColumn.name,
        CONVERT(NVARCHAR(255), viewColumn.name),
        CASE
            WHEN viewColumn.system_type_id = 104 THEN 'sw'
            WHEN viewColumn.system_type_id IN (40, 42, 43, 58, 61) THEN 'D'
            WHEN viewColumn.system_type_id = 41 THEN 'H'
            WHEN viewColumn.system_type_id IN (48, 52, 56, 59, 60, 62, 106, 108, 122, 127) THEN 'N0'
            ELSE 't'
        END
    FROM sys.columns viewColumn
    WHERE viewColumn.object_id = OBJECT_ID(N'dbo.v_DanhSachHopDong')
      AND NOT EXISTS (
          SELECT 1
          FROM dbo.SY_FmtFldTbl dictionary
          WHERE dictionary.FieldName = viewColumn.name
      );
END;
GO
