-------------------------------------------
-- Creates all global variables for DATA --
-------------------------------------------

-- Holds all the data filled by the data luas
MTSL_DATA = {
    -- Each profession has 4 ranks to learn (1-75, 75-150, 150-225, 225-300), execpt poisons (only 1)
    ["AMOUNT_RANKS"] = {
        ["Alchemy"] = 4,
        ["Blacksmithing"] = 4,
        ["Cooking"] = 4,
        ["Enchanting"] = 4,
        ["Engineering"] = 4,
        ["First Aid"] = 4,
        ["Fishing"] = 4,
        ["Herbalism"] = 4,
        ["Leatherworking"] = 4,
        ["Mining"] = 4,
        ["Poisons"] = 1,
        ["Skinning"] = 4,
        ["Tailoring"] = 4,
    },
    -- Counters keeping track of total amount of skill (this includes AMOUNT_RANKS)
    ["AMOUNT_SKILLS"] = {},
    MIN_PATCH_LEVEL = 1,
    MAX_PATCH_LEVEL = 6,
    CURRENT_PATCH_LEVEL = 5,
    -- Phases by id: MC, DiM, BWL, ZG, AQ, Naxx
    PHASE_IDS = { 2717, 2557, 2677, 1977, 3428, 3456 }
}
