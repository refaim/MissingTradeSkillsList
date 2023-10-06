----------------
-- Enhance default tooltip to show characters on same realm/faction and the status for learning the recipe/skill
----------------
local _G = _G or getfenv(0)

---@param profession string
---@return any[]
local function getPlayers(profession)
    if MTSLUI_SAVED_VARIABLES:GetEnhancedTooltipFaction() == "any" then
        return MTSL_LOGIC_PLAYER_NPC:GetOtherPlayersOnCurrentRealmLearnedProfession(profession)
    end

    return MTSL_LOGIC_PLAYER_NPC:GetOtherPlayersOnCurrentRealmSameFactionLearnedProfession(profession)
end

---@param tooltip GameTooltip
---@param link string
local function tryToEnhanceTooltip(tooltip, link)
    local unsafe_recipe = MTSL_LOGIC_TOOLTIP:GetRecipeFromLink(link)
    if unsafe_recipe == nil then
        return
    end
    local recipe = --[[---@type Recipe]] unsafe_recipe

    ---@type RecipeStatus[]
    local statuses = {}
    for _, player in ipairs(getPlayers(recipe.profession)) do
        local status = MTSL_LOGIC_TOOLTIP:GetPlayerRecipeStatus(player, recipe)
        local known_status_should_be_displayed = status.is_known or MTSLUI_SAVED_VARIABLES:GetEnhancedTooltipShowKnown()
        if known_status_should_be_displayed and status.player.skill_level ~= nil then
            tinsert(statuses, status)
        end
    end
    if getn(statuses) == 0 then
        return
    end

    tooltip:AddLine(" ")

    for _, status in ipairs(statuses) do
        local message
        local main_color

        if status.is_known then
            message = "Already known by"
            main_color = MTSLUI_FONTS.COLORS.AVAILABLE.YES
        elseif status.player.skill_level >= recipe.required_skill_level then
            message = "Learnable by"
            main_color = MTSLUI_FONTS.COLORS.AVAILABLE.LEARNABLE
        else
            message = "Will be learnable by"
            main_color = MTSLUI_FONTS.COLORS.AVAILABLE.NO
        end

        local faction_color = MTSLUI_FONTS.COLORS.FACTION[string.upper(status.player.faction)]

        local line = main_color .. message .. " "
            .. faction_color .. status.player.name .. " "
            .. main_color .. "(" .. status.player.skill_level .. ")"

        tooltip:AddLine(line)
    end

    tooltip:Show()
end

local tooltipItemLink
local tooltipFrame = CreateFrame("Frame", nil, GameTooltip)

tooltipFrame:SetScript("OnHide", function()
    tooltipItemLink = nil
end)

tooltipFrame:SetScript("OnShow", function()
    if tooltipItemLink ~= nil then
        tryToEnhanceTooltip(GameTooltip, tooltipItemLink)
    end
end)

local HookSetItemRef = SetItemRef
---@param link string
---@param text string
---@param button MouseButton
SetItemRef = function(link, text, button)
    HookSetItemRef(link, text, button)
    if not IsAltKeyDown() and not IsControlKeyDown() and not IsShiftKeyDown() then
        tryToEnhanceTooltip(ItemRefTooltip, link)
    end
end

local HookSetBagItem = GameTooltip.SetBagItem
function GameTooltip.SetBagItem(self, container, slot)
    tooltipItemLink = GetContainerItemLink(container, slot)
    return HookSetBagItem(self, container, slot)
end

local HookSetCraftItem = GameTooltip.SetCraftItem
function GameTooltip.SetCraftItem(self, skill, slot)
    tooltipItemLink = GetCraftReagentItemLink(skill, slot)
    return HookSetCraftItem(self, skill, slot)
end

local HookSetCraftSpell = GameTooltip.SetCraftSpell
function GameTooltip.SetCraftSpell(self, slot)
    tooltipItemLink = GetCraftItemLink(slot)
    return HookSetCraftSpell(self, slot)
end

local HookSetInventoryItem = GameTooltip.SetInventoryItem
function GameTooltip.SetInventoryItem(self, unit, slot)
    tooltipItemLink = GetInventoryItemLink(unit, slot)
    return HookSetInventoryItem(self, unit, slot)
end

local HookSetLootItem = GameTooltip.SetLootItem
function GameTooltip.SetLootItem(self, slot)
    tooltipItemLink = GetLootSlotLink(slot)
    HookSetLootItem(self, slot)
end

local HookSetLootRollItem = GameTooltip.SetLootRollItem
function GameTooltip.SetLootRollItem(self, id)
    tooltipItemLink = GetLootRollItemLink(id)
    return HookSetLootRollItem(self, id)
end

local HookSetMerchantItem = GameTooltip.SetMerchantItem
function GameTooltip.SetMerchantItem(self, item_index)
    tooltipItemLink = GetMerchantItemLink(item_index)
    return HookSetMerchantItem(self, item_index)
end

local HookSetQuestItem = GameTooltip.SetQuestItem
function GameTooltip.SetQuestItem(self, item_type, index)
    tooltipItemLink = GetQuestItemLink(item_type, index)
    return HookSetQuestItem(self, item_type, index)
end

local HookSetQuestLogItem = GameTooltip.SetQuestLogItem
function GameTooltip.SetQuestLogItem(self, item_type, index)
    tooltipItemLink = GetQuestLogItemLink(item_type, index)
    return HookSetQuestLogItem(self, item_type, index)
end

local HookSetTradePlayerItem = GameTooltip.SetTradePlayerItem
function GameTooltip.SetTradePlayerItem(self, index)
    tooltipItemLink = GetTradePlayerItemLink(index)
    return HookSetTradePlayerItem(self, index)
end

local HookSetTradeSkillItem = GameTooltip.SetTradeSkillItem
function GameTooltip.SetTradeSkillItem(self, skillIndex, reagentIndex)
    if reagentIndex then
        tooltipItemLink = GetTradeSkillReagentItemLink(skillIndex, reagentIndex)
    else
        tooltipItemLink = GetTradeSkillItemLink(skillIndex)
    end
    return HookSetTradeSkillItem(self, skillIndex, reagentIndex)
end

local HookSetTradeTargetItem = GameTooltip.SetTradeTargetItem
function GameTooltip.SetTradeTargetItem(self, index)
    tooltipItemLink = GetTradeTargetItemLink(index)
    return HookSetTradeTargetItem(self, index)
end
