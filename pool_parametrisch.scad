/* Edelstahlpool - parametrischer Geometrieentwurf, alle Masse in mm.
   F5: farbiges Modell. Ausgabe und Export siehe README.md.
   Keine Fertigungsfreigabe / keine Statik oder Stroemungssimulation. */
/* [Ausschnitt und Platzreserve] */
ausschnitt_breite = 3150;
ausschnitt_laenge = 7500;
// Vorlaeufige Platzreserve pro Seite, KEINE berechnete Profilabmessung!
tragwerk_platz = 150;
montageluft = 10;
hoehe = 1500; // von Boden an Aussenwand bis Oberkante
blech = 2;
werkstoff = "Duplex-Edelstahl 1.4462 (2205) - Planungsvorgabe";
/* [Tragwerk Geometrievorlage - nicht statisch bemessen] */
tragwerk_zeigen = true;
stuetzen_max_abstand = 805;
u_breite = 80;
u_tiefe = 40;
profil_dicke = 2;
rahmen_breite = 80;
rahmen_tiefe = 40;
// Gesamttiefe eines Stuetzenpaares von der Beckenwand nach aussen.
stuetzen_bautiefe = 140;
// K: zwei Diagonalen; Einzeldiagonale: eine durchgehende Strebe.
stuetzen_verband = "K"; // [K,Einzeldiagonale]
diagonal_endlage = 0.15; // relativ zur freien Stuetzenhoehe
diagonal_spiel = 1; // seitliches Spiel im U-Profil je Seite
/* [Boden und Mittelrinne] */
gefaelle_prozent = 3.5;
rinnenbreite = 220;
rinnentiefe = 100;
// Anschlusspositionen entlang Y; reine Anschlussplanung, kein Ansaugschutz!
ablauf_positionen = [0.25,0.75]; // relative Position entlang der Laenge
ablauf_d = 90;
/* [Oberflaeche] */
skimmer_aktiv = false; // nur optional: true ersetzt die Ueberlaufrinne komplett
// Relative X-/Z-Position sowie echte Ausschnittmasse
skimmer_position = [0.5,0.87];
skimmer_groesse = [400,150];
ueberlauf_tiefe = 200;
// Je ein Anschluss in den beiden seitlichen Rinnen
ueberlauf_ablauf_position = 0.5;
ueberlauf_ablauf_d = 90;
/* [Fliesenabdeckung und Auflager] */
fliesen_zeigen = true;
fliesen_breite = 200; // echtes Fliesenmass quer zur Rinne
fliesen_laenge = 200; // echtes Fliesenmass entlang der Rinne
fliesen_fuge = 8;
fliesen_dicke = 20;
fliesen_gefaelle_prozent = 2; // einstellbare Geometrieannahme
fliesen_randspiel = 2;
auflager_breite = 25;
anschlag_hoehe = 8; // ueber Auflager, unter Fliesenoberkante
/* [Einbauteile] */
gegenstrom = true;
// Frontwand Y=0, Rechteck-Platzhalter nach Herstellerzeichnung anpassen!
gegenstrom_position = [0.5,0.67];
gegenstrom_breite = 350;
gegenstrom_hoehe = 250;
// Automatik skaliert Anzahl und Positionen mit der Beckenlaenge.
duesen_automatisch = true;
duesen_max_abstand = 2000;
duesen_hoehe = 180;
duesen_d = 60;
// Manuell: [Seite (0=links,1=rechts), Y, Z, Lochdurchmesser, Ziel-Y], mm
duesen_manuell = [[0,1000,180,60,1000],[1,1000,180,60,1000]];
/* [Blechaufteilung] */
tafel_lang = 3000;
tafel_kurz = 1500;
/* [Darstellung und Export] */
ansicht = "Modell"; // [Modell,Explodiert,Einzelteil,Schnitt,Kontur,Rinnendetail,Fliesenkontur,Stuetzendetail,Profilkontur,Fertigungsplan]
teil_index = 0;
explosion = 300;
stroemung_zeigen = true;
teile_beschriften = false;
materialliste = true;
fertigungsplan_zeigen = true; // Montageplan und Profilstueckliste neben dem 3D-Pool
export_daten = false; // interne Datensaetze nur fuer Exportskript
fliese_index = 0;
profil_index = 0;
/* [Hidden] */
$fn=64;
eps=0.01;
system=skimmer_aktiv?"Skimmer":"Ueberlauf";
breite=ausschnitt_breite-2*(tragwerk_platz+montageluft);
laenge=ausschnitt_laenge-2*(tragwerk_platz+montageluft);
ablauf_y=[for(p=ablauf_positionen)p*laenge];
skimmer=[skimmer_position[0]*breite,skimmer_position[1]*hoehe,skimmer_groesse[0],skimmer_groesse[1]];
gegenstrom_x=gegenstrom_position[0]*breite;
gegenstrom_z=gegenstrom_position[1]*hoehe;
ueberlauf_ablauf_y=ueberlauf_ablauf_position*laenge;
nd=max(1,ceil(laenge/duesen_max_abstand));
duesen=duesen_automatisch?[for(s=[0:1],i=[0:nd-1])[s,(i+0.5)*laenge/nd,duesen_hoehe,duesen_d,(i+0.5)*laenge/nd]]:duesen_manuell;
a=(breite-rinnenbreite)/2;
fall=a*gefaelle_prozent/100;
zrinne=-fall-rinnentiefe;
schraeg=sqrt(a*a+fall*fall);
winkel=atan2(fall,a);
function rect(w,h)=[[0,0],[w,0],[w,h],[0,h]];
function clamp(v,lo,hi)=min(hi,max(lo,v));
// Record: ID, polygon, holes [x,y,w,h] (h=0 => circle diameter w),
// origin, local U, local V, thickness direction, colour, family.
function part(id,p,holes,o,u,v,n,c,f)=[id,p,holes,o,u,v,n,c,f];
function width(p)=max([for(q=p[1])q[0]])-min([for(q=p[1])q[0]]);
function height(p)=max([for(q=p[1])q[1]])-min([for(q=p[1])q[1]]);
function localholes(hs,x,y,w,h)=[for(q=hs) if(q[0]+q[2]/2>x && q[0]-q[2]/2<x+w && q[1]+(q[3]==0?q[2]:q[3])/2>y && q[1]-(q[3]==0?q[2]:q[3])/2<y+h) [q[0]-x,q[1]-y,q[2],q[3]]];
function add(u,v)=u+v;
// Rectangle panel grid, preserving hole location even across panel seams.
function panels(prefix,w,h,hs,o,u,v,n,c,f,maxw=tafel_lang,maxh=tafel_kurz)=
 let(nx=ceil(w/maxw),ny=ceil(h/maxh))
 [for(j=[0:ny-1],i=[0:nx-1])let(x=i*maxw,y=j*maxh,dx=min(maxw,w-x),dy=min(maxh,h-y))part(str(prefix,"_",i,"_",j),rect(dx,dy),localholes(hs,x,y,dx,dy),o+u*x+v*y,u,v,n,c,f)];
