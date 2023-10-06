---@shape Recipe
---@field item_id number
---@field profession ProfessionId
---@field skill_id number
---@field required_skill_level number

---@shape RecipePlayer
---@field faction string
---@field name string
---@field skill_level number|nil

---@shape RecipeStatus
---@field player RecipePlayer
---@field is_known boolean

MTSL_LOGIC_TOOLTIP = {
    ---@param item_link string
    ---@return Recipe|nil
    GetRecipeFromLink = function(self, item_link)
        local unsafe_item_id = MTSL_LOGIC_ITEM_OBJECT:GetItemIdFromLink(item_link)
        if unsafe_item_id == nil then
            return nil
        end
        local item_id = --[[---@type number]] unsafe_item_id

        local _, _, _, _, item_type, item_sub_type, _, _, _ = GetItemInfo(item_id)
        if item_type ~= "Recipe" then
            return nil
        end
        local profession = --[[---@type ProfessionId]] item_sub_type

        local unsafe_skill = MTSL_LOGIC_SKILL:GetSkillForProfessionByItemId(item_id, profession)
        if unsafe_skill == nil then
            return nil
        end
        local skill = --[[---@type Skill]] unsafe_skill

        return {
            ["item_id"] = item_id,
            ["profession"] = profession,
            ["skill_id"] = --[[---@type number]] tonumber(skill.id),
            ["required_skill_level"] = --[[---@type number]] tonumber(skill.min_skill),
        }
    end,

    ---@param player any
    ---@param recipe Recipe
    ---@return RecipeStatus
    GetPlayerRecipeStatus = function(self, player, recipe)
        local profession = player.TRADESKILLS[recipe.profession]

        local skill_level
        if profession ~= nil then
            skill_level = profession.SKILL_LEVEL
        end

        local is_recipe_known = false
        if profession ~= nil then
            is_recipe_known = MTSL_TOOLS:ListContainsNumber(profession.LEARNED_SKILLS, recipe.skill_id)
        end

        return {
            ["player"] = {
                ["faction"] = player.FACTION,
                ["name"] = player.NAME,
                ["skill_level"] = skill_level,
            },
            ["is_known"] = is_recipe_known,
        }
    end
}
