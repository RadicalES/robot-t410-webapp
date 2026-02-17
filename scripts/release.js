#!/usr/bin/env node
/**
 * release.js - Build a distributable release package
 *
 * Creates dist/robot-t430-webapp-vX.X.X/ with:
 *   html/        Minified static web files
 *   cgi/         CGI scripts
 *   nginx.conf   NGINX config
 *   sync.sh      Deployment script
 *   network-failsafe.sh/.service  Boot failsafe
 *   www-nmcli    Sudoers file
 *
 * Then creates dist/robot-t430-webapp-vX.X.X.tar.gz
 */

import { execSync } from 'child_process';
import fs from 'fs';
import path from 'path';

const pkg = JSON.parse(fs.readFileSync('package.json', 'utf-8'));
const version = pkg.version;
const releaseName = `robot-t430-webapp-v${version}`;
const distDir = path.join('dist', releaseName);
const htmlDir = path.join(distDir, 'html');
const layersDir = path.join(htmlDir, 'layers');
const cgiDir = path.join(distDir, 'cgi');

function run(cmd) {
    console.log(`  $ ${cmd}`);
    execSync(cmd, { stdio: 'inherit' });
}

function ensureDir(dir) {
    fs.mkdirSync(dir, { recursive: true });
}

console.log(`\n=== Building release: ${releaseName} ===\n`);

// Clean
if (fs.existsSync(distDir)) {
    fs.rmSync(distDir, { recursive: true });
}
ensureDir(htmlDir);
ensureDir(layersDir);
ensureDir(cgiDir);

// Minify JS with Babel
console.log('[1/5] Minifying JavaScript...');
run(`npx babel public/robot.js --out-file ${htmlDir}/robot.js --compact=true --minified --no-comments`);
run(`npx babel public/validation.js --out-file ${htmlDir}/validation.js --compact=true --minified --no-comments`);

// Minify CSS
console.log('[2/5] Minifying CSS...');
run(`npx cleancss -o ${htmlDir}/site.css public/site.css`);
fs.copyFileSync('public/w3.css', path.join(htmlDir, 'w3.css'));

// Minify HTML
console.log('[3/5] Minifying HTML...');
const htmlMinOpts = '--collapse-whitespace --remove-comments --remove-redundant-attributes --minify-css true --minify-js true';
run(`npx html-minifier-terser ${htmlMinOpts} -o ${htmlDir}/index.html public/index.html`);

// Minify layer HTML fragments
const layerFiles = fs.readdirSync('public/layers').filter(f => f.endsWith('.html'));
for (const file of layerFiles) {
    run(`npx html-minifier-terser ${htmlMinOpts} -o ${layersDir}/${file} public/layers/${file}`);
}

// Copy binary assets
console.log('[4/5] Copying assets...');
fs.copyFileSync('public/favicon.png', path.join(htmlDir, 'favicon.png'));
fs.copyFileSync('public/robot.png', path.join(htmlDir, 'robot.png'));

// Copy CGI scripts
const cgiFiles = fs.readdirSync('deploy/cgi');
for (const file of cgiFiles) {
    fs.copyFileSync(path.join('deploy/cgi', file), path.join(cgiDir, file));
    fs.chmodSync(path.join(cgiDir, file), 0o755);
}

// Copy deploy files
fs.copyFileSync('deploy/nginx.conf', path.join(distDir, 'nginx.conf'));
fs.copyFileSync('deploy/sync.sh', path.join(distDir, 'sync.sh'));
fs.chmodSync(path.join(distDir, 'sync.sh'), 0o755);
fs.copyFileSync('deploy/network-failsafe.sh', path.join(distDir, 'network-failsafe.sh'));
fs.chmodSync(path.join(distDir, 'network-failsafe.sh'), 0o755);
fs.copyFileSync('deploy/network-failsafe.service', path.join(distDir, 'network-failsafe.service'));
fs.copyFileSync('deploy/www-nmcli', path.join(distDir, 'www-nmcli'));

// Create tarball
console.log('[5/5] Creating tarball...');
run(`tar -czf dist/${releaseName}.tar.gz -C dist ${releaseName}`);

// Show summary
const tarSize = (fs.statSync(`dist/${releaseName}.tar.gz`).size / 1024).toFixed(1);
console.log(`\n=== Release built successfully ===`);
console.log(`Folder: dist/${releaseName}/`);
console.log(`Tarball: dist/${releaseName}.tar.gz (${tarSize} KB)`);
console.log(`\nTo deploy:`);
console.log(`  tar xzf ${releaseName}.tar.gz`);
console.log(`  cd ${releaseName}`);
console.log(`  ./sync.sh <device-ip> [user]`);
console.log('');
