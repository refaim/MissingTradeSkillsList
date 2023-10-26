---------------------------------------------
-- Contains all functions for a profession --
---------------------------------------------

---@shape SkillCounter
---@field trade_skill string
---@field specialisation_id number|nil
---@field amount number

---@type table<string, SkillCounter>
local skills_counters_by_key = {}

---@param trade_skill string
---@param specialisation_id number|nil
---@return string
local function make_skill_counter_key(trade_skill, specialisation_id)
    return trade_skill .. ";" .. tostring(specialisation_id or -1)
end

---@param trade_skill string
---@param specialisation_id number|nil
---@return SkillCounter
local function get_or_create_counter(trade_skill, specialisation_id)
    local counter_key = make_skill_counter_key(trade_skill, specialisation_id)
    local counter = skills_counters_by_key[counter_key]
    if counter == nil then
        counter = { trade_skill = trade_skill, specialisation_id = specialisation_id, amount = 0 }
        skills_counters_by_key[counter_key] = counter
    end
    return counter
end

MTSL_LOGIC_PROFESSION = {
    RACIAL_BONUS = 15,

    ----------------------------------------------------------------------------------------
    -- Returns the current rank learned for a profession (1 Apprentice to  4 Artisan)
    --
    -- @profession_name     String      The name of the profession
    -- @max_level           Number      The current maximum number of skill that can be learned
    --
    -- returns              Array       The array with the ids of the missing levels
    -----------------------------------------------------------------------------------------
    GetRankForProfessionByMaxLevel = function(self, profession_name, max_level)
        local ranks = self:GetRanksForProfession(profession_name)
        for _, v in pairs(ranks) do
            -- calculate Tauren racial bonus as well
            if v.max_skill == max_level or v.max_skill + self.RACIAL_BONUS == max_level then
                return v.rank
            end
        end
        -- always return lowest possible rank (for poisons)
        return 1
    end,

    -----------------------------------------------------------------------------------------------
    -- Get all the levels of a profession, ordered by rank (Apprentice, Journeyman, Expert, Artisan)
    --
    -- @profession_name     String      The name of the profession
    --
    -- returns              Array       The array with levels
    -----------------------------------------------------------------------------------------------
    GetRanksForProfession = function(self, profession_name)
        return MTSL_TOOLS:SortArrayByProperty(TRADE_SKILLS_DATA["levels"][profession_name], "rank")
    end,

    -----------------------------------------------------------------------------------------------
    -- Returns a list of skills based on the filters
    --
    -- @list_skills         Array       The list of skills to filter
    -- @profession_name     String      The name of the profession
    -- @skill_name          String      The (partial) name of the skill
    -- @source_types        Array       The sourcetypes allowed for the skill
    -- @specialisation_ids  Array       The ids of the specialisation
    -- @zone_id             Number      The id of the zone in which we must be able to learn skill (0 = all)
    -- @faction_ids         Array       The ids of the faction from which we must be able to learn skill (0 = all)
    --
    -- returns              Array       The skills passed the filter
    -----------------------------------------------------------------------------------------------
    FilterListOfSkills = function(self, list_skills, profession_name, skill_name, source_types, specialisation_ids, zone_id, faction_ids)
        local filtered_list = {}

        -- alter the skill_name now if needed
        local check_skill_name = false
        if skill_name then
            -- remove leading & trailing spaces
            skill_name = string.gsub(skill_name, "^%s*(.-)%s*$", "%1")
            -- if we still have text to search enable the flag and lowercase the text
            if string.len(skill_name) > 0 then
                check_skill_name = true
                skill_name = string.lower(skill_name)
            end
        end

        -- add all the skills
        if list_skills then
            for _, v in pairs(list_skills) do
                local skill_passed_filter = true
                -- Check if name is ok
                if check_skill_name == true then
                    local name = string.lower(MTSLUI_TOOLS:GetLocalisedData(v))
                    local start_index, _ = string.find(name, skill_name)
                    -- if we dont have a start index, the name does not contain the pattern
                    if start_index == nil then
                        skill_passed_filter = false
                    end
                end

                local spec_id = v.specialisation
                --  check specialisation (added check for no specialisation = -1)
                if v.specialisation == nil then
                    spec_id = 0
                end

                if skill_passed_filter == true and MTSL_TOOLS:ListContainsNumber(specialisation_ids, spec_id) == false then
                    skill_passed_filter = false
                end
                -- Check availability in zone
                if skill_passed_filter == true and MTSL_LOGIC_SKILL:IsSkillAvailableInZone(v, profession_name, zone_id) == false then
                    skill_passed_filter = false
                end
                -- check if source type is ok
                if skill_passed_filter == true and MTSL_LOGIC_SKILL:IsAvailableForSourceTypes(v.id, profession_name, source_types) == false then
                    skill_passed_filter = false
                end
                -- check if faction is ok
                if skill_passed_filter == true and MTSL_LOGIC_SKILL:IsAvailableForFactions(v.id, profession_name, faction_ids) == false then
                    skill_passed_filter = false
                end
                -- passed all filters so add it to list
                if skill_passed_filter then
                    table.insert(filtered_list, v)
                end
            end
        end
        return filtered_list
    end,

    -----------------------------------------------------------------------------------------------
    -- Get All the available skills and levels in a zone for one profession sorted by minimim skill
    --
    -- @profession_name     String      The name of the profession
    -- @zone_id             Number      The id of the zone in which we must be able to learn skill (0 = all)
    --
    -- return               Array       All the skills for one profession sorted by name or minimim skill
    ------------------------------------------------------------------------------------------------
    GetAllAvailableSkillsAndLevelsForProfessionInZone = function(self, profession_name, zone_id)
        local profession_skills = {}

        local arrays_to_loop = { "skills", "levels", "specialisations" }

        for _, a in pairs(arrays_to_loop) do
            if TRADE_SKILLS_DATA[a][profession_name] then
                for _, v in pairs(TRADE_SKILLS_DATA[a][profession_name]) do
                    if MTSL_LOGIC_SKILL:IsSkillAvailableInZone(v, profession_name, zone_id) then
                        table.insert(profession_skills, v)
                    end
                end
            end
        end

        -- sort the array by minimum skill
        MTSL_TOOLS:SortArrayByProperty(profession_skills, "min_skill")

        return profession_skills
    end,

    -----------------------------------------------------------------------------------------------
    -- Get All the skills and levels for one profession sorted by minimim skill (regardless the zone)
    --
    -- @prof_name           String      The name of the profession
    --
    -- return               Array       All the skills for one profession sorted by name or minimim skill
    ------------------------------------------------------------------------------------------------
    GetAllSkillsAndLevelsForProfession = function(self, profession_name)
        -- pass 0 as zone_id for all zones
        return self:GetAllAvailableSkillsAndLevelsForProfessionInZone(profession_name, 0)
    end,

    -----------------------------------------------------------------------------------------------
    -- Get All the available skills (EXCL the levels) for one profession sorted by minimim skill
    --
    -- @prof_name           String      The name of the profession
    -- @class_name          String      The name of the class of the player
    --
    -- return               Array       All the skills for one profession sorted by name or minimim skill
    ------------------------------------------------------------------------------------------------
    GetAllAvailableSkillsForProfession = function(self, profession_name, class_name)
        local profession_skills = {}

        if TRADE_SKILLS_DATA["skills"][profession_name] ~= nil then
            -- add all the skills, dont add a skill if obtainable for ohter classes
            for _, v in pairs(TRADE_SKILLS_DATA["skills"][profession_name]) do
                if v.classes == nil or (v.classes ~= nil and MTSL_TOOLS:ListContainsKeyIgnoreCasingAndSpaces(v.classes, class_name) == true) then
                    table.insert(profession_skills, v)
                end
            end
        end
        -- sort the array by minimum skill
        MTSL_TOOLS:SortArrayByProperty(profession_skills, "min_skill")

        return profession_skills
    end,

    -----------------------------------------------------------------------------------------------
    -- Gets a list of skill ids for the current craft that are learned
    --
    -- return               Array       Array containing all the ids
    ------------------------------------------------------------------------------------------------
    GetSkillIdsCurrentCraft = function(self)
        local learned_skill_ids = {}
        -- Loop all known skills
        for i=1,GetNumCrafts() do
            local _, _, skill_type = GetCraftInfo(i)
            -- Skip the headers, only check real skills
            if skill_type ~= "header" then
                local itemLink = GetCraftItemLink(i)
                local itemID = string.gfind(itemLink, "enchant:(%d+)")()
                table.insert(learned_skill_ids, itemID)
            end
        end
        -- Sort the list
        learned_skill_ids = MTSL_TOOLS:SortArrayNumeric(learned_skill_ids)
        -- return the found list
        return learned_skill_ids
    end,

    -----------------------------------------------------------------------------------------------
    -- Gets a list of localised skill names for the current tradeskill that are learned
    --
    -- return               Array       Array containing all the names
    ------------------------------------------------------------------------------------------------
    GetSkillNamesCurrentTradeSkill = function(self)
        local learned_skill_names = {}
        -- Loop all known skills
        for i=1,GetNumTradeSkills() do
            local skill_name, skill_type = GetTradeSkillInfo(i)
            -- Skip the headers, only check real skills
            if skill_name ~= nil and skill_type ~= "header" then
                table.insert(learned_skill_names, skill_name)
            end
        end
        -- return the found list
        return learned_skill_names
    end,

    -----------------------------------------------------------------------------------------------
    -- Gets a list of skill ids for the current tradeskill that are learned
    --
    -- return               Array       Array containing all the ids
    ------------------------------------------------------------------------------------------------
    GetSkillIdsCurrentTradeSkill = function(self)
        local learned_skill_ids = {}
        -- Loop all known skills
        for i=1,GetNumTradeSkills() do
            local _, skill_type = GetTradeSkillInfo(i)
            -- Skip the headers, only check real skills
            if skill_type ~= "header" then
                local itemLink = GetTradeSkillItemLink(i)
                local itemID = string.gfind(itemLink, "item:(%d+)")()
                table.insert(learned_skill_ids, itemID)
            end
        end
        -- Sort the list
        learned_skill_ids = MTSL_TOOLS:SortArrayNumeric(learned_skill_ids)
        -- return the found list
        return learned_skill_ids
    end,

    ------------------------------------------------------------------------------------------------
    -- Gets the status for a player for a skill of a Profession
    --
    -- @player              Object      The player for who to check
    -- @profession_name     String      The name of the profession
    -- @skill_id            Number      The id of the skill to search
    --
    -- return               Number      Status of the skill
    ------------------------------------------------------------------------------------------------
    IsSkillKnownForPlayer = function(self, player, profession_name, skill_id)
        local trade_skill = player.TRADESKILLS[profession_name]
        -- returns 0 if tadeskill not trained, 1 if trained but skill not learned and current skill to low, 2 if skill is learnable, 3 if skill learned
        local known_status
        if trade_skill == nil or trade_skill == 0 then
            known_status = 0
        else
            local skill_known = MTSL_TOOLS:ListContainsNumber(trade_skill.MISSING_SKILLS, skill_id)
            if skill_known == true then
                known_status = 3
            else
                -- try to find the skill
                local skill = MTSL_TOOLS:GetItemFromUnsortedListById(TRADE_SKILLS_DATA["skills"][profession_name], skill_id)
                -- its a level
                if skill == nil then
                    skill = MTSL_TOOLS:GetItemFromUnsortedListById(TRADE_SKILLS_DATA["levels"][profession_name], skill_id)
                end
                if trade_skill.SKILL_LEVEL < skill.min_skill then
                    known_status = 1
                else
                    known_status = 2
                end
            end
        end
        return known_status
    end,

    ---@param profession string
    ---@param specialisation_ids number[]
    ---@return number
    GetTotalNumberOfAvailableSkillsForProfession = function(self, profession, specialisation_ids)
        if specialisation_ids == nil then
            specialisation_ids = {}
        end

        if MTSL_TOOLS:TableEmpty(skills_counters_by_key) then
            -- TODO: there are class-only recipes (Thistle Tea, Poisons)
            for trade_skill, skills in pairs(TRADE_SKILLS_DATA["skills"]) do
                for _, skill in ipairs(skills) do
                    local counter = get_or_create_counter(trade_skill, skill.specialisation)
                    counter.amount = counter.amount + 1
                end
            end

            for trade_skill, levels in pairs(TRADE_SKILLS_DATA["levels"]) do
                local counter = get_or_create_counter(trade_skill, nil)
                counter.amount = counter.amount + getn(levels)
            end
        end

        local total_amount = 0

        local unspec_skill_counter = skills_counters_by_key[make_skill_counter_key(profession, nil)]
        if unspec_skill_counter ~= nil then
            total_amount = total_amount + unspec_skill_counter.amount
        end

        for _, counter in pairs(skills_counters_by_key) do
            local match_by_trade_skill = counter.trade_skill == profession
            local match_by_spec = MTSL_TOOLS:TableEmpty(specialisation_ids) or MTSL_TOOLS:ListContainsNumber(specialisation_ids, counter.specialisation_id)
            if match_by_trade_skill and match_by_spec then
                total_amount = total_amount + counter.amount
            end
        end

        return total_amount
    end,

    IsSpecialisationKnown = function(self, specialisation_id)
        -- TODO implement
        return false
    end,

    -----------------------------------------------------------------------------------------------
    -- Get list of specialisations for a profession
    --
    -- @profession_name     String      The name of the profession
    --
    -- return               Array       List or {}
    ------------------------------------------------------------------------------------------------
    GetSpecialisationsForProfession = function(self, profession_name)
        return TRADE_SKILLS_DATA["specialisations"][profession_name] or {}
    end,

    -----------------------------------------------------------------------------------------------
    -- Get the name of specialisation for a profession
    --
    -- @profession_name         String      The name of the profession
    -- @specialisation_id       Number      The id of the specialisation
    --
    -- return                   String      Name or nil
    ------------------------------------------------------------------------------------------------
    GetNameSpecialisation = function(self, profession_name, specialisation_id)
        local spec = MTSL_TOOLS:GetItemFromArrayByKeyValue(TRADE_SKILLS_DATA["specialisations"][profession_name], "id", specialisation_id)
        if spec ~= nil then
            return MTSLUI_TOOLS:GetLocalisedData(spec)
        end

        return ""
    end,

    -----------------------------------------------------------------------------------------------
    -- Get the name of the profession based on a skill
    --
    -- @skill               Object      The skill for which we search the profession
    --
    -- return               String      The name of the profession
    ------------------------------------------------------------------------------------------------
    GetProfessionNameBySkill = function(self, skill)
        local profession_name = ""
        -- loop each profession until we find it
        for k, _ in pairs(TRADE_SKILLS_DATA["professions"]) do
            -- loop each skill for this profession and compare to skill we seek
            local skills = self:GetAllSkillsAndLevelsForProfession(k)
            local s = 1
            while profession_name == "" and skills[s] do
                if skills[s].id == skill.id then
                    profession_name = k
                end
                -- next skill
                s = s + 1
            end
        end

        return profession_name
    end,

    GetEnglishProfessionNameFromLocalisedName = function(self, profession_name)
        local prof_name_eng = nil

        for k, v in pairs(TRADE_SKILLS_DATA["professions"]) do
            if v["name"][MTSLUI_CURRENT_LANGUAGE] == profession_name then
                prof_name_eng = k
            end
        end

        return prof_name_eng
    end,

    GetLocalisedProfessionNameFromEnglishName = function(self, profession_name)
        return TRADE_SKILLS_DATA["professions"][profession_name]["name"][MTSLUI_CURRENT_LANGUAGE]
    end,

    -----------------------------------------------------------------------------------------------
    -- Checks if a profession has a real tradeskill/craftframe or not
    --
    -- @profession_name     String      The name of the profession
    --
    -- return               Boolean     Flag for being frameless or not
    ------------------------------------------------------------------------------------------------
    IsFramelessProfession = function(self, profession_name)
        local frameless = false

        if profession_name == "Fishing" or
                profession_name == "Skinning" or
                profession_name == "Herbalism" then
            frameless = true
        end

        return frameless
    end,

    -----------------------------------------------------------------------------------------------
    -- Checks if a profession is secondary or not
    --
    -- @profession_name     String      The name of the profession
    --
    -- return               Boolean     Flag for being secondary or not
    ------------------------------------------------------------------------------------------------
    IsSecondaryProfession = function(self, profession_name)
        local secondary = false

        if profession_name == "Cooking" or
                profession_name == "First Aid" or
                profession_name == "Fishing" then
            secondary = true
        end

        return secondary
    end,

    -----------------------------------------------------------------------------------------------
    -- Gets a list of auto learned skills for a profession
    --
    -- @profession_name     String      The name of the profession
    --
    -- return               Array       The list of auto learned skills (id)
    ------------------------------------------------------------------------------------------------
    GetAutoLearnedSkillsForProfession = function(self, profession_name)
        local auto_learned = {}

        -- Make sure the profession has skills (herb/skin/fish do not)
        if TRADE_SKILLS_DATA["skills"][profession_name] ~= nil then
            for _, v in pairs(TRADE_SKILLS_DATA["skills"][profession_name]) do
               if v.special_action and v.special_action == "auto learned" then
                   table.insert(auto_learned, v.id)
               end
            end
        end

        return auto_learned
    end,

    -----------------------------------------------------------------------------------------------
    -- Gets a list of auto learned skills for a profession
    --
    -- @profession_name     String      The name of the profession
    --
    -- return               Array       The list of auto learned skills (id)
    ------------------------------------------------------------------------------------------------
    GetAutoLearnedLevelForProfession = function(self, profession_name)
        local auto_learned_level = nil

        for _, v in pairs(TRADE_SKILLS_DATA["levels"][profession_name]) do
            if v.rank == 1 then
                auto_learned_level = v.id
            end
        end

        return auto_learned_level
    end,
}
