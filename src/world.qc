/*  $Id: world.qc,v 1.85 2008/08/13 03:54:59 slotzero Exp $

    Copyright (C) 1996, 1997  Id Software, Inc.

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
*/

void ()
main =
{
};

entity	lastspawn;       


//=======================
/*QUAKED worldspawn (0 0 0) ?
Only used for the world entity.
Set message to the level name.
Set sounds to the cd track to play.

World Types:
0: medieval
1: metal
2: base
*/
void () SetMapAuthor =
{
local string aut,wm;
aut = "";
wm = world.message;
if (mapname == "dm3" || mapname == "start" || mapname == "e1m1"|| mapname == "e2m1" || mapname == "e2m2" || mapname == "e2m3" || mapname == "e2m4" || mapname == "e2m5" || mapname == "e2m6" || mapname == "e3m1" || mapname == "end")
aut = "John Romero";
else if (mapname == "dm1" || mapname == "e1m2" || mapname == "e1m3" || mapname == "e1m4" || mapname == "e1m5" || mapname == "e2m7" || mapname == "e3m5" || mapname == "e4m1")
aut = "Tim Willits";   
else if (mapname == "dm6" || mapname == "dm5" || mapname == "dm4" || mapname == "dm2" || mapname == "e1m8" || mapname == "e1m6" || mapname == "e1m7" || mapname == "e3m2" || mapname == "e3m4" || mapname == "e3m7")
aut = "American McGee"; 
else if (mapname == "e3m6")
aut = "American McGee & Tim Willits";
else if (mapname == "e4m2" || mapname == "e4m3" || mapname == "e4m5" || mapname == "e4m6" || mapname == "e4m7" || mapname == "e4m8")
aut = "Sandy Petersen";  
else return;

self.message = string_null;
self.message = strcat (wm, ". (by ");
self.message = strcat (wm, aut); 
self.message = strcat (wm, ")");  


          
};

void () world_touch =
{

SetMapAuthor ();
          
};

