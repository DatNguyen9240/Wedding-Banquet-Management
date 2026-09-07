import assert from 'node:assert/strict';
import fs from 'node:fs';
import vm from 'node:vm';
class Element {
    constructor(){this.value='';this.children=[];this.handlers={};this.style={setProperty(){},removeProperty(){}};}
    appendChild(e){e.parentNode=this;this.children.push(e);}
    insertBefore(e){this.appendChild(e);}
    remove(){this.parentNode.children=this.parentNode.children.filter(x=>x!==this);}
    setAttribute(){}
    addEventListener(n,f){this.handlers[n]=f;}
    dispatchEvent(){}
}
const fields={Loaitiecid:new Element(),DSKhuyenMai:new Element(),SobanManchinhthuc:new Element(),SobanChaychinhthuc:new Element(),Ngaytochuc:new Element()};
fields.Loaitiecid.value='BLT000001';fields.SobanManchinhthuc.value='20';fields.SobanChaychinhthuc.value='2';fields.Ngaytochuc.value='2026-09-20';
const parent=new Element();parent.appendChild(fields.DSKhuyenMai);
const modal={querySelector(s){if(s==='.promo-catalog-picker')return parent.children.find(x=>x.className==='promo-catalog-picker');return fields[s.match(/name="([^"]+)/)?.[1]]||null;}};
const pending=[];let lastPayload;
const context=vm.createContext({document:{body:{},createElement:()=>new Element()},MutationObserver:class{observe(){}},ApiClient:{post:(url,payload)=>{lastPayload=payload;return new Promise(resolve=>pending.push(resolve));}},console,Event:class{},setTimeout,clearTimeout});
let source=fs.readFileSync(new URL('../src/js/utils/PromotionAutoFillPlugin.js',import.meta.url),'utf8');
source=source.replace('init: init','init: init, fetch: _fetchAndFill');vm.runInContext(source,context);
const fetch=()=>context.PromotionAutoFillPlugin.fetch(modal,'frmHopDong');
const flush=()=>new Promise(resolve=>setImmediate(resolve));
fetch();assert.equal(JSON.parse(lastPayload.JsonData).Soluongban,22);assert.equal(JSON.parse(lastPayload.JsonData).TatCa,1);
pending.shift()({records:[{DocumentID:'KM1',Tenhang:'Ưu đãi A'},{DocumentID:'KM2',Tenhang:'Ưu đãi B',Soluong:2}]});await flush();
const select=modal.querySelector('.promo-catalog-picker').children[0];assert.equal(select.children.length,3);
select.value='KM2';select.handlers.change();assert.equal(fields.DSKhuyenMai.value,'Ưu đãi B (SL: 2)');
fetch();fields.Ngaytochuc.value='';fetch();pending.shift()({records:[{DocumentID:'OLD',Tenhang:'Hết hạn'}]});await flush();assert.equal(modal.querySelector('.promo-catalog-picker'),undefined);
fields.Ngaytochuc.value='2026-10-20';fetch();pending.shift()({records:[]});await flush();assert.ok(modal.querySelector('.promo-catalog-picker').textContent.includes('Không có CTKM'));
assert.equal(fields.DSKhuyenMai.value,'Ưu đãi B (SL: 2)');
console.log('PASS promotion selection, payload, stale response, missing date, empty catalog');
