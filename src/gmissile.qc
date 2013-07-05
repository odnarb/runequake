/*
    Copyright (C) 2013  David 'Slot Zero' Roberts.

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

void (entity e)
restore_gmissile_owner =
{
	local entity os;

	if (!e.rqstate & RQS_GUIDED_MISSILE)
		return;

	os = self;
	self = e;

	// restore your viewport and remove flags
	set_viewport (self);
	self.rqstate = self.rqstate - self.rqstate & RQS_GUIDED_MISSILE;
	self.effects = self.effects - self.effects & EF_FROZEN;

	// reset player view
	self.view_ofs = PLAYER_VIEW_OFFSET;

	// only update these if you're alive
	if (self != os)
	{
		// restore model
		W_SetCurrentAmmo (1);

		// prevent firing immediately after explosion
		self.attack_finished = time + 0.25;

		// reset your angle
		/*if (os.delay < time)
		{
			self.angles = os.oldrunevector;
			self.fixangle = 1;
		}*/
	}

	self = os;
};

void ()
gmissile_think =
{
	// more than likely you are dead, so explode
	if (!self.owner.rqstate & RQS_GUIDED_MISSILE || !self.owner.cl[CL_ACTIVE])
	{
		create_te_explosion (self.origin, 1);
		return;
	}

	if (intermission_running)
	{
		restore_gmissile_owner (self.owner);
		return;
	}

	// update missile direction
	makevectors (self.owner.v_angle);
	self.velocity		= v_forward * 350;
	self.angles		= vectoangles (self.velocity);

	// remove ammo, explode if none
	if (self.oldrunetime < time)
	{
		if (self.owner.ammo_rockets >= 1)
			self.owner.ammo_rockets = self.owner.ammo_rockets - 1;
		else
		{
			restore_gmissile_owner (self.owner);
			create_te_explosion (self.origin, 1);
			return;
		}
		self.oldrunetime = time + 1;
	}

	// lock player down only when he's on ground
	if (self.owner.flags & FL_ONGROUND && !self.owner.effects & EF_FROZEN)
		self.owner.effects = self.owner.effects | EF_FROZEN;

	// don't show weapon model
	self.owner.weaponmodel = string_null;

	self.nextthink = time + sys_ticrate;
};

void ()
W_FireGuidedMissile =
{
	newmis.nextthink	= time;
	newmis.think		= gmissile_think;

	// don't explode right away if low ammo
	newmis.oldrunetime		= time + 2;

	// set your view to missiles and set flags
	set_viewport (newmis);
	self.rqstate		= self.rqstate | RQS_GUIDED_MISSILE;

	// spawn a rocket hat
	Hat_Spawn (self, "progs/missile.mdl", '-4 1 32', VEC_ORIGIN, 16);

	// center view on rocket, reduces PVS stickyness.
	self.view_ofs		= VEC_ORIGIN;
};