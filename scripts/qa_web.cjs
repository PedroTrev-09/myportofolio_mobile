// Serve `flutter build web --no-web-resources-cdn` locally before running this script.
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const { chromium } = require(process.env.PLAYWRIGHT_MODULE || 'playwright');
const base = process.env.QA_URL || 'http://127.0.0.1:8018';
assert(['127.0.0.1','localhost'].includes(new URL(base).hostname),'Use a local Flutter build');
const output = process.env.QA_OUTPUT_DIR || '/tmp/myportofolio-mobile-qa';
fs.mkdirSync(output,{recursive:true});
const checks=[];
function check(condition,label){assert(condition,label);checks.push(label);}
const actions=['Lihat Proyek','Tambah Proyek','Lihat Pengalaman','Tambah Pengalaman','Logout'];
(async()=>{
 const browser=await chromium.launch({headless:true,executablePath:process.env.CHROME_PATH || '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome'});
 const errors=[];
 try{
  for(const variant of [
   {name:'desktop-light',width:1440,height:900,colorScheme:'light'},
   {name:'mobile-light',width:390,height:844,colorScheme:'light'},
   {name:'mobile-dark',width:390,height:844,colorScheme:'dark'},
   {name:'narrow-light',width:320,height:568,colorScheme:'light'},
  ]){
   const context=await browser.newContext({viewport:{width:variant.width,height:variant.height},colorScheme:variant.colorScheme});
   const page=await context.newPage();page.on('pageerror',error=>errors.push(error.message));
   await page.goto(base);await page.waitForSelector('flt-glass-pane',{state:'attached'});
   const toggle=page.locator('flt-semantics-placeholder');
   if(await toggle.count())await toggle.evaluate(element=>element.click());
   await page.getByRole('heading',{name:'MyPortfolio',exact:true}).waitFor();
   let snapshot=await page.locator('body').ariaSnapshot();
   check(snapshot.includes('Haikal Rafka A Rahman')&&snapshot.includes('2506553383')&&snapshot.includes('PBP A'),variant.name+': personal identity is readable');
   check(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth),variant.name+': no document horizontal overflow');
   await page.waitForLoadState('networkidle');
   await page.waitForTimeout(250); // Let CanvasKit finish painting after fonts/semantics initialize.
   await page.screenshot({path:path.join(output,variant.name+'.png')});
   // Short phones scroll to the menu; Flutter's semantics follow the painted widgets.
   if(variant.height<700){await page.mouse.move(160,300);await page.mouse.wheel(0,1400);await page.waitForTimeout(200);}
   for(const name of actions){
    const button=page.getByRole('button',{name,exact:true});
    await button.click();
    const message='Kamu telah menekan tombol '+name+'!';
    await page.getByText(message,{exact:true}).first().waitFor({state:'attached'});
    check(true,variant.name+': '+name+' shows the matching SnackBar');
   }
   await page.waitForTimeout(350);
   await page.screenshot({path:path.join(output,variant.name+'-snackbar.png')});
   if(variant.name==='desktop-light'){
    await page.getByRole('button',{name:'Lihat Proyek',exact:true}).focus();
    await page.keyboard.press('Enter');
    await page.getByText('Kamu telah menekan tombol Lihat Proyek!',{exact:true}).first().waitFor({state:'attached'});
    check(true,'desktop: keyboard activates a focused menu action');
   }
   await context.close();
  }
  check(errors.length===0,'No JavaScript exceptions in the release web build');
  const result={passed:checks.length,checks,output};
  fs.writeFileSync(path.join(output,'results.json'),JSON.stringify(result,null,2)+'\n');
  console.log(JSON.stringify(result,null,2));
 }finally{await browser.close();}
})().catch(error=>{console.error(error);process.exitCode=1;});
