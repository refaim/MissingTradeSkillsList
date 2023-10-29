-----------------------------------------------------------------------
-- Name: MissingTradeSkillFrame                                      --
-- Description: The main frame shown next to TradeSkill/Craft Window --
-----------------------------------------------------------------------

---@class MTSLUI_MISSING_TRADESKILLS_FRAME: MTSLUI_BASE_FRAME
MTSLUI_MISSING_TRADESKILLS_FRAME = MTSL_TOOLS:CopyObject(MTSLUI_BASE_FRAME)

-- Custom properties
MTSLUI_MISSING_TRADESKILLS_FRAME.FRAME_WIDTH_VERTICAL_SPLIT = 908
MTSLUI_MISSING_TRADESKILLS_FRAME.FRAME_HEIGHT_VERTICAL_SPLIT = 497

MTSLUI_MISSING_TRADESKILLS_FRAME.FRAME_WIDTH_HORIZONTAL_SPLIT = 523
MTSLUI_MISSING_TRADESKILLS_FRAME.FRAME_HEIGHT_HORIZONTAL_SPLIT = 770

MTSLUI_MISSING_TRADESKILLS_FRAME.previous_amount_missing = ""
MTSLUI_MISSING_TRADESKILLS_FRAME.previous_profession_name = ""

function MTSLUI_MISSING_TRADESKILLS_FRAME:Hide()
    self.ui_frame:Hide()
    -- reset the filters
    self:ResetFilters()
    -- deselect any button from the list
    self.skill_list_frame:DeselectCurrentSkillButton()
    self.previous_amount_missing = ""
    self.previous_profession_name = ""
end

function MTSLUI_MISSING_TRADESKILLS_FRAME:Initialise()
    self.ui_frame = MTSLUI_TOOLS:CreateBaseFrame("Frame", "MTSLUI_MissingTradeSkillsFrame", MTSLUI_TOGGLE_BUTTON.ui_frame, nil, self.FRAME_WIDTH_VERTICAL_SPLIT, self.FRAME_HEIGHT_VERTICAL_SPLIT, true)
    self.ui_frame:SetFrameLevel(10)
    self.ui_frame:SetToplevel(true)
    -- Set Position relative to MTSL button
    self.ui_frame:SetPoint("TOPLEFT", MTSLUI_TOGGLE_BUTTON.ui_frame, "TOPRIGHT", -2, 0)
    -- Dummy operation to do nothing, discarding the zooming in/out
    self.ui_frame:SetScript("OnMouseWheel", function() end)
    -- hide on creation
    self.ui_frame:Hide()

    self:CreateCompontentFrames()
    self:LinkFrames()

    -- Make it dragable
    MTSLUI_TOOLS:AddDragToFrame(self.ui_frame)
end

function MTSLUI_MISSING_TRADESKILLS_FRAME:CreateCompontentFrames()
    -- initialise the components of the frame
    self.title_frame = MTSL_TOOLS:CopyObject(MTSLUI_TITLE_FRAME)
    self.title_frame:Initialise(self.ui_frame, "", 815, 510)
    -- Copy & init the filter frame
    self.skill_list_filter_frame = MTSL_TOOLS:CopyObject(MTSLUI_FILTER_FRAME)
    self.skill_list_filter_frame:Initialise(self.ui_frame, "MTSLUI_MTSLF_MISSING_SKILLS_FILTER_FRAME")
    -- position under TitleFrame
    self.skill_list_filter_frame.ui_frame:SetPoint("TOPLEFT", self.title_frame.ui_frame, "BOTTOMLEFT", 4, -5)
    -- Copy & init the list frame
    self.skill_list_frame = MTSL_TOOLS:CopyObject(MTSLUI_LIST_FRAME)
    self.skill_list_frame:Initialise(self.ui_frame, "MTSLUI_MTSLF_MISSING_SKILLS_LIST_FRAME")
    -- position under the filter frame
    self.skill_list_frame.ui_frame:SetPoint("TOPLEFT", self.skill_list_filter_frame.ui_frame, "BOTTOMLEFT", 0, -10)
    -- Copy & init the detail frame
    self.skill_detail_frame = MTSL_TOOLS:CopyObject(MTSLUI_SKILL_DETAIL_FRAME)
    self.skill_detail_frame:Initialise(self.ui_frame, "MTSLUI_MTSLF_MISSING_SKILLS_DETAIL_FRAME")
    -- position left of the list frame
    self.skill_detail_frame.ui_frame:SetPoint("BOTTOMLEFT", self.skill_list_frame.ui_frame, "BOTTOMRIGHT", 0, 0)
    -- Copy & init the pgoress bar
    self.progressbar = MTSL_TOOLS:CopyObject(MTSLUI_PROGRESSBAR)
    self.progressbar:Initialise(self.ui_frame, "MTSLUI_MTSLF_PROGRESS_BAR", MTSLUI_TOOLS:GetLocalisedLabel("missing skills"))
    -- Bottom of the frame
    self.progressbar.ui_frame:SetPoint("BOTTOMLEFT", self.ui_frame, "BOTTOMLEFT", 4, 2)
