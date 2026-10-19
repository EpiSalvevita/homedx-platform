(function(root){
 'use strict';
 const answered=v=>v!==undefined&&v!==null&&v!==''&&(!Array.isArray(v)||v.length>0)&&(typeof v!=='object'||Array.isArray(v)||Object.keys(v).length>0);
 function rule(r,a,features={},isVisible=()=>true){
  if(!r)return true;
  if(r.any)return r.any.some(x=>rule(x,a,features,isVisible));
  if(r.all)return r.all.every(x=>rule(x,a,features,isVisible));
  if(r.feature)return r.op==='shown'&&features[r.feature]===true;
  if(!isVisible(r.item)||!answered(a[r.item]))return false;
  const v=a[r.item];
  switch(r.op){case'answered':return true;case'eq':return v===r.value;case'neq':return v!==r.value;case'in':return r.values.includes(v);case'contains':return Array.isArray(v)&&v.includes(r.value);default:return false;}
 }
 function visible(items,a,features={}){
  const by=new Map(items.map(x=>[x.id,x]));const memo=new Map();const visiting=new Set();
  function check(id){if(memo.has(id))return memo.get(id);if(visiting.has(id))throw Error('Zyklische Anzeigeabhängigkeit: '+id);visiting.add(id);const item=by.get(id);const ok=!!item&&rule(item.visibilityRule,a,features,check);visiting.delete(id);memo.set(id,ok);return ok;}
  return items.filter(x=>check(x.id));
 }
 function valid(item,value){
  if(!answered(value))return !item.required;
  const opts=item.options||[];
  if(item.type==='matrix_presence'||item.type==='matrix_importance'){
   const labels=item.type==='matrix_presence'?['regelhaft','manchmal','selten','nicht','unbekannt']:['erforderlich','hilfreich','nicht erforderlich','nicht beurteilbar'];
   return typeof value==='object'&&!Array.isArray(value)&&opts.every(row=>labels.includes(value[row]))&&Object.keys(value).every(row=>opts.includes(row));
  }
  if(item.type.startsWith('rank_'))return Array.isArray(value)&&value.length>0&&value.length<=(item.type==='rank_top3'?3:5)&&new Set(value).size===value.length&&(!item.options||value.every(x=>opts.includes(x)));
  if(item.type==='scale_0_10')return /^([0-9]|10)$/.test(String(value));
  if(item.type==='textarea'||item.type==='version'){
   const digits=opts.join(' ').match(/([\d.]+) Zeichen/);const limit=digits?Number(digits[1].replace(/\./g,'')):500;
   return typeof value==='string'&&value.length<=limit;
  }
  if(['multi','bodymap_multi','lab_multi','multi_with_detail'].includes(item.type))return Array.isArray(value)&&new Set(value).size===value.length&&value.every(x=>opts.includes(x))&&(!value.some(x=>(item.exclusiveOptions||[]).includes(x))||value.length===1);
  if(['single','scale_agree','scale_1_5'].includes(item.type))return typeof value==='string'&&opts.includes(value);
  return false;
 }
 const exclusive=s=>/^(keine(?:\b|r)|keines|nichts|weiß ich nicht|weiss ich nicht|möchte ich nicht|kann ich nicht)/i.test(s);
 function toggle(values,value,checked,exclusiveOptions){const isExclusive=s=>exclusiveOptions?exclusiveOptions.includes(s):exclusive(s);const v=values||[];if(!checked)return v.filter(x=>x!==value);return isExclusive(value)?[value]:[...v.filter(x=>!isExclusive(x)&&x!==value),value];}
 const api={answered,rule,visible,valid,exclusive,toggle};root.RCEngine=api;if(typeof module==='object')module.exports=api;
})(typeof window==='object'?window:globalThis);
