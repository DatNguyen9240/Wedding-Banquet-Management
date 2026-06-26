IF EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[v_DanhSachHopDong]'))
    DROP VIEW [dbo].[v_DanhSachHopDong]
GO
CREATE VIEW [dbo].[v_DanhSachHopDong] AS
SELECT 
    h.Sohopdong AS [Id], -- Đóng vai trò là PrimaryKey cho Frontend

    h.Sohopdong AS [Sohopdong], -- Cột khóa chính thật
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
    (SELECT TOP 1 tm.TemplateFile FROM tbmk_LoaitiecAddfile tm WHERE tm.FormName = 'frmHopDong' AND tm.Loaitiecid = h.Loaitiecid) AS [TemplateFile],
    h.Thoigianid,
    h.SobanManchinhthuc AS [SobanManchinhthuc],
    h.SobanManduphong AS [SobanManduphong],
    h.SobanChaychinhthuc AS [SobanChaychinhthuc],
    h.SobanChayduphong AS [SobanChayduphong],
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
    ISNULL(NULLIF((SELECT TOP 1 CodeValue FROM [dbo].[SY_Setup] WHERE CodeID = 'HNNguoiDaiDien'), ''), N'Nguyễn Văn A') AS [BenANguoiDaiDien],
    ISNULL(NULLIF((SELECT TOP 1 CodeValue FROM [dbo].[SY_Setup] WHERE CodeID = 'HNNguoiDaiDien'), ''), N'Nguyễn Văn A') AS [BenADaiDien],
    ISNULL(NULLIF(h.BenAChucVuDaiDien, ''), ISNULL((SELECT TOP 1 CodeValue FROM [dbo].[SY_Setup] WHERE CodeID = 'HNChucVuNguoiDaiDien'), N'Giám đốc')) AS [BenAChucVu],
    ISNULL(
        (SELECT TOP 1 nv.Tennv FROM dmNhanvienView nv WHERE nv.Manv = h.Manv OR nv.USERNAME = h.Manv),
        ISNULL(
            (SELECT TOP 1 nv.Tennv FROM dmNhanvienView nv WHERE nv.USERNAME = h.UserCreate),
            ISNULL(h.UserCreate, h.Manv)
        )
    ) AS [BenANhanVienPhuTrach],
    ISNULL(
        (SELECT TOP 1 nv.DIENTHOAI FROM dmNhanvienView nv WHERE nv.Manv = h.Manv OR nv.USERNAME = h.Manv),
        ISNULL(
            (SELECT TOP 1 nv.DIENTHOAI FROM dmNhanvienView nv WHERE nv.USERNAME = h.UserCreate),
            ISNULL(
                (SELECT TOP 1 CodeValue FROM [dbo].[SY_Setup] WHERE CodeID = 'Com3'),
                ISNULL(
                    (SELECT TOP 1 CodeValue FROM [dbo].[SY_Setup] WHERE CodeID = 'BenASDT'),
                    ''
                )
            )
        )
    ) AS [BenASDTNhanVien],
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
    -- Nếu đã có JsonLichTrinh lưu trong DB thì ưu tiên lấy, ngược lại trả về mảng rỗng []
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
    
    (SELECT TOP 1 s.Tensanhtiec FROM tbmk_Hopdongsanhtiec hs INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid WHERE hs.Sohopdong = h.Sohopdong) AS [TenSanhTiec],
    (SELECT TOP 1 s.SLBanMin FROM tbmk_Hopdongsanhtiec hs INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid WHERE hs.Sohopdong = h.Sohopdong) AS [SanhQuyMoMin],
    (SELECT TOP 1 s.SLBanMax FROM tbmk_Hopdongsanhtiec hs INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid WHERE hs.Sohopdong = h.Sohopdong) AS [SanhQuyMoMax],
    
    -- Tên loại hình tiệc (computed từ dmLoaihinhtiec, dùng cho in ấn Word)
    ISNULL((SELECT TOP 1 lt.Tenloaitiec FROM dmLoaihinhtiec lt WHERE lt.Loaitiecid = h.Loaitiecid), '') AS [TiecLoaiTiec],
    ISNULL(h.LoaiHinhSuKien, ISNULL((
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
    ), '')) AS [LoaiHinhSuKien],
    
    ISNULL(h.SobanManchinhthuc, 0) + ISNULL(h.SobanChaychinhthuc, 0) AS [TiecSoBanChinhThuc],
    ISNULL(h.SoBanTang, 0) AS [TiecSoBanTang],
    ISNULL(h.SobanManduphong, 0) + ISNULL(h.SobanChayduphong, 0) AS [TiecSoBanDuPhong],
    ISNULL(h.SoNguoiTrenBan, 10) AS [TiecSoKhach1Ban],
    
    -- Thông tin Cá»c & Khuyến mãi
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
    CAST(ISNULL(h.PhiPhucVu, 0) AS VARCHAR) + '%' AS [MucPhiPhucVu],
    FORMAT(c_phiphucvu.CalcPhiPhucVu, 'N0', 'vi-VN') AS [PhiPhucVu],
    FORMAT(c_chuavat.CalcChuaVAT, 'N0', 'vi-VN') AS [TongCongChuaVAT],
    FORMAT(CASE WHEN ISNULL(h.PTThueVAT, 0) = 8 OR (ISNULL(h.PTThueVAT, 0) = 0 AND c_vat.CalcTienThueVAT > 0 AND ABS((c_vat.CalcTienThueVAT * 100.0 / NULLIF(c_chuavat.CalcChuaVAT, 0)) - 8) < 1.0) THEN c_vat.CalcTienThueVAT ELSE 0 END, 'N0', 'vi-VN') AS [VAT8],
    FORMAT(CASE WHEN ISNULL(h.PTThueVAT, 0) = 10 OR (ISNULL(h.PTThueVAT, 0) = 0 AND c_vat.CalcTienThueVAT > 0 AND NOT (ABS((c_vat.CalcTienThueVAT * 100.0 / NULLIF(c_chuavat.CalcChuaVAT, 0)) - 8) < 1.0)) THEN c_vat.CalcTienThueVAT ELSE 0 END, 'N0', 'vi-VN') AS [VAT10],
    FORMAT(ISNULL(h.Tongtienhopdong, 0), 'N0', 'vi-VN') AS [TongTienFormat],


    ISNULL(h.DieuKhoanBoSung, N'- Áp dụng thực đơn tự chọn theo bảng giá lẻ (chưa bao gồm phí phục vụ).
- Áp dụng chương trình đặt 10 bàn tặng 01 bàn (từ 20 bàn trở lên)
Tất cả các chương trình khuyến mãi và ưu đãi trên không quy đổi thành tiền mặt và không thay thế bằng dịch vụ khác nếu quý khách không sử dụng.') AS [DieuKhoanBoSung],
    ISNULL(NULLIF(h.Noidunguudai, ''), 
        ISNULL((
            SELECT STUFF((
                SELECT CHAR(10) + CAST(ROW_NUMBER() OVER(ORDER BY ct.STT) AS VARCHAR(10)) + '. ' + ISNULL(hh.Tenhang, ct.Mahang) + 
                       CASE WHEN ISNULL(ct.Soluong, 1) > 1 THEN ' (SL: ' + CAST(CAST(ct.Soluong AS INT) AS VARCHAR(10)) + ')' ELSE '' END
                FROM tbmk_Banuudaict ct
                LEFT JOIN dmHanghoa hh ON ct.Mahang = hh.Mahang
                WHERE ct.DocumentID = (
                    SELECT TOP 1 ud.DocumentID
                    FROM tbmk_Banuudai ud
                    WHERE ud.Loaitiecid = h.Loaitiecid
                      AND ISNULL(h.TongSoBan, 0) >= ud.Tusoluongban 
                      AND ISNULL(h.TongSoBan, 0) <= ud.Densoluongban
                      AND (ud.IsKetthuc IS NULL OR ud.IsKetthuc = 0)
                    ORDER BY ud.Tusoluongban DESC
                )
                ORDER BY ct.STT ASC
                FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 1, '')
        ), '')
    ) AS [DSKhuyenMai],

    -- ==========================================
    -- THÔNG TIN XUẤT HÓA ĐƠN GTGT (Điều 6)
    -- ==========================================
    -- Nếu chưa điền riêng thì tự lấy từ thông tin khách hàng
    ISNULL(NULLIF(h.TenCtyHoaDon, ''),    ISNULL(k.Tenkh,  N'...')) AS [HDTenCty],
    ISNULL(NULLIF(h.DiaChiCtyHoaDon, ''), ISNULL(k.Diachi, N'...')) AS [HDDiaChi],
    ISNULL(NULLIF(h.MaSoThueHoaDon, ''),  N'...') AS [HDMaSoThue],
    ISNULL(k.Mail, N'...') AS [Email],

    -- Menu / dịch vụ cho docx (fn_DOCX_* — sql/Functions/fn_DOCX_MenuDichVu.sql)
    dbo.fn_DOCX_DanhSachMenu(h.Sohopdong)     AS [DanhSachMenu],
    dbo.fn_DOCX_DanhSachThucUong(h.Sohopdong) AS [DanhSachThucUong],
    dbo.fn_DOCX_MenuTiec(h.Sohopdong)         AS [MenuTiec],
    dbo.fn_DOCX_MenuTongCong(h.Sohopdong)     AS [MenuTongCong],
    dbo.fn_DOCX_DichVuTinhPhi(h.Sohopdong)    AS [DichVuTinhPhi],
    dbo.fn_DOCX_DanhSachNgay(h.Sohopdong)     AS [DanhSachNgay],
    dbo.fn_DOCX_DanhSachDichVu(h.Sohopdong)   AS [DanhSachDichVu],

    -- Tổng giá trị tạm tính bằng chữ
    [dbo].[fn_DocTienBangChu](ISNULL(h.Tongtienhopdong, 0)) AS [TongGiaTriTamTinhBangChu],
    FORMAT(ISNULL(h.Tongtienhopdong, 0), 'N0', 'vi-VN') AS [TongGiaTriTamTinh],

    -- Các biến tùy chỉnh ánh xạ trực tiếp đến các file Word mẫu (tránh lệch chữ hoa/thường hoặc thiếu trường)
    (SELECT TOP 1 s.Tensanhtiec FROM tbmk_Hopdongsanhtiec hs INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid WHERE hs.Sohopdong = h.Sohopdong) AS [TiecSanhTiec],
    ISNULL(NULLIF(h.BenAChucVuDaiDien, ''), ISNULL((SELECT TOP 1 CodeValue FROM [dbo].[SY_Setup] WHERE CodeID = 'HNChucVuNguoiDaiDien'), N'Giám đốc')) AS [BenAChucVuDaiDien],
    k.Mail AS [BenBEmail],
    [dbo].[fn_DocTienBangChu](ISNULL(h.Sotiencoccho, 0)) AS [Dot1BangChu],
    ISNULL((SELECT TOP 1 s.SLBanMin * ISNULL(h.SoNguoiTrenBan, 10) FROM tbmk_Hopdongsanhtiec hs INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid WHERE hs.Sohopdong = h.Sohopdong), 0) AS [KhachToiThieu],
    ISNULL((SELECT TOP 1 CAST(s.ChieuRong AS VARCHAR) + 'm x ' + CAST(s.ChieuDai AS VARCHAR) + 'm' FROM tbmk_Hopdongsanhtiec hs INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid WHERE hs.Sohopdong = h.Sohopdong ORDER BY hs.IsSanhchinh DESC), '...') AS [KichThuocSanh],
    ISNULL((SELECT CAST(s.ChieuRong AS VARCHAR) + 'm x ' + CAST(s.ChieuDai AS VARCHAR) + 'm' FROM tbmk_Hopdongsanhtiec hs INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid WHERE hs.Sohopdong = h.Sohopdong ORDER BY hs.IsSanhchinh DESC, hs.Sanhtiecid OFFSET 1 ROWS FETCH NEXT 1 ROWS ONLY), '...') AS [KichThuocSanhPhu],
    ISNULL((SELECT TOP 1 s.KTSanKhau FROM tbmk_Hopdongsanhtiec hs INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid WHERE hs.Sohopdong = h.Sohopdong ORDER BY hs.IsSanhchinh DESC), '...') AS [KichThuocSanKhau],
    ISNULL((SELECT s.KTSanKhau FROM tbmk_Hopdongsanhtiec hs INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid WHERE hs.Sohopdong = h.Sohopdong ORDER BY hs.IsSanhchinh DESC, hs.Sanhtiecid OFFSET 1 ROWS FETCH NEXT 1 ROWS ONLY), '...') AS [KichThuocSanKhauPhu],
    STUFF((
        SELECT N', ' + s.Tensanhtiec
        FROM tbmk_Hopdongsanhtiec hs
        INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid
        WHERE hs.Sohopdong = h.Sohopdong
        ORDER BY hs.IsSanhchinh DESC, hs.Sanhtiecid
        FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 2, '') AS [SanhTiec],
    ISNULL((SELECT TOP 1 CASE WHEN hs.KieuSetup = 'ClassRoom' THEN ISNULL(s.ClassRoom, 0) WHEN hs.KieuSetup = 'Theater' THEN ISNULL(s.Theater, 0) WHEN hs.KieuSetup = 'Cluster' THEN ISNULL(s.ClusterHalfRound, 0) ELSE ISNULL(s.SLBanMax * 10, 0) END FROM tbmk_Hopdongsanhtiec hs INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid WHERE hs.Sohopdong = h.Sohopdong ORDER BY hs.IsSanhchinh DESC), 0) AS [SucChuaToiDa],
    ISNULL((SELECT CASE WHEN hs.KieuSetup = 'ClassRoom' THEN ISNULL(s.ClassRoom, 0) WHEN hs.KieuSetup = 'Theater' THEN ISNULL(s.Theater, 0) WHEN hs.KieuSetup = 'Cluster' THEN ISNULL(s.ClusterHalfRound, 0) ELSE ISNULL(s.SLBanMax * 10, 0) END FROM tbmk_Hopdongsanhtiec hs INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid WHERE hs.Sohopdong = h.Sohopdong ORDER BY hs.IsSanhchinh DESC, hs.Sanhtiecid OFFSET 1 ROWS FETCH NEXT 1 ROWS ONLY), 0) AS [SucChuaToiDaPhu],
    ISNULL((SELECT ISNULL(s.SLBanMin * 10, 0) FROM tbmk_Hopdongsanhtiec hs INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid WHERE hs.Sohopdong = h.Sohopdong ORDER BY hs.IsSanhchinh DESC, hs.Sanhtiecid OFFSET 1 ROWS FETCH NEXT 1 ROWS ONLY), 0) AS [SucChuaToiThieuPhu],
    ISNULL((SELECT s.Tensanhtiec FROM tbmk_Hopdongsanhtiec hs INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid WHERE hs.Sohopdong = h.Sohopdong ORDER BY hs.IsSanhchinh DESC, hs.Sanhtiecid OFFSET 1 ROWS FETCH NEXT 1 ROWS ONLY), '') AS [TenSanhTiecPhu],
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

    -- , AS [DanhSachDV], AS [GhiChuChiTiet], AS [KhungGio], AS [TenDichVu], AS [TenMonAn], AS [TenNhomNgay], AS [ThanhTien], AS [UuDai]

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
