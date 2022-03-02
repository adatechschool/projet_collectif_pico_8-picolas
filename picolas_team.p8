pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
--1er projet groupe ada tech school (https://adatechschool.fr/)
--par picolas team
--sources : https://fairedesjeux.fr/pico-8/

-- menu titre

function _init()
 menu_init() 
end

function menu_init()
	_update=menu_update   -- affectation de la fonction menu_update dans _update
	_draw=menu_draw  	  -- idem
end

function menu_update()
 if (btnp(❎)) then _initgame() -- x pour commencer le jeu
 end
end

function menu_draw()
		cls(15)
		--premiere ligne bleue
		rectfill(0,30,128,30,8)
		rectfill(0,31,128,40,1)
		rectfill(0,40,128,40,8)

		--seconde ligne jaune
		rectfill(0,47,128,47,8)
		rectfill(0,48,128,57,10)
		rectfill(0,57,128,57,8)
		
		--texts
		print("ada'cademy adventure ♥ ada'cademy adventure ♥ ada'cademy adventure",-70,33,7)
  print("♥ be the future ♥",25,50,8)
  print("press 'x' to start game",16,80,5)
  print("anne ♥ cyril",40,100,14)
  print("myriam ♥ helene",32,108,14)

end
-->8
--sources : https://fairedesjeux.fr/pico-8/
-- menu initgame
function _initgame()
	_update=_updategame
	_draw=_drawgame
	create_player()
	reading=true
	sfx(4)
	particles={}
	tb_init("picolas team",{"bienvenue picolas ! il s'agit\nde ton premier jour a la\nnouvelle ecole ada! ta mission","sera de decouvrir le quartier\navant de te rendre a l ecole.\nn'hesites pas a visiter","tous les restaurants.\napprendre c'est bien!","mais il faut savoir recharger\nses batteries aussi!"})
	
end

cnt=0  -- pour les feux d'artifice

-- menu _updategame
function _updategame()
 update_camera()
 if reading then 
		tb_update()
	else 
		player_movement()	
	end
	
	cnt += 1   -- pour les feux d'artifice

 if cnt% flr(rnd(200))==0 then
  boom(rnd(128),rnd(128))
 end
 
 if btnp(4) then
  --spawn fireworks at
  --a random position
  boom(rnd(128),rnd(128))
 end
 -- update particles
 updateparticles()
 
end

-- menu _drawgame
function _drawgame()
 cls()
 draw_map()
 draw_player()
 draw_ui()
 tb_draw()
 
 --draw particles
 if (newx==49 and newy==42) or (newx==52 and newy==42) then 
		drawparticles()
		
		if (btnp(🅾️)) then  -- appuie sur c pour reinitialiser le jeu
  	run()
  end
 end
end




-->8
--sources : https://fairedesjeux.fr/pico-8/
-- map 

function draw_map()
	map(0,0,0,0,128,64)
end 
 
-- pour les interactions avec les objets/personnages
function check_flag(flag,x,y)
	local sprite=mget(x,y)
	return fget(sprite,flag)
end

-- camera en plan qui suit le personnage
function update_camera()   
	camx=mid(0,(p.x-7.5)*8+p.ox,(64-15)*8)
	camy=mid(0,(p.y-7.5)*8+p.oy,(47-15)*8)
	camera(camx,camy)
end

-- pour les mouvements des portes
function next_tile(x,y)
	sprite=mget(x,y)
	mset(x,y,sprite+1)
end

-- pour le ramassage des objets
function pick_up_key(x,y)
	next_tile(x,y)
	p.keys+=1
	sfx(0)
end

-- pour ouverture des portes
function open_door(x,y)
	next_tile(x,y)
	sfx(1)
end	
-->8
--sources : https://fairedesjeux.fr/pico-8/
-- initialisation du joueur

function create_player()
	p={
		x=8,y=8,
		ox=0,oy=0,
		start_ox=0,start_oy=0,
		anim_t=0,
		sprite=64,
		keys=0,  -- nb de coeurs
		bonus=0, -- parler a tous les patrons permet d'ouvrir la porte d'Ada
		ada=0}	 -- parler a Chloe
end

-- gere le mouvement du joueur avec fluidite via les offsets
function player_movement()
 newx = p.x
 newy = p.y
 if p.anim_t == 0 then
    newox = 0
    newoy = 0
   if btn(⬅️) then
     newx -= 1
     newox = 8
     p.flip=true
   elseif btn(➡️) then
     newx += 1
     newox = -8
     p.flip=false
   elseif btn(⬆️) then
     newy -= 1
     newoy = 8
   elseif btn(⬇️) then
     newy += 1
     newoy = -8
   end
  end
  
	interact(newx,newy)  -- gere les interactions avec les objets/personnages
	
	if (p.x!=newx or p.y!=newy)	and
	not check_flag(0,newx,newy) then
		-- on avance
		p.x=mid(0,newx,127)
		p.y=mid(0,newy,47)
		p.start_ox=newox
		p.start_oy=newoy
		p.anim_t=1
	end
	--animation
	p.anim_t=max(p.anim_t-0.125,0)
	p.ox=p.start_ox*p.anim_t
	p.oy=p.start_oy*p.anim_t
	--marche
	if p.anim_t>=0.5 then
		p.sprite=65
	else
		p.sprite=64
	end
end

-- gere les interactions avec les objets/personnages
function interact(x,y)
	
	if check_flag(2,x,y) then  -- ramassage des coeurs
		pick_up_key(x,y)
	
	elseif check_flag(1,x,y)   -- ouvre les magasins
	and p.keys>0 then
		open_door(x,y)
		p.keys-=1 			   -- un coeur en moins a chaque ouverture
	
	elseif check_flag(3,x,y)  -- ouvre la porte d'ada apres avoir parle au 6 restaurants
		and p.bonus>=6 then
			open_door(x,y)
	
	elseif check_flag(4,x,y)  -- ouvre la barriere apres avoir parle a chloe
		and p.ada>=1 then  
			open_door(x,y)
	end
	
	-- positions des personnages pour le dialogue avec la fonction tb_init :
	if x==8 and y==4 then 
		tb_init("metany",{"hello picolas! \npret pour l'adaventure\ndiversidays & inclusivedays?"})
	elseif x==0 and y==6 then 
		tb_init("betty",{"dans ce quartier, il faut\navoir bon coeur pour pouvoir\nentrer dans les restaurants!"})
	elseif x==11 and y==5 then 
		tb_init("kouikoui",{"kouikoui est en solidarite\navec tous les peuples qui\nsouffrent de la guerre!"})
	elseif x==23 and y==9 then 
		tb_init("sophy",{"ce qui fait la vraie valeur\nd'un etre humain,","c'est de s'etre delivre de son petit\nmoi. (albert einstein)"})
	elseif x==24 and y==7 then 
		tb_init("milounou",{"ce qui fait la vraie valeur\nd'un milounou,","c'est d'etre a cote de sophy.\nwaoh! waoh!"})
	elseif x==1 and y==11 then 
		tb_init("kingerly",{"bienvenue chez burger king!\ntout est dans le nom! faut-il\nencore presenter cette chaine\n","de restauration rapide\nmondialement connue ?\n93 bd de strasbourg"})
		p.bonus+=1
	elseif x==3 and y==10 then 
		tb_init("bobby",{"peu importe ce que les gens\nvous disent, les mots et les\nidees peuvent changer le monde","(robin williams)"})
	elseif x==4 and y==10 then 
		tb_init("biaity",{"a competences egales, un\ncandidat issu de la diversite\nva devoir envoyer quatre fois","plus de cv pour decrocher un\nentretien d'embauche. le poids\ndes stereotypes continue","a produire de la discrimi-\nnation."})
	elseif x==17 and y==17 then 
		tb_init("chicky",{"bienvenue chez chicken street:\nnotre specialite, c'est le\npoulet: du sandwich naan\n","au fried chicken en passant\npar les burgers.\n121 rue du fbg saint-martin"})
		p.bonus+=1
	elseif x==26 and y==5 then 
		tb_init("kouikoui",{"kouikoui est triste, kouikoui\na peur de la guerre...et toi?"})
	elseif x==28 and y==16 then 
		tb_init("fleur",{"welcome to maison nomade: ici\non sert des plats vegan, sains\net bio dans une ambiance","detendue.\n140 rue du fbg saint-martin"})
		p.bonus+=1
	elseif x==28 and y==23 then 
		tb_init("affou",{"installez-vous chez affou :\nvenez deguster nos specialites\nivoiriennes et senegalaises !","132 rue du fbg saint-martin"})
		p.bonus+=1
	elseif x==26 and y==29 then 
		tb_init("drinky",{"attelez-vous chez marrow :\nnotre bistrot-bar branche et\ndouillet vous accueille","a partir de 18h !\n128 rue du fbg saint-martin"})
		p.bonus+=1
		sfx(3)
	elseif x==5 and y==30 then 
		tb_init("koffy",{"priver les gens de leurs\ndroits fondamentaux revient a\ncontester leur humanite meme.","(nelson mandela)"})
	elseif x==22 and y==34 then 
		tb_init("kouikoui",{"l'homme se doit d'etre le\ngardien de la nature, non son\nproprietaire"})
	elseif x==2 and y==41 then 
		tb_init("frankly",{"ici c'est franprix, votre\nsuperette super chouette pour\nvos anniv du vendredi","55 bd de magenta"})
		p.bonus+=1
	elseif x==10 and y==40 then 
		tb_init("jacky",{"le raciste est celui qui pense\nque tout ce qui est trop\ndifferent de lui le menace","dans sa tranquillite.\n(tahar ben jelloun)"})
	elseif x==4 and y==40 then 
		tb_init("biaity",{"a competences egales, un\ncandidat issu de la diversite\nva devoir envoyer quatre fois","plus de cv pour decrocher un\nentretien d'embauche. le poids\ndes stereotypes continue a\nproduire de la discrimination."})
	elseif x==27 and y==40 then 
		tb_init("marco",{"pourquoi le logo de facebook\nest-il bleu? parce que mark\nzuckerberg est daltonien.","en effet, le fondateur de fb\na des deficiences sur la\nperception des couleurs et","le bleu et le blanc sont les\ncouleurs qu'il voit le mieux."})
	elseif x==25 and y==39 then 
		tb_init("chloe",{"felicitation! tu es enfin\narrive.e a ada tech school,\nun nouveau genre d'ecole","informatique ou il y a\n+ de filles, + de sens,\n+ de confiance!","sors de ta zone de confort\net va vers l'est!\nune surprise t'attend!!!"})	
	 p.ada+=1
	 sfx(6)
	 elseif x==25 and y==37 then	
		tb_init("diversity",{"sans les femmes, on se prive\nde regards sur le monde,\net on laisse des angles morts"})
	elseif x==25 and y==42 then 
		tb_init("bobby",{"actuellement, on denombre pres\nde 12 millions de personnes\natteintes de deficience en","france. on estime qu'environ\n80% des personnes handicapees\nsont atteintes d'un handicap","invisible."})
	elseif x==28 and y==40 then 
		tb_init("johny",{"ces dernieres annees, l'accent\na ete mis sur le recrutement\ndes collaborateurs juniors","mais le mouvement risque de\ns'essoufler si la strategie\nd'inclusion n'atteint pas le","sommet des organisations."})
		
	elseif x==49 and y==42 then 
		tb_init("picolas team",{"eh!tu n'es pas sense.e arriver\njusqu'ici! mais puisque tu es\nla, on a une bonne adresse a\n","te donner c'est : youpi tea'm\n(bubble tea et sandwich\nvietnamien) 14 rue vicq d'azir","press c to play again"})	
	elseif x==52 and y==42 then 
		tb_init("picolas team",{"eh!tu n'es pas sense.e arriver\njusqu'ici! mais puisque tu es\nla, on a une bonne adresse a\n","te donner c'est : youpi tea'm\n(bubble tea et sandwich\nvietnamien) 14 rue vicq d'azir","press c to play again"})	
	elseif x==8 and y==47 then 
		tb_init("yvette",{"je reve que mes quatre\npetits-enfants vivent un jour\ndans une nation ou ils ne","seront pas juges sur la\ncouleur de leur peau, mais sur\nla valeur de leur caractere.","(martin luther king)"})
	end
	
end

-- dessine le joueur
function draw_player()
	spr(p.sprite,p.x*8+p.ox,p.y*8+p.oy,1,1,p.flip)
end 
 
-->8
--sources : https://fairedesjeux.fr/pico-8/
-- affiche nombre de coeurs en haut a gauche

function draw_ui()
	camera()
	palt(0,false)
	palt(12,true)
	spr(81,2,2)
	palt()
	print_outline("X"..p.keys,10,2)
end

function print_outline(text,x,y)
	print(text,x-1,y,0)
	print(text,x+1,y,0)
	print(text,x,y-1,0)
	print(text,x,y+1,0)
	print(text,x,y,7)
end

-->8
-- code de la zone de texte
-- par profpatonildo
-- largeur lettre = 4 pixel
function tb_init(name,string) -- cette fonction demarre et definit une zone de texte avec un son en entree.
    reading=true -- met la lecture a vrai lorsqu'une zone de texte a ete appelee.
    sfx(2)
    msg_title=""
	--tableau contenant toutes les proprietes d'une zone de texte.
    tb={ 
    str=string, -- les chaines de caracteres: c'est la table des chaines de caracteres passee a cette fonction dans _update()
  	msg_title=name,
	i=1, -- index utilise pour indiquer quelle chaine de tb.str lire.
    cur=0, -- tampon utilise pour afficher progressivement les caracteres dans la zone de texte.
    char=0, -- caractere courant a dessiner dans la zone de texte.
    x=2, -- coordonnee x
    y=104, -- coordonnee y
    w=123, -- largeur de la boite de texte
    h=20, -- hauteur de la boite de texte
    col1=7, -- couleur du fond 10
    col2=2, -- couleur de la bordure 12
    col3=13, -- couleur du texte 8
    }
end

function tb_update()  -- cette fonction gere la boite de texte a chaque mise a jour de l'image.
   
		
	if tb.char<#tb.str[tb.i] then -- si le message n'a pas ete traite jusqu'a son dernier caractere :
        tb.cur+=0.5 -- augmente la memoire tampon. 0.5 est deja la vitesse maximale pour cette configuration. si vous souhaitez que les messages s'affichent plus lentement, reglez cette valeur sur une valeur inferieure. elle ne doit pas etre inferieure a 0.1 ni superieure a 0.9.
        if tb.cur>0.9 then -- si le tampon est superieur a 0,9 :
            tb.char+=1 -- definit le prochain caractere a dessiner.
            tb.cur=0    -- reinitialise le tampon.
            
			--if (ord(tb.str[tb.i],tb.char)!=32) sfx(tb.voice) -- jouer l'effet sonore de la voix.
        end
        if (btnp(5)) tb.char=#tb.str[tb.i] -- avancer au dernier caractere, pour accelerer le message.
    elseif btnp(5) then -- s'il est deja sur le dernier caractere du message et que la touche ❎/x est enfoncee :
        if #tb.str>tb.i then -- si le nombre de chaines a afficher est plus grand que l'index actuel (cela signifie qu'il y a un autre message a afficher ensuite) :
            tb.i+=1 -- augmenter l'index, pour afficher le message suivant sur tb.str
            tb.cur=0 -- reinitialise le tampon.
            tb.char=0 -- reinitialise la position du caractere.
        else -- s'il n'y a plus de messages a afficher :
            reading=false -- definir la lecture a faux. cela permet de s'assurer que la zone de texte n'est pas dessinee a l'ecran et peut etre utilise pour reprendre le jeu normal.
        end
    end
end

function tb_draw() -- cette fonction dessine la zone de texte sans incrementer les characteres (voir tb_update pour cela)
    if reading then -- ne dessine la boite de texte que si la lecture est vraie et si une boite de texte a ete appelee avec tb_init()
         --titre
    local y=95
	rectfill(5,y,11+#tb.msg_title*4,y+8,2)  -- 1
	rect(5,y,11+#tb.msg_title*4,y+8,2) -- 8
	print(tb.msg_title,9,y+2,7)  -- 10
		rectfill(tb.x,tb.y,tb.x+tb.w,tb.y+tb.h,tb.col1) -- dessine l'arriere-plan
        rect(tb.x,tb.y,tb.x+tb.w,tb.y+tb.h,tb.col2) -- dessine la bordure
        print(sub(tb.str[tb.i],1,tb.char),tb.x+2,tb.y+2,tb.col3) -- extrait une sous-chaine de characteres et dessine le texte
    end
end
-->8
-- auteur : hoschi
-- firework particles
-- this sample code shows
-- how to make firework-style
-- particles
--[ function _init()
 -- crate a table for
 -- particles
 --particles={}
--end

function boom(_x,_y)
 -- crate 100 particles at a location
 for i=0,50 do
  spawn_particle(_x,_y)
    spawn_particle(_x,_y)
 end
end

function spawn_particle(_x,_y)
 -- create a new particle
 local new={}
 
 -- generate a random angle
 -- and speed
 local angle = rnd()
 local speed = 0.1+rnd(0.4)
 
 new.x=_x --set start position
 new.y=_y --set start position
 -- set velocity based on
 -- speed and angle
 new.dx=sin(angle)*speed
 new.dy=cos(angle)*speed
 --new.dy=atan2(angle,5)*speed
 
 --add a random starting age
 --to add more variety
 --new.age=flr(rnd(25))
 --new.age=	flr(rnd(25))
 new.age=	flr(rnd(25))
 
 --add the particle to the list
 add(particles,new)
end

function updateparticles()
 --iterate trough all particles
 for p in all(particles) do
  --delete old particles
  --or if particle left 
  --the screen 
  if p.age > 180 
   or p.y > 128
   or p.y < 0
   or p.x > 128
   or p.x < 0
   then
   del(particles,p)
  else
  
   --move particle
   p.x+=p.dx
   p.y+=p.dy
   
   --age particle
   p.age+=1
   
   --add gravity
--   p.dy+=0.15
   p.dy+=0.005
  end
 end
end

function drawparticles() 
--iterate trough all particles
 local col
 for p in all(particles) do
  --change color depending on age
  if p.age > 60 then col=8
  elseif p.age > 40 then col=9
  elseif p.age > 20 then col=10  
  else col=7 end
  
  --actually draw particle
  line(p.x,p.y,p.x+p.dx,p.y+p.dy,col)
  
  --you can also draw simpler
  --particles like this
  --pset(p.x,p.y,col)

 end
end
__gfx__
0000000005ffffff78888888888888877878787878787878eee11eee78787878ccccccccccccccccccccccccccccccccffffffffaaaaaaaaaaaaaaaae8eeeeee
0000000005fffcff88888888888888888888888888888888ee1131e888888888cccccc0c0cccccccccccccccccccccccffffffffeeeeeeea0000000aeeeeee8e
0000000005f3cac3788888888888888788888888888888878d81119e88888888ccccccc0ccccccccccccccccccccccccffffffffeeeeeeeaeee0eeeaeee11eee
0000000005ff3cbf88888888888888888888888888888888edd1b11e88888888ccccccccccccccc444ccccccccccccccffffffffeeeeeeeaeeeeeeeae111131e
0000000005fff33f78888888888888878888888888888887eed111ee88888888cccccccccccccc41144cccccccccccccffffffffeeeeeeeaeeeeeeea1b1a1111
0000000005ff222288888888888888888888888888888888eee42ee888888888ccccccccccccc4444444cccccc0c0cccffffffffeeeeeeeaeeeeeeeae111117e
0000000005ff2222788888888888888788888888888888878ee42eee88888888ccccccccccc11444441114ccccc0ccccffffffffeee0eeeaeeeeeeeaeeeeeeee
0000000005fff22f88888888888888888888888888888888ee4442ee88888888ccccccccc444441144444444ccccccccffffffff0000000aeeeeeeeae8eeee8e
ffffffffffffff50ffffff5000000000000000000000000005ffffff05ffffffcccccccc44444444441114444ccccccceeeeeeee787878780000000aeeeeeeea
ffffffffffffff50ffffff5055555550555555550555555505ffffff05ffffffccccccc44411444411444444114cccccefeeeee988888888eee0eeeaeeeeeeea
ffffffffffffff50ffffff50ffffff50ffffffff05ffffff05ffffff05ffffffccccc44114444411444411444444cccceeeeeeee88888888eeeeeeeaeeeeeeea
ffffffffffffff50ffffff50ffffff50ffffffff05ffffff05ffffff05ffffffccc44444444114444444441114444ccc8eeee8ee88888888eeeeeeeaeeeeeeea
ffffffffffffff50ffffff50ffffff50ffffffff05ffffff05ffffff05ffffffc444411444444444114444444444444ceeeeeeee88888888eeeeeeeaeeeeeeea
ffffffffffffff50ffffff50ffffff50ffffffff05ffffff05ffffff05ffffff00000000004444114444440000000000ee9eeeee88888888eeeeeeeaeee0eeea
55555555ffffff5055555550ffffff50ffffffff05ffffff05ffffff0555555555555666550000000000000556665555eeeeeee888888888eeeeeeea0000000a
00000000ffffff5000000000ffffff50ffffffff05ffffff05ffffff0000000055665556666555555566655555566655eeeefeee78787878aaaaaaaaaaaaaaaa
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa8888888811111111888888887878787866556665555555111115566555555555111117118e88888800000000ffff222f
aeeeeee0a0eeeeee0eeeeeeaeeeeee0a88888888111111117888888788888888555555566655517777715556665555661111787188888e8855555555fff22222
aeeeeee0a0eeeeee0eeeeeeaeeeeee0a88888888111111118888888888888887555666655555177171771665555665551111171188811888ffffffff444f222f
aeeeeee0a0eeeeee0eeeeeeaeeeeee0a88888888111111117888888788888888555555555555171717171555555555661a11111181111318ffff222f442ff5ff
aeeeee0000eeeeee00eeeeeaeeeeee008888888811111111888888888888888766665566665517171717156665556665a8a111111b1a1111fff22222f4fffdff
aeeeeee0a0eeeeee0eeeeeeaeeeeee0a88888888111111117888888788888888555555555566617777715555566655551a11116181111178444f222fffffffff
aeeeeee0a0eeeeee0eeeeeeaeeeeee0a8888888811111111888888888888888766555666655555111115555555555555111116118e888888442ff5ff55555555
aeeeeee0a0eeeeee0eeeeeeaeeeeee0a88888888111111117888888788888888556665555555665555556665555666551111111188888e88f4fffdff00000000
1111111111111711eeeeeeefeeeeeeee88888888788888888888888887878787555556666566600000005556665555661114111044444110ffffffffffffff50
1881881111117871e88e88eeefeeeee98888888888888888888888878888888855555555555550aa0aa05555555555554444441011141110fffffffffffeff50
877e888111111711877e888eeeeeeeee8888888878888888888888887888888866566665555500aa0aa00555556665551114111014444410fffffffff3eae350
87e888811a11111187e8888e8eeee8ee888888888888888888888887888888885566555666650aaa0aaa0566555555554444441011114110ffff222fff3ebf50
87888881a8a111118788888eeeeeeeee888888887888888888888888788888885555555555550aaa0aaa0556666556661114111011444440fff22222fff33f50
188888111a111161e88888eeee9eeeee888888888888888888888887888888885555666655550aa000aa0555556665554444441011111110444f222fff222250
1188811611111611ee888eeaeeeeeee8888888887888888888888888788888886655555566660aaa0aaa0556665555551114111011111110442ff5ffff222250
1118116111111111eee8ee9eeeeefeee787878788787878787878787888888885566555555550aaa0aaa0555555556664444441011111110f4fffdfffff22f50
9555559095555590f000000fff000000ffffff66666666ffffffffffffffffffccccccccccccccc4cccccccccccccccc88888888888888880000000aeeeeeeea
55f55f5055f55f50f000000fff090090ffffff777666666fffffffffffffffffcccccccccccccc444ccccccc0c0ccccc8777777777777778eee0eeeaeeeeeeea
5f1ff1f05f1ff1f0f41ff14fff049940fff555ff7766677fffffffffffffffffc0c0ccccccccc441144cccccc0cccccc8777777777777778eeeeeeeaeeeeeeea
5effffe05effffe0f4ffff4fff099990fff050fff7777fffffffffffffffffffcc0cccccccc444444444cccccccccccc8777777777777778eeeeeeeaeeeeeeea
5512215055122150ff033055ff98778ffff050000000000000000fffffffffffcccccccccc44140000444cccccccc0c08777777777777778eeeeeeeaeeeeeeea
00f22f0000f22f00f555555f5558888ffff0044444444222444040ffffffffffccccccccc44440a0aa0444cccccccc0c8788878887888778eeeeeeeaeee0eeea
0022220000222200f555500f5558888fff004411444444444404440fffffffffcccccccc41140aa0aaa0114ccccccccc8787878787878778eeeeeeea0000000a
0010010000015000f0fff00f0f05ff5ff00444444442114440400040ffffffffccccccc444440000000044444ccccccc8788878787888778aaaaaaaaaaaaaaaa
11111111c00c00cc866666689444444900444411411144440440a0440fffffffcccccc4444110aa0aaa0411444cccccc8787878787878778aaaaaaaaaaaaaaaa
111111110880880c8666666844f44f4404411444444444104440004440ffffffccccc411144440a0aa044444444ccccc8787878887878778eeeeeeea0000000a
11411144077e880c861ff1684f1ff1f4044444444444400444444444440fffffccc4444444114400004444444114cccc8777777777777778eeeeeeeaeee0eeea
1444444407e8880c86ffff684ffffff4000000000000000000000000000fffffcc1144114444444444444114444444cc8777777777777778eeeeeeeaeeeeeeea
54144441c08880cc880220f544888844055555555555505555555555550fffffc444444444444444444444444444114c8777777777777778eeeeeeeaeeeeeeea
44444441cc080ccc88222285f4f88f4f055555555555505555555555550fffff000000000000000000000000000000008777777777777778eeeeeeeaeeeeeeea
194fff41ccc0cccc88222285ff1111ff050000550000505000055000050fffff555555666555555555666555555555558777777777777778eee0eeeaeeeeeeea
11411141cccccccc88288285ff1ff1ff050aa0550aa05050aa0550aa050fffff5566655555555551115566655555666588888888888888880000000aeeeeeeea
f000000ff000000feeeeaeee89999998050aa0550aa05050aa0550aa05011fff5555555555555111111155555555555500000000000000000000000000000000
0000000f009009007eeeee7e99999999050aa0550aa0506000055000051131ff5500000005001111131100050000000500000000044444400555555500000000
fe1ff1ef09099090eecceeee9fcffcf90500005500005050aa0550aa0111111f650aa0aa050a113111111a050aa0aa050000000044f44f4405f55f5500000000
feffffeff999999fec1cceae9ffffff90555566555555050aa0660aa0181111155000000050a111111111a0500000005000000004fdffdf40f1ff1f500000000
ff0330fff022220f44ccccee993333990555555555555050aa0560aa11111318660aa0aa05011111111311050aa0aa05055555509ffffff90effffe500000000
ff9999fff922229feeaaccccf9f33f9f055565555555505000055000819111115500000005011311311111050000000505955950991771990522225500000000
ff4444ffff1111ffe8eaa9ceff3333ff0500005600005055555555551113111955666666650a111111111a05666666650909909000f77f0000f22f0000000000
ff0ff0ffff1ff1ffeee9e9eeff0ff0ff050aa0550aa05055566155555111113155555555550aa1111311aa055555555509999990444444444444444404444444
ff5555ff1eeeeee1f000000f01111110050aa0550aa05056661111555f13111155000000050aa3111113aa0500000005011ff1104ddddd444444444404f44f44
f555555feefeefee0000000011f11f11060aa0650aa05065555555595511191f550aa0aa05000004220000050aa0aa05091111904d7ccd44444444440f1ff1f4
f514415fef2ff2fe041441401f3ff3f1050000550000505500000000055011ff550aa0aa05555554425555550aa0aa05005555004dcccd44444444440ffffff4
f544445feffffffe044444408ffffff8055555555555505504444444055022ff55000000055555544255d55500000005005005005b5555544444444404888844
f50aa05fee8778ee00988900880dd08805f555555555505504d444d4055042ff550aa0aa05555554445555550aa0aa0500000000444444444444444400f88f00
f40004ff1ef77fe1f048840ff8fddf8f0555555f5555505e04d444d4055042ff55000000055d555444555d550000000500000000444444444444444400111100
ff0000ff11888811ff8888ffffddddff0555f5555559505504d444d4055044ff5555555555515554445355556666666500000000444444444444444400100100
ff0ff0ff11d11d11ff9ff9ffff0ff0ff055555555555505504444444055044ff5555555555555444444455555555555500000000040000000000400000000000
c1c146566676c12030c245556575c145556575c22030c145556545556575c26000fc000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f0c147576777c12030c246566676c146566676c22030c146566646566676c26000fc000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c1c1f0c1c1c1c12030c247576777c147576777c220302647576747576777c260fcfc000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f0c144546474c12030f0c1c1c1c1c1c1c1c1c1f02030c1c2c2c2c2c2c2c2c260fcfc000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c16045556575c12030c2c2c2c2c2c2c2c2c2c2c22030c151414141414131c26000fc000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c1c146566676c12030c2c2c2c2c2c2c2c205c2c22030c161c007c0c4d4f3136000fc000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c16047576777c12030c2c2c2c2c213c2c2c2c2c220306010c0c0c0c5d51113600000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6060c1c1c1c1c12030c2c2c2c2c2c2c2c2c2c2c2204270e5c035c0c0c01103600000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c15141413731f02030c217c2c2c2c205c2c2c2c2204243e4c0c0c016061113600000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c16134c0c011c12030c2c2c2c2c2c2c2c2c2c2c220306010c0c0c0c0c01113600000000000000000000000000000000000c6d6e6f60000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c161c0c0c011c1203060c1c160c1f0c1c12660c12030c161e324e3c0e3f313600000000000000000000000000000000000c7d7e7f70000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c17101022221c12030c160c1f0c160c160c1c1f02030f071f201f201f22113600000000000000000000000000000000000510000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c1c1f02030f0c12030f023c160c1c1c1c1f0c1c12030c160c1f0c160c1f0c1600000000000000000000000000000000051000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
40404042424040424270707070707070707070704242407070707070707070c30000000000000000000000000000005100000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
43434343434343424243434343434343434343434242434343434343434343c30000000000000000000000000000510000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
60606060606060202560606060606060606060602030606060606060606060600000000000000000000000000000000000000000000000000000000000000000
__gff__
0001000000000100010101010003000101010101010101010101010100000300030003000000000001010101000101010400040000000000010101011100010100000101010101010101010101010900010001010101010101010101010109000101010101010101010101010101010101010101010101010101010101010101
0000000000000000010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
4a4b48494a4b08090a0b48494a4b48494a4b48494a4b48494a4b48494a4b4849000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5a5b58595a5b18191a1b58595a5b58595a5b58595a5b58595a5b58595a5b5859000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6a6b68696a6b28292a2b68696a6b68696a6b68696a6b68696a6b68696a6b6869000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7a7b78797a7b38393a3b78797a7b78797a7b78797a7b78797a7b78797a7b7879000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2d2d2d2d2d2d2d33722d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d06000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
061c061c061c060203061c620f1c1c33063333331c061c061c0662061c061c06000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
521d07071d1d1d24031c0f1c1c1c0f1c1c330f33371d1d1d1d1d272c2c2c3106000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1c1c20223333060224040404040404040404040403252c2c502c262c2c2c2c06000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
152e0c0c2e133302243434343434343434343424032c252c2c25262c2c2c2c06000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
160c0c0c0c110602030644454647444546470602032530712c2c262c2c2c2c06000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
160c0c6173113302030654555657545556573202032c312c252c262c2c2c2c06000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
16600c3e3e110602030664656667646566670602032c252c2c2c262c2c2c2c06000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1710102f2f121c02030674757677747576771c02032531371d1d362c2c2c2c06000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f1c0f1c0f1c0602241d1d1d1d1d1d1d07071d3424041d3631312c2c2c2c2c06000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
060606060606060203444546471c1c0f20220f1c0203313131312c2c2c2c2c06000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
331c1c061c1c060203545556571c15140c0c141302031c152e2e2e2e2e132c06000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1c061c06061c1c0203646566671c010c0c0c0c3f020306160c0c0c0c63112c06000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
32061c1c1c1c060203747576771c160c0c610c110224070d0c0c0c0c0c3f2c06000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0606061c061c060203444546471c163e3e3e3e110224341e0c0c0c0c0c3f2c06000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1c1c1c1c061c060203545556571c172f2f2f2f12020306163e0c3e0c3e112c06000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
061c0606060606020364656667321c1c1c1c1c1c02031c172f102f102f122c06000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1c1c1c1c1c1c060203747576770662061c061c0602030615142e142e14132c06000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1c060606061c0602031c0f1c0f1c1c1c1c1c1c1c0224070d0c0c0c0c0c113106000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1c1c061c1c1c06022407070707070707070707072424341e0c0c0c0c72113106000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
061c061c0606060224343434343434343434343424030617102f102f10123106000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1c1c06061c320602032c2c2c2c2c2c2c2c2c2c2c020332152e2e142e2e133006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
061c1c061c060602032c4445464733444546472c020306163e3e0c3e3e113106000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1c1c1c1c1c060602032c5455565733545556572c0224070d0c0c0c0c0c113106000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0606060606060602032c646566671c646566672c0224341e0c0c0c0c3e113106000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f1c1c1c1c1c6202032c747576771c747576772c020306163e3e700c3e113106000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1c1c444546531c02032c1c1c1c1c321c1c1c1c2c02030f172f2f10102f123106000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f1c545556571c02032c444546471c444546472c02031c444546444546472c06000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
0001000028050350603f0703f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000900001f65000000000003865000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010800001f051171511d05128151130511c0511f05124051095511015109551101510955110151095511c1511f000171001d00028100130001c0001f00024000095001010009500101000950010100095001c100
010f00200c0430040000300000003c6150000000000000000c0430040000300000003c6150000000000000000c0430040000300000003c6150000000000000000c0430040000300000003c615000000000000000
0110002016710167101f7101f7101b7101b710167101671014710147101f7101f7101b7101b7101671016710147101471020710207101b7101b7101871018710167101671020710207101b7101b7101871018710
011000200c00014700147000c0433c6151b70018700187100c0000c0433c615000003c6001b70018700187000c00014700147000c0433c6151b70018700187100c0000c0433c615000003c6001b7001870018700
00140000290502f05033050390503d75031300350003b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0010000012410124101d1101c11017110181101411014110000000000000000000000000000000000000000000000000001b35000000000000000000000000000000000000000000000000000000000000000000
__music__
03 41450304

