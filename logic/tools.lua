-------------------------------------------------
-- Contains all shared functions for the logic --
-------------------------------------------------

MTSL_AVAILABLE_PROFESSIONS = { "Alchemy", "Blacksmithing", "Cooking", "Enchanting", "Engineering", "First Aid", "Leatherworking", "Mining", "Poisons", "Tailoring" }
MTSL_AVAILABLE_LANGUAGES = { "French", "English", "German", "Russian", "Spanish", "Portuguese", "Chinese", "Taiwanese" }

MTSL_TOOLS = {
    Print = function(self, text)
        DEFAULT_CHAT_FRAME:AddMessage(string.format("|cffffff00%s", text or "nil"))
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
            if MTSL_DATA[v] == nil then
                MTSL_TOOLS:Print(MTSLUI_FONTS.COLORS.TEXT.ERROR .. "MTSL: Could not load all the data needed for the addon! Missing " .. v .. ". Please reinstall the addon!")
                return false
            end
        end

        -- Count the data
        self:CountSkillsPerProfessionAndPhase()

        return true
    end,

    ----------------------------------------------------------------------------------------------------------
    -- Creates a deep copy of an object
    --
    -- @orig        Object      The original object to copy
    --
    -- returns      Object      A copy of the original object
    ----------------------------------------------------------------------------------------------------------
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
    -- Searches for an item by id in a sorted list
    --
    -- @list        Array       The lsit in which to search
    -- @id          Number      The id to search for
    --
    -- returns      Object      The item with the corresponding id or nil if not found
    ----------------------------------------------------------------------------------------------------------
    GetItemFromSortedListById = function(self, list, id)
        local i = 1
        -- lists are sorted on id (low to high) so stop when id in array >= id we search
        while list[i] ~= nil and list[i].id < id do
            i = i + 1
        end
        -- item found in list so return it
        if list[i] ~= nil and list[i].id == id then
            return list[i]
        end
        -- item not found in the list
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
        if list ~= nil and list ~= {} then
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
        if list == nil or list == {} then
            return false
        end
        local i = 1
        while list[i] ~= nil and tonumber(list[i]) ~= tonumber(number) do
            i = i + 1
        end
        return list[i] ~= nil
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
        if list == nil or list == {} then
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
        if list == nil or list == {} then
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
    -- Searches an named array to see if it contains a key for given value
    --
    -- @list            Array       The list to search
    -- @key             String      The key to search
    --
    -- return           boolean     Flag indicating if number is foundFound skill (nil if not  in list)
    ------------------------------------------------------------------------------------------------
    NamedListContainsKey = function(self, list, key)
        if list == nil or list == {} then
            return false
        end
        for k, _ in pairs(list) do
            if k == key then
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
        if array ~= nil and array ~= {} then
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
        if array ~= nil and array ~= {} then
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
        if array ~= nil and array ~= {} then
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
        if array ~= nil and array ~= {} then
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
        if array ~= nil and array ~= {} then
            table.sort(array, function(a, b) return a[property][MTSLUI_CURRENT_LANGUAGE] < b[property][MTSLUI_CURRENT_LANGUAGE] end)
        end
        return array
    end,

    ------------------------------------------------------------------------------------------------
    -- Counts the number of skills each profession has in each phase and for each specialisation
    ------------------------------------------------------------------------------------------------
    CountSkillsPerProfessionAndPhase = function(self)
        MTSL_DATA["AMOUNT_SKILLS"] = {}

        local current_phase = MTSL_DATA.MIN_PATCH_LEVEL
        -- Create the array to hold the counters
        while current_phase <= MTSL_DATA.MAX_PATCH_LEVEL do
            MTSL_DATA["AMOUNT_SKILLS"]["phase_" .. current_phase] = {}
            for prof_name, _ in pairs(MTSL_DATA["professions"]) do
                MTSL_DATA["AMOUNT_SKILLS"]["phase_" .. current_phase][prof_name] = {}
                -- each profession has a number of ranks that can be learned from trainer
                MTSL_DATA["AMOUNT_SKILLS"]["phase_" .. current_phase][prof_name]["spec_0"] = MTSL_DATA["AMOUNT_RANKS"][prof_name]
                -- add counter for each specialisation if profession has em
                if MTSL_DATA["specialisations"][prof_name] then
                    for _, specialisation in pairs(MTSL_DATA["specialisations"][prof_name]) do
                        MTSL_DATA["AMOUNT_SKILLS"]["phase_" .. current_phase][prof_name]["spec_" .. specialisation.id] = 0
                    end
                end
            end
            current_phase = current_phase + 1
        end

        local horde_id = MTSL_LOGIC_FACTION_REPUTATION:GetFactionIdByName("Horde")
        local alliance_id = MTSL_LOGIC_FACTION_REPUTATION:GetFactionIdByName("Alliance")
        local neutral_id = MTSL_LOGIC_FACTION_REPUTATION:GetFactionIdByName("Neutral")

        -- Start counting the skills for each profession
        for prof_name, prof_skills in pairs(MTSL_DATA["skills"]) do
            for _, skill in pairs(prof_skills) do
                local specialisation_id = 0
                if skill.specialisation then specialisation_id = tonumber(skill.specialisation) end
                local current_phase = 1
                if skill.phase then current_phase = skill.phase end
                -- Check if class only
                local classes = MTSL_LOGIC_SKILL:GetClassesOnlyForSkill(skill.id, prof_name)
                local class_only = false
                if self:CountItemsInArray(classes) > 0 then class_only = true end
                -- Check if faction only
                local available_horde = MTSL_LOGIC_SKILL:IsAvailableForFaction(skill.id, prof_name, horde_id)
                local available_alliance = MTSL_LOGIC_SKILL:IsAvailableForFaction(skill.id, prof_name, alliance_id)
                local available_neutral = MTSL_LOGIC_SKILL:IsAvailableForFaction(skill.id, prof_name, neutral_id)

                -- add one to each phase from current one
                while current_phase <= MTSL_DATA.MAX_PATCH_LEVEL do
                    -- if not available for either factions add 1 to other side
                    if not available_horde and not available_neutral then
                        if MTSL_DATA["AMOUNT_SKILLS"]["phase_" .. current_phase][prof_name]["spec_" .. specialisation_id .. "_alliance"] == nil then
                            MTSL_DATA["AMOUNT_SKILLS"]["phase_" .. current_phase][prof_name]["spec_" .. specialisation_id .. "_alliance"] = 1
                        else
                            MTSL_DATA["AMOUNT_SKILLS"]["phase_" .. current_phase][prof_name]["spec_" .. specialisation_id .. "_alliance"] = tonumber(MTSL_DATA["AMOUNT_SKILLS"]["phase_" .. current_phase][prof_name]["spec_" .. specialisation_id .. "_alliance"]) + 1
                        end
                    end
                    if not available_alliance and not available_neutral then
                        if MTSL_DATA["AMOUNT_SKILLS"]["phase_" .. current_phase][prof_name]["spec_" .. specialisation_id .. "_horde"] == nil then
                            MTSL_DATA["AMOUNT_SKILLS"]["phase_" .. current_phase][prof_name]["spec_" .. specialisation_id .. "_horde"] = 1
                        else
                            MTSL_DATA["AMOUNT_SKILLS"]["phase_" .. current_phase][prof_name]["spec_" .. specialisation_id .. "_horde"] = tonumber(MTSL_DATA["AMOUNT_SKILLS"]["phase_" .. current_phase][prof_name]["spec_" .. specialisation_id .. "_horde"]) + 1
                        end
                    end
                    if class_only then
                        for _, c in pairs(classes) do
                            if MTSL_DATA["AMOUNT_SKILLS"]["phase_" .. current_phase][prof_name]["spec_" .. specialisation_id .. "_" .. c] == nil then
                                MTSL_DATA["AMOUNT_SKILLS"]["phase_" .. current_phase][prof_name]["spec_" .. specialisation_id .. "_" .. c] = 1
                            else
                                MTSL_DATA["AMOUNT_SKILLS"]["phase_" .. current_phase][prof_name]["spec_" .. specialisation_id .. "_" .. c] = tonumber(MTSL_DATA["AMOUNT_SKILLS"]["phase_" .. current_phase][prof_name]["spec_" .. specialisation_id .. "_" .. c]) + 1
                            end
                        end
                    end
                    -- If not counted yet do it now
                    if (not class_only) and ((available_horde and available_alliance) or available_neutral) then
                        MTSL_DATA["AMOUNT_SKILLS"]["phase_" .. current_phase][prof_name]["spec_" .. specialisation_id] = tonumber(MTSL_DATA["AMOUNT_SKILLS"]["phase_" .. current_phase][prof_name]["spec_" .. specialisation_id]) + 1
                    end
                    -- Move to next phase
                    current_phase = current_phase + 1
                end
            end

            -- Save results to test
            MTSLUI_PLAYER["TEST_ADDON_DATA"] = MTSL_DATA["AMOUNT_SKILLS"]
        end
    end,
}
