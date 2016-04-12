/*  $Id: subs.qc,v 1.12 2003/06/24 22:17:45 slotzero Exp $

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
SUB_Null =
{
};

void ()
SUB_Remove =
{
	remove (self);
};

/*
QuakeEd only writes a single float for angles (bad idea), so up and down are
just constant angles.
*/
void ()
SetMovedir =
{
	if (self.angles == '0 -1 0')
		self.movedir = '0 0 1';
	else if (self.angles == '0 -2 0')
		self.movedir = '0 0 -1';
	else
	{
		makevectors (self.angles);
		self.movedir = v_forward;
	}

	self.angles = VEC_ORIGIN;
};

/*
================
InitTrigger
================
*/
void ()
InitTrigger =
{
	// trigger angles are used for one-way touches.  An angle of 0
	// is assumed to mean no restrictions, so use a yaw of 360
	// instead.
	if (self.angles != VEC_ORIGIN)
		SetMovedir ();
	self.solid = SOLID_TRIGGER;
	setmodel (self, self.model);	// set size and link into world
	self.movetype = MOVETYPE_NONE;
	self.modelindex = 0;
	self.model = string_null;
};

/*
=============
SUB_CalcMove

calculate self.velocity and self.nextthink to reach dest from
self.origin traveling at speed
===============
*/
void (entity ent, vector tdest, float tspeed, void () func)
SUB_CalcMoveEnt =
{
local entity	stemp;
	stemp = self;
	self = ent;

	SUB_CalcMove (tdest, tspeed, func);
	self = stemp;
};

void (vector tdest, float tspeed, void () func)
SUB_CalcMove =
{
local vector	vdestdelta;
local float		len, traveltime;

	if (!tspeed)
		objerror ("No speed is defined!");

	self.think1 = func;
	self.finaldest = tdest;
	self.think = SUB_CalcMoveDone;

	if (tdest == self.origin)
	{
		self.velocity = VEC_ORIGIN;
		self.nextthink = self.ltime + sys_ticrate;
		return;
	}

	// set destdelta to the vector needed to move
	vdestdelta = tdest - self.origin;

	// calculate length of vector
	len = vlen (vdestdelta);

	// divide by speed to get time to reach dest
	traveltime = len / tspeed;

	IN_POQ([-
		if (traveltime < sys_ticrate)
		{
			self.velocity = VEC_ORIGIN;
			self.nextthink = self.ltime + sys_ticrate;
			return;
		}
	-], [-
		if (traveltime < 0.03)
			traveltime = 0.03;
	-])

	// set nextthink to trigger a think when dest is reached
	self.nextthink = self.ltime + traveltime;

	// scale the destdelta vector by the time spent traveling to get velocity
	self.velocity = vdestdelta * (1/traveltime);	// qcc won't take vec/float
};

/*
============
After moving, set origin to exact final destination
============
*/
void ()
SUB_CalcMoveDone =
{
	setorigin (self, self.finaldest);
	self.velocity = VEC_ORIGIN;
	self.nextthink = -1;
	if (self.think1)
		self.think1 ();
};

/*
=============
SUB_CalcAngleMove

calculate self.avelocity and self.nextthink to reach destangle from
self.angles rotating

The calling function should make sure self.think is valid
===============
*/
void (entity ent, vector destangle, float tspeed, void () func)
SUB_CalcAngleMoveEnt =
{
local entity		stemp;
	stemp = self;
	self = ent;
	SUB_CalcAngleMove (destangle, tspeed, func);
	self = stemp;
};

void (vector destangle, float tspeed, void () func)
SUB_CalcAngleMove =
{
local vector	destdelta;
local float		len, traveltime;

	if (!tspeed)
		objerror ("No speed is defined!");

	// set destdelta to the vector needed to move
	destdelta = destangle - self.angles;

	// calculate length of vector
	len = vlen (destdelta);

	// divide by speed to get time to reach dest
	traveltime = len / tspeed;

	// set nextthink to trigger a think when dest is reached
	self.nextthink = self.ltime + traveltime;

	// scale the destdelta vector by the time spent traveling to get velocity
	self.avelocity = destdelta * (1 / traveltime);

	self.think1 = func;
	self.finalangle = destangle;
	self.think = SUB_CalcAngleMoveDone;
};

