---------------------------------------------------------
-- Contains all functions for a faction and reputation --
---------------------------------------------------------

MTSL_LOGIC_FACTION_REPUTATION = {
    FACTION_ID_NEUTRAL = 10000,
    FACTION_ID_ALLIANCE_AND_HORDE = 11000,

    ------------------------------------------------------------------------------------------------
    -- Returns the name (localised) of a faction by id
    --
    -- @faction_id      Number      The id of the faction
    --
    -- returns          String      The localised name of the faction
    ------------------------------------------------------------------------------------------------
    GetFactionNameById = function(self, faction_id)
        local faction = MTSL_TOOLS:GetItemFromUnsortedListById(MTSL_DATA["factions"], faction_id)
        if faction == nil then
            print(MTSLUI_FONTS.COLORS.TEXT.ERROR .. "MTSL: No faction found for id " .. faction_id .. "! Please report this bug!")
            return ""
        else
            return MTSLUI_TOOLS:GetLocalisedData(faction)
        end
    end,

    ------------------------------------------------------------------------------------------------
    -- Returns the id of a faction by (English) name
    --
    -- @faction_name    String      The (English) name of the faction
    --
    -- returns          Number      The id of the faction (-1 if not found, 10000 for neutral)
    ------------------------------------------------------------------------------------------------
    GetFactionIdByName = function(self, faction_name)
        local faction_id = -1
        if faction_name == "Neutral" then
            faction_id = self.FACTION_ID_NEUTRAL
        elseif faction_name ~= "Hostile" then
            local faction = MTSL_TOOLS:GetItemFromArrayByKeyValueIgnoringLocalisation(MTSL_DATA["factions"], "name", faction_name)
            if faction ~= nil then
                faction_id = faction.id
            end
        end
        return faction_id
    end,

    ----------------------------------------------------------------------------------------
    -- Gives the level of the standing (0-8) with a certain faction
    --
    -- @faction_name    String      The name of the faction
    --
    -- return           number      The standing with the rep (0-8) for the faction
    -----------------------------------------------------------------------------------------
    GetReputationLevelWithFaction = function (self, faction_name)
        for factionIndex = 1, GetNumFactions() do
            local name, description, standingId, bottomValue, topValue, earnedValue, atWarWith,
            canToggleAtWar, isHeader = GetFactionInfo(factionIndex)
            -- check if localised
            if (isHeader == nil or isHeader == false) and name == faction_name then
                return standingId
            end
        end
        -- Not found so return "unknown" (0)
        return 0
    end,

    ----------------------------------------------------------------------------------------
    -- Gives the replevel based on the standing (0-8)
    --
    -- @rep_id      number      The standing with the rep (0-8)
    --
    -- return       Array       The replevel
    -----------------------------------------------------------------------------------------
    GetReputationLevelById = function (self, rep_id)
        return MTSL_TOOLS:GetItemFromUnsortedListById(MTSL_DATA["reputation_levels"], rep_id)
    end,

    ----------------------------------------------------------------------------------------
    -- Gives the level of the standing (0-8) based on the name of the level
    --
    -- @rep_name    String      The name of the replevel
    --
    -- return       number      The standing with the rep (0-8)
    -----------------------------------------------------------------------------------------
    GetReputationLevelByLevelName = function (self, rep_name)
        local rep_level = 0
        for _, v in pairs(MTSL_DATA["reputation_levels"]) do
            if v["name"][MTSLUI_CURRENT_LANGUAGE] == rep_name then
                rep_level = v.id
            end
        end
        -- Not found so return 0 = "Unknown"
        return rep_level
    end,


    GetEnglishReputationLevelNameFromLocalisedName = function (self, rep_level)
        local rep_level_eng = nil

        for k, v in pairs(MTSL_DATA["reputation_levels"]) do
            if v["name"][MTSLUI_CURRENT_LANGUAGE] == rep_level then
                rep_level_eng = k
            end
        end

        return rep_level_eng
    end,
}