end

function MTSLUI_MISSING_TRADESKILLS_FRAME:LinkFrames()
    self.skill_list_filter_frame:SetListFrame(self.skill_list_frame)
    self.skill_list_frame:SetDetailSelectedItemFrame(self.skill_detail_frame)
end

function MTSLUI_MISSING_TRADESKILLS_FRAME:SwapToVerticalMode()
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

function MTSLUI_MISSING_TRADESKILLS_FRAME:SwapToHorizontalMode()
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

function MTSLUI_MISSING_TRADESKILLS_FRAME:RefreshUI(force)
    -- only refresh if this window is visible
    if self:IsShown() or force == 1 then
        -- reset the filters when refresh of ui is forced
        if force == 1 then
            self:ResetFilters()
            self.skill_list_filter_frame:DontIncludeOppositeFaction()
        end
        -- only update if we have a current profession
        if self.current_profession_name ~= nil then
            -- Get the list of skills which are found by the filters
            local list_skills = MTSL_LOGIC_PLAYER_NPC:GetMissingSkillsForProfessionCurrentPlayer(self.current_profession_name)
            -- Refresh the UI frame showing the list of skill
            self.skill_list_frame:UpdateList(list_skills)

            -- Update the progressbar on bottom
            local skills_amount_total = MTSL_LOGIC_PROFESSION:GetTotalNumberOfAvailableSkillsForProfession(self.current_profession_name, MTSL_CURRENT_PLAYER.TRADESKILLS[self.current_profession_name].SPELLIDS_SPECIALISATION)
            local skills_amount_missing = MTSL_LOGIC_PLAYER_NPC:GetAmountMissingSkillsForProfessionCurrentPlayer(self.current_profession_name)
            self.progressbar:UpdateStatusbar(skills_amount_missing, skills_amount_total)

            self:NoSkillSelected()
            -- if we miss skills, auto select first one
            if skills_amount_missing > 0 then
                self.skill_list_frame:HandleSelectedListItem(1)
            end
        end
    end
end

function MTSLUI_MISSING_TRADESKILLS_FRAME:SetCurrentProfessionDetails(profession_name, current_skill_level, xp_level, specialisation_ids)
    self.current_profession_name = profession_name
    self.skill_list_filter_frame:ChangeProfession(profession_name)
    self.skill_list_frame:UpdatePlayerLevels(xp_level, current_skill_level)
    local list_skills = MTSL_LOGIC_PLAYER_NPC:GetMissingSkillsForProfessionCurrentPlayer(profession_name)
    self.skill_list_frame:ChangeProfession(profession_name, list_skills)
    -- update the filter dropdown for specialisations
    if specialisation_ids == nil or MTSL_TOOLS:TableEmpty(specialisation_ids) then
        self.skill_list_filter_frame:UseAllSpecialisations()
    else
        self.skill_list_filter_frame:UseOnlyLearnedSpecialisations(specialisation_ids)
    end
end
function MTSLUI_MISSING_TRADESKILLS_FRAME:GetCurrentProfessionName()
    return self.current_profession_name
end

function MTSLUI_MISSING_TRADESKILLS_FRAME:NoSkillSelected()
    self.skill_list_frame:NoSkillsToShow()
end
