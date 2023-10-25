---@class MTSL_Domain_VO_TradeSkillId
---@field __name string
MTSL_Domain_VO_TradeSkillId = mtsl_declare_class({})

---@type table<string, boolean>
local set = {
    ["Alchemy"] = true,
    ["Blacksmithing"] = true,
    ["Cooking"] = true,
    ["Enchanting"] = true,
    ["Engineering"] = true,
    ["First Aid"] = true,
    ["Fishing"] = true,
    ["Herbalism"] = true,
    ["Leatherworking"] = true,
    ["Mining"] = true,
    ["Poisons"] = true,
    ["Skinning"] = true,
    ["Tailoring"] = true,
}

---@param name string
---@return MTSL_Domain_VO_TradeSkillId
function MTSL_Domain_VO_TradeSkillId.Construct(name)
    local object = mtsl_new(MTSL_Domain_VO_TradeSkillId)

    assert(type(name) == "string" and set[name] ~= nil)
    object.__name = name

    return object
end

---@return string
function MTSL_Domain_VO_TradeSkillId:GetName()
    return self.__name
end

---@param other MTSL_Domain_VO_TradeSkillId
---@return boolean
function MTSL_Domain_VO_TradeSkillId:EqualsTo(other)
    return self.__name == other.__name
end
