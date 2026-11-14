class CfgPatches {
    class zsa_main {
        name = "Spawn As any Faction in ZEUS";
        author = "[RTLS] DerTapp";
        units[] = {};
        weapons[] = {};
        requiredVersion = 2.0;
        requiredAddons[] = {"cba_main", "A3_UI_F_Curator"};
    };
};

class CfgFunctions {
    class zsa {
        class main {
            file = "\z\zsa\addons\main\functions";
            class init { postInit = 1; };
            class initDisplay {};
            class setSide {};
            class switchSide {};
        };
    };
};

// Build the Spawn As strip and banner every time the Zeus display opens (CBA display XEH)
class Extended_DisplayLoad_EventHandlers {
    class RscDisplayCurator {
        zsa_main = "with missionNamespace do { _this call zsa_fnc_initDisplay }";
    };
};

// Controls created by zsa_fnc_initDisplay. Sizes and colors are set from script.
class RscText;
class RscButton;

class zsa_RscTextCenter: RscText {
    style = 2; // ST_CENTER
    font = "RobotoCondensedBold";
    shadow = 0;
};

// Transparent click area on top of a chip; the chip's fill and border are separate controls
class zsa_RscChipButton: RscButton {
    font = "RobotoCondensedBold";
    shadow = 0;
    colorText[] = {1, 1, 1, 1};
    colorDisabled[] = {1, 1, 1, 0.5};
    colorBackground[] = {0, 0, 0, 0};
    colorBackgroundActive[] = {1, 1, 1, 0.15};
    colorBackgroundDisabled[] = {0, 0, 0, 0};
    colorFocused[] = {0, 0, 0, 0};
    colorShadow[] = {0, 0, 0, 0};
    colorBorder[] = {0, 0, 0, 0};
    offsetPressedX = 0;
    offsetPressedY = 0;
};