end_profile=[[0,0],[a,-fall],[a,zrinne],[a+rinnenbreite,zrinne],[a+rinnenbreite,-fall],[breite,0],[breite,hoehe],[0,hoehe]];
// Sutherland-Hodgman clipping: same polygon used for model and cut file.
function inside(p,axis,bound,keepgreater)=keepgreater?p[axis]>=bound:p[axis]<=bound;
function clip(poly,axis,bound,keepgreater)=len(poly)==0?[]: [for(i=[0:len(poly)-1])let(p=poly[i],q=poly[(i+1)%len(poly)],ip=inside(p,axis,bound,keepgreater),iq=inside(q,axis,bound,keepgreater)) each
 (ip && iq ? [q] : ip && !iq ? [p+(q-p)*(bound-p[axis])/(q[axis]-p[axis])] : !ip && iq ? [p+(q-p)*(bound-p[axis])/(q[axis]-p[axis]),q] : [])];
function sumlist(xs,i=0)=i>=len(xs)?0:xs[i]+sumlist(xs,i+1);
function area(poly)=len(poly)<3?0:abs(sumlist([for(i=[0:len(poly)-1])let(p=poly[i],q=poly[(i+1)%len(poly)])p[0]*q[1]-p[1]*q[0]]))/2;
function endpanels(prefix,hs,y,normal)=let(nx=ceil(breite/tafel_lang),ny=ceil((hoehe-zrinne)/tafel_kurz))
 [for(j=[0:ny-1],i=[0:nx-1])let(x=i*tafel_lang,dx=min(tafel_lang,breite-x),z=max(zrinne,hoehe-(j+1)*tafel_kurz),dy=min(tafel_kurz,hoehe-j*tafel_kurz-zrinne),p=clip(clip(clip(clip(end_profile,0,x,true),0,x+dx,false),1,z,true),1,z+dy,false))
 if(area(p)>0.001)part(str(prefix,"_",i,"_",j),[for(q=p)q-[x,z]],localholes(hs,x,z,dx,dy),[x,y,z],[1,0,0],[0,0,1],normal,[0.6,0.72,0.85],"Stirnwand")];
sideparts=[for(s=[0:1])each panels(str("W",s),laenge,hoehe,[for(d=duesen)if(d[0]==s)[d[1],d[2],d[3],0]],
 [s*breite,0,0],[0,1,0],[0,0,1],[s==0?-1:1,0,0],[0.7,0.78,0.85],"Laengswand")];
