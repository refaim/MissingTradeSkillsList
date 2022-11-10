-----------------------------------------
-- Contains all functions for a player --
-----------------------------------------

-- Shared/saved variable
MTSL_PLAYERS = {}

-- Holds info about the current logged in player
-- Contains following info once loaded from data
--      NAME,
--      FACTION,
--      REALM,
--      XP_LEVEL,
--      TRADESKILLS = {}
MTSL_CURRENT_PLAYER = {}

MTSL_LOGIC_PLAYER_NPC = {
    ---------------------------------------------------------------------------------------
    -- Loads the saved data of the logged in player or creates a new save
    -- Triggerd by game event "PLAYER_LOGIN"
    ---------------------------------------------------------------------------------------
    LoadPlayer = function(self)
        local name = UnitName("player")
        local realm = GetRealmName()
        local faction = UnitFactionGroup("player")
        local xp_level = UnitLevel("player")
        -- ignore first return since its localised
        local _, player_class = UnitClass("player")

        if name == nil then return "name" end
        if realm == nil then return "realm" end
        if faction == nil then return "faction" end
        if xp_level == nil then return "xp_level" end
        if player_class == nil then return "player_class" end

        -- First time we save a character, so create a new array
        if not MTSL_PLAYERS then
            MTSL_PLAYERS = {}
        end

        -- Check if realm exits
        if not MTSL_PLAYERS[realm] then
            MTSL_PLAYERS[realm] = {}
        end

        -- try and load the player
        local current_player = MTSL_PLAYERS[realm][name]

        local return_code

        -- Player was saved before, so load it
        if current_player then
            current_player = MTSL_PLAYERS[realm][name]

            -- Update class, faction & xp_level, just in case
            MTSL_CURRENT_PLAYER.CLASS = string.lower(player_class)
            MTSL_CURRENT_PLAYER.XP_LEVEL = xp_level
            MTSL_CURRENT_PLAYER.FACTION = faction

            return_code = "existing"
            -- new player so create it and add it
        else
            -- Not found so create a new one
            current_player = {
                NAME = name,
                REALM = realm,
                FACTION = faction,
                XP_LEVEL = xp_level,
                CLASS = player_class,
                TRADESKILLS = {},
            }
            -- new player added so sort the table (first the realms, then for new realm, sort by name
            MTSL_PLAYERS[realm][name] = current_player
            MTSL_TOOLS:SortArray(MTSL_PLAYERS)
            MTSL_TOOLS:SortArrayByProperty(MTSL_PLAYERS[realm], "name")

            return_code = "new"
        end

        -- set the loaded or created player as current one
        MTSL_CURRENT_PLAYER = current_player

        self:CheckSavedProfessions()
        self:RemoveUnlearnedProfessions()
        self:UpdatePlayerSkillLevels()

        return return_code
    end,


    ------------------------------------------------------------------------------------------------
    --- Update the XP level & faction of a player (called after a "ding")
    ------------------------------------------------------------------------------------------------
    UpdatePlayerInfo = function(self)
        local faction = UnitFactionGroup("player")
        local xp_level = UnitLevel("player")

        MTSL_CURRENT_PLAYER.XP_LEVEL = xp_level
        MTSL_CURRENT_PLAYER.FACTION = faction
    end,

    ------------------------------------------------------------------------------------------------
    -- Scan the skillframe to update skill levels
    ------------------------------------------------------------------------------------------------
    UpdatePlayerSkillLevels = function(self)
        local i = 1

        while GetSkillLineInfo(i) ~= nil  do
            local skilldata = {GetSkillLineInfo(i)}
            -- Skip header rows
            if skilldata[2] ~= 1 then
                local profession_name = MTSL_LOGIC_PROFESSION:GetEnglishProfessionNameFromLocalisedName(skilldata[1])
                -- only trigger event if its a trade_skill supported by the addon
                if profession_name ~= nil then
                    if MTSL_CURRENT_PLAYER.TRADESKILLS[profession_name] == nil then
                        self:AddNewProfession(profession_name, skilldata[4])
                    else
                        MTSL_CURRENT_PLAYER.TRADESKILLS[profession_name]["SKILL_LEVEL"] = skilldata[4]
                    end

                    -- Update profession without tradeskill/Craft frame
                    if MTSL_LOGIC_PROFESSION:IsFramelessProfession(profession_name) == true then
                        self:UpdateMissingSkillsForProfessionCurrentPlayer(profession_name, skilldata[4], skilldata[7])
                    end
                end
            end
            i = i + 1
        end
    end,

    ------------------------------------------------------------------------------------------------
    -- Checks if the saved data of profession is correct, if not remove the profession
    ------------------------------------------------------------------------------------------------
    CheckSavedProfessions = function(self)
        if MTSL_CURRENT_PLAYER.TRADESKILLS ~= nil and MTSL_CURRENT_PLAYER.TRADESKILLS ~= {} then
            for k, v in pairs(MTSL_CURRENT_PLAYER.TRADESKILLS) do
               if type(v) ~= "table" or v.NAME == nil or v.SKILL_LEVEL == nil or v.AMOUNT_MISSING == nil or v.AMOUNT_LEARNED == nil or
                       v.SPELLIDS_SPECIALISATION == nil or v.MISSING_SKILLS == nil or v.LEARNED_SKILLS == nil then
                   MTSL_CURRENT_PLAYER.TRADESKILLS[k] = nil
               end
            end
       end
    end,

    ------------------------------------------------------------------------------------------------
    -- Scan the skillframe to add a new learned profession to saved data
    ------------------------------------------------------------------------------------------------
    AddLearnedProfessions = function(self)
        local i = 1

        local have_learned_profession = false

        -- loop all the skill lines
        while GetSkillLineInfo(i) ~= nil do
            local skilldata = {GetSkillLineInfo(i) }
            -- Skip header rows
            if skilldata[2] ~= 1 then
                local profession_name = MTSL_LOGIC_PROFESSION:GetEnglishProfessionNameFromLocalisedName(skilldata[1])
                -- only trigger event if its a trade_skill supported by the addon and  we dont know it yet
                if profession_name ~= nil then
                    if MTSL_CURRENT_PLAYER.TRADESKILLS[profession_name] == nil then
                        self:AddNewProfession(profession_name, skilldata[4])
                        have_learned_profession = true
                    end
                end
            end
            i = i + 1
        end

        return have_learned_profession
    end,

    AddNewProfession = function(self, profession_name, current_skill_level)
        -- add the profession and its "basic" skills (the ones u auto learn)
        -- Reset any previously saved skills
        MTSL_CURRENT_PLAYER.TRADESKILLS[profession_name] = {
            ["NAME"] = profession_name,
            ["SKILL_LEVEL"] = tonumber(current_skill_level),
            -- Array because you can learn 2 specialisations as Blacksmith
            -- default empty since cant have learned specialisation when learning a new profession
            ["SPELLIDS_SPECIALISATION"] = {},
            ["AMOUNT_MISSING"] = 0,
            ["AMOUNT_LEARNED"] = 0,
            ["MISSING_SKILLS"] = {},
            ["LEARNED_SKILLS"] = {},
        }
        -- Add the auto learned level
        local learned_rank = MTSL_LOGIC_PROFESSION:GetAutoLearnedLevelForProfession(profession_name)
        MTSL_CURRENT_PLAYER.TRADESKILLS[profession_name]["HIGHEST_KNOWN_RANK"] = 1
        MTSL_CURRENT_PLAYER.TRADESKILLS[profession_name]["SPELLID_HIGHEST_KNOWN_RANK"] = learned_rank

        -- add auto learned skills
        local auto_learned = MTSL_LOGIC_PROFESSION:GetAutoLearnedSkillsForProfession(profession_name)

        if auto_learned ~= {} then
            MTSL_CURRENT_PLAYER.TRADESKILLS[profession_name]["AMOUNT_LEARNED"] = MTSL_TOOLS:CountItemsInArray(auto_learned)
            MTSL_CURRENT_PLAYER.TRADESKILLS[profession_name]["LEARNED_SKILLS"] = auto_learned
        end

        local missing_skills = MTSL_LOGIC_PROFESSION:GetAllAvailableSkillsForProfession(profession_name, MTSL_DATA.CURRENT_PATCH_LEVEL, MTSL_CURRENT_PLAYER.CLASS)

        if missing_skills ~= {} then
            MTSL_CURRENT_PLAYER.TRADESKILLS[profession_name]["AMOUNT_MISSING"] = MTSL_TOOLS:CountItemsInArray(missing_skills)
            for _, v in pairs(missing_skills) do
                table.insert(MTSL_CURRENT_PLAYER.TRADESKILLS[profession_name]["MISSING_SKILLS"], v.id)
            end
        end
    end,

    ------------------------------------------------------------------------------------------------
    -- Scan the skillframe to remove unlearned professions from saved data
    ------------------------------------------------------------------------------------------------
    RemoveUnlearnedProfessions = function(self)
        local i = 1

        local profession_names = {}
        -- copy each name from current data so we can check if we still know it
        if MTSL_CURRENT_PLAYER.TRADESKILLS ~= nil and MTSL_CURRENT_PLAYER.TRADESKILLS ~= {} then
            for _, v in pairs(MTSL_CURRENT_PLAYER.TRADESKILLS) do
                -- only add if primary profession
                if not MTSL_LOGIC_PROFESSION:IsSecondaryProfession(v.NAME) then
                    -- mark as unlearned
                    profession_names[v.NAME] = 0
                end
            end
        end

        local have_unlearned_profession = false

        -- only check if we actualy added professions to list to check
        if profession_names ~= {} then
            -- loop all the skill lines
            while GetSkillLineInfo(i) ~= nil do
                local skilldata = {GetSkillLineInfo(i) }
                    -- Skip header rows
                if skilldata[2] ~= 1 then
                    local profession_name = MTSL_LOGIC_PROFESSION:GetEnglishProfessionNameFromLocalisedName(skilldata[1])
                    -- only trigger event if its a trade_skill supported by the addon and if NOT a secundary profession
                    if profession_name ~= nil and not MTSL_LOGIC_PROFESSION:IsSecondaryProfession(profession_name) then
                        -- mark as (still) learned
                        profession_names[profession_name] = 1
                    end
                end
                i = i + 1
            end

            -- Remove the professions who are still marked unlearned from data
            for k, v in pairs(profession_names) do
                if v == 0 then
                    MTSL_CURRENT_PLAYER.TRADESKILLS[k] = nil
                    have_unlearned_profession = true
                end
            end
        end

        return have_unlearned_profession
    end,

    ------------------------------------------------------------------------------------------------
    -- Returns the number of characters
    --
    -- @realm   String      The name of the realm
    --
    -- returns  Number      The number of chars on that realm
    ------------------------------------------------------------------------------------------------
    CountPlayersOnRealm = function(self, realm)
        return MTSL_TOOLS:CountItemsInNamedArray(MTSL_PLAYERS[realm])
    end,

    ------------------------------------------------------------------------------------------------
    -- Returns the player on a realm
    --
    -- @name    String      The name of the player
    -- @realm   String      The name of the realm
    --
    -- returns  Number      The number of chars on that realm
    ------------------------------------------------------------------------------------------------
    GetPlayerOnRealm = function(self, name, realm)
        if MTSL_PLAYERS[realm] ~= nil then
            return MTSL_PLAYERS[realm][name]
        end
        return nil
    end,

    ------------------------------------------------------------------------------------------------
    -- Returns the players on current realm except current player
    --
    -- returns  Array       The list of players
    ------------------------------------------------------------------------------------------------
    GetOtherPlayersOnCurrentRealm = function(self)
        local players = {}
        if MTSL_CURRENT_PLAYER ~= nil then
            -- loop all players on the current realm
            for k, v in pairs(MTSL_PLAYERS[MTSL_CURRENT_PLAYER.REALM]) do
                -- skip if name is same as current player
                if k ~= MTSL_CURRENT_PLAYER.NAME then
                    table.insert(players, v)
                end
            end
        end

        return MTSL_TOOLS:SortArrayByProperty(players, "NAME")
    end,

    ------------------------------------------------------------------------------------------------
    -- Returns the players on current realm with same faction except current player
    --
    -- returns  Array       The list of players
    ------------------------------------------------------------------------------------------------
    GetOtherPlayersOnCurrentRealmSameFaction = function(self)
        local players = {}
        if MTSL_CURRENT_PLAYER then
            -- loop all players on the current realm
            for k, v in pairs(MTSL_PLAYERS[MTSL_CURRENT_PLAYER.REALM]) do
                -- skip if name is same as current player
                if k ~= MTSL_CURRENT_PLAYER.NAME and v.FACTION == MTSL_CURRENT_PLAYER.FACTION then
                    table.insert(players, v)
                end
            end
        end

        return MTSL_TOOLS:SortArrayByProperty(players, "NAME")
    end,

    ------------------------------------------------------------------------------------------------
    -- Returns the players on current realm except current player that learned a profession
    --
    -- returns  Array       The list of players
    ------------------------------------------------------------------------------------------------
    GetOtherPlayersOnCurrentRealmLearnedProfession = function(self, profession_name)
        local other_players = self:GetOtherPlayersOnCurrentRealm()
        local players = {}
        -- loop all players on the current realm
        for _, v in pairs(other_players) do
           -- skip if he doesnt know the profession
            if v.TRADESKILLS ~= nil and v.TRADESKILLS[profession_name] ~= nil and v.TRADESKILLS[profession_name] ~= 0 then
                table.insert(players, v)
            end
        end

        return MTSL_TOOLS:SortArrayByProperty(players, "NAME")
    end,

    ------------------------------------------------------------------------------------------------
    -- Returns the players on current realm and same faction except current player that learned a profession
    --
    -- returns  Array       The list of players
    ------------------------------------------------------------------------------------------------
    GetOtherPlayersOnCurrentRealmSameFactionLearnedProfession = function(self, profession_name)
        local other_players = self:GetOtherPlayersOnCurrentRealmSameFaction()
        local players = {}
        -- loop all players on the current realm
        for _, v in pairs(other_players) do
            -- skip if he doesnt know the profession
            if v.TRADESKILLS ~= nil and v.TRADESKILLS[profession_name] ~= nil and v.TRADESKILLS[profession_name] ~= 0 then
                table.insert(players, v)
            end
        end

        return MTSL_TOOLS:SortArrayByProperty(players, "NAME")
    end,

    ------------------------------------------------------------------------------------------------
    -- Check if player exists in saved date
    --
    -- @name    String      The name of the player
    -- @realm   String      The name of the realm
    --
    -- returns  Number      The number of chars on that realm
    ------------------------------------------------------------------------------------------------
    PlayerExists = function(self, name, realm)
        if MTSL_PLAYERS[realm] ~= nil and MTSL_PLAYERS[realm][name] ~= nil then
            return true
        end
        return false
    end,

    ------------------------------------------------------------------------------------------------
    -- Returns the missing skills of a player for a profession
    --
    -- @player_name         String      The name of the player
    -- @player_realm        String      The name of the realm
    -- @profession_name     String      The name of the profession
    --
    -- returns              Array       List of missing skills for the profession ({} if not found)
    ------------------------------------------------------------------------------------------------
    GetMissingSkillsForProfessionOfPlayer = function(self, player_name, player_realm, profession_name)
        local player = self:GetPlayerOnRealm(player_name, player_realm)
        local missing_skills = {}
        -- Check if player exits
        if player ~= nil and player.TRADESKILLS[profession_name] ~= nil and
                player.TRADESKILLS[profession_name] ~= 0 and player.TRADESKILLS[profession_name]["MISSING_SKILLS"] ~= nil then
            -- get the skill for each id
            for _, s in pairs(player.TRADESKILLS[profession_name]["MISSING_SKILLS"]) do
                table.insert(missing_skills, MTSL_LOGIC_SKILL:GetSkillForProfessionById(s, profession_name))
            end
        end
        return missing_skills
    end,

    ------------------------------------------------------------------------------------------------
    -- Returns the missing skills of a player for a profession
    --
    -- @profession_name     String      The name of the profession
    --
    -- returns              Array       List of missing skills for the profession ({} if not found)
    ------------------------------------------------------------------------------------------------
    GetMissingSkillsForProfessionCurrentPlayer = function(self, profession_name)
        return self:GetMissingSkillsForProfessionOfPlayer(MTSL_CURRENT_PLAYER.NAME, MTSL_CURRENT_PLAYER.REALM, profession_name)
    end,

    ------------------------------------------------------------------------------------------------
    -- Returns the missing skills of a player for a profession
    --
    -- @profession_name     String      The name of the profession
    --
    -- returns              Array       List of missing skills for the profession ({} if not found)
    ------------------------------------------------------------------------------------------------
    GetAmountMissingSkillsForProfessionCurrentPlayer = function(self, profession_name)
        local amount_missing = 0
        if MTSL_CURRENT_PLAYER.TRADESKILLS[profession_name]["AMOUNT_MISSING"] then amount_missing = tonumber(MTSL_CURRENT_PLAYER.TRADESKILLS[profession_name]["AMOUNT_MISSING"]) end

        return amount_missing
    end,

    -----------------------------------------------------------------------------------------------
    -- Get All the skills learned by a player for one profession sorted by minimim skill
    --
    -- @profession_name     String      The name of the profession
    --
    -- return               Array       All the skills for one profession sorted by name or minimim skill
    ------------------------------------------------------------------------------------------------
    GetLearnedSkillsForPlayerForProfession = function(self, player_name, realm_name, profession_name)
        local learned_skills = {}
        local player = self:GetPlayerOnRealm(player_name, realm_name)

        -- Check if player exits
        if player ~= nil and player.TRADESKILLS[profession_name] ~= nil and player.TRADESKILLS[profession_name] ~= 0 then
            -- get the skill for each id
            if player.TRADESKILLS[profession_name]["LEARNED_SKILLS"] ~= nil then
                for _, s in pairs(player.TRADESKILLS[profession_name]["LEARNED_SKILLS"]) do
                    table.insert(learned_skills, MTSL_LOGIC_SKILL:GetSkillForProfessionById(s, profession_name))
                end
            end
        end

        return MTSL_TOOLS:SortArrayByProperty(learned_skills, "min_skill")
    end,

    ------------------------------------------------------------------------------------------------
    -- Returns the amount of learned skills of a player for a profession
    --
    -- @player_name         String      The name of the player
    -- @player_realm        String      The name of the realm
    -- @profession_name     String      The name of the profession
    --
    -- returns              Number      The amount of missing skills
    ------------------------------------------------------------------------------------------------
    GetAmountOfLearnedSkillsForProfession = function(self, player_name, player_realm, profession_name)
        local player = self:GetPlayerOnRealm(player_name, player_realm)
        -- Check if player exits
        if player ~= nil and player.TRADESKILLS[profession_name] ~= nil and player.TRADESKILLS[profession_name] ~= 0 then
            return player.TRADESKILLS[profession_name]["AMOUNT_LEARNED"]
        end
        return 0
    end,

    -----------------------------------------------------------------------------------------------
    -- Get a flag indicating if a skill is learned in a profession
    --
    -- @player_name         String      The name of the player
    -- @player_realm        String      The name of the realm
    -- @profession_name     String      The name of the profession
    -- @skill_id            Number      The id of the skill
    --
    -- return               Boolean     Flag indicating if learend or not
    ------------------------------------------------------------------------------------------------
    HasLearnedSkillForProfession = function(self,  player_name, realm_name, profession_name, skill_id)
        local player = self:GetPlayerOnRealm(player_name, realm_name)

        -- Check if player exits
        if player ~= nil and player.TRADESKILLS[profession_name] ~= nil and player.TRADESKILLS[profession_name] ~= 0 then
            -- get the skill for each id
            if player.TRADESKILLS[profession_name]["LEARNED_SKILLS"] ~= nil then
                for _, s in pairs(player.TRADESKILLS[profession_name]["LEARNED_SKILLS"]) do
                    if s == skill_id then
                        return true
                    end
                end
            end
        end

        return false
    end,

    -------------------------------------------------------------------
    -- Get a flag indicating if a player has learned a profession
    --
    -- @player_name         String      The name of the player
    -- @player_realm        String      The name of the realm
    -- @profession_name     String      The name of the profession
    --
    -- return               Boolean     Flag indicating if learend or not
    ------------------------------------------------------------------------------------------------
    HasLearnedProfession = function(self,  player_name, realm_name, profession_name)
        local player = self:GetPlayerOnRealm(player_name, realm_name)

        -- Check if player exits
        if player then
            -- Check if player has leared at least one profession, if none is specified
            if profession_name == "" or profession_name == nil or
                    (player.TRADESKILLS[profession_name] and player.TRADESKILLS[profession_name] ~= 0) then
                return true
            end
        end

        return false
    end,

    -----------------------------------------------------------------------------------------------
    -- Gets the current skill level for a profession of a player
    --
    -- @player_name         String      The name of the player
    -- @player_realm        String      The name of the realm
    -- @profession_name     String      The name of the profession
    --
    -- return               Number      The current skill level
    ------------------------------------------------------------------------------------------------
    GetCurrentSkillLevelForProfession = function(self,  player_name, realm_name, profession_name)
        local player = self:GetPlayerOnRealm(player_name, realm_name)

        -- Check if player exits
        if player ~= nil and player.TRADESKILLS[profession_name] ~= nil and player.TRADESKILLS[profession_name] ~= 0 then
            return player.TRADESKILLS[profession_name].SKILL_LEVEL
        end

        return 0
    end,

    ------------------------------------------------------------------------------------------------
    -- Returns the list of names for known professsions of a player
    --
    -- @player_name         String      The name of the player
    -- @player_realm        String      The name of the realm
    --
    -- returns              Array       List of known professions ({} if none)
    ------------------------------------------------------------------------------------------------
    GetKnownProfessionsForPlayer = function(self, realm_name, player_name)
        local player = self:GetPlayerOnRealm(player_name, realm_name)
        local known_professions = {}
        if player ~= nil then
            for k, v in pairs(player.TRADESKILLS) do
                -- only add if initialised
                if v ~= 0 then
                    -- add english name to list (should already be localised when saved)
                    table.insert(known_professions, k)
                end
            end
        end

        return known_professions
    end,

    ------------------------------------------------------------------------------------------------
    -- Refresh the list of missing skills for a profession for the current player
    --
    -- @profession_name         String      The name of the profession to scan
    -- @current_skill_level     Number      The number of the current skill level of the player
    -- @max_level               Number      Maximum number of skilllevel that can be achieved for current rank
    ------------------------------------------------------------------------------------------------
    UpdateMissingSkillsForProfessionCurrentPlayer = function(self, profession_name, current_skill_level, max_level)
        -- Reset any previously saved skills
        MTSL_CURRENT_PLAYER.TRADESKILLS[profession_name] = {
            ["NAME"] = profession_name,
            ["AMOUNT_MISSING"] = 0,
            ["SKILL_LEVEL"] = current_skill_level,
            ["SPELLID_HIGHEST_KNOWN_RANK"] = 0,
            -- Array because you can learn 2 specialisations as Blacksmith
            ["SPELLIDS_SPECIALISATION"] = {},
            ["HIGHEST_KNOWN_RANK"] = 0,
            ["AMOUNT_LEARNED"] = 0,
            ["MISSING_SKILLS"] = {},
            ["LEARNED_SKILLS"] = {},
        }

        -- only scan for missing skills if it has a tradeskill/craft frame
        if MTSL_LOGIC_PROFESSION:IsFramelessProfession(profession_name) == false then
            if profession_name == "Enchanting" then
                self:UpdateMissingSkillsForCraftCurrentPlayer(profession_name)
            else
                local amount_specs_learned = self:UpdateSpecialisations(profession_name)
                self:UpdateMissingSkillsForTradeSkillCurrentPlayer(profession_name, amount_specs_learned)
            end
        end

        self:UpdateMissingLevelsForProfessionCurrentPlayer(profession_name, max_level)
    end,

    UpdateSpecialisations = function(self, profession_name)
        -- check if player has learned specialisations
        local specialisations = MTSL_LOGIC_PROFESSION:GetSpecialisationsForProfession(profession_name)

        local amount_specs_learned = 0
        local unlearned_specs = {}

        for _, s in pairs(specialisations) do
            if MTSL_LOGIC_PROFESSION:IsSpecialisationKnown(s.id) then
                table.insert(MTSL_CURRENT_PLAYER.TRADESKILLS[profession_name].SPELLIDS_SPECIALISATION, s.id)
                amount_specs_learned = amount_specs_learned + 1
                table.insert(MTSL_CURRENT_PLAYER.TRADESKILLS[profession_name].LEARNED_SKILLS, s.id)
                MTSL_CURRENT_PLAYER.TRADESKILLS[profession_name].AMOUNT_LEARNED = MTSL_CURRENT_PLAYER.TRADESKILLS[profession_name].AMOUNT_LEARNED + 1
            else
                table.insert(unlearned_specs, s.id)
            end
        end

        -- if no specialisations learned, add the spells of all specialisations as unlearned
        if amount_specs_learned > 0 then
            for _, s in pairs(unlearned_specs) do
                table.insert(MTSL_CURRENT_PLAYER.TRADESKILLS[profession_name].MISSING_SKILLS, s)
                MTSL_CURRENT_PLAYER.TRADESKILLS[profession_name].AMOUNT_MISSING = MTSL_CURRENT_PLAYER.TRADESKILLS[profession_name].AMOUNT_MISSING + 1
            end
        end

        return amount_specs_learned
    end,

    UpdateMissingSkillsForTradeSkillCurrentPlayer = function(self, profession_name, amount_specs_learned)
        -- get the list of learned skills
        local known_skill_names = MTSL_LOGIC_PROFESSION:GetSkillNamesCurrentTradeSkill()

        -- get the list of available skills in the current phase for the profession,
        local available_skills = MTSL_LOGIC_PROFESSION:GetAllAvailableSkillsForProfession(profession_name, MTSL_DATA.CURRENT_PATCH_LEVEL, MTSL_CURRENT_PLAYER.CLASS)

        for _, skill in pairs(available_skills) do
            --We learned the skill
            if MTSL_TOOLS:ListContainsKeyIgnoreCasingAndSpaces(known_skill_names, MTSLUI_TOOLS:GetLocalisedData(skill)) then
                 table.insert(MTSL_CURRENT_PLAYER.TRADESKILLS[profession_name].LEARNED_SKILLS, skill.id)
                 MTSL_CURRENT_PLAYER.TRADESKILLS[profession_name].AMOUNT_LEARNED = MTSL_CURRENT_PLAYER.TRADESKILLS[profession_name].AMOUNT_LEARNED + 1
             else
            -- Add skill to unlearned if we dont have a specialisation, skill doenst have specialisation or if player specialisation is same as the skill specialisation
                 if amount_specs_learned <= 0 or skill.specialisation == nil or (skill.specialisation ~= nil and
                         MTSL_TOOLS:ListContainsNumber(MTSL_CURRENT_PLAYER.TRADESKILLS[profession_name].SPELLIDS_SPECIALISATION, skill.specialisation) == true) then
                     table.insert(MTSL_CURRENT_PLAYER.TRADESKILLS[profession_name].MISSING_SKILLS, skill.id)
                     MTSL_CURRENT_PLAYER.TRADESKILLS[profession_name].AMOUNT_MISSING = MTSL_CURRENT_PLAYER.TRADESKILLS[profession_name].AMOUNT_MISSING + 1
                 end
             end
        end
    end,

    UpdateMissingSkillsForCraftCurrentPlayer = function(self, profession_name)
        local known_skill_ids = MTSL_LOGIC_PROFESSION:GetSkillIdsCurrentCraft()

        -- get the list of available skills in the current phase for the profession,
        local available_skills = MTSL_LOGIC_PROFESSION:GetAllAvailableSkillsForProfession(profession_name, MTSL_DATA.CURRENT_PATCH_LEVEL, MTSL_CURRENT_PLAYER.CLASS)
        -- sorted by id
        available_skills = MTSL_TOOLS:SortArrayByProperty(available_skills, "id")

        -- Loop all skills of the profession
        local known_skill_index = 1
        for _, skill in pairs(available_skills) do
            -- current enchant is known
            if known_skill_ids[known_skill_index] ~= nil and tonumber(skill.id) == tonumber(known_skill_ids[known_skill_index]) then
                table.insert(MTSL_CURRENT_PLAYER.TRADESKILLS[profession_name].LEARNED_SKILLS, skill.id)
                MTSL_CURRENT_PLAYER.TRADESKILLS[profession_name].AMOUNT_LEARNED = MTSL_CURRENT_PLAYER.TRADESKILLS[profession_name].AMOUNT_LEARNED + 1
                known_skill_index = known_skill_index + 1
            -- skill is unknown
            else
                table.insert(MTSL_CURRENT_PLAYER.TRADESKILLS[profession_name].MISSING_SKILLS, skill.id)
                MTSL_CURRENT_PLAYER.TRADESKILLS[profession_name].AMOUNT_MISSING = MTSL_CURRENT_PLAYER.TRADESKILLS[profession_name].AMOUNT_MISSING + 1
            end
        end
    end,


    ------------------------------------------------------------------------------------------------
    -- Refresh the list of missing skills for a profession for the current player
    --
    -- @profession_name         String      The name of the profession to scan
    -- @max_level               Number      The current maximum number of skill that can be learned
    ------------------------------------------------------------------------------------------------
    UpdateMissingLevelsForProfessionCurrentPlayer = function(self, profession_name, max_level)
        -- Get the current trained max based on max_level for the player for the profession
        local learned_rank = MTSL_LOGIC_PROFESSION:GetRankForProfessionByMaxLevel(profession_name, max_level)
        MTSL_CURRENT_PLAYER.TRADESKILLS[profession_name]["HIGHEST_KNOWN_RANK"] = learned_rank
        -- add all the missing levels to the array of skills as well and increase counter
        local rank_ids = MTSL_LOGIC_PROFESSION:GetRanksForProfession(profession_name)

        -- loop all level ranks
        for _, v in pairs(rank_ids) do
            -- all lower ranks are considered learned
            if v.rank <= learned_rank then
                table.insert(MTSL_CURRENT_PLAYER.TRADESKILLS[profession_name].LEARNED_SKILLS, v.id)
                MTSL_CURRENT_PLAYER.TRADESKILLS[profession_name].AMOUNT_LEARNED = MTSL_CURRENT_PLAYER.TRADESKILLS[profession_name].AMOUNT_LEARNED + 1
                if v.rank == learned_rank then
                    MTSL_CURRENT_PLAYER.TRADESKILLS[profession_name].SPELLID_HIGHEST_KNOWN_RANK = v.id
                end
            else
                table.insert(MTSL_CURRENT_PLAYER.TRADESKILLS[profession_name].MISSING_SKILLS, v.id)
                MTSL_CURRENT_PLAYER.TRADESKILLS[profession_name].AMOUNT_MISSING = MTSL_CURRENT_PLAYER.TRADESKILLS[profession_name].AMOUNT_MISSING + 1
            end
        end
    end,

    ----------------------------------------------------------------------------------------
    -- Check if we unlearned a profession (No need for cooking or First Aid, can't unlearn those)
    ----------------------------------------------------------------------------------------
    CheckProfessions = function(self)
        local unlearned = false
        if MTSL_CURRENT_PLAYER ~= nil and MTSL_CURRENT_PLAYER.TRADESKILLS ~= nil then
            for _, v in pairs(MTSL_CURRENT_PLAYER.TRADESKILLS) do
                -- Cant unlearn secondary profs, so skip those
                if v.NAME and MTSL_LOGIC_PROFESSION:IsSecondaryProfession(v.NAME) == false and not IsSpellKnown(v.SPELLID_HIGHEST_KNOWN_RANK) then
                    -- delete the saved data
                    v = nil
                    unlearned = true
                end
            end
        end
        return unlearned
    end,

    ----------------------------------------------------------------------------------------
    -- Check if we unlearned a specialisation
    ----------------------------------------------------------------------------------------
    CheckSpecialisations = function(self)
        local unlearned = false
        if MTSL_CURRENT_PLAYER ~= nil and MTSL_CURRENT_PLAYER.TRADESKILLS ~= nil then
            for _, v in pairs(MTSL_CURRENT_PLAYER.TRADESKILLS) do
                -- Check all specialisations if we have learned some
                if v.SPELLIDS_SPECIALISATION ~= nil and v.SPELLIDS_SPECIALISATION ~= {} then
                    local new_spellids_specialisation = {}
                    for _, s in pairs(v.SPELLIDS_SPECIALISATION) do
                        if MTSL_LOGIC_PROFESSION:IsSpecialisationKnown(s) then
                            -- Keep the specialisation
                            table.insert(new_spellids_specialisation, s)
                        -- We no longer know the specialisation
                        else
                            unlearned = true
                        end
                    end
                    v.SPELLIDS_SPECIALISATION = new_spellids_specialisation
                end
            end
        end
        return unlearned
    end,

    -----------------------------------------------------------------------------------------------
    -- Gets a list of all npcs (based on their ids) available to the player's faction
    --
    -- @ids                 Array       The ids of NPCs to search
    --
    -- return               Array       List of found NPCs
    ------------------------------------------------------------------------------------------------
    GetNpcsByIds = function(self, ids)
        local npcs = {}

        for _, id in pairs(ids)
        do
            local npc = self:GetNpcById(id)
            -- If we found one, check if the faction is valid (= neutral OR the same faction as player
            if npc ~= nil then
                if MTSL_CURRENT_PLAYER.FACTION == npc.reacts or npc.reacts == "Neutral" then
                    table.insert(npcs, npc)
                end
            else
                MTSL_TOOLS:Print(MTSLUI_FONTS.COLORS.TEXT.ERROR .. "MTSL: Could not find NPC with id " .. id .. ". Please report this bug!")
            end
        end

        -- Return the found npcs
        return MTSL_TOOLS:SortArrayByLocalisedProperty(npcs, "name")
    end,

    -----------------------------------------------------------------------------------------------
    -- Gets a list of all npcs (based on their ids) ignoring the player's faction
    --
    -- @ids                 Array       The ids of NPCs to search
    --
    -- return               Array       List of found NPCs
    ------------------------------------------------------------------------------------------------
    GetNpcsIgnoreFactionByIds = function(self, ids)
        local npcs = {}

        for _, id in pairs(ids)
        do
            local npc = self:GetNpcById(id)
            -- If we found one, check if the faction is valid (= neutral OR the same faction as player
            if npc ~= nil then
                table.insert(npcs, npc)
            else
                MTSL_TOOLS:Print(MTSLUI_FONTS.COLORS.TEXT.ERROR .. "MTSL: Could not find NPC with id " .. id .. ". Please report this bug!")
            end
        end

        -- Return the found npcs
        return MTSL_TOOLS:SortArrayByLocalisedProperty(npcs, "name")
    end,

    -----------------------------------------------------------------------------------------------
    -- Gets an NPC (based on it's id) for the current Tradeskill
    --
    -- @id              Number      The id of the NPC to search
    --
    -- return           Object      Found NPC (nil if not found)
    ------------------------------------------------------------------------------------------------
    GetNpcById = function(self, id)
        return MTSL_TOOLS:GetItemFromArrayByKeyValue(MTSL_DATA["npcs"], "id", id)
    end,

    -----------------------------------------------------------------------------------------------
    -- Gets a list of all drop mobs (based on their ids) for the current Tradeskill
    --
    -- @ids                 Array       The ids of mobs to search
    --
    -- return               Array       List of found mobs
    ------------------------------------------------------------------------------------------------
    GetMobsByIds = function(self, ids)
        local mobs = {}

        for _, id in pairs(ids)
        do
            local mob = self:GetNpcById(id)
            -- Check if we found one
            if mob ~= nil then
                -- only add mob if player can attack it
                if mob.reacts ~= MTSL_CURRENT_PLAYER.FACTION then
                    table.insert(mobs, mob)
                end
            else
                MTSL_TOOLS:Print(MTSLUI_FONTS.COLORS.TEXT.ERROR .. "MTSL: Could not find mob with id " .. id .. " for " .. MTSL_CURRENT_PROFESSION.NAME .. ". Please report this bug!")
            end
        end

        -- Return the found mobs sorted by name
        return MTSL_TOOLS:SortArrayByLocalisedProperty(mobs, "name")
    end,

    -----------------------------------------------------------------------------------------------
    -- Get a list of realms where the player has at least 1 saved char on
    --
    -- return               Array       The list of realm names
    ------------------------------------------------------------------------------------------------
    GetRealmsWithPlayers = function(self)
        local realm_names = {}
        for k, _ in pairs(MTSL_PLAYERS) do
            if self:CountPlayersOnRealm(k) > 0 then
                table.insert(realm_names, k)
            end
        end

        return MTSL_TOOLS:SortArray(realm_names)
    end,

    -----------------------------------------------------------------------------------------------
    -- Get a list of realms where the player has at least 1 saved char on that knows the profession
    --
    -- @profession_name     String      The name of the profession needed by 1 char / realm
    --
    -- return               Array       The list of realm names
    ------------------------------------------------------------------------------------------------
    GetRealmsWithPlayersKnowingProfession = function(self, profession_name)
        local realm_names = {}
        -- keep last saved realm name
        local last_added_realm = ""

        for k, r in pairs(MTSL_PLAYERS) do
            -- loop all chars on realm until we find one with the profession
            for _, p in pairs(r) do
                if k ~= last_added_realm and p.TRADESKILLS[profession_name] ~= nil then
                    table.insert(realm_names, k)
                    last_added_realm = k
                end
            end
        end

        return MTSL_TOOLS:SortArray(realm_names)
    end,

    GetCurrentPlayerIsInGuild = function(self)
        return MTSL_CURRENT_PLAYER.GUILD  ~= ""
    end,

    GetCurrentPlayerIsInParty = function(self)
        return GetNumPartyMembers() > 1
    end,

    GetCurrentPlayerIsInRaid = function(self)
        return UnitInRaid("player") ~= nil
    end,

}
