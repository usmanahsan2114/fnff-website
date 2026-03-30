const fs = require('fs');
const path = require('path');

const baseDir = path.resolve('c:/xampp/htdocs/fnff');
let count = 0;

function walkDir(dir) {
    const files = fs.readdirSync(dir);
    for (const file of files) {
        const fullPath = path.join(dir, file);
        if (fs.statSync(fullPath).isDirectory()) {
            if (!fullPath.includes('.gemini') && !fullPath.includes('node_modules') && !fullPath.includes('tmp') && !fullPath.includes('.git')) {
                walkDir(fullPath);
            }
        } else if (file === 'index.html') {
            const relPath = path.relative(baseDir, dir);
            if (relPath === 'donate-us') continue;

            const depth = relPath === '' ? 0 : relPath.split(path.sep).length;
            const donateRel = depth === 0 ? 'donate-us/' : '../'.repeat(depth) + 'donate-us/';

            let content = fs.readFileSync(fullPath, 'utf8');
            let newContent = content.replace(/<a href="https:\/\/wa\.link\/[^"]*"([^>]*)>([\s\S]*?Donate Now[\s\S]*?)<\/a>/gi, `<a href="${donateRel}"$1>$2</a>`);
            newContent = newContent.replace(/<a href="(?:(?:\.\.\/)*)?contact(?:\/)?"([^>]*)>([\s\S]*?Donate Now[\s\S]*?)<\/a>/gi, `<a href="${donateRel}"$1>$2</a>`);

            if (content !== newContent) {
                fs.writeFileSync(fullPath, newContent, 'utf8');
                console.log(`Updated: ${relPath}`);
                count++;
            }
        }
    }
}

walkDir(baseDir);
console.log(`Total files updated: ${count}`);
