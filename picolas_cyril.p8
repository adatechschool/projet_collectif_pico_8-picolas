pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
-- main
function _init()
	create_player()
	--init_msg()
	reading=false 
end

function _update()
if reading then
  tb_update()
  player_movement()
	
  else
  if (btnp(5)) tb_init(0,{"♥aimer, ce n'est pas se\nregarder l'un l'autre, c'est\nregarder ensemble dans la","meme direction.\nantoine de saint-exupery\n","il faut faire aujourd'hui ce\nque tout le monde fera\ndemain. jean cocteau","c'est adacademie!\nc'est adacroyable:\nca marche! ♥"})
  if (btnp(4)) tb_init(1,{"this is a higher pitch voice\nbecause i can speak in\ndifferent voices!","pretty cool, huh? this system\nis simple, but it can be put to\ngreat use!","i bet you are impressed! ♥"})
    end
	update_camera()
	--[[if not messages[1] then 
	player_movement()
	end 
	update_camera()
	update_msg()]]--
	
end

function _draw()
	cls()
	draw_map()
	draw_player() 
	draw_ui()
	--draw_msg()
	tb_draw()
end
-->8
-- map 

function draw_map()
	map(0,0,0,0,128,64)
end 
 
function check_flag(flag,x,y)
	local sprite=mget(x,y)
	return fget(sprite,flag)
end

function update_camera()
	camx=flr(p.x/16)*16
	camy=flr(p.y/16)*16
	camera(camx*8,camy*8)
end

function old_camera()   
	camx=mid(0,p.x-7.5,31-15)
	camy=mid(0,p.y-7.5,31-15)
	camera(camx*8,camy*8)
end

function next_tile(x,y)
	sprite=mget(x,y)
	mset(x,y,sprite+1)
end

function pick_up_key(x,y)
	next_tile(x,y)
	p.keys+=1
	sfx(0)
end

function open_door(x,y)
	next_tile(x,y)
	p.keys-=1
	sfx(1)
end	
-->8
-- player

function create_player()
	p={
		x=8,y=8,
		ox=0,oy=0,
		start_ox=0,start_oy=0,
		anim_t=0,
		sprite=64,
		keys=0}
end

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
  
	interact(newx,newy)
	
	if (p.x!=newx or p.y!=newy)	and
	not check_flag(0,newx,newy) then
		-- on avance
		p.x=mid(0,newx,127)
		p.y=mid(0,newy,63)
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

function interact(x,y)
	if check_flag(2,x,y) then
		pick_up_key(x,y)
	elseif check_flag(1,x,y) and p.keys>0 then
		open_door(x,y)
	end
	
	if x==8 and y==4 then 
			create_msg("metany","hello picolas! \npret pour l'aventure\ndiversidays & inclusivedays?")
	elseif x==0 and y==5 then 
			create_msg("kingerly","la moindre injustice ouqu'elle\nsoit commise menace l'edifice\ntout entier. martin luther king")
	elseif x==11 and y==5 then 
		create_msg("kouikoui","ce qui fait la vraie valeur\nd'un etre humain, c'est de\ns'etre delivre de son petit\nmoi.albert einstein")
	end
	
end

function draw_player()
	spr(p.sprite,p.x*8+p.ox,p.y*8+p.oy,1,1,p.flip)
end  
-->8
--ui

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
--messages
function init_msg()
	messages={}
	create_msg("picolas","hello! bonne decouverte de \ndiversidays & inclusivedays!\n x pour sortir","ciao! ")
	--create_msg("picolas","123456789012345678901234567890","")
end

function create_msg(name,...)
	msg_title=name
	messages={...}
end

function update_msg()
	if (btn(❎)) then 
	deli(messages,1)
	end
end 

