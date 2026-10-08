"""Generate original Little World Kitchen SVG art; no external artwork required."""
from pathlib import Path
import math
ROOT = Path(__file__).resolve().parents[1] / 'assets'
for part in ('items','icons','characters'): (ROOT/part).mkdir(exist_ok=True,parents=True)

def path(d, fill, stroke=None, sw=2.5, extra=''):
    return f'<path d="{d}" fill="{fill}"'+(f' stroke="{stroke}" stroke-width="{sw}" stroke-linecap="round" stroke-linejoin="round"' if stroke else '')+f' {extra}/>'
def ellipse(x,y,rx,ry,c,stroke=None,sw=2.5):
    return f'<ellipse cx="{x}" cy="{y}" rx="{rx}" ry="{ry}" fill="{c}"'+(f' stroke="{stroke}" stroke-width="{sw}"' if stroke else '')+'/>'
def circle(x,y,r,c,stroke=None,sw=2.5): return ellipse(x,y,r,r,c,stroke,sw)
def rect(x,y,w,h,r,c,stroke=None,sw=2.5):
    return f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="{r}" fill="{c}"'+(f' stroke="{stroke}" stroke-width="{sw}"' if stroke else '')+'/>'
def line(d,c,sw=2.5): return path(d,'none',c,sw)
def group(s,tr): return f'<g transform="{tr}">{s}</g>'
def gradient(name,a,b): return f'<linearGradient id="{name}" x1=".2" y1="0" x2=".8" y2="1"><stop stop-color="{a}"/><stop offset="1" stop-color="{b}"/></linearGradient>'
DEFS = '<defs>'+''.join(gradient(*g) for g in [('red','#ff8572','#e93754'),('green','#b9e568','#499e54'),('yellow','#ffe888','#f4b93b'),('cream','#fff9d8','#efcf98'),('orange','#ffd279','#f7873e'),('pink','#ffa8bc','#ed6a9c'),('teal','#a1ecdc','#43b6ab'),('blue','#b6e7f5','#73b4cf'),('brown','#d49a62','#8d513b'),('dark','#667478','#34484d'),('white','#ffffff','#d8e9e2')])+'</defs>'
def save(cat,name,s,shadow=True):
    bg=ellipse(49,83,29,5,'#20433e',None) if shadow else ''
    if bg: bg='<g opacity=".13">'+bg+'</g>'
    (ROOT/cat/f'{name}.svg').write_text('<svg xmlns="http://www.w3.org/2000/svg" width="96" height="96" viewBox="0 0 96 96">'+DEFS+bg+s+'</svg>')
