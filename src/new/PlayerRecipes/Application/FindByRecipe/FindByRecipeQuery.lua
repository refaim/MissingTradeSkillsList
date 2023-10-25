---@class MTSL_App_FindByRecipeQuery: MTSL_App_Query
---@field __recipe_id number
MTSL_App_FindByRecipeQuery = mtsl_declare_class({ implements = MTSL_App_Query })

---@param recipe_id number
function MTSL_App_FindByRecipeQuery.Construct(recipe_id)
    local object = mtsl_new(MTSL_App_FindByRecipeQuery)
    assert(type(recipe_id) == "number")
    object.__recipe_id = recipe_id
    return object
end

---@return number
function MTSL_App_FindByRecipeQuery:GetRecipeId()
    return self.__recipe_id
end
