/*
 * postInit: placement handlers and the cycle keybind.
 *
 * zsa_sideIndex is this Zeus's choice, local to their machine and reset every mission:
 * 0 = DEFAULT (units keep their side), 1-4 = BLUFOR, OPFOR, INDEPENDENT, CIVILIAN (see zsa_sides).
 */

zsa_sides = [sideUnknown, west, east, independent, civilian];
zsa_sideIndex = 0;

if (!hasInterface) exitWith {};

// Curator placement events fire on the machine of the Zeus who placed the entity.
// Registered on every curator module (also ones created later), like ZEN does.
["ModuleCurator_F", "Init", {
    params ["_curator"];

    // Single units, crewed vehicles and every unit of a placed group
    _curator addEventHandler ["CuratorObjectPlaced", {
        params ["_curator", "_object"];
        if (zsa_sideIndex == 0 || {_curator != getAssignedCuratorLogic player}) exitWith {};

        private _units = [crew _object, [_object]] select (_object isKindOf "CAManBase");
        [_units, zsa_sides select zsa_sideIndex] call zsa_fnc_switchSide;
    }];

    // Whole groups, in case a unit of the group didn't raise CuratorObjectPlaced
    _curator addEventHandler ["CuratorGroupPlaced", {
        params ["_curator", "_group"];
        if (zsa_sideIndex == 0 || {_curator != getAssignedCuratorLogic player}) exitWith {};

        [units _group, zsa_sides select zsa_sideIndex] call zsa_fnc_switchSide;
    }];
}, true, [], true] call CBA_fnc_addClassEventHandler;

// Ctrl+Shift+S (rebindable): DEFAULT -> BLU -> OPF -> IND -> CIV -> DEFAULT
["Spawn As", "zsa_cycle", ["Cycle spawn side", "Zeus: cycle the side newly placed units join (DEFAULT, BLU, OPF, IND, CIV)"], {
    if (!isNull curatorCamera && {!(missionNamespace getVariable ["RscDisplayCurator_search", false])}) then {
        [(zsa_sideIndex + 1) % count zsa_sides] call zsa_fnc_setSide;
        true
    };
}, {}, [0x1F, [true, true, false]]] call CBA_fnc_addKeybind; // DIK_S with Shift + Ctrl