floorparts=[for(s=[0:1])each panels(str("B",s),laenge,schraeg,[],[s*breite,0,0],[0,1,0],[(s==0?1:-1)*cos(winkel),0,-sin(winkel)],[(s==0?-1:1)*sin(winkel),0,-cos(winkel)],[0.15,0.55,0.85],"Boden geneigt")];
channelparts=concat(
 panels("RB",laenge,rinnenbreite,[for(y=ablauf_y)[y,rinnenbreite/2,ablauf_d,0]],[a,0,zrinne],[0,1,0],[1,0,0],[0,0,-1],[0.15,0.75,0.45],"Rinnenboden"),
 [for(s=[0:1])each panels(str("RW",s),laenge,rinnentiefe,[],[a+s*rinnenbreite,0,zrinne],[0,1,0],[0,0,1],[s==0?-1:1,0,0],[0.1,0.6,0.4],"Rinnenwand")]);
frontparts=endpanels("V",gegenstrom?[[gegenstrom_x,gegenstrom_z,gegenstrom_breite,gegenstrom_hoehe]]:[],0,[0,-1,0]);
backparts=endpanels("H",system=="Skimmer"?[[skimmer[0],skimmer[1],skimmer[2],skimmer[3]]]:[],laenge,[0,1,0]);
// Rinnenbreite folgt der echten Fliesenbreite und dem Gefaelle.
fw=atan(fliesen_gefaelle_prozent/100);
fc=cos(fw);
fs=sin(fw);
tile_r0=blech+fliesen_randspiel;
tile_r1=tile_r0+fliesen_breite*fc;
g=tile_r1+fliesen_randspiel;
ueberlauf_breite=g;
rise=g*tan(fw);
gz=hoehe-ueberlauf_tiefe;
// Edge: ID, length, inner corner XY, tangent, outward. Corners meet on 45-degree mitres.
edges=[["L",laenge+2*blech,[-blech,-blech,0],[0,1,0],[-1,0,0]],
       ["R",laenge+2*blech,[breite+blech,laenge+blech,0],[0,-1,0],[1,0,0]],
       ["V",breite+2*blech,[breite+blech,-blech,0],[-1,0,0],[0,-1,0]],
       ["H",breite+2*blech,[-blech,laenge+blech,0],[1,0,0],[0,1,0]]];
// Planar strip including corner mitres, tiled into stock-sized rectangles.
function bandpoly(e,r0,r1,c=1,trim=0)=[[-r0+trim,r0/c],[e[1]+r0-trim,r0/c],[e[1]+r1-trim,r1/c],[-r1+trim,r1/c]];
function bandparts(prefix,e,r0,r1,z,ang,c,f,hs=[])=
 let(co=cos(ang),si=sin(ang),poly=bandpoly(e,r0,r1,co),nx=ceil((e[1]+2*r1)/tafel_lang),ny=ceil((r1-r0)/co/tafel_kurz),u=e[3],v=e[4]*co+[0,0,si],n=e[4]*si+[0,0,-co])
 [for(j=[0:ny-1],i=[0:nx-1])let(x=-r1+i*tafel_lang,y=r0/co+j*tafel_kurz,w=min(tafel_lang,e[1]+r1-x),h=min(tafel_kurz,r1/co-y),p=clip(clip(clip(clip(poly,0,x,true),0,x+w,false),1,y,true),1,y+h,false))
 if(area(p)>0.001)part(str(prefix,e[0],"_",i,"_",j),[for(q=p)q-[x,y]],localholes(hs,x,y,w,h),e[2]+[0,0,z]+u*x+v*y,u,v,n,c,f)];
// Keep the outlet clear of the restored transverse ties. Move to a bay centre
// only when the requested station would intersect a tie.
function rim_drain_u(e)=let(n=max(1,ceil((e[1]-2*blech-u_breite)/stuetzen_max_abstand)),pitch=(e[1]-2*blech-u_breite)/n,offset=blech+u_breite/2,desired=e[1]*ueberlauf_ablauf_position,
 nearest=offset+clamp(round((desired-offset)/pitch),0,n)*pitch,clear=u_breite/2+ueberlauf_ablauf_d/2+blech)
 abs(desired-nearest)>clear?desired:offset+(clamp(floor((desired-offset)/pitch),0,n-1)+0.5)*pitch;