// Cobalt, mostly for the plat on e1m2 and other stuff
void () VelocityPhysics = 
{


local float ap,op;
ap = 0;
op = PLAYERS;
local entity r;
r = nextent (world);
while (r)
{
          if (pointcontents (r.origin) != r.pco)
            r.pcn = pointcontents (r.origin); 
  
        
           if (r.pcn != -1)
           r.Ldepth = WlevelEnt (r);
          if (r.flags & FL_CLIENT)
          ap = ap + 1;
          /*
          if ((r.flags & FL_CLIENT) && (!(r.flags & FL_OBSERVER)))
          {
          r.dest = world.dest;
          
          if (r.ShamTmr == framecount)
          {
            
          local entity tf,sc;
          tf = spawn ();
          tf.effects = EF_MAYBE_DRAW;
          tf.groundentity = r;
          tf.classname = "testfield_0";
          setsize (tf, VEC_HULL2_MIN, VEC_HULL2_MAX);
          setorigin (tf, r.origin + '0 0 4'); // Cobalt try player origin first
           if (dh_shambler_test (tf))
           {      
                    r.dest = tf.origin;
                     centerprint (r,"Player origin ok\n");
                     
                     
           }            
                 remove (tf);   
          if (!(r.dest))
          {
          sc = find (world, classname, "shambler_control");
	while (sc != world)
	{
		if (sc.owner != r)
		sc = find (sc, classname, "shambler_control");
	}          
               setsize (sc, VEC_HULL2_MIN, VEC_HULL2_MAX);
               sc.dest = sc.origin;
               local float halt;
              while (anglemod (sc.angles_y) < 360 && (!(halt)))
           {      
           sc.angles_y = anglemod (sc.angles_y + 5);
           makevectors (sc.angles);
           
          setorigin (sc, sc.origin + v_forward*56);
           if (dh_shambler_test (sc))
           {
                    r.dest = sc.dest;
                    create_te_spike (TE_WIZSPIKE, sc.dest);
                    halt = 1;
           }
                     
                     
           }          
           setorigin (sc, sc.dest);         
           setsize (sc, VEC_ORIGIN, VEC_ORIGIN);
         
          }
        
          r.ShamTmr = framecount + r.colormap;
          }
          }
          */
          if (r.classname == "plat")
	if (r.velocity_z != 0)
	{
          //bprint ("Plat ");
	//bprint (r.model);
	//bprint (" Is moving...waterlevel is ");
	//bprint (ftos (r.waterlevel));
	//PrintNL ();
	//if (r.state == STATE_DOWN)
	if ((pointcontents (r.absmax + '0 0 5') == CONTENT_EMPTY && pointcontents (r.absmax) == CONTENT_WATER))
	{

	sound (r, CHAN_AUTO, "misc/h2ohit1.wav", 1, ATTN_NORM);   
	if (r.velocity_z < 0)
          r.velocity =  r.velocity * 0.75;

          }
          }
         
          
          /*        
	
	if ((pointcontents (ctr + '0 0 -5') == CONTENT_WATER))
	bprint ("Plat in water\n");
	if ((pointcontents (r.absmax + '0 0 5') == CONTENT_EMPTY))
          bprint ("Plat near surface\n");
	   */
		
	
	
            if (r.model == "progs/grenade.mdl")
            {
           
           if ((r.classname == "gasbomb" && r.pcn < -2 && r.pcn != r.pco) || r.pcn == CONTENT_LAVA)
           {
                      r.nextthink = time;
           }
            else 
            {
            if (r.pcn < -2 && r.pcn != r.pco)
            {
        
            
             r.velocity_z = r.velocity_z * (1/8);
             r.velocity_x = r.velocity_x * (1/6);
             r.velocity_y = r.velocity_y * (1/6);
             r.movetype = MOVETYPE_FLY;
	    
            
            
            }
            else if (r.pco < -2 && r.pcn == -1)
            r.velocity_z = -2;    
            if (r.classname == "gasbomb") // Cobalt mark gasbombs when they stop moving 
            if ((!(r.velocity)) && r.frame == 0)
            {
            if (time >= (r.nextthink - 1))
            r.effects = EF_FROZEN | 2;
            else r.effects = 0;
            }
            
            }
            
            
            }
            
            if (r.classname == "bubble")
            {
             if (r.pcn == -2)
             {
             r.think = SUB_Remove;
              r.nextthink = time + frametime;
             }
            else if (r.pco < -2 && r.pcn == -1)
            {
             if (r.pco == CONTENT_WATER)
	SUB_Drip(r.origin + ' 0 0 16',WATERCOLOR);
	else if (r.pco == CONTENT_SLIME)
	SUB_Drip(r.origin + ' 0 0 16',SLIMECOLOR);
          local float db;
          db = random ();
          if (db == 0) db = 0.5;
          sound (r, CHAN_AUTO, "wizard/hit.wav", db, ATTN_IDLE);
              r.think = SUB_Remove;
              r.nextthink = time + frametime;
            }
            
            }
            else if ((!(r.effects & EF_MAYBE_DRAW)))
          {
           if (r.solid < 2 && r.th_stand != PlaceItem && (!(r.model)) && r.touch != Rune_Touch && r.classname != "Chatbubble")
          {
                     r.effects = r.effects | EF_MAYBE_DRAW;
                   // bprint ("Optimized ");
                   // bprint (r.classname);
                   // bprint ("\n");
          }          
          }
          
          
          r.pco = r.pcn;
          r = nextent(r);
          }

          
          PLAYERS = ap;

          if (PLAYERS > op)
          LoadBalance (1);
          else if (PLAYERS < op)
          LoadBalance (2);
          
};



