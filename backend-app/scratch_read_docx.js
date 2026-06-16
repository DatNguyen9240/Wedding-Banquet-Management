import fs from 'fs';
import PizZip from 'pizzip';

const docxPath = './samples/BEO_Tiec_Cuoi.docx';
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

// Match anything between { and }
const matches = xml.match(/\{[^}]+\}/g);
if (matches) {
    const uniqueMatches = [...new Set(matches)];
    console.log("Placeholders found:");
    uniqueMatches.forEach(m => console.log(m));
} else {
    console.log("No placeholders found.");
}