overflowparts=system!="Ueberlauf"?[]:concat(
 [for(e=edges)each bandparts("ULB",e,0,g,gz,0,[1,0.65,0.12],"Rinnenboden / gerades Dach",(e[0]=="L" || e[0]=="R")?[[rim_drain_u(e),(rahmen_breite+g)/2,ueberlauf_ablauf_d,0]]:[])],
 [for(e=edges)each panels(str("ULW",e[0]),e[1]+2*g,ueberlauf_tiefe+rise,[],e[2]-e[3]*g+e[4]*g+[0,0,gz],e[3],[0,0,1],e[4],[1,0.5,0.1],"Erhoehte Rinnenaussenwand")],
 [for(e=edges)each bandparts("AI",e,0,auflager_breite,hoehe,fw,[0.95,0.8,0.2],"Fliesenauflager innen")],
 [for(e=edges)each bandparts("AA",e,g-auflager_breite,g,hoehe,fw,[0.95,0.8,0.2],"Fliesenauflager aussen erhoeht")],
 [for(e=edges)each panels(str("AS",e[0]),e[1],anschlag_hoehe,[],e[2]+[0,0,hoehe],e[3],[0,0,1],e[4],[0.9,0.35,0.15],"Poolseitiger Fliesenanschlag")]);
// True 200-mm tiles, then remainder pieces; corners clipped to the same mitre.
function tileparts(e)=let(poly=bandpoly(e,tile_r0,tile_r1,fc,fliesen_fuge/2),pitch=fliesen_laenge+fliesen_fuge,n=ceil((e[1]+2*tile_r1)/pitch),v=e[4]*fc+[0,0,fs])
 [for(i=[0:n-1])let(x=-tile_r1+i*pitch+fliesen_fuge/2,p=clip(clip(poly,0,x,true),0,x+fliesen_laenge,false))
 if(area(p)>0.001)part(str("FL",e[0],"_",i),[for(q=p)q-[x,tile_r0/fc]],[],e[2]+[0,0,hoehe]+e[3]*x+v*(tile_r0/fc),e[3],v,-e[4]*fs+[0,0,fc],[0.72,0.67,0.55],"Fliese mit Eckzuschnitt wo erforderlich")];
fliesen_teile=system!="Ueberlauf"?[]:[for(e=edges)each tileparts(e)];
teile=concat(sideparts,floorparts,channelparts,frontparts,backparts,overflowparts);
// Straight top frame entirely below gutter floor: no support notches in gutter sheets.
rahmen_oben_z=(system=="Ueberlauf"?gz-blech:hoehe)-rahmen_tiefe;
// Profile: ID, Typ, Laenge, Querschnitt-Breite, Tiefe, Dicke, Ursprung, Z-Rotation.
// U-Paare: Ruecken innen/an Wand und aussen; offene Seiten zeigen zueinander.
nx=max(1,ceil((breite-u_breite)/stuetzen_max_abstand));
ny=max(1,ceil((laenge-u_breite)/stuetzen_max_abstand));
sh=rahmen_oben_z-rahmen_tiefe;
dw=u_breite-2*profil_dicke-2*diagonal_spiel;
// Group: ID, inner-web centre XY, tangent, outward, rotation about Z.
stuetzen=[for(e=edges)let(n=max(1,ceil((e[1]-2*blech-u_breite)/stuetzen_max_abstand)))for(i=[0:n])
 [str(e[0],"_",i),e[2]+e[3]*(blech+u_breite/2+i*(e[1]-2*blech-u_breite)/n),e[3],e[4],atan2(e[3][1],e[3][0])]];
// Diagonal side outline, r outward / z upward. Ends trimmed to upright webs,
// K meeting point additionally trimmed horizontally. This is NOT a square cut.
function diagpoly(r0,r1,z0,z1,q0,q1,zlo,zhi)=let(dr=r1-r0,dz=z1-z0,l=sqrt(dr*dr+dz*dz),p=[[r0,z0+q0*l/dr],[r1,z1+q0*l/dr],[r1,z1+q1*l/dr],[r0,z0+q1*l/dr]])clip(clip(p,1,zlo,true),1,zhi,false);
function diagrecord(st,k)=let(r0=profil_dicke,r1=stuetzen_bautiefe-profil_dicke,mid=rahmen_tiefe+sh/2,
 z0=stuetzen_verband=="K"?mid:rahmen_tiefe+sh*diagonal_endlage,
 z1=rahmen_tiefe+sh*(k==0?diagonal_endlage:1-diagonal_endlage),
 dz=z1-z0,dr=r1-r0,l=sqrt(dr*dr+dz*dz),
 zlo=stuetzen_verband=="K" && k==1?mid:rahmen_tiefe,
 zhi=stuetzen_verband=="K" && k==0?mid:rahmen_oben_z,
 p=diagpoly(r0,r1,z0,z1,-u_tiefe/2,u_tiefe/2,zlo,zhi),
 along=[for(q=p)((q[0]-r0)*dr+(q[1]-z0)*dz)/l],raw=max(along)-min(along))
 [str("KD",st[0],"_",k),"UD",raw,dw,u_tiefe,profil_dicke,st[1],st[4],
 [r0,r1,z0,z1,zlo,zhi,p,acos(dr/l),l,st[0]]];
