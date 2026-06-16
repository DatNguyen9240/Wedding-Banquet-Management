import fs from 'fs';
import PizZip from 'pizzip';

const docxPath = 'c:\\Users\\Dell3070\\Downloads\\phu_luc_hop_dong_PL99767785_1781599677935.docx';
const content = fs.readFileSync(docxPath);
const zip = new PizZip(content);

// Normalize zip file paths for backslashes
const fileNames = Object.keys(zip.files);
for (const name of fileNames) {
    if (name.includes('\\')) {
        const normalizedName = name.replace(/\\/g, '/');
        zip.files[normalizedName] = zip.files[name];
        if (zip.files[normalizedName]) {
            zip.files[normalizedName].name = normalizedName;
        }
        delete zip.files[name];
    }
}

const xml = zip.files['word/document.xml'].asText();

// 1. Check for unresolved placeholders
const matches = xml.match(/\{[^}]+\}/g);
if (matches) {
    console.log("Unresolved placeholders found in the document:");
    console.log([...new Set(matches)]);
} else {
    console.log("No unresolved placeholders found (All tags successfully replaced).");
}

console.log("\n--- Clean Document Text Content ---");
const text = xml.replace(/<[^>]+>/g, ' ');
console.log(text.replace(/\s+/g, ' ').substring(0, 1500));
