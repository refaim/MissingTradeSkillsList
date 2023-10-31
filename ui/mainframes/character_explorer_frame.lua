-----------------------------------------------------------------------
-- Name: MissingTradeSkillFrame                                      --
-- Description: The main frame shown next to TradeSkill/Craft Window --
-----------------------------------------------------------------------

---@class MTSLUI_CHARACTER_EXPLORER_FRAME: MTSLUI_BASE_FRAME
MTSLUI_CHARACTER_EXPLORER_FRAME = MTSL_TOOLS:CopyObject(MTSLUI_BASE_FRAME)

-- Custom properties
MTSLUI_CHARACTER_EXPLORER_FRAME.FRAME_WIDTH_VERTICAL_SPLIT = 975
MTSLUI_CHARACTER_EXPLORER_FRAME.FRAME_HEIGHT_VERTICAL_SPLIT = 495

MTSLUI_CHARACTER_EXPLORER_FRAME.FRAME_WIDTH_HORIZONTAL_SPLIT = 590
MTSLUI_CHARACTER_EXPLORER_FRAME.FRAME_HEIGHT_HORIZONTAL_SPLIT = 768

MTSLUI_CHARACTER_EXPLORER_FRAME.previous_amount_missing = ""
MTSLUI_CHARACTER_EXPLORER_FRAME.previous_profession_name = ""

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

    self.title_frame = MTSL_TOOLS:CopyObject(MTSLUI_TITLE_FRAME)
    self.profession_list_frame = MTSL_TOOLS:CopyObject(MTSLUI_ProfessionList)
    self.skill_list_filter_frame = MTSL_TOOLS:CopyObject(MTSLUI_FILTER_FRAME)
    self.skill_list_frame = MTSL_TOOLS:CopyObject(MTSLUI_LIST_FRAME)
    self.skill_detail_frame = MTSL_TOOLS:CopyObject(MTSLUI_SKILL_DETAIL_FRAME)
    self.progressbar = MTSL_TOOLS:CopyObject(MTSLUI_PROGRESSBAR)

    self.title_frame:Initialise(self.ui_frame, "Character Explorer", self.FRAME_WIDTH_VERTICAL_SPLIT - 5, self.FRAME_WIDTH_HORIZONTAL_SPLIT - 5)
    self.profession_list_frame:Initialise(self.ui_frame, self.skill_list_filter_frame, self.skill_list_frame)
    self.skill_list_filter_frame:Initialise(self.ui_frame, "MTSLUI_CHAR_EXPLORER_FILTER_FRAME")
    self.skill_list_frame:Initialise(self.ui_frame, "MTSLUI_CHAR_EXPLORER_LIST_FRAME")
    self.skill_detail_frame:Initialise(self.ui_frame, "MTSLUI_CHAR_EXPLORER_DETAIL_FRAME")
    self.progressbar:Initialise(self.ui_frame, "MTSLUI_MTSLF_PROGRESS_BAR", MTSLUI_TOOLS:GetLocalisedLabel("missing skills"))

    self.profession_list_frame.ui_frame:SetPoint("TOPLEFT", self.ui_frame, "TOPLEFT", 4, -32)
    self.skill_list_filter_frame.ui_frame:SetPoint("TOPLEFT", self.profession_list_frame.ui_frame, "TOPRIGHT", 0, 0)
    self.skill_list_frame.ui_frame:SetPoint("TOPLEFT", self.skill_list_filter_frame.ui_frame, "BOTTOMLEFT", 0, -10)
    self.skill_detail_frame.ui_frame:SetPoint("BOTTOMLEFT", self.skill_list_frame.ui_frame, "BOTTOMRIGHT", 0, 0)
    self.progressbar.ui_frame:SetPoint("TOPRIGHT", self.skill_detail_frame.ui_frame, "BOTTOMRIGHT", 0, 3)

    self.skill_list_filter_frame:SetListFrame(self.skill_list_frame)
    self.skill_list_frame:SetDetailSelectedItemFrame(self.skill_detail_frame)

    self.profession_list_frame:SetPlayer(MTSL_CURRENT_PLAYER)
    self.profession_list_frame:UpdateButtonsToShowAmountMissingSkills()
end

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

function MTSLUI_CHARACTER_EXPLORER_FRAME:UpdateProfessions()
    self.profession_list_frame:SetPlayer(MTSL_CURRENT_PLAYER)
    self.profession_list_frame:UpdateButtonsToShowAmountMissingSkills()
    self:RefreshUI(1)
end

function MTSLUI_CHARACTER_EXPLORER_FRAME:RefreshUI(force)
    -- only refresh if this window is visible
    if self:IsShown() or force == 1 then
        -- reset the filters when refresh of ui is forced
        if force == 1 then self:ResetFilters() end
        -- if we dont know any profession, dont show it
        if MTSL_CURRENT_PLAYER.TRADESKILLS == nil or MTSL_TOOLS:TableEmpty(MTSL_CURRENT_PLAYER.TRADESKILLS) or self.current_profession_name == "Any" then
            self.progressbar:UpdateStatusbar(0, 0)
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
                local skills_amount_total = MTSL_LOGIC_PROFESSION:GetTotalNumberOfAvailableSkillsForProfession(self.current_profession_name, MTSL_CURRENT_PLAYER.TRADESKILLS[self.current_profession_name].SPELLIDS_SPECIALISATION)
                local skills_amount_missing = MTSL_LOGIC_PLAYER_NPC:GetAmountMissingSkillsForProfessionCurrentPlayer(self.current_profession_name)
                self.progressbar:UpdateStatusbar(skills_amount_missing, skills_amount_total)

                if skills_amount_missing <= 0 then
                    self:NoSkillSelected()
                end

                local specialisation_ids = MTSL_CURRENT_PLAYER.TRADESKILLS[self.current_profession_name].SPELLIDS_SPECIALISATION
                -- update the filter dropdown for specialisations
                if specialisation_ids == nil or MTSL_TOOLS:TableEmpty(specialisation_ids) then
                    self.skill_list_filter_frame:UseAllSpecialisations()
                else
                    self.skill_list_filter_frame:UseOnlyLearnedSpecialisations(specialisation_ids)
                end

                -- if we miss skills, auto select first one (only do if we dont have one selected)
                if not self.skill_list_frame:HasSkillSelected() and skills_amount_missing > 0 then
                    self.skill_list_frame:HandleSelectedListItem(1)
                end
            else
                -- Force select first profession
                self.profession_list_frame:HandleSelectedListItem(1)
            end
            self.profession_list_frame:UpdateButtonsToShowAmountMissingSkills()
        end
    end
end

function MTSLUI_CHARACTER_EXPLORER_FRAME:NoProfessionSelected()
    self.profession_list_frame:ShowNoProfessions()
    self.skill_list_frame:DeselectCurrentSkillButton()
    self.skill_detail_frame:ShowNoSkillSelected()
end

function MTSLUI_CHARACTER_EXPLORER_FRAME:NoSkillSelected()
    self.skill_list_frame:DeselectCurrentSkillButton()
    self.skill_detail_frame:ShowNoSkillSelected()
end
