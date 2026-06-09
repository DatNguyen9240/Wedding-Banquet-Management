USE [QLTiec]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Ensure NoteBaoVe, NoteKyThuat, NoteBieuNgu columns exist on tbmk_Hopdong
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[tbmk_Hopdong]') AND name = 'NoteBaoVe')
BEGIN
    ALTER TABLE tbmk_Hopdong ADD NoteBaoVe NVARCHAR(1000) NULL;
END
GO
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[tbmk_Hopdong]') AND name = 'NoteKyThuat')
BEGIN
    ALTER TABLE tbmk_Hopdong ADD NoteKyThuat NVARCHAR(1000) NULL;
END
GO
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[tbmk_Hopdong]') AND name = 'NoteBieuNgu')
BEGIN
    ALTER TABLE tbmk_Hopdong ADD NoteBieuNgu NVARCHAR(1000) NULL;
END
GO
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[tbmk_Hopdong]') AND name = 'NoteLobby')
BEGIN
    ALTER TABLE tbmk_Hopdong ADD NoteLobby NVARCHAR(1000) NULL;
END
GO
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[tbmk_Hopdong]') AND name = 'JsonLichTrinh')
BEGIN
    ALTER TABLE tbmk_Hopdong ADD JsonLichTrinh NVARCHAR(MAX) NULL;
END
GO

-- =============================================
IF EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[v_DanhSachHopDong]'))
    DROP VIEW [dbo].[v_DanhSachHopDong]
