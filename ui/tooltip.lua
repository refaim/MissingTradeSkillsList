----------------
-- Enhance default tooltip to show characters on same realm/faction and the status for learning the recipe/skill
----------------
local _G = _G or getfenv(0)

MTSL_RECIPE_PROFESSION_TYPES  = {
    "Leatherworking",   -- _G.LE_ITEM_RECIPE_LEATHERWORKING    = 1
    "Tailoring",        -- _G.LE_ITEM_RECIPE_TAILORING         = 2
    "Engineering",      -- _G.LE_ITEM_RECIPE_ENGINEERING       = 3
    "Blacksmithing",    -- _G.LE_ITEM_RECIPE_BLACKSMITHING     = 4
    "Cooking",          -- _G.LE_ITEM_RECIPE_COOKING           = 5
    "Alchemy",          -- _G.LE_ITEM_RECIPE_ALCHEMY           = 6
    "First Aid",        -- _G.LE_ITEM_RECIPE_FIRST_AID         = 7
    "Enchanting",       -- _G.LE_ITEM_RECIPE_ENCHANTING        = 8
}

-- variable to avoid adding the info more than once to the tooltip
local MTSL_TOOLTIP_SHOWN = 0

if false then
-- Enrich the tooltip with alts info
GameTooltip:HookScript("OnTooltipSetItem", function(self)
    -- Only update the tooltip when needed
    if MTSLUI_SAVED_VARIABLES:GetEnhancedTooltipActive() and MTSL_TOOLTIP_SHOWN <= 0 then
         -- Mark the tooltip as shown
        MTSL_TOOLTIP_SHOWN = 1
        -- Find out if this is the first or second call of OnTooltipSetItem().
        local name, link = GameTooltip:GetItem()
        if not name or not link then return end
        -- Get the type of item we are gonna show in the tooltip
        local _, _, _, _, _, _, _, _, _, _, _, itemTypeId, subItemTypeId = GetItemInfo(link)
        -- Only looking at recipes/formula's/schematics/...4
        if itemTypeId == _G.LE_ITEM_CLASS_RECIPE then
            local _, itemId, _  = strsplit(":", link)
            local prof_name = MTSL_RECIPE_PROFESSION_TYPES[subItemTypeId]
            -- add a line for each character on the same realm (but not current player itself) that knows the profession
            local other_players
            if MTSLUI_SAVED_VARIABLES:GetEnhancedTooltipFaction() == "any" then
                other_players = MTSL_LOGIC_PLAYER_NPC:GetOtherPlayersOnCurrentRealmLearnedProfession(prof_name)
            else
                other_players = MTSL_LOGIC_PLAYER_NPC:GetOtherPlayersOnCurrentRealmSameFactionLearnedProfession(prof_name)
            end

            -- Only add if we have players to add
            if MTSL_TOOLS:CountItemsInArray(other_players) > 0 then
                -- Get the skill from our data (convert itemid to a number instead of string) so we can check the min_skill
                local skill = MTSL_LOGIC_SKILL:GetSkillForProfessionByItemId(tonumber(itemId), prof_name)
                if skill ~= nil then
                    -- Empty line
                    GameTooltip:AddLine(" ")
                    GameTooltip:AddLine(MTSLUI_TOOLS:GetLocalisedLabel("status other characters"), true)
                    for _, v in pairs(other_players) do
                        -- Check if learned or not
                        -- default color = learned (green)
                        local status_color = MTSLUI_FONTS.COLORS.AVAILABLE.YES
                        if MTSL_TOOLS:ListContainsNumber(v["TRADESKILLS"][prof_name]["MISSING_SKILLS"], tonumber(skill.id)) == true then
                            -- depending on his skill level, mark as learnable or not yet learnable
                            if tonumber(v["TRADESKILLS"][prof_name]["SKILL_LEVEL"]) >= tonumber(skill.min_skill) then
                                status_color = MTSLUI_FONTS.COLORS.AVAILABLE.LEARNABLE
                            else
                                status_color = MTSLUI_FONTS.COLORS.AVAILABLE.NO
                            end
                        end
                        -- dont add to tooltip if we hide known players
                        if (MTSLUI_SAVED_VARIABLES:GetEnhancedTooltipShowKnown() and status_color == MTSLUI_FONTS.COLORS.AVAILABLE.YES) or
                                status_color ~= MTSLUI_FONTS.COLORS.AVAILABLE.YES then
                            local faction_color = MTSLUI_FONTS.COLORS.FACTION[string.upper(v.FACTION)]
                            GameTooltip:AddLine(MTSLUI_FONTS.TAB .. status_color  .. "[" .. v["TRADESKILLS"][prof_name]["SKILL_LEVEL"] .. "] " .. faction_color .. v["NAME"])
                        end
                    end
                end
            end
        end
    end
end)

-- Mark the tooltip as hidden
GameTooltip:HookScript("OnTooltipCleared", function(self)
    MTSL_TOOLTIP_SHOWN = 0
end)
end
