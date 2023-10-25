---@class MTSL_Domain_VO_ItemId
---@field __value number
MTSL_Domain_VO_ItemId = mtsl_declare_class({})

---@return MTSL_Domain_VO_ItemId
function MTSL_Domain_VO_ItemId.Construct(value)
    local object = mtsl_new(MTSL_Domain_VO_ItemId)

    assert(type(value) == "number" and value > 0)
    object.__value = value

    return object
end

---@return number
function MTSL_Domain_VO_ItemId:AsNumber()
    return self.__value
end
