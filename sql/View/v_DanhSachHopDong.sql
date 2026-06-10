IF EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[v_DanhSachHopDong]'))
    DROP VIEW [dbo].[v_DanhSachHopDong]
GO
CREATE VIEW [dbo].[v_DanhSachHopDong] AS
SELECT 
    h.Sohopdong AS [Id], -- ÄÃ³ng vai trÃ² lÃ  PrimaryKey cho Frontend

    h.Sohopdong AS [Sohopdong], -- Cá»™t khoÃ¡ chÃ­nh tháº­t
    h.Sobiennhan,
    h.Makh,
    
    -- Láº¥y thÃ´ng tin khÃ¡ch hÃ ng tá»« dmkhachhang
    CASE 
        WHEN k.Tenchure IS NOT NULL AND k.Tencodau IS NOT NULL AND k.Tenchure <> '' AND k.Tencodau <> ''
            THEN k.Tenchure + ' & ' + k.Tencodau
        ELSE ISNULL(k.Tenkh, N'KhÃ¡ch vÃ£ng lai')
    END AS [TenKhachHang],
    
    CASE 
        WHEN k.Tenchure IS NOT NULL AND k.Tencodau IS NOT NULL AND k.Tenchure <> '' AND k.Tencodau <> ''
            THEN k.Tenchure + ' & ' + k.Tencodau
        ELSE ISNULL(k.Tenkh, N'KhÃ¡ch vÃ£ng lai')
    END AS [TenCongTy],
    
    CASE 
        WHEN ISNULL((SELECT MAX(td.LanThayDoi) FROM tbmk_Thaydoi td WHERE td.Sohopdong = h.Sohopdong AND ISNULL(td.IsDeleted, 0) = 0), 0) = 0
            THEN N'PHIáº¾U Äáº¶T TIá»†C'
        ELSE N'PHIáº¾U Äáº¶T TIá»†C THAY Äá»”I Láº¦N ' + CAST((SELECT MAX(td.LanThayDoi) FROM tbmk_Thaydoi td WHERE td.Sohopdong = h.Sohopdong AND ISNULL(td.IsDeleted, 0) = 0) AS NVARCHAR(10))
    END AS [TieuDePhieu],
    
    ISNULL(k.Dienthoai, ISNULL(k.DTchure, k.DTcodau)) AS [DienThoai],
    h.Ngaytochuc AS [NgayToChuc],
    h.TuNgaySetup AS [TuNgaySetup],
    h.NgayTraSanhDV AS [NgayTraSanhDV],
    
    ISNULL(h.TongSoBan, 0) AS [SoBan],
    
    (
        SELECT TOP 1 s.Tensanhtiec 
        FROM tbmk_Hopdongsanhtiec hs 
        INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid 
        WHERE hs.Sohopdong = h.Sohopdong
        ORDER BY hs.IsSanhchinh DESC, hs.Sanhtiecid
    ) AS [SanhDat],
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
        WHEN h.IsHuy = 1 THEN N'ÄÃ£ Há»§y'
        WHEN h.IsKetthuc = 1 THEN N'ÄÃ£ Quyáº¿t ToÃ¡n'
        ELSE N'ÄÃ£ KÃ½'
    END AS [TrangThai],

    -- CÃC TRÆ¯á»œNG THÃŠM Má»šI Äá»‚ PHá»¤C Vá»¤ NHáº¬P LIá»†U/Sá»¬A Há»¢P Äá»’NG (ShowInForm = 1, ShowInGrid = 0)
    k.Tenchure,
    k.Tencodau,
    k.Diachi,
    k.Mail,
    h.Ngayhopdong,
    h.Nhamngay,
    h.Loaitiecid,
    (SELECT TOP 1 tm.TemplateFile FROM tbmk_LoaitiecAddfile tm WHERE tm.FormName = 'frmHopDong' AND tm.Loaitiecid = h.Loaitiecid) AS [TemplateFile],
    h.Thoigianid,
    h.SobanManchinhthuc,
    h.SobanManduphong,
    h.SobanChaychinhthuc,
    h.SobanChayduphong,
    h.Sotiencoccho AS DaCocVND,
    h.Sotiencochopdong,
    h.Tongtiencoc,
    h.Ghichu,
    h.JsonLichTrinh,
    (
        SELECT 
            hs.Sanhtiecid AS [Sanhtiecid],
            CAST(ISNULL(hs.IsSanhchinh, 0) AS BIT) AS [IsSanhchinh],
            hs.KieuSetup AS [KieuSetup],
            hs.Ghichuct AS [Ghichuct]
        FROM tbmk_Hopdongsanhtiec hs 
        WHERE hs.Sohopdong = h.Sohopdong 
        ORDER BY hs.IsSanhchinh DESC, hs.Sanhtiecid ASC
        FOR JSON PATH
    ) AS [JsonSanhTiec],
    
    -- ==========================================
    -- CÃC Cá»˜T Dá»® LIá»†U ÄÆ¯á»¢C FORMAT Sáº´N CHO IN áº¤N 
    -- DÃ¹ng Ä‘á»ƒ binding vÃ o file hop_dong.docx (docxtemplater)
    -- ==========================================
    -- (ÄÃ£ cÃ³ sáºµn h.Sohopdong á»Ÿ trÃªn nÃªn khÃ´ng cáº§n táº¡o SoHopDong ná»¯a, trong Word sáº½ dÃ¹ng biáº¿n {Sohopdong})
    RIGHT('0' + CAST(DAY(h.Ngayhopdong) AS VARCHAR), 2) AS [NgayLapHD],
    RIGHT('0' + CAST(MONTH(h.Ngayhopdong) AS VARCHAR), 2) AS [ThangLapHD],
    CAST(YEAR(h.Ngayhopdong) AS VARCHAR) AS [NamLapHD],

    -- ThÃ´ng tin BÃªn A (cÃ³ _ cho hop_dong.docx cÅ©)
    (SELECT TOP 1 CodeValue FROM [dbo].[SY_Setup] WHERE CodeID = 'HNNguoiDaiDien') AS [BenANguoiDaiDien],
    (SELECT TOP 1 CodeValue FROM [dbo].[SY_Setup] WHERE CodeID = 'HNChucVuNguoiDaiDien') AS [BenAChucVu],
    ISNULL(h.UserCreate, '...') AS [BenANhanVienPhuTrach],
    (SELECT TOP 1 CodeValue FROM [dbo].[SY_Setup] WHERE CodeID = 'Com3') AS [BenASDTNhanVien],
    (SELECT TOP 1 CodeValue FROM [dbo].[SY_Setup] WHERE CodeID = 'BenADiaChi') AS [BenADiaChi],
    (SELECT TOP 1 CodeValue FROM [dbo].[SY_Setup] WHERE CodeID = 'BenAEmail')  AS [BenAEmail],
    (SELECT TOP 1 CodeValue FROM [dbo].[SY_Setup] WHERE CodeID = 'BenATenCongTy') AS [BenATenCongTy],
    (SELECT TOP 1 CodeValue FROM [dbo].[SY_Setup] WHERE CodeID = 'BenASDT') AS [BenASDT],
    (SELECT TOP 1 CodeValue FROM [dbo].[SY_Setup] WHERE CodeID = 'BenAMST') AS [BenAMST],


    -- ThÃ´ng tin BÃªn B
    CASE 
        WHEN k.Tenchure IS NOT NULL AND k.Tencodau IS NOT NULL AND k.Tenchure <> '' AND k.Tencodau <> ''
            THEN k.Tenchure + ' & ' + k.Tencodau
        ELSE ISNULL(k.Tenkh, N'KhÃ¡ch vÃ£ng lai')
    END AS [BenBTenDaiDien],
    ISNULL(h.NguoinhanTT, CASE WHEN k.Tenchure <> '' AND k.Tencodau <> '' THEN k.Tenchure + ' & ' + k.Tencodau ELSE ISNULL(k.Tenkh, N'KhÃ¡ch vÃ£ng lai') END) AS [BenBTenChuTiec],
    ISNULL(NULLIF(k.CMNDDaiDien, ''), ISNULL(NULLIF(k.CMNDnguoidd, ''), ISNULL(NULLIF(k.CMNDchure, ''), '...'))) AS [BenBCCCD],
    ISNULL(k.Diachi, '...') AS [BenBDiaChi],
    ISNULL(k.Dienthoai, ISNULL(k.DTchure, k.DTcodau)) AS [BenBDienThoai],
    '' AS [BenBChucVu],

    -- ThÃ´ng tin Tiá»‡c
    ISNULL(h.TuGioDenGioSetup, '...') AS [SetupBatDau],
    ISNULL(h.DenGioSetup, '...') AS [SetupKetThuc],
    N'VÃ o hÃ ng hÃ³a' AS [SetupNoiDung1],
    ISNULL(h.GhiChuSetup, N'SETUP: KhÃ´ng mÃ¡y láº¡nh') AS [SetupNoiDung2],
    N'RHS: CÃ³ ATAS, Led; khÃ´ng mÃ¡y láº¡nh' AS [ToChucNoiDung],
    N'Ra hÃ ng hÃ³a' AS [OutNoiDung],
    ISNULL(h.GioDienRaSuKien, '...') AS [TiecGioBatDau],

    -- CÃ¡c trÆ°á»ng lá»‹ch trÃ¬nh Ä‘á»™ng dáº¡ng JSON phá»¥c vá»¥ in áº¥n BEO má»›i
    -- Náº¿u Ä‘Ã£ cÃ³ JsonLichTrinh lÆ°u trong DB thÃ¬ Æ°u tiÃªn láº¥y, ngÆ°á»£c láº¡i tráº£ vá» máº£ng rá»—ng []
    ISNULL(NULLIF(h.JsonLichTrinh, ''), '[]') AS [LichTrinh],
    
    (
        SELECT 
            t.STT AS [STT],
            t.SoTien AS [SoTien],
            t.Ngay AS [Ngay],
            t.NoiDung AS [NoiDung]
        FROM (
            SELECT 
                1 AS STT, 
                FORMAT(ISNULL(h.Sotiencoccho, 0), 'N0', 'vi-VN') + ' VNÄ' AS SoTien, 
                ISNULL(CONVERT(VARCHAR(10), (SELECT TOP 1 b.DocumentDate FROM tbmk_Biennhancoccho b WHERE b.DocumentID = h.Sobiennhan), 103), '...') AS Ngay,
                N'Äáº·t cá»c giá»¯ chá»—' AS NoiDung
            WHERE ISNULL(h.Sotiencoccho, 0) > 0

            UNION ALL

            SELECT 
                2 AS STT, 
                FORMAT(ISNULL(h.Sotiencochopdong, 0), 'N0', 'vi-VN') + ' VNÄ' AS SoTien, 
                ISNULL(CONVERT(VARCHAR(10), h.Ngayhopdong, 103), '...') AS Ngay,
                N'Äáº·t cá»c kÃ½ há»£p Ä‘á»“ng' AS NoiDung
            WHERE ISNULL(h.Sotiencochopdong, 0) > 0

            UNION ALL

            SELECT 
                CASE WHEN ISNULL(h.Sotiencochopdong, 0) > 0 THEN 3 ELSE 2 END AS STT, 
                N'Thanh toÃ¡n cÃ²n láº¡i' AS SoTien, 
                ISNULL(CONVERT(VARCHAR(10), h.Ngaytochuc, 103), '...') AS Ngay,
                ISNULL(NULLIF(h.Ghichu, ''), 
                    CASE 
                        WHEN (SELECT TOP 1 lt.Tenloaitiec FROM dmLoaihinhtiec lt WHERE lt.Loaitiecid = h.Loaitiecid) LIKE N'%Há»™i Nghá»‹%' 
                            THEN N'Thanh toÃ¡n sau tiá»‡c 07 ngÃ y' 
                        ELSE N'Thanh toÃ¡n cuá»‘i tiá»‡c.' 
                    END
                ) AS NoiDung
        ) t
        ORDER BY t.STT
        FOR JSON PATH
    ) AS [LichTrinhThanhToan],
    
    (
        SELECT 
            CASE WHEN hs.IsSanhchinh = 1 THEN N'Há»™i nghá»‹ / Tiá»‡c chÃ­nh' ELSE N'Tiá»‡c' END AS [LoaiPhong],
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
            CASE 
                WHEN hs.KieuSetup = 'ClassRoom' THEN N'Lá»›p há»c'
                WHEN hs.KieuSetup = 'Theater' THEN N'NhÃ  hÃ¡t'
                WHEN hs.KieuSetup = 'Cluster' THEN N'BÃ n trÃ²n xoay 1 phÃ­a'
                ELSE N'BÃ n trÃ²n (Banquet)'
            END + 
            CASE 
                WHEN ISNULL(hs.Ghichuct, '') <> '' THEN N' (' + hs.Ghichuct + N')'
                ELSE N''
            END AS [SetupBanGhe]
        FROM tbmk_Hopdongsanhtiec hs
        INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid
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
    
    (SELECT TOP 1 s.Tensanhtiec FROM tbmk_Hopdongsanhtiec hs INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid WHERE hs.Sohopdong = h.Sohopdong) AS [TenSanhTiec],
    (SELECT TOP 1 s.SLBanMin FROM tbmk_Hopdongsanhtiec hs INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid WHERE hs.Sohopdong = h.Sohopdong) AS [SanhQuyMoMin],
    (SELECT TOP 1 s.SLBanMax FROM tbmk_Hopdongsanhtiec hs INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid WHERE hs.Sohopdong = h.Sohopdong) AS [SanhQuyMoMax],
    
    -- TÃªn loáº¡i hÃ¬nh tiá»‡c (computed tá»« dmLoaihinhtiec, dÃ¹ng cho in áº¥n Word)
    ISNULL((SELECT TOP 1 lt.Tenloaitiec FROM dmLoaihinhtiec lt WHERE lt.Loaitiecid = h.Loaitiecid), '') AS [TiecLoaiTiec],
    ISNULL((
        SELECT 
            CASE 
                -- Náº¿u cÃ³ sáº£nh 2 vÃ  loáº¡i hÃ¬nh tiá»‡c cÃ³ 2 pháº§n (dáº¥u +)
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
                -- Náº¿u chá»‰ cÃ³ 1 sáº£nh
                ELSE 
                    lt.Tenloaitiec 
                    + ' ' 
                    + ISNULL((SELECT TOP 1 s.Tensanhtiec FROM tbmk_Hopdongsanhtiec hs INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid WHERE hs.Sohopdong = h.Sohopdong ORDER BY hs.IsSanhchinh DESC, hs.Sanhtiecid), '')
            END
        FROM dmLoaihinhtiec lt 
        WHERE lt.Loaitiecid = h.Loaitiecid
    ), '') AS [LoaiHinhSuKien],
    
    ISNULL(h.SobanManchinhthuc, 0) + ISNULL(h.SobanChaychinhthuc, 0) AS [TiecSoBanChinhThuc],
    ISNULL(h.SoBanTang, 0) AS [TiecSoBanTang],
    ISNULL(h.SobanManduphong, 0) + ISNULL(h.SobanChayduphong, 0) AS [TiecSoBanDuPhong],
    ISNULL(h.SoNguoiTrenBan, 10) AS [TiecSoKhach1Ban],
    
    -- ThÃ´ng tin Cá»c & Khuyáº¿n mÃ£i
    FORMAT(ISNULL(h.Sotiencoccho, 0), 'N0', 'vi-VN') AS [CocLan1SoTien],
    [dbo].[fn_DocTienBangChu](ISNULL(h.Sotiencoccho, 0)) AS [CocLan1BangChu],
    FORMAT(ISNULL(h.Sotiencochopdong, 0), 'N0', 'vi-VN') AS [CocLan2SoTien],
    [dbo].[fn_DocTienBangChu](ISNULL(h.Sotiencochopdong, 0)) AS [CocLan2BangChu],
    RIGHT('0' + CAST(DAY(h.Ngayhopdong) AS VARCHAR), 2) AS [CocNgay],
    RIGHT('0' + CAST(MONTH(h.Ngayhopdong) AS VARCHAR), 2) AS [CocThang],
    CAST(YEAR(h.Ngayhopdong) AS VARCHAR) AS [CocNam],
    
    -- CÃ¡c biáº¿n phá»¥c vá»¥ hiá»ƒn thá»‹ Ä‘á»™ng PhÆ°Æ¡ng thá»©c thanh toÃ¡n (BEO)
    FORMAT(ISNULL(h.Sotiencoccho, 0), 'N0', 'vi-VN') + ' VNÄ' AS [Dot1SoTien],
    ISNULL(CONVERT(VARCHAR(10), (
        SELECT TOP 1 b.DocumentDate 
        FROM tbmk_Biennhancoccho b 
        WHERE b.DocumentID = h.Sobiennhan
    ), 103), '...') AS [Dot1Ngay],
    ISNULL((
        SELECT TOP 1 NULLIF(b.HinhThuc, '') 
        FROM tbmk_Biennhancoccho b 
        WHERE b.DocumentID = h.Sobiennhan
    ), N'Chuyá»ƒn khoáº£n') AS [Dot1HinhThuc],
    
    FORMAT(ISNULL(h.Sotiencochopdong, 0), 'N0', 'vi-VN') + ' VNÄ' AS [Dot2SoTien],
    N'Chuyá»ƒn khoáº£n' AS [Dot2HinhThuc],
    
    ISNULL(NULLIF(h.Ghichu, ''), 
        CASE 
            WHEN (SELECT TOP 1 lt.Tenloaitiec FROM dmLoaihinhtiec lt WHERE lt.Loaitiecid = h.Loaitiecid) LIKE N'%Há»™i Nghá»‹%' 
                THEN N'Thanh toÃ¡n sau tiá»‡c 07 ngÃ y' 
            ELSE N'Thanh toÃ¡n cuá»‘i tiá»‡c.' 
        END
    ) AS [DotCuoiGhiChu],
    


    -- CÃ¡c biáº¿n tÃ­nh tá»•ng tiá»n
    FORMAT(ISNULL(h.TongTienHopDongChuaVAT, 0) - ISNULL(h.TongTienPhiPhucVu, 0), 'N0', 'vi-VN') AS [TongThanhTien],
    CAST(ISNULL(h.PhiPhucVu, 0) AS VARCHAR) + '%' AS [MucPhiPhucVu],
    FORMAT(ISNULL(h.TongTienPhiPhucVu, 0), 'N0', 'vi-VN') AS [PhiPhucVu],
    FORMAT(ISNULL(h.TongTienHopDongChuaVAT, 0), 'N0', 'vi-VN') AS [TongCongChuaVAT],
    CASE WHEN h.PTThueVAT = 8 THEN FORMAT(ISNULL(h.TienThueVAT, 0), 'N0', 'vi-VN') ELSE '0' END AS [VAT8],
    CASE WHEN h.PTThueVAT = 10 THEN FORMAT(ISNULL(h.TienThueVAT, 0), 'N0', 'vi-VN') ELSE '0' END AS [VAT10],
    FORMAT(ISNULL(h.Tongtienhopdong, 0), 'N0', 'vi-VN') AS [TongTienFormat],

    ISNULL(h.Ghichu, '') AS [DieuKhoanBoSung],
    ISNULL(h.Noidunguudai, '') AS [DSKhuyenMai],

    -- ==========================================
    -- THÃ”NG TIN XUáº¤T HÃ“A ÄÆ N GTGT (Äiá»u 6)
    -- ==========================================
    ISNULL(h.TenCtyHoaDon,    N'...') AS [HDTenCty],
    ISNULL(h.DiaChiCtyHoaDon, N'...') AS [HDDiaChi],
    ISNULL(h.MaSoThueHoaDon,  N'...') AS [HDMaSoThue],
    ISNULL(k.Mail, N'...') AS [Email]
    
FROM tbmk_Hopdong h
LEFT JOIN dmkhachhang k ON h.Makh = k.Makh
WHERE ISNULL(h.IsDeleted, 0) = 0;
GO