def leaf(x,y,scale=1,rot=0): return group(path('M0 0C-18 -20 -21 -30 -8 -33C9 -34 12 -16 0 0Z','url(#green)','#448b4a',2)+line('M0 -2L-7 -26','#75b35a',1.5),f'translate({x} {y}) rotate({rot}) scale({scale})')
def spark(x,y): return path(f'M{x} {y-7}Q{x+1} {y-1} {x+7} {y}Q{x+1} {y+1} {x} {y+7}Q{x-1} {y+1} {x-7} {y}Q{x-1} {y-1} {x} {y-7}Z','#fff8c7')
def shine(x,y,rot=20): return f'<ellipse cx="{x}" cy="{y}" rx="4" ry="8" fill="#fff" opacity=".55" transform="rotate({rot} {x} {y})"/>'
# Fresh ingredients: hand drawn silhouettes and softened shaded materials.
s= line('M32 51Q36 22 55 18M64 49Q53 36 55 18','#678346',4)+leaf(56,20,.55,74)
s+=circle(29,62,19,'url(#red)','#c2374c')+circle(65,64,19,'url(#red)','#c2374c')+shine(22,55)+shine(58,57)
s+=line('M26 45Q30 48 35 46M62 47Q67 50 70 48','#a63342',2)
save('items','cherry',s)
s=path('M21 39C21 18 72 20 77 39C82 54 61 82 49 85C38 82 15 54 21 39Z','url(#red)','#cc4255')
s+=path('M47 32L28 20L43 24L47 12L53 26L68 19L61 32L76 34L57 40L48 34L33 40L36 32Z','url(#green)','#4c9851',2)
for x,y in [(30,44),(45,47),(63,45),(35,59),(52,61),(48,74),(64,56)]: s+=ellipse(x,y,1.7,3,'#ffe5a4')
s+=shine(28,43,-20)
save('items','strawberry',s)
s=path('M17 33C11 56 28 81 53 79C78 77 91 48 78 22L72 20C79 46 64 62 44 59C29 57 24 46 25 33Z','url(#yellow)','#d5a331',2.5)
s+=path('M25 34C18 58 41 72 58 66C72 61 80 44 76 27','none','#f1c345',3)+path('M18 34L19 25L28 25L26 35Z','#8d7447')+path('M73 24L72 15L77 14L81 24Z','#7c6440')+line('M26 42Q31 57 47 59','#fff4b9',3)
save('items','banana',s)
s=path('M34 37L22 18L42 28L42 8L52 25L65 12L62 30L80 25L65 44Z','url(#green)','#4b984e')
s+=path('M29 41C40 29 63 30 73 48C88 75 64 89 46 84C24 78 16 56 29 41Z','url(#yellow)','#d39c36')
for a in [0,1,2,3]: s+=line(f'M{26+a*12} {43}L{37+a*12} 80','#dfab3e',1.7)
for a in [0,1,2,3]: s+=line(f'M23 {49+a*9}L76 {39+a*9}','#dfab3e',1.7)
s+=shine(31,47,-16)
save('items','pineapple',s)
s=path('M18 45C23 27 38 28 49 35C62 28 79 29 82 50C87 75 62 85 48 84C29 85 10 67 18 45Z','url(#red)','#c63f48')
s+=path('M47 38L32 25L44 28L49 16L54 30L69 25L60 37L73 43L56 43L48 39L34 44L38 37Z','url(#green)','#4c8f4b',2)+shine(25,48,-22)
save('items','tomato',s)
s=leaf(55,35,.85,-30)+leaf(60,34,.85,32)+leaf(60,32,.7,75)
s+=path('M41 31C48 24 72 35 75 46C74 56 30 89 17 87C20 72 29 41 41 31Z','url(#orange)','#d17b39')+line('M36 44L48 51M28 60L38 66M54 36L62 42','#e98642',3)+line('M42 37Q29 55 25 71','#ffe2a3',3)
save('items','carrot',s)
s=path('M42 46L59 45L67 80Q50 87 33 79Z','url(#green)','#599657')
s+=line('M48 69L40 48M54 62L65 43','#d4e98c',4)
for x,y,r in [(29,42,16),(45,31,20),(62,33,16),(73,47,16),(52,48,20),(32,52,16)]: s+=circle(x,y,r,'url(#green)','#4d9952',2)
s+=line('M24 36Q27 29 34 31M41 20Q48 16 54 21M70 38L75 40','#d0ef8c',3)
save('items','broccoli',s)
s=path('M47 15C61 15 69 37 77 50C94 83 61 93 37 85C9 75 22 50 29 35C33 24 35 15 47 15Z','#4e9151','#3b7847')
s+=path('M47 22C57 21 63 40 70 53C83 77 61 85 40 79C18 72 31 52 35 39C39 28 40 22 47 22Z','url(#green)','#b4d964',3)+circle(49,62,16,'url(#brown)','#965939')+shine(42,55,25)
save('items','avocado',s)
s=path('M28 14L68 14L64 28L76 76Q76 84 65 85L27 85Q18 83 21 73L32 28Z','url(#cream)','#c0a273')
s+=path('M27 14Q47 19 69 14L65 25Q46 29 30 25Z','#c39b6b')+rect(28,39,40,32,7,'#ee846e')+path('M48 65V45M48 51Q34 48 38 44Q45 44 48 51M48 58Q33 54 39 51Q46 52 48 58M49 55Q62 46 62 52Q58 58 49 59','#fff3cd','#fff3cd',2)+line('M24 74L26 61','#fff8e3',3)
save('items','flour',s)
s=path('M16 43C10 22 34 18 49 24C66 15 90 30 80 47L78 76Q78 83 68 84L27 84Q17 83 18 73Z','url(#orange)','#bc7c41',3)
s+=path('M25 44C18 31 37 27 49 32C63 24 78 34 71 46L70 72Q69 75 62 75L32 75Q27 75 27 69Z','url(#cream)','#e2b568',2)
for x,y in [(38,44),(56,52),(40,65),(64,38)]: s+=circle(x,y,2,'#deb981')
save('items','bread',s)
s=path('M17 41L68 20L82 64L35 83L17 71Z','url(#yellow)','#d59f3c')+path('M17 41L35 54L82 36L68 20Z','#ffeb99','#d9ab49')+path('M35 54V83L82 64V36Z','#f7c845','#d9ab49')
for x,y,r in [(47,64,4),(66,56,5),(70,68,3),(49,38,3)]: s+=circle(x,y,r,'#e3a434')
s+=line('M24 40L35 47L70 34','#fff6c6',3)
save('items','cheese',s)
s=path('M50 14C65 13 83 48 77 68C73 89 26 92 20 68C15 46 35 14 50 14Z','url(#cream)','#c8ac80')+shine(33,42,25)
s+=path('M56 62C58 60 63 61 65 66C71 61 75 65 77 72C86 83 70 91 62 86C52 92 39 84 45 73C40 63 49 58 56 62Z','url(#white)','#cccfac',2)+circle(62,74,10,'url(#yellow)','#e7ae2f',1.5)+ellipse(59,71,3,2,'#fff3a2')
save('items','egg',s)
# Plated dishes share porcelain edges.
def plate(): return ellipse(48,74,38,13,'#b5d0c8')+ellipse(48,70,38,13,'#fffcef','#d1dfd7',2)+ellipse(48,70,29,8,'#e7f0e6')
s=path('M25 32H72L65 82H34Z','url(#pink)','#b87683')+ellipse(49,32,24,7,'#ffd1d0','#b87683',2)+line('M59 52L70 13L80 13','#ffeed9',6)+line('M38 43L42 71','#ffe3e1',4)+group(path('M-8 0Q-12 -9 0 -9Q12 -9 8 0L0 10Z','url(#red)','#dc5868',1.5)+path('M-6 -8L0 -14L6 -8Z','#67ad57'), 'translate(32 32)')
save('items','smoothie',s)
s=plate()+path('M17 58Q18 87 49 86Q79 85 80 57Z','url(#teal)','#55a19b')+ellipse(48,55,32,11,'#619755')
for x,y,r in [(24,51,11),(41,47,13),(63,48,13),(75,52,9),(44,56,12),(58,55,10)]:s+=circle(x,y,r,'url(#green)','#66a458',1.2)
for x,y in [(32,51),(62,56),(50,41)]: s+=circle(x,y,7,'url(#red)','#cf5551',1)+ellipse(x-2,y-2,2,1,'#ffc6a5')
s+=path('M26 43L31 36L39 40L35 48Z','#f6d681')+path('M62 39L68 33L75 40L69 47Z','#f6d681')+line('M25 67Q44 78 66 70','#b0e9d4',3)
save('items','salad',s)
s=plate()+group(path('M13 35Q8 17 29 17Q49 12 66 27L66 67L16 67Z','url(#orange)','#bd8048',2.5)+path('M20 36Q16 23 33 24Q47 20 59 32L59 59L23 59Z','#ffe2a0')+path('M27 49C24 40 31 30 41 33C47 26 57 35 54 42C63 50 56 56 49 55C42 64 35 56 32 57C22 58 21 53 27 49Z','url(#white)','#ddd4b1',1.5)+circle(41,45,10,'url(#yellow)','#e4aa37',1.5),'translate(6 2) rotate(-9 48 48)')
save('items','toast',s)
s=plate()
for dx in [-16,16]:
 s+=group(ellipse(48,63,17,10,'url(#brown)','#aa714a',2)+ellipse(48,59,17,8,'#ffc980')+path('M31 55Q48 41 65 55L64 60Q47 54 33 62Z','#67a553')+path('M34 48C24 35 42 27 51 33C62 29 72 47 63 52L35 53Z','url(#white)','#d6d5b7',1.5)+path('M33 46Q49 31 64 43L61 56L54 52L48 57L41 49L34 51Z','url(#yellow)','#e8b246',1.3)+line('M47 40L50 42M41 44L45 42M56 46L53 46','#60985a',2),f'translate({dx} 0)')
