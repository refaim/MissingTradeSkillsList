-----------------------------------------------------------------------
-- Name: MissingTradeSkillFrame                                      --
-- Description: The main frame shown next to TradeSkill/Craft Window --
-----------------------------------------------------------------------
MTSLUI_CHARACTER_EXPLORER_FRAME = MTSL_TOOLS:CopyObject(MTSLUI_BASE_FRAME)

-- Custom properties
MTSLUI_CHARACTER_EXPLORER_FRAME.FRAME_WIDTH_VERTICAL_SPLIT = 975
MTSLUI_CHARACTER_EXPLORER_FRAME.FRAME_HEIGHT_VERTICAL_SPLIT = 495

MTSLUI_CHARACTER_EXPLORER_FRAME.FRAME_WIDTH_HORIZONTAL_SPLIT = 590
MTSLUI_CHARACTER_EXPLORER_FRAME.FRAME_HEIGHT_HORIZONTAL_SPLIT = 768

MTSLUI_CHARACTER_EXPLORER_FRAME.previous_amount_missing = ""
MTSLUI_CHARACTER_EXPLORER_FRAME.previous_profession_name = ""

----------------------------------------------------------------------------------------------------------
-- Shows the frame
----------------------------------------------------------------------------------------------------------
function MTSLUI_CHARACTER_EXPLORER_FRAME:Show()
    -- only show if not options menu open
    if MTSLUI_OPTIONS_MENU_FRAME:IsShown() then
        MTSL_TOOLS:Print(MTSLUI_FONTS.COLORS.TEXT.ERROR .. "MTSL: " .. MTSLUI_TOOLS:GetLocalisedLabel("close options menu"))
    else
        -- hide other explorerframes
        MTSLUI_ACCOUNT_EXPLORER_FRAME:Hide()
        MTSLUI_DATABASE_EXPLORER_FRAME:Hide()
        MTSLUI_NPC_EXPLORER_FRAME:Hide()
        self.ui_frame:Show()
        -- update the UI of the screen
        self.current_profession_name = nil
        self.profession_list_frame:HandleSelectedListItem(1)
    end
end

----------------------------------------------------------------------------------------------------------
-- Intialises the MissingTradeSkillFrame
--
-- @parent_frame        Frame       The parent frame
----------------------------------------------------------------------------------------------------------
function MTSLUI_CHARACTER_EXPLORER_FRAME:Initialise()
    local swap_frames = {
        {
            button_text = "ACC",
            frame_name = "MTSLUI_ACCOUNT_EXPLORER_FRAME",
        },
        {
            button_text = "DB",
            frame_name = "MTSLUI_DATABASE_EXPLORER_FRAME",
        },
        {
            button_text = "NPC",
            frame_name = "MTSLUI_NPC_EXPLORER_FRAME",
        },
    }
    self.ui_frame = MTSLUI_TOOLS:CreateMainFrame("MTSLUI_CHARACTER_EXPLORER_FRAME", "MTSLUI_CharacterExplorerFrame", self.FRAME_WIDTH_VERTICAL_SPLIT, self.FRAME_HEIGHT_VERTICAL_SPLIT, swap_frames)

    self:CreateCompontentFrames()
    self:LinkFrames()

    self.profession_list_frame:ChangePlayer(MTSL_CURRENT_PLAYER.NAME, MTSL_CURRENT_PLAYER.REALM)
    self.profession_list_frame:UpdateButtonsToShowAmountMissingSkills()
end

