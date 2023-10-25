---@class MTSL_Domain_VO_Faction
---@field __name string
MTSL_Domain_VO_Faction = mtsl_declare_class({})

---@type table<string, boolean>
local set = {
    ["Alliance"] = true,
    ["Horde"] = true,
}

---@param name string
---@return MTSL_Domain_VO_Faction
function MTSL_Domain_VO_Faction.Construct(name)
    local object = mtsl_new(MTSL_Domain_VO_Faction)

    assert(type(name) == "string" and set[name] ~= nil)
    object.__name = name

    return object
end

---@return string
function MTSL_Domain_VO_Faction:AsString()
    return self.__name
end
