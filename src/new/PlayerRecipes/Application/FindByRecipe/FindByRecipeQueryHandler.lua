local tsd_source = mtsl_get_service(MTSL_Domain_TradeSkillDataSource)
local player_repository = mtsl_get_service(MTSL_Domain_PlayerRepository)

---@class MTSL_App_FindByRecipeQueryHandler: MTSL_App_QueryHandler
MTSL_App_FindByRecipeQueryHandler = mtsl_declare_class({ implements = MTSL_App_QueryHandler })

function MTSL_App_FindByRecipeQueryHandler:invoke(query)
    if not mtsl_instance_of(query, MTSL_App_FindByRecipeQuery) then
        return nil
    end

    local find_by_recipe_query = --[[---@type MTSL_App_FindByRecipeQuery]] query

    local recipe_id = find_by_recipe_query:GetRecipeId()
    local _, _, _, _, item_type, item_sub_type, _, _, _ = GetItemInfo(recipe_id) --TODO спрятать за ACL?
    if item_type ~= "Recipe" then
        return nil
    end

    -- TODO наверное надо TradeSkill везде переименовать в Profession, а то путаница со Skill происходит
    local trade_skill_id = MTSL_Domain_VO_TradeSkillId.Construct(item_sub_type)
    local skill_or_nil = tsd_source:FindSkillByRecipe(trade_skill_id, MTSL_Domain_VO_ItemId.Construct(recipe_id))
    if skill_or_nil == nil then
        return nil
    end
    local skill = --[[---@type MTSL_Domain_VO_Skill]] skill_or_nil

    local players = {}
    for _, player in ipairs(player_repository:FindAll()) do --TODO only current realm
        if player:HasTradeSkill(trade_skill_id) then
            local player_trade_skill = player:GetTradeSkill(trade_skill_id)
            if player_trade_skill ~= nil then
                tinsert(players, MTSL_App_FindByRecipeQueryResponsePlayer.Construct(
                    player:GetName(),
                    player:GetFaction():AsString(),
                    player_trade_skill:GetLevel():AsNumber(),
                    player_trade_skill:IsLearned(skill:GetId())))
            end
        end
    end

    return MTSL_App_FindByRecipeQueryResponse.Construct(skill:GetLevel():AsNumber(), players)
end