profile=concat(
 [for(st=stuetzen)each [
 [str("KI",st[0]),"U",sh,u_breite,u_tiefe,profil_dicke,st[1]-st[2]*u_breite/2+[0,0,rahmen_tiefe],st[4]],
 [str("KA",st[0]),"U",sh,u_breite,u_tiefe,profil_dicke,st[1]+st[2]*u_breite/2+st[3]*stuetzen_bautiefe+[0,0,rahmen_tiefe],st[4]+180]]],
 [for(st=stuetzen,k=stuetzen_verband=="K"?[0,1]:[1])diagrecord(st,k)],
 // Straight ties join outer upright to the continuous inner frame, no overlap.
 [for(st=stuetzen,z=[0,rahmen_oben_z]) [str("KT",st[0],"_",z),"R",stuetzen_bautiefe-rahmen_breite,u_breite,rahmen_tiefe,profil_dicke,st[1]-st[2]*u_breite/2+st[3]*rahmen_breite+[0,0,z],st[4]]],
 [for(s=[0:1],z=[0,rahmen_oben_z]) [str("RL",s,"_",z),"R",laenge+2*blech+2*rahmen_breite,rahmen_breite,rahmen_tiefe,profil_dicke,[s==0?-blech-rahmen_breite:breite+blech,-blech-rahmen_breite,z],0]],
 [for(s=[0:1],z=[0,rahmen_oben_z]) [str("RQ",s,"_",z),"R",breite+2*blech,rahmen_breite,rahmen_tiefe,profil_dicke,[breite+blech,s==0?-blech-rahmen_breite:laenge+blech,z],90]]);
assert(breite>rinnenbreite && rinnenbreite>ablauf_d && laenge>0 && hoehe>0);
assert(tragwerk_platz>=0 && montageluft>=0 && duesen_max_abstand>0);
assert(stuetzen_max_abstand>0 && u_breite>2*profil_dicke && u_tiefe>profil_dicke && profil_dicke>0 && rahmen_breite>2*profil_dicke && rahmen_tiefe>2*profil_dicke && hoehe>2*rahmen_tiefe);
assert(!tragwerk_zeigen || tragwerk_platz>=max(u_tiefe,rahmen_breite)+blech,"Platzreserve zu klein fuer Profile");
assert(stuetzen_bautiefe>=rahmen_breite+u_tiefe && stuetzen_bautiefe+blech<=tragwerk_platz,"Stuetzenpaar passt nicht in Tragwerkreserve");
assert(stuetzen_verband=="K" || stuetzen_verband=="Einzeldiagonale");
assert(diagonal_endlage>0 && diagonal_endlage<0.5 && diagonal_spiel>0 && dw>2*profil_dicke);
assert(fliesen_laenge>fliesen_fuge && fliesen_fuge>0 && fliesen_dicke>0 && fliesen_breite>0);
assert(fliesen_gefaelle_prozent>=0 && fliesen_gefaelle_prozent<=10 && fliesen_randspiel>fliesen_dicke*fs);
assert(auflager_breite>tile_r0+blech && 2*auflager_breite<g && anschlag_hoehe>0 && anschlag_hoehe<fliesen_dicke*fc);
assert(rahmen_oben_z>rahmen_tiefe,"Rinne zu tief fuer Stuetzen");
assert(blech>0 && tafel_lang>0 && tafel_kurz>0 && gefaelle_prozent>=0 && rinnentiefe>0);
assert(system=="Skimmer" || system=="Ueberlauf","system: Skimmer oder Ueberlauf");
assert(teil_index>=0 && teil_index<len(teile),"teil_index ausserhalb Liste");
assert(system!="Ueberlauf" || (g>ueberlauf_ablauf_d && ueberlauf_tiefe>0 && ueberlauf_tiefe<hoehe && ueberlauf_ablauf_y>ueberlauf_ablauf_d/2 && ueberlauf_ablauf_y<laenge-ueberlauf_ablauf_d/2));
assert(system!="Ueberlauf" || g-rahmen_breite>ueberlauf_ablauf_d+2*blech,"Rinnenablauf braucht Platz neben dem Randrahmen");
if(system=="Ueberlauf")for(e=edges)if(e[0]=="L" || e[0]=="R")let(n=max(1,ceil((e[1]-2*blech-u_breite)/stuetzen_max_abstand)),pitch=(e[1]-2*blech-u_breite)/n)
 for(i=[0:n])assert(abs(rim_drain_u(e)-(blech+u_breite/2+i*pitch))>u_breite/2+ueberlauf_ablauf_d/2+blech,"Kein Platz fuer Ablauf zwischen Querbindern");
