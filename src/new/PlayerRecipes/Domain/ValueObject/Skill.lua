---@class MTSL_Domain_VO_Skill
---@field __id MTSL_Domain_VO_SkillId
---@field __level MTSL_Domain_VO_Level
MTSL_Domain_VO_Skill = mtsl_declare_class({})

---@param id MTSL_Domain_VO_SkillId
---@param level MTSL_Domain_VO_Level
---@return MTSL_Domain_VO_Skill
function MTSL_Domain_VO_Skill.Construct(id, level)
    local object = mtsl_new(MTSL_Domain_VO_Skill)

    assert(mtsl_instance_of(id, MTSL_Domain_VO_SkillId))
    object.__id = id

    assert(mtsl_instance_of(level, MTSL_Domain_VO_Level))
    object.__level = level

    return object
end

---@return MTSL_Domain_VO_SkillId
function MTSL_Domain_VO_Skill:GetId()
    return self.__id
end

---@return MTSL_Domain_VO_Level
function MTSL_Domain_VO_Skill:GetLevel()
    return self.__level
end
