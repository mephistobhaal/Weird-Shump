pico-8 cartridge // http://www.pico-8.com
version 38
__lua__
--adventure game tutorial
--by dylan

--making a shmup 
--by lazy devs

function _init()
 map_setup()
 make_player()
 
 game_win=false
 game_over=false
end

function _update()
 if (not game_over) then
  update_map()
  move_player()
  check_win_lose()
 else
  if (btnp(❎)) extcmd("reset")
 end
end

function _draw()
 cls()
 if (not game_over) then
  draw_map()
  draw_player()
  if (btn(❎)) show_inventory()
 else
  draw_win_lose()
 end
end


-->8
--map code

function map_setup()
 --timers
 timer=0
 anim_time=30 --30 = 1 second

 --map tile settings
 wall=0
 key=1
 door=2
 anim1=3
 anim2=4
 lose=6
 win=7
end

function update_map()
 if (timer<0) then
  toggle_tiles()
  timer=anim_time
 end
 timer-=1
end

function draw_map()
 mapx=flr(p.x/16)*16
 mapy=flr(p.y/16)*16
 camera(mapx*8,mapy*8)

 map(0,0,0,0,128,64)
end

function is_tile(tile_type,x,y)
 tile=mget(x,y)
 has_flag=fget(tile,tile_type)
 return has_flag
end

function can_move(x,y)
 return not is_tile(wall,x,y)
end

function swap_tile(x,y)
 tile=mget(x,y)
 mset(x,y,tile+1)
end

function unswap_tile(x,y)
 tile=mget(x,y)
 mset(x,y,tile-1)
end

function get_key(x,y)
 p.keys+=1
 swap_tile(x,y)
 sfx(1)
end

function open_door(x,y)
 p.keys-=1
 swap_tile(x,y)
 sfx(2)
end
-->8
--player code

function make_player()
 p={}
 p.x=3
 p.y=2
 p.sprite=1
 p.keys=0
end

function draw_player()
 spr(p.sprite,p.x*8,p.y*8)
end

function move_player()
 newx=p.x
 newy=p.y
 
 if (btnp(⬅️)) newx-=1
 if (btnp(➡️)) newx+=1
 if (btnp(⬆️)) newy-=1
 if (btnp(⬇️)) newy+=1
 
 interact(newx,newy)
 
 if (can_move(newx,newy)) then
  p.x=mid(0,newx,127)
  p.y=mid(0,newy,63)
 else
  sfx(0)
 end
end

function interact(x,y)
 if (is_tile(key,x,y)) then
  get_key(x,y)
 elseif (is_tile(door,x,y) and p.keys>0) then
  open_door(x,y)
 end
end
-->8
--inventory code

function show_inventory()
 invx=mapx*8+40
 invy=mapy*8+8
 
 rectfill(invx,invy,invx+48,invy+24,0)
 print("inventory",invx+7,invy+4,7)
 print("keys "..p.keys,invx+12,invy+14,9)
end
-->8
--animation code

function toggle_tiles()
 for x=mapx,mapx+15 do
  for y=mapy,mapy+15 do
   if (is_tile(anim1,x,y)) then
    swap_tile(x,y)
    sfx(3)
   elseif (is_tile(anim2,x,y)) then
    unswap_tile(x,y)
    sfx(3)
   end
  end
 end
end
-->8
--win/lose code

function check_win_lose()
 if (is_tile(win,p.x,p.y)) then
  game_win=true
  game_over=true
 elseif (is_tile(lose,p.x,p.y)) then
  game_win=false
  game_over=true
 end
end

function draw_win_lose()
 camera()
 if (game_win) then
  print("★ you win! ★",37,64,7)
 else
  print("game over! :(",38,64,7)  
 end
 print("press ❎ to play again",20,72,5)
end
-->8
--various

function _init()
 --this will clear the screen
 cls(0)

 startscreen()
 blinkt=1
 t=0
 lockout=0
 shake=0
 
 debug=""
end

function _update() 
 t+=1
 
 blinkt+=1
 
 if mode=="game" then
  update_game()
 elseif mode=="start" then
  update_start()
 elseif mode=="wavetext" then
  update_wavetext()
 elseif mode=="over" then
  update_over()
 elseif mode=="win" then
  update_win()
 end
 
end

function _draw()

 doshake()
 
 if mode=="game" then
  draw_game()
 elseif mode=="start" then
  draw_start()
 elseif mode=="wavetext" then
  draw_wavetext()
 elseif mode=="over" then
  draw_over()
 elseif mode=="win" then
  draw_win()
 end
 
 camera()
 print(debug,2,9,7)
end

function startscreen()
 mode="start"
 music(7)
end

function startgame()
 t=0
 wave=0
 lastwave=9
 nextwave()
 
 ship=makespr()
 ship.x=64
 ship.y=64
 ship.sx=0
 ship.sy=0
 ship.spr=2
   
 flamespr=5
 
 bultimer=0
 
 muzzle=0
 
 score=0
 cher=0
 
 lives=4
 invul=0
 
 attacfreq=60
 nextfire=0
 
 stars={} 
 for i=1,100 do
  local newstar={}
  newstar.x=flr(rnd(128))
  newstar.y=flr(rnd(128))
  newstar.spd=rnd(1.5)+0.5
  add(stars,newstar)
 end 
  
 buls={}
 ebuls={}
 
 enemies={}
 
 parts={}
 
 shwaves={}
 
 pickups={}
 
 floats={}
end

-->8
-- tools

function starfield()
 
 for i=1,#stars do
  local mystar=stars[i]
  local scol=6
  
  if mystar.spd<1 then
   scol=1
  elseif mystar.spd<1.5 then
   scol=13
  end   
  
  pset(mystar.x,mystar.y,scol)
 end
end

function animatestars()
 
 for i=1,#stars do
  local mystar=stars[i]
  mystar.y=mystar.y+mystar.spd
  if mystar.y>128 then
   mystar.y=mystar.y-128
  end
 end

end

function blink()
 local banim={5,5,5,5,5,5,5,5,5,5,5,6,6,7,7,6,6,5}
 
 if blinkt>#banim then
  blinkt=1
 end

 return banim[blinkt]
end

function drwoutline(myspr)
 spr(myspr.spr,myspr.x+1,myspr.y,myspr.sprw,myspr.sprh)
 spr(myspr.spr,myspr.x-1,myspr.y,myspr.sprw,myspr.sprh)
 spr(myspr.spr,myspr.x,myspr.y+1,myspr.sprw,myspr.sprh)
 spr(myspr.spr,myspr.x,myspr.y-1,myspr.sprw,myspr.sprh)
end