save('items','benedict',s)
s=plate()+path('M14 51Q17 83 48 84Q81 83 83 51Z','url(#orange)','#ca7955')+ellipse(48,51,35,12,'#ffc66c','#bc7050',2.5)
for x,y,c in [(29,50,'#ee7153'),(41,46,'#81b557'),(53,56,'#f5e5a9'),(63,45,'#eb825b'),(68,55,'#77a853')]:s+=ellipse(x,y,6,3,c)
s+=line('M24 66Q34 75 47 75','#ffe0aa',3)+line('M33 32Q27 24 33 17M49 29Q44 20 51 12M64 32Q58 24 64 17','#e4ddd0',3)
save('items','soup',s)
s=plate()
for x,y in [(31,48),(63,48),(46,67)]:
 s+=rect(x-14,y-10,28,21,9,'#40665b','#2d534a',2)+ellipse(x,y-8,14,10,'#fff9db','#b1c8ad',1.5)+ellipse(x,y-8,8,6,'#eda876')+rect(x-5,y-12,7,8,2,'#ed7657')+rect(x+2,y-11,4,7,1,'#74a361')
save('items','sushi',s)
s=plate()+path('M14 50Q17 83 48 84Q81 83 83 50Z','#e97462','#bc6254')+ellipse(48,50,35,12,'#d0a059','#bc6254',2.5)
for k in range(4): s+=path(f'M{24+k*7} 53Q{22+k*7} 36 {42+k*6} 44Q{64+k*3} 51 {48+k*5} 56','none','#f9d889',2.2)
s+=ellipse(66,43,10,8,'#fffae2','#e8d9a6',1)+ellipse(67,44,5,4,'#ffc13e')+path('M24 48L27 36L37 38L34 51Z','#558259')+line('M59 26L85 14M60 31L88 20','#835947',3)+line('M25 66Q34 75 47 75','#ffb1a1',3)
save('items','ramen',s)
s=plate()
for x,y,c1,c2 in [(33,55,'#e997b7','#c6638c'),(63,59,'#94cda2','#69a67b'),(46,35,'#efbb77','#d59c5c')]:
 s+=ellipse(x,y+5,19,8,c2)+rect(x-19,y-3,38,8,5,'#fff2dc')+ellipse(x,y-3,19,9,c1,c2,1.5)+line(f'M{x-11} {y-6}Q{x-2} {y-12} {x+8} {y-7}','#fff1d8',2)
