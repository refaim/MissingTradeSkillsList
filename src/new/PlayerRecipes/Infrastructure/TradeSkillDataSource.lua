---@class MTSL_Infrastructure_TradeSkillDataSource: MTSL_Domain_TradeSkillDataSource
MTSL_Infrastructure_TradeSkillDataSource = mtsl_declare_class({ implements = MTSL_Domain_TradeSkillDataSource })

---@return MTSL_Infrastructure_TradeSkillDataSource
function MTSL_Infrastructure_TradeSkillDataSource.Construct()
    return mtsl_new(MTSL_Infrastructure_TradeSkillDataSource)
end

function MTSL_Infrastructure_TradeSkillDataSource:FindSkillByRecipe(trade_skill_id, recipe_id)
    for _, skill_data in ipairs(TRADE_SKILLS_DATA["skills"][--[[---@type ProfessionId]] trade_skill_id:GetName()]) do
        for _, item_id in ipairs(skill_data.items or {}) do
            if item_id == recipe_id:AsNumber() then
                return MTSL_Domain_VO_Skill.Construct(
                    MTSL_Domain_VO_SkillId.Construct(skill_data.id),
                    MTSL_Domain_VO_Level.Construct(skill_data.min_skill))
            end
        end
    end
    return nil
end