assert(system!="Skimmer" || (skimmer[0]>skimmer[2]/2 && skimmer[0]+skimmer[2]/2<breite && skimmer[1]>skimmer[3]/2 && skimmer[1]+skimmer[3]/2<hoehe),"Skimmer ausserhalb Wand");
assert(!gegenstrom || (gegenstrom_x>gegenstrom_breite/2 && gegenstrom_x+gegenstrom_breite/2<breite && gegenstrom_z>gegenstrom_hoehe/2 && gegenstrom_z+gegenstrom_hoehe/2<hoehe),"Gegenstrom ausserhalb Wand");
for(d=duesen) assert((d[0]==0 || d[0]==1) && d[3]>0 && d[1]>d[3]/2 && d[1]<laenge-d[3]/2 && d[2]>d[3]/2 && d[2]<hoehe-d[3]/2 && d[4]>=0 && d[4]<=laenge,"Duese ungueltig");
for(y=ablauf_y) assert(y>ablauf_d/2 && y<laenge-ablauf_d/2,"Ablauf ausserhalb Boden");
module kontur(p){difference(){polygon(p[1]);for(h=p[2])translate([h[0],h[1]])if(h[3]==0)circle(d=h[2]);else square([h[2],h[3]],center=true);}}
module platziert(p,t=blech){o=p[3]+(ansicht=="Explodiert"?p[6]*explosion:[0,0,0]);u=p[4];v=p[5];n=p[6];
 multmatrix([[u[0],v[0],n[0],o[0]],[u[1],v[1],n[1],o[1]],[u[2],v[2],n[2],o[2]],[0,0,0,1]]){
 color(p[7])linear_extrude(t)kontur(p);
 if(teile_beschriften)color("black")translate([width(p)/2,height(p)/2,-0.3])linear_extrude(0.2)text(p[0],size=55,halign="center");}}
module pfeil(von,nach){d=nach-von;l=norm(d);color([0.1,0.8,0.95])translate(von)rotate([0,acos(d[2]/l),atan2(d[1],d[0])]){cylinder(h=l-70,r=9);translate([0,0,l-70])cylinder(h=70,r1=30,r2=0);}}
module fliesen(){for(p=fliesen_teile)platziert(p,fliesen_dicke);}
// Left gutter cross-section, pool to the right. Includes tile and support frame.
module rinnendetail(){projection(cut=true)rotate([-90,0,0])translate([0,-laenge*0.43,0])intersection(){
 union(){for(p=teile)platziert(p);fliesen();if(tragwerk_zeigen)for(p=profile)profil(p);}
 translate([-blech-g-20,laenge*0.43-1,gz-rahmen_tiefe-20])cube([g+blech+60,2,ueberlauf_tiefe+rahmen_tiefe+rise+fliesen_dicke+60]);}}
module diagprism(poly,w,x){multmatrix([[0,0,1,x],[1,0,0,0],[0,1,0,0],[0,0,0,1]])linear_extrude(w)polygon(poly);}
module profil(p){color(p[1]=="UD"?[0.95,0.65,0.12]:p[1]=="U"?[0.8,0.25,0.2]:[0.35,0.4,0.45])translate(p[6])rotate([0,0,p[7]])
 if(p[1]=="U")linear_extrude(p[2])difference(){square([p[3],p[4]]);translate([p[5],p[5]])square([p[3]-2*p[5],p[4]]);}
 else if(p[1]=="UD")let(m=p[8])difference(){
 diagprism(m[6],p[3],-p[3]/2);
 diagprism(diagpoly(m[0],m[1],m[2],m[3],-p[4]/2+p[5],p[4]/2+1,m[4],m[5]),p[3]-2*p[5],-p[3]/2+p[5]);}
 else difference(){cube([p[3],p[2],p[4]]);translate([p[5],-1,p[5]])cube([p[3]-2*p[5],p[2]+2,p[4]-2*p[5]]);}}
// Isolated first pair, including both tie bars and the adjoining inner frame.
module stuetzendetail(){st=stuetzen[0];
 for(p=profile)if((p[1]=="UD" && p[8][9]==st[0]) || p[0]==str("KI",st[0]) || p[0]==str("KA",st[0]) || p[0]==str("KT",st[0],"_0") || p[0]==str("KT",st[0],"_",rahmen_oben_z))profil(p);
 for(z=[0,rahmen_oben_z])profil(["Detailrahmen","R",u_breite,rahmen_breite,rahmen_tiefe,profil_dicke,st[1]-st[2]*u_breite/2+st[3]*rahmen_breite+[0,0,z],st[4]-90]);}
function rnd(v)=round(v*1000)/1000;
function profkey(p)=[p[1],rnd(p[2]),p[3],p[4],p[5]];
profilgruppen=[for(i=[0:len(profile)-1])if(len([for(j=[0:len(profile)-1])if(j<i && profkey(profile[j])==profkey(profile[i]))j])==0)
 let(p=profile[i],n=len([for(q=profile)if(profkey(q)==profkey(p))q]))[p[1],p[3],p[4],p[5],rnd(p[2]),n,rnd(n*p[2]/1000)]];
