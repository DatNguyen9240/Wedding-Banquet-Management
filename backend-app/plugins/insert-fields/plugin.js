(function(window, undefined){

    console.log("[InsertFieldsPlugin] Script loaded and executing IIFE...");

    // Khai báo danh sách biến toàn cục để phục vụ tìm kiếm
    var _allBadges = [];

    // Tạo sẵn namespace Asc.plugin nếu thư viện plugin-api.js chưa load xong (tránh lỗi đua tốc độ - Race Condition)
    window.Asc = window.Asc || {};
    window.Asc.plugin = window.Asc.plugin || {};

    window.Asc.plugin.init = function() {
        console.log("[InsertFieldsPlugin] window.Asc.plugin.init called!");
        window.initCalled = true;

        // 1. Xác định loại tài liệu đang mở để tải biến tương ứng (Bọc trong try-catch siêu an toàn)
        var type = "hop_dong";
        try {
            var fileName = "";
            if (window.Asc && window.Asc.plugin && window.Asc.plugin.info) {
                fileName = window.Asc.plugin.info.documentTitle || "";
                console.log("[InsertFieldsPlugin] Document title detected:", fileName);
            } else {
                console.warn("[InsertFieldsPlugin] window.Asc.plugin.info is not fully populated yet.");
            }

            if (fileName && (fileName.indexOf("dat_coc") !== -1 || fileName.indexOf("phieu_thu") !== -1)) {
                type = "dat_coc";
            } else if (fileName && fileName.indexOf("quyet_toan") !== -1) {
                type = "quyet_toan";
            }
        } catch (e) {
            console.error("[InsertFieldsPlugin] Error during document type resolution:", e);
        }

        console.log("[InsertFieldsPlugin] Resolved document type for fields loading:", type);

        // Tải danh sách biến từ Backend thông qua IP máy chủ thực tế (cổng 8080)
        var apiUrl = "http://192.168.68.241:8080/api/documents/fields/" + type;
        console.log("[InsertFieldsPlugin] Fetching fields from URL:", apiUrl);

        // 2. Fetch danh sách biến từ Backend
        fetch(apiUrl)
            .then(function(res) { 
                console.log("[InsertFieldsPlugin] Fetch response received. Status:", res.status);
                return res.json(); 
            })
            .then(function(data) {
                console.log("[InsertFieldsPlugin] Parse JSON response data:", data);
                if (!data.success) {
                    console.error("[InsertFieldsPlugin] API returned success=false:", data.message);
                    return;
                }
                
                var fields = data.fields || [];
                var groups = {
                    "group_a": { title: "Bên A (Nhà hàng)", items: [] },
                    "group_b": { title: "Bên B (Khách hàng)", items: [] },
                    "group_tiec": { title: "Thông tin Tiệc & Sảnh", items: [] },
                    "group_khac": { title: "Trường bổ sung khác", items: [] }
                };

                fields.forEach(function(f) {
                    var cleanName = f.replace(/[{}]/g, "");
                    var label = getFriendlyLabel(cleanName);
                    var item = { id: "field_" + cleanName, label: label, token: f };

                    if (["TenNhaHang", "DiaChiNhaHang", "DienThoaiNhaHang", "HotlineNhaHang", "SlogenNhaHang"].includes(cleanName)) {
                        groups["group_a"].items.push(item);
                    } else if (["TenKhachHang", "DienThoai", "TenCoDau", "TenChuRe"].includes(cleanName)) {
                        groups["group_b"].items.push(item);
                    } else if (["NgayToChuc", "SanhDat", "SoBan", "TongTien"].includes(cleanName)) {
                        groups["group_tiec"].items.push(item);
                    } else {
                        groups["group_khac"].items.push(item);
                    }
                });



                // ── B. BIỂU DIỄN GIAO DIỆN LÊN LEFT SIDEBAR PANEL ──
                try {
                    var container = document.getElementById("groups-container");
                    if (container) {
                        container.innerHTML = "";
                        _allBadges = [];

                        Object.keys(groups).forEach(function(gKey) {
                            var g = groups[gKey];
                            if (g.items.length === 0) return;

                            // Tạo Group Header
                            var hDiv = document.createElement("div");
                            hDiv.className = "group-title";
                            hDiv.innerText = g.title;
                            container.appendChild(hDiv);

                            // Tạo container cho badges
                            var fDiv = document.createElement("div");
                            fDiv.className = "fields-container";

                            g.items.forEach(function(item) {
                                var badge = document.createElement("div");
                                badge.className = "field-badge";
                                badge.innerHTML = 
                                    '<span class="field-label">' + item.label + '</span>' +
                                    '<span class="field-token">' + item.token + '</span>';

                                // Lưu reference phục vụ tìm kiếm nhanh
                                _allBadges.push({
                                    element: badge,
                                    label: item.label.toLowerCase(),
                                    token: item.token.toLowerCase(),
                                    header: hDiv
                                });

                                // Click vào Badge -> Gọi lệnh paste trực tiếp của OnlyOffice (Quy trình khép kín, zero copy-paste!)
                                badge.addEventListener("click", function() {
                                    console.log("[InsertFieldsPlugin] Badge clicked! Pasting token:", item.token);
                                    window.Asc.plugin.executeMethod("PasteText", [item.token]);
                                });

                                // Hỗ trợ kéo thả (Drag & Drop) chuẩn HTML5 trực tiếp vào văn bản OnlyOffice
                                badge.setAttribute("draggable", "true");
                                badge.addEventListener("dragstart", function(e) {
                                    console.log("[InsertFieldsPlugin] Drag start! Token:", item.token);
                                    e.dataTransfer.setData("text/plain", item.token);
                                    badge.style.opacity = "0.5";
                                });
                                badge.addEventListener("dragend", function() {
                                    badge.style.opacity = "1";
                                });

                                fDiv.appendChild(badge);
                            });

                            container.appendChild(fDiv);
                        });
                        console.log("[InsertFieldsPlugin] Successfully rendered sidebar dynamic panel.");
                    } else {
                        console.warn("[InsertFieldsPlugin] Element #groups-container not found in DOM.");
                    }
                } catch (e) {
                    console.error("[InsertFieldsPlugin] Error rendering sidebar elements:", e);
                }
            })
            .catch(function(err) {
                console.error("[InsertFieldsPlugin] Lỗi tải biến hoặc parse response:", err);
                var container = document.getElementById("groups-container");
                if (container) container.innerHTML = '<div class="empty-state" style="color:#ef4444;">⚠️ Lỗi tải danh sách biến</div>';
            });

        // ── C. THIẾT LẬP TÌM KIẾM BIẾN (REAL-TIME FILTER) ──
        try {
            var searchInput = document.getElementById("search-input");
            if (searchInput) {
                searchInput.addEventListener("input", function(e) {
                    var val = e.target.value.trim().toLowerCase();
                    
                    // Thuật toán ẩn hiện badge theo kết quả tìm kiếm
                    _allBadges.forEach(function(b) {
                        var isMatch = b.label.indexOf(val) !== -1 || b.token.indexOf(val) !== -1;
                        b.element.style.display = isMatch ? "flex" : "none";
                    });

                    // Tự động ẩn Group Header nếu toàn bộ các badge con đều bị ẩn
                    var headers = document.querySelectorAll(".group-title");
                    headers.forEach(function(h) {
                        var containerSibling = h.nextElementSibling;
                        if (containerSibling && containerSibling.classList.contains("fields-container")) {
                            var visibleBadges = containerSibling.querySelectorAll('.field-badge[style*="display: flex"], .field-badge:not([style*="display: none"])');
                            h.style.display = visibleBadges.length > 0 ? "flex" : "none";
                        }
                    });
                });
                console.log("[InsertFieldsPlugin] Search filter events attached successfully.");
            }
        } catch (e) {
            console.error("[InsertFieldsPlugin] Error setting up search filter:", e);
        }
    };



    // Hàm chuyển đổi key thành tên tiếng Việt thân thiện
    function getFriendlyLabel(key) {
        var map = {
            "TenNhaHang": "Tên nhà hàng",
            "DiaChiNhaHang": "Địa chỉ nhà hàng",
            "DienThoaiNhaHang": "Điện thoại nhà hàng",
            "HotlineNhaHang": "Hotline nhà hàng",
            "SlogenNhaHang": "Slogan nhà hàng",
            "TenKhachHang": "Tên khách hàng",
            "DienThoai": "Điện thoại khách",
            "TenCoDau": "Tên cô dâu",
            "TenChuRe": "Tên chú rể",
            "NgayToChuc": "Ngày tổ chức",
            "SanhDat": "Sảnh đặt",
            "SoBan": "Số lượng bàn",
            "TongTien": "Tổng số tiền",
            "SoTienCoc": "Số tiền cọc",
            "SoTienCocChu": "Tiền cọc bằng chữ",
            "NgayKy": "Ngày ký",
            "NhanVienPhuTrach": "Nhân viên phụ trách",
            "MaChungTu": "Mã chứng từ",
            "SoPhieu": "Số phiếu cọc",
            "NgayLap": "Ngày lập phiếu"
        };
        return map[key] || key;
    }

})(window, undefined);
