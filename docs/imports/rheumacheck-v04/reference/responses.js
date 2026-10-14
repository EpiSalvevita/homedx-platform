(function(root){
 'use strict';
 function record(item,value,shown,E){
  const has=E.answered(value);
  const state=!shown?'not_shown_by_rule':has?'answered':item.required?'not_answered_required':'not_answered_optional';
  const code=x=>(item.optionCodes||[]).find(o=>o.label===x)?.code??null;
  let coded=null;
  if(shown&&has){
   if(item.type.startsWith('matrix_'))coded=Object.entries(value).map(([row,rating])=>({rowCode:code(row),rowLabel:row,rating}));
   else if(['multi','bodymap_multi','lab_multi','multi_with_detail'].includes(item.type)||item.type.startsWith('rank_'))coded=value.map(code);
   else if(['single','scale_agree','scale_1_5'].includes(item.type))coded=code(value);
   else if(item.type==='scale_0_10')coded=Number(value);
  }
  return {itemId:item.id,itemVersion:item.itemVersion,responseState:state,exposure:shown?'shown_by_rule':'not_shown_by_rule',requiredWhenShown:!!item.required,value:shown&&has?value:null,codedValue:coded,valid:!shown||E.valid(item,value)};
 }
 const api={record};root.RCResponseExport=api;if(typeof module==='object')module.exports=api;
})(typeof window==='object'?window:globalThis);