function gruppentext(r)=str(r[5]," x ",r[0]," ",r[1],"x",r[2],"x",r[3]," | L=",r[4]," mm | ges. ",r[6]," m");
module plantext(s,x,y,size=30,c=[0.12,0.2,0.28]){color(c)translate([x,y])text(s,size=size,font="Liberation Sans");}
module planlinie(a,b,c=[0.2,0.3,0.4],d=2){color(c)hull(){translate(a)circle(d=d);translate(b)circle(d=d);}}
module knoten(p,label){color([0.05,0.65,0.35])translate(p)difference(){circle(r=13);circle(r=9);}plantext(label,p[0]+22,p[1]-8,24,[0.05,0.5,0.25]);}
module fertigungsplan(){
 dp=[for(p=profile)if(p[1]=="UD" && p[8][9]==stuetzen[0][0])p];
 top=rahmen_oben_z+rahmen_tiefe;
 plantext(str("MONTAGEPLAN | ",len(stuetzen)," STUETZENPAARE | ",system),-120,top+220,42);
 // Side elevation, inner upright at left; colours follow the 3D model.
 for(p=dp)color([0.95,0.65,0.12])polygon(p[8][6]);
 color([0.8,0.25,0.2])for(r=[0,stuetzen_bautiefe-u_tiefe])translate([r,rahmen_tiefe])square([u_tiefe,sh]);
 color([0.35,0.4,0.45])for(z=[0,rahmen_oben_z])translate([0,z])square([stuetzen_bautiefe,rahmen_tiefe]);
 plantext("INNEN",-75,-70,24);plantext("AUSSEN",stuetzen_bautiefe+10,-70,24);
 planlinie([-70,rahmen_tiefe],[-70,rahmen_oben_z]);
 for(z=[rahmen_tiefe,rahmen_oben_z])planlinie([-85,z],[-55,z]);
 color([0.12,0.2,0.28])translate([-95,rahmen_tiefe+sh/2])rotate(90)text(str("2 x L=",rnd(sh)," mm"),size=26,halign="center");
 planlinie([0,-110],[stuetzen_bautiefe,-110]);
 for(x=[0,stuetzen_bautiefe])planlinie([x,-100],[x,-120]);
 plantext(str("Bautiefe ",stuetzen_bautiefe," mm"),0,-160,24);
 for(i=[0:len(dp)-1])let(m=dp[i][8]){
 knoten([m[0],m[2]],"J1");knoten([m[1],m[3]],str("J",i+2));
 }
 for(z=[rahmen_tiefe,rahmen_oben_z])for(x=[u_tiefe/2,stuetzen_bautiefe-u_tiefe/2])knoten([x,z],"J4");
 x=580;
 plantext("JE STUETZENPAAR",x,top+100,34);
 plantext(str("2 x U ",u_breite,"x",u_tiefe,"x",profil_dicke," - Laenge ",rnd(sh)," mm"),x,top+45,28);
 for(i=[0:len(dp)-1])plantext(str("1 x UD ",dw,"x",u_tiefe,"x",profil_dicke," - Rohlaenge ",rnd(dp[i][2])," mm (",i==0 && stuetzen_verband=="K"?"unten":"oben", ")"),x,top-10-i*48,28);
 plantext(str("2 x Querbinder R ",u_breite,"x",rahmen_tiefe,"x",profil_dicke," - Laenge ",stuetzen_bautiefe-rahmen_breite," mm"),x,top-120,28);
 plantext("U-Oeffnungen zueinander; gelbe Streben in die U-Profile einpassen.",x,top-180,25);
 plantext("J1: mittlerer K-Knoten am inneren U; J2/J3: am aeusseren U.",x,top-225,25);
 plantext("J4: Staender an oberen/unteren Rahmen bzw. Querbinder anschliessen.",x,top-270,25);
 plantext("Knoten markieren Verbindungsstellen, keine festgelegte Nahtgroesse.",x,top-315,25);
 plantext("DIAGONALZUSCHNITT",x,top-390,32);
 plantext(str("Achsmass ",rnd(dp[0][8][8])," mm; Schraegschnitt ",rnd(dp[0][8][7])," Grad gegen rechtwinklig."),x,top-440,25);
 plantext("Rohlaenge = maximale Laenge vor Endbeschnitt; siehe KD-Seitenkonturen.",x,top-485,25);
 plantext("74-mm-Profil (Standardfall) ist kein bestaetigtes Handelsprofil.",x,top-530,25);
 plantext("PROFILSTUECKLISTE GESAMTER POOL",x,top-610,32);
 for(i=[0:len(profilgruppen)-1])plantext(gruppentext(profilgruppen[i]),x,top-665-i*48,27);
 plantext("Nennmasse ohne Saegefuge/Zugabe. Keine Schweiss- oder Statikfreigabe.",x,top-720-len(profilgruppen)*48,24);
 plantext("Rahmenabschnitte im Detail gehoeren zum umlaufenden Rahmen; nicht doppelt kaufen.",x,top-765-len(profilgruppen)*48,24);
}
module modell(){for(p=teile)platziert(p);if(tragwerk_zeigen)for(p=profile)profil(p);if(fliesen_zeigen && system=="Ueberlauf")fliesen();if(stroemung_zeigen)for(d=duesen)pfeil([d[0]*breite,d[1],d[2]],[breite/2,d[4],-fall+30]);
 if(fertigungsplan_zeigen && tragwerk_zeigen)translate([breite+g+700,0,0])rotate([90,0,0])linear_extrude(0.4)fertigungsplan();}
