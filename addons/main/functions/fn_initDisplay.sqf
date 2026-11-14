/*
 * Builds the Spawn As strip and banner on the Zeus display (runs every time Zeus opens).
 *
 * Strip: "SPAWN AS" + chips DEFAULT / BLU / OPF / IND / CIV, docked directly left of the
 *        vanilla side tabs row of the Create panel (controls group idc 450, row at y 2-4).
 * Banner: "SPAWNING AS <SIDE>" + hint, under the mission clock (idc 16808), only while a side is active.
 *
 * Both are own controls; vanilla and ZEN controls are not touched. Colors and texts are set
 * by zsa_fnc_setSide. Visibility follows the vanilla panels (Backspace / hidden Create panel).
 *
 * Arguments:
 * 0: Zeus display <DISPLAY>
 */

params ["_display"];

// Curator GUI grid units, same as the vanilla config
private _gw = ((safeZoneW / safeZoneH) min 1.2) / 40;
private _gh = ((safeZoneW / safeZoneH) min 1.2) / 1.2 / 25;

private _ctrlAdd = _display displayCtrl 450;
private _ctrlClock = _display displayCtrl 16808;

// ---- Strip ----
// [text, width in grid units, tooltip], in zsa_sides order
private _chipDefs = [
    ["DEFAULT", 2.6, "Units keep their own side (normal Zeus)"],
    ["BLU", 1.7, "New units join BLUFOR the moment they're placed"],
    ["OPF", 1.7, "New units join OPFOR the moment they're placed"],
    ["IND", 1.7, "New units join INDEPENDENT the moment they're placed"],
    ["CIV", 1.7, "New units join CIVILIAN the moment they're placed"]
];

private _stripW = 0.2 + 2.6 + 0.2; // padding, "SPAWN AS" label, padding
{ _stripW = _stripW + 0.15 + (_x select 1) } forEach _chipDefs;

(ctrlPosition _ctrlAdd) params ["_addX", "_addY"];

private _strip = _display ctrlCreate ["RscControlsGroupNoScrollbars", -1];
_strip ctrlSetPosition [_addX - (_stripW + 0.25) * _gw, _addY + 2 * _gh, _stripW * _gw, 2 * _gh];
_strip ctrlCommit 0;

private _stripBack = _display ctrlCreate ["RscText", -1, _strip];
_stripBack ctrlSetPosition [0, 0, _stripW * _gw, 2 * _gh];
_stripBack ctrlSetBackgroundColor [0.1, 0.1, 0.1, 0.75];
_stripBack ctrlCommit 0;

private _stripFrame = _display ctrlCreate ["RscFrame", -1, _strip];
_stripFrame ctrlSetPosition [0, 0, _stripW * _gw, 2 * _gh];
_stripFrame ctrlCommit 0;

private _label = _display ctrlCreate ["RscText", -1, _strip];
_label ctrlSetPosition [0.2 * _gw, 0, 2.6 * _gw, 2 * _gh];
_label ctrlSetFont "RobotoCondensedBold";
_label ctrlSetFontHeight (0.6 * _gh);
_label ctrlSetTextColor [0.74, 0.74, 0.74, 1];
_label ctrlSetText "SPAWN AS";
_label ctrlCommit 0;

// Each chip: fill + border + transparent button with the text on top
private _chips = [];
private _left = 0.2 + 2.6 + 0.15;
{
    _x params ["_text", "_w", "_tooltip"];
    private _pos = [_left * _gw, 0.3 * _gh, _w * _gw, 1.4 * _gh];

    private _fill = _display ctrlCreate ["RscText", -1, _strip];
    private _border = _display ctrlCreate ["RscFrame", -1, _strip];
    private _button = _display ctrlCreate ["zsa_RscChipButton", -1, _strip];
    { _x ctrlSetPosition _pos; _x ctrlCommit 0 } forEach [_fill, _border, _button];

    _button ctrlSetText _text;
    _button ctrlSetFontHeight (0.6 * _gh);
    _button ctrlSetTooltip _tooltip;
    _button setVariable ["zsa_index", _forEachIndex];
    _button ctrlAddEventHandler ["ButtonClick", {
        with missionNamespace do { [(_this select 0) getVariable "zsa_index"] call zsa_fnc_setSide };
    }];

    _chips pushBack [_fill, _border, _button];
    _left = _left + _w + 0.15;
} forEach _chipDefs;

// ---- Banner ----
private _banner = _display ctrlCreate ["RscControlsGroupNoScrollbars", -1];
_banner ctrlSetPosition [0.5 - 12 * _gw, safeZoneY + 3.4 * _gh, 24 * _gw, 2.4 * _gh];
_banner ctrlCommit 0;
_banner ctrlShow false;

private _title = _display ctrlCreate ["zsa_RscTextCenter", -1, _banner];
_title ctrlSetFontHeight (0.8 * _gh);
_title ctrlSetTextColor [1, 1, 1, 1];

private _titleFrame = _display ctrlCreate ["RscFrame", -1, _banner];
_titleFrame ctrlSetTextColor [1, 1, 1, 1];

private _hint = _display ctrlCreate ["zsa_RscTextCenter", -1, _banner];
_hint ctrlSetFont "RobotoCondensed";
_hint ctrlSetFontHeight (0.6 * _gh);
_hint ctrlSetTextColor [0.84, 0.84, 0.84, 1];
_hint ctrlSetBackgroundColor [0, 0, 0, 0.55];

_display setVariable ["zsa_controls", [_stripFrame, _chips, _title, _titleFrame, _hint]];
[zsa_sideIndex, _display] call zsa_fnc_setSide;

// Follow the vanilla interface: hidden with Backspace (vanilla fades its panels) and,
// for the strip, when the Create panel is collapsed. Removed when the display closes.
addMissionEventHandler ["EachFrame", {
    _thisArgs params ["_display", "_ctrlAdd", "_ctrlClock", "_strip", "_banner"];
    if (isNull _display) exitWith { removeMissionEventHandler ["EachFrame", _thisEventHandler] };

    _strip ctrlShow (ctrlFade _ctrlAdd < 0.5);
    _banner ctrlShow (zsa_sideIndex > 0 && {ctrlFade _ctrlClock < 0.5});
}, [_display, _ctrlAdd, _ctrlClock, _strip, _banner]];
