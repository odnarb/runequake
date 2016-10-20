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
local string aut;
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
          
};

void () world_touch =
{
 
 if (!(other.waterlevel))
          {
         //           bprint ("hits world ");
         local vector s,e;
           makevectors (other.velocity * -1);
	s = other.origin;
	v_forward_z = 0;
	normalize (v_forward);
	e = s + v_forward * 24;
	traceline (s, e, TRUE, other);
        
          //local vector tempi;
          bprint (vtos(trace_plane_normal)); bprint ("\n");
          //tempi = vectoangles(trace_plane_normal);
          //other.angles_x = tempi_x - 90;
          } 
          
};

// Cobalt, mostly for the plat on e1m2 and other stuff
void () VelocityPhysics = 
{



local entity r;
r = nextent (world);
while (r)
{
          
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
		
		
	

            // Cobalt mark gasbombs when they stop moving 
            if (r.classname == "gasbomb")
            if ((!(r.velocity)) && r.frame == 0)
            {
            if (time >= (r.nextthink - 1))
            r.effects = EF_FROZEN | 2;
            else r.effects = 0;
            }
          
          r = nextent(r);
          }

          

};



//=======================
void ()
worldspawn =
{
          SetMapAuthor ();
          //world.touch = world_touch;
          InternalInit ();
	InitBodyQue ();
	rjs_worldspawn ();
	precaches ();
	Light_Setup ();
	place_my_items ();
	IN_POQ(InitSearchHunk();)
         
          
          other = nextent(world);
	while (other != world)
	{
           MAX_CLIENTS = MAX_CLIENTS + 1;

           other = nextent (other);
	}
          
         
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
