--define the class
ACF_DefineRackClass("RK", {
	spread = 1,
	name = "Munitions Rack",
	desc = "A lightweight rack for rockets and bombs which is vulnerable to shots and explosions.",
	muzzleflash = "40mm_muzzleflash_noscale",
	rofmod = 1,
	sound = "acf_extra/airfx/rocket_fire2.wav",
	soundDistance = " ",
	soundNormal = " ",
    
    reloadmul       = 8,
} )




--add a gun to the class
ACF_DefineRack("1xRK", {
	name = "Single Munitions Rack",
	desc = "A lightweight rack for rockets and bombs which is vulnerable to shots and explosions.",
	model		= "models/missiles/rack_single.mdl",
	gunclass = "RK",
	weight = 100,
	rofmod = 2.2,
	year = 1915,
    magsize = 1,
	sound = "acf_extra/airfx/rocket_fire2.wav",

    mountpoints = 
	{
		["missile1"] = {["offset"] = Vector(0, 0, 3),	["scaledir"] = Vector(0, 0, -1)}
	}
} )




ACF_DefineRack("2xRK", {
	name = "Dual Munitions Rack",
	desc = "A lightweight rack for rockets and bombs which is vulnerable to shots and explosions.",
	model		= "models/missiles/rack_double.mdl",
	gunclass = "RK",
	weight = 150,
	year = 1915,
    magsize = 2,
	sound = "acf_extra/airfx/rocket_fire2.wav",

    mountpoints = 
	{
		["missile1"] = {["offset"] = Vector(4, -1.5, -1.7),	["scaledir"] = Vector(0, -1, 0)},
		["missile2"] = {["offset"] = Vector(4, 1.5, -1.7),	["scaledir"] = Vector(0, 1, 0)}
	}
} )


ACF_DefineRack("3xRK", {
	name = "BRU-42 Rack",
	desc = "A lightweight rack for bombs which is vulnerable to shots and explosions.",
	model		= "models/missiles/bomb_3xrk.mdl",
	gunclass = "RK",
	weight = 200,
	year = 1936,
    magsize = 3,

    mountpoints = 
	{
		["missile1"] = {["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,0,-1)},
		["missile2"] = {["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,1,0)},
		["missile3"] = {["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,-1,0)},
	}
} )


ACF_DefineRack("4xRK", {
	name = "Quad Munitions Rack",
	desc = "A lightweight rack for rockets and bombs which is vulnerable to shots and explosions.",
	model		= "models/missiles/rack_quad.mdl",
	gunclass = "RK",
	weight = 200,
	year = 1936,
    magsize = 4,

    mountpoints = 
	{
		["missile1"] = {["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,1,0)},
		["missile2"] = {["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,-1,0)},
		["missile3"] = {["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,0,-1)},
		["missile4"] = {["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,0,-1)}
	}
} )

ACF_DefineRack("2x AGM-114", {
	name = "Dual Munitions AGM-114 Rack",
	desc = "An AGM-114 rack designed to carry 2 missiles.",
	model		= "models/missiles/agm_114_2xrk.mdl",
	gunclass = "RK",
	weight = 152,
	year = 1984,
    magsize = 2,
	caliber = 16,

    mountpoints = 
	{
		["missile1"] = {["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,0,-1)},
		["missile2"] = {["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,0,-1)},
	}
} )

ACF_DefineRack("4x AGM-114", {
	name = "Quad Munitions AGM-114 Rack",
	desc = "An AGM-114 rack designed to carry 4 missiles.",
	model		= "models/missiles/agm_114_4xrk.mdl",
	gunclass = "RK",
	weight = 220,
	year = 1984,
    magsize = 4,
	caliber = 16,

    mountpoints = 
	{
		["missile1"] = {["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,0,-1)},
		["missile2"] = {["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,0,-1)},
		["missile3"] = {["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,0,-1)},
		["missile4"] = {["offset"] = Vector(0,0,0), ["scaledir"] = Vector(0,0,-1)}
	}
} )

