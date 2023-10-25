---@class MTSL_Domain_PlayerTradeSkill
---@field __id MTSL_Domain_VO_TradeSkillId
---@field __level MTSL_Domain_VO_Level
---@field __learned_skill_ids MTSL_Domain_VO_SkillId[]
---@field __missing_skill_ids MTSL_Domain_VO_SkillId[]
MTSL_Domain_PlayerTradeSkill = mtsl_declare_class({})

---@param id MTSL_Domain_VO_TradeSkillId
---@param level MTSL_Domain_VO_Level
---@param learned_skill_ids MTSL_Domain_VO_SkillId[]
---@param missing_skill_ids MTSL_Domain_VO_SkillId[]
---@return MTSL_Domain_PlayerTradeSkill
function MTSL_Domain_PlayerTradeSkill.Construct(id, level, learned_skill_ids, missing_skill_ids)
    local object = mtsl_new(MTSL_Domain_PlayerTradeSkill)

    assert(mtsl_instance_of(id, MTSL_Domain_VO_TradeSkillId))
    object.__id = id

    assert(mtsl_instance_of(level, MTSL_Domain_VO_Level))
    object.__level = level

    assert(mtsl_list_of(learned_skill_ids, MTSL_Domain_VO_SkillId))
    object.__learned_skill_ids = learned_skill_ids

    assert(mtsl_list_of(missing_skill_ids, MTSL_Domain_VO_SkillId))
    object.__missing_skill_ids = missing_skill_ids

    return object
end

---@return MTSL_Domain_VO_TradeSkillId
function MTSL_Domain_PlayerTradeSkill:GetId()
    return self.__id
end

---@return string
function MTSL_Domain_PlayerTradeSkill:GetName()
    return self.__id:GetName()
end

---@return MTSL_Domain_VO_Level
function MTSL_Domain_PlayerTradeSkill:GetLevel()
    return self.__level
end

---@return MTSL_Domain_VO_SkillId[]
function MTSL_Domain_PlayerTradeSkill:GetLearnedSkillIds()
    return self.__learned_skill_ids
end

---@return MTSL_Domain_VO_SkillId[]
function MTSL_Domain_PlayerTradeSkill:GetMissingSkillIds()
    return self.__missing_skill_ids
end

---@param skill_id MTSL_Domain_VO_SkillId
---@return boolean
function MTSL_Domain_PlayerTradeSkill:IsLearned(skill_id)
    for _, candidate in ipairs(self:GetLearnedSkillIds()) do
        if candidate:EqualsTo(skill_id) then
            return true
        end
    end
    return false
end
