"""Original foods and illustrated travel postcards for the v0.2 expansion."""
from generate_assets import ROOT, save, path, ellipse, circle, rect, line, group, leaf, shine, spark, plate, DEFS

# New merge ingredients. Their silhouettes stay distinct at phone tile size.
save('items','mango',path('M29 23C65 0 88 29 77 59C68 88 35 92 21 71C6 51 14 32 29 23Z','url(#orange)','#c68737')+path('M29 23Q49 13 66 27Q42 19 28 54Q17 69 21 48Z','#ffd66e')+leaf(47,20,.55,55)+shine(27,41,-20))
save('items','coconut',circle(48,51,34,'url(#brown)','#86573b')+ellipse(51,45,29,26,'#fff7dd','#b88b63',4)+ellipse(51,45,20,17,'#eff0d4')+line('M19 65L27 68M32 81L35 75M68 76L70 69','#6d4c37',2)+line('M51 44L71 13','#efa47e',5))
save('items','pepper',path('M43 31C15 14 7 61 29 81Q45 88 47 79Q65 93 81 70C93 42 70 15 53 32Z','url(#red)','#b94d3c')+path('M41 32Q53 28 58 34L54 25L60 12L52 10L45 25Z','#4d9b58')+line('M47 36Q36 65 45 77','#d23e43',3)+shine(26,43,-12))
save('items','mushroom',path('M39 47L34 78Q48 91 63 77L56 47Z','url(#cream)','#ba9e79')+path('M12 49C11 1 86 1 85 49Q49 68 12 49Z','url(#brown)','#8f5d3e')+ellipse(48,49,35,9,'#eed4a3','#926442',2)+line('M26 27Q40 13 57 20','#efc695',4)+circle(68,32,4,'#e5b378'))
save('items','butter',plate()+path('M18 44L62 30L78 42V69L34 82L18 68Z','url(#yellow)','#cfa442')+path('M18 44L34 55L78 42M34 55V82','none','#d6ae53',2)+line('M24 44L59 35','#fff4b0',3))
save('items','cream',path('M26 22L61 16L76 32V83H27Z','url(#white)','#92b7ad')+path('M26 22L41 35H76L61 16Z','#b8dccd')+rect(27,44,49,29,1,'#e99b95')+path('M45 64C33 52 63 48 61 64Z','#fff9e6')+circle(58,23,5,'#fff7e7','#adc8bc',2))
save('items','shrimp',path('M72 22C27 -1 3 43 24 67C42 90 79 72 62 57C49 46 36 65 33 48C29 33 49 20 59 34L72 44L86 30Z','url(#orange)','#cd7659')+line('M22 31L35 37M18 46L33 48M24 62L38 57M40 72L43 60','#e6a284',4)+circle(66,28,2.5,'#493d38'))
save('items','fish',path('M13 51C24 20 57 18 72 39L89 25L84 51L90 75L71 62C51 84 28 80 13 51Z','url(#blue)','#63949f')+path('M37 29L46 13L60 29M37 73L51 86L61 70','#6ea6b3','#63949f',2)+circle(29,46,4,'#345b60')+circle(30,45,1.5,'#fff')+line('M39 36Q48 52 39 65M52 39Q60 51 54 63','#a3dce3',3))
save('items','salmon',path('M20 26C32 12 72 18 80 40L76 77Q46 91 18 66Z','url(#orange)','#be735c')+path('M20 26Q44 49 80 40L76 77Q46 91 18 66Z','#f79d86','#bf7968',2)+line('M28 31L26 65Q42 75 68 69M42 37L38 67M57 40L52 70','#ffdfc5',3)+line('M18 68Q43 90 76 79','#78a89a',5))
save('items','crab',ellipse(48,55,24,21,'url(#red)','#bf4e47')+path('M27 44L15 28L8 12L23 21L29 12L31 31ZM69 44L82 29L91 12L75 21L68 11L66 30Z','url(#orange)','#c16a43')+line('M26 53L11 49L5 62M27 63L14 67L9 81M69 55L87 51L92 65M68 65L82 70L86 81','#cc604c',4)+circle(40,37,5,'#fff5d2')+circle(56,37,5,'#fff5d2')+circle(41,36,2,'#41433e')+circle(55,36,2,'#41433e'))
save('items','lobster',path('M39 31L59 31L63 67L55 82H39L32 67Z','url(#red)','#b84942')+line('M37 48H60M35 59H62M38 71H57','#f9b282',3)+path('M34 43L14 36L8 15L22 20L31 10L33 29ZM62 43L83 36L89 15L77 20L65 10L62 29Z','url(#orange)','#c15d45')+line('M40 34L30 17M55 34L66 17M35 54L21 63M62 54L74 63','#c95e43',3)+circle(40,29,3,'#334e42')+circle(56,29,3,'#334e42'))
save('items','roe',ellipse(48,75,33,9,'#617978')+path('M16 42H81V73Q49 89 16 73Z','url(#teal)','#528b83')+ellipse(48,42,32,11,'#345b52')+''.join(circle(x,y,6,'url(#orange)','#c7823f',1) for x,y in [(24,41),(34,35),(45,41),(57,35),(68,41),(36,46),(57,46)])+rect(35,60,25,13,4,'#fff2cc'))
save('items','cocoa',path('M27 13H69L65 29L76 80H20L32 29Z','url(#brown)','#8e694e')+rect(28,42,40,27,7,'#ffe2ac')+ellipse(49,55,11,8,'#986449')+line('M42 52L56 59','#e4b68a',2)+line('M29 17H67','#eccb91',4))
save('items','cookie',circle(48,49,34,'url(#cream)','#b68851',3)+''.join(path(f'M{x} {y}l7 -3l4 7l-6 4Z','#845a43') for x,y in [(25,35),(48,24),(62,42),(32,57),(54,63)])+shine(27,43,-30))
save('items','chocolate',path('M20 22L65 13L81 73L33 86Z','url(#brown)','#765141')+path('M23 59L75 47L81 73L33 86Z','#b4dacc','#6ba594',2)+line('M33 20L42 57M48 17L57 54M24 35L69 26M28 48L73 40','#643f33',3)+spark(63,65))
save('items','croissant',path('M13 65C2 32 30 17 48 20C76 15 94 46 82 72L65 65L31 65Z','url(#orange)','#ba803e')+path('M31 30L30 69L49 75L65 64L64 28L49 20Z','url(#cream)','#d29746',2)+line('M35 32L34 63M58 32L61 60M18 40L21 63M74 42L74 65','#e7af55',3)+shine(42,36,-30))
save('items','cake',plate()+path('M18 37L68 20L80 69L31 85L18 72Z','url(#cream)','#bb9781')+path('M19 47L72 32L75 41L23 59M25 68L77 51L79 61L28 79','#ec8d97')+path('M18 37L31 49L77 34L68 20Z','#fff3e0','#c9b598',2)+circle(47,29,11,'url(#red)','#c75d60',1.5)+leaf(51,24,.4,80))
save('items','truffle',plate()+''.join(circle(x,y,17,c,'#7d5144',2)+line(f'M{x-10} {y-5}l18 8M{x-7} {y-10}l17 8','#dfa782',2) for x,y,c in [(29,57,'url(#brown)'),(64,59,'#77483e'),(48,33,'#a96d53')]))
# Suppliers use the existing illustrated crates as a cohesive visual anchor.
for new, base, contents in [('produce_seafood','produce_veg','fish'),('produce_bakery','produce_fruit','croissant')]:
 icon=(ROOT/'items'/f'{contents}.svg').read_text().split('</defs>',1)[1].rsplit('</svg>',1)[0]
 save('items',new,rect(12,37,73,48,9,'#d6a570','#a57d50')+rect(15,43,67,10,3,'#edce9d')+group(icon,'translate(12 -6) scale(.74)')+rect(30,65,37,17,5,'#fff1ce')+spark(49,73))