function drwmyspr(myspr)
 local sprx=myspr.x
 local spry=myspr.y
 
 if myspr.shake>0 then
  myspr.shake-=1
  if t%4<2 then
   sprx+=1
  end
 end
 if myspr.bulmode then
  sprx-=2
  spry-=2
 end
 
 spr(myspr.spr,sprx,spry,myspr.sprw,myspr.sprh)
end

function col(a,b)
 if a.ghost or b.ghost then 
  return false
 end

 local a_left=a.x
 local a_top=a.y
 local a_right=a.x+a.colw-1
 local a_bottom=a.y+a.colh-1
 
 local b_left=b.x
 local b_top=b.y
 local b_right=b.x+b.colw-1
 local b_bottom=b.y+b.colh-1

 if a_top>b_bottom then return false end
 if b_top>a_bottom then return false end
 if a_left>b_right then return false end
 if b_left>a_right then return false end
 
 return true
end

function explode(expx,expy,isblue)
 
 local myp={}
 myp.x=expx
 myp.y=expy
 
 myp.sx=0
 myp.sy=0
 
 myp.age=0
 myp.size=10
 myp.maxage=0
 myp.blue=isblue
 
 add(parts,myp)
	  
 for i=1,30 do
	 local myp={}
	 myp.x=expx
	 myp.y=expy
	 
	 myp.sx=rnd()*6-3
	 myp.sy=rnd()*6-3
	 
	 myp.age=rnd(2)
	 myp.size=1+rnd(4)
	 myp.maxage=10+rnd(10)
	 myp.blue=isblue
	 
	 add(parts,myp)
 end
 
 for i=1,20 do
	 local myp={}
	 myp.x=expx
	 myp.y=expy
	 
	 myp.sx=(rnd()-0.5)*10
	 myp.sy=(rnd()-0.5)*10
	 
	 myp.age=rnd(2)
	 myp.size=1+rnd(4)
	 myp.maxage=10+rnd(10)
	 myp.blue=isblue
	 myp.spark=true
	 
	 add(parts,myp)
 end
 
 big_shwave(expx,expy)
 
end

function bigexplode(expx,expy)
 
 local myp={}
 myp.x=expx
 myp.y=expy
 
 myp.sx=0
 myp.sy=0
 
 myp.age=0
 myp.size=25
 myp.maxage=0
 
 add(parts,myp)
	  
 for i=1,60 do
	 local myp={}
	 myp.x=expx
	 myp.y=expy
	 
	 myp.sx=rnd()*12-6
	 myp.sy=rnd()*12-6
	 
	 myp.age=rnd(2)
	 myp.size=1+rnd(6)
	 myp.maxage=20+rnd(20)
	 
	 add(parts,myp)
 end
 
 for i=1,100 do
	 local myp={}
	 myp.x=expx
	 myp.y=expy
	 
	 myp.sx=(rnd()-0.5)*30
	 myp.sy=(rnd()-0.5)*30
	 
	 myp.age=rnd(2)
	 myp.size=1+rnd(4)
	 myp.maxage=20+rnd(20)
	 myp.spark=true
	 
	 add(parts,myp)
 end
 
 big_shwave(expx,expy)
 
end

function page_red(page)
 local col=7
 
 if page>5 then
  col=10
 end
 if page>7 then
  col=9
 end
 if page>10 then
  col=8
 end
 if page>12 then
  col=2
 end
 if page>15 then
  col=5
 end
 
 return col
end

function page_blue(page)
 local col=7
 
 if page>5 then
  col=6
 end
 if page>7 then
  col=12
 end
 if page>10 then
  col=13
 end
 if page>12 then
  col=1
 end
 if page>15 then
  col=1
 end
 
 return col
end

function smol_shwave(shx,shy,shcol)
 if shcol==nil then
  shcol=9
 end 
 local mysw={}
 mysw.x=shx
 mysw.y=shy
 mysw.r=3
 mysw.tr=6
 mysw.col=shcol
 mysw.speed=1
 add(shwaves,mysw)
end

function big_shwave(shx,shy)
 local mysw={}
 mysw.x=shx
 mysw.y=shy
 mysw.r=3
 mysw.tr=25
 mysw.col=7
 mysw.speed=3.5
 add(shwaves,mysw)
end

function smol_spark(sx,sy)
 --for i=1,2 do
 local myp={}
 myp.x=sx
 myp.y=sy
 
 myp.sx=(rnd()-0.5)*8
 myp.sy=(rnd()-1)*3
 
 myp.age=rnd(2)
 myp.size=1+rnd(4)
 myp.maxage=10+rnd(10)
 myp.blue=isblue
 myp.spark=true
 
 add(parts,myp)
 --end
end

function makespr()
 local myspr={}
 myspr.x=0
 myspr.y=0
 myspr.sx=0
 myspr.sy=0
 
 myspr.flash=0
 myspr.shake=0
 
 myspr.aniframe=1
 myspr.spr=0
 myspr.sprw=1
 myspr.sprh=1
 myspr.colw=8
 myspr.colh=8
 
 return myspr
end

function doshake()

 local shakex=rnd(shake)-(shake/2)
 local shakey=rnd(shake)-(shake/2)
 
 camera(shakex,shakey)
 
 if shake>10 then
  shake*=0.9
 else
  shake-=1
  if shake<1 then
   shake=0
  end
 end
end

function popfloat(fltxt,flx,fly)
 local fl={}
 fl.x=flx
 fl.y=fly
 fl.txt=fltxt
 fl.age=0
 add(floats,fl)
end