/*
============
After rotating, set angle to exact final angle
============
*/
void ()
SUB_CalcAngleMoveDone =
{
	self.angles = self.finalangle;
	self.avelocity = VEC_ORIGIN;
	self.nextthink = -1;
	if (self.think1)
		self.think1 ();
};

//=============================================================================

void ()
DelayThink =
{
	activator = self.enemy;
	SUB_UseTargets ();
	remove (self);
};

/*
==============================
SUB_UseTargets

the global "activator" should be set to the entity that initiated the firing.

If self.delay is set, a DelayedUse entity will be created that will actually
do the SUB_UseTargets after that many seconds have passed.

Centerprints any self.message to the activator.

Removes all entities with a targetname that match self.killtarget,
and removes them, so some events can remove other triggers.

Search for (string)targetname in all entities that
match (string)self.target and call their .use function

==============================
*/
void ()
SUB_UseTargets =
{
	local entity t, stemp, otemp, act;

	// check for a delay
	if (self.delay)
	{
		// create a temp object to fire at a later time
		t = spawn ();
		t.classname = "DelayedUse";
		t.nextthink = time + self.delay;
		t.think = DelayThink;
		t.enemy = activator;
		t.message = self.message;
		t.killtarget = self.killtarget;
		t.target = self.target;
		return;
	}

	// print the message
	if (activator.classname == "player" && self.message != string_null)
	{
		centerprint (activator, self.message);
		if (!self.noise)
			sound (activator, CHAN_VOICE, "misc/talk.wav", 1, ATTN_NORM);
	}

	// kill the killtagets
	if (self.killtarget)
	{
		t = world;
		do
		{
			t = find (t, targetname, self.killtarget);
			if (!t)
				return;
			remove (t);
		} while (1);
	}

	// fire targets
	if (self.target)
	{
		act = activator;
		t = world;
		do
		{
			t = find (t, targetname, self.target);
			if (!t)
			{
				return;
			}
			stemp = self;
			otemp = other;
			self = t;
			other = stemp;
			if (self.use != SUB_Null)
			{
				if (self.use)
					self.use ();
			}
			self = stemp;
			other = otemp;
			activator = act;
		} while (1);
	}

};

/*

in nightmare mode, all attack_finished times become 0
some monsters refire twice automatically

*/

void (float normal)
SUB_AttackFinished =
{
	self.cnt = 0;		// refire count for nightmare
	if (skill != 3)
		self.attack_finished = time + normal;
};

void (void () thinkst)
SUB_CheckRefire =
{
	if (skill != 3)
		return;
	if (self.cnt == 1)
		return;
	if (!visible (self.enemy))
		return;
	self.cnt = 1;
	self.think = thinkst;
};