if(materialliste){
 echo(str("=== STUECKLISTE: ",system," | alle Laengen in mm ==="));
 if(tragwerk_zeigen){
 echo(str("STUETZEN: ",len(stuetzen)," Paare, je 2 gegengleiche U-Staender und ",stuetzen_verband=="K"?2:1," diagonale U-Stuecke"));
 for(r=profilgruppen){echo(gruppentext(r));if(export_daten)echo("CUTGROUP",r);}
 echo("UD: Rohlaenge vor schraegem Endbeschnitt; KD-Zeichnung beachten. U und R: gerade Enden.");
 echo("Montage: U-Oeffnungen gegeneinander. J1 innerer K-Knoten; J2/J3 aeussere Diagonalanschluesse; J4 Rahmenanschluesse.");
 }
 echo("=== BLECHZUSCHNITTE: 1 Stueck je ID, genaue Kontur/Ausschnitte siehe DXF ===");
 for(p=teile)echo(str(p[0]," | 1 St. | ",p[8]," | ",rnd(width(p))," x ",rnd(height(p))," x ",blech," mm"));
 echo("Bestellbedarf des modellierten Umfangs; Lieferlaengen, Saegefuge, Zugaben und Werkstoffnummer noch festlegen.");
}
if(materialliste && export_daten){
 echo("INFO|Geometrieentwurf, Nennmasse ohne Schweissspalt, Fase, Schrumpfung oder Schnittfuge");
 echo(str("INFO|Innenmass=",breite,"x",laenge,"x",hoehe,"; Bodenabsenkung=",fall,"; Rinnenboden-Z=",zrinne));
 for(i=[0:len(teile)-1])let(p=teile[i]){
 echo(str("BOM|",i,"|",p[0],"|",p[8],"|",width(p),"|",height(p),"|",blech,"|",werkstoff));
 echo("PART",i,p[0],p[1],p[2],p[3],p[4],p[5],p[6]);
 }
 if(tragwerk_zeigen)for(p=profile)echo("PROFILE",p);
 if(tragwerk_zeigen)echo("BRACING",len(stuetzen),stuetzen_bautiefe,sh,dw,stuetzen_verband);
 if(system=="Ueberlauf"){
 for(e=edges)if(e[0]=="L" || e[0]=="R")echo("OUTLET",e[0],e[1]*ueberlauf_ablauf_position,rim_drain_u(e));
 echo("RIM",g,rise,fliesen_gefaelle_prozent,auflager_breite,anschlag_hoehe,rahmen_oben_z,gz,fliesen_breite,fliesen_laenge);
 for(i=[0:len(fliesen_teile)-1])let(p=fliesen_teile[i]){
 echo("COVER",p[0],1,width(p),height(p),fliesen_dicke);
 echo("TILE",i,p[0],p[1],p[2],p[3],p[4],p[5],p[6],fliesen_dicke);
 }}
}
if(ansicht=="Kontur")kontur(teile[teil_index]);
else if(ansicht=="Fliesenkontur") {assert(fliese_index>=0 && fliese_index<len(fliesen_teile));kontur(fliesen_teile[fliese_index]);}
else if(ansicht=="Rinnendetail")rinnendetail();
else if(ansicht=="Stuetzendetail")stuetzendetail();
else if(ansicht=="Fertigungsplan")fertigungsplan();
else if(ansicht=="Profilkontur"){assert(profil_index>=0 && profil_index<len(profile) && profile[profil_index][1]=="UD");polygon(profile[profil_index][8][6]);}
else if(ansicht=="Einzelteil")color(teile[teil_index][7])linear_extrude(blech)kontur(teile[teil_index]);
else if(ansicht=="Schnitt")projection(cut=true)rotate([-90,0,0])translate([0,-laenge/2,0])for(p=teile)platziert(p);
else modell();
