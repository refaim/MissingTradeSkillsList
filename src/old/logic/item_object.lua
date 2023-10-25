--------------------------------------------------
-- Contains all functions for an item or object --
--------------------------------------------------

MTSL_LOGIC_ITEM_OBJECT = {
    -----------------------------------------------------------------------------------------------
    -- Gets a list of all objects (based on their ids)
    --
    -- @ids                 Array       The ids of objects to search
    --
    -- return               Array       List of found items
    ------------------------------------------------------------------------------------------------
    GetObjectsByIds = function(self, ids)
        local objects = {}

        for _, id in pairs(ids)
        do
            local object = self:GetObjectById(id)
            -- If we found one add to list
            if object ~= nil then
                table.insert(objects, object)
            else
                MTSL_TOOLS:Print(MTSLUI_FONTS.COLORS.TEXT.ERROR .. "MTSL: Could not find object with id " .. id .. ". Please report this bug!")
            end
        end

        -- Return the found objects sorted by localised name
        return MTSL_TOOLS:SortArrayByLocalisedProperty(objects, "name")
    end,

    -----------------------------------------------------------------------------------------------
    -- Gets an object (based on it's id)
    --
    -- @id              Number      The id of the item to search
    --
    -- return           Object      Found item (nil if not found)
    ------------------------------------------------------------------------------------------------
    GetObjectById = function(self, id)
        return MTSL_TOOLS:GetItemFromArrayByKeyValue(TRADE_SKILLS_DATA["objects"], "id", id)
    end,

    -----------------------------------------------------------------------------------------------
    -- Gets a list of all items (based on their ids)
    --
    -- @ids                 Array       The ids of items to search
    -- @profession_name     String      The name of the profession
    --
    -- return               Array       List of found items
    ------------------------------------------------------------------------------------------------
    GetItemsForProfessionByIds = function(self, ids, profession_name)
        local items = {}

        for _, id in pairs(ids)
        do
            local item = self:GetItemForProfessionById(id, profession_name)
            -- If we found one add to list
            if item ~= nil then
                table.insert(items, item)
            else
                MTSL_TOOLS:Print(MTSLUI_FONTS.COLORS.TEXT.ERROR .. "MTSL: Could not find item with id " .. id .. " for " .. profession_name .. ". Please report this bug!")
            end
        end

        -- Return the found items sorted by localised name
        return MTSL_TOOLS:SortArrayByLocalisedProperty(items, "name")
    end,

    -----------------------------------------------------------------------------------------------
    -- Gets an item (based on it's id)
    --
    -- @id                  Number      The id of the item to search
    -- @profession_name     String      The name of the profession
    --
    -- return               Object      Found item (nil if not found)
    ------------------------------------------------------------------------------------------------
    GetItemForProfessionById = function(self, id, profession_name)
        return MTSL_TOOLS:GetItemFromArrayByKeyValue(TRADE_SKILLS_DATA["items"][profession_name], "id", id)
    end,
}
