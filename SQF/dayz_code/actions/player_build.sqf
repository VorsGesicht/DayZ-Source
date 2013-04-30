private ["_alt1", "_alt2", "_item", "_classname", "_require", "_text", "_booleans", "_worldspace", "_dir", "_location", "_dis", "_sfx", "_object"];

call gear_ui_init;

_item = _this;
_classname = getText (configFile >> "CfgMagazines" >> _item >> "ItemActions" >> "Build" >> "create");
_require = getText (configFile >> "CfgMagazines" >> _item >> "ItemActions" >> "Build" >> "require");
_text =  getText (configFile >> "CfgVehicles" >> _classname >> "displayName");

// item is missing or tools are missing
if ((!(_require IN items player)) OR {(!(_item IN magazines player))}) exitWith {
	cutText [format[(localize "str_player_31"),_text,(localize "str_player_31_build")] , "PLAIN DOWN"];
	diag_log(format["player_build: item:%1 require:%2  Player items:%3  magazines:%4", _item, _require, (items player), (magazines player)]);
};

_booleans = []; //testonLadder, testSea, testPond, testBuilding, testSlope, testDistance
_worldspace = [_classname, player, _booleans] call fn_niceSpot;
diag_log(format["player_build: booleans: %1 worldspace:%2", _booleans, _worldspace]);

// player on ladder or in a vehicle
if (_booleans select 0) exitWith { cutText [localize "str_player_21", "PLAIN DOWN"]; };

// object would be in the water (pool or sea)
//if ((_booleans select 1) OR (_booleans select 2)) exitWith { cutText [localize "str_player_26", "PLAIN DOWN"]; };

if ((count _worldspace) == 2) then {
	_dir = _worldspace select 0;
	_location = _worldspace select 1; 
	
	player playActionNow "Medic";
	sleep 1;
	// installed item location may not be in front of player (but in 99% time it should)
	player setDir _dir;
	player setPosATL (getPosATL player);
	
	_dis=20;
	_sfx = "repair";
	[player,_sfx,0,false,_dis] call dayz_zombieSpeak;  
	[player,_dis,true,(getPosATL player)] spawn player_alertZombies;
	
	sleep 5;
		
	_object = createVehicle [_classname, getMarkerpos "respawn_west", [], 0, "CAN_COLLIDE"];
	_object setDir _dir;
	// the following is a trick to sink the object in the bottom of the sea/pond while following the terrain slope:
	_object setPosATL _location;
	_alt2 = getPosASL _object;
	_object setPos _location;
	_alt1 = getPosASL _object;
	if (alt2 < alt1) then {
		_location set [2, alt2 - alt1];
		_object setPos _location;
	};
	player reveal _object;

	dayzPublishObj = [dayz_characterID,_object,[_dir,_location],_classname];
	publicVariable "dayzPublishObj";	
	
	cutText [format[localize "str_build_01",_text], "PLAIN DOWN"];
} else {
	cutText [format[localize "str_build_failed_01",_text], "PLAIN DOWN"];
};
