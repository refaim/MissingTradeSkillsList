---@class MTSL_Infrastructure_QueryBus: MTSL_App_QueryBus
---@field __handlers MTSL_App_QueryHandler[]
MTSL_Infrastructure_QueryBus = mtsl_declare_class({ implements = MTSL_App_QueryBus })

---@param handlers MTSL_App_QueryHandler[]
---@return MTSL_Infrastructure_QueryBus
function MTSL_Infrastructure_QueryBus.Construct(handlers)
    local object = mtsl_new(MTSL_Infrastructure_QueryBus)

    assert(mtsl_list_of(handlers, MTSL_App_QueryHandler))
    object.__handlers = handlers

    return object
end

function MTSL_Infrastructure_QueryBus:Ask(query)
    assert(mtsl_instance_of(query, MTSL_App_Query))

    for _, handler in ipairs(self.__handlers) do
        local result = handler:invoke(query)
        if result ~= nil then
            return --[[---@type MTSL_App_QueryResponse]] result
        end
    end

    assert(false, "No handler found")
end
