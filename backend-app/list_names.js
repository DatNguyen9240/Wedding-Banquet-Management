import fs from 'fs';
import path from 'path';

const dir = './samples/FILE MAU HOP DONG CÒN LẠI';
if (fs.existsSync(dir)) {
    const files = fs.readdirSync(dir);
    files.forEach(f => {
        console.log("Name:", f);
        console.log("Codes:", f.split('').map(c => c.charCodeAt(0)).join(', '));
    });
} else {
    console.log("Directory does not exist:", dir);
}
const dir2 = './samples/biểu mẫu tiệc';
if (fs.existsSync(dir2)) {
    const files = fs.readdirSync(dir2);
    files.forEach(f => {
        console.log("Name:", f);
        console.log("Codes:", f.split('').map(c => c.charCodeAt(0)).join(', '));
    });
}
