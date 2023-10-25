---@class MTSL_App_FindByRecipeQueryResponsePlayer
---@field __name string
---@field __faction string
---@field __trade_skill_level number
---@field __knows_recipe boolean
MTSL_App_FindByRecipeQueryResponsePlayer = mtsl_declare_class({})

---@param name string
---@param faction string
---@param trade_skill_level number
---@param knows_recipe boolean
---@return MTSL_App_FindByRecipeQueryResponsePlayer
function MTSL_App_FindByRecipeQueryResponsePlayer.Construct(name, faction, trade_skill_level, knows_recipe)
    local object = mtsl_new(MTSL_App_FindByRecipeQueryResponsePlayer)

    assert(type(name) == "string" and name ~= "")
    object.__name = name

    assert(type(faction) == "string" and faction ~= "")
    object.__faction = faction

    assert(type(trade_skill_level) == "number" and trade_skill_level > 0)
    object.__trade_skill_level = trade_skill_level

    assert(type(knows_recipe) == "boolean")
    object.__knows_recipe = knows_recipe

    return object
end

---@return string
function MTSL_App_FindByRecipeQueryResponsePlayer:GetName()
    return self.__name
end

---@return string
function MTSL_App_FindByRecipeQueryResponsePlayer:GetFaction()
    return self.__faction
end

---@return number
function MTSL_App_FindByRecipeQueryResponsePlayer:GetTradeSkillLevel()
    return self.__trade_skill_level
end

---@return boolean
function MTSL_App_FindByRecipeQueryResponsePlayer:KnowsRecipe()
    return self.__knows_recipe
end

---@class MTSL_App_FindByRecipeQueryResponse: MTSL_App_QueryResponse
---@field __required_skill_level number
---@field __players MTSL_App_FindByRecipeQueryResponsePlayer[]
MTSL_App_FindByRecipeQueryResponse = mtsl_declare_class({ implements = MTSL_App_QueryResponse })

---@param required_skill_level number
---@param players MTSL_App_FindByRecipeQueryResponsePlayer[]
---@return MTSL_App_FindByRecipeQueryResponse
function MTSL_App_FindByRecipeQueryResponse.Construct(required_skill_level, players)
    local object = mtsl_new(MTSL_App_FindByRecipeQueryResponse)

    assert(type(required_skill_level) == "number" and required_skill_level >= 0)
    object.__required_skill_level = required_skill_level

    assert(mtsl_list_of(players, MTSL_App_FindByRecipeQueryResponsePlayer))
    object.__players = players

    return object
end

---@return number
function MTSL_App_FindByRecipeQueryResponse:GetRequiredSkillLevel()
    return self.__required_skill_level
end

---@return MTSL_App_FindByRecipeQueryResponsePlayer[]
function MTSL_App_FindByRecipeQueryResponse:GetPlayers()
    return self.__players
end