----------------------------------------------------------------------------------------------------------
-- Create and place the componentframes for the parent frame
----------------------------------------------------------------------------------------------------------
function MTSLUI_CHARACTER_EXPLORER_FRAME:CreateCompontentFrames()
    -- initialise the components of the frame
    self.title_frame = MTSL_TOOLS:CopyObject(MTSLUI_TITLE_FRAME)
    self.title_frame:Initialise(self.ui_frame, "Character Explorer", self.FRAME_WIDTH_VERTICAL_SPLIT - 5, self.FRAME_WIDTH_HORIZONTAL_SPLIT - 5)
    -- Copy & init the profession list frame
    self.profession_list_frame = MTSL_TOOLS:CopyObject(MTSLUI_PROFESSION_LIST_FRAME)

    -- Override the current HandleSelect of profession list frame
    self.profession_list_frame.HandleSelectedListItem = function(me, index)
        if me.selected_index ~= index then
            -- Deselect the old BG_Frame by hiding it
            if me.selected_index ~= nil then
                me.PROF_BGS[me.selected_index]:Hide()
            end
            me.selected_index = index
            me.PROF_BGS[me.selected_index]:Show()

            self.current_profession_name = me:GetCurrentProfession()
            self:RefreshUI(1)
        end
    end

    self.profession_list_frame:Initialise(self.ui_frame, "MTSLUI_CHAR_EXPLORER_PROFESSION_LIST_FRAME")
    -- position under the filter frame
    self.profession_list_frame.ui_frame:SetPoint("TOPLEFT", self.ui_frame, "TOPLEFT", 4, -32)
    -- Copy & init the filter frame
    self.skill_list_filter_frame = MTSL_TOOLS:CopyObject(MTSLUI_FILTER_FRAME)
    self.skill_list_filter_frame:Initialise(self.ui_frame, "MTSLUI_CHAR_EXPLORER_FILTER_FRAME")
    -- position left of profession_list_Frame
    self.skill_list_filter_frame.ui_frame:SetPoint("TOPLEFT", self.profession_list_frame.ui_frame, "TOPRIGHT", 0, 0)
    -- Copy & init the list frame
    self.skill_list_frame = MTSL_TOOLS:CopyObject(MTSLUI_LIST_FRAME)
    self.skill_list_frame:Initialise(self.ui_frame, "MTSLUI_CHAR_EXPLORER_LIST_FRAME")
    -- position under the filter frame
    self.skill_list_frame.ui_frame:SetPoint("TOPLEFT", self.skill_list_filter_frame.ui_frame, "BOTTOMLEFT", 0, -10)
    -- Copy & init the detail frame
    self.skill_detail_frame = MTSL_TOOLS:CopyObject(MTSLUI_SKILL_DETAIL_FRAME)
    self.skill_detail_frame:Initialise(self.ui_frame, "MTSLUI_CHAR_EXPLORER_DETAIL_FRAME")
    -- position left of the list frame
    self.skill_detail_frame.ui_frame:SetPoint("BOTTOMLEFT", self.skill_list_frame.ui_frame, "BOTTOMRIGHT", 0, 0)
    -- Copy & init the pgoress bar
    self.progressbar = MTSL_TOOLS:CopyObject(MTSLUI_PROGRESSBAR)
    self.progressbar:Initialise(self.ui_frame, "MTSLUI_MTSLF_PROGRESS_BAR", MTSLUI_TOOLS:GetLocalisedLabel("missing skills"))
    -- Bottom of the frame
    self.progressbar.ui_frame:SetPoint("TOPRIGHT", self.skill_detail_frame.ui_frame, "BOTTOMRIGHT", 0, 3)
end

----------------------------------------------------------------------------------------------------------
-- link the frames to correct event frames
----------------------------------------------------------------------------------------------------------
function MTSLUI_CHARACTER_EXPLORER_FRAME:LinkFrames()
    self.profession_list_frame:SetFilterFrame(self.skill_list_filter_frame)
    self.profession_list_frame:SetListFrame(self.skill_list_frame)
    self.skill_list_filter_frame:SetListFrame(self.skill_list_frame)
    self.skill_list_frame:SetDetailSelectedItemFrame(self.skill_detail_frame)
    -- limit to current phase only
    self.skill_list_filter_frame:UseOnlyCurrentPhase()
end

----------------------------------------------------------------------------------------------------------
-- Swap to Vertical Mode (Default mode, means list left & details right)
----------------------------------------------------------------------------------------------------------
function MTSLUI_CHARACTER_EXPLORER_FRAME:SwapToVerticalMode()
    -- resize the frames
    self.ui_frame:SetWidth(self.FRAME_WIDTH_VERTICAL_SPLIT)
    self.ui_frame:SetHeight(self.FRAME_HEIGHT_VERTICAL_SPLIT)
    self.title_frame:ResizeToVerticalMode()
    self.skill_list_filter_frame:ResizeToVerticalMode()
    self.skill_list_frame:ResizeToVerticalMode()
    -- no need to reseize detail frame, always same size, just rehook it
    self.skill_detail_frame.ui_frame:ClearAllPoints()
    self.skill_detail_frame.ui_frame:SetPoint("BOTTOMLEFT", self.skill_list_frame.ui_frame, "BOTTOMRIGHT", 0, 0)
    self.progressbar:ResizeToVerticalMode()
end

----------------------------------------------------------------------------------------------------------
-- Swap to Horizontal Mode (means list on top & details below)
----------------------------------------------------------------------------------------------------------
function MTSLUI_CHARACTER_EXPLORER_FRAME:SwapToHorizontalMode()
    -- resize the frames where needed
    self.ui_frame:SetWidth(self.FRAME_WIDTH_HORIZONTAL_SPLIT)
    self.ui_frame:SetHeight(self.FRAME_HEIGHT_HORIZONTAL_SPLIT)
    self.title_frame:ResizeToHorizontalMode()
    self.skill_list_filter_frame:ResizeToHorizontalMode()
    self.skill_list_frame:ResizeToHorizontalMode()
    -- no need to reseize detail frame, always same size, just rehook it
    self.skill_detail_frame.ui_frame:ClearAllPoints()
    self.skill_detail_frame.ui_frame:SetPoint("TOPLEFT", self.skill_list_frame.ui_frame, "BOTTOMLEFT", 0, 0)
    self.progressbar:ResizeToHorizontalMode()
end

