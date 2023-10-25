---@class MTSL_Domain_VO_SkillId
---@field __value number
MTSL_Domain_VO_SkillId = mtsl_declare_class({}) --TODO а это точно SpellId? не SkillId? это вроде разные вещи были

---@return MTSL_Domain_VO_SkillId
function MTSL_Domain_VO_SkillId.Construct(value)
    local object = mtsl_new(MTSL_Domain_VO_SkillId)

    assert(type(value) == "number" and value > 0)
    object.__value = value

    return object
end

---@return number
function MTSL_Domain_VO_SkillId:AsNumber()
    return self.__value
end

---@param other MTSL_Domain_VO_SkillId
---@return boolean
function MTSL_Domain_VO_SkillId:EqualsTo(other)
    return self.__value == other.__value
end
