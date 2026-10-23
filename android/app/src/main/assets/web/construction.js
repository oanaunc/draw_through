'use strict';
/** Original Apple construction diagrams, same 720×540 coordinates and paths. */
function construction(id) {
 const ink='#1b1915c7',guide='#96755773';let out='';
 const path=(d,color=ink,width=2,fill='none')=>{out+=`<path d="${d}" stroke="${color}" stroke-width="${width}" fill="${fill}" stroke-linecap="round" stroke-linejoin="round"/>`;};
 const line=(points,color=ink,width=2)=>path('M'+points.map(p=>p.join(' ')).join('L'),color,width);
 const oval=(x,y,w,h,fill='none')=>{out+=`<ellipse cx="${x+w/2}" cy="${y+h/2}" rx="${w/2}" ry="${h/2}" stroke="${ink}" stroke-width="2" fill="${fill}"/>`;};
 const box=(x,y,w,h,fill='none')=>{out+=`<rect x="${x}" y="${y}" width="${w}" height="${h}" stroke="${ink}" stroke-width="2" fill="${fill}"/>`;};
 const dot=(x,y)=>{out+=`<circle cx="${x}" cy="${y}" r="5" fill="#6e523c"/>`;};
 const label=(s,x,y)=>{out+=`<text x="${x}" y="${y}" text-anchor="middle" dominant-baseline="central" font-family="Georgia,serif" font-size="17" fill="#6e523c">${s}</text>`;};
 const leaf=(x,y,w,h)=>{path(`M${x} ${y+h}Q${x-w*.25} ${y-h*.2} ${x+w} ${y}Q${x+w*1.2} ${y+h*.9} ${x} ${y+h}`);line([[x,y+h],[x+w,y]],guide);};
 switch(Number(id)){
 case 1:for(let i=0;i<5;i++){const y=105+i*77;dot(125,y);dot(595,y-i*8);line([[125,y],[595,y-i*8]],ink,1.5);}break;
 case 2:for(let i=0;i<3;i++){const x=125+i*220;path(i===1?`M${x+80} 100C${x-130} 210 ${x+240} 320 ${x+80} 430`:`M${x+80} 100C${x-90} 140 ${x-90} 390 ${x+80} 430`);dot(x+80,100);dot(x+80,430);}break;
 case 3:for(let i=0;i<3;i++){const y=90+i*150,h=45+i*35;oval(175,y,370,h);line([[150,y+h/2],[570,y+h/2]],guide,1);line([[360,y-15],[360,y+h+15]],guide,1);}break;
 case 4:oval(130,100,250,250);box(290,215,250,210);line([[290,350],[290,215],[380,215]],ink,6);line([[540,425],[290,425]],ink,4);label('overlap → stronger edge',360,475);break;
 case 5:case 10:if(Number(id)===10){for(let i=0;i<=4;i++){const x=110+i*125;line([[x,65],[x,475]],guide,1);const y=65+i*102;line([[110,y],[610,y]],guide,1);}}leaf(220,100,275,320);line([[220,420],[195,465]]);break;
 case 6:line([[350,85],[435,135],[545,360],[455,465],[230,465],[175,360],[275,135],[350,85]],guide);oval(285,125,135,160);oval(205,260,310,200);path('M350 135Q350 85 385 70',ink,4);break;
 case 7:oval(465,180,140,180,'#96755721');oval(485,205,85,125);path('M175 170Q175 395 210 405Q335 460 465 405L500 170');oval(175,130,325,80);label('observe the opening',360,485);break;
 case 8:line([[360,65],[360,475]],guide,1);for(let i=0;i<=4;i++){const y=75+i*100;line([[175,y],[545,y]],guide,1);}line([[320,75],[400,75],[400,170],[470,235],[470,475],[250,475],[250,235],[320,170],[320,75]]);break;
 case 9:line([[90,410],[225,165],[310,290],[440,95],[630,410]]);line([[70,430],[650,430]],guide);line([[225,165],[440,165]],guide,1);label('compare each slope',360,485);break;
 case 11:for(let i=0;i<5;i++){const x=70+i*120;box(x,170,100,150,`rgba(27,25,21,${i*.22})`);label(String(i+1),x+50,355);}label('light                           →                           dark',360,110);break;
 case 12:oval(280,385,310,65,'#1b191529');oval(195,100,300,300,'#9675571a');line([[110,70],[190,140]],guide);label('light',105,45);out+='<defs><clipPath id="sphere"><ellipse cx="345" cy="250" rx="150" ry="150"/></clipPath></defs><g clip-path="url(#sphere)">';for(let i=0;i<13;i++){const x=290+i*13;path(`M${x} 205Q${x+65} 290 ${x-40} 365`,guide);}out+='</g>';break;
 case 13:for(let i=0;i<3;i++){const x=75+i*220;for(let j=0;j<10;j++){const o=j*14;path(i===2?`M${x} ${180+o}Q${x+72} ${250+o} ${x+145} ${180+o}`:`M${x} ${180+o}L${x+145} ${225+o}`,ink,1.5);if(i===1)line([[x+o,170],[x+o+15,365]],ink,1.5);}}break;
 case 14:box(80,65,560,410);box(265,180,190,140);for(const p of [[80,65],[640,65],[80,475],[640,475]])line([p,[360,250]],guide);line([[65,250],[655,250]],guide,1);dot(360,250);label('eye level',125,230);break;
 case 15:oval(225,105,270,85);oval(225,350,270,110);line([[225,147],[225,405]]);line([[495,147],[495,405]]);line([[360,70],[360,480]],guide,1);break;
 case 16:path('M300 475Q390 280 390 65',ink,3);leaf(335,110,60,125);leaf(215,170,135,115);leaf(355,220,150,110);leaf(205,320,125,90);break;
 case 17:path('M430 70C280 200 440 310 260 470',guide,4);oval(390,70,75,85);oval(300,175,120,150);oval(310,320,110,70);line([[320,205],[210,250],[150,190]]);line([[405,210],[500,265],[555,225]]);line([[330,375],[300,425],[260,475]]);line([[390,375],[470,410],[490,475]]);break;
 case 18:for(let i=0;i<3;i++){const x=50+i*225;box(x,160,185,210);oval(x+30+i*13,200,100-i*8,100,'#9675571a');box(x+80,280,80,65,'#1b19151f');label(['balance','emphasis','space'][i],x+90,410);}break;
 case 19:oval(315,185,90,90);for(let i=0;i<8;i++){out+=`<g transform="rotate(${i*45} 360 230)">`;oval(335,75,50,110);out+='</g>';}line([[360,350],[340,470]]);leaf(350,365,105,70);break;
 default:line([[100,430],[630,430]],guide);oval(150,260,220,165,'#96755714');line([[400,180],[415,405],[570,405],[590,180]]);oval(400,145,190,70);oval(580,210,65,105);line([[250,265],[275,230]],ink,4);oval(270,410,340,35,'#1b19151a');
 }
 return `<svg class="art" viewBox="0 0 720 540" role="img" aria-label="Instructional construction study">${out}</svg>`;
}
