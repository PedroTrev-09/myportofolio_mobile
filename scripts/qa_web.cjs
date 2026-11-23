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
    if(name==='Tambah Proyek'||name==='Tambah Pengalaman'){
     const title=name==='Tambah Proyek'?'Add Project Form':'Tambah Pengalaman';
     await page.getByRole('heading',{name:title,exact:true}).waitFor();
     check(true,variant.name+': project action opens the form');
     await page.goBack();
     await page.getByRole('heading',{name:'MyPortfolio',exact:true}).waitFor();
     check(true,variant.name+': browser Back returns to the menu');
     if(variant.height<700){await page.mouse.move(160,300);await page.mouse.wheel(0,1400);await page.waitForTimeout(200);}
    }
   }
   await page.waitForTimeout(350);
   await page.screenshot({path:path.join(output,variant.name+'-snackbar.png')});
   if(variant.name==='desktop-light'){
    await page.getByRole('button',{name:'Lihat Proyek',exact:true}).focus();
    await page.keyboard.press('Enter');
    await page.getByText('Kamu telah menekan tombol Lihat Proyek!',{exact:true}).first().waitFor({state:'attached'});
    check(true,'desktop: keyboard activates a focused menu action');
   }
   await page.getByRole('button',{name:'Open navigation menu',exact:true}).click();
   await page.getByText('Add Project',{exact:true}).click();
   await page.getByRole('heading',{name:'Add Project Form',exact:true}).waitFor();
   check(true,variant.name+': drawer opens the project form');
   const scrollForm=async(delta)=>{await page.mouse.move(variant.width/2,Math.min(variant.height-100,400));await page.mouse.wheel(0,delta);await page.waitForTimeout(200);};
   await scrollForm(1800);
   await page.getByRole('button',{name:'Save',exact:true}).click();
   await scrollForm(-1800);
   await page.getByText('Nama proyek tidak boleh kosong!',{exact:true}).first().waitFor({state:'attached'});
   await page.getByText('Deskripsi proyek tidak boleh kosong!',{exact:true}).first().waitFor({state:'attached'});
   check(true,variant.name+': required fields reject empty submission');
   const enter=async(name,value)=>{
    const field=page.getByRole('textbox',{name});
    await field.click();
    await page.waitForTimeout(200); // Flutter attaches its text-input connection after focus.
    await page.keyboard.press('ControlOrMeta+A');
    await field.pressSequentially(value,{delay:20});
    await page.waitForTimeout(100);
    await page.keyboard.press('Tab');
   };
   await enter(/^Nama Proyek/,'Portofolio Flutter');
   await enter(/^Deskripsi Proyek/,'Latihan form Tutorial 09.');
   await page.getByRole('button',{name:'Kategori Proyek Web Development',exact:true}).click();
   await page.getByRole('menuitem',{name:'Mobile Development',exact:true}).click();
   await enter('Teknologi yang Digunakan','Flutter, Dart');
   await enter('Tautan Proyek','https://example.com/portfolio');
   await scrollForm(1800);
   await page.screenshot({path:path.join(output,variant.name+'-form.png')});
   await page.getByRole('button',{name:'Save',exact:true}).click();
   for(const line of ['Nama Proyek: Portofolio Flutter','Deskripsi: Latihan form Tutorial 09.','Kategori: Mobile Development','Teknologi: Flutter, Dart','Tautan: https://example.com/portfolio']){
    await page.getByText(line,{exact:true}).waitFor({state:'attached'});
   }
   check(true,variant.name+': confirmation shows all five submitted values');
   await page.waitForTimeout(350); // Wait for the dialog transition before visual capture.
   await page.screenshot({path:path.join(output,variant.name+'-dialog.png')});
   await page.getByRole('button',{name:'OK',exact:true}).click();
   await scrollForm(-1800);
   for(const name of ['Nama Proyek','Deskripsi Proyek','Teknologi yang Digunakan','Tautan Proyek']){
    check(await page.getByRole('textbox',{name,exact:true}).inputValue()==='',variant.name+': OK resets '+name);
   }
   await page.getByRole('button',{name:'Kategori Proyek Web Development',exact:true}).waitFor({state:'attached'});
   check(true,variant.name+': OK resets category to Web Development');
   await page.getByRole('button',{name:'Open navigation menu',exact:true}).click();
   await page.getByText('Home',{exact:true}).click();
   await page.getByRole('heading',{name:'MyPortfolio',exact:true}).waitFor();
   check(true,variant.name+': drawer returns to Home');
   await page.getByRole('button',{name:'Open navigation menu',exact:true}).click();
   await page.getByText('Tambah Pengalaman',{exact:true}).click();
   await page.getByRole('heading',{name:'Tambah Pengalaman',exact:true}).waitFor();
   check(true,variant.name+': drawer opens Experience');
   await scrollForm(1800);
   await page.getByRole('button',{name:'Simpan',exact:true}).click();
   await scrollForm(-1800);
   for(const text of ['Judul tidak boleh kosong!','Deskripsi tidak boleh kosong!','Tanggal mulai wajib dipilih!']){
    await page.getByText(text,{exact:true}).first().waitFor({state:'attached'});
   }
   check(true,variant.name+': invalid Experience stays on the form');
   await enter(/^Judul Pengalaman/,'Desainer Portofolio');
   await enter('Lokasi','Jakarta');
   await page.getByRole('button',{name:'Kategori Pengalaman Full-Time',exact:true}).click();
   await page.getByRole('menuitem',{name:'Volunteer',exact:true}).click();
   const pickDate=async(label,value)=>{
    await scrollForm(-1800);
    await page.getByRole('textbox',{name:label}).click();
    const dialog=page.getByRole('dialog');
    await dialog.getByRole('button',{name:'Switch to input',exact:true}).click();
    const input=dialog.getByRole('textbox');
    await input.click();
    await page.waitForTimeout(200);
    await page.keyboard.press('ControlOrMeta+A');
    await input.pressSequentially(value,{delay:20});
    await page.keyboard.press('Tab');
    await dialog.getByRole('button',{name:'Pilih',exact:true}).click();
    await dialog.waitFor({state:'detached'});
   };
   await pickDate(/^Tanggal Mulai/,'01/10/2026');
   await pickDate(/^Tanggal Selesai/,'01/09/2026');
   await scrollForm(1800);
   await enter(/^Deskripsi Pengalaman/,'Mendesain identitas visual.');
   await page.getByRole('button',{name:'Simpan',exact:true}).click();
   await page.getByText('Tanggal selesai tidak boleh sebelum tanggal mulai!',{exact:true}).first().waitFor({state:'attached'});
   check(true,variant.name+': reversed Experience dates are rejected');
   await pickDate(/^Tanggal Selesai/,'01/11/2026');
   await scrollForm(1800);
   await page.getByRole('button',{name:'Simpan',exact:true}).click();
   for(const line of ['Judul: Desainer Portofolio','Kategori: Volunteer','Lokasi: Jakarta','Tanggal mulai: 2026-01-10','Tanggal selesai: 2026-01-11','Deskripsi: Mendesain identitas visual.']){
    await page.getByText(line,{exact:true}).waitFor({state:'attached'});
   }
   check(true,variant.name+': valid Experience summary contains every field');
   await page.waitForTimeout(350);
   await page.screenshot({path:path.join(output,variant.name+'-experience-dialog.png')});
   await page.getByRole('button',{name:'Tutup',exact:true}).click();
   await page.waitForTimeout(250);
   await page.screenshot({path:path.join(output,variant.name+'-experience-form.png')});
   await page.getByRole('button',{name:'Simpan',exact:true}).click();
   await page.getByText('Deskripsi: Mendesain identitas visual.',{exact:true}).waitFor({state:'attached'});
   check(true,variant.name+': closing summary preserves the form');
   await page.getByRole('button',{name:'Tutup',exact:true}).click();
   await page.getByRole('button',{name:'Open navigation menu',exact:true}).click();
   await page.getByText('Home',{exact:true}).click();
   await page.getByRole('heading',{name:'MyPortfolio',exact:true}).waitFor();
   check(true,variant.name+': Experience drawer returns to Home');
   console.log(variant.name+': browser checks passed');
   await context.close();
  }
  check(errors.length===0,'No JavaScript exceptions in the release web build');
  const result={passed:checks.length,checks,output};
  fs.writeFileSync(path.join(output,'results.json'),JSON.stringify(result,null,2)+'\n');
  console.log(JSON.stringify(result,null,2));
 }finally{await browser.close();}
})().catch(error=>{console.error(error);process.exitCode=1;});
