---@class MTSL_Domain_VO_Level
---@field __value number
MTSL_Domain_VO_Level = mtsl_declare_class({})

---@param value number
---@return MTSL_Domain_VO_Level
function MTSL_Domain_VO_Level.Construct(value)
    local object = mtsl_new(MTSL_Domain_VO_Level)

    assert(type(value) == "number" and value > 0)
    object.__value = value

    return object
end

---@return number
function MTSL_Domain_VO_Level:AsNumber()
    return self.__value
end
