------------------------------------------
-- Contains all functions for the world --
------------------------------------------

MTSL_LOGIC_WORLD = {
    ------------------------------------------------------------------------------------------------
    -- Returns a zone by name
    --
    -- @name        String      The name of the zone
    --
    -- returns      Array       The continent
    ------------------------------------------------------------------------------------------------
    GetZoneByName = function(self, name)
        return MTSL_TOOLS:GetItemFromLocalisedArrayByKeyValue(TRADE_SKILLS_DATA["zones"], "name", name)
    end,

    ------------------------------------------------------------------------------------------------
    -- Returns the name (localised) of a zone by id
    --
    -- @zone_id     Number      The id of the zone
    --
    -- returns      String      The localised name of the zone
    ------------------------------------------------------------------------------------------------
    GetZoneNameById = function(self, zone_id)
        local zone = MTSL_TOOLS:GetItemFromArrayByKeyValue(TRADE_SKILLS_DATA["zones"], "id", zone_id)
        if zone then
            return MTSLUI_TOOLS:GetLocalisedData(zone)
        end
        return ""
    end,

    ------------------------------------------------------------------------------------------------
    -- Returns the zone by id
    --
    -- @zone_id     Number      The id of the zone
    --
    -- returns      Object      The zone
    ------------------------------------------------------------------------------------------------
    GetZoneId = function(self, id)
        return MTSL_TOOLS:GetItemFromArrayByKeyValue(TRADE_SKILLS_DATA["zones"], "id", id)
    end,

    ------------------------------------------------------------------------------------------------
    -- Returns a list of Zones for a contintent by id
    --
    -- @continent_id      Number      The id of the contintent
    --
    -- returns              Array       The zones
    ------------------------------------------------------------------------------------------------
    GetZonesInContinentById = function(self, continent_id)
        local zones_continent = MTSL_TOOLS:GetAllItemsFromArrayByKeyValue(TRADE_SKILLS_DATA["zones"], "cont_id", continent_id)
        return MTSL_TOOLS:SortArrayByLocalisedProperty(zones_continent, "name")
    end,

    ------------------------------------------------------------------------------------------------
    -- Check is zone is a "real" zone (so no BG, dung or raid)
    --
    -- @zone_id     Number      The id of the zone
    --
    -- returns      Number      Flag indicating if real zone (= 1) or not (= 0)
    ------------------------------------------------------------------------------------------------
    IsRealZone = function(self, zone_id)
        local zone = MTSL_TOOLS:GetItemFromArrayByKeyValue(TRADE_SKILLS_DATA["zones"], "id", zone_id)
        local real_zone = 0
        if zone and zone.cont_id < 3 then
            real_zone = 1
        end
        return real_zone
    end,
}
