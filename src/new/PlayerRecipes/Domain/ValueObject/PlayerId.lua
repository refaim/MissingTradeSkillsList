---@class MTSL_Domain_VO_PlayerId
---@field __realm string
---@field __name string
MTSL_Domain_VO_PlayerId = mtsl_declare_class({})

---@param realm string
---@param name string
---@return MTSL_Domain_VO_PlayerId
function MTSL_Domain_VO_PlayerId.Construct(realm, name)
    local object = mtsl_new(MTSL_Domain_VO_PlayerId)

    assert(type(realm) == "string" and realm ~= "")
    object.__realm = realm

    assert(type(name) == "string" and name ~= "")
    object.__name = name

    return object
end

---@return string
function MTSL_Domain_VO_PlayerId:GetRealm()
    return self.__realm
end

---@return string
function MTSL_Domain_VO_PlayerId:GetName()
    return self.__name
end
