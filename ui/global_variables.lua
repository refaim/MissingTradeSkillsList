-----------------------------------------
-- Creates all global variables for UI --
-----------------------------------------

-- holds all info about the addon itself
MTSLUI_ADDON = {
    AUTHOR = "Thumbkin",
    NAME = "Missing TradeSkills List",
    VERSION = "1.14",
    SERVER_VERSION_PHASES = {
        -- max build number from server for phase 1,
        {
            ["id"] = 1,
            ["max_tocversion"] = 11301,
        },
        {
            ["id"] = 2,
            ["max_tocversion"] = 11302,
        },
        {
            ["id"] = 3,
            ["max_tocversion"] = 11303,
        },
        {
            ["id"] = 4,
            ["max_tocversion"] = 11304,
        },
        {
            ["id"] = 5,
            ["max_tocversion"] = 11305,
        },
        {
            ["id"] = 6,
            ["max_tocversion"] = 999999,
        }
    }
}

MTSLUI_PROFESSION_TEXTURES = {
    ["Alchemy"] = "Interface\\Icons\\trade_alchemy",
    ["Blacksmithing"] = "Interface\\Icons\\trade_blacksmithing",
    ["Cooking"] = "Interface\\Icons\\inv_misc_food_15",
    ["Enchanting"] = "Interface\\Icons\\trade_engraving",
    ["Engineering"] = "Interface\\Icons\\trade_engineering",
    ["First Aid"] = "Interface\\Icons\\spell_holy_sealofsacrifice",
    ["Fishing"] = "Interface\\Icons\\trade_fishing",
    ["Herbalism"] = "Interface\\Icons\\spell_nature_naturetouchgrow",
    ["Leatherworking"] = "Interface\\Icons\\inv_misc_armorkit_17",
    ["Mining"] = "Interface\\Icons\\trade_mining",
    ["Poisons"] =  "Interface\\Icons\\trade_brewpoison",
    ["Skinning"] = "Interface\\Icons\\inv_misc_pelt_wolf_01",
    ["Tailoring"] = "Interface\\Icons\\trade_tailoring",
}

MTSLUI_ADDON_PATH = "Interface\\AddOns\\MissingTradeSkillsList"
