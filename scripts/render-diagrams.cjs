// Local-only rendering; generated SVGs are committed. No browser-side Mermaid dependency.
const fs = require('node:fs'), path = require('node:path'), crypto = require('node:crypto');
const root = path.resolve(__dirname, '..');
const bundle = process.env.MERMAID_BUNDLE;
const expected = '581ed7d74bd9048d0e3a91363927d72ef22942d7722546b27f7cc29e35390eb8';
if (!bundle || crypto.createHash('sha256').update(fs.readFileSync(bundle)).digest('hex') !== expected) throw Error('Set MERMAID_BUNDLE to the documented, hash-pinned local Mermaid bundle');
const { chromium } = require(process.env.PLAYWRIGHT_MODULE || 'playwright-core');
const dir = path.join(root,'site/assets/diagrams'); fs.mkdirSync(dir,{recursive:true});
const entries=[];
for(const base of ['.','docs','site/content']) for(const file of (base === '.' ? ['README.md'] : fs.readdirSync(path.join(root,base)).filter(x=>x.endsWith('.md')).sort())) {
 const text=fs.readFileSync(path.join(root,base,file),'utf8');
 for(const match of text.matchAll(/```mermaid\n([\s\S]*?)\n```/g)) {
  const source=match[1], hash=crypto.createHash('sha256').update(source).digest('hex').slice(0,20);
  entries.push({file:base === '.' ? file : base+'/'+file,hash,source});
 }
}
(async()=>{
 const browser=await chromium.launch({executablePath:process.env.CHROMIUM_PATH||'/snap/bin/chromium',headless:true});
 let errors=0;
 try {
 const page=await browser.newPage(); await page.setContent('<!doctype html><html><body></body></html>');
 await page.addScriptTag({path:bundle});
 await page.evaluate(()=>mermaid.initialize({startOnLoad:false,securityLevel:'strict',theme:'base',htmlLabels:false,fontFamily:'Arial, sans-serif',themeVariables:{background:'#ffffff',primaryColor:'#edf2f7',primaryTextColor:'#17212b',primaryBorderColor:'#425466',lineColor:'#425466',secondaryColor:'#f5f0df',tertiaryColor:'#edf2f7',textColor:'#17212b',mainBkg:'#edf2f7',nodeBorder:'#425466',clusterBkg:'#f6f8fa',clusterBorder:'#425466',edgeLabelBackground:'#ffffff',titleColor:'#17212b'},flowchart:{htmlLabels:false,useMaxWidth:false},sequence:{useMaxWidth:false}}));
 for(const e of entries) {
  try {
   let svg=await page.evaluate(async ({source,hash})=>(await mermaid.render('diagram'+hash,source)).svg,e);
   svg=svg.replace('<svg ','<svg style="background:#ffffff" ');
   // Explicit token separators preserve path geometry and avoid IP-like decimal runs.
   svg=svg.replace(/\bd="([^"]*)"/g, (_,d) => 'd="' + (d.match(/[a-zA-Z]|[-+]?(?:\d*\.\d+|\d+\.?\d*)(?:[eE][-+]?\d+)?/g) || []).join(' ') + '"');
   // Standalone SVGs must never load remote assets or execute code.
   if(/<script|<foreignObject|\son\w+=|(?:href|src)="(?:https?:|\/\/)/i.test(svg)) throw Error('Unsafe or externally dependent SVG');
   fs.writeFileSync(path.join(dir,e.hash+'.svg'),svg+'\n');
   console.log('Rendered',e.file,e.hash);
  }catch(error){errors++;console.error('FAILED',e.file,error.message);}
 }
 if(errors) throw Error(errors+' diagrams failed');
 const active = new Set(entries.map(e=>e.hash+'.svg'));
 for(const file of fs.readdirSync(dir)) if(/^[a-f0-9]{20}\.svg$/.test(file) && !active.has(file)) fs.unlinkSync(path.join(dir,file));
 fs.writeFileSync(path.join(root,'site/diagrams.json'),JSON.stringify({renderer:'Mermaid (local Chromium)',bundleSha256:expected,diagrams:entries.map(({file,hash})=>({file,hash}))},null,2)+'\n');
 console.log('PASS',entries.length,'diagrams rendered locally');
 }finally{await browser.close();}
})().catch(e=>{console.error(e.message);process.exitCode=1;});
