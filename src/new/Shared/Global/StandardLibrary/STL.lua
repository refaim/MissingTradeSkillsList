---@param t table
---@return boolean
function mtsl_is_empty(t)
    assert(type(t) == "table")

    for _, _ in pairs(t) do
        return false
    end

    return true
end

---@generic T
---@param t T[]
---@param value T
---@return boolean
function mtsl_list_contains(t, value) -- TODO test
    for _, candidate in ipairs(t) do
        if candidate == value then
            return true
        end
    end
    return false
end