GO
CREATE VIEW [dbo].[v_DanhSachHopDong] AS
SELECT 
    h.Sohopdong AS [Id], -- Đóng vai trò là PrimaryKey cho Frontend

    h.Sohopdong AS [Sohopdong], -- Cột khoá chính thật
    h.Sobiennhan,
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
        WHEN h.IsHuy = 1 THEN N'Đã Hủy'
        WHEN h.IsKetthuc = 1 THEN N'Đã Quyết Toán'
        ELSE N'Đã Ký'
    END AS [TrangThai],

    -- CÁC TRƯỜNG THÊM MỚI ĐỂ PHỤC VỤ NHẬP LIỆU/SỬA HỢP ĐỒNG (ShowInForm = 1, ShowInGrid = 0)
    k.Tenchure,
    k.Tencodau,
    k.Diachi,
    k.Mail,
    h.Ngayhopdong,
    h.Nhamngay,
    h.Loaitiecid,
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
    -- CÁC CỘT DỮ LIỆU ĐƯỢC FORMAT SẴN CHO IN ẤN 
    -- Dùng để binding vào file hop_dong.docx (docxtemplater)
    -- ==========================================
    -- (Đã có sẵn h.Sohopdong ở trên nên không cần tạo SoHopDong nữa, trong Word sẽ dùng biến {Sohopdong})
    RIGHT('0' + CAST(DAY(h.Ngayhopdong) AS VARCHAR), 2) AS [NgayLapHD],
    RIGHT('0' + CAST(MONTH(h.Ngayhopdong) AS VARCHAR), 2) AS [ThangLapHD],
    CAST(YEAR(h.Ngayhopdong) AS VARCHAR) AS [NamLapHD],

    -- Thông tin Bên A (có _ cho hop_dong.docx cũ)
    (SELECT TOP 1 CodeValue FROM [dbo].[SY_Setup] WHERE CodeID = 'HNNguoiDaiDien') AS [BenANguoiDaiDien],
    (SELECT TOP 1 CodeValue FROM [dbo].[SY_Setup] WHERE CodeID = 'HNChucVuNguoiDaiDien') AS [BenAChucVu],
    ISNULL(h.UserCreate, '...') AS [BenANhanVienPhuTrach],
    (SELECT TOP 1 CodeValue FROM [dbo].[SY_Setup] WHERE CodeID = 'Com3') AS [BenASDTNhanVien],
    (SELECT TOP 1 CodeValue FROM [dbo].[SY_Setup] WHERE CodeID = 'BenADiaChi') AS [BenADiaChi],
    (SELECT TOP 1 CodeValue FROM [dbo].[SY_Setup] WHERE CodeID = 'BenAEmail')  AS [BenAEmail],
    (SELECT TOP 1 CodeValue FROM [dbo].[SY_Setup] WHERE CodeID = 'BenATenCongTy') AS [BenATenCongTy],
    (SELECT TOP 1 CodeValue FROM [dbo].[SY_Setup] WHERE CodeID = 'BenASDT') AS [BenASDT],
    (SELECT TOP 1 CodeValue FROM [dbo].[SY_Setup] WHERE CodeID = 'BenAMST') AS [BenAMST],


    -- Thông tin Bên B
    CASE 
        WHEN k.Tenchure IS NOT NULL AND k.Tencodau IS NOT NULL AND k.Tenchure <> '' AND k.Tencodau <> ''
            THEN k.Tenchure + ' & ' + k.Tencodau
        ELSE ISNULL(k.Tenkh, N'Khách vãng lai')
    END AS [BenBTenDaiDien],
    ISNULL(h.NguoinhanTT, CASE WHEN k.Tenchure <> '' AND k.Tencodau <> '' THEN k.Tenchure + ' & ' + k.Tencodau ELSE ISNULL(k.Tenkh, N'Khách vãng lai') END) AS [BenBTenChuTiec],
    ISNULL(NULLIF(k.CMNDDaiDien, ''), ISNULL(NULLIF(k.CMNDnguoidd, ''), ISNULL(NULLIF(k.CMNDchure, ''), '...'))) AS [BenBCCCD],
    ISNULL(k.Diachi, '...') AS [BenBDiaChi],
    ISNULL(k.Dienthoai, ISNULL(k.DTchure, k.DTcodau)) AS [BenBDienThoai],
    '' AS [BenBChucVu],

    -- Thông tin Tiệc
    ISNULL(h.TuGioDenGioSetup, '...') AS [SetupBatDau],
    ISNULL(h.DenGioSetup, '...') AS [SetupKetThuc],
    N'Vào hàng hóa' AS [SetupNoiDung1],
    ISNULL(h.GhiChuSetup, N'SETUP: Không máy lạnh') AS [SetupNoiDung2],
    N'RHS: Có ATAS, Led; không máy lạnh' AS [ToChucNoiDung],
    N'Ra hàng hóa' AS [OutNoiDung],
    ISNULL(h.GioDienRaSuKien, '...') AS [TiecGioBatDau],

    -- Các trường lịch trình động dạng JSON phục vụ in ấn BEO mới
    -- Nếu đã có JsonLichTrinh lưu trong DB thì ưu tiên lấy, ngược lại dùng fallback tự sinh
    ISNULL(NULLIF(h.JsonLichTrinh, ''), (
        SELECT 
            t.BatDau AS [BatDau],
            t.KetThuc AS [KetThuc],
            t.Sanh AS [Sanh],
            t.NoiDung AS [NoiDung]
        FROM (
            -- SETUP 1
            SELECT 
                ISNULL(h.TuGioDenGioSetup, '...') AS BatDau, 
                ISNULL(h.DenGioSetup, '...') AS KetThuc, 
                s.Tensanhtiec AS Sanh, 
                N'Vào hàng hóa' AS NoiDung,
                1 AS STT
            FROM tbmk_Hopdongsanhtiec hs 
            INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid 
            WHERE hs.Sohopdong = h.Sohopdong

            UNION ALL

            -- SETUP 2
            SELECT 
                N'13h00' AS BatDau, 
                N'17h00' AS KetThuc, 
                s.Tensanhtiec AS Sanh, 
                ISNULL(h.GhiChuSetup, N'SETUP: Không máy lạnh') AS NoiDung,
                2 AS STT
            FROM tbmk_Hopdongsanhtiec hs 
            INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid 
            WHERE hs.Sohopdong = h.Sohopdong

            UNION ALL

            -- TOCHUC 1: RHS (Chạy ở Sảnh chính)
            SELECT 
                ISNULL(h.GioDienRaSuKien, '10h00') AS BatDau, 
                ISNULL(h.GioKetThucSuKien, '12h00') AS KetThuc, 
                s.Tensanhtiec AS Sanh, 
                N'RHS: Có ATAS, Led; không máy lạnh' AS NoiDung,
                3 AS STT
            FROM tbmk_Hopdongsanhtiec hs 
            INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid 
            WHERE hs.Sohopdong = h.Sohopdong AND hs.IsSanhchinh = 1

            UNION ALL

            -- TOCHUC 2: HỘI NGHỊ (Chạy ở Sảnh chính)
            SELECT 
                N'13h00' AS BatDau, 
                N'17h00' AS KetThuc, 
                s.Tensanhtiec AS Sanh, 
                N'HỘI NGHỊ' AS NoiDung,
                4 AS STT
            FROM tbmk_Hopdongsanhtiec hs 
            INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid 
            WHERE hs.Sohopdong = h.Sohopdong AND hs.IsSanhchinh = 1

            UNION ALL

            -- TOCHUC 3: TIỆC
            SELECT 
                N'18h00' AS BatDau, 
                N'22h00' AS KetThuc, 
                ISNULL(
                    (SELECT s2.Tensanhtiec 
                     FROM tbmk_Hopdongsanhtiec hs2 
                     INNER JOIN dmSanhtiec s2 ON hs2.Sanhtiecid = s2.Sanhtiecid 
                     WHERE hs2.Sohopdong = h.Sohopdong AND hs2.IsSanhchinh = 0),
                    (SELECT s3.Tensanhtiec 
                     FROM tbmk_Hopdongsanhtiec hs3 
                     INNER JOIN dmSanhtiec s3 ON hs3.Sanhtiecid = s3.Sanhtiecid 
                     WHERE hs3.Sohopdong = h.Sohopdong AND hs3.IsSanhchinh = 1)
                ) AS Sanh, 
                N'TIỆC' AS NoiDung,
                5 AS STT

            UNION ALL

            -- OUT
            SELECT 
                N'Trước 10h sáng' AS BatDau, 
                N'' AS KetThuc, 
                s.Tensanhtiec AS Sanh, 
                N'Ra hàng hóa' AS NoiDung,
                6 AS STT
            FROM tbmk_Hopdongsanhtiec hs 
            INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid 
            WHERE hs.Sohopdong = h.Sohopdong
        ) t
        ORDER BY t.STT
        FOR JSON PATH
    )) AS [LichTrinh],
    
    (
        SELECT 
            t.STT AS [STT],
            t.SoTien AS [SoTien],
            t.Ngay AS [Ngay],
            t.NoiDung AS [NoiDung]
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
            CASE 
                WHEN hs.KieuSetup = 'ClassRoom' THEN N'Lớp học'
                WHEN hs.KieuSetup = 'Theater' THEN N'Nhà hát'
                WHEN hs.KieuSetup = 'Cluster' THEN N'Bàn tròn xoay 1 phía'
                ELSE N'Bàn tròn (Banquet)'
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
    
    (SELECT TOP 1 s.Tensanhtiec FROM tbmk_Hopdongsanhtiec hs INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid WHERE hs.Sohopdong = h.Sohopdong) AS [TiecSanhTiec],
    (SELECT TOP 1 s.SLBanMin FROM tbmk_Hopdongsanhtiec hs INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid WHERE hs.Sohopdong = h.Sohopdong) AS [SanhQuyMoMin],
    (SELECT TOP 1 s.SLBanMax FROM tbmk_Hopdongsanhtiec hs INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid WHERE hs.Sohopdong = h.Sohopdong) AS [SanhQuyMoMax],
    
    -- Tên loại hình tiệc (computed từ dmLoaihinhtiec, dùng cho in ấn Word)
    ISNULL((SELECT TOP 1 lt.Tenloaitiec FROM dmLoaihinhtiec lt WHERE lt.Loaitiecid = h.Loaitiecid), '') AS [TiecLoaiTiec],
    ISNULL((
        SELECT 
            CASE 
                -- Nếu có sảnh 2 và loại hình tiệc có 2 phần (dấu +)
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
                -- Nếu chỉ có 1 sảnh
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
    -- THÔNG TIN XUẤT HÓA ĐƠN GTGT (Điều 6)
    -- ==========================================
    ISNULL(h.TenCtyHoaDon,    N'...') AS [HDTenCty],
    ISNULL(h.DiaChiCtyHoaDon, N'...') AS [HDDiaChi],
    ISNULL(h.MaSoThueHoaDon,  N'...') AS [HDMaSoThue],
    ISNULL(k.Mail, N'...') AS [Email]
    
FROM tbmk_Hopdong h
LEFT JOIN dmkhachhang k ON h.Makh = k.Makh
WHERE ISNULL(h.IsDeleted, 0) = 0;
GO

-- 1. Cập nhật Form Hợp Đồng chọc vào View này
UPDATE SY_FrmLstTbl 
SET TableName = 'v_DanhSachHopDong', PrimaryKey = 'Sohopdong'
WHERE FormID = 'frmHopDong';
GO

-- 2. Đồng bộ lại cấu hình các cột giao diện từ View
EXEC API_DongBoTruongGiaoDien @FormName = 'frmHopDong', @ObjectName = 'v_DanhSachHopDong';
GO

-- 3. Đăng ký định tuyến Save trong WA_API
DELETE FROM WA_API WHERE List = 'frmHopDong' AND Func = 'Save';
INSERT INTO WA_API (List, Func, [SQL], Para)
VALUES (
    'frmHopDong',
    'Save',
    'API_LuuHopDong',
    '@Sohopdong=N''{Sohopdong}'', @Sobiennhan=N''{Sobiennhan}'', @Makh=N''{Makh}'', @Tenchure=N''{Tenchure}'', @Tencodau=N''{Tencodau}'', @Dienthoai=N''{DienThoai}'', @Diachi=N''{Diachi}'', @Mail=N''{Mail}'', @BenBCCCD=N''{BenBCCCD}'', @Ngayhopdong=N''{Ngayhopdong}'', @Ngaytochuc=N''{NgayToChuc}'', @Nhamngay=N''{Nhamngay}'', @Loaitiecid=N''{Loaitiecid}'', @Thoigianid=N''{Thoigianid}'', @SobanManchinhthuc=N''{SobanManchinhthuc}'', @SobanManduphong=N''{SobanManduphong}'', @SobanChaychinhthuc=N''{SobanChaychinhthuc}'', @SobanChayduphong=N''{SobanChayduphong}'', @TongSoBan=N''{SoBan}'', @Tongtienhopdong=N''{TongTien}'', @Sotiencoccho=N''{DaCocVND}'', @Sotiencochopdong=N''{Sotiencochopdong}'', @Tongtiencoc=N''{Tongtiencoc}'', @Ghichu=N''{Ghichu}'', @JsonSanhTiec=N''{JsonSanhTiec}'', @JsonLichTrinh=N''{JsonLichTrinh}'''
);
GO

-- 4. Cấu hình hiển thị và định dạng cho các trường nhập liệu Hợp đồng trong SY_FormatFields
UPDATE SY_FormatFields
SET ShowInForm = 1, ShowInAdd = 1, ShowInEdit = 1, ShowInFilter = 0, FormPosition = '6'
WHERE FormName = 'frmHopDong'
  AND FieldName IN (
    'Tenchure', 'Tencodau', 'Diachi', 'Mail',
    'Ngayhopdong', 'Nhamngay', 'Loaitiecid', 'Thoigianid', 'JsonSanhTiec',
    'SobanManchinhthuc', 'SobanManduphong', 'SobanChaychinhthuc', 'SobanChayduphong',
    'DaCocVND', 'Sotiencochopdong', 'Tongtiencoc'
  );

-- Số CCCD Bên B hiển thị ở cả Grid và Form (FormPosition = 'grid')
UPDATE SY_FormatFields
SET ShowInForm = 1, ShowInAdd = 1, ShowInEdit = 1, ShowInFilter = 0, FormPosition = 'grid'
WHERE FormName = 'frmHopDong' AND FieldName = 'BenBCCCD';

-- Ghi chú bổ sung
UPDATE SY_FormatFields
SET ShowInForm = 1, ShowInAdd = 1, ShowInEdit = 1, ShowInFilter = 0, FormPosition = 'form'
WHERE FormName = 'frmHopDong' AND FieldName = 'Ghichu';

-- Ẩn các cột chỉ dùng để IN ẤN khỏi giao diện Grid/Form
UPDATE SY_FormatFields
SET ShowInForm = 0, ShowInEdit = 0, ShowInAdd = 0, ShowInFilter = 0, FormPosition = 'hidden'
WHERE FormName = 'frmHopDong' 
  AND FieldName IN (
    'NgayLapHD', 'ThangLapHD', 'NamLapHD',
    'BenANhanVienPhuTrach', 'BenASDTNhanVien',
    'BenBTenDaiDien', 'BenBTenChuTiec', 'BenBDiaChi', 'BenBDienThoai', 'BenBChucVu',
    'TiecGioBatDau', 'TiecNgayDL', 'TiecThangDL', 'TiecNamDL',
    'TiecNgayAL', 'TiecThangAL', 'TiecNamAL',
    'TiecSanhTiec', 'TiecLoaiTiec', 'SanhQuyMoMin', 'SanhQuyMoMax',
    'TiecSoBanChinhThuc', 'TiecSoBanTang', 'TiecSoBanDuPhong', 'TiecSoKhach1Ban',
    'CocLan1SoTien', 'CocLan1BangChu', 'CocNgay', 'CocThang', 'CocNam',
    'CocLan2SoTien', 'CocLan2BangChu',
    'DieuKhoanBoSung', 'DSKhuyenMai'
  );

-- Ẩn các trường tính toán tự động khỏi Form (chỉ hiện trên Grid lưới) hoặc cấu hình Read-Only khi sửa
UPDATE SY_FormatFields
SET ShowInAdd = 0, ShowInEdit = 0
WHERE FormName = 'frmHopDong' AND FieldName = 'TenKhachHang';

UPDATE SY_FormatFields
SET ShowInAdd = 0, ShowInEdit = 1, IsReadOnlyEdit = 1
WHERE FormName = 'frmHopDong' AND FieldName IN ('Makh', 'SoBan', 'SanhDat', 'TongTien', 'TrangThai', 'Sohopdong');

-- CCCD Bên B: lấy từ dmkhachhang, chỉ nhập được khi Thêm mới (lần đầu), khoá khi Sửa
UPDATE SY_FormatFields
SET ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 1
WHERE FormName = 'frmHopDong' AND FieldName = 'BenBCCCD';

-- Bên A (thông tin nhà hàng): lấy từ SY_Setup - không cho phép nhập/sửa trực tiếp trên form HĐ
UPDATE SY_FormatFields
SET ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 1, IsReadOnlyEdit = 1
WHERE FormName = 'frmHopDong' AND FieldName IN ('BenANguoiDaiDien', 'BenAChucVu');

-- Cấu hình định dạng (FormatID) cho các trường
UPDATE SY_FormatFields SET FormatID = 't' WHERE FormName = 'frmHopDong' AND FieldName IN ('Tenchure', 'Tencodau', 'Diachi', 'Mail', 'BenBCCCD', 'Nhamngay', 'Ghichu');
UPDATE SY_FormatFields SET FormatID = 'd' WHERE FormName = 'frmHopDong' AND FieldName IN ('Ngayhopdong');
UPDATE SY_FormatFields SET FormatID = 'sl' WHERE FormName = 'frmHopDong' AND FieldName IN ('Loaitiecid', 'Thoigianid', 'JsonSanhTiec');
UPDATE SY_FormatFields SET FormatID = 'js', DataSource = N'[{"key":"BatDau","label":"Bắt đầu","type":"text","width":"100px"},{"key":"KetThuc","label":"Kết thúc","type":"text","width":"100px"},{"key":"Sanh","label":"Sảnh","type":"text","width":"180px"},{"key":"NoiDung","label":"Nội dung","type":"text","width":"auto"}]', FormPosition = '12' WHERE FormName = 'frmHopDong' AND FieldName = 'JsonLichTrinh';
UPDATE SY_FormatFields SET FormatID = 'n' WHERE FormName = 'frmHopDong' AND FieldName IN ('SobanManchinhthuc', 'SobanManduphong', 'SobanChaychinhthuc', 'SobanChayduphong', 'DaCocVND', 'Sotiencochopdong', 'Tongtiencoc');

-- Cấu hình DataSource cho các Dropdown
UPDATE SY_FormatFields
SET DataSource = '/api/API_Gateway_Router?List=API_DanhSachCaLam&Func=View'
WHERE FormName = 'frmHopDong' AND FieldName = 'Thoigianid';

UPDATE SY_FormatFields
SET DataSource = '/api/API_Gateway_Router?List=API_DanhSachLoaiHinhTiec&Func=View'
WHERE FormName = 'frmHopDong' AND FieldName = 'Loaitiecid';

UPDATE SY_FormatFields
SET DataSource = '/api/API_Gateway_Router?List=API_DanhSachSanh&Func=View'
WHERE FormName = 'frmHopDong' AND FieldName = 'JsonSanhTiec';

-- Cập nhật tên tiếng Việt thân thiện
UPDATE SY_FormatFields SET CaptionVN = N'Ngày lập HĐ' WHERE FormName = 'frmHopDong' AND FieldName = 'NgayLapHD';
UPDATE SY_FormatFields SET CaptionVN = N'Tháng lập HĐ' WHERE FormName = 'frmHopDong' AND FieldName = 'ThangLapHD';
UPDATE SY_FormatFields SET CaptionVN = N'Năm lập HĐ' WHERE FormName = 'frmHopDong' AND FieldName = 'NamLapHD';

UPDATE SY_FormatFields SET CaptionVN = N'Nhân viên phụ trách' WHERE FormName = 'frmHopDong' AND FieldName = 'BenANhanVienPhuTrach';
UPDATE SY_FormatFields SET CaptionVN = N'SĐT nhân viên' WHERE FormName = 'frmHopDong' AND FieldName = 'BenASDTNhanVien';
UPDATE SY_FormatFields SET CaptionVN = N'Đại diện Bên A' WHERE FormName = 'frmHopDong' AND FieldName = 'BenANguoiDaiDien';
UPDATE SY_FormatFields SET CaptionVN = N'Chức vụ Bên A' WHERE FormName = 'frmHopDong' AND FieldName = 'BenAChucVu';

UPDATE SY_FormatFields SET CaptionVN = N'Đại diện Bên B' WHERE FormName = 'frmHopDong' AND FieldName = 'BenBTenDaiDien';
UPDATE SY_FormatFields SET CaptionVN = N'Tên Chủ Tiệc' WHERE FormName = 'frmHopDong' AND FieldName = 'BenBTenChuTiec';
UPDATE SY_FormatFields SET CaptionVN = N'Địa chỉ Bên B' WHERE FormName = 'frmHopDong' AND FieldName = 'BenBDiaChi';
UPDATE SY_FormatFields SET CaptionVN = N'SĐT Bên B' WHERE FormName = 'frmHopDong' AND FieldName = 'BenBDienThoai';
UPDATE SY_FormatFields SET CaptionVN = N'Chức vụ Bên B' WHERE FormName = 'frmHopDong' AND FieldName = 'BenBChucVu';
UPDATE SY_FormatFields SET CaptionVN = N'Số CCCD (Bên B)' WHERE FormName = 'frmHopDong' AND FieldName = 'BenBCCCD';

UPDATE SY_FormatFields SET CaptionVN = N'Giờ bắt đầu' WHERE FormName = 'frmHopDong' AND FieldName = 'TiecGioBatDau';
UPDATE SY_FormatFields SET CaptionVN = N'Ngày đãi tiệc (DL)' WHERE FormName = 'frmHopDong' AND FieldName = 'TiecNgayDL';
UPDATE SY_FormatFields SET CaptionVN = N'Tháng đãi tiệc (DL)' WHERE FormName = 'frmHopDong' AND FieldName = 'TiecThangDL';
UPDATE SY_FormatFields SET CaptionVN = N'Năm đãi tiệc (DL)' WHERE FormName = 'frmHopDong' AND FieldName = 'TiecNamDL';
UPDATE SY_FormatFields SET CaptionVN = N'Ngày đãi tiệc (AL)' WHERE FormName = 'frmHopDong' AND FieldName = 'TiecNgayAL';
UPDATE SY_FormatFields SET CaptionVN = N'Tháng đãi tiệc (AL)' WHERE FormName = 'frmHopDong' AND FieldName = 'TiecThangAL';
UPDATE SY_FormatFields SET CaptionVN = N'Năm đãi tiệc (AL)' WHERE FormName = 'frmHopDong' AND FieldName = 'TiecNamAL';

UPDATE SY_FormatFields SET CaptionVN = N'Sảnh đãi tiệc' WHERE FormName = 'frmHopDong' AND FieldName = 'TiecSanhTiec';
UPDATE SY_FormatFields SET CaptionVN = N'Quy mô tối thiểu' WHERE FormName = 'frmHopDong' AND FieldName = 'SanhQuyMoMin';
UPDATE SY_FormatFields SET CaptionVN = N'Quy mô tối đa' WHERE FormName = 'frmHopDong' AND FieldName = 'SanhQuyMoMax';

UPDATE SY_FormatFields SET CaptionVN = N'Số bàn chính thức' WHERE FormName = 'frmHopDong' AND FieldName = 'TiecSoBanChinhThuc';
UPDATE SY_FormatFields SET CaptionVN = N'Số bàn tặng' WHERE FormName = 'frmHopDong' AND FieldName = 'TiecSoBanTang';
UPDATE SY_FormatFields SET CaptionVN = N'Số bàn dự phòng' WHERE FormName = 'frmHopDong' AND FieldName = 'TiecSoBanDuPhong';
UPDATE SY_FormatFields SET CaptionVN = N'Số khách/Bàn' WHERE FormName = 'frmHopDong' AND FieldName = 'TiecSoKhach1Ban';

UPDATE SY_FormatFields SET CaptionVN = N'Tiền cọc lần 1' WHERE FormName = 'frmHopDong' AND FieldName = 'CocLan1SoTien';
UPDATE SY_FormatFields SET CaptionVN = N'Tiền cọc bằng chữ' WHERE FormName = 'frmHopDong' AND FieldName = 'CocLan1BangChu';
UPDATE SY_FormatFields SET CaptionVN = N'Tiền cọc lần 2' WHERE FormName = 'frmHopDong' AND FieldName = 'CocLan2SoTien';
UPDATE SY_FormatFields SET CaptionVN = N'Tiền cọc lần 2 bằng chữ' WHERE FormName = 'frmHopDong' AND FieldName = 'CocLan2BangChu';
UPDATE SY_FormatFields SET CaptionVN = N'Ngày cọc' WHERE FormName = 'frmHopDong' AND FieldName = 'CocNgay';
UPDATE SY_FormatFields SET CaptionVN = N'Tháng cọc' WHERE FormName = 'frmHopDong' AND FieldName = 'CocThang';
UPDATE SY_FormatFields SET CaptionVN = N'Năm cọc' WHERE FormName = 'frmHopDong' AND FieldName = 'CocNam';

UPDATE SY_FormatFields SET CaptionVN = N'Điều khoản bổ sung' WHERE FormName = 'frmHopDong' AND FieldName = 'DieuKhoanBoSung';
UPDATE SY_FormatFields SET CaptionVN = N'Khuyến mãi' WHERE FormName = 'frmHopDong' AND FieldName = 'DSKhuyenMai';

-- Cập nhật tên tiếng Việt cho các trường mới
UPDATE SY_FormatFields SET CaptionVN = N'Tên chú rể' WHERE FormName = 'frmHopDong' AND FieldName = 'Tenchure';
UPDATE SY_FormatFields SET CaptionVN = N'Tên cô dâu' WHERE FormName = 'frmHopDong' AND FieldName = 'Tencodau';
UPDATE SY_FormatFields SET CaptionVN = N'Địa chỉ khách hàng' WHERE FormName = 'frmHopDong' AND FieldName = 'Diachi';
UPDATE SY_FormatFields SET CaptionVN = N'Email' WHERE FormName = 'frmHopDong' AND FieldName = 'Mail';
UPDATE SY_FormatFields SET CaptionVN = N'Ngày lập HĐ' WHERE FormName = 'frmHopDong' AND FieldName = 'Ngayhopdong';
UPDATE SY_FormatFields SET CaptionVN = N'Nhằm ngày âm lịch' WHERE FormName = 'frmHopDong' AND FieldName = 'Nhamngay';
UPDATE SY_FormatFields SET CaptionVN = N'Loại hình tiệc' WHERE FormName = 'frmHopDong' AND FieldName = 'Loaitiecid';
UPDATE SY_FormatFields SET CaptionVN = N'Ca đãi tiệc' WHERE FormName = 'frmHopDong' AND FieldName = 'Thoigianid';
UPDATE SY_FormatFields SET CaptionVN = N'Sảnh đãi tiệc' WHERE FormName = 'frmHopDong' AND FieldName = 'JsonSanhTiec';
UPDATE SY_FormatFields SET CaptionVN = N'Bàn mặn chính thức' WHERE FormName = 'frmHopDong' AND FieldName = 'SobanManchinhthuc';
UPDATE SY_FormatFields SET CaptionVN = N'Bàn mặn dự phòng' WHERE FormName = 'frmHopDong' AND FieldName = 'SobanManduphong';
UPDATE SY_FormatFields SET CaptionVN = N'Bàn chay chính thức' WHERE FormName = 'frmHopDong' AND FieldName = 'SobanChaychinhthuc';
UPDATE SY_FormatFields SET CaptionVN = N'Bàn chay dự phòng' WHERE FormName = 'frmHopDong' AND FieldName = 'SobanChayduphong';
UPDATE SY_FormatFields SET CaptionVN = N'Tiền cọc chỗ (Lần 1)' WHERE FormName = 'frmHopDong' AND FieldName = 'DaCocVND';
UPDATE SY_FormatFields SET CaptionVN = N'Tiền cọc hợp đồng (Lần 2)' WHERE FormName = 'frmHopDong' AND FieldName = 'Sotiencochopdong';
UPDATE SY_FormatFields SET CaptionVN = N'Tổng tiền cọc', ValidateRule = 'formula:{DaCocVND} + {Sotiencochopdong}' WHERE FormName = 'frmHopDong' AND FieldName = 'Tongtiencoc';
UPDATE SY_FormatFields SET CaptionVN = N'Ghi chú bổ sung' WHERE FormName = 'frmHopDong' AND FieldName = 'Ghichu';
UPDATE SY_FormatFields SET CaptionVN = N'Lịch trình BEO (JSON)', ShowInForm = 1, ShowInAdd = 1, ShowInEdit = 1 WHERE FormName = 'frmHopDong' AND FieldName = 'JsonLichTrinh';

-- Cập nhật tên tiếng Việt thân thiện cho các cột gốc (Grid mặc định)
UPDATE SY_FormatFields SET CaptionVN = N'Số hợp đồng' WHERE FormName = 'frmHopDong' AND FieldName = 'Sohopdong';
UPDATE SY_FormatFields SET CaptionVN = N'Số biên nhận' WHERE FormName = 'frmHopDong' AND FieldName = 'Sobiennhan';
UPDATE SY_FormatFields SET CaptionVN = N'Mã KH' WHERE FormName = 'frmHopDong' AND FieldName = 'Makh';
UPDATE SY_FormatFields SET CaptionVN = N'Tên khách hàng' WHERE FormName = 'frmHopDong' AND FieldName = 'TenKhachHang';
UPDATE SY_FormatFields SET CaptionVN = N'Điện thoại' WHERE FormName = 'frmHopDong' AND FieldName = 'DienThoai';
UPDATE SY_FormatFields SET CaptionVN = N'Ngày tổ chức' WHERE FormName = 'frmHopDong' AND FieldName = 'NgayToChuc';
UPDATE SY_FormatFields SET CaptionVN = N'Số bàn' WHERE FormName = 'frmHopDong' AND FieldName = 'SoBan';
UPDATE SY_FormatFields SET CaptionVN = N'Sảnh đặt' WHERE FormName = 'frmHopDong' AND FieldName = 'SanhDat';
UPDATE SY_FormatFields SET CaptionVN = N'Tổng tiền' WHERE FormName = 'frmHopDong' AND FieldName = 'TongTien';
UPDATE SY_FormatFields SET CaptionVN = N'Trạng thái' WHERE FormName = 'frmHopDong' AND FieldName = 'TrangThai';

-- Cấu hình thứ tự hiển thị (OrderNo) trên Form
UPDATE SY_FormatFields SET OrderNo = 1 WHERE FormName = 'frmHopDong' AND FieldName = 'Sohopdong';
UPDATE SY_FormatFields SET OrderNo = 2 WHERE FormName = 'frmHopDong' AND FieldName = 'Sobiennhan';
UPDATE SY_FormatFields SET OrderNo = 3 WHERE FormName = 'frmHopDong' AND FieldName = 'Makh';
UPDATE SY_FormatFields SET OrderNo = 4 WHERE FormName = 'frmHopDong' AND FieldName = 'TenKhachHang';
UPDATE SY_FormatFields SET OrderNo = 5 WHERE FormName = 'frmHopDong' AND FieldName = 'Tenchure';
UPDATE SY_FormatFields SET OrderNo = 6 WHERE FormName = 'frmHopDong' AND FieldName = 'Tencodau';
UPDATE SY_FormatFields SET OrderNo = 7 WHERE FormName = 'frmHopDong' AND FieldName = 'DienThoai';
UPDATE SY_FormatFields SET OrderNo = 8 WHERE FormName = 'frmHopDong' AND FieldName = 'Mail';
UPDATE SY_FormatFields SET OrderNo = 9 WHERE FormName = 'frmHopDong' AND FieldName = 'Diachi';
UPDATE SY_FormatFields SET OrderNo = 10 WHERE FormName = 'frmHopDong' AND FieldName = 'Ngayhopdong';
UPDATE SY_FormatFields SET OrderNo = 11 WHERE FormName = 'frmHopDong' AND FieldName = 'NgayToChuc';
UPDATE SY_FormatFields SET OrderNo = 12 WHERE FormName = 'frmHopDong' AND FieldName = 'Nhamngay';
UPDATE SY_FormatFields SET OrderNo = 13 WHERE FormName = 'frmHopDong' AND FieldName = 'Loaitiecid';
UPDATE SY_FormatFields SET OrderNo = 14 WHERE FormName = 'frmHopDong' AND FieldName = 'Thoigianid';
UPDATE SY_FormatFields SET OrderNo = 15 WHERE FormName = 'frmHopDong' AND FieldName = 'JsonSanhTiec';
UPDATE SY_FormatFields SET OrderNo = 16 WHERE FormName = 'frmHopDong' AND FieldName = 'SoBan';
UPDATE SY_FormatFields SET OrderNo = 17 WHERE FormName = 'frmHopDong' AND FieldName = 'SobanManchinhthuc';
UPDATE SY_FormatFields SET OrderNo = 18 WHERE FormName = 'frmHopDong' AND FieldName = 'SobanManduphong';
UPDATE SY_FormatFields SET OrderNo = 19 WHERE FormName = 'frmHopDong' AND FieldName = 'SobanChaychinhthuc';
UPDATE SY_FormatFields SET OrderNo = 20 WHERE FormName = 'frmHopDong' AND FieldName = 'SobanChayduphong';
UPDATE SY_FormatFields SET OrderNo = 21 WHERE FormName = 'frmHopDong' AND FieldName = 'DaCocVND';
UPDATE SY_FormatFields SET OrderNo = 22 WHERE FormName = 'frmHopDong' AND FieldName = 'Sotiencochopdong';
UPDATE SY_FormatFields SET OrderNo = 23 WHERE FormName = 'frmHopDong' AND FieldName = 'Tongtiencoc';
UPDATE SY_FormatFields SET OrderNo = 24 WHERE FormName = 'frmHopDong' AND FieldName = 'TongTien';
UPDATE SY_FormatFields SET OrderNo = 25 WHERE FormName = 'frmHopDong' AND FieldName = 'TrangThai';
UPDATE SY_FormatFields SET OrderNo = 26 WHERE FormName = 'frmHopDong' AND FieldName = 'Ghichu';
UPDATE SY_FormatFields SET OrderNo = 27 WHERE FormName = 'frmHopDong' AND FieldName = 'JsonLichTrinh';
GO
