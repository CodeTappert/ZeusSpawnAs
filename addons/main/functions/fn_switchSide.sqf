/*
 * Moves freshly placed units into a new group of the given side. Gear, identity and voice stay.
 *
 * All units of one original group end up in the same new group (stored on the old group as
 * "zsa_newGroup"), no matter in which order the placement events arrive. Units that already
 * have the target side, or have no real side (modules, animals), are left alone, so calling
 * this twice for the same unit is harmless.
 *
 * Runs where the unit is local: Zeus-placed units normally are local to the Zeus, otherwise
 * the call is forwarded to the unit's owner.
 *
 * Arguments:
 * 0: Units <ARRAY of OBJECTs>
 * 1: Side to join <SIDE>
 */

params ["_units", "_side"];

{
    private _oldGroup = group _x;

    if (side _oldGroup in [west, east, independent, civilian] && {side _oldGroup != _side}) then {
        if (local _x) then {
            private _newGroup = _oldGroup getVariable ["zsa_newGroup", grpNull];
            if (isNull _newGroup) then {
                _newGroup = createGroup [_side, true];
                _oldGroup setVariable ["zsa_newGroup", _newGroup];
                _oldGroup deleteGroupWhenEmpty true;
            };
            [_x] joinSilent _newGroup;
        } else {
            [[_x], _side] remoteExecCall ["zsa_fnc_switchSide", _x];
        };
    };
} forEach _units;
