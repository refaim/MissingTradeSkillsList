---@param tooltip GameTooltip
---@param item_link string
local function notify(tooltip, item_link)
    --TODO implement
end

local game_tooltip_item_link
local event_frame = CreateFrame("Frame", nil, GameTooltip)

event_frame:SetScript("OnHide", function()
    game_tooltip_item_link = nil
end)

event_frame:SetScript("OnShow", function()
    if game_tooltip_item_link ~= nil then
        notify(GameTooltip, game_tooltip_item_link)
    end
end)

local HookSetItemRef = SetItemRef
---@param link string
---@param text string
---@param button MouseButton
SetItemRef = function(link, text, button)
    HookSetItemRef(link, text, button)
    if not IsAltKeyDown() and not IsControlKeyDown() and not IsShiftKeyDown() then
        notify(ItemRefTooltip, link)
    end
end

local HookSetBagItem = GameTooltip.SetBagItem
function GameTooltip.SetBagItem(self, container, slot)
    game_tooltip_item_link = GetContainerItemLink(container, slot)
    return HookSetBagItem(self, container, slot)
end

local HookSetCraftItem = GameTooltip.SetCraftItem
function GameTooltip.SetCraftItem(self, skill, slot)
    game_tooltip_item_link = GetCraftReagentItemLink(skill, slot)
    return HookSetCraftItem(self, skill, slot)
end

local HookSetCraftSpell = GameTooltip.SetCraftSpell
function GameTooltip.SetCraftSpell(self, slot)
    game_tooltip_item_link = GetCraftItemLink(slot)
    return HookSetCraftSpell(self, slot)
end

local HookSetInventoryItem = GameTooltip.SetInventoryItem
function GameTooltip.SetInventoryItem(self, unit, slot)
    game_tooltip_item_link = GetInventoryItemLink(unit, slot)
    return HookSetInventoryItem(self, unit, slot)
end

local HookSetLootItem = GameTooltip.SetLootItem
function GameTooltip.SetLootItem(self, slot)
    game_tooltip_item_link = GetLootSlotLink(slot)
    HookSetLootItem(self, slot)
end

local HookSetLootRollItem = GameTooltip.SetLootRollItem
function GameTooltip.SetLootRollItem(self, id)
    game_tooltip_item_link = GetLootRollItemLink(id)
    return HookSetLootRollItem(self, id)
end

local HookSetMerchantItem = GameTooltip.SetMerchantItem
function GameTooltip.SetMerchantItem(self, item_index)
    game_tooltip_item_link = GetMerchantItemLink(item_index)
    return HookSetMerchantItem(self, item_index)
end

local HookSetQuestItem = GameTooltip.SetQuestItem
function GameTooltip.SetQuestItem(self, item_type, index)
    game_tooltip_item_link = GetQuestItemLink(item_type, index)
    return HookSetQuestItem(self, item_type, index)
end

local HookSetQuestLogItem = GameTooltip.SetQuestLogItem
function GameTooltip.SetQuestLogItem(self, item_type, index)
    game_tooltip_item_link = GetQuestLogItemLink(item_type, index)
    return HookSetQuestLogItem(self, item_type, index)
end

local HookSetTradePlayerItem = GameTooltip.SetTradePlayerItem
function GameTooltip.SetTradePlayerItem(self, index)
    game_tooltip_item_link = GetTradePlayerItemLink(index)
    return HookSetTradePlayerItem(self, index)
end

local HookSetTradeSkillItem = GameTooltip.SetTradeSkillItem
function GameTooltip.SetTradeSkillItem(self, skill_index, reagent_index)
    if reagent_index then
        game_tooltip_item_link = GetTradeSkillReagentItemLink(skill_index, reagent_index)
    else
        game_tooltip_item_link = GetTradeSkillItemLink(skill_index)
    end
    return HookSetTradeSkillItem(self, skill_index, reagent_index)
end

local HookSetTradeTargetItem = GameTooltip.SetTradeTargetItem
function GameTooltip.SetTradeTargetItem(self, index)
    game_tooltip_item_link = GetTradeTargetItemLink(index)
    return HookSetTradeTargetItem(self, index)
end
