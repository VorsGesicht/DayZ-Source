
private ["_refObj",  "_listTalk",  "_pHeight",  "_attacked",  "_multiplier",  "_type",  "_dist",  "_chance",  "_last",  "_targets",  "_cantSee",  "_tPos",  "_zPos",  "_eyeDir",  "_inAngle",  "_lowBlood",  "_attackResult", "_near"];

_refObj = vehicle player;
_listTalk = (position _refObj) nearEntities ["zZombie_Base", 200];
_pHeight = (getPosATL _refObj) select 2;
_attacked = false; // at least 1 Z attacked the player
_near = false;
_multiplier = 1;

{

	_type = "zombie";
	if (alive _x) then {
		private["_dist"];
		_dist = (_x distance _refObj);
		_group = _x;
		_chance = 20 / dayz_monitorPeriod; // Z verbosity
		if ((_x distance player < dayz_areaAffect) and !(animationState _x == "ZombieFeed")) then {
			[_x,"attack",(_chance),true] call dayz_zombieSpeak;
			//perform an attack
			_last = _x getVariable["lastAttack",0];
			_entHeight = (getPosATL _x) select 2;
			_delta = _pHeight - _entHeight;
			if ( ((time - _last) > 1) and ((_delta < 1.5) and (_delta > -1.5)) ) then {
				//_isZInside = [_x,_building] call fnc_isInsideBuilding;
				//if ((_isPlayerInside and _isZInside) or (!_isPlayerInside and !_isZInside)) then {
					[_x,  _type] call player_zombieAttack;
					_x setVariable["lastAttack",time];
				//};
			};
			_attacked = true;
		} else {
			if (speed _x < 4) then {
				[_x,"idle",(_chance + 4),true] call dayz_zombieSpeak;
			} else {
				[_x,"chase",(_chance + 3),true] call dayz_zombieSpeak;
			};
		};
		
		//Noise Activation
		_targets = _group getVariable ["targets", []];
		if (!(_refObj in _targets)) then {
			if (_dist < DAYZ_disAudial) then {
				if (DAYZ_disAudial > 65) then { //65
					_targets set [count _targets,  driver _refObj];
					_group setVariable ["targets", _targets];				
				} else {
					_chance = [_x, _dist, DAYZ_disAudial] call dayz_losChance;
					//diag_log ("Visual Detection: " + str([_x, _dist]) + " " + str(_chance));
					if ((random 1) < _chance) then {
						_cantSee = [ _refObj,_x] call dayz_losCheck;
						if (!_cantSee) then {
							_targets set [count _targets,  driver _refObj];
							_group setVariable ["targets", _targets];
						} else {
							if (_dist < (DAYZ_disAudial / 2)) then {
								_targets set [count _targets,  driver _refObj];
								_group setVariable ["targets", _targets];
							};
						};
					};
				};
			};
		};
		//Sight Activation
		_targets = _group getVariable ["targets", []];
		if (_dist < 100) then {
			if (!(_refObj in _targets)) then {
				if (_dist < (DAYZ_disVisual / 2)) then {
					_chance = [_x, _dist, DAYZ_disVisual] call dayz_losChance;
					//diag_log ("Visual Detection: m" + str([_x, _dist]) + " " + str(_chance));
					if ((random 1) < _chance) then {
						//diag_log ("Chance Detection");
						_tPos = (getPosASL _refObj);
						_zPos = (getPosASL _x);
						//_eyeDir = _x call dayz_eyeDir;
						_eyeDir = direction _x;
						_inAngle = [_zPos, _eyeDir, 90, _tPos] call fnc_inAngleSector;
						if (_inAngle) then {
							//LOS check
							_cantSee = [ _refObj, _x] call dayz_losCheck;
							//diag_log ("LOS Check: " + str(_cantSee));
							if (!_cantSee) then {
								//diag_log ("Within LOS! Target");
								_targets set [count _targets,  driver _refObj];
								_group setVariable ["targets", _targets];
							};
						};
					};
				};
			};
		};	
	};
} forEach _listTalk;



if (_attacked) then {
	if (r_player_unconscious) then {
		[_refObj, "scream", 3, false] call dayz_zombieSpeak;
	} else {
		_lowBlood = (r_player_blood / r_player_bloodTotal) < 0.5;
		if (_lowBlood) then {
			dayz_panicCooldown = time;
			[_refObj, "panic", 3, false] call dayz_zombieSpeak;
		};
	};
};

// return true if attacked or near. if so,  player_monitor will perform its ridiculous 'while true' loop faster.
(_attacked OR _near)