save('items','macaron',s)
s=path('M26 35L34 67L45 72L45 82L32 86H65L52 82V72L63 67L73 35Z','url(#orange)','#cd9353')+ellipse(49,35,24,8,'#ffe2a0','#cd9353',2)+line('M54 49L67 11L81 11','#72bca3',4)+path('M13 28Q24 12 40 26Z','#ed806e','#c36058',2)+line('M25 24L35 49','#b58154',2)+circle(69,36,11,'#ffe99b','#e3b74c',2)+path('M69 27V45M60 36H78','#fff4c5','#fff4c5',1.5)+circle(31,41,6,'url(#red)')
save('items','tropical',s)
# Ingredient generators: illustrated crates / countertop fridge.
for name,kind in [('produce_fruit','fruit'),('produce_veg','veg')]:
 s=''
 if kind=='fruit':
  s+=circle(32,34,13,'url(#red)','#cd4e57',2)+circle(55,28,14,'url(#orange)','#d18a40',2)+leaf(60,17,.45,58)+circle(70,42,13,'url(#yellow)','#c7a04a',2)+leaf(34,23,.4,45)
 else:
  s+=group(path('M0 0L-8 -25L5 -31L14 -21L8 2Z','url(#orange)','#c98046',2)+leaf(4,-27,.5,-30),'translate(31 49)')+circle(56,32,14,'url(#green)','#619d54',2)+circle(73,37,12,'url(#green)','#619d54',2)+circle(46,40,12,'url(#green)','#619d54',2)
 s+=path('M15 45L27 38H83L77 78L20 79Z','#dba96b','#a77850',2)+rect(16,47,65,11,3,'#efc085','#bb8a56',2)+rect(18,65,60,12,3,'#efc085','#bb8a56',2)+rect(20,44,7,38,2,'#c59462')+rect(68,44,7,38,2,'#c59462')
 s+=circle(23,51,1.5,'#987344')+circle(71,51,1.5,'#987344')+rect(37,57,23,15,4,'#fff5d6')+path('M49 69L49 59M49 64L44 61M49 64L53 60','#74a977','#74a977',2)
 save('items',name,s)
