local query_bus = mtsl_get_service(MTSL_App_QueryBus)

--TODO это надо убрать в ItemTooltipHook
---@param item_link string
---@return number|nil
local function get_item_id(item_link)
    local _, _, string_id = strfind(item_link, 'item:(%d+)')
    if string_id == nil then
        return nil
    end

    local numeric_id = tonumber(--[[---@type string]] string_id)
    if numeric_id == nil then
        return nil
    end

    return numeric_id
end

---@param tooltip GameTooltip
local function add_players(tooltip)
    -- TODO implement
end

---@param tooltip GameTooltip
---@param item_link string
local function enhance_tooltip(tooltip, item_link)
    local item_id = get_item_id(item_link)
    if item_id == nil then
        return
    end

    --TODO мы кладём сюда item_id, но запрос хочет recipe_id, но тут у нас не должно быть логики, как быть? полагаю, надо из инфраструктуры слать событие вида (тултип, ссылка на вещь, айди вещи, тип вещи) и тогда можно рецептовость прямо тут проверить

    local query = MTSL_App_FindByRecipeQuery.Construct(--[[---@type number]] item_id)
    local response = --[[---@type MTSL_App_FindByRecipeQueryResponse]] query_bus:Ask(query)

    -- TODO implement
    -- TODO MTSLUI_SAVED_VARIABLES:GetEnhancedTooltipShowKnown()

    add_players(tooltip)
end

-----@param a MTSL_Domain_Player
-----@param b MTSL_Domain_Player
-----@return boolean
--local function comparePlayers(a, b)
--    return a:GetName() < b:GetName()
--end
--
-----@param tooltip GameTooltip
-----@param link string
--local function tryToEnhanceTooltip(tooltip, link)
--    sort(players, comparePlayers)

--
--    tooltip:AddLine(" ")
--
--    for _, status in ipairs(statuses) do
--        local message
--        local main_color
--
--        if status.is_known then
--            message = "Already known by"
--            main_color = MTSLUI_FONTS.COLORS.AVAILABLE.YES
--        elseif status.player.skill_level >= recipe.required_skill_level then
--            message = "Learnable by"
--            main_color = MTSLUI_FONTS.COLORS.AVAILABLE.LEARNABLE
--        else
--            message = "Will be learnable by"
--            main_color = MTSLUI_FONTS.COLORS.AVAILABLE.NO
--        end
--
--        local faction_color = MTSLUI_FONTS.COLORS.FACTION[string.upper(status.player.faction)]
--
--        local line = main_color .. message .. " "
--                .. faction_color .. status.player.name .. " "
--                .. main_color .. "(" .. status.player.skill_level .. ")"
--
--        tooltip:AddLine(line)
--    end
--
--    tooltip:Show()
--end


-- TODO а может быть вот этот весь низкоуровневый код хука надо унести в Infrastructure?
