-- Fast and dependency-free UUID library for LuaJIT.
-- Written by Thibault Charbonnier. MIT License.
-- Modified and adapted for the WoW 1.12.1 Lua 5.0 API by Roman Kharitonov

---@param x number
---@return string
local function tohex(x)
    return format('%02x', x)
end

local random = math.random
local band = bit.band
local bor = bit.bor

local initialized = false

---@return string
function mtsl_uuid()
    if not initialized then
        randomseed(time())
        initialized = true
    end

    return (format('%s%s%s%s-%s%s-%s%s-%s%s-%s%s%s%s%s%s',
            tohex(random(0, 255)),
            tohex(random(0, 255)),
            tohex(random(0, 255)),
            tohex(random(0, 255)),

            tohex(random(0, 255)),
            tohex(random(0, 255)),

            tohex(bor(band(random(0, 255), 0x0F), 0x40)),
            tohex(random(0, 255)),

            tohex(bor(band(random(0, 255), 0x3F), 0x80)),
            tohex(random(0, 255)),

            tohex(random(0, 255)),
            tohex(random(0, 255)),
            tohex(random(0, 255)),
            tohex(random(0, 255)),
            tohex(random(0, 255)),
            tohex(random(0, 255))))
end