function draw_msg()
	if messages[1] then
		local y=98
		--titre
		rectfill(7,y,
		11+#msg_title*4,y+8,15)
		rect(7,y,
		11+#msg_title*4,y+8,3)
		print(msg_title,10,y+2,8)

		--message
		rectfill(3,y+9,124,y+28,7)
		rect(3,y+9,124,y+29,3)
		print(messages[1],6,y+11,8)
	end
end
-->8
-- text box code

function tb_init(voice,string) -- this function starts and defines a text box.
    reading=true -- sets reading to true when a text box has been called.
    tb={ -- table containing all properties of a text box. i like to work with tables, but you could use global variables if you preffer.
    str=string, -- the strings. remember: this is the table of strings you passed to this function when you called on _update()
    voice=voice, -- the voice. again, this was passed to this function when you called it on _update()
    i=1, -- index used to tell what string from tb.str to read.
    cur=0, -- buffer used to progressively show characters on the text box.
    char=0, -- current character to be drawn on the text box.
    x=0, -- x coordinate
    y=106, -- y coordginate
    w=127, -- text box width
    h=21, -- text box height
    col1=0, -- background color
    col2=7, -- border color
    col3=7, -- text color
    }
end

function tb_update()  -- this function handles the text box on every frame update.
    if tb.char<#tb.str[tb.i] then -- if the message has not been processed until it's last character:
        tb.cur+=0.5 -- increase the buffer. 0.5 is already max speed for this setup. if you want messages to show slower, set this to a lower number. this should not be lower than 0.1 and also should not be higher than 0.9
        if tb.cur>0.9 then -- if the buffer is larger than 0.9:
            tb.char+=1 -- set next character to be drawn.
            tb.cur=0    -- reset the buffer.
            if (ord(tb.str[tb.i],tb.char)!=32) sfx(tb.voice) -- play the voice sound effect.
        end
        if (btnp(5)) tb.char=#tb.str[tb.i] -- advance to the last character, to speed up the message.
    elseif btnp(5) then -- if already on the last message character and button ❎/x is pressed:
        if #tb.str>tb.i then -- if the number of strings to disay is larger than the current index (this means that there's another message to display next):
            tb.i+=1 -- increase the index, to display the next message on tb.str
            tb.cur=0 -- reset the buffer.
            tb.char=0 -- reset the character position.
        else -- if there are no more messages to display:
            reading=false -- set reading to false. this makes sure the text box isn't drawn on screen and can be used to resume normal gameplay.
        end
    end
end

function tb_draw() -- this function draws the text box.
    if reading then -- only draw the text box if reading is true, that is, if a text box has been called and tb_init() has already happened.
        rectfill(tb.x,tb.y,tb.x+tb.w,tb.y+tb.h,tb.col1) -- draw the background.
        rect(tb.x,tb.y,tb.x+tb.w,tb.y+tb.h,tb.col2) -- draw the border.
        print(sub(tb.str[tb.i],1,tb.char),tb.x+2,tb.y+2,tb.col3) -- draw the text.
    end
end
__gfx__
0000000088888888888888870eee11ee0eeeeeeeeeeeeee0eee11eee78787878888888887878787811111a118e888888ffffffffffffffff8800008700000000
0000000078888888888888880ee1131e0eeeeeeeeeeeeee0ee1131ee888888888e88888e888888881111a8a188888e88ffffffffffffffff8808808800000000
0070070088888888888888870e1311110eeeeeeeeeeeeee0e131131e888888888888e8888888888811111a1188811888ffffffffffffffff8800008700000000
0007700078888888888888880e1111310eeeeeeeeeeeeee0e111111e8888888888888888888888881a11111183111138ffffffffffffffff8809908800000000
0007700088888888888888870ee1311e0eeeeeeeeeeeeee0ee1131ee888888888888888888888888a8a1111111131111ffffffffffffffff8800008700000000
0070070078888888888888880eee44ee0eeeeeeeeeeeeee0eee44eee8888888888e888e8888888881a11111183111138ffffffffffffffff8803308800000000
0000000088888888888888870eee44ee0eeeeeeeeeeeeee0eee44eee88888888e888888888888888111111118e888888ffffffffffffffff8800008700000000
0000000078888888888888880ee4444e0eeeeeeeeeeeeee0ee4444ee888888888888e888787878781111111188888e88ffffffffffffffff7878787800000000
fffffffffffff500fffff500000000000000000000000000005fffff005fffffcccccccccccccccccccccccccccccccc444ccccccccccccc5555555500000000
fffffffffffff500fffff500000000000000000000000000005fffff005fffffcccccc0c0ccccccccccccccccccccccc4414cccccccccccc5555555500000000
fffffffffffff500fffff500555555005555555500555555005fffff005fffffccccccc0cccccccccccccccccccccccc44444ccccccccccc5555555500000000
fffffffffffff500fffff500fffff500ffffffff005fffff005fffff005fffffccccccccccccccc444cccccccccccccc144444cccccccccc5555555500000000
fffffffffffff500fffff500fffff500ffffffff005fffff005fffff005fffffcccccccccccccc41144ccccccccccccc4114444ccccccccc5555555500000000
55555555fffff50055555500fffff500ffffffff005fffff005fffff00555555ccccccccccccc4444444cccccc0c0ccc4441144ccccc0c0c5555555500000000
00000000fffff50000000000fffff500ffffffff005fffff005fffff00000000ccccccccccc11444441114ccccc0cccc44444444ccccc0cc5555555500000000
00000000fffff50000000000fffff500ffffffff005fffff005fffff00000000ccccccccc444441144444444cccccccc4444444444cccccc5555555500000000
aaaaaaaaaaaaaaaa000000000000000088888888111111118888888778787878cccccccc44444444441114444ccccccc44444444444ccccc0000000000000000
aeeeeee0eeeeeeaaeeeeeeeeeee11eee88888888111111117888888888888888ccccccc44411444411444444114ccccc441444114444cccc0000000000000000
aeeeeee0eeeeeeaaeeeeeeeeee1131ee88888888111111118888888788888887ccccc44114444411444411444444cccc11444444444444cc0000000000000000
aeeeeee0eeeeeeaaeeeeeeeee131111e88888888111111117888888888888888ccc44444444114444444441114444ccc444411444441144c0000000000000000
aeeeee000eeeeeaaeeeeeeeeee1311ee88888888111111118888888788888887c444411444444444114444444444444c44444444444444440000000000000000
aeeeeee0eeeeeeaaeeeeeeeeeee11eee888888881111111178888888888888880000000000444411444444000000000000000000000000000000000000000000
aeeeeee0eeeeeeaaeeeeeeeeeee44eee888888881111111188888887888888875555566655000000000000055666555555565555566555650000000000000000
aeeeeee0eeeeeeaaeeeeeeeeee4444ee888888881111111178888888888888885566555666655555556665555556665566555566655555550000000000000000
00000000eee11ee0000000000ee11eee888888887888888888888887878787876655666555555511111556655555555555555555555555550000000000000000
0ee13eeeee1131e0ee11eee00e3131ee888888888888888888888888888888885555555666555177777155566655556655556665555555550000000000000000
0e3111eee1131310e3131ee00111111e888888887888888888888887788888885556666555551771717716655556655500000006655566550000000000000000
0111311eee1111e0111111e00e1311ee88888888888888888888888888888888555555555555171717171555555555660aaaaa05555555650000000000000000
0e1111eeeee44ee0e1311ee00ee44eee88888888788888888888888778888888666655666655171717171566655566650aaaaa06555555550000000000000000
0ee44eeeeee44ee0ee44eee00ee44eee888888888888888888888888888888885555555555666177777155555666555500000005566555660000000000000000
0ee44eeeee4444e0ee44eee00e4444ee88888888788888888888888878888888665556666555551111155555555555550aaaaa05555555550000000000000000
0e4444ee00000000e4444ee00000000078787878878787878787878788888888556665555555665555556665555666550aaaaa05555555550000000000000000
9555559095555590f000000f00000000ffffffff66666666ffffffffffffffff5555566665666000000055566655556600000005555555550000000000000000
55f55f5055f55f50f000000f00000000ffffffff777666666fffffffffffffff55555555555550aa0aa055555555555566666665556665550000000000000000
5f1ff1f05f1ff1f0f41ff14f00000000fffff555ff7766677fffffffffffffff66566665555500aa0aa005555566655555556655665555550000000000000000
5effffe05effffe0f4ffff4f00000000fffff050fff7777fffffffffffffffff5566555666650aaa0aaa05665555555555555555555555550000000000000000
5512215055122150ff03305500000000fffff0500000ffffffffffffffffffff5555555555550aaa0aaa05566665566655666555556655550000000000000000
00f22f0000f22f00f555555f00000000fffff00444440000ffffffffffffffff5555666655550aa000aa05555566655555555555555556660000000000000000
0022220000222200f555500f00000000ffff0044114444440000ffffffffffff6655555566660aaa0aaa05566655555566555555555555550000000000000000
0010010000015000f0fff00f00000000fff00444444441114444000fffffffff5566555555550aaa0aaa05555555566655555555555555550000000000000000
ffffffffc00c00cc1666666100000000ff0044441141114444444040ffffffffccccccccccccccc4cccccccccccccccccccccccccccccc440000000000000000
ffffffff0880880c1666666100000000f004411444444444111404440fffffffcccccccccccccc444ccccccc0c0cccccccccccccccccc4440000000000000000
ff4fff44077e880c161ff16100000000f0044444444444444440410040ffffffc0c0ccccccccc441144cccccc0cccccccccccccccccc44440000000000000000
f444444407e8880c16ffff6100000000f000000444444111440440aa040fffffcc0cccccccc444444444cccccccccccccccccccccc4444140000000000000000
5414444fc08880cc110220f500000000ff05555000444444404140aa0410ffffcccccccccc44140000444cccccccc0c0ccccccccc44444440000000000000000
4444444fcc080ccc1122221500000000ff055555550000440444440044440fffccccccccc44440a0aa0444cccccccc0cccccccc4444411440000000000000000
f94fff4fccc0cccc1122221500000000ff050000555555000000000000000fffcccccccc41140aa0aaa0114cccccccccccccc444444444440000000000000000
ff4fff4fcccccccc1121121500000000ff050aa0550000505555555556650fffccccccc444440000000044444ccccccccccc4414444444440000000000000000
f000000ff0000000ffffffff00000000ff050aa0550aa050555555555555111fcccccc4444110aa0aaa0411444cccccccc444444411444140000000000000000
0000000f00900900ffffffff08808800ff050aa0550aa0506000055000011131ccccc411144440a0aa044444444cccccc4411444444444440000000000000000
fe1ff1ef09499400ffccffff877e8880ff050000550aa05050aa0550aa013111ccc4444444114400004444444114cccc44444444444441440000000000000000
feffffef09999990fc1ccfff87e88880ff0555566500005050aa0660aa011111cc1144114444444444444114444444cc44000000000000000000000000000000
ff0330fff022220f99ccccff87888880ff0555555555555050aa0560aa011113c444444444000000000000044444114c00055555566555550000000000000000
ff9999fff922229fff77cccc08888800ff05556555555550500005500006131f0000000000556555555555500000000055555556655556650000000000000000
ff4444ffff1111fffff779cf00888000ff050000560000505555555555560f4f5555556665555555556665555555555566655655555565550000000000000000
ff0ff0ffff1ff1fffff9f9ff00080000ff050aa0550aa0505556615555550f4f5566655555555551115566655555666555555555565555550000000000000000
ff5555fff999999ff000000f00aa0a00ff050aa0550aa0505666111165550f4f5555555555555111111155555555555500000000000000000000000000000000
f555555f99999999000000000a0aa0a0ff060aa06606a0506551131116550f4f5500000005001111131100050000000500000000000000000000000000000000
f514415f9fcffcf904144140eeeaaeeeff050000550000505511111311550f4f650aa0aa050a113111111a050aa0aa0500000000000000000000000000000000
f544445f9ffffff904444440eeeaaeeeff055555555555505511311111550f4f55000000050a111111111a050000000500000000000000000000000000000000
f50aa05f9933339900988900022aa2208888e8888888888888888888e8888888660aa0aa05011111111311050aa0aa0500000000000000000000000000000000
f40004fff9f33f9ff048840f0eeaaee0888888888e8888888e88e8888888888e5500000005011311311111050000000500000000000000000000000000000000
ff0000ffff3333ffff8888ff0eeaaee088e888e888888e888888888888e8888855666666650a111111111a056666666500000000000000000000000000000000
ff0ff0ffff0ff0ffff9ff9ff000000008888888888888888888888888888888855555555550aa1111311aa055555555500000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000055000000050aaa11111aaa050000000500000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000550aa0aa05000004440000050aa0aa0500000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000550aa0aa05555554445555550aa0aa0500000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000006500000005555554445555550000000500000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000550aa0aa05556664445565550aa0aa0500000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000005500000005665554445555550000000500000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000005566666665555554445556656666666500000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000005555555555555444444455555555555500000000000000000000000000000000
__gff__
0000000100000100000000010100010001010101010101010101010101010000030300010000000001010101010100000101000000000000010101010101000000000100010101010101010101010000010001000101010101010101010100000101010401010101010101010101000001010104010101010101010100000000
0000000000000000010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
1c1d58595a5b18191a1b58595a5b58595a5b58595a58595a5b5c5d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2c2d68696a6b28292a2b68696a6b68696a6b68696a68696a6b6c6d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3c3d78797a7b38393a3b78797a7b78797a7b78797a78797a7b3c3d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4c4d88898a8b48494a4b88898a8b88898a8b88898a88898a8b4c4d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0b0b0b0b0b0b0b08720b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7108080808080601020308620a0808700a080808080808080808080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
09090707090909240203080a0a08080a0a080808730909090909270000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a0a08080a0a0601240909090909090909090909020a0a0a250a260000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a152021130a0501023022232223732322232232260a250a0a0a260000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a160d0d110a0601026344454647444546470d06260a0a525037020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a16606111520501020354555657545556570d06260a630a0a010e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a17101012500601020364656667646566670d06260a250a0a26000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a0a0a0a0a0a0501023374757677747576770b31260a0a370936000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0d0d0d0d0d0d0601240909090909090907070909240909360c0c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000102444546470d0a0b08080b0a26420c0c0c0c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000102545556570d0a152021130a260c0c0c0c0c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000102646566670c0a160c0d110a260c0c0b0c0c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000102747576770c0a160d0d110a010707080c0c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000102444546470c0a171010120a01240e080c0c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000102545556570c0a0a0a0a0a0a01340c0b0c0c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000102646566673023222322232326000c0c0c0c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000001027475767703000000000000260000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000001020b08080b03000000000000260000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000260000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
