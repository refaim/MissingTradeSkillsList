---@class MTSL_Domain_VO_PlayerClass
---@field __name string
MTSL_Domain_VO_PlayerClass = mtsl_declare_class({})

---@type table<string, boolean>
local set = {
    ["druid"] = true,
    ["hunter"] = true,
    ["mage"] = true,
    ["paladin"] = true,
    ["priest"] = true,
    ["rogue"] = true,
    ["shaman"] = true,
    ["warlock"] = true,
    ["warrior"] = true,
}

---@param name string
---@return MTSL_Domain_VO_PlayerClass
function MTSL_Domain_VO_PlayerClass.Construct(name)
    local object = mtsl_new(MTSL_Domain_VO_PlayerClass)

    assert(type(name) == "string" and set[name] ~= nil)
    object.__name = name

    return object
end

---@return string
function MTSL_Domain_VO_PlayerClass:AsString()
    return self.__name
end
