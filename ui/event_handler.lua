------------------------------------------------------------------
-- Name: EventHandler                                           --
-- Description: handles all the UI events needed for the addon  --
------------------------------------------------------------------

MTSLUI_EVENT_HANDLER = {
    -- flags keeping track if window is open or not
    ui_trade_open = 0,
    ui_craft_open = 0,
    addon_loaded = 0,

    ---------------------------------------------------------------------------------------
    -- Event started when our addon is fully loaded
    ---------------------------------------------------------------------------------------
    PLAYER_LOGIN = function(self)
        if MTSL_TOOLS:CheckIfDataIsValid() then
            if MTSLUI_TOOLS:SetAddonLocale() then
                -- load the data for the player
                local error_loading_player = MTSL_LOGIC_PLAYER_NPC:LoadPlayer()
                if error_loading_player ~= "new" and error_loading_player ~= "existing" then
                    print(MTSLUI_FONTS.COLORS.TEXT.ERROR .. "MTSL: Could not load player info (Empty " .. error_loading_player .."! Try reloading this addon")
                    self.addon_loaded = 0
                else
                    -- Initialise the minimap button
                    MTSLUI_MINIMAP:Initialise()
                    -- Try to load the saved variables
                    MTSLUI_SAVED_VARIABLES:Initialise()
                    -- make the data for dropdowns in sort frames
                    MTSLUI_FILTER_FRAME:InitialiseData()
                    -- Initialise all the frames now we know we can use the addon
                    -- Create the toggle button (shown on tradeskill/craft window)
                    MTSLUI_TOGGLE_BUTTON:Initialise()
                    -- Create the MTSL window expanding tradeskill/craft window)
                    MTSLUI_MISSING_TRADESKILLS_FRAME:Initialise()
                    -- Initialise the explorer frames
                    MTSLUI_ACCOUNT_EXPLORER_FRAME:Initialise()
                    MTSLUI_DATABASE_EXPLORER_FRAME:Initialise()
                    MTSLUI_NPC_EXPLORER_FRAME:Initialise()
                    MTSLUI_CHARACTER_EXPLORER_FRAME:Initialise()
                    -- Create the options menu
                    MTSLUI_OPTIONS_MENU_FRAME:Initialise()
                    -- Load the saved variables for UI
                    MTSLUI_SAVED_VARIABLES:LoadSavedUIScales()
                    MTSLUI_SAVED_VARIABLES:LoadSavedSplitModes()

                    -- print loaded message if possible
                    if MTSLUI_SAVED_VARIABLES:GetShowWelcomeMessage() == 1 then
                        print(MTSLUI_FONTS.COLORS.TEXT.TITLE .. MTSLUI_ADDON.NAME .. MTSLUI_FONTS.COLORS.TEXT.NORMAL .. " (by " .. MTSLUI_ADDON.AUTHOR .. ")" .. MTSLUI_FONTS.COLORS.TEXT.TITLE .. " v" .. MTSLUI_ADDON.VERSION .. " loaded!")
                        print(MTSLUI_FONTS.COLORS.TEXT.TITLE .."MTSL: Using data for phase " .. MTSL_DATA.CURRENT_PATCH_LEVEL .. " (" .. MTSL_LOGIC_WORLD:GetZoneNameById(MTSL_DATA.PHASE_IDS[MTSL_DATA.CURRENT_PATCH_LEVEL]) .. ")")
                        if error_loading_player == "existing" then
                            print(MTSLUI_FONTS.COLORS.TEXT.SUCCESS .. "MTSL: " .. MTSL_CURRENT_PLAYER.NAME .. " (" .. MTSL_CURRENT_PLAYER.XP_LEVEL .. ", " .. MTSL_CURRENT_PLAYER.FACTION .. ") on " .. MTSL_CURRENT_PLAYER.REALM .. " loaded")
                        end
                        if error_loading_player == "new" then
                            -- Get additional player info to save
                            print(MTSLUI_FONTS.COLORS.TEXT.WARNING .. "MTSL: New character: " .. MTSL_CURRENT_PLAYER.NAME .. " (" .. MTSL_CURRENT_PLAYER.XP_LEVEL .. ", " .. MTSL_CURRENT_PLAYER.FACTION .. ") on " .. MTSL_CURRENT_PLAYER.REALM)
                            print(MTSLUI_FONTS.COLORS.TEXT.WARNING .. "MTSL: Please open all profession windows to save skills!")
                        end
                    end

                    self.addon_loaded = 1
                end
            else
                print(MTSLUI_FONTS.COLORS.TEXT.ERROR .. "MTSL: Your locale " .. GetLocale() .. " is not supported!")
                self.addon_loaded = 0
            end
        else
            print(MTSLUI_FONTS.COLORS.TEXT.ERROR .. "MTSL: Data for addon could not load. Please reinstall addon!")
            self.addon_loaded = 0
        end
    end,

    ---------------------------------------------------------------------------------------
    -- Event started when a crafting window is closed
    ---------------------------------------------------------------------------------------
    CRAFT_CLOSE = function(self)
        self.ui_craft_open = 0
        -- if we have a tradeskill window open, reanchor togglebutton and refresh frame
        if self.ui_trade_open > 0 then
            self:TRADE_SKILL_SHOW()
            self:TRADE_SKILL_UPDATE()
        -- no other window was open so close the addon
        else
            MTSLUI_TOGGLE_BUTTON:Hide()
            MTSLUI_MISSING_TRADESKILLS_FRAME:Hide()
        end
    end,

    ---------------------------------------------------------------------------------------
    -- Event started when a crafting window is opened
    ---------------------------------------------------------------------------------------
    CRAFT_SHOW = function(self)
        -- Check if we effectively opened a CraftFrame
        if CraftFrame then
            -- make it drageable
            MTSLUI_TOOLS:AddDragToFrame(CraftFrame)
            local localised_name, current_skill_level, max_level = GetCraftDisplaySkillLine()
            --Get the English name of the profession
            local profession_name = MTSL_LOGIC_PROFESSION:GetEnglishProfessionNameFromLocalisedName(localised_name)
            -- There are other craftframes like (Beast Training) so we only want enchanting
            if profession_name == "Enchanting" then
                self:SwapToProfession(profession_name, current_skill_level, max_level)
                MTSLUI_MISSING_TRADESKILLS_FRAME:RefreshUI(1)
                MTSLUI_CHARACTER_EXPLORER_FRAME:RefreshUI(1)
            end
        end
    end,

    ---------------------------------------------------------------------------------------
    -- Event started when a crafting window is updated
    ---------------------------------------------------------------------------------------
    CRAFT_UPDATE = function(self)
        -- only trigger update event if we have the window opened
        local localised_name, current_skill_level, max_level = GetCraftDisplaySkillLine()
        local profession_name = MTSL_LOGIC_PROFESSION:GetEnglishProfessionNameFromLocalisedName(localised_name)
        -- only trigger event if its a different but supported tradeskill in addon
        if CraftFrame and profession_name == "Enchanting" then
            self:RefreshSkills(profession_name, current_skill_level, max_level)
        end
    end,

    ---------------------------------------------------------------------------------------
    -- Event started when a skill point is gained or unlearned a profession / specialisation
    ---------------------------------------------------------------------------------------
    SKILL_LINES_CHANGED = function(self)
        local has_learned = MTSL_LOGIC_PLAYER_NPC:AddLearnedProfessions()
        MTSL_LOGIC_PLAYER_NPC:UpdatePlayerSkillLevels()
        -- Check if we (un)learned a profession (only possbile if SkillFrame is shown and active and player exists)
        if SkillFrame and SkillFrame:IsVisible() and MTSL_LOGIC_PLAYER_NPC:PlayerExists(MTSL_CURRENT_PLAYER.NAME, MTSL_CURRENT_PLAYER.REALM) then
            local has_unlearned = MTSL_LOGIC_PLAYER_NPC:RemoveUnlearnedProfessions()
            if has_unlearned == false then has_unlearned = MTSL_LOGIC_PLAYER_NPC:CheckSpecialisations() end

            if has_unlearned == true then
                MTSLUI_ACCOUNT_EXPLORER_FRAME:RefreshUI(1)
                MTSLUI_CHARACTER_EXPLORER_FRAME:UpdateProfessions()
            end
        end

        if has_learned == true then
            MTSLUI_ACCOUNT_EXPLORER_FRAME:RefreshUI(1)
            MTSLUI_CHARACTER_EXPLORER_FRAME:UpdateProfessions()
        end
    end,

    ---------------------------------------------------------------------------------------
    -- Event started when a trade skill windows is closed
    ---------------------------------------------------------------------------------------
    TRADE_SKILL_CLOSE = function(self)
        self.ui_trade_open = 0
        -- if we have a tradeskill window open, reanchor togglebutton and refresh frame
        if self.ui_craft_open > 0 then
            self:CRAFT_SHOW()
            self:CRAFT_UPDATE()
        -- no other window was open so close the addon
        else
            MTSLUI_TOGGLE_BUTTON:Hide()
            MTSLUI_MISSING_TRADESKILLS_FRAME:Hide()
        end
    end,

    ---------------------------------------------------------------------------------------
    -- Event started when a trade skill windows is opened
    ---------------------------------------------------------------------------------------
    TRADE_SKILL_SHOW = function(self)
        -- If we have a tradeskillframe
        if TradeSkillFrame then
            -- make it drageable
            MTSLUI_TOOLS:AddDragToFrame(TradeSkillFrame)
            local localised_name, current_skill_level, max_level = GetTradeSkillLine()
            local profession_name = MTSL_LOGIC_PROFESSION:GetEnglishProfessionNameFromLocalisedName(localised_name)
            -- only trigger event if its a trade_skill supported by the addon
            if profession_name ~= nil then
                self:SwapToProfession(profession_name, current_skill_level, max_level)
                MTSLUI_MISSING_TRADESKILLS_FRAME:RefreshUI(1)
                MTSLUI_CHARACTER_EXPLORER_FRAME:RefreshUI(1)
            end
        end
    end,

    ---------------------------------------------------------------------------------------
    -- Event started when a trade skill windows is updated
    ---------------------------------------------------------------------------------------
    TRADE_SKILL_UPDATE = function(self)
        -- only trigger update event if we have the window opened
        local localised_name, current_skill_level, max_level = GetTradeSkillLine()
        local profession_name = MTSL_LOGIC_PROFESSION:GetEnglishProfessionNameFromLocalisedName(localised_name)
        -- only trigger event if its a different but supported tradeskill in addon
        if TradeSkillFrame and profession_name ~= nil then
            self:RefreshSkills(profession_name, current_skill_level, max_level)
        end
    end,

    ---------------------------------------------------------------------------------------
    -- Refresh the list of missing skills for the current player an de UI f needed
    --
    -- @profession_name         String          The name of the profession
    -- @current_skill_level     Number          The number of the current level of skill of the current player for the profession
    -- @max_level               Number          Maximum number of skilllevel that can be achieved for current rank
    ---------------------------------------------------------------------------------------
    RefreshSkills = function(self, profession_name, current_skill_level, max_level)
        -- save the current amount of missing skills
        local amount_missing_skills = MTSL_CURRENT_PLAYER.TRADESKILLS[profession_name].AMOUNT_MISSING
        -- trigger the show event to refresh the missing list
        MTSL_LOGIC_PLAYER_NPC:UpdateMissingSkillsForProfessionCurrentPlayer(profession_name, current_skill_level, max_level)
        -- only refresh the ui if we the amount missing is lower
        if amount_missing_skills > MTSL_CURRENT_PLAYER.TRADESKILLS[profession_name].AMOUNT_MISSING then
            -- Only refresh the UI if we successfully updated the skillinfo (this ignores the update with any unsupported profession)
            MTSLUI_MISSING_TRADESKILLS_FRAME:RefreshUI()
            MTSLUI_CHARACTER_EXPLORER_FRAME:RefreshUI()
        end
    end,

    ---------------------------------------------------------------------------------------
    -- Event started when a skill is learned from trainer
    ---------------------------------------------------------------------------------------
    TRAINER_UPDATE = function(self)
        local has_learned = MTSL_LOGIC_PLAYER_NPC:AddLearnedProfessions()
        -- only possible react if we have a craft or tradeskill open
        if self.ui_craft_open > 0 or self.ui_trade_open > 0 then
            -- Check if we have a trainer window open
            if ClassTrainerFrame and ClassTrainerFrame:IsVisible() and ClassTrainerFrame.selectedService then
                -- get the name of the profession for the current opened trainer (This is always localised name)
                local localised_name = GetTrainerServiceSkillLine(ClassTrainerFrame.selectedService)
                local profession_name = MTSL_LOGIC_PROFESSION:GetEnglishProfessionNameFromLocalisedName(localised_name)
                -- only update if current profession is the opened MTSL one
                -- both can be open at same time, but only refresh if its the active one as well
                if self.ui_craft_open > 0 and MTSLUI_MISSING_TRADESKILLS_FRAME:GetCurrentProfessionName() == profession_name then
                    self:CRAFT_UPDATE()
                elseif self.ui_trade_open > 0 and MTSLUI_MISSING_TRADESKILLS_FRAME:GetCurrentProfessionName() == profession_name then
                    self:TRADE_SKILL_UPDATE()
                end
            end

            if has_learned == true then
                MTSLUI_ACCOUNT_EXPLORER_FRAME:RefreshUI(1)
                MTSLUI_CHARACTER_EXPLORER_FRAME:UpdateProfessions()
            end
        end
    end,

    ---------------------------------------------------------------------------------------
    -- Event thrown when player changes zones in the world
    ---------------------------------------------------------------------------------------
    ZONE_CHANGED_NEW_AREA = function(self)
        -- Get the text of the new zone
        local zone_name = GetRealZoneText()
        -- if we actually fond one, update the filter frames
        if zone_name ~= nil then
            MTSLUI_MISSING_TRADESKILLS_FRAME.skill_list_filter_frame:UpdateCurrentZone(zone_name)
            MTSLUI_ACCOUNT_EXPLORER_FRAME.skill_list_filter_frame:UpdateCurrentZone(zone_name)
            MTSLUI_DATABASE_EXPLORER_FRAME.skill_list_filter_frame:UpdateCurrentZone(zone_name)
            MTSLUI_CHARACTER_EXPLORER_FRAME.skill_list_filter_frame:UpdateCurrentZone(zone_name)
        end
    end,

    ---------------------------------------------------------------------------------------
    -- Update the current XP level of the char when he "dings"
    ---------------------------------------------------------------------------------------
    CHARACTER_POINTS_CHANGED = function(self)
        MTSL_LOGIC_PLAYER_NPC:UpdatePlayerInfo()
        -- TODO refresh player info show in ACC or DB explorer
    end,

    ---------------------------------------------------------------------------------------
    -- Handles a slash command for this addon
    --
    -- @msg:            string      The argument for the slash command
    ---------------------------------------------------------------------------------------
    SLASH_COMMAND = function(self, msg)
        -- remove case sensitive options by setting all passed text to lowercase
        if msg then msg = string.lower(msg) end
        if msg == "acc" or msg == "account" then
            -- only execute if not yet shown
            if not MTSLUI_ACCOUNT_EXPLORER_FRAME:IsShown() then
                MTSLUI_ACCOUNT_EXPLORER_FRAME:Show()
                MTSLUI_ACCOUNT_EXPLORER_FRAME:RefreshUI()
            end
        elseif msg == "db" or msg == "database" then
            -- only execute if not yet shown
            if not MTSLUI_DATABASE_EXPLORER_FRAME:IsShown() then
                MTSLUI_DATABASE_EXPLORER_FRAME:Show()
                MTSLUI_DATABASE_EXPLORER_FRAME:RefreshUI()
            end
        elseif msg == "npc" then
            MTSLUI_NPC_EXPLORER_FRAME:Show()
            MTSLUI_NPC_EXPLORER_FRAME:RefreshUI()
        elseif msg == "about" then
            MTSLUI_TOOLS:PrintAboutMessage()
        elseif msg == "options" or msg == "config" then
            MTSLUI_OPTIONS_MENU_FRAME:Show()
        -- Not a known parameter or "help"
        elseif msg == nil or msg == "" or msg == "char" then
            MTSLUI_CHARACTER_EXPLORER_FRAME:Show()
            MTSLUI_CHARACTER_EXPLORER_FRAME:RefreshUI()
        else
            MTSLUI_TOOLS:PrintHelpMessage()
        end
    end,

    ---------------------------------------------------------------------------------------
    ---------------------------------------------------------------------------------------
    -- Initialise the handler and hook all events
    ---------------------------------------------------------------------------------------
    Initialise = function(self)
        -- Create an "empty" frame to hook onto
        local event_frame = CreateFrame("FRAME")
        -- Set function how to react on event
        event_frame:SetScript("OnEvent", function()
            -- only execute the event if the addon is loaded OR the event = player_login
            if self.addon_loaded == 1 or event == "PLAYER_LOGIN" then
                self[event](self)
            end
        end)

        -- Event thrown when player has logged in
        event_frame:RegisterEvent("PLAYER_LOGIN")
        -- Events for crafts (= Enchanting)
        event_frame:RegisterEvent("CRAFT_CLOSE")
        event_frame:RegisterEvent("CRAFT_SHOW")
        event_frame:RegisterEvent("CRAFT_UPDATE")
        -- Gained a skill point
        event_frame:RegisterEvent("SKILL_LINES_CHANGED")
        -- Events for trade skills (= all but enchanting)
        event_frame:RegisterEvent("TRADE_SKILL_CLOSE")
        event_frame:RegisterEvent("TRADE_SKILL_SHOW")
        event_frame:RegisterEvent("TRADE_SKILL_UPDATE")
        -- Learned Skill from trainer
        event_frame:RegisterEvent("TRAINER_UPDATE")
        -- Event to update current zone in filterframe
        event_frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
        -- Capture a "ding" of a player
        event_frame:RegisterEvent("CHARACTER_POINTS_CHANGED")
    end,

    ---------------------------------------------------------------------------------------
    -- Get loadstatus of addon
    --
    -- returns      Boolean     Flag indicating if addon is loaded
    ---------------------------------------------------------------------------------------
    IsAddonLoaded = function(self)
        return self.addon_loaded == 1
    end,

    ---------------------------------------------------------------------------------------
    -- Swap to Craft or Tradeskill mode
    --
    -- @profession_name         String      The name of the profession to scan
    -- @current_skill_level     Number      The number of the current skill level of the player
    -- @max_level               Number      Maximum number of skilllevel that can be achieved for current rank
    ---------------------------------------------------------------------------------------
    SwapToProfession = function(self, profession_name, current_skill_level, max_level)
        if profession_name == "Enchanting" then
            self.ui_craft_open = 1
            MTSLUI_TOGGLE_BUTTON:SwapToCraftMode()
        else
            self.ui_trade_open = 1
            MTSLUI_TOGGLE_BUTTON:SwapToTradeSkillMode()
        end
        MTSLUI_TOGGLE_BUTTON:Show()

        -- Update the missing skills for the current player
        MTSL_LOGIC_PLAYER_NPC:UpdateMissingSkillsForProfessionCurrentPlayer(profession_name, current_skill_level, max_level)
        MTSLUI_MISSING_TRADESKILLS_FRAME:SetCurrentProfessionDetails(profession_name, current_skill_level, MTSL_CURRENT_PLAYER.XP_LEVEL, MTSL_CURRENT_PLAYER.TRADESKILLS[profession_name].SPELLIDS_SPECIALISATION)
        MTSLUI_MISSING_TRADESKILLS_FRAME:NoSkillSelected()
        -- Show the frame if option is selected "auto"
        if MTSLUI_SAVED_VARIABLES:GetAutoShowMTSL() == 1 then
            MTSLUI_MISSING_TRADESKILLS_FRAME:Show()
            MTSLUI_MISSING_TRADESKILLS_FRAME:RefreshUI(1)
        end
    end,
}
