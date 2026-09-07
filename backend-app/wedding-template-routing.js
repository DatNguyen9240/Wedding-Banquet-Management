// Compare calendar dates; missing deposit dates must never become today's date.
function day(value) {
    const match = String(value || '').match(/^(\d{4})-(\d{2})-(\d{2})(?:T| |$)/);
    if (!match) return null;
    const [y, m, d] = match.slice(1).map(Number);
    const date = new Date(Date.UTC(y, m - 1, d));
    return date.getUTCFullYear() === y && date.getUTCMonth() === m - 1 && date.getUTCDate() === d
        ? date.getTime() / 86400000 : null;
}
export function chooseWeddingTemplate(data) {
    const deposit = day(data.NgayCocThucTe);
    const event = day(data.Ngaytochuc || data.NgayToChuc);
    return deposit !== null && event !== null && event - deposit >= 0 && event - deposit <= 30
        ? 'hop_dong_menu_ngay' : 'hop_dong';
}
