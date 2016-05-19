


void (vector org, float perm,float eff) SpawnTempDebugMarker =
{
	
if (!(cvar ("developer"))) return;
local entity st;

st = spawn ();

//dprint ("Spawning marker for Edict No. ");
		//dprint (ftos(num_for_edict(self)));
		//dprint ("\n");
st.classname = "TEMP_DEBUG_MARKER";
st.effects = eff;
st.origin = org;
setorigin (st, org);
st.solid = SOLID_NOT;
st.movetype = MOVETYPE_NONE;
//st.mdl = self.mdl;
setmodel (st, "progs/s_bubble.spr");
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

//-------------------------------------------------------- New Code --------
//  Modified by Cobalt: This performs a "+" shaped set of tracelines and
// an "X" shaped set of tracelines, in an attempt to determine if the entities bounding 
//box is not inside a solid.
//--------------------------------------------------------------------------
float(entity field) TraceCheck4 =
{

local vector corner1,corner2,corner3,corner4,side1,side2,side3,side4,start,end;

           corner1 = field.absmin;
	 corner2 = field.absmax;
           local entity ref;
           ref = find (world, classname, "info_player_deathmatch"); // Dummy ent so trace_ent dont start off as world

           trace_ent = ref;
           traceline (corner1, corner2, 0, field.aiment); // Check min and max, 1st part of "X" pattern
           if (trace_ent == ref) // Setup scan on opposite corners, complete the X pattern
           {
           SpawnTempDebugMarker (corner1, 0.5, 0);
           SpawnTempDebugMarker corner2, 0.5, 0);
           corner2_z = corner1_z;
	 corner3 = corner1;
	 corner3_x = corner2_x;
	 corner4 = corner2;
	 corner4_x = corner1_x;  
           traceline (corner3, corner4, 0, field.aiment);
           if (trace_ent == ref) // X scan completed, start on plus type scan           
           {
            SpawnTempDebugMarker (corner3, 0.5, 0);
            SpawnTempDebugMarker (corner4, 0.5, 0);
            start = end = field.origin;
            start_x = corner1_x;
            end_x = corner2_x;            
           traceline(start, end, 0, field.aiment);
           if (trace_ent == ref) // Xpart of plus scan completed, start on y part
           {
            SpawnTempDebugMarker (start, 0.5, 0);
            SpawnTempDebugMarker (end, 0.5, 0);
           start = end = field.origin;
            start_y = corner1_y;
            end_y = corner2_y;  
               traceline(start, end, 0, field.aiment);
              if (trace_ent == ref) // entire scan completed ok
              {
              SpawnTempDebugMarker (start, 0.5, 0);
            SpawnTempDebugMarker (end, 0.5, 0);
              return 1;
              }
            
           }
                     
           }
                     
                     
           }
           // Back side center
           side1_z = field.absmin_z;
           side1_y = field.origin_y;
           side1_x = field.absmin_x;
           
           
           
           
           // top side center
           side2_z = field.absmax_z;
           side2_y = field.origin_y;
           side2_x = field.absmax_x;
           
           
           
           // bottom side center
           side3_z = field.absmin_z;
           side3_y = field.absmax_y;
           side3_x = field.origin_x;
           
           // top side center
           side3_z = field.absmax_z;
           side3_x = field.origin_x;
           side3_y = field.absmin_y;
          
          
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








