---@shape ClassDeclarationConfig
---@field final boolean|nil
---@field implements table|nil

---@param config ClassDeclarationConfig
function mtsl_declare_class(config)
    local implements = config.implements
    if implements ~= nil then
        assert(mtsl_is_interface(--[[---@type table]] implements))
    end

    return {
        __class_id = mtsl_uuid(),
        __implements = implements,
        __index = implements,
    }
end

---@param t table
---@return boolean
function mtsl_is_class(t)
    assert(type(t) == "table")
    return t.__class_id ~= nil and t.__interface_id == nil
end

function mtsl_declare_interface()
    return { __interface_id = mtsl_uuid() }
end

---@param t table
---@return boolean
function mtsl_is_interface(t)
    assert(type(t) == "table")
    return t.__interface_id ~= nil and t.__class_id == nil
end

---@generic T
---@param class T
---@return T
function mtsl_new(class)
    assert(type(class) == "table")
    assert(mtsl_is_class(--[[---@type table]] class))

    local object = {}
    setmetatable(object, { __index = class })
    return --[[---@type T]] object
end

---@param object table
---@param class_or_interface table
function mtsl_instance_of(object, class_or_interface)
    assert(type(object) == "table")
    assert(type(class_or_interface) == "table")

    local mt = getmetatable(object)
    assert(type(mt) == "table")
    local object_class = --[[---@type table]] (--[[---@type table]] mt).__index

    if mtsl_is_class(class_or_interface) then
        return class_or_interface.__class_id == object_class.__class_id
    end

    if mtsl_is_interface(class_or_interface) then
        return class_or_interface.__interface_id == (--[[---@type table]] object_class.__implements).__interface_id
    end

    assert(false)
end

---@generic T
---@param t T[]
---@param class_or_interface table
function mtsl_list_of(t, class_or_interface)
    assert(type(t) == "table")
    assert(mtsl_is_class(class_or_interface) or mtsl_is_interface(class_or_interface))

    for _, v in ipairs(t) do
        if type(v) ~= "table" or not mtsl_instance_of(--[[---@type table]] v, class_or_interface) then
            return false
        end
    end
    return true
end
