


void (vector org, float perm,float spr) SpawnTempDebugMarker =
{
	
if (!(cvar ("developer"))) return;
local entity st;

st = spawn ();

//dprint ("Spawning marker for Edict No. ");
		//dprint (ftos(num_for_edict(self)));
		//dprint ("\n");
st.classname = "TEMP_DEBUG_MARKER";

st.origin = org;
setorigin (st, org);
st.solid = SOLID_NOT;
st.movetype = MOVETYPE_NONE;
if (!spr)
setmodel (st, "progs/s_bubble.spr");
else
setmodel (st, "progs/s_light.spr");
setsize (st, '0 0 0', '0 0 0');
if (perm == -1) 
{
st.classname = "PERM_DEBUG_MARKER";	
return;
}

st.think = SUB_Remove;
st.nextthink = time + perm;

};


//==========================================================================
//  check.qc -- by Patrick Martin               Last updated:  9-8-1997
//--------------------------------------------------------------------------
//  This file contains code that determines whether an entity or a
//  location is inside the various contents found in Quake.
//==========================================================================
float(entity dh_player) dh_shambler_test =
{
          
        
	// pass this function an entity with absmin/absmax being the box you want to test to see if it's safe to spawn a shambler
	// returns:
	//	1(true)  if safe   to spawn shambler because no obstacles were found
	//	0(false) if unsafe to spawn shambler because obstacles found

	// this can be adapted later to a shambler's size based on the player's position
	// dhmin/dhmax will be the 2 vector points that the traceline will cover through interations

	local vector dhmin,dhmax;
	local float i,d,za;

	d=1;  // set this to 1 for debug bubbles, or 0 for off
	      // note that on my system, not all the bubbles spawned at once
	      // some showed after the first set vanished, but this does
	      // not seem to hinder detection

	// test logic is 6 x "square plane" "line radar" sweeps (6 sides of a cubic region)
	// names of faces are correct when player aiming angle is (0 0 0)
	// 1 : "bottom" (min_x, min_y, min_z) to (max_x, min_y, min_z) where both Y values increment from min_y to max_y
	// 2 : "right"  (min_x, min_y, min_z) to (max_x, min_y, min_z) where both Z values increment from min_z to max_z
	// 3 : "top"    (min_x, min_y, max_z) to (max_x, min_y, max_z) where both Y values increment from min_y to max_y
	// 4 : "left"   (min_x, max_y, min_z) to (max_x, max_y, min_z) where both Z values increment from min_z to max_z
	// 5 : "back"   (min_x, min_y, min_z) to (min_x, max_y, min_z) where both Z values increment from min_z to max_z
	// 6 : "front"  (max_x, min_y, min_z) to (max_x, max_y, min_z) where both Z values increment from min_z to max_z

	// first of all, we should increase the Z values slightly so that our test doesn't bomb out impacting the floor
	// note that we should remove this adjustment if the existing shambler code already accounts for it
	za=4;  // add this value to both absmin_z and absmax_z
	dh_player.absmin_z = dh_player.absmin_z + za;
	dh_player.absmax_z = dh_player.absmax_z + za;

	i=4;  // set incremental resolution scale value of our trace lines to this number of units

	// 1 : "bottom"
	dhmin_x = dh_player.absmin_x;
	dhmin_y = dh_player.absmin_y;
	dhmin_z = dh_player.absmin_z;
	dhmax_x = dh_player.absmax_x;
	dhmax_y = dh_player.absmin_y;
	dhmax_z = dh_player.absmin_z;
	while (dhmin_y < dh_player.absmax_y ) {
		if (d) { SpawnTempDebugMarker(dhmin,20,0); SpawnTempDebugMarker(dhmax,20,0); }
		traceline (dhmin, dhmax, 0, dh_player.enemy);
                    bprint (ftos(trace_fraction);
                    bprint ("\n");
		if (trace_fraction < 1) return 0;
		dhmin_y = dhmin_y + i;
		dhmax_y = dhmax_y + i;
	}
          return 1;
	// 2 : "right"
	dhmin_x = dh_player.absmin_x;
	dhmin_y = dh_player.absmin_y;
	dhmin_z = dh_player.absmin_z;
	dhmax_x = dh_player.absmax_x;
	dhmax_y = dh_player.absmin_y;
	dhmax_z = dh_player.absmin_z;
	while (dhmin_z < dh_player.absmax_z ) {
		if (d) { SpawnTempDebugMarker(dhmin,20,0); SpawnTempDebugMarker(dhmax,20,0); }
		traceline (dhmin, dhmax, 0, dh_player.enemy);
		if (trace_fraction < 1) return 0;
		dhmin_z = dhmin_z + i;
		dhmax_z = dhmax_z + i;
	}

	// 3 : "top"
	dhmin_x = dh_player.absmin_x;
	dhmin_y = dh_player.absmin_y;
	dhmin_z = dh_player.absmax_z;
	dhmax_x = dh_player.absmax_x;
	dhmax_y = dh_player.absmin_y;
	dhmax_z = dh_player.absmax_z;
	while (dhmin_y < dh_player.absmax_y ) {
		if (d) { SpawnTempDebugMarker(dhmin,20,0); SpawnTempDebugMarker(dhmax,20,0); }
		traceline (dhmin, dhmax, 0, dh_player.enemy);
		if (trace_fraction < 1) return 0;
		dhmin_y = dhmin_y + i;
		dhmax_y = dhmax_y + i;
	}

	// 4 : "left"
	dhmin_x = dh_player.absmin_x;
	dhmin_y = dh_player.absmax_y;
	dhmin_z = dh_player.absmin_z;
	dhmax_x = dh_player.absmax_x;
	dhmax_y = dh_player.absmax_y;
	dhmax_z = dh_player.absmin_z;
	while (dhmin_z < dh_player.absmax_z ) {
		if (d) { SpawnTempDebugMarker(dhmin,20,0); SpawnTempDebugMarker(dhmax,20,0); }
		traceline (dhmin, dhmax, 0, dh_player.enemy);
		if (trace_fraction < 1) return 0;
		dhmin_z = dhmin_z + i;
		dhmax_z = dhmax_z + i;
	}

	// To avoid hitting a debug bubble drawing the last 2 sides and then returning, shift the original vectors slightly to compensate :)
	// this is not needed if we are not drawing bubbles :)
	if (d) { dh_player.absmin_z = dh_player.absmin_z + 4; dh_player.absmax_z = dh_player.absmax_z + 4; }

	// 5 : "back"
	dhmin_x = dh_player.absmin_x;
	dhmin_y = dh_player.absmin_y;
	dhmin_z = dh_player.absmin_z;
	dhmax_x = dh_player.absmin_x;
	dhmax_y = dh_player.absmax_y;
	dhmax_z = dh_player.absmin_z;
	while (dhmin_z < dh_player.absmax_z ) {
		if (d) { SpawnTempDebugMarker(dhmin,20,0); SpawnTempDebugMarker(dhmax,20,0); }
		traceline (dhmin, dhmax, 0, dh_player.enemy);
		if (trace_fraction < 1) return 0;
		dhmin_z = dhmin_z + i;
		dhmax_z = dhmax_z + i;
	}

	// 6 : "front"
	dhmin_x = dh_player.absmax_x;
	dhmin_y = dh_player.absmin_y;
	dhmin_z = dh_player.absmin_z;
	dhmax_x = dh_player.absmax_x;
	dhmax_y = dh_player.absmax_y;
	dhmax_z = dh_player.absmin_z;
	while (dhmin_z < dh_player.absmax_z ) {
		if (d) { SpawnTempDebugMarker(dhmin,20,0); SpawnTempDebugMarker(dhmax,20,0); }
		traceline (dhmin, dhmax, 0, dh_player.enemy);
		if (trace_fraction < 1) return 0;
		dhmin_z = dhmin_z + i;
		dhmax_z = dhmax_z + i;
	}

	return 1;
};



//-------------------------------------------------------- New Code --------
//  Modified by Cobalt: This performs a "+" shaped set of tracelines on the bounding box sides and
//  a "x" shaped set of tracelines on its 4 corners , and also another "x" pattern on the sides
//  in an attempt to determine if the entities bounding box is not inside a solid.
//--------------------------------------------------------------------------
float(entity field) TraceCheck6 =
{
if (pointcontents (field.origin) == CONTENT_SOLID)
          return 0;

local vector cornermn,cornermx,cornermn1,cornermx1,start,end;

           cornermn = field.absmin;
           cornermx = field.absmax;
           
           // lower left corner is mn1
	 cornermn1 = cornermn;
	 cornermn1_x = cornermx_x;
           
           // upper rt corner is mx1
	 cornermx1 = cornermx;
	 cornermx1_x = cornermn_x; 
           
           local entity ref;
           ref = find (world, classname, "info_player_deathmatch"); // Dummy ent so trace_ent dont start off as world

           trace_ent = ref;
           traceline (cornermn, cornermx, 0, field.enemy); // Check min and max, 1st part of "X" pattern
           if (trace_fraction == 1) // Setup scan on opposite corners, complete the X pattern
           {
            SpawnTempDebugMarker (cornermn, 0.5, 0);
            SpawnTempDebugMarker (cornermx, 0.5, 0);
            
           traceline (cornermn1, cornermx1, 0, field.enemy);
           if (trace_fraction == 1) // X scan completed, start on plus type scan           
           {
            SpawnTempDebugMarker (cornermn1, 0.5, 0);
            SpawnTempDebugMarker (cornermx1, 0.5, 0);
            start = end = field.origin;
            start_x = cornermx_x;
            end_x = cornermn_x;            
           traceline(start, end, 0, field.enemy);
           if (trace_fraction == 1) // Xpart of plus scan completed, start on y part
           {
            SpawnTempDebugMarker (start, 0.5, 0);
            SpawnTempDebugMarker (end, 0.5, 0);
           start = end = field.origin;
            start_y = cornermn_y;
            end_y = cornermx_y;  
               traceline(start, end, 0, field.enemy);
              if (trace_fraction == 1) // entire plus scan completed ok, start on plus shaped sides scan
              {
                  SpawnTempDebugMarker (start, 0.5, 0);
                  SpawnTempDebugMarker (end, 0.5, 0);
            start_z = cornermn_z;
            start_x = field.origin_x;
            start_y = cornermn_y;
            
            end_z = cornermx_z;
            end_x = field.origin_x;
            end_y = cornermx_y;         
            
            
                        
             traceline(start, end, 0, field.enemy);
            if (trace_fraction == 1) // back side to front side ok, do side to side check
            {
                  SpawnTempDebugMarker (start, 0.5, 0);
                  SpawnTempDebugMarker (end, 0.5, 0);
                  
                   start_z = cornermn_z;
                   start_y = field.origin_y;
                   start_x = cornermn_x;
            
                  end_z = cornermx_z;
                  end_y = field.origin_y;
                  end_x = cornermx_x;
                   traceline(start, end, 0, field.enemy);
              if (trace_fraction == 1) // entire 6 segments of scan completed do one more from max top to max bottom
              {
               SpawnTempDebugMarker (start, 0.5, 0);
                  SpawnTempDebugMarker (end, 0.5, 0);
                 start = end = field.origin;
                 start_z = cornermx_z;
                 end_z = cornermn_z;
                 traceline(start, end, 0, field.enemy);
                    if (trace_fraction == 1)
                    {
                    
                      SpawnTempDebugMarker (start, 0.5, 0);
                      SpawnTempDebugMarker (end, 0.5, 0);
                    return 1;
                  
                    }
              }
                  
                  
            }
            
            
              }
            
           }
                     
           }
                     
                     
           }
           // SpawnTempDebugMarker (trace_endpos, 0.5, 1);
           bprint (trace_ent.classname);
           bprint ("\n");

          
          return 0;


};

//-------------------------------------------------------- New Code --------
//  This checks if a bbox is inside a wall or sky.  The bbox's origin
//  and corners are checked.  If any one points is within a solid or sky,
//  TRUE is returned.
//--------------------------------------------------------------------------
float(entity head, vector spot) PM_InWall =
{
        local   vector  p;

// Check origin.
        p = spot;
        if (pointcontents(p) == CONTENT_SOLID)  return TRUE;
        if (pointcontents(p) == CONTENT_SKY)    return TRUE;

// Check bbox faces.
// Order:  1)-00  2)+00  3)0-0  4)0+0  5)00-  6)00+
        p_x = spot_x + head.mins_x; // back
        if (pointcontents(p) == CONTENT_SOLID)  return TRUE;
        if (pointcontents(p) == CONTENT_SKY)    return TRUE;

        p_x = spot_x + head.maxs_x; // front
        if (pointcontents(p) == CONTENT_SOLID)  return TRUE;
        if (pointcontents(p) == CONTENT_SKY)    return TRUE;

        p = spot;
        p_y = spot_y + head.mins_y; // left
        if (pointcontents(p) == CONTENT_SOLID)  return TRUE;
        if (pointcontents(p) == CONTENT_SKY)    return TRUE;

        p_y = spot_y + head.maxs_y; // right
        if (pointcontents(p) == CONTENT_SOLID)  return TRUE;
        if (pointcontents(p) == CONTENT_SKY)    return TRUE;

        p = spot;
        p_z = spot_z + head.mins_z; // bottom
        if (pointcontents(p) == CONTENT_SOLID)  return TRUE;
        if (pointcontents(p) == CONTENT_SKY)    return TRUE;

        p_z = spot_z + head.maxs_z; // top
        if (pointcontents(p) == CONTENT_SOLID)  return TRUE;
        if (pointcontents(p) == CONTENT_SKY)    return TRUE;

// Check bbox corners.


//       1)+++  Upper max corner
        p_x = spot_x + head.maxs_x;
        p_y = spot_y + head.maxs_y;
        if (pointcontents(p) == CONTENT_SOLID)  return TRUE;
        if (pointcontents(p) == CONTENT_SKY)    return TRUE;

	 // 2)-++ 
        p_x = spot_x + head.mins_x;
        if (pointcontents(p) == CONTENT_SOLID)  return TRUE;
        if (pointcontents(p) == CONTENT_SKY)    return TRUE;

	 // 3)+-+
        p_x = spot_x + head.maxs_x;
        p_y = spot_y + head.mins_y;
        if (pointcontents(p) == CONTENT_SOLID)  return TRUE;
        if (pointcontents(p) == CONTENT_SKY)    return TRUE;

	 
	 // 4)--+ 
        p_x = spot_x + head.mins_x;
        if (pointcontents(p) == CONTENT_SOLID)  return TRUE;
        if (pointcontents(p) == CONTENT_SKY)    return TRUE;

	 
	 // 5)++- 
        p_x = spot_x + head.maxs_x;
        p_y = spot_y + head.maxs_y;
        p_z = spot_z + head.mins_z;
        if (pointcontents(p) == CONTENT_SOLID)  return TRUE;
        if (pointcontents(p) == CONTENT_SKY)    return TRUE;

	 // 6)-+-
        p_x = spot_x + head.mins_x;
        if (pointcontents(p) == CONTENT_SOLID)  return TRUE;
        if (pointcontents(p) == CONTENT_SKY)    return TRUE;

	 // 7)+--
        p_x = spot_x + head.maxs_x;
        p_y = spot_y + head.mins_y;
        if (pointcontents(p) == CONTENT_SOLID)  return TRUE;
        if (pointcontents(p) == CONTENT_SKY)    return TRUE;

	 // 8)---  Lower min corner
        p_x = spot_x + head.mins_x;
        if (pointcontents(p) == CONTENT_SOLID)  return TRUE;
        return (pointcontents(p) == CONTENT_SKY);
};

//-------------------------------------------------------- New Code --------
//  This is a variation of InWall.  The bbox is checked if it is a
//  empty air; that is not inside solid, water, or anything else.
//  If any one point is within a brush, FALSE is returned.
//--------------------------------------------------------------------------
float(entity head, vector spot) PM_InEmpty =
{
        local   vector  p;

// Check origin.
        p = spot;
        if (pointcontents(p) != CONTENT_EMPTY)  return FALSE;

// Check bbox faces.
// Order:  1)-00  2)+00  3)0-0  4)0+0  5)00-  6)00+
        p_x = spot_x + head.mins_x;
        if (pointcontents(p) != CONTENT_EMPTY)  return FALSE;

        p_x = spot_x + head.maxs_x;
        if (pointcontents(p) != CONTENT_EMPTY)  return FALSE;

        p = spot;
        p_y = spot_y + head.mins_y;
        if (pointcontents(p) != CONTENT_EMPTY)  return FALSE;

        p_y = spot_y + head.maxs_y;
        if (pointcontents(p) != CONTENT_EMPTY)  return FALSE;

        p = spot;
        p_z = spot_z + head.mins_z;
        if (pointcontents(p) != CONTENT_EMPTY)  return FALSE;

        p_z = spot_z + head.maxs_z;
        if (pointcontents(p) != CONTENT_EMPTY)  return FALSE;

// Check bbox corners.
// Order:  1)+++  2)-++  3)+-+  4)--+  5)++-  6)-+-  7)+--  8)---
        p_x = spot_x + head.maxs_x;
        p_y = spot_y + head.maxs_y;
        if (pointcontents(p) != CONTENT_EMPTY)  return FALSE;

        p_x = spot_x + head.mins_x;
        if (pointcontents(p) != CONTENT_EMPTY)  return FALSE;

        p_x = spot_x + head.maxs_x;
        p_y = spot_y + head.mins_y;
        if (pointcontents(p) != CONTENT_EMPTY)  return FALSE;

        p_x = spot_x + head.mins_x;
        if (pointcontents(p) != CONTENT_EMPTY)  return FALSE;

        p_x = spot_x + head.maxs_x;
        p_y = spot_y + head.maxs_y;
        p_z = spot_z + head.mins_z;
        if (pointcontents(p) != CONTENT_EMPTY)  return FALSE;

        p_x = spot_x + head.mins_x;
        if (pointcontents(p) != CONTENT_EMPTY)  return FALSE;

        p_x = spot_x + head.maxs_x;
        p_y = spot_y + head.mins_y;
        if (pointcontents(p) != CONTENT_EMPTY)  return FALSE;

        p_x = spot_x + head.mins_x;
        return (pointcontents(p) == CONTENT_EMPTY);
};

//-------------------------------------------------------- New Code --------
//  This checks if the entity is in a body of liquid.
//--------------------------------------------------------------------------
float(entity head) PM_InLiquid =
{
local float score;
local vector here;
here = head.origin;
   if (head.flags & FL_CLIENT) // Cobalt added for players and bots
{	

	 here_z = here_z - 20; // right at players feet
if (pointcontents (head.absmax - '0 0 56') == CONTENT_WATER) score = score + 1;
if (pointcontents (head.absmax - '0 0 56') == CONTENT_SLIME) score = score + 1;
if (pointcontents (head.absmax - '0 0 56') == CONTENT_LAVA) score = score + 1;

if (pointcontents (head.absmax - '0 32 56') == CONTENT_WATER) score = score + 1;
if (pointcontents (head.absmax - '0 32 56') == CONTENT_SLIME) score = score + 1;
if (pointcontents (head.absmax - '0 32 56') == CONTENT_LAVA) score = score + 1;

if (pointcontents (head.absmin - '0 -32 0') == CONTENT_WATER) score = score + 1;
if (pointcontents (head.absmin - '0 -32 0') == CONTENT_SLIME) score = score + 1;
if (pointcontents (head.absmin - '0 -32 0') == CONTENT_LAVA) score = score + 1;
}

     
        if (pointcontents(here) == CONTENT_WATER)  score = score + 1;
        if (pointcontents(here) == CONTENT_SLIME)  score = score + 1;
        if (pointcontents(here) == CONTENT_LAVA)   score = score + 1;
	 
	  if (pointcontents(head.absmin) == CONTENT_WATER)  score = score + 1;
        if (pointcontents(head.absmin) == CONTENT_SLIME)  score = score + 1;
        if (pointcontents(head.absmin) == CONTENT_LAVA)   score = score + 1;
	 
	  if (pointcontents(head.absmax) == CONTENT_WATER)  score = score + 1;
        if (pointcontents(head.absmax) == CONTENT_SLIME)  score = score + 1;
        if (pointcontents(head.absmax) == CONTENT_LAVA)   score = score + 1;

	 if (score) return 1;
	
        return FALSE;    // Entity is not in liquid.
};




//--------------------------------------------------------------------------
//  END OF LINE.
//--------------------------------------------------------------------------