s=rect(19,12,60,73,11,'url(#teal)','#498f87',2.5)+rect(24,17,50,21,6,'#c5f2df')+line('M19 43H78','#498f87',2.5)+rect(26,49,5,17,2,'#f5fff0')+rect(26,25,5,9,2,'#fffdf0')+circle(62,62,9,'#fff2c8')+path('M62 55L58 62H63L60 70L68 60H63L65 55Z','#e6b943')
save('items','produce_pantry',s)
# Seven machines, original counter equipment.
s=path('M59 53L88 22L81 15L53 48Z','url(#brown)','#754f3c',3)+ellipse(39,58,31,21,'url(#dark)','#30484a',3)+ellipse(38,53,29,17,'#a0b4ad','#4e6464',2.5)+ellipse(39,53,21,11,'#657f79')+path('M27 55C17 45 29 40 39 42C52 35 64 50 53 57C44 66 34 57 27 55Z','#fff9df')+ellipse(41,50,8,6,'url(#yellow)')
save('items','pan',s)
s=path('M28 20H68L62 58H35Z','url(#blue)','#739f9f',2.5)+path('M33 34H64L60 54H37Z','#f3aa98')+path('M68 24Q86 23 80 42L65 45','none','#78b9b0',5)+rect(25,14,45,8,4,'#58958c')+rect(36,58,26,9,3,'#d6e8d9')+path('M31 65H66L73 82H24Z','url(#teal)','#4d948b')+circle(48,75,5,'#fff4d5')+line('M39 27L41 49','#effbf2',3)
save('items','blender',s)
s=rect(12,22,72,60,8,'url(#pink)','#b66472')+rect(17,26,61,13,4,'#fff5dc')+circle(25,33,3,'#72aaa0')+circle(39,33,3,'#72aaa0')+rect(58,29,14,6,2,'#78a494')+rect(19,45,58,30,5,'#5b6666','#b05e6b',2)+rect(25,49,46,18,3,'#dc9962')+line('M26 67H70','#f1cf94',2)+rect(24,42,48,4,2,'#fef1d6')+path('M31 62Q30 50 40 52Q48 49 49 62Z','#efc278')+path('M48 62Q46 53 56 54Q64 51 65 62Z','#efc278')
save('items','oven',s)
s=rect(17,34,63,42,13,'url(#teal)','#4d9289')+ellipse(49,35,33,11,'#baded0','#609c90',2)+ellipse(49,35,26,7,'#6ca59c')+path('M16 44Q3 39 7 54L18 58M80 44Q94 39 90 54L79 58','none','#5d9c93',5)+ellipse(48,25,26,6,'#d5eade','#74ab9b',2)+rect(42,14,14,8,4,'#6a9f90')+line('M29 45V62','#ceefe0',4)
save('items','pot',s)
s=rect(15,36,67,38,8,'url(#cream)','#b79a71')+ellipse(48,38,34,11,'#e6c293','#b99b6e',2)+ellipse(48,34,31,10,'#fff1ce','#c4a171',2)+rect(43,19,12,9,4,'#d6b385')+line('M19 51H78M19 67H78','#be9e70',2)
for x in [26,37,48,59,70]:s+=line(f'M{x} 44V50M{x} 57V65','#ba9c72',2)
save('items','steamer',s)
s=path('M23 62L19 84M70 62L76 84','none','#536f68',5)+path('M15 39Q17 77 48 78Q80 77 83 39Z','url(#red)','#b35359')+ellipse(49,40,35,14,'#677775','#435e59',2.5)
for y in [31,37,43,49]:s+=line(f'M24 {y}H74','#adbbb0',2)
s+=path('M31 38Q35 25 51 29Q67 32 62 43Q47 49 31 38Z','url(#orange)','#d58f5b',1.5)+line('M39 31L44 43M48 29L53 44M56 32L60 41','#975f43',2)
save('items','grill',s)
s=path('M24 37L38 83H65L76 37Z','url(#blue)','#6a959b')+path('M24 37L32 20H65L76 37Z','#d9e9e6','#6a959b',2.5)+rect(36,11,24,12,4,'#94b9b6','#6a959b',2)+line('M34 44L44 74','#e9ffff',5)+path('M55 46L53 61L64 54Z','#8ab6b9')
save('items','shaker',s)
# Icons. Readable without glyph fonts at 24px.
icons={
'coin':circle(48,48,35,'url(#yellow)','#dcaa44',3)+circle(48,48,26,'none','#efbb44',3)+path('M49 27L37 47H51L40 68L63 43H49L57 27Z','#d49c31')+line('M28 32Q37 20 49 21','#fff3bb',4),
'star':path('M48 11L59 34L84 38L66 56L70 82L48 69L24 82L29 56L10 38L36 34Z','url(#yellow)','#dba147',3)+path('M48 20L43 42L22 42L39 48Z','#fff5b4'),
'gem':path('M12 33L28 16H70L85 34L48 82Z','url(#pink)','#b5679b',3)+path('M12 33H85M28 16L34 33L48 82L64 33L70 16M34 33L48 16L64 33','none','#ffd3ec',2.5),
'energy':path('M43 10L23 52H45L36 87L76 38H55L66 10Z','url(#yellow)','#dfaa40',3)+path('M46 18L34 44H46','#fff3a9'),
'lock':path('M30 41V30Q30 8 48 8Q69 8 68 30V41','none','#acbcae',8)+rect(17,35,62,47,12,'#dce3d7','#a9b9a8',3)+circle(48,54,7,'#93a993')+rect(44,55,8,13,3,'#93a993'),
'gift':rect(16,39,64,44,6,'url(#red)','#c65d61',3)+rect(11,28,74,18,4,'#f68e78','#c65d61',3)+rect(42,28,13,55,2,'#ffe3a0')+path('M48 27C17 29 20 6 34 12Q42 15 48 27C74 -1 86 25 59 29Z','#ffcf84','#d49b55',2.5),
'book':path('M12 18Q30 11 48 20Q65 11 84 18V78Q65 72 48 81Q28 73 12 78Z','url(#teal)','#579c8e',3)+path('M17 20Q33 17 48 25Q64 17 79 21V69Q63 64 48 74Q32 66 17 69Z','#fff8dc')+line('M48 25V73M25 31L39 34M25 42L39 45M58 34L71 30M58 44L71 40','#ccbda0',3),
'bag':rect(16,31,64,52,13,'url(#orange)','#bc885d',3)+path('M32 34V25Q32 8 48 8Q65 8 65 26V34','none','#ba8053',6)+rect(25,46,46,24,7,'#ffe0a6')+circle(48,58,6,'#cc9b5f'),
'globe':circle(48,48,36,'url(#blue)','#5a9c9f',3)+path('M20 27L32 17L39 26L32 34L37 42L28 49L16 40M60 17L75 31L68 40L77 49L67 61L63 77L50 79L44 67L49 56L40 45L44 33L59 35Z','#8fc585')+path('M48 13Q28 48 48 83M48 13Q68 48 48 83M14 48H82','none','#e5fff0',1.5),
'gear':path('M38 12H58L61 23L71 28L81 25L89 42L79 50L78 62L84 70L70 83L60 77L48 80L42 89L24 81L26 68L19 59L8 56L9 37L21 33L28 24L28 15Z','#92b7aa','#5d9888',3)+circle(48,49,17,'#f5f4d9','#5d9888',3),
'arrow':path('M18 43H62L46 26L54 17L84 48L54 79L46 70L62 53H18Z','#519c84'),
'check':path('M18 48L38 68L79 26','none','#faffec',10),
'chef':path('M24 47C1 35 19 7 36 18C47 -1 65 7 67 20C86 10 98 39 76 47L72 82H26Z','url(#white)','#9cbfb2',3)+line('M27 67H73M36 48L38 64M60 48L58 64','#a9c4b9',3),
'restaurant':rect(17,35,63,48,6,'#fbe9c2','#ba9372',3)+path('M11 37L21 14H77L88 37Z','#ec947f','#bf7865',2.5)+path('M26 14L21 37M41 14L39 37M58 14L59 37M71 14L78 37','none','#fff0ce',9)+rect(26,47,19,20,3,'#81b8af')+rect(54,47,17,36,3,'#81b8af')+circle(59,67,2,'#fff0c7')}
for name,s in icons.items(): save('icons',name,s,False)
# Cast portraits. Individual palette, hairstyle, accessory and expression.
def portrait(skin,hair,shirt,bg,style=0,chef=False):
 s=circle(48,48,46,bg)+path('M12 95Q14 69 39 68H58Q83 70 85 95Z',shirt)+rect(40,59,18,19,7,skin)+ellipse(47,40,28,31,hair)
 s+=ellipse(24,48,5,7,skin)+ellipse(71,48,5,7,skin)+ellipse(48,45,23,28,skin)
 if style in [1,3,5]: s+=path('M23 43Q18 6 50 11Q78 11 74 41L61 26Q44 39 27 34Z',hair)
 elif style==2:s+=path('M23 44Q14 10 48 11Q82 11 75 44L65 27L61 35L53 23L35 31L27 46Z',hair)
 elif style==4:s+=path('M22 35Q17 8 48 10Q79 10 73 32L56 26L44 32L32 25Z',hair)+circle(23,39,8,hair)+circle(73,40,8,hair)
 else:s+=path('M23 40Q18 11 46 11Q77 8 74 37Q62 30 59 23Q46 38 24 32Z',hair)
 s+=ellipse(37,45,3,4,'#394e46')+ellipse(59,45,3,4,'#394e46')+circle(38,44,1,'#fff')+circle(60,44,1,'#fff')+path('M43 58Q49 64 56 57','#fff9eb','#9e6652',1)+ellipse(30,55,5,2.8,'#ec9c86')+ellipse(66,55,5,2.8,'#ec9c86')+line('M47 49L46 53L49 53','#b88064',1.5)
 if style in [1,4]:s+=circle(36,45,9,'none','#3e625b',2.5)+circle(61,45,9,'none','#3e625b',2.5)+line('M45 43H52M24 43H27M70 43H75','#3e625b',2.5)
 if style==3:s+=path('M39 56Q43 51 48 56Q53 51 58 56L56 61L48 58L42 61Z',hair)
 if style==5:s+=path('M20 29Q25 6 48 7Q71 8 77 29Z','#e7a562')+path('M17 29H79Q78 37 48 34Q20 38 17 29Z','#efb577')
 if chef:
  s+=path('M25 26C6 15 27 -1 39 7C48 -5 65 -2 67 11C84 5 91 27 72 30L27 31Z','#fffbed','#bddbd1',1.5)+path('M26 26L72 26L70 35L28 35Z','#fffbed','#bddbd1',1.5)+path('M27 75L40 69L48 79L58 69L72 75L68 96H28Z','#fff9df')+path('M40 72L48 77L57 71L60 77L49 81L37 79Z','#e37c67')+line('M48 81V94','#cfdbcb',1.5)
 else:s+=path('M31 77L40 71L48 79L58 71L67 77L61 95H35Z','#fff3d9')
 return s
save('characters','chef',portrait('#efc498','#765445','#e18b72','#d2eadb',1,True),False)
save('characters','assistant',portrait('#edbd8d','#795346','#db887c','#f3ddbc',1,True),False)
cast=[('#e6ae7b','#654c3d','#87ae8e','#ddecce',3),('#ca956e','#50453e','#d4907c','#f1dbd5',2),('#efd0a3','#a49e89','#b2a0bf','#eadfeb',4),('#975f48','#393e34','#edb95d','#d9e9db',1),('#e5b185','#674f3e','#91b9bd','#d8e9ed',5),('#dba782','#4d4540','#cc8285','#f1d9cb',0),('#b78666','#44473d','#8caf95','#eee5cd',3)]
for i,parts in enumerate(cast):save('characters',f'customer_{i}',portrait(*parts),False)
# Original isometric bistro diorama, 540x320.
s=rect(0,0,540,320,25,'#dce9d9')+ellipse(279,266,233,32,'#b0c9b1')
# Trees beyond the glass.
for x,y,r in [(39,75,35),(472,61,39),(511,90,28),(97,36,25)]:s+=circle(x,y,r,'#bfdbba')
s+=path('M65 214L277 100L492 208L278 310Z','#b79575')+path('M65 207L277 93L492 201L278 303Z','#f0d9ad')
# Checker floor tiles in perspective.
_tiles_start = len(s)
for i in range(7):
 for j in range(6):
  if (i+j)%2==0:
   x=75+i*29+j*31;y=206-i*15+j*14
   s+=path(f'M{x} {y}l29 -15l31 14l-29 15Z','#e2c69a')
floor_tiles = s[_tiles_start:]
s+=path('M65 207V69L278 15V94Z','#f1e7c8','#d3bfa0',2)+path('M278 15L492 115V201L278 94Z','#a7c6b0','#87aa99',2)
# Left brick panelling and sill.
s+=path('M65 159L278 72V94L65 207Z','#9bbba4')+path('M68 155L273 74','none','#fff4d6',6)
# Large front-facing perspective windows on back wall.
for k in range(3):
 x=86+k*60; y=73-k*15
 s+=path(f'M{x} {y}l49 -12v68l-49 19Z','#fff8de','#d4b894',4)
 s+=path(f'M{x+5} {y+5}l39 -10v55l-39 16Z','#c3ded2')
 s+=path(f'M{x+10} {y+3}l14 -3l25 39v15l-11 4Z','#e8f2d9')+line(f'M{x+24} {y-5}v70','#fff7dc',3)
