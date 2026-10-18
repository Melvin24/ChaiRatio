// Daily Ritual has a navigation stack; the other explorations keep their own navigation.
function mountRitual(root, initial) {
 const requestedRoute = root.dataset.hero && previewRoute ? previewRoute : initial.route;
 const s = {id:mounts.length, route:requestedRoute==='measurements'?'ratios':requestedRoute,
  recipe:initial.recipe||0, step:0, ratio:root.dataset.hero&&!previewRoute?savedRatio():2,
  servings:4, size:150, strength:'Regular', sweetness:'Regular'};
 const parents = {calculator:'ratios', methods:'calculator', detail:'methods', guide:'detail', complete:'guide'};
 const names = {ratios:'Ratios', calculator:'Calculator', methods:'Methods', detail:'Recipe', guide:'Guide', complete:'Finished'};
 const find = q => root.querySelector(q);
 let history = [], scrollTimer, restoreFrame, modalReturn;
 function seedHistory() {
  history = [];
  for(let route=parents[s.route];route;route=parents[route]) history.unshift({route,recipe:s.recipe,step:0,scroll:0});
 }
 function setRatio(i) {
  s.ratio=Math.max(0,Math.min(ratios.length-1,i));
  if(root.dataset.hero&&!previewRoute)persist(s.ratio);
  const r=ratios[s.ratio];root.style.setProperty('--ratio-bg',r.tone);
  root.querySelectorAll('.ratio-progress button').forEach((n,i)=>{n.classList.toggle('selected',i===s.ratio);n.setAttribute('aria-pressed',String(i===s.ratio));});
  if(find('.ratio-position'))find('.ratio-position').textContent=`${s.ratio+1} of 5`;
  if(find('.ratio-announcement'))find('.ratio-announcement').textContent=`${r.name}, ${r.a} to ${r.b} water to milk, ${Math.round(r.b/(r.a+r.b)*100)} percent milk`;
 }
 function selectedRatio() {
  const viewport=find('.ratio-viewport');
  if(viewport?.clientWidth)setRatio(Math.round(viewport.scrollLeft/viewport.clientWidth));
 }
 function scrollRatio(i) {
  const viewport=find('.ratio-viewport');setRatio(i);
  viewport?.scrollTo({left:s.ratio*viewport.clientWidth,behavior:matchMedia('(prefers-reduced-motion: reduce)').matches?'instant':'smooth'});
 }
 function push(route, updates={}) {
  history.push({route:s.route, recipe:s.recipe, step:s.step, scroll:find('.phone-content').scrollTop});
  Object.assign(s,updates,{route});render(true,'push');
 }
 function pop() {
  const previous=history.pop();if(!previous)return;
  Object.assign(s,{route:previous.route,recipe:previous.recipe,step:previous.step});
  render(true,'pop',previous.scroll);
 }
 function nav() {
  const previous=history.at(-1);
  return `<nav class="ritual-nav" aria-label="Screen navigation">${previous?button(`${icon('back')}${names[previous.route]}`,'pop','back'): '<span class="brand">ChaiRatio</span>'}${button(icon('info'),'info','info-button','aria-label="Know your measures" aria-haspopup="dialog" title="Know your measures" data-symbol="info.circle"')}</nav>`;
 }
 function render(focus=false,motion='',scroll=0) {
  clearTimeout(scrollTimer);cancelAnimationFrame(restoreFrame);
  const ratio=s.route==='ratios';root.classList.toggle('ratio-phone',ratio);root.dataset.route=s.route;
  let footer='';
  if(ratio)footer=button(`Let’s make chai ${icon('arrow')}`,'go:calculator');
  if(s.route==='calculator')footer=button(`Methods ${icon('arrow')}`,'go:methods');
  if(s.route==='detail')footer=button('Start cooking','start');
  if(s.route==='guide')footer=button(s.step===3?'Finish guide':'Next step','step-next');
  if(s.route==='complete')footer=button('Make another cup','again');
  root.innerHTML=`<div class="ritual-screen"><div class="status" aria-hidden="true"><span>9:41</span><span class="status-icons">${icon('wifi')}${icon('battery')}</span></div>${nav()}<div class="phone-content ${motion?`navigate-${motion}`:''}">${screenMarkup(s)}</div>${footer?`<div class="action-footer ${s.route==='calculator'?'floating-action':''}">${footer}</div>`:''}<div class="home-indicator" aria-hidden="true"></div></div>`;
  setRatio(s.ratio);
  if(ratio) {
   const viewport=find('.ratio-viewport');
   restoreFrame=requestAnimationFrame(()=>{viewport.scrollLeft=s.ratio*viewport.clientWidth;});
   viewport.addEventListener('scroll',()=>{clearTimeout(scrollTimer);scrollTimer=setTimeout(selectedRatio,100);},{passive:true});
   viewport.addEventListener('keydown',e=>{
    if(['ArrowLeft','ArrowRight','Home','End'].includes(e.key)) {
     e.preventDefault();scrollRatio(e.key==='Home'?0:e.key==='End'?4:s.ratio+(e.key==='ArrowRight'?1:-1));
    }
   });
  }
  if(s.route==='calculator')refresh();
  find('.phone-content').scrollTop=scroll;
  if(focus)find('.screen-heading')?.focus({preventScroll:true});
 }
 function openInfo(focus=true) {
  if(find('.measurements-overlay'))return;
  modalReturn=document.activeElement;
  find('.ritual-screen').inert=true;
  const overlay=document.createElement('div');overlay.className='measurements-overlay';
  overlay.innerHTML=`<section class="measurements-sheet" role="dialog" aria-modal="true" aria-label="Know your measures"><div class="sheet-handle" aria-hidden="true"></div><div class="sheet-nav"><span>Measurements</span>${button('Done','dismiss-info','sheet-done','aria-label="Done, close measurements"')}</div><div class="measurements-content">${measurementsMarkup()}</div></section>`;
  root.append(overlay);if(focus)overlay.querySelector('.screen-heading').focus({preventScroll:true});
 }
 function closeInfo() {
  find('.measurements-overlay')?.remove();find('.ritual-screen').inert=false;
  if(modalReturn?.isConnected&&root.contains(modalReturn))modalReturn.focus({preventScroll:true});
  else find('[data-action="info"]').focus({preventScroll:true});
 }
 function refresh() {
  find('[data-results]').innerHTML=liquidResults(s);
  find('[data-dose]').textContent=doseCopy(s);
  find('[data-action="minus"]').disabled=s.servings===1;find('[data-action="plus"]').disabled=s.servings===20;
  root.querySelectorAll('[data-action^="size:"],[data-action^="strength:"],[data-action^="sweetness:"]').forEach(n=>{
   const [key,value]=n.dataset.action.split(':');const selected=s[key]===(key==='size'?Number(value):value);
   n.classList.toggle('selected',selected);n.setAttribute('aria-pressed',String(selected));
  });
 }
 function entry(input,commit=false) {
  const n=Number(input.value),error=find('.field-error');
  if(input.value===''||!Number.isFinite(n)||!Number.isInteger(n)) {
   if(commit){input.value=s.servings;input.removeAttribute('aria-invalid');error.hidden=true;}
   else{input.setAttribute('aria-invalid','true');error.textContent='Enter a whole number from 1 to 20.';error.hidden=false;}return;
  }
  s.servings=Math.max(1,Math.min(20,n));input.removeAttribute('aria-invalid');
  if(n!==s.servings){input.value=s.servings;error.textContent='Servings must be between 1 and 20.';error.hidden=false;}else error.hidden=true;
  refresh();
 }
 root.addEventListener('input',e=>{if(e.target.matches('input[type=number]'))entry(e.target);});
 root.addEventListener('focusout',e=>{if(e.target.matches('input[type=number]'))entry(e.target,true);});
 root.addEventListener('change',e=>{if(e.target.matches('select')){setRatio(Number(e.target.value));refresh();}});
 root.addEventListener('keydown',e=>{
  const modal=find('.measurements-overlay');if(!modal)return;
  if(e.key==='Escape'){e.preventDefault();closeInfo();}
  if(e.key==='Tab') {
   const controls=[...modal.querySelectorAll('button,[href],input,select,[tabindex="0"]')];
   const first=controls[0],last=controls.at(-1);
   if(e.shiftKey&&(document.activeElement===first||!controls.includes(document.activeElement))){e.preventDefault();last.focus();}
   else if(!e.shiftKey&&(document.activeElement===last||!controls.includes(document.activeElement))){e.preventDefault();first.focus();}
  }
 });
 root.addEventListener('click',e=>{
  if(e.target.matches('.measurements-overlay')){closeInfo();return;}
  const target=e.target.closest('[data-action]');if(!target||target.disabled)return;
  const [action,value]=target.dataset.action.split(':');
  if(action==='info')openInfo();
  else if(action==='dismiss-info')closeInfo();
  else if(action==='pop')pop();
  else if(action==='go')push(value);
  else if(action==='recipe')push('detail',{recipe:Number(value)});
  else if(action==='start')push('guide',{step:0});
  else if(action==='step-next'){if(s.step===3)push('complete');else{s.step++;render(true);}}
  else if(action==='step-back'){s.step=Math.max(0,s.step-1);render(true);}
  else if(action==='again'){s.route='calculator';seedHistory();render(true);}
  else if(action==='ratio')scrollRatio(Number(value));
  else if(action==='plus'||action==='minus') {
   s.servings=Math.max(1,Math.min(20,s.servings+(action==='plus'?1:-1)));
   const input=find('input[type=number]');input.value=s.servings;input.removeAttribute('aria-invalid');find('.field-error').hidden=true;refresh();
  } else if(['size','strength','sweetness'].includes(action)) {s[action]=action==='size'?Number(value):value;refresh();}
 });
 // Keep the selected page aligned when the showcase or device viewport changes width.
 new ResizeObserver(()=>{const v=find('.ratio-viewport');if(v)v.scrollLeft=s.ratio*v.clientWidth;}).observe(root);
 const reset=()=>{
  Object.assign(s,{route:requestedRoute==='measurements'?'ratios':requestedRoute,recipe:initial.recipe||0,step:0,ratio:2,servings:4,size:150,strength:'Regular',sweetness:'Regular'});
  seedHistory();render();if(requestedRoute==='measurements')openInfo();
 };
 seedHistory();mounts.push({root,state:s,reset});render();if(requestedRoute==='measurements')openInfo(Boolean(root.dataset.hero));return reset;
}