void () CDTrack =
{
	
local float sil;
local float nn;

sil = random ();
if (sil <= 0.33)
sil = (rint (random () *24) + 2) * (rint (random () *8) + 2); // short Silence length, 4-36 secs
else if (sil <= 0.66)
sil = (rint (random () *50) + 10) * (rint (random () *16) + 10); // med Silence length, 20-66 secs
else
sil = (rint (random () *60) + 20) * (rint (random () *32) + 20); // long Silence length, 40-92 secs

//if (CD_START == -2)  return; /// no humans so just let it play world sounds for a while


nn = CD_RNTRACK;

while (CD_XTRACK == nn)
nn = rint (random () * 10) + 1; // Pick another if same one we just played

          if (nn == 3 || CD_XTRACK == -1)
          {
          
          
          other = find (world, classname, "player");
	while (other != world)
	{
           
          if (nn == 3 && CD_XTRACK != -1)
          {
          stuffcmd (other, "cd pause\n");
          //sprint (other, " CD PAUSE\n");
           nn = -1;
          }
          else if (CD_XTRACK == -1)
          {
          stuffcmd (other, "cd resume\n");
          //sprint (other, " CD RESUME\n");          
          }

          other = find (other, classname, "player");
	}
         
          }
         

       

	  
//msg_entity = self;
//WriteByte(MSG_ONE, 8);
//WriteByte(MSG_ONE, 2);
// Time of current cd track
//local string sb;
// sb = ftos (gettime (4));
// sb = strzone (sb);
// bprint (sb);
// sb = strunzone (sb);

	local string a,c,d,e,jj,kk,r,tsr,tsb,nl;

	
	tsr ="                   TRACK";
	r = ftos (nn);
	jj = "                         œœCurrent CD Track now playingœœ\n";
nl = "‘\n";
if (nn == 2)
{
tsb = " QUAKE";
tsr ="                                TRACK";
CD_END = time + 308.75;
}

else if ( nn == 4)
{
tsb = " The Hall of Souls";
tsr ="                            TRACK";
CD_END = time + 500;
}

else if ( nn == 5)
{
tsr ="                             TRACK";
tsb = " The Grisly Grotto";
CD_END = time + 365;
}
else if ( nn == 6)
{
tsb = " Parallel Dimensions";	
tsr ="                           TRACK";
CD_END = time + 444;
}
else if ( nn == 7)
{
tsr ="                              TRACK";
tsb = " The Underearth";
CD_END = time + 517;
}
else if ( nn == 8)
{
tsr ="                                 TRACK";
tsb = " Damnation";
CD_END = time + 335.5;
}
else if ( nn == 9)
{
tsr ="                              TRACK";
tsb = " The Necropolis";
CD_END = time + 389;
}
else if ( nn == 10)
{
tsb = " The Ziggurat Vertigo";
tsr ="                          TRACK";
CD_END = time + 212;
}
else if (nn == 11)
{
tsb = " Gloom Keep";
tsr ="                               TRACK";
CD_END = time + 319;
}
else if (nn == -1)
{
tsr ="                                 TRACK";
tsb = " Silence";
CD_END = time + sil;
}


         WriteByte (MSG_ALL,SVC_CDTRACK);
         WriteByte (MSG_ALL,nn);
         WriteByte (MSG_ALL,nn);

CD_END = CD_END + 0.15 + (random () * 0.25); // Slight leader

a = strcat (jj, tsr); //current cd track: track
e = strcat (a, r); //current cd track(newline) track (r)

c = strcat (e,tsb); //current cd track(newline) track (r) (title)
kk = strcat (c,nl); //current cd track(newline) track (r) (title) (newline)


CD_MSG = kk;



CD_XTRACK = nn;  // Current world.sounds , approximate...



};

float(entity head) Blocked =
{
if (head.health < 1 || head.waterlevel > 0) return 0;
local float score;
local vector here;
here = head.origin - '0 0 10';

if (vlen(head.velocity) >= 28) return 0;



   if (head.flags & FL_CLIENT) 
{	



if (pointcontents (here + '18 0 0') == CONTENT_SOLID) 
score = score + 1; // Front at knee level



if (pointcontents (here + '-18 0 0') == CONTENT_SOLID) score = score + 1; // back at knee level

if (pointcontents (here + '18 18 0') == CONTENT_SOLID) 
score = score + 1; // Front side at knee level
if (pointcontents (here + '18 -18 0') == CONTENT_SOLID) 
score = score + 1; // Front side knee level

if (pointcontents (here + '-18 18 0') == CONTENT_SOLID) 
score = score + 1; // back side at knee level
if (pointcontents (here + '-18 -18 0') == CONTENT_SOLID) 
score = score + 1; // back side at knee level

if (pointcontents (here + '0 18 0') == CONTENT_SOLID) 	
score = score + 1; // side at knee level
if (pointcontents (here + '0 -18 0') == CONTENT_SOLID) 
score = score + 1; // side at knee level


}

     
     
	 if (score > 0)
	 {
	 //if (head.button8 && vlen(head.velocity) > 44.5)
	//	  return 0;


		 
	/*	  
	 local string val;
	 val = strcat ("^5Blocked  () SCORE: ", (ftos(score)));
	 val = strcat (val, "^7");
	LogMsg2 (head, val);
	*/
	return 1;
	}
        return FALSE;    // Entity is not in blocked.
};

void () 
LoadBalance = 
{
        
          // Cobalt  - load balance experiment
if (PLAYERS > 1 && time > 10)
{
local float bal, tr;
tr = cvar ("sys_ticrate");
bal = (PLAYERS * 0.00075);

if (tr != (tr - bal))
{
          bal = tr - bal;
          localcmd ("sys_ticrate ");
          localcmd ((ftos(bal)));
          localcmd ("\n");
          bprint ("Server Framerate set to ");
          bal = 1 / bal;
          bprint (ftos(fabs(bal)));
          bprint (" FPS\n");
}
}
else if (cvar ("sys_ticrate") != 0.0375)
{
localcmd ("sys_ticrate ");
         localcmd ((ftos(0.0375)));
         localcmd ("\n");        
}  
     

  sys_ticrate = frametime;        
};