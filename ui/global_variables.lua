-----------------------------------------
-- Creates all global variables for UI --
-----------------------------------------

-- holds all info about the addon itself
MTSLUI_ADDON = {
    AUTHOR = "Thumbkin",
    NAME = "Missing TradeSkills List",
    VERSION = "1.13.54",
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

-- holds the icons of the professions
MTSLUI_ICONS_PROFESSION = {
    -- Primary professions
    ["Alchemy"] = "136240",
    ["Blacksmithing"] = "136241",
    ["Enchanting"] = "136244",      -- craft
    ["Engineering"] = "136243",
    ["Herbalism"] = "136065",
    ["Leatherworking"] = "133611",
    ["Mining"] = "136248",
    ["Skinning"] = "134366",
    ["Tailoring"] = "136249",
    -- Secondary professions
    ["Cooking"] = "133971",
    ["First Aid"] = "135966",
    ["Fishing"] = "136245",
    -- Rogue only
    ["Poisons"] =  "136242",
}

MTSLUI_ADDON_PATH = "Interface\\AddOns\\MissingTradeSkillsList"