# Right wall door and shelves.
s+=path('M391 88L442 112V210L391 188Z','#fff1ce','#7d9d87',3)+path('M398 102L435 119V187L398 171Z','#82b6ab')+path('M401 106L409 110L431 167V179L423 175Z','#bce0cc')+ellipse(429,165,2,4,'#fff2be')
s+=path('M303 49L366 78V111L303 82Z','#e3bfa0','#789a86',3)+path('M306 65L365 94','none','#fff3d7',3)
for x,y in [(317,67),(331,73),(350,82)]:s+=rect(x,y,6,10,1,'#be8774')
# Awning, scallops and stripes.
s+=path('M64 61L277 7L288 25L67 88L45 85Z','#f2ab8b','#ce8b6e',2)
for i in range(9):
 x=52+i*25;y=70-i*6.2
 s+=path(f'M{x} {y}l14 -3l11 18l-15 4Z','#ffedca')
s+=path('M47 84L287 22V32L47 96Z','#ea9a7b')
# Hanging brass lights.
_lights_start = len(s)
for x,y in [(120,102),(224,76),(336,92)]:s+=line(f'M{x} {y-39}V{y-10}','#8f9d7d',2)+path(f'M{x-13} {y}Q{x-10} {y-17} {x} {y-16}Q{x+11} {y-16} {x+14} {y}Z','#e7bc69','#cda557',1.5)+ellipse(x,y,13,3,'#fff4c5')
lights_section = s[_lights_start:]
# Back counter, coffee machine, stools.
s+=path('M102 174L211 125L255 146L145 196Z','#ca9976')+path('M102 174L145 196V224L102 202Z','#d7aa80')+path('M145 196L255 146V174L145 224Z','#fff1d3')+path('M97 173L210 122L259 145L145 199Z','#6f9f8a','#5b8b77',2)
s+=path('M162 142L187 131L204 139V164L179 176L162 168Z','#d48772','#ae7763',2)+path('M164 145L183 136L201 143L180 152Z','#f5bea1')+path('M180 151L199 142V157L180 166Z','#f8e3bb')+ellipse(185,157,5,2,'#fff6dc')
for x,y in [(162,222),(208,201)]:s+=line(f'M{x-6} {y-2}L{x-10} {y+19}M{x+6} {y-2}L{x+10} {y+19}','#8e765c',3)+ellipse(x,y,14,7,'#d78873','#ad735f',2)
# Dining chairs/tables.
def table(x,y):
 t=line(f'M{x-23} {y+5}V{y+35}M{x+22} {y+5}V{y+33}','#90765e',4)
 t+=path(f'M{x-46} {y-2}l45 -23l48 23l-45 24Z','#caab84')+path(f'M{x-46} {y-7}l45 -23l48 23l-45 24Z','#fff1ce','#d9c29e',2)
 t+=ellipse(x-17,y-5,10,5,'#ffffff','#c9d5bc',1)+ellipse(x+17,y-6,10,5,'#ffffff','#c9d5bc',1)+rect(x-2,y-13,5,12,2,'#a5bda0')+leaf(x+1,y-11,.22,10)+leaf(x+1,y-12,.23,70)
 return t
_dining_start = len(s)
for x,y in [(304,233),(407,197)]:
 for dx,dy in [(-47,6),(31,-28)]:
  s+=path(f'M{x+dx} {y+dy}v-23l16 -8v23Z','#dc957e','#bc806c',2)+path(f'M{x+dx} {y+dy}l16 -8l15 7l-16 9Z','#f0b399','#bc806c',1.5)+line(f'M{x+dx+3} {y+dy+3}v18M{x+dx+26} {y+dy+1}v18','#927a64',3)
 s+=table(x,y)
dining_section = s[_dining_start:]
# Plants soften corners.
_plants_start = len(s)
for x,y in [(89,213),(458,232),(272,146)]:
 s+=path(f'M{x-12} {y-18}h25l-4 26h-17Z','#e3a283','#bc876d',2)+ellipse(x,y-18,13,4,'#ead0a3')
 for rot in [-65,-25,25,70]:s+=leaf(x,y-20,.85,rot)