----------------------------------------------------------------------------------------------------------
-- Update the list of professions shown for the character
----------------------------------------------------------------------------------------------------------
function MTSLUI_CHARACTER_EXPLORER_FRAME:UpdateProfessions()
    self.profession_list_frame:ChangePlayer(MTSL_CURRENT_PLAYER.NAME, MTSL_CURRENT_PLAYER.REALM)
    self.profession_list_frame:UpdateButtonsToShowAmountMissingSkills()
    self:RefreshUI(1)
end

----------------------------------------------------------------------------------------------------------
-- Refresh the ui of the MTSLUI_CHARACTER_EXPLORER_FRAME
--
-- @force                   Number      Flag indication if we have to force a refresh (1 == yes)
-- @profession_name         String      The name of the profession
----------------------------------------------------------------------------------------------------------
function MTSLUI_CHARACTER_EXPLORER_FRAME:RefreshUI(force)
    -- only refresh if this window is visible
    if self:IsShown() or force == 1 then
        -- reset the filters when refresh of ui is forced
        if force == 1 then self:ResetFilters() end
        -- if we dont know any profession, dont show it
        if MTSL_CURRENT_PLAYER.TRADESKILLS == nil or MTSL_CURRENT_PLAYER.TRADESKILLS == {} or self.current_profession_name == "Any" then
            self.progressbar:UpdateStatusbar(0, 0, 0, 0)
            self:NoProfessionSelected()
        else
            if self.current_profession_name ~= nil then
                -- Get the list of skills which are found by the filters
                local list_skills = MTSL_LOGIC_PLAYER_NPC:GetMissingSkillsForProfessionCurrentPlayer(self.current_profession_name)
                local current_skill_level = MTSL_LOGIC_PLAYER_NPC:GetCurrentSkillLevelForProfession(MTSL_CURRENT_PLAYER.NAME, MTSL_CURRENT_PLAYER.REALM, self.current_profession_name)
                local xp_level = MTSL_CURRENT_PLAYER.XP_LEVEL
                self.skill_list_filter_frame:ChangeProfession(self.current_profession_name)
                self.skill_list_frame:UpdatePlayerLevels(xp_level, current_skill_level)
                self.skill_list_frame:ChangeProfession(self.current_profession_name, list_skills)
                -- Update the progressbar on bottom
                local skills_max_amount = MTSL_LOGIC_PROFESSION:GetTotalNumberOfAvailableSkillsForProfession(self.current_profession_name, MTSL_DATA.MAX_PATCH_LEVEL, MTSL_CURRENT_PLAYER.TRADESKILLS[self.current_profession_name].SPELLIDS_SPECIALISATION)
                local skills_phase_max_amount = MTSL_LOGIC_PROFESSION:GetTotalNumberOfAvailableSkillsForProfession(self.current_profession_name, MTSL_DATA.CURRENT_PATCH_LEVEL, MTSL_CURRENT_PLAYER.TRADESKILLS[self.current_profession_name].SPELLIDS_SPECIALISATION)
                local amount_missing = MTSL_LOGIC_PLAYER_NPC:GetAmountMissingSkillsForProfessionCurrentPlayer(self.current_profession_name)
                self.progressbar:UpdateStatusbar(0, skills_phase_max_amount, skills_max_amount, amount_missing)

                if amount_missing <= 0 then
                    self:NoSkillSelected()
                end

                local specialisation_ids = MTSL_CURRENT_PLAYER.TRADESKILLS[self.current_profession_name].SPELLIDS_SPECIALISATION
                -- update the filter dropdown for specialisations
                if specialisation_ids == nil or specialisation_ids == {} or MTSL_TOOLS:CountItemsInArray(specialisation_ids) <= 0 then
                    self.skill_list_filter_frame:UseAllSpecialisations()
                else
                    self.skill_list_filter_frame:UseOnlyLearnedSpecialisations(specialisation_ids)
                end

                -- if we miss skills, auto select first one (only do if we dont have one selected)
                if not self.skill_list_frame:HasSkillSelected() and amount_missing > 0 then
                    self.skill_list_frame:HandleSelectedListItem(1)
                end
                -- Force select first profession
            else
                self.profession_list_frame:HandleSelectedListItem(1)
            end
            self.profession_list_frame:UpdateButtonsToShowAmountMissingSkills()
        end
    end
end

----------------------------------------------------------------------------------------------------------
-- When no profession is selected
----------------------------------------------------------------------------------------------------------
function MTSLUI_CHARACTER_EXPLORER_FRAME:NoProfessionSelected()
    self.profession_list_frame:ShowNoProfessions()
    self.skill_list_frame:DeselectCurrentSkillButton()
    self.skill_detail_frame:ShowNoSkillSelected()
end

----------------------------------------------------------------------------------------------------------
-- When no skill is selected
----------------------------------------------------------------------------------------------------------
function MTSLUI_CHARACTER_EXPLORER_FRAME:NoSkillSelected()
    self.skill_list_frame:DeselectCurrentSkillButton()
    self.skill_detail_frame:ShowNoSkillSelected()
end
