--------------------------------------------------------
-- Contains all functions for a skill of a profession --
--------------------------------------------------------

MTSL_LOGIC_SKILL = {
    ----------------------------------------------------------------------------------------
    -- Checks if a skill is available in this content phase
    --
    -- @skill               Object          The skill
    -- @profession_name     String          The name of the profession
    -- @max_phase           Number          The number of content phase that is maximal allowed
    --
    -- return               Boolean         Flag indicating availability
    -----------------------------------------------------------------------------------------
    IsSkillAvailableInPhase = function(self, skill, max_phase)
        return tonumber(skill.phase) <= tonumber(max_phase)
    end,

    ----------------------------------------------------------------------------------------
    -- Checks if a skill is available in a certain zone
    --
    -- @skill               Object          The skill
    -- @profession_name     String          The name of the profession
    -- @zone_id             Number          The id of the zone (0 = all)
    --
    -- return               Boolean         Flag indicating availability
    -----------------------------------------------------------------------------------------
    IsSkillAvailableInZone = function(self, skill, profession_name, zone_id)
        local available = true
        -- check fot at least one source in the zone (skip zone if id = 0 => all are good)
        if zone_id ~= 0 then
            local at_least_one_source = false
            -- if trainers, loop em
            if skill.trainers ~= nil then
                local npcs = MTSL_LOGIC_PLAYER_NPC:GetNpcsByIds(skill.trainers.sources)
                at_least_one_source = self:HasAtleastOneNpcInZoneById(npcs, zone_id)
            end
            -- keep going if still no valid source found
            if not at_least_one_source and skill.quests then
                at_least_one_source = self:HasAtleastOneObtainableQuestInZone(skill.quests, profession_name, zone_id)
            end
            -- keep going if still no valid source found
            if not at_least_one_source and skill.objects then
                at_least_one_source = self:HasAtleastOneObtainableObjectInZone(skill.objects, zone_id)
            end
            -- keep going if still no valid source found
            if not at_least_one_source and skill.items then
                at_least_one_source = self:HasAtleastOneObtainableItemInZone(skill.items, profession_name, zone_id)
            end
            available = at_least_one_source
        end
        return available
    end,

    ----------------------------------------------------------------------------------------
    -- Checks if a at least one npc is located in a certain zone
    --
    -- @npcs                Array           The list of NPCs
    -- @zone_id             Number          The id of the zone
    --
    -- return               Boolean         Flag indicating if at least one is found
    -----------------------------------------------------------------------------------------
    HasAtleastOneNpcInZoneById = function(self, npcs, zone_id)
        -- Get the first npc found for the given zone
        local npc = MTSL_TOOLS:GetItemFromArrayByKeyValue(npcs, "zone_id", zone_id)
        -- return if we found one or not
        return npc ~= nil
    end,

    ----------------------------------------------------------------------------------------
    -- Checks if at least one of the quests is available in a certain zone
    --
    -- @quest_ids           Array           Contains all different quest_ids (Alliance and horde can have different ones)
    -- @zone_id             Number          The id of the zone (0 = all)
    --
    -- return               Boolean         Flag indicating obtainable
    -----------------------------------------------------------------------------------------
    HasAtleastOneObtainableQuestInZone = function(self, quest_ids, tradeskill_name, zone_id)
        local quest = MTSL_LOGIC_QUEST:GetQuestByIds(quest_ids)
        -- Quest has many sources (npcs, objects or items)
        -- check npcs
        local is_obtainable = false
        if quest then
            if quest.npcs then
                local npcs = MTSL_LOGIC_PLAYER_NPC:GetNpcsByIds(quest.npcs)
                is_obtainable = self:HasAtleastOneNpcInZoneById(npcs, zone_id)
            end
            -- Check objects
            if not is_obtainable and quest.objects then
                is_obtainable = self:HasAtleastOneObtainableObjectInZone(quest.objects, zone_id)
            end
            -- check items
            if not is_obtainable and quest.items then
                is_obtainable = self:HasAtleastOneObtainableItemInZone(quest.items, tradeskill_name, zone_id)
            end
        end

        return is_obtainable
    end,

    ----------------------------------------------------------------------------------------
    -- Checks if at least one of the objects is available in a certain zone
    --
    -- @item_ids            Array           Contains the ids of the items to check
    -- @zone_id             Number          The id of the zone (0 = all)
    --
    -- return               Boolean         Flag indicating obtainable
    -----------------------------------------------------------------------------------------
    HasAtleastOneObtainableObjectInZone = function(self, object_ids, zone_id)
        local objects = MTSL_LOGIC_ITEM_OBJECT:GetObjectsByIds(object_ids)
        local object = MTSL_TOOLS:GetItemFromArrayByKeyValue(objects, "zone_id", zone_id)
        return object ~= nil
    end,

    ----------------------------------------------------------------------------------------
    -- Checks if at least one of the items is available in a certain zone
    --
    -- @item_ids            Array           Contains the ids of the items to check
    -- @profession_name     String          The name of the profession for which the item is valid
    -- @zone_id             Number          The id of the zone (0 = all)
    --
    -- return               Boolean         Flag indicating obtainable
    -----------------------------------------------------------------------------------------
    HasAtleastOneObtainableItemInZone = function(self, item_ids, profession_name, zone_id)
        local i = 1
        local is_obtainable = false
        while item_ids[i] and is_obtainable == false do
            local skill_item = MTSL_LOGIC_ITEM_OBJECT:GetItemForProfessionById(item_ids[i], profession_name)
            if skill_item then
                -- item has many sources (drops, quests, vendors, object)
                -- check quests
                if skill_item.quests then
                    is_obtainable = self:HasAtleastOneObtainableQuestInZone(skill_item.quests, profession_name, zone_id)
                end
                -- check vendors
                if not is_obtainable and skill_item.vendors then
                    local vendors = MTSL_LOGIC_PLAYER_NPC:GetNpcsByIds(skill_item.vendors.sources)
                    is_obtainable = self:HasAtleastOneNpcInZoneById(vendors, zone_id)
                end
                -- check drops only if not a world drop
                if not is_obtainable and skill_item.drops then
                    -- World drop
                    if skill_item.drops.range then
                        -- check if the zone levels are in range of the drop range mobs
                        local zone = MTSL_LOGIC_WORLD:GetZoneId(zone_id)
                        if zone.levels then
                            if (tonumber(zone.levels.min) > tonumber(skill_item.drops.range.max_xp_level) or
                                    tonumber(zone.levels.max) < tonumber(skill_item.drops.range.min_xp_level)) then
                                is_obtainable = false
                            else
                                is_obtainable = true
                            end
                        else
                            is_obtainable = false
                        end
                        -- Drop mobs
                    else
                        local mobs = MTSL_LOGIC_PLAYER_NPC:GetMobsByIds(skill_item.drops.sources)
                        is_obtainable = self:HasAtleastOneNpcInZoneById(mobs, zone_id)
                    end
                end
                -- check objects
                if not is_obtainable and skill_item.objects then
                    is_obtainable = self:HasAtleastOneObtainableObjectInZone(skill_item.objects, zone_id)
                end
            end
            i = i + 1
        end
        return is_obtainable
    end,

    ------------------------------------------------------------------------------------------------
    -- Returns a skill for a certain profession based on the recipe id its learned from
    --
    -- @item_id         Number      The id of the item (source of the skill)
    -- @prof_name       String      Name of the profession
    --
    -- returns          Array       The skills
    ------------------------------------------------------------------------------------------------
    GetSkillForProfessionByItemId = function(self, item_id, profession_name)
        local skill = MTSL_TOOLS:GetItemFromArrayByKeyArrayValue(MTSL_DATA["skills"][profession_name], "items", item_id)
        -- try a level if nil
        if skill == nil then
            skill = MTSL_TOOLS:GetItemFromArrayByKeyArrayValue(MTSL_DATA["levels"][profession_name], "items", item_id)
        end
        return skill
    end,

    ------------------------------------------------------------------------------------------------
    -- Returns a skill for a certain profession by id
    --
    -- @skill_id        Number      The id of the skill
    -- @prof_name       String      Name of the profession
    --
    -- returns          Skill       The skill
    ------------------------------------------------------------------------------------------------
    GetSkillForProfessionById = function(self, skill_id, profession_name)
        local skill = MTSL_TOOLS:GetItemFromArrayByKeyValue(MTSL_DATA["skills"][profession_name], "id", skill_id)
        -- try a level if nil
        if skill == nil then
            skill = MTSL_TOOLS:GetItemFromArrayByKeyValue(MTSL_DATA["levels"][profession_name], "id", skill_id)
        end
        return skill
    end,

    ------------------------------------------------------------------------------------------------
    -- Returns a list of source types for a skill for a certain profession by id
    --
    -- @skill_id            Number      The id of the skill
    -- @profession_name     String      Name of the profession
    --
    -- returns              Array       The sourcetypes
    ------------------------------------------------------------------------------------------------
    GetSourcesForSkillForProfessionById = function(self, skill_id, profession_name)
        local source_types = {}
        local skill = MTSL_TOOLS:GetItemFromArrayByKeyValue(MTSL_DATA["skills"][profession_name], "id", skill_id)
        -- try a level if nil
        if skill == nil then
            skill = MTSL_TOOLS:GetItemFromArrayByKeyValue(MTSL_DATA["levels"][profession_name], "id", skill_id)
        end
        if skill then
            if skill.quests then
                table.insert(source_types, "quest")
            end
            -- if learned from item, determine the source types based on the item source
            if skill.items then
                local item = MTSL_LOGIC_ITEM_OBJECT:GetItemForProfessionById(skill.items[1], profession_name)
                if item then
                    if item.vendors then
                        table.insert(source_types, "vendor")
                    end
                    if item.quests then
                        table.insert(source_types, "quest")
                    end
                    if item.drops then
                        table.insert(source_types, "drop")
                    end
                    -- if only obtainable during holiday event
                    if item.holiday then
                        table.insert(source_types, "holiday")
                    end
                    -- object
                    if item.objects then
                        table.insert(source_types, "object")
                    end
                end
            end
            -- if we learned from object
            if skill.objects then
                table.insert(source_types, "object")
            end
            -- if only obtainable during holiday event
            if skill.holiday then
                table.insert(source_types, "holiday")
            end
            -- default source type is trainer, if no other source type is found
            if MTSL_TOOLS:CountItemsInArray(source_types) <= 0 then
                table.insert(source_types, "trainer")
            end
        end

        return source_types
    end,

    ----------------------------------------------------------------------------------------
    -- Returns a list of classes who can exclusive obtain recipe
    --
    -- @skill_id            Number      The id of the skill
    -- @profession_name     String      Name of the profession
    --
    -- return               Array       List of exclusive factions (empty if none)
    ----------------------------------------------------------------------------------------
    GetClassesOnlyForSkill = function(self, skill_id, profession_name)
        local classes = {}
        local skill = MTSL_TOOLS:GetItemFromArrayByKeyValue(MTSL_DATA["skills"][profession_name], "id", skill_id)
        -- try a level if nil
        if skill == nil then
            skill = MTSL_TOOLS:GetItemFromArrayByKeyValue(MTSL_DATA["levels"][profession_name], "id", skill_id)
        end
        if skill then
            self:AddClassesToList(skill, classes)
            -- if learned from item, determine the source types based on the item source
            if skill.items then
                local items = MTSL_LOGIC_ITEM_OBJECT:GetItemsForProfessionByIds(skill.items, profession_name)

                for _, item in pairs(items) do
                    self:AddClassesToList(item, classes)

                    if item.quests then
                        -- loop all quests
                        for _, v in pairs(item.quests) do
                            local quest = MTSL_TOOLS:GetItemFromUnsortedListById(MTSL_DATA["quests"], v)
                            if quest then
                                self:AddClassesToList(quest, classes)
                            end
                        end
                    end

                    -- if we learned from object
                    if item.objects then
                        local objects = MTSL_LOGIC_ITEM_OBJECT:GetObjectsByIds(item.objects)

                        for _, object in pairs(objects) do
                            self:AddClassesToList(object, classes)
                        end
                    end

                    if item.quests then
                        -- loop all quests
                        for _, v in pairs(item.quests) do
                            local quest = MTSL_TOOLS:GetItemFromUnsortedListById(MTSL_DATA["quests"], v)
                            if quest then
                                self:AddClassesToList(quest, classes)
                            end
                        end
                    end
                end
            end
            -- if we learned from object
            if skill.objects then
                local objects = MTSL_LOGIC_ITEM_OBJECT:GetObjectsByIds(skill.objects)

                for _, object in pairs(objects) do
                    self:AddClassesToList(object, classes)
                end
            end
        end

        -- convert table
        unique_classes = {}

        for class, _ in pairs(classes) do
            table.insert(unique_classes, class)
        end

        return unique_classes
    end,

    -- Private method to add classes
    AddClassesToList = function(self, object, classes)
        if object.classes then
            local i = 1
            -- lists are sorted on id (low to high)
            while object.classes[i] ~= nil do
                classes[object.classes[i]] = 1
                i = i + 1
            end
        end
    end,

    ----------------------------------------------------------------------------------------
    -- Checks if at skill is avaiable through a source type
    --
    -- @skill_id            Number      The id of the skill
    -- @profession_name     String      Name of the profession
    -- @source_type         String      The type of source want
    --
    -- return               Boolean     Flag indicating obtainable
    -----------------------------------------------------------------------------------------
    IsAvailableForSourceType = function(self, skill_id, profession_name, source_type)
        local source_types = self:GetSourcesForSkillForProfessionById(skill_id, profession_name)
        return MTSL_TOOLS:ListContainsKey(source_types, source_type)
    end,

    ----------------------------------------------------------------------------------------
    -- Checks if at skill is avaiable through at least one given source type
    --
    -- @skill_id            Number      The id of the skill
    -- @profession_name     String      Name of the profession
    -- @source_types        Array       The types of source wanted
    --
    -- return               Boolean     Flag indicating obtainable
    -----------------------------------------------------------------------------------------
    IsAvailableForSourceTypes = function(self, skill_id, profession_name, source_types)
        local skill_source_types = self:GetSourcesForSkillForProfessionById(skill_id, profession_name)
        for _, wanted_source_type in pairs(source_types) do
            if MTSL_TOOLS:ListContainsKey(skill_source_types, wanted_source_type) == true then
                return true
            end
        end
        return false
    end,

    ------------------------------------------------------------------------------------------------
    -- Returns a list of factions for a skill for a certain profession by id
    --
    -- @skill_id            Number      The id of the skill
    -- @profession_name     String      Name of the profession
    --
    -- returns              Array       The factions
    ------------------------------------------------------------------------------------------------
    GetFactionsForSkillForProfessionById = function(self, skill_id, profession_name)
        local faction_ids = { 59, 270, 529, 576, 609, 469, 67, MTSL_LOGIC_FACTION_REPUTATION.FACTION_ID_ALLIANCE_AND_HORDE, MTSL_LOGIC_FACTION_REPUTATION.FACTION_ID_NEUTRAL }

        local factions = {}
        -- loop all factions and set flag to 0
        for _, fid in pairs(faction_ids) do
            table.insert(factions, fid)
            factions[fid] = 0
        end

        local skill = MTSL_TOOLS:GetItemFromArrayByKeyValue(MTSL_DATA["skills"][profession_name], "id", skill_id)
        -- try a level if nil
        if skill == nil then
            skill = MTSL_TOOLS:GetItemFromArrayByKeyValue(MTSL_DATA["levels"][profession_name], "id", skill_id)
        end
        -- if we find the skill of the profession, search for factions
        if skill then
            -- loop trainers
            if skill.trainers then
                local trainers = MTSL_LOGIC_PLAYER_NPC:GetNpcsIgnoreFactionByIds(skill.trainers.sources)
                for _, t in pairs(trainers) do
                    self:AddFactionForDataToArray(factions, t)
                end
            end
            if skill.objects then
                factions[MTSL_LOGIC_FACTION_REPUTATION.FACTION_ID_ALLIANCE_AND_HORDE] = 1
            end
            -- try reputation/reacts on skill itself
            self:AddFactionForDataToArray(factions, skill)
            -- if learned from item, add the factions based on the item source
            if skill.items then
                local item = MTSL_LOGIC_ITEM_OBJECT:GetItemForProfessionById(skill.items[1], profession_name)
                if item then
                    self:AddFactionForDataToArray(factions, item)
                    if item.vendors then
                        local vendors = MTSL_LOGIC_PLAYER_NPC:GetNpcsIgnoreFactionByIds(item.vendors.sources)
                        -- loop all the vendors
                        for _, v in pairs(vendors) do
                            self:AddFactionForDataToArray(factions, v)
                        end
                    end
                    -- it is is a drop of mobs or learned from object or special action, add both alliance and horde
                    if item.drops or item.objects or item.special_action then
                        factions[MTSL_LOGIC_FACTION_REPUTATION.FACTION_ID_ALLIANCE_AND_HORDE] = 1
                    end
                    -- if its from quest, add NPC/questgivers
                    if item.quests then
                        -- loop all quests
                        for _, v in pairs(item.quests) do
                            local quest = MTSL_TOOLS:GetItemFromUnsortedListById(MTSL_DATA["quests"], v)
                            if quest then
                                self:AddFactionForDataToArray(factions, quest)
                                -- loop all the NPC/questgivers
                                if quest.npcs then
                                    local npcs = MTSL_LOGIC_PLAYER_NPC:GetNpcsIgnoreFactionByIds(quest.npcs)
                                    -- loop all the vendors
                                    for _, n in pairs(npcs) do
                                        self:AddFactionForDataToArray(factions, n)
                                    end
                                    -- no questgivers so assume alliance and horde can get it
                                else
                                    factions[MTSL_LOGIC_FACTION_REPUTATION.FACTION_ID_ALLIANCE_AND_HORDE] = 1
                                end
                            end
                        end
                    end
                end
            end
            -- if we learned from object
            if skill.quests then
                -- loop all quests
                for _, v in pairs(skill.quests) do
                    local quest = MTSL_TOOLS:GetItemFromUnsortedListById(MTSL_DATA["quests"], v)
                    if quest then
                        self:AddFactionForDataToArray(factions, quest)
                        -- loop all the NPC/questgivers
                        if quest.npcs then
                            local npcs = MTSL_LOGIC_PLAYER_NPC:GetNpcsIgnoreFactionByIds(quest.npcs)
                            -- loop all the vendors
                            for _, n in pairs(npcs) do
                                self:AddFactionForDataToArray(factions, n)
                            end
                        -- no questgivers so assume alliance and horde can get it
                        else
                            factions[MTSL_LOGIC_FACTION_REPUTATION.FACTION_ID_ALLIANCE_AND_HORDE] = 1
                        end
                    end
                end
            end
        end

        -- if both alliance and horde are flagged using id, undo it and mark the combined id
        if factions[67] == 1 and factions[469] == 1 then
            factions[67] = 0
            factions[469] = 0
            factions[MTSL_LOGIC_FACTION_REPUTATION.FACTION_ID_ALLIANCE_AND_HORDE] = 1
        end

        -- now convert array to only contain the factions with value = 1
        local factions_found = {}

        for k, v in pairs(factions) do
            if v == 1 then table.insert(factions_found, k) end
        end

        -- add alliance and horde if we did not find any
        if MTSL_TOOLS:CountItemsInArray(factions_found) <= 0 then
            table.insert(factions_found, MTSL_LOGIC_FACTION_REPUTATION.FACTION_ID_ALLIANCE_AND_HORDE)
        end

        return factions_found
    end,

    AddFactionForDataToArray = function (self, array, data)
        if data.reputation then
            array[tonumber(data.reputation.faction_id)] = 1
        else
            if data.reacts then
                array[tonumber(MTSL_LOGIC_FACTION_REPUTATION:GetFactionIdByName(data.reacts))] = 1
            end
        end
    end,

    ----------------------------------------------------------------------------------------
    -- Checks if at skill is available through a faction
    --
    -- @skill_id            Number      The id of the skill
    -- @profession_name     String      Name of the profession
    -- @faction_id          Number      The id of the faction from which we must be able to learn skill (0 = all)
    --
    -- return               Boolean     Flag indicating obtainable
    -----------------------------------------------------------------------------------------
    IsAvailableForFaction = function(self, skill_id, profession_name, faction_id)
        local factions = self:GetFactionsForSkillForProfessionById(skill_id, profession_name)
        return MTSL_TOOLS:ListContainsNumber(factions, tonumber(faction_id))
    end,

    ----------------------------------------------------------------------------------------
    -- Checks if at skill is available through at least one given faction
    --
    -- @skill_id            Number      The id of the skill
    -- @profession_name     String      Name of the profession
    -- @faction_ids         Array       The ids of the faction from which we must be able to learn skill (0 = all)
    --
    -- return               Boolean     Flag indicating obtainable
    -----------------------------------------------------------------------------------------
    IsAvailableForFactions = function(self, skill_id, profession_name, faction_ids)
        local factions = self:GetFactionsForSkillForProfessionById(skill_id, profession_name)
        for _, wanted_faction_id in pairs(faction_ids) do
            if MTSL_TOOLS:ListContainsNumber(factions, tonumber(wanted_faction_id)) == true then
                return true
            end
        end
        return false
    end,

    ----------------------------------------------------------------------------------------
    -- Checks if at skill is avaiable through an id of a npc
    --
    -- @profession_name     String      The name of the profession
    -- @skill               Object      The skill to check
    -- @npc_id              Number      The id of the npc
    --
    -- return               Boolean     Flag indicating obtainable
    -----------------------------------------------------------------------------------------
    IsObtainableFromNpcById = function(self, profession_name, skill, npc_id)
        local obtainable = false
        -- Check if npc_id is contained in list of trainers if there are
        if skill.trainers and MTSL_TOOLS:ListContainsNumber(skill.trainers.sources, npc_id) then
            obtainable = true
        end
        -- Check if questgiver
        if not obtainable and skill.quests then
            -- loop each quest
            for _, v in pairs(skill.quests) do
                local quest = MTSL_LOGIC_QUEST:GetQuestById(v)
                if quest ~= nil and quest.npcs ~= nil and MTSL_TOOLS:ListContainsNumber(quest.npcs, npc_id) then
                    obtainable = true
                end
            end
        end
        -- check if learned from item
        if not obtainable and skill.item then
            local item = MTSL_LOGIC_ITEM_OBJECT:GetItemForProfessionById(skill.items[1], profession_name)
            if item then
                -- npc can be a mob that drops it or vendor
                if ((item.drops and item.drops.sources and MTSL_TOOLS:ListContainsNumber(item.drops.sources, npc_id))
                        or (item.vendors and MTSL_TOOLS:ListContainsNumber(item.vendors.sources, npc_id))) then
                    obtainable = true
                end
            end
            -- or questgiver
            if not obtainable and item and item.quests then
                for _, v in pairs(item.quests) do
                    local quest = MTSL_LOGIC_QUEST:GetQuestById(v)
                    if quest and quest.npcs and MTSL_TOOLS:ListContainsNumber(quest.npcs, npc_id) then
                        obtainable = true
                    end
                end
            end
        end
        -- return the status we found
        return obtainable
    end
}
