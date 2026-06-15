import fs from 'fs';
import PizZip from 'pizzip';

const docxPath = './samples/phu_luc_hop_dong.docx';
const content = fs.readFileSync(docxPath);
const zip = new PizZip(content);
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