# Distinct dishes: shared porcelain, hand-built toppings and silhouettes.
def bowl(fill='#ffbf71'):
 return plate()+path('M12 46H84Q79 84 48 84Q17 84 12 46Z','url(#white)','#9cbeb4')+ellipse(48,46,36,12,fill,'#86aa9b',2)
def garnish(): return leaf(60,46,.38,54)+circle(33,48,6,'url(#red)')
def drink(color):return path('M26 25H70L64 82H34Z',color,'#83b6ac')+ellipse(48,25,22,6,'#fff0cb')+line('M56 49L66 10L78 10','#d98682',4)+shine(35,47,0)
def toast_food(topping):return plate()+path('M16 51L60 30L81 58L35 80Z','url(#orange)','#bf8c4f')+path('M24 52L58 38L73 58L37 73Z',topping)
art={}
art['berry_tart']=plate()+ellipse(49,60,34,16,'url(#orange)','#c89051')+ellipse(49,55,31,13,'#fff0c7')+''.join(circle(x,y,9,'url(#red)','#d16768',1.3)+leaf(x,y-5,.25,50) for x,y in [(29,49),(48,42),(64,49),(46,61)])
art['mango_lassi']=drink('url(#yellow)')+circle(28,27,10,'url(#orange)')+leaf(29,23,.35,50)
art['coconut_cooler']=drink('#def0cf')+ellipse(32,31,17,12,'#92613e')+ellipse(32,29,13,9,'#fff6da')
art['bruschetta']=toast_food('#77af5d')+''.join(rect(x,y,9,8,2,'#ef7561') for x,y in [(29,50),(43,44),(56,52),(42,60)])+leaf(61,41,.4,70)
art['tacos']=plate()+path('M11 65C16 16 67 15 84 62L75 72L24 75Z','url(#yellow)','#b18e3c')+path('M19 61Q45 33 77 61L72 73L25 75Z','#589756')+''.join(circle(x,y,6,'#e96955') for x,y in [(29,57),(47,52),(65,59)])+line('M27 64L64 70M40 58L61 65','#fff0ad',3)
art['risotto']=bowl('#efe0a6')+''.join(ellipse(x,y,8,4,'#b48259')+rect(x-2,y,4,7,1,'#e6c69c') for x,y in [(30,43),(52,50),(65,39)])+garnish()
art['pizza']=plate()+ellipse(48,49,35,27,'url(#orange)','#c98b40')+ellipse(48,49,29,22,'#ef7961')+''.join(circle(x,y,7,'#fff1bb') for x,y in [(32,39),(59,35),(66,54),(44,62),(38,49)])+leaf(46,42,.33,40)+leaf(68,59,.3,80)
art['pancakes']=plate()+''.join(ellipse(48,y,33,12,'#d28c46','#ae713e',1.5)+ellipse(48,y-4,33,10,'#f1c278') for y in [68,58,48])+path('M24 41Q48 27 74 42L67 58L57 55L48 63L41 51L33 56Z','#bd7146')+path('M39 34L53 30L62 39L45 43Z','#ffe68a')
art['creme_brulee']=bowl('#bb7844')+''.join(circle(x,y,2,'#efc083') for x,y in [(28,43),(36,49),(49,39),(62,45),(57,52)])+leaf(63,30,.5,60)
art['shrimp_skewer']=plate()+line('M19 80L76 16','#9f8056',4)+''.join(group(path('M-12 -3C-12 -17 16 -15 14 0C13 12 -4 12 -5 3L2 -2L9 4','url(#orange)','#d27e4f',3),f'translate({x} {y}) rotate(35)') for x,y in [(31,63),(46,45),(61,27)])+leaf(73,72,.5,55)
art['fish_chips']=plate()+path('M13 56Q17 25 43 25L64 56L34 75Z','url(#orange)','#be883c')+''.join(rect(x,y,7,31,2,'#ffdc75','#d6ac4e',1) for x,y in [(62,36),(72,42),(53,46)])+line('M26 40L39 59M33 34L47 52','#f5c56c',3)
art['salmon_bowl']=bowl('#faf1c7')+''.join(path(f'M{x} {y}l18 -5l11 12l-20 6Z','#f6927c','#d97860',1) for x,y in [(23,36),(33,49),(48,36)])+leaf(75,48,.5,50)
art['crab_cakes']=plate()+''.join(ellipse(x,y,19,11,'url(#orange)','#b78044',2)+line(f'M{x-9} {y-2}l8 3l8 -4','#e9ba63',3) for x,y in [(29,60),(65,62),(48,37)])+garnish()
art['lobster_bisque']=bowl('#f29573')+path('M27 42Q28 23 48 31Q62 24 67 45L57 48L47 39L36 48Z','#d85b4d','#b95245',2)+garnish()
art['caviar_toast']=toast_food('#fff0c9')+''.join(circle(x,y,4,'#ef9b43','#d38839',1) for x,y in [(34,50),(45,47),(54,44),(59,54),(47,59),(35,61)])+leaf(71,56,.4,70)
art['hot_cocoa']=path('M22 30H70V71Q47 88 22 71Z','url(#pink)','#ae7777')+path('M70 39Q94 39 82 63L71 64','none','#b47876',7)+ellipse(46,30,24,8,'#7e5441')+''.join(rect(x,y,10,9,3,'#fff5da') for x,y in [(29,26),(44,30),(52,23)])+line('M34 17Q30 9 36 3M53 15Q48 9 54 1','#c8b9a7',2)
art['choc_cookie']=plate()+''.join(circle(x,y,22,'url(#cream)','#bd965f',2)+''.join(circle(x+dx,y+dy,3,'#79513e') for dx,dy in [(-8,-7),(8,-6),(3,9)]) for x,y in [(32,56),(63,53)])
art['chocolate_mousse']=path('M21 45H77L69 77Q47 88 29 77Z','url(#white)','#9fbbb1')+path('M21 44Q27 29 37 34Q29 22 51 21Q43 8 61 13Q73 19 63 28Q83 29 77 44Z','url(#brown)','#8d5945',2)+line('M36 34Q51 42 67 32','#e1ac82',3)+circle(58,12,7,'url(#red)')
art['croissant_sandwich']=plate()+path('M11 54Q17 20 47 23Q78 20 85 54L73 72H25Z','url(#orange)','#bc884a')+path('M20 51L70 44L78 58L67 70L26 70Z','#77af5d')+path('M24 50L66 47L77 57L61 68L30 64Z','#ffe5a4')+line('M34 30L29 49M59 28L65 47','#f3c27c',3)
art['strawberry_cake']=plate()+rect(18,35,62,43,9,'#f3a6af','#c87f86')+rect(18,53,62,8,2,'#fff0d4')+ellipse(49,36,31,10,'#ffedda')+''.join(circle(x,y,9,'url(#red)')+leaf(x,y-4,.25,65) for x,y in [(31,31),(49,21),(67,31)])
art['truffle_box']=path('M13 36L61 20L85 35V73L37 86L13 69Z','#de9eaa','#ab7884')+path('M13 36L38 50L85 35L60 20Z','#f9d7d0')+''.join(circle(x,y,9,c,'#825742',1) for x,y,c in [(32,37,'#9e694b'),(49,31,'#774d3f'),(62,39,'#c99162'),(45,46,'#875641')])+line('M16 61L82 43','#fff2cd',4)
art['bibimbap']=bowl('#fff0c2')+path('M17 45Q27 24 40 34L39 52Z','#e47f5b')+path('M58 33Q75 28 81 45L60 51Z','#69a757')+ellipse(49,45,16,10,'#fff8e7')+circle(49,44,8,'url(#yellow)')
art['dumplings']=plate()+''.join(path(f'M{x-17} {y+6}Q{x} {y-28} {x+17} {y+6}Q{x} {y+16} {x-17} {y+6}Z','url(#cream)','#bfa47e',2)+line(f'M{x-8} {y-4}L{x-5} {y+6}M{x} {y-8}V{y+5}M{x+8} {y-4}L{x+5} {y+6}','#c5ad87',1.5) for x,y in [(28,59),(66,59),(48,35)])
for id,s in art.items(): save('items',id,s)
save('icons','medal',path('M21 12L45 15L62 46L39 48Z','#ec947d')+path('M75 12L51 15L34 46L57 48Z','#86bca2')+circle(48,59,28,'url(#yellow)','#c6973c',3)+group(spark(0,0),'translate(48 58) scale(2)'),False)
# Panoramic travel postcards: quiet geometry and warm, original landmark motifs.
city_dir=ROOT/'cities'; city_dir.mkdir(exist_ok=True)
palettes=[('#d6e8d9','#91b6a7','#ecb477'),('#f7e2b5','#cc8d52','#e69f60'),('#f3dfe5','#aaa9c8','#ce8e9f'),('#dde7ed','#8bacae','#e4b186'),('#f1ddc7','#c49c7f','#d68f65'),('#f0dba7','#c59380','#dd9479'),('#d9eaf0','#9eb7b8','#d8a36d'),('#dfe2f0','#a59cc3','#ddad99')]
ids=['new_york','bangkok','tokyo','paris','rome','mexico_city','istanbul','seoul']
for i,id in enumerate(ids):
 sky,building,accent=palettes[i]
 s=rect(0,0,540,220,22,sky)+circle(443,45,25,'#fff2be')+ellipse(85,32,56,13,'#edf5e9')+ellipse(351,62,50,12,'#edf5e9')+path('M0 169Q170 121 313 172Q436 129 540 170V220H0Z','#a8c8a0')
 if id=='new_york':
  for x,y,w in [(32,73,63),(108,41,57),(180,89,50),(263,55,62),(343,91,68)]:
   s+=rect(x,y,w,115,3,building)+''.join(rect(x+9+c*17,y+10+r*20,8,11,1,'#fff2c5') for c in range(2) for r in range(4))
  s+=line('M137 41V17',building,6)+rect(323,164,89,27,8,'#edb85d')+rect(343,147,40,23,6,'#edb85d')+circle(343,190,10,'#5b7467')+circle(395,190,10,'#5b7467')
 elif id=='bangkok':
  for x,h in [(60,90),(210,120),(376,82)]:
   s+=rect(x,140-h/2,105,h,3,'#f2ca84')+path(f'M{x-14} {140-h/2}L{x+52} {70-h/2}L{x+119} {140-h/2}Z',accent)+path(f'M{x-2} {121-h/2}L{x+52} {45-h/2}L{x+107} {121-h/2}Z','#ddad59')+line(f'M{x+52} {45-h/2}V{25-h/2}','#ca9650',4)+rect(x+41,146-h/2,25,45,10,building)
 elif id=='tokyo':
  s+=path('M125 174L268 25L416 174Z','#b6c6cd')+path('M222 73L268 25L315 74L288 66L267 80L247 64Z','#fff8e8')
  s+=rect(75,64,16,132,3,'#c87669')+rect(205,64,16,132,3,'#c87669')+rect(57,65,183,14,5,'#bd7466')+path('M46 43Q145 61 250 42L241 57Q146 73 56 57Z','#655a5f')+rect(73,98,153,11,2,'#c87669')
  for x,y in [(438,77),(481,119),(403,120)]: s+=line(f'M{x} 190V{y}',building,8)+circle(x,y,34,'#e3a6b3')+circle(x-18,y-12,24,'#f0bdc5')
 elif id=='paris':
  s+=path('M247 25L261 25L279 107L320 190H289L253 130L220 190H191L232 107Z',building)+line('M226 108H282M213 145H297M233 76H273','#5e898e',5)+path('M233 190Q252 143 276 190Z',sky)
  for x in [22,365,441]: s+=rect(x,107,62,85,3,'#eed1b0')+path(f'M{x-5} 107L{x+30} 78L{x+67} 107Z',accent)+rect(x+20,128,21,32,10,'#fff3d2')
 elif id=='rome':
  s+=path('M78 102Q261 44 449 105V192H78Z','#d0aa84')+path('M78 102Q262 69 449 105V121Q260 88 78 119Z','#e7caaa')
  for x in range(99,422,45): s+=rect(x,118,28,35,14,'#9c8675')+rect(x,162,28,31,13,'#9c8675')
  for x in [41,483]:s+=rect(x-3,87,6,117,2,'#897f62')+ellipse(x,93,19,56,'#6e9c77')
 elif id=='mexico_city':
  for x,y,c in [(28,80,'#e8a18e'),(126,109,'#e6bd73'),(233,60,'#9ab8a4'),(349,95,'#d59bb1')]:
   s+=rect(x,y,88,125,4,c)+rect(x+29,y+39,28,60,14,'#fff0d2')+rect(x+12,y+10,18,20,3,'#6e9c8c')
  s+=line('M0 40Q270 124 540 39','#9c8072',2)
  for x in range(20,521,50): s+=path(f'M{x} {42+int(33*(1-abs(x-270)/270))}l35 0l-3 27l-13 -5l-16 5Z',[accent,'#a4c1ab','#cc9aae'][x%3])
 elif id=='istanbul':
  s+=rect(135,118,250,79,4,'#d9c7aa')+path('M189 121Q197 39 261 51Q320 47 330 121Z',building)+circle(261,46,8,'#e6bb65')+line('M261 40V22','#bc9b66',3)
  for x in [100,404]:s+=rect(x,57,15,141,4,'#d8c3a1')+path(f'M{x-3} 58L{x+8} 23L{x+18} 58Z',building)+rect(x-7,100,29,8,2,accent)
  for x in [163,205,247,289,331]:s+=rect(x,142,21,39,10,'#98a7a0')
 else:
  s+=path('M81 193L251 76L419 193Z','#b6c0b3')+rect(283,36,9,133,3,'#e9ddcc')+ellipse(288,60,33,10,'#b19ca7')+rect(272,42,32,17,5,'#c3a7b2')+line('M288 35V7','#839395',4)
  for x in [26,144,370]:s+=rect(x,136,109,62,3,'#d4ae94')+path(f'M{x-14} 137Q{x+55} 94 {x+123} 136L{x+105} 142H{x}Z','#6b8790')+rect(x+37,148,37,49,2,'#fae9be')
 s+=path('M0 207Q165 185 302 205T540 200V220H0Z','#81ad9d')
 (city_dir/f'{id}.svg').write_text('<svg xmlns="http://www.w3.org/2000/svg" width="540" height="220" viewBox="0 0 540 220">'+DEFS+s+'</svg>')
print('Expansion art:',len(art),'new dishes, 18 ingredients, 2 suppliers, 8 postcards.')