//=======================
void ()
worldspawn =
{
          
           
          
                    local entity first_ent, test_enemy;
          
                    
          first_ent = nextent (world);
	test_enemy = first_ent;
	while (test_enemy != world)
	{
		MAX_CLIENTS = MAX_CLIENTS + 1;
		test_enemy = nextent (test_enemy);
	}
                    
                    
	
                    
                    
          
          
          
          
          
          
          //world.touch = world_touch;
          InternalInit ();
	InitBodyQue ();
	rjs_worldspawn ();
	precaches ();
	Light_Setup ();
	place_my_items ();
	IN_POQ(InitSearchHunk();)
         
          
          WATERCOLOR = 178; // 13;
//if (self.model == "maps/e1m1.bsp" || self.model == "maps/dm2.bsp" || self.model == "maps/e3m3.bsp")
//WATERCOLOR = 3; 
if (self.model == "maps/e1m2.bsp"  || self.model == "maps/end.bsp" || self.model == "maps/e2m6.bsp" || self.model == "maps/e2m5.bsp")
WATERCOLOR =112;


if (self.model == "maps/e1m3.bsp")
WATERCOLOR =30;
if (self.model == "maps/e1m4.bsp" || self.model == "maps/dm3.bsp" || self.model == "maps/e3m5.bsp")
WATERCOLOR =16;
if (self.model == "maps/e1m5.bsp" || self.model == "maps/dm5.bsp" || self.model == "maps/e2m7.bsp")
WATERCOLOR =170;
if (self.model == "maps/e2m1.bsp")
WATERCOLOR =30;
if (self.model == "maps/e2m2.bsp")
WATERCOLOR =185;
if (self.model == "maps/e2m3.bsp")
WATERCOLOR =31;
if (self.model == "maps/e2m4.bsp")
WATERCOLOR =19;
if (self.model == "maps/e3m4.bsp" || self.model == "maps/e4m3.bsp")
WATERCOLOR =45;
if (self.model == "maps/e4m1.bsp")
WATERCOLOR =17;
if (self.model == "maps/e4m2.bsp")
WATERCOLOR =33;
if (self.model == "maps/e4m4.bsp")
WATERCOLOR =35;
if (self.model == "maps/e1m8.bsp" || self.model == "maps/dm4.bsp")
WATERCOLOR =229;

        
          
         
};

void ()
StartFrame =
{
          sys_ticrate 	= frametime; // Cobalt - same as frametime cvar ("sys_ticrate");
          
        
          framecount = framecount + 1; // Cobalt count number of frames
	check_teamplay ();
	check_console_command ();
	CheckRules ();
	spawn_runes ();
	update_client_pings ();
	IN_QW(update_deathmatch ();)
          
          CD_RNTRACK = rint (random () * 10) + 1; // Random cd track
           
          if (!intermission_running)
          if (time > CD_END && CD_START != -2)
          {
          if (time >= (((cvar ("timelimit") * 60) - 30)))
          CD_RNTRACK = 3; // Force silence if near end of level
          CDTrack ();
          CD_START = time;
         
          msg_entity = find (world, classname, "player");
	while (msg_entity != world)
	{
            if (!(msg_entity.aqflags & AQ_QUIET))
           { 
 
	WriteByte (MSG_ONE, 8);
          WriteByte(MSG_ONE, 2);
          WriteString(MSG_ONE, CD_MSG);
           }         
                    
                    
         
           
          msg_entity = find (msg_entity, classname, "player");
	}

          }
          

          VelocityPhysics ();
         
          SLIMECOLOR = (rint (random () * 12) + 179);

          if (random () < 0.5)
          LAVACOLOR = (rint (random () * 7) + 227);
          else if (random () < 0.5)
          LAVACOLOR = (random () * 5) + 74;
          else 
          LAVACOLOR = (random () * 6) + 101;
         
          
};



/*
==============================================================================

BODY QUE

==============================================================================
*/

entity	bodyque_head;

void ()
InitBodyQue =
{
	bodyque_head = spawn ();
	bodyque_head.classname = "bodyque";
	bodyque_head.owner = spawn ();
	bodyque_head.owner.classname = "bodyque";
	bodyque_head.owner.owner = spawn ();
	bodyque_head.owner.owner.classname = "bodyque";
	bodyque_head.owner.owner.owner = spawn ();
	bodyque_head.owner.owner.owner.classname = "bodyque";
	bodyque_head.owner.owner.owner.owner = bodyque_head;
};

// make a body que entry for the given ent so the ent can be
// respawned elsewhere
void (entity ent)
CopyToBodyQue =
{
	if (gamemode == MODE_HEADS)
		return;

	bodyque_head.angles	= ent.angles;
	bodyque_head.model	= ent.model;
	bodyque_head.modelindex	= ent.modelindex;
	bodyque_head.frame	= ent.frame;
	bodyque_head.colormap	= ent.colormap;

	if (ent.movetype == MOVETYPE_WALK)
	{
		dprint ("bad movetype for bodyque by ", ent.netname, "\n");
		bodyque_head.movetype	= MOVETYPE_TOSS;
	}
	else
		bodyque_head.movetype	= ent.movetype;

	bodyque_head.velocity	= ent.velocity;
	bodyque_head.flags	= 0;

	setorigin (bodyque_head, ent.origin);
	setsize (bodyque_head, ent.mins, ent.maxs);

	bodyque_head		= bodyque_head.owner;
};
