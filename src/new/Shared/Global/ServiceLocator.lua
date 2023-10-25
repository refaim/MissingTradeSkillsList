---@type table[]
local wired = {}

---@param interface table
---@param implementation table
local function wire(interface, implementation)
    assert(type(interface) == "table")
    assert(mtsl_is_interface(interface) and not mtsl_list_contains(wired, interface))
    assert(type(implementation) == "table")
    assert(mtsl_is_class(implementation))
    assert(mtsl_instance_of(implementation, interface))

    local public_methods = {}
    for k, v in pairs(implementation) do
        if type(k) == "string" then
            local name = --[[---@type string]] k
            if strfind(name, "^_") == nil then --TODO test
                public_methods[name] = v
            end
        end
    end

    setmetatable(interface, { __index = public_methods })
    tinsert(wired, interface)
end

---@generic T
---@param class T
---@return T
function mtsl_get_service(class)
    assert(type(class) == "table")
    assert(mtsl_list_contains(wired, --[[---@type table]] class))
    return class
end

wire(MTSL_Domain_PlayerRepository, MTSL_Infrastructure_PlayerRepository.Construct())
wire(MTSL_Domain_TradeSkillDataSource, MTSL_Infrastructure_TradeSkillDataSource.Construct())
wire(MTSL_App_QueryBus, MTSL_Infrastructure_QueryBus.Construct({})) --TODO pass handlers