plants_section = s[_plants_start:]
# Little welcome chalkboard.
_chalkboard_start = len(s)
s+=path('M228 247L248 236L258 267L236 279Z','#749883','#5a7d68',2)+path('M231 248L246 241L253 263L237 272Z','#456f5d')+line('M236 250L245 246M237 255L248 250M239 260L249 255','#f5e6bd',1.5)
chalkboard_section = s[_chalkboard_start:]
# Handwritten looking entrance sign (shapes, no font dependencies).
s+=path('M280 109L312 124V145L280 130Z','#ffedc7','#ac9171',2)+path('M288 114V128M284 120L293 124M301 120L298 132L306 136','#aa8060','#aa8060',2)
(ROOT/'restaurant.svg').write_text('<svg xmlns="http://www.w3.org/2000/svg" width="540" height="320" viewBox="0 0 540 320">'+DEFS+s+'</svg>')
# Independent renovation combinations preserve each selected part's style.
# These are complete images so furniture always correctly occludes flooring.
from itertools import product
room_dir = ROOT / 'rooms'
room_dir.mkdir(exist_ok=True)
styles = ('none', 'sage', 'sunshine', 'rose')
floor_colors = {
 'sage': ('#f3e8cb', '#c8d4b5'),
 'sunshine': ('#fff0c6', '#e9c87f'),
 'rose': ('#f8e8d9', '#dec3b4'),
}
table_colors = {
 'sage': {'#dc957e':'#9fb78d', '#f0b399':'#c5d7a8', '#fff1ce':'#edf2d5', '#6f9f8a':'#6f9f8a', '#d78873':'#a7bc93'},
 'sunshine': {'#dc957e':'#e4b761', '#f0b399':'#f5d395', '#fff1ce':'#fff2bf', '#6f9f8a':'#c99b51', '#d78873':'#dfb45f'},
 'rose': {'#dc957e':'#d7959d', '#f0b399':'#f0bec0', '#fff1ce':'#ffe7dd', '#6f9f8a':'#b87f86', '#d78873':'#d89598'},
}
decor_colors = {
 'sage': {'#a7c6b0':'#a7c6b0', '#9bbba4':'#9bbba4', '#e7bc69':'#a5bd81', '#e3a283':'#d6b991', '#749883':'#749883'},
 'sunshine': {'#a7c6b0':'#e6c773', '#9bbba4':'#d9b96b', '#e7bc69':'#e7bc69', '#e3a283':'#e7b565', '#749883':'#b79961'},
 'rose': {'#a7c6b0':'#d8aaa9', '#9bbba4':'#c69599', '#e7bc69':'#d99a99', '#e3a283':'#d89f9a', '#749883':'#b48491'},
}
def recolor(content, colors):
 for old, new in colors.items(): content = content.replace(old, new)
 return content
for floor_style, table_style, decor_style in product(styles, repeat=3):
 scene = s.replace(floor_tiles, '@@FLOOR@@').replace(dining_section, '@@TABLES@@')
 scene = scene.replace(lights_section, '@@LIGHTS@@').replace(plants_section, '@@PLANTS@@').replace(chalkboard_section, '@@SIGN@@')
 if floor_style == 'none':
  floor_layer = path('M269 207l17 5l8 -9l15 5M350 216l5 10l15 2M246 254l9 -5l12 5','none','#bba98a',2)
  floor_layer += ellipse(297,249,40,6,'#d6bf96') + ellipse(373,208,29,5,'#d6bf96')
 else:
  floor_base, tile_color = floor_colors[floor_style]
  scene = scene.replace('#f0d9ad', floor_base)
  floor_layer = floor_tiles.replace('#e2c69a', tile_color)
 if table_style == 'none':
  dining_layer = path('M311 222l22 -12l21 10v21l-22 13l-21 -12Z','#bba682','#a08d70',2) + path('M311 222l21 11l22 -13M332 233v21','none','#9f8d72',2)
 else:
  dining_layer = recolor(dining_section, table_colors[table_style])
  # Matching countertop and bar stools belong to the furniture selection.
  scene = scene.replace('#6f9f8a', table_colors[table_style]['#6f9f8a']).replace('#d78873', table_colors[table_style]['#d78873'])
 if decor_style == 'none':
  lights_layer = plants_layer = sign_layer = ''
  # Muted unfinished plaster keeps the reveal visible when decor is installed.
  scene = scene.replace('#a7c6b0', '#c7c5ac').replace('#9bbba4', '#b7bba1')
 else:
  scene = recolor(scene, decor_colors[decor_style])
  lights_layer = recolor(lights_section, decor_colors[decor_style])
  plants_layer = recolor(plants_section, decor_colors[decor_style])
  sign_layer = recolor(chalkboard_section, decor_colors[decor_style])
 for placeholder, layer in [('@@FLOOR@@',floor_layer),('@@TABLES@@',dining_layer),('@@LIGHTS@@',lights_layer),('@@PLANTS@@',plants_layer),('@@SIGN@@',sign_layer)]:
  scene = scene.replace(placeholder,layer)
 name = f'{floor_style}_{table_style}_{decor_style}.svg'
 (room_dir/name).write_text('<svg xmlns="http://www.w3.org/2000/svg" width="540" height="320" viewBox="0 0 540 320">'+DEFS+scene+'</svg>')
# Keep hand-maintained license notices intact when regenerating art.
chef = (ROOT/'icons/chef.svg').read_text()
body = chef[chef.index('>')+1:chef.rindex('</svg>')]
(ROOT/'app_icon.svg').write_text('<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512"><rect width="512" height="512" rx="112" fill="#397b62"/><circle cx="404" cy="96" r="29" fill="#f0b94e"/><circle cx="82" cy="424" r="47" fill="#e98269"/><g transform="translate(80 69) scale(3.65)">'+body+'</g></svg>')
print('Generated',len(list(ROOT.rglob('*.svg'))),'original SVG assets.')
