---@param message string
local function print(message)
    DEFAULT_CHAT_FRAME:AddMessage(message)
end

local counter = 0

---@param case string
---@param name string
---@param run fun: any
function mtsl_test(case, name, run)
    local no_errors_encountered, _ = pcall(run)
    local success = no_errors_encountered
    if not success then
        print(format("|cffff0000%s: %s: FAIL", case, name))
    end
    counter = counter + 1
end

---@param module string
function mtsl_module_test_start(module)
    counter = 0
    print(format("%s: testing...", module))
end

function mtsl_module_test_end(module)
    print(format("%s: %d tests done", module, counter))
end
