/*
 * Sets the side newly placed units join and refreshes the strip and banner (if Zeus is open).
 *
 * Side colors come from the player's map color profile, like the vanilla side tabs.
 *
 * Arguments:
 * 0: Index into zsa_sides: 0 = DEFAULT, 1 = BLUFOR, 2 = OPFOR, 3 = INDEPENDENT, 4 = CIVILIAN <NUMBER>
 * 1: Zeus display, needed while it is still loading (findDisplay doesn't find it yet) <DISPLAY> (default: findDisplay 312)
 */

params ["_index", ["_display", findDisplay 312]];

zsa_sideIndex = _index;

if (isNull _display) exitWith {};
(_display getVariable ["zsa_controls", []]) params ["_stripFrame", "_chips", "_title", "_titleFrame", "_hint"];
if (isNil "_chips") exitWith {};

private _gw = ((safeZoneW / safeZoneH) min 1.2) / 40;
private _gh = ((safeZoneW / safeZoneH) min 1.2) / 1.2 / 25;

// Profile map color, fallback = vanilla tab text colors
private _colors = [[0.35, 0.35, 0.35, 1]] + ([
    ["BLUFOR", [0, 0.3, 0.6]],
    ["OPFOR", [0.5, 0, 0]],
    ["Independent", [0, 0.5, 0]],
    ["Civilian", [0.4, 0, 0.5]]
] apply {
    _x params ["_name", "_default"];
    [
        profileNamespace getVariable [format ["Map_%1_R", _name], _default select 0],
        profileNamespace getVariable [format ["Map_%1_G", _name], _default select 1],
        profileNamespace getVariable [format ["Map_%1_B", _name], _default select 2],
        1
    ]
});
private _color = _colors select _index;

// Active chip: filled in side color, white border. Others: dark, border in their side color.
{
    _x params ["_fill", "_border", "_button"];
    if (_forEachIndex == _index) then {
        _fill ctrlSetBackgroundColor _color;
        _border ctrlSetTextColor [1, 1, 1, 1];
        _button ctrlSetTextColor [1, 1, 1, 1];
    } else {
        _fill ctrlSetBackgroundColor [0, 0, 0, 0.45];
        _border ctrlSetTextColor (_colors select _forEachIndex);
        _button ctrlSetTextColor [0.81, 0.81, 0.81, 1];
    };
} forEach _chips;

_stripFrame ctrlSetTextColor ([[0, 0, 0, 0.6], _color] select (_index > 0));

// Banner (shown by the EachFrame handler of zsa_fnc_initDisplay while a side is active)
if (_index == 0) exitWith {};

private _name = ["", "BLUFOR", "OPFOR", "INDEPENDENT", "CIVILIAN"] select _index;
private _keyHint = "";
private _keybind = ["Spawn As", "zsa_cycle"] call CBA_fnc_getKeybind;
if (!isNil "_keybind" && {(_keybind select 5 select 0) > 0}) then {
    _keyHint = format [" · %1 cycles", (_keybind select 5) call CBA_fnc_localizeKey];
};

_title ctrlSetText format ["SPAWNING AS %1", _name];
_title ctrlSetBackgroundColor _color;
_hint ctrlSetText format ["New units join %1 the moment they're placed%2", _name, _keyHint];

// Size both boxes to their text, centered in the 24 grid wide banner group
private _titleW = ctrlTextWidth _title + 2 * _gw;
{
    _x ctrlSetPosition [(24 * _gw - _titleW) / 2, 0, _titleW, 1.3 * _gh];
    _x ctrlCommit 0;
} forEach [_title, _titleFrame];

private _hintW = ctrlTextWidth _hint + 1 * _gw;
_hint ctrlSetPosition [(24 * _gw - _hintW) / 2, 1.45 * _gh, _hintW, 0.85 * _gh];
_hint ctrlCommit 0;
