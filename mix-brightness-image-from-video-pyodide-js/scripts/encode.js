import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname  = path.dirname(__filename);

const scriptRoot      = path.dirname(__dirname);
const convertFilePath = path.join(scriptRoot, './src/python/convert.py');
const encodeFilePath  = path.join(scriptRoot, './src/python/convert.py.bin');

function pack(text) {
    const chars = [];

    for(let i=0, n=text.length; i<n;) {
        chars.push(((text[i++] & 0xff) << 8) | (text[i++] & 0xff));
    }

    return String.fromCharCode.apply(null, chars);
}

function unpack(bin) {
    const bytes = [];

    for(let i=0, n=bin.length; i<n; i++) {
        const char = bin.charCodeAt(i);

        bytes.push(char >>> 8, char & 0xFF);
    }

    return bytes;
}

// Pack
const rawContent = fs.readFileSync(convertFilePath);
const packedContent = pack(rawContent);

fs.writeFileSync(encodeFilePath, packedContent);

// Unpack
const encodedContent = fs.readFileSync(encodeFilePath, 'utf-8');
const unpackedContent =  String.fromCharCode.apply(String, unpack(encodedContent))

// Info
console.log(`
   raw length: ${rawContent.length}
packed length: ${packedContent.length}
`);
