// Serve a release build against an isolated Django QA database.
// Set QA_URL, QA_API_URL and QA_CREDENTIALS_FILE; never commit QA credentials.
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const {chromium} = require(process.env.PLAYWRIGHT_MODULE || 'playwright');
const base = process.env.QA_URL || 'http://127.0.0.1:8040';
const api = process.env.QA_API_URL || 'http://127.0.0.1:8031';
for (const url of [base,api]) assert(['localhost','127.0.0.1'].includes(new URL(url).hostname),'Use local QA services');
assert(process.env.QA_CREDENTIALS_FILE,'Provide a local, untracked QA credentials file');
const credentials = JSON.parse(fs.readFileSync(process.env.QA_CREDENTIALS_FILE,'utf8'));
const output = process.env.QA_OUTPUT_DIR || '/tmp/myportofolio-tutorial10-qa';
fs.mkdirSync(output,{recursive:true});
const runId=Date.now();
const checks=[];
function check(value,label){assert(value,label);checks.push(label);}
(async()=>{
 const projects=await (await fetch(api+'/api/v1/projects/')).json();
 assert(projects.length>0,'The isolated QA database needs portfolio projects');
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
   const page=await context.newPage();page.on('pageerror',e=>errors.push(e.message));
   const heading=name=>page.getByRole('heading',{name,exact:true});
   const projectButton=title=>page.getByRole('button',{name:new RegExp('^'+title.replace(/[.*+?^${}()|[\]\\]/g,'\\$&'))});
   const button=name=>page.getByRole('button',{name,exact:true});
   const scroll=async(delta)=>{await page.mouse.move(variant.width/2,Math.min(400,variant.height-100));await page.mouse.wheel(0,delta);await page.waitForTimeout(250);};
   const drawer=async(name)=>{await button('Open navigation menu').click();await page.getByText(name,{exact:true}).click();};
   const enter=async(name,value)=>{
    const field=page.getByRole('textbox',{name});await field.click();
    await page.waitForTimeout(200);await page.keyboard.press('ControlOrMeta+A');
    await field.pressSequentially(value,{delay:10});await page.waitForTimeout(100);await page.keyboard.press('Tab');
   };
   await page.goto(base);await page.waitForSelector('flt-glass-pane',{state:'attached'});
   const toggle=page.locator('flt-semantics-placeholder');if(await toggle.count())await toggle.evaluate(e=>e.click());
   await heading('MyPortfolio').waitFor();
   check((await page.locator('body').ariaSnapshot()).includes('2506553383'),variant.name+': owner identity');
   if(variant.height<700)await scroll(1400);
   await button('Lihat Proyek').click();await heading('Daftar Proyek').waitFor();
   await projectButton(projects[0].title).first().waitFor();
   check(true,variant.name+': public list shows real Django data without login');
   await projectButton(projects[0].title).first().click();
   await heading(projects[0].title).waitFor();
   await page.getByText(projects[0].full_description,{exact:true}).first().waitFor({state:'attached'});
   check(true,variant.name+': public detail shows full project data');
   await page.goBack();await heading('Daftar Proyek').waitFor();
   await drawer('Home');await heading('MyPortfolio').waitFor();
   if(variant.height<700)await scroll(1400);
   await button('Tambah Proyek').click();await heading('Login').waitFor();
   check(true,variant.name+': guest create action is guarded');
   await button('Login').click();
   await page.getByText('Username tidak boleh kosong!',{exact:true}).first().waitFor({state:'attached'});
   check(true,variant.name+': login validates empty input');
   await enter(/^Username/,credentials.username);await enter(/^Password/,'incorrect-password');
   await button('Login').click();
   await page.getByText('Username atau password salah (400).',{exact:true}).first().waitFor({state:'attached'});
   check(true,variant.name+': bad credentials report 400');
   await enter(/^Password/,credentials.password);
   await button('Login').click();await heading('Add Project Form').waitFor();
   check(true,variant.name+': token login resumes the guarded form');
   await scroll(1800);await button('Save').click();await scroll(-1800);
   await page.getByText('Judul Proyek tidak boleh kosong!',{exact:true}).first().waitFor({state:'attached'});
   check(true,variant.name+': project validation blocks empty POST');
   const title='Tutorial10 browser QA '+variant.name+' '+runId;
   await enter(/^Judul Proyek/,title);await enter(/^Kategori Proyek/,'Design');
   await enter(/^Deskripsi Singkat/,'Ringkasan uji integrasi.');
   await scroll(350);await enter(/^Deskripsi Lengkap/,'Data uji hanya disimpan pada salinan database QA.');
   await scroll(1800);await enter(/^Teknologi \/ Tags/,'Flutter, Django');
   await enter(/^URL \/ Path Gambar/,projects[0].image_url || '/static/img/monte.png');
   const createdResponse=page.waitForResponse(r=>r.url()===api+'/api/v1/projects/'&&r.request().method()==='POST');
   await button('Save').click();const response=await createdResponse;
   check(response.status()===201,variant.name+': authenticated POST returns 201');
   const created=await response.json();check(created.title===title&&!!created.id,variant.name+': server persists project and assigns UUID');
   await page.getByText('Proyek berhasil disimpan!',{exact:true}).waitFor();
   await page.waitForTimeout(350);await page.screenshot({path:path.join(output,variant.name+'-created.png')});
   await button('OK').click();
   await drawer('Daftar Proyek');await heading('Daftar Proyek').waitFor();
   await projectButton(title).waitFor();
   check(true,variant.name+': fresh public GET contains the saved project');
   await page.waitForTimeout(350);await page.screenshot({path:path.join(output,variant.name+'-list.png')});
   const logoutResponse=page.waitForResponse(r=>r.url()===api+'/api/v1/auth/logout/');
   await drawer('Logout');check((await logoutResponse).status()===204,variant.name+': logout revokes token with 204');
   await button('Open navigation menu').click();await page.getByText('Login',{exact:true}).waitFor();
   check(true,variant.name+': drawer reacts to logout');
   await page.getByText('Add Project',{exact:true}).click();await heading('Login').waitFor();
   check(true,variant.name+': logout protects subsequent create access');
   check(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth),variant.name+': no horizontal overflow');
   await context.close();console.log(variant.name+': live Django integration passed');
  }
  check(errors.length===0,'No JavaScript exceptions');
  const result={passed:checks.length,checks,output};
  fs.writeFileSync(path.join(output,'results.json'),JSON.stringify(result,null,2)+'\n');console.log(JSON.stringify(result,null,2));
 }finally{await browser.close();}
})().catch(error=>{console.error(error);process.exitCode=1;});
