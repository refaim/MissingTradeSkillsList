----------------
-- Enhance default tooltip to show characters on same realm/faction and the status for learning the recipe/skill
----------------
local _G = _G or getfenv(0)

---@param tooltip GameTooltip
---@param link string
---@param text string
---@return boolean|nil
local function enhanceTooltip(tooltip, link, text)
    local _, _, string_item_id = strfind(link, 'item:(%d+)')
    if string_item_id == nil then
        return false
    end

    ---@type number
    local item_id = --[[---@type number]] tonumber(--[[---@type string]] string_item_id)
    if item_id == nil then
        return false
    end

    local _, _, _, _, item_type, item_sub_type, _, _, _ = GetItemInfo(item_id)
    if item_type ~= "Recipe" then
        return false
    end

    local profession = item_sub_type

    local other_players
    if MTSLUI_SAVED_VARIABLES:GetEnhancedTooltipFaction() == "any" then
        other_players = MTSL_LOGIC_PLAYER_NPC:GetOtherPlayersOnCurrentRealmLearnedProfession(profession)
    else
        other_players = MTSL_LOGIC_PLAYER_NPC:GetOtherPlayersOnCurrentRealmSameFactionLearnedProfession(profession)
    end
    if MTSL_TOOLS:CountItemsInArray(other_players) == 0 then
        return false
    end

    local skill = MTSL_LOGIC_SKILL:GetSkillForProfessionByItemId(item_id, profession)
    if skill == nil then
        return false
    end

    tooltip:AddLine(" ")
    for _, player in pairs(other_players) do
        local player_profession = player["TRADESKILLS"][profession]

        local status = "known"
        local status_color = MTSLUI_FONTS.COLORS.AVAILABLE.YES
        local description = "Already known by"
        if MTSL_TOOLS:ListContainsNumber(player_profession["MISSING_SKILLS"], tonumber(skill.id)) == true then
            if tonumber(player_profession["SKILL_LEVEL"]) >= tonumber(skill.min_skill) then
                status = "learnable"
                status_color = MTSLUI_FONTS.COLORS.AVAILABLE.LEARNABLE
                description = "Could be learned by"
            else
                status = "no"
                status_color = MTSLUI_FONTS.COLORS.AVAILABLE.NO
                description = "Will be learnable by"
            end
        end

        if status ~= "known" or MTSLUI_SAVED_VARIABLES:GetEnhancedTooltipShowKnown() then
            local faction_color = MTSLUI_FONTS.COLORS.FACTION[string.upper(player.FACTION)]
            tooltip:AddLine(status_color .. description .. " " .. faction_color .. player["NAME"] .. status_color .. " " .. "(" .. player_profession["SKILL_LEVEL"] .. ") ")
        end
    end
    tooltip:Show()

    return true
end

local MTSL_HookSetItemRef = SetItemRef
---@param link string
---@param text string
---@param button MouseButton
SetItemRef = function(link, text, button)
    MTSL_HookSetItemRef(link, text, button)
    enhanceTooltip(ItemRefTooltip, link, text)
end