function cprint(txt,x,y,c)
 print(txt,x-#txt*2,y,c)
end
-->8
--update

function update_game()
 --controls
 ship.sx=0
 ship.sy=0
 ship.spr=2
 
 if btn(0) then
  ship.sx=-2
  ship.spr=1
 end
 if btn(1) then
  ship.sx=2
  ship.spr=3
 end
 if btn(2) then
  ship.sy=-2
 end
 if btn(3) then
  ship.sy=2
 end
  
 if btnp(4) then
  if cher>0 then
   cherbomb(cher)
   cher=0
  else
   sfx(32)
  end
 end
 
 if btn(5) then
  if bultimer<=0 then
	  local newbul=makespr()
	  newbul.x=ship.x+1
	  newbul.y=ship.y-3
	  newbul.spr=16
	  newbul.colw=6
	  newbul.sy=-4
	  newbul.dmg=1
	  add(buls,newbul)
	  
	  sfx(0)
	  muzzle=5
	  bultimer=4
  end
 end
 bultimer-=1
 
 --moving the ship
 ship.x+=ship.sx
 ship.y+=ship.sy
 
 --checking if we hit the edge
 if ship.x>120 then
  ship.x=120
 end
 if ship.x<0 then
  ship.x=0
 end
 if ship.y<0 then
  ship.y=0
 end
 if ship.y>120 then
  ship.y=120
 end
 
 --move the bullets
 for mybul in all(buls) do
  move(mybul)
  if mybul.y<-8 then
   del(buls,mybul)
  end
 end
 
 --move the ebuls
 for myebul in all(ebuls) do
  move(myebul)
  animate(myebul)
  if myebul.y>128 or myebul.x<-8 or myebul.x>128 or myebul.y<-8 then
   del(ebuls,myebul)
  end
 end 
 
 --move the pickups
 for mypick in all(pickups) do
  move(mypick)
  if mypick.y>128 then
   del(pickups,mypick)
  end
 end 
 
 --moving enemies 
 for myen in all(enemies) do
  --enemy mission
  doenemy(myen)
  
  --enemy animation
  animate(myen)
    
  --enemy leaving screen
  if myen.mission!="flyin" then 
   if myen.y>128 or myen.x<-8 or myen.x>128 then
    del(enemies,myen)
   end
  end
 end
 
 --collision enemy x bullets
 for myen in all(enemies) do
  for mybul in all(buls) do
   if col(myen,mybul) then
    del(buls,mybul)
    smol_shwave(mybul.x+4,mybul.y+4)
    smol_spark(myen.x+4,myen.y+4)
    if myen.mission!="flyin" then
     myen.hp-=mybul.dmg
    end
    sfx(3)
    if myen.boss then
     myen.flash=5
    else
     myen.flash=2
    end
    if myen.hp<=0 then
     killen(myen)
    end
   end
  end
 end
 
 --collision ship x enemies
 if invul<=0 then
	 for myen in all(enemies) do
	  if col(myen,ship) then
    explode(ship.x+4,ship.y+4,true)
	   lives-=1
	   sfx(1)
	   shake=12
	   invul=60
	  end
	 end
 else
  invul-=1
 end
 
 --collision ship x ebuls
 if invul<=0 then
	 for myebul in all(ebuls) do
	  if col(myebul,ship) then
    explode(ship.x+4,ship.y+4,true)
	   lives-=1
	   shake=12
	   sfx(1)
	   invul=60
	  end
	 end
 end
 
 --collision pickup x ship
 for mypick in all(pickups) do
  if col(mypick,ship) then
   del(pickups,mypick)
   plogic(mypick)
  end
 end
 
 
 if lives<=0 then
  mode="over"
  lockout=t+30
  music(6)
  return
 end
 
 --picking
 picktimer()
 
 --animate flame
 flamespr=flamespr+1
 if flamespr>9 then
  flamespr=5
 end
 
 --animate mullze flash
 if muzzle>0 then
  muzzle=muzzle-1
 end
  
 animatestars()
 
 --check if wave over
 if mode=="game" and #enemies==0 then
  nextwave()
 end
 
end

function update_start()

 if btn(4)==false and btn(5)==false then
  btnreleased=true
 end

 if btnreleased then
  if btnp(4) or btnp(5) then
   startgame()
   btnreleased=false
  end
 end
end

function update_over()
 if t<lockout then
  return
 end
 
 if btn(4)==false and btn(5)==false then
  btnreleased=true
 end

 if btnreleased then
  if btnp(4) or btnp(5) then
   startscreen()
   btnreleased=false
  end
 end
end

function update_win()
 if t<lockout then
  return
 end
 
 if btn(4)==false and btn(5)==false then
  btnreleased=true
 end

 if btnreleased then
  if btnp(4) or btnp(5) then
   startscreen()
   btnreleased=false
  end
 end
end

function update_wavetext()
 update_game()
 wavetime-=1
 if wavetime<=0 then
  mode="game"
  spawnwave()
 end
end
-->8
-- draw

function draw_game()
 cls(0)
 starfield()
 color(rnd(7))
 for n=1,10 do
 circ(rnd(128), rnd(128), 6)
 end
color(rnd(7))
for x=1,20 do
  line(rnd(128), rnd(128), rnd(128), rnd(128))
end
 if lives>0 then
	 if invul<=0 then
	  drwmyspr(ship)
	  spr(flamespr,ship.x,ship.y+8)
	 else
	  --invul state
	  if sin(t/5)<0.1 then
	   drwmyspr(ship)
	   spr(flamespr,ship.x,ship.y+8)
	  end
	 end
 end
 
 --drawing pickups
 for mypick in all(pickups) do
  local mycol=7
  if t%4<2 then
   mycol=14
  end
  for i=1,15 do
   pal(i,mycol)
  end
  drwoutline(mypick)
  pal()
  drwmyspr(mypick)
 end
 
 --drawing enemies
 for myen in all(enemies) do
  if myen.flash>0 then
   if t%4<2 then
    pal(3,8)
    pal(11,14)
   end
   myen.flash-=1
   if myen.boss then
    myen.spr=64
   else
    for i=1,15 do
     pal(i,7)
    end
   end
  end
  drwmyspr(myen)
  pal()
 end
  
 --drawing bullets
 for mybul in all(buls) do
  drwmyspr(mybul)
 end
 
 if muzzle>0 then
  circfill(ship.x+3,ship.y-2,muzzle,7)
  circfill(ship.x+4,ship.y-2,muzzle,7)
 end
 
 --drawing shwaves
 for mysw in all(shwaves) do
  circ(mysw.x,mysw.y,mysw.r,mysw.col)
  mysw.r+=mysw.speed
  if mysw.r>mysw.tr then
   del(shwaves,mysw)
  end
 end
 
 --drawing particles
 for myp in all(parts) do
  local pc=7

  if myp.blue then
   pc=page_blue(myp.age)
  else
   pc=page_red(myp.age)
  end
  
  if myp.spark then
   pset(myp.x,myp.y,7)
  else
   circfill(myp.x,myp.y,myp.size,pc)
  end
  
  myp.x+=myp.sx
  myp.y+=myp.sy
  
  myp.sx=myp.sx*0.85
  myp.sy=myp.sy*0.85
  
  myp.age+=1
  
  if myp.age>myp.maxage then
   myp.size-=0.5
   if myp.size<0 then
    del(parts,myp)
   end
  end
 end
 
 --drawing ebuls
 for myebul in all(ebuls) do
  drwmyspr(myebul)
 end
 
 --floats
 for myfl in all(floats) do
  local mycol=7
  if t%4<2 then
   mycol=8
  end
  cprint(myfl.txt,myfl.x,myfl.y,mycol)
  myfl.y-=0.5
  myfl.age+=1
  if myfl.age>60 then
   del(floats,myfl)
  end
 end
 
 print("blood:"..score,40,1,12)
 
 for i=1,4 do
  if lives>=i then
   spr(13,i*9-8,1)
  else
   spr(14,i*9-8,1)
  end 
 end

 spr(48,108,1)
 print(cher,118,2,14)
 
 --print(#buls,5,5,7)
end

function draw_start()
 --print(blink())

 cls(1) 
 cprint("your life means death to others",64,40,12) 
 cprint("do not forget this",64,80,blink())
end

function draw_over()
 draw_game()
 cprint("game over",64,40,8) 
 cprint("press any key to continue",64,80,blink())
end

function draw_win()
 draw_game()
 cprint("congratulations",64,40,12)
 cprint("press any key to continue",64,80,blink())
end

function draw_wavetext()
 draw_game()
 cprint("innocents who died: "..wave,64,40,blink())
end
-->8
-- waves and enemies

function spawnwave()
 if wave<lastwave then
  sfx(28)
 else
  music(10)
 end
 
 if wave==1 then
 
 cprint("hello",64,40,12)
  --space invaders
  attacfreq=60
  placens({
   {0,1,1,1,1,1,1,1,1,0},
   {0,1,1,1,1,1,1,1,1,0},
   {0,1,1,1,1,1,1,1,1,0},
   {0,1,1,1,1,1,1,1,1,0}
  })
 elseif wave==2 then
  --red tutorial
  attacfreq=60
  placens({
   {1,1,2,2,1,1,2,2,1,1},
   {1,1,2,2,1,1,2,2,1,1},
   {1,1,2,2,2,2,2,2,1,1},
   {1,1,2,2,2,2,2,2,1,1}
  })
 elseif wave==3 then
  --wall of red
  attacfreq=60
  placens({
   {1,1,2,2,1,1,2,2,1,1},
   {1,1,2,2,2,2,2,2,1,1},
   {2,2,2,2,2,2,2,2,2,2},
   {2,2,2,2,2,2,2,2,2,2}
  })
 elseif wave==4 then
  --spin tutorial
  attacfreq=60
  placens({
   {3,3,0,1,1,1,1,0,3,3},
   {3,3,0,1,1,1,1,0,3,3},
   {3,3,0,1,1,1,1,0,3,3},
   {3,3,0,1,1,1,1,0,3,3}
  })
 elseif wave==5 then
  --chess
  attacfreq=60
  placens({
   {3,1,3,1,2,2,1,3,1,3},
   {1,3,1,2,1,1,2,1,3,1},
   {3,1,3,1,2,2,1,3,1,3},
   {1,3,1,2,1,1,2,1,3,1}
  })
 elseif wave==6 then
  --yellow tutorial
  attacfreq=60
  placens({
   {1,1,1,0,4,0,0,1,1,1},
   {1,1,0,0,0,0,0,0,1,1},
   {1,1,0,1,1,1,1,0,1,1},
   {1,1,0,1,1,1,1,0,1,1}
  })
  
 elseif wave==7 then
  --double yellow
  attacfreq=60
  placens({
   {3,3,0,1,1,1,1,0,3,3},
   {4,0,0,2,2,2,2,0,4,0},
   {0,0,0,2,1,1,2,0,0,0},
   {1,1,0,1,1,1,1,0,1,1}
  })
 elseif wave==8 then
  --hell
  attacfreq=60
  placens({
   {0,0,1,1,1,1,1,1,0,0},
   {3,3,1,1,1,1,1,1,3,3},
   {3,3,2,2,2,2,2,2,3,3},
   {3,3,2,2,2,2,2,2,3,3}
  })
 elseif wave==9 then
  --boss
  attacfreq=60
  placens({
   {0,0,0,0,5,0,0,0,0,0},
   {0,0,0,0,0,0,0,0,0,0},
   {0,0,0,0,0,0,0,0,0,0},
   {0,0,0,0,0,0,0,0,0,0}
  })
 end  
end

function placens(lvl)

 for y=1,4 do
  local myline=lvl[y]
  for x=1,10 do
   if myline[x]!=0 then
    spawnen(myline[x],x*12-6,4+y*12,x*3)
   end
  end
 end
 
end

function nextwave()
 wave+=1
 
 if wave>lastwave then
  mode="win"
  lockout=t+30
  music(4)
 else
  if wave==1 then
   music(0)
  else
   music(3)  
  end
  
  mode="wavetext"
  wavetime=80
 end

end

function spawnen(entype,enx,eny,enwait)
 local myen=makespr()
 myen.x=enx*1.25-16
 myen.y=eny-66
 
 myen.posx=enx
 myen.posy=eny
 
 myen.type=entype
 
 myen.wait=enwait

 myen.anispd=0.4
 
 myen.mission="flyin"
 
 if entype==nil or entype==1 then
  -- green alien
  myen.spr=21
  myen.hp=3
  myen.ani={21,22,23,24}
 elseif entype==2 then
  -- red flame guy
  myen.spr=148
  myen.hp=2
  myen.ani={148,149}
 elseif entype==3 then
  -- spinning ship
  myen.spr=184
  myen.hp=4
  myen.ani={184,185,186,187}
 elseif entype==4 then
  -- yellow guy
  myen.spr=208
  myen.hp=20
  myen.ani={208,210}
  myen.sprw=2
  myen.sprh=2
  myen.colw=16
  myen.colh=16
 elseif entype==5 then
  myen.hp=130
  myen.spr=68
  myen.ani={68,72,76,72}
  myen.sprw=4
  myen.sprh=3
  myen.colw=32
  myen.colh=24
  
  myen.x=48
  myen.y=-24
  myen.posx=48
  myen.posy=25
  
  myen.boss=true
 end
  
 add(enemies,myen)
end
-->8
--behavior

function doenemy(myen)
 if myen.wait>0 then
  myen.wait-=1
  return
 end
 
 --debug=myen.hp
 
 if myen.mission=="flyin" then
  --flying in
  --basic easing function
  --x+=(targetx-x)/n
  
  local dx=(myen.posx-myen.x)/7
  local dy=(myen.posy-myen.y)/7
  
  if myen.boss then
   dy=min(dy,1)
  end
  myen.x+=dx
  myen.y+=dy
  
  if abs(myen.y-myen.posy)<0.7 then
   myen.y=myen.posy
   myen.x=myen.posx
   if myen.boss then
    sfx(50)
    myen.shake=20
    myen.wait=28
    myen.mission="boss1"
    myen.phbegin=t
   else
    myen.mission="protec"
   end
  end
  
 elseif myen.mission=="protec" then
  -- staying put
 elseif myen.mission=="boss1" then
  boss1(myen)
 elseif myen.mission=="boss2" then
  boss2(myen)
 elseif myen.mission=="boss3" then
  boss3(myen)
 elseif myen.mission=="boss4" then
  boss4(myen)
 elseif myen.mission=="boss5" then
  boss5(myen)
 elseif myen.mission=="attac" then  
  -- attac
  if myen.type==1 then
   --green guy
   myen.sy=1.7
   myen.sx=sin(t/45)
   
   -- just tweaks
   if myen.x<32 then
    myen.sx+=1-(myen.x/32)
   end
   if myen.x>88 then
    myen.sx-=(myen.x-88)/32
   end
  elseif myen.type==2 then
   --red guy
   myen.sy=2.5
   myen.sx=sin(t/20)
   
   -- just tweaks
   if myen.x<32 then
    myen.sx+=1-(myen.x/32)
   end
   if myen.x>88 then
    myen.sx-=(myen.x-88)/32
   end   
   
  elseif myen.type==3 then
   --spinny ship
   if myen.sx==0 then
    --flying down
    myen.sy=2
    if ship.y<=myen.y then
     myen.sy=0
     if ship.x<myen.x then
      myen.sx=-2
     else
      myen.sx=2
     end
    end
   end
   
  elseif myen.type==4 then
   --yellow ship
   myen.sy=0.35
   if myen.y>110 then
    myen.sy=1
   else
    
    if t%25==0 then
     firespread(myen,8,1.3,rnd())
    end
   end   
  end
  
  move(myen)
 end
  
end

function picktimer()
 if mode!="game" then
  return
 end

 if t>nextfire then
  pickfire()
  nextfire=t+20+rnd(20)
 end
 
 if t%attacfreq==0 then
  pickattac()
 end
end

function pickattac()
 local maxnum=min(10,#enemies)
 local myindex=flr(rnd(maxnum))
 
 myindex=#enemies-myindex
 local myen=enemies[myindex]
 if myen==nil then return end
 
 if myen.mission=="protec" then
  myen.mission="attac"
  myen.anispd*=3
  myen.wait=60
  myen.shake=60
 end
end

function pickfire()
 local maxnum=min(10,#enemies)
 local myindex=flr(rnd(maxnum))
 
 for myen in all(enemies) do
  if myen.type==4 and myen.mission=="protec" then
   if rnd()<0.5 then
    firespread(myen,12,1.3,rnd())
    return
   end
  end
 end
 
 myindex=#enemies-myindex
 local myen=enemies[myindex]
 if myen==nil then return end
 
 if myen.mission=="protec" then
  if myen.type==4 then
   --yellow guy
   firespread(myen,12,1.3,rnd())
  elseif myen.type==2 then
   --red guy
   aimedfire(myen,2)
  else
   fire(myen,0,2)
  end
 end
end


function move(obj)
 obj.x+=obj.sx
 obj.y+=obj.sy
end

function killen(myen)
 if myen.boss then
  myen.mission="boss5"
  myen.phbegin=t
  myen.ghost=true
  ebuls={}
  sfx(51)
  return
 end

 del(enemies,myen)   
 sfx(2)
 score+=1
 explode(myen.x+4,myen.y+4)
 local cherchance=0.1
 
 if myen.mission=="attac" then
  if rnd()<0.5 then
   pickattac()
  end
  cherchance=0.2
  popfloat("100",myen.x+4,myen.y+4)
 end
 
 if rnd()<cherchance then
  dropickup(myen.x,myen.y)
 end
end

function dropickup(pix,piy)
 local mypick=makespr()
 mypick.x=pix
 mypick.y=piy
 mypick.sy=0.75
 mypick.spr=48
 add(pickups,mypick)
end

function plogic(mypick)
 cher+=1
 smol_shwave(mypick.x+4,mypick.y+4,14)
 if cher>=10 then
  --get a life
  if lives<4 then
   lives+=1
   sfx(31)
   cher=0
   popfloat("1up!",mypick.x+4,mypick.y+4)
  else
   --points
   score+=10
   cher=0
  end
 else
  sfx(30)
 end
end

function animate(myen)
 myen.aniframe+=myen.anispd
 if flr(myen.aniframe) > #myen.ani then
  myen.aniframe=1
 end
 myen.spr=myen.ani[flr(myen.aniframe)]
end
-->8
--bullets

function fire(myen,ang,spd)
 local myebul=makespr()
 myebul.x=myen.x+3
 myebul.y=myen.y+6
 
 if myen.type==4 then
  myebul.x=myen.x+7
  myebul.y=myen.y+13
 elseif myen.boss then
  myebul.x=myen.x+15
  myebul.y=myen.y+23 
 end
 
 myebul.spr=32
 myebul.ani={32,33,34,33}
 myebul.anispd=0.5
 
 myebul.sx=sin(ang)*spd
 myebul.sy=cos(ang)*spd
 
 myebul.colw=2
 myebul.colh=2
 myebul.bulmode=true
 
 if myen.boss!=true then
  myen.flash=4
  sfx(29)
 else
  sfx(34)
 end
 
 add(ebuls,myebul)
 
 return myebul
end

function firespread(myen,num,spd,base)
 if base==nil then
  base=0
 end
 for i=1,num do
  fire(myen,1/num*i+base,spd)
 end
end

function aimedfire(myen,spd)
 local myebul=fire(myen,0,spd)
 
 local ang=atan2((ship.y+4)-myebul.y,(ship.x+4)-myebul.x)

 myebul.sx=sin(ang)*spd
 myebul.sy=cos(ang)*spd 
end

function cherbomb(cher)
 local spc=0.25/(cher*2)
 
 for i=0,cher*2 do
  local ang=0.375+spc*i
  
  local newbul=makespr()
  newbul.x=ship.x
  newbul.y=ship.y-3
  newbul.spr=17
  newbul.dmg=3
  
  newbul.sx=sin(ang)*4
  newbul.sy=cos(ang)*4
 
  add(buls,newbul)
 end
 
 big_shwave(ship.x+3,ship.y+3)
 shake=5
 muzzle=5
 invul=30

 sfx(33)
 
end
-->8
--boss

function boss1(myen)
 -- movement
 local spd=2
 
 if myen.sx==0 or myen.x>=93 then
  myen.sx=-spd
 end
 if myen.x<=3 then
  myen.sx=spd
 end
 -- shooting
 if t%30>3 then
  if t%3==0 then
   fire(myen,0,2)
  end
 end
 
 -- transition
 if myen.phbegin+8*30<t then
  myen.mission="boss2"
  myen.phbegin=t
  myen.subphase=1
 end
 move(myen)
end

function boss2(myen)
 local spd=1.5
 
 -- movement
 if myen.subphase==1 then
  myen.sx=-spd
  if myen.x<=4 then
   myen.subphase=2
  end
 elseif myen.subphase==2 then
  myen.sx=0
  myen.sy=spd
  if myen.y>=100 then
   myen.subphase=3
  end 
 elseif myen.subphase==3 then
  myen.sx=spd
  myen.sy=0
  if myen.x>=91 then
   myen.subphase=4
  end  
 elseif myen.subphase==4 then
  myen.sx=0
  myen.sy=-spd
  if myen.y<=25 then
   -- transition
   myen.mission="boss3"
   myen.phbegin=t
   myen.sy=0
  end  
 end 
 -- shooting
 if t%15==0 then
  aimedfire(myen,spd)
 end

 move(myen)
end

function boss3(myen)
 -- movement
 local spd=0.5
 
 if myen.sx==0 or myen.x>=93 then
  myen.sx=-spd
 end
 if myen.x<=3 then
  myen.sx=spd
 end

 -- shooting
 if t%10==0 then
  firespread(myen,8,2,time()/2)
 end 
 
 -- transition
 if myen.phbegin+8*30<t then
  myen.mission="boss4"
  myen.subphase=1
  myen.phbegin=t
 end
 move(myen)
end

function boss4(myen)
 local spd=1.5
 
 -- movement
 if myen.subphase==1 then
  myen.sx=spd
  if myen.x>=91 then
   myen.subphase=2
  end
 elseif myen.subphase==2 then
  myen.sx=0
  myen.sy=spd
  if myen.y>=100 then
   myen.subphase=3
  end 
 elseif myen.subphase==3 then
  myen.sx=-spd
  myen.sy=0
  if myen.x<=4 then
   myen.subphase=4
  end  
 elseif myen.subphase==4 then
  myen.sx=0
  myen.sy=-spd
  if myen.y<=25 then
   -- transition
   myen.mission="boss1"
   myen.phbegin=t
   myen.sy=0
  end  
 end 

 -- shooting
 if t%12==0 then
  if myen.subphase==1 then
   fire(myen,0,2)
  elseif myen.subphase==2 then
   fire(myen,0.25,2)
  elseif myen.subphase==3 then
   fire(myen,0.5,2)
  elseif myen.subphase==4 then
   fire(myen,0.75,2)
  end
 end
 -- transition
 move(myen)
end

function boss5(myen)
 myen.shake=10
 myen.flash=10 
 
 if t%8==0 then
  explode(myen.x+rnd(32),myen.y+rnd(24))
  sfx(2)
  shake=2
 end

 if myen.phbegin+2*30<t then
	 if t%5==0 then
	  explode(myen.x+rnd(32),myen.y+rnd(24))
	  sfx(2)
   shake=2
	 end
 end

 if myen.phbegin+4*30<t then
  bigexplode(myen.x+16,myen.y+12)
  shake=15
  enemies={}
  sfx(35)
 end
end
__gfx__
00000000004444000044440000000000000000000000000000000000000000000000000000888800000000000000000000000000000000000000000000000000
00000000044004400440044000000000000000000000000000000000000000000000000008800880000000000000000000000000000000000000000000000000
00700700440000444400004400000000000000000000000000000000000000000000000088000088000000000000000000000000000000000000000000000000
00077000449009044490090400000000000000000000000000000000000000000000000088900908000000000000000000000000000000000000000000000000
00077000040000440400004400000000000000000000000000000000000000000000000008000088000000000000000000000000000000000000000000000000
00700700044004400440044000000000000000000000000000000000000000000000000008800880000000000000000000000000000000000000000000000000
00000000044444000444440000000000000000000000000000000000000000000000000008888800000000000000000000000000000000000000000000000000
00000000000440000004400000000000000000000000000000000000000000000000000000088000000000000000000000000000000000000000000000000000
00000000333333333333333300000000333333330000000000000000000000000000000000000000000000000000000088888888888888880000000000000000
00aaa00033333bb3333399330000000033aaa333000000000000000000ee000000ee000000000000000000000000000080000000000000080000000000000000
00999a003b333b33355998530000000033999a330000000000000000ee00eee0ee00eee000000000000000000000000080800000000008080000000000000000
0a030a003bb3bb3335890933000000003a030a330000000000000000e00e0e00e00e0e0000000000000000000000000080000000000000080000000000000000
0930a90033b3333335505093000000003930a9330000000000000000eee0eeee66e0eeee00000000000000000000000080000000000000080000000000000000
099a990033bb3b333335053300000000399a99330000000000000000606eeeee006eeeee00000000000000000000000080000000000000080000000000000000
00099000333333b333505533000000003339933300000000000000000eeeeeee0eeeeeee00000000000000000000000080000000000000080000000000000000
00000000333333333333333300000000333333330000000000000000eeeee000eeeee00000000000000000000000000080000000000000080000000000000000
8000000880000008800000080000000044999994449499940000000033e333330000000000000000000000000000000080000000000000080000000000000000
0800008008000080080000800000000099999994999999940000000033ee33330000000000000000000000000000000080000000000000080000000000000000
008008000080080000800800000000009994999400000000000000003ddedd330000000000000000000000000000000080000000000000080000000000000000
000880000008800000088000000000009444449400000000000000003333e3330000000000000000000000000000000080000000000000080000000000000000
0008800000088000000880000000000099949999000000000000000033ddedd30000000000000000000000000000000080000000000000080000000000000000
008008000080080000800800000000009999999900000000000000003333e3330000000000000000000000000000000080800000000008080000000000000000
0800008008000080080000800000000049999999499999990000000033ddedd30000000000000000000000000000000080000000000000080000000000000000
80000008800000088000000800000000999944449999444400000000333ee3330000000000000000000000000000000088888888888888880000000000000000
fffffffffff5fffff5ff5fff000000000044444444333333000000003e3eee3e00000000000000000005dd010000000000000000000000000000000000000000
fffffffffff55fff5555555500000000040000044043333300000000ee3eee3e0000000000000000000555d60000000000000000000000000000000000000000
ffffffff555ffffffff5fff500000000440444004043333300000000eeee3eee00000000000000000005500d0000000000000000000000000000000000000000
fffffffff5ff5fff55555555000000004044044040433333000000003e3333e30000000000000000000055500000000000000000000000000000000000000000
ffffffffffffff5ff5fff5ff000000004040004044433333000000003e3333e30000000000000000000010500000000000000000000000000000000000000000
fffffffffffff5f555555555000000004040440043333333000000003e3333e30000000000000000000011000000000000000000000000000000000000000000
ffffffffffff5fffff5fff5f000000004040000444333333000000003e3333e30000000000000000000005000000000000000000000000000000000000000000
fffffffffffff5ff5555555500000000404440440433333300000000ee3333ee0000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01010173010101010111110101010143230101020202020202011111010101232301010101011101010101010101010123230123230111111101010101011101
01011101111111011123010101110101010101010101010101010101011111010101010101110101011101010101111101010123232301010101010101010101
01010101010101011111110101232323010102020202020201010101010123230111010111110101010101111101111123232323231111011101010101010111
01010101010101010123010101010101010101010111010111110101010101010101010101110101010101110111010101010101012323010101010101010101
01010101010111010111110123232323010102020202021101010101110123010101010111010101010101010111010101012323232311010171010101010101
01111101011101010101230101010101010101110111011101011101010101011101010101010101010101110101010101010101010101232301010101010101
01010101011101010101110101232323010101020202010101010101110143010101110101010111010101010101010101110101232311011172010101010101
01010111010101010101230101010101010111110111010101010101010101010111011101010101010101010101010101010101010101010123230101010101
01010111010101011111110101232323010101020202010111010101012323012301020202010111010101110101011101011101012323010173010101010101
01010101010101010101230101010101010101011101010101110101010101010101010101110101011101010101010101010101010101010101012323010101
01011111111111111111111111232323231111010202010111010101012323232301020202232323230101710101010101010101111123230101011101011101
01011111010101010101231101010101011101010111110101110111010111010101010101010101111101010101010101010101010101010101010123230101
01011101010111111111010101012323232301010202010101010101012323232301020202232323232323721101110101017101010101230101010101010111
11011101011101010101230101010101110101011111110101110101010101011101010101011111110101010101010101010101010101010101010101012301
01010101011111010111010101111123232311010102010101010101232323232301020211232301012323730101010101017201010101231101010101010101
01010101010111011101230101010101010101010101010101010101011101010101011101110101010101010101010101010101010101010101010101012323
01010101010101010111110101010101232301010102020111011101012323230101111123230111110123230101010101017301010101230101010101010101
01111101010101010101230101110101710111010101110101010111110111011101010101010101010101010101010101010101010101010101010101010123
01010101010101010111110101010111012323010102020111010101012323232311110101011111010123230101010101010101010123230101010101011101
01010101010101110101230101010101720101010101010101010101110101110111010101010101010101010101010101010101010101010101010101010123
01010101410101011101110101010101012323010101020201010101012323232301010101010101010123230101010101010101110123230111110101010111
01110101010101110101230101010101730101010101011111110101011101010101010101010101010101010101010101010101010101010101010101010123
01010101010101010101010101010101012323232301020202010101010123232301010101010101010123230101010101010101010123010101010101010101
11010101111101010123230101110101010111010101010101011101011101010101010101010101010101010101010101010101010101010101010101010123
01010101010101010101010101010101111123232301020202020101010123232323010101010101010123230101010101010101012323110101010101011111
01010101010111010123010101010101010101010101110101010101010101010101010101010101010101010101010101010101010101010101010101012301
01010101011101110101010101010111011101232301010202020101010123232323230101010101012323230101010101010111232301010101110101010111
01010101010101012301010101010101010101010101710111010101010101010101010101010101010101010101010101010101010101010101010123230101
01010101010101010101010101010101110101232323010102020201010101012323232301010123432323010101010101010123232301010111010101010111
01110101110101112301010101010101010101010101720101010101010101010101010101010101010101010101010101010101010101010101012323010101
01010101010171010101010101010101010101012323230101020202110101010123232323232323010101010101010101012323230101011101010101010101
01010101111101230101011101010101711101011101730101010101010101010101010101010101010101010101010101010101010101010123230101010101
01010101111172010101010101111101110101010123230101010202020101010101010101010101010101010101010101232323230101011101010101010101
11010101110101230101010101010101720101110101010101010101010101010101010101010101010101010101010101010101010101232323010101010101
01010101010173110111010171011101010101010123230101010101020111010101010101010101010101010101010123232311010101010101010101010101
01010101010123230101010111010101731101010101010101010101010101010101010101010101010101010101010101010101012323230101010101010101
01010101010101010101010172110111010101010123232301110111010101010101010111110101010101011101012323232311010101010101010101010101
01010101010123011101010101011111010101010101010101010101710101010101010101010101010101010101010101010123230101010101010101010101
01011101011101110111010173111101010101010101232323010101010101010111010111010101010101110123232323231101010101010101010101010101
01010101010123110101010101710101010101010101010101010101720101010101010101010101010101010101010123232301010101010101010101010101
01010101010101010101011101010101010101010101030303030303010111010111010101010101110111010303030303010101010101010101010101010101
01010101010123010101010101720101010101010101010101010101730101010101010101010101010101010123232301010101010101010101010101010101
11011111010101010101010111110101010101010101010103030303030303030301010101011101010103030303030101010101011101010101010101010101
01010101010123010101010101730101010101010101010101010101010101010101010101010101010101232323010101010101010101010101010101010101
11010101011101111101110101010101010101110101010101030303030303030303030303030303030303030303010101011101011101010101010171010101
01010101010123010101010101010101010101010101010101010101010101010101010101010101010123230101010101010101010101010101010101010101
01011101011101010101011101010101010101010101017101010101010101030303030303030303030303030301010101010111010101010101010172010101
01010101010123010101010101010101010101010101010101010101010101010101010101010101232301010101010101010101010101010101010101010101
01010111010101010101011101010111111101010101017201010101010101010101010101010101110101010101011101110101010101010101010173010101
01010101010123010101010101010101010101010101010101010101010101010101010101010123010101010101010101010101010101010101010101010101
11010101010111010111011101010111010101010101017301010101110101010101010101110101010101011101011101010101010101010101010101010101
01010101010123230101010101010101010101010101010101010101010101010101010123230101010101010101010101010101010101010101010101010101
11010101010101010101111101010171010101010111010101010101010101010101010101010101010101010111010101010101010101010101010101010101
01010101010101012301010101010101010101010101010101010101010101010101012323010101010101010101010101010101010101010101010101010101
01010101010111110101010101010172010101011101110101010101114101010101010111010101010101011101010101010101010101010101010101010101
01010101010101010123232301010101010101010101010101010101010101012323232301010101010101010101010101010101010101010101010101010101
01010101010111010101010101010173010101011101010101010101010101110101010101010101010101010101010101010101010101010101010101010101
01010101010101010101012323230101010101010101010101010101010123232301010101010101010101010101010101010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101011101010101110101010101010101010101010101010101010101010101010101
01010101010101010101010101232323010101010101010101010101232323010101010101010101010101010101010101010101010101010101010101010101
01010101010101010101010101010101010101010101010111010111010101010101010101010101010101010101010101010101010101010101010101010101
01010101010101010101010101010123232301010101010101012323230101010101010101010101010101010101010101010101010101010101010101010101
01010101010101010101010101010101010101010111011101010101010101010101110101010101010101010101010101010101010101010101010101010101
01010101010101010101010101010101012323010101010123232301010101010101010101010101010101010101010101010101010101010101010101010101
__gff__
0000000000000000000000000000000002000001020000481000000000000000050505000301000100000000000000000101010005000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
1010101010101010101010101010101010101210101110101010101010111111101010101010101010101010101010101010101010101010101010101010101010101010111011103232321010101010101032321010323232101010101010101010323210101111101010101010101010111111101010101010101010101010
1010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010111010111010101010323232101010101010323232321010101010101010101010321011101010101010101010101110101010101010101010101010101010
1010101010101010101010101010103232323232323210101010101010101010101111101010101010101010101010101010101010101010101010101010101011101010101010101010101032321010101010101010101010101010101010101032321010101010101010111011101011101011101010101010101010101010
1010101010101010101010101010103232323232323232323232323232323232323232323232323210101010101010101010101010171010101010101110101010101010101010101011101110323210111010101010101010101010101010113232101010101010101110101010101010101010101110101010111011111010
1010101010101010101010101017101032323232323232323232323232323232323232323232323232323232321010101010101010271010101010101110101010101010101111101110101010103210111010101010101010101010111010103210101010101010111010101010101010101010101110101010101010101010
1010101410101015101010101027101032323210101011101010101010103232323232323232323232323232323232321010101010371010111010101010101011111010101010101010101010103210101010101010101010101011101010103210111011101010101010101010101010101010101011101010101010101010
1010101010101011101010101037101010323232321111101710101010111010101011101010341110111111101032321010101710101010101111101110101010101011101010101010101010101132101010101010101010101010101010323210101010101010101010101010101110101010101010101010101010101010
1010101010101010101010171010171710101015341110112710101011101110101010101032321110101110101010101010102710111110101010101010101010101010101010101011101010101032101010101010101011111011101110321010111010101010101010101010101011101110101010101010101010101010
1010101010101010101010271010272710101111323210113711101017111010121010103232321110101010101010101010113711101010101010101010101010101010101010111117101110101032101010101010101011101010101010321010101010101010101110101010101010111010101010101010101010101010
1010101110101011101010371017171710101010323232101110101027101010101011103232321010101011101010101010101010101010101010101010101010101011101110101027101010101032321010101010101010101010101110321010101010101010101011101011101110101010101010101010101010101010
1010111011101010101010101027272710101110103232101110111037101010111110103232321011101110101010101010101010101010101010111010101010101010101010101037101010101010321010101010111110101010101010321110101010101010101110101010101111101010101010101010111011101010
1010101010101111101032323237373732323232323232323232321017111112101010101132321010111710101010101010101010101010101010101010111010101010101011101010101010101010321011101010101110101110111010323210101010101010101010101110101010101010101010111010101010101010
1010111110101010101032323232323232323232323232323232321027101010101110101032321010102710111410101010101010101010101010101010101010111010101010101010101010101132321010101010101010101110101010103232101010101111101010101010101010101011101010101011101010101010
1010101010101010111032321010101010101111101010111010101037101010111010101032321011103710101010101710101010101011101110101010101017101110101010101011101010101032101010101110101010101010101010101032321010101110101010101010101010101010101010101010101010101010
1010101010101011101032321010141010101010171111101010101010101110171010101032323210101010101010102710101010101010101010101010101027101011111010101010101010103232101010101010101010101010101011111111103232101010111110101010101010101010101011101010101010101010
1010101011171010101032321010101010101011271010101010101010101010271111101032323211101010101111103710101011111010101010111010101137101110101010101010101010103211101010101010101010111011101010101010101010323232101010101110101010101010101010101010101010111011
1010101011271010101032321010101010101710371010101017101010101010371010101032323232101110101110101010101010101010101010101010111010101010101010101017101010323210101010101010101110111010101010101010101010101032323210101010101010101010101010101010111010101011
1010101010371010101032321011101010102710101010101027101010101011111010101111323232321010111011101010101010101010101010111010101111101010101010101027111110321010101010101010101010101110101010101110101011111110103210101010101010101110101010101010101010111010
1010101010101010101032321111101010103710101710101037101011111010111010101011323232321111111110101010101010101011101011101010101010111010101010111037111032321011101010101011101010101010111017101010101011101010103210101010101010101010101110101010101010101010
1010101010101010101032321111101110101010102710101010101111101111111711101010111032323211101010101010101010101010111011111711101010101111111010101010101032101010101111111010101010101011101027101010111017101010103210101011101010101010101010101010101110101010
1010101010103232323232323232323232321010103710101010101110101010102710101011101110323232101010101010101010111110171010102710101011101110111111111111103232101010111110111010101010101010101037111110101027101010103210101010111010101010101011101110101010101010
1010101010111111111111111111111010323232323232323232323232323210103710101111111010103232323210101010101010101010271010113710111110111011101110101010103210111011101010101011101010101010101010101011101037101010103210101010101010101010101010101010101010101010
1010101010111111111110111110101111101010101032323232323232323232323232111110101010101010323210101110101010101010371011111111111011101011101010101032321010101410101010101011101010101010101110111010101010101010113211101010101010101010101010101010101010101010
1010101010111111111111101011111010101010101032323232111010103232323232321010101010101010101110101010101010101011111010101010101011101010101010323210111010101010101010101010101010111010101010101010101010101010103210101010101010101010101010101010101010101010
1010101010111010111110171110101010101010103232323211101010101111103232323210101010101010101010101010101010111010101010101010111110101032323232323210101010101010111010101010101010101010111010101010101010101010103210101010101010101010101010101010101010101010
1010101010111111111111271111101010101010323232321010101011111010101032323232321010101110101010101011101010101010101111101010323232323232111010103210101010111110101010101010101010101010101110101010101010101010103210101010101010101010101010101010101010101010
1010101010111010101110371010101010101010323232101010101010101010101010323232323210101410101010101010111010101110111010103232101010101010101010103210101010101010101010101010101010101010101010101010101010101010103232101010101010101010101010101010101010101010
1010101010111110101110101010101010101032321010102020101010101010101010103232323210101011101011101010101010101010101010323210101010101011101010103210101010101110101017101110111010101010101010101010101010101010323232101010101010101010101010101010101010101010
1010101011111010101010101010101010103232321010202010101010101010101010101110103232323210101010101110101011101010103232321010101010101011101010101010101010111110101027101010101011101110101010101010101010101111103232111110101010101010101010101010101010101010
1010101011111010101010101017101010103232101020202020101011101010101010323232323232323232323232101010101010101032323210101010171010111110101010101032101011101010111137101010101010101010101010101010101011111010103232323232101010101010101010101010101010101010
1010101711111010101010101027101010323210102020202020111110101010323232321010101010111110103232321110101010103232101010101011271011101110101010111110101010101010101010101010101010101010101010101011111110101010101010101032323232101010101010101010101010101010
1010102710101010101011101037101032321010102020202020101010101032323210101010101010101010101032323210101032321010101111111011371010101110111010101032101010101111101010101011101010101010101011101010101010101010111011101011101032323210101010101010101010101010
__sfx__
0005000000000000000c0500d0500e050100501605013050000001505017050000001b05020050220502605023050200501f05000000140500e0500d050110501c05017050130500000000000000000000000000
0014000000000000001405002050190500d06000060120501f0501104005040160501705018050190401c04025050170500305000000000000f050150500000026050060500000021050320502e0500000000000
