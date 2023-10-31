-------------------------------------------------
-- Contains all shared functions for the logic --
-------------------------------------------------

MTSL_AVAILABLE_PROFESSIONS = { "Alchemy", "Blacksmithing", "Cooking", "Enchanting", "Engineering", "First Aid", "Leatherworking", "Mining", "Poisons", "Tailoring" }
MTSL_AVAILABLE_LANGUAGES = { "French", "English", "German", "Russian", "Spanish", "Portuguese", "Chinese", "Taiwanese" }

MTSL_TOOLS = {
    Print = function(self, text)
        DEFAULT_CHAT_FRAME:AddMessage(string.format("|cffffff00%s", text or "nil"))
    end,

    BindArgument = function(self, callback, arg)
        return function(a1, a2, a3, a4, a5, a6, a7, a8, a9, a10) return callback(arg, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10) end
    end,

    ---------------------------------------------------------------------------------------
    -- Conver a number to xx g xx s xx c
    --
    -- @money_number:   number      The amount expressed in coppers (e.g.: 10000 = 1g 00 s 00c)
    --
    -- returns          String      Number converted to xx g xx s xx c
    ----------------------------------------------------------------------------------------
    GetNumberAsMoneyString = function(self, money_number)
        if type(money_number) ~= "number" then
            return "-"
        end

        -- Calculate the amount of gold, silver and copper
        local gold = floor(money_number/10000)
        local silver = floor(mod((money_number/100),100))
        local copper = mod(money_number,100)

        local money_string = ""
        -- Add gold if we have
        if gold > 0 then
            money_string = money_string .. MTSLUI_FONTS.COLORS.TEXT.NORMAL .. gold .. MTSLUI_FONTS.COLORS.MONEY.GOLD .. "g "
        end
        -- Add silver if we have
        if silver > 0 then
            money_string = money_string .. MTSLUI_FONTS.COLORS.TEXT.NORMAL .. silver .. MTSLUI_FONTS.COLORS.MONEY.SILVER .. "s "
        end
        -- Always show copper even if 0
        money_string = money_string .. MTSLUI_FONTS.COLORS.TEXT.NORMAL .. copper .. MTSLUI_FONTS.COLORS.MONEY.COPPER .. "c"

        return money_string
    end,

    ----------------------------------------------------------------------------------------------------------
    -- Checks if all data is present and correctly loaded in the addon
    --
    -- returns      Boolean     Flag indicating if data is valid
    ----------------------------------------------------------------------------------------------------------
    CheckIfDataIsValid = function(self)
        local objects_to_check = { "continents", "factions", "holidays", "npcs", "objects", "professions", "profession_ranks", "quests", "reputation_levels", "special_actions", "zones", "items", "levels", "skills", "specialisations"}
        for _, v in pairs(objects_to_check) do
            -- object not present
            if TRADE_SKILLS_DATA[v] == nil then
                MTSL_TOOLS:Print(MTSLUI_FONTS.COLORS.TEXT.ERROR .. "MTSL: Could not load all the data needed for the addon! Missing " .. v .. ". Please reinstall the addon!")
                return false
            end
        end
        return true
    end,

    ---@generic T
    ---@param orig T
    ---@return T
    CopyObject = function(self, orig)
        local orig_type = type(orig)
        local copy
        if orig_type == 'table' then
            copy = {}
            for orig_key, orig_value in next, orig, nil do
                copy[self:CopyObject(orig_key)] = self:CopyObject(orig_value)
            end
            setmetatable(copy, self:CopyObject(getmetatable(orig)))
        else -- number, string, boolean, etc
            copy = orig
        end
        return copy
    end,

    ----------------------------------------------------------------------------------------------------------
    -- Searches for an item by id in an unsorted list
    --
    -- @list        Array       The lsit in which to search
    -- @id          Number      The id to search for
    --
    -- returns      Object      The item with the corresponding id or nil if not found
    ----------------------------------------------------------------------------------------------------------
    GetItemFromUnsortedListById = function(self, list, id)
        local i = 1
        -- lists are sorted on id (low to high)
        while list[i] ~= nil and list[i].id ~= id do
            i = i + 1
        end

        return list[i]
    end,

    ----------------------------------------------------------------------------------------------------------
    -- Searches for an item in a named array by index
    --
    -- @list        Array       The lsit in which to search
    -- @index       Number      The index to search for
    --
    -- returns      Object      The item with the corresponding id or nil if not found
    ----------------------------------------------------------------------------------------------------------
    GetItemFromNamedListByIndex = function(self, list, index)
        local i = 1

        if list ~= nil then
            for _, v in pairs(list) do
                if index == i then
                    return v
                end
                i = i + 1
            end
        end

        return nil
    end,

    ----------------------------------------------------------------------------------------------------------
    -- Counts the number of elements in the list using number as indexes
    --
    -- @list        Array       The list to count items from
    --
    -- returns      Number      The amount of items
    ----------------------------------------------------------------------------------------------------------
    CountItemsInArray = function(self, list)
        local amount = 0
        if list ~= nil then
            amount = getn(list)
        end
        return amount
    end,

    ----------------------------------------------------------------------------------------------------------
    -- Counts the number of elements in the list using Strings as indexes
    --
    -- @list        Array       The list to count items from
    --
    -- returns      Number      The amount of items
    ----------------------------------------------------------------------------------------------------------
    CountItemsInNamedArray = function(self, list)
        local amount = 0
        if list == nil then
            return 0
        end
        for _, _ in pairs(list) do
            amount = amount + 1
        end
        return amount
    end,

    -----------------------------------------------------------------------------------------------
    -- Gets an item (based on it's keyvalue) from an array
    --
    -- @array           Array       The array to search
    -- @key_name        String      The name of the key to use to compare values
    -- @key_value       Object      The value of the key to search
    --
    -- return           Object      Found item (nil if not found)
    ------------------------------------------------------------------------------------------------
    GetItemFromArrayByKeyValue = function(self, array, key_name, key_value)
        if key_value ~= nil and array ~= nil then
            for _, v in pairs(array) do
                if v[key_name] ~= nil and v[key_name] == key_value then
                    return v
                end
            end
        end
        -- item not found
        return nil
    end,
    -----------------------------------------------------------------------------------------------
    -- Gets an item (based on a value in an array) from an array
    --
    -- @array           Array       The array to search
    -- @key_name        String      The name of the key to use to compare values
    -- @key_value       Object      The value of the key to search in the key_array
    --
    -- return           Object      Found item (nil if not found)
    ------------------------------------------------------------------------------------------------
    GetItemFromArrayByKeyArrayValue = function(self, array, key_name, key_value)
        if key_value ~= nil and array ~= nil then
            for _, v in pairs(array) do
                if v[key_name] ~= nil and type(v[key_name]) == "table" and self:ListContainsKey(v[key_name], key_value) then
                    return v
                end
            end
        end
        -- item not found
        return nil
    end,

    -----------------------------------------------------------------------------------------------
    -- Gets an item (based on it's keyvalue) from an array that uses localisation
    --
    -- @array           Array       The array to search
    -- @key_name        String      The name of the key to use to compare values
    -- @key_value       Object      The value of the key to search
    --
    -- return           Object      Found item (nil if not found)
    ------------------------------------------------------------------------------------------------
    GetItemFromLocalisedArrayByKeyValue = function(self, array, key_name, key_value)
        if key_value ~= nil and array ~= nil then
            for _, v in pairs(array) do
                if v[key_name] ~= nil and v[key_name][MTSLUI_CURRENT_LANGUAGE] == key_value then
                    return v
                end
            end
        end
        -- item not found
        return nil
    end,

    -----------------------------------------------------------------------------------------------
    -- Gets an item (based on it's keyvalue) from an array that ignores localisation (so uses English value)
    --
    -- @array           Array       The array to search
    -- @key_name        String      The name of the key to use to compare values
    -- @key_value       Object      The value of the key to search
    --
    -- return           Object      Found item (nil if not found)
    ------------------------------------------------------------------------------------------------
    GetItemFromArrayByKeyValueIgnoringLocalisation = function(self, array, key_name, key_value)
        if key_value ~= nil and array ~= nil then
            for _, v in pairs(array) do
                if v[key_name] ~= nil and v[key_name]["English"] == key_value then
                    return v
                end
            end
        end
        -- item not found
        return nil
    end,

    -----------------------------------------------------------------------------------------------
    -- Gets all items (based on it's keyvalue) from an array
    --
    -- @array           Array       The array to search
    -- @key_name        String      The name of the key to use to compare values
    -- @key_value       Object      The value of the key to search
    --
    -- return           Object      Found item (nil if not found)
    ------------------------------------------------------------------------------------------------
    GetAllItemsFromArrayByKeyValue = function(self, array, key_name, key_value)
        local items = {}
        if key_value ~= nil and array ~= nil then
            for _, v in pairs(array) do
                if v[key_name] ~= nil and v[key_name] == key_value then
                    table.insert(items, v)
                end
            end
        end
        -- item not found
        return items
    end,

    ------------------------------------------------------------------------------------------------
    -- Searches an array to see if it contains a number
    --
    -- @list            Array       The list to search
    -- @number          Number      The number to search
    --
    -- return           boolean     Flag indicating if number is foundFound skill (nil if not  in list)
    ------------------------------------------------------------------------------------------------
    ListContainsNumber = function(self, list, number)
        if list == nil then
            return false
        end
        local i = 1
        while list[i] ~= nil and tonumber(list[i]) ~= tonumber(number) do
            i = i + 1
        end
        return list[i] ~= nil
    end,

    ---@return boolean
    TableEmpty = function(self, t)
        for _, _ in pairs(t) do
            return false
        end
        return true
    end,

    ------------------------------------------------------------------------------------------------
    -- Searches an array to see if it contains a key for given value
    --
    -- @list            Array       The list to search
    -- @key             String      The key to search
    --
    -- return           boolean     Flag indicating if number is foundFound skill (nil if not  in list)
    ------------------------------------------------------------------------------------------------
    ListContainsKey = function(self, list, key)
        if list == nil then
            return false
        end
        for _, k in pairs(list) do
            if k == key then
                return true
            end
        end
        -- not found
        return false
    end,

    ------------------------------------------------------------------------------------------------
    -- Searches an array to see if it contains a key (after spaces stripped) for given value
    --
    -- @list            Array       The list to search
    -- @key             String      The key to search
    --
    -- return           boolean     Flag indicating if number is foundFound skill (nil if not  in list)
    ------------------------------------------------------------------------------------------------
    ListContainsKeyIgnoreCasingAndSpaces = function(self, list, key)
        if list == nil then
            return false
        end
        for _, k in pairs(list) do
            if self:StripSpacesAndLower(k) == self:StripSpacesAndLower(key) then
                return true
            end
        end
        -- not found
        return false
    end,

    ------------------------------------------------------------------------------------------------
    -- Trims all the spaces in a string and turn it to lowercase
    --
    -- @text            String      The text to convert
    --
    -- return           String      Text trimmed of spaces and put into lowercase
    ------------------------------------------------------------------------------------------------
    StripSpacesAndLower = function(self, text)
        local lowered = string.lower(text)
        local stripped_text,_ = string.gsub(lowered, "%s", "")
        return stripped_text
    end,

    ------------------------------------------------------------------------------------------------
    -- Sorts an array
    --
    -- @array           Array       The array to sort
    --
    -- return           Array       Sorted array
    ------------------------------------------------------------------------------------------------
    SortArray = function(self, array)
        if array ~= nil then
            table.sort(array, function(a, b) return a < b end)
        end
        return array
    end,

    ------------------------------------------------------------------------------------------------
    -- Sorts an array
    --
    -- @array           Array       The array to sort
    --
    -- return           Array       Sorted array
    ------------------------------------------------------------------------------------------------
    SortArrayNumeric = function(self, array)
        if array ~= nil then
            table.sort(array, function(a, b) return tonumber(a) < tonumber(b) end)
        end
        return array
    end,

    ------------------------------------------------------------------------------------------------
    -- Sorts an array by property
    --
    -- @array           Array       The array to sort
    -- @property            String      The name of the property to sort addon
    --
    -- return           Array       Sorted array
    ------------------------------------------------------------------------------------------------
    SortArrayByProperty = function(self, array, property)
        if array ~= nil then
            table.sort(array, function(a, b) return a[property] < b[property] end)
        end
        return array
    end,

    ------------------------------------------------------------------------------------------------
    -- Sorts an array by property
    --
    -- @array           Array       The array to sort
    -- @property            String      The name of the property to sort addon
    --
    -- return           Array       Sorted array
    ------------------------------------------------------------------------------------------------
    SortArrayByPropertyReversed = function(self, array, property)
        if array ~= nil then
            table.sort(array, function(a, b) return a[property] > b[property] end)
        end
        return array
    end,


    ------------------------------------------------------------------------------------------------
    -- Sorts an array by property using localisation
    --
    -- @array           Array       The array to sort
    -- @property        String      The name of the property to sort addon
    --
    -- return           Array       Sorted array
    ------------------------------------------------------------------------------------------------
    SortArrayByLocalisedProperty = function(self, array, property)
        if array ~= nil then
            table.sort(array, function(a, b) return a[property][MTSLUI_CURRENT_LANGUAGE] < b[property][MTSLUI_CURRENT_LANGUAGE] end)
        end
        return array
    end,
}
