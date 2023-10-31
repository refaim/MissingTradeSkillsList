---------------------------------------------------------
-- Name: Database Explorer Frame                       --
-- Description: The main frame to explore the database --
---------------------------------------------------------

---@class MTSLUI_DATABASE_EXPLORER_FRAME: MTSLUI_BASE_FRAME
MTSLUI_DATABASE_EXPLORER_FRAME = MTSL_TOOLS:CopyObject(MTSLUI_BASE_FRAME)

MTSLUI_DATABASE_EXPLORER_FRAME.FRAME_WIDTH_VERTICAL_SPLIT = 1274
MTSLUI_DATABASE_EXPLORER_FRAME.FRAME_HEIGHT_VERTICAL_SPLIT = 479

MTSLUI_DATABASE_EXPLORER_FRAME.FRAME_WIDTH_HORIZONTAL_SPLIT = 889
MTSLUI_DATABASE_EXPLORER_FRAME.FRAME_HEIGHT_HORIZONTAL_SPLIT = 744

function MTSLUI_DATABASE_EXPLORER_FRAME:Show()
    -- only show if not options menu open
    if MTSLUI_OPTIONS_MENU_FRAME:IsShown() then
        MTSL_TOOLS:Print(MTSLUI_FONTS.COLORS.TEXT.ERROR .. "MTSL: " .. MTSLUI_TOOLS:GetLocalisedLabel("close options menu"))
    else
        -- hide other explorerframes
        MTSLUI_ACCOUNT_EXPLORER_FRAME:Hide()
        MTSLUI_CHARACTER_EXPLORER_FRAME:Hide()
        MTSLUI_NPC_EXPLORER_FRAME:Hide()
        self.ui_frame:Show()
        -- update the UI of the screen
        self:RefreshUI()
    end
end

function MTSLUI_DATABASE_EXPLORER_FRAME:Initialise()
    local swap_frames = {
        {
            button_text = "ACC",
            frame_name = "MTSLUI_ACCOUNT_EXPLORER_FRAME",
        },
        {
            button_text = "CHAR",
            frame_name = "MTSLUI_CHARACTER_EXPLORER_FRAME",
        },
        {
            button_text = "NPC",
            frame_name = "MTSLUI_NPC_EXPLORER_FRAME",
        },
    }
    self.ui_frame = MTSLUI_TOOLS:CreateMainFrame("MTSLUI_DATABASE_EXPLORER_FRAME", "MTSLUI_DatabaseFrame", self.FRAME_WIDTH_VERTICAL_SPLIT, self.FRAME_HEIGHT_VERTICAL_SPLIT, swap_frames)

    self.title_frame = MTSL_TOOLS:CopyObject(MTSLUI_TITLE_FRAME)
    self.profession_list_frame = MTSL_TOOLS:CopyObject(MTSLUI_ProfessionList)
    self.skill_list_filter_frame = MTSL_TOOLS:CopyObject(MTSLUI_FILTER_FRAME)
    self.skill_list_frame = MTSL_TOOLS:CopyObject(MTSLUI_LIST_FRAME)
    self.skill_detail_frame = MTSL_TOOLS:CopyObject(MTSLUI_SKILL_DETAIL_FRAME)
    self.player_filter_frame = MTSL_TOOLS:CopyObject(MTSLUI_PLAYER_FILTER_FRAME)
    self.player_list_frame = MTSL_TOOLS:CopyObject(MTSLUI_PLAYER_LIST_FRAME)

    self.title_frame:Initialise(self.ui_frame, "Database Explorer", self.FRAME_WIDTH_VERTICAL_SPLIT - 5, self.FRAME_WIDTH_HORIZONTAL_SPLIT - 5)
    self.profession_list_frame:Initialise(self.title_frame.ui_frame, self.skill_list_filter_frame, self.skill_list_frame)
    self.skill_list_filter_frame:Initialise(self.profession_list_frame.ui_frame, "MTSLDBUI_SKILL_LIST_FILTER_FRAME")
    self.skill_list_frame:Initialise(self.skill_list_filter_frame.ui_frame, "MTSLDBUI_SKILL_LIST_FRAME")
    self.skill_detail_frame:Initialise(self.skill_list_frame.ui_frame, "MTSLDBUI_SKILL_DETAIL_FRAME")
    self.player_filter_frame:Initialise(self.skill_detail_frame.ui_frame, "MTSLDBUI_PLAYER_FILTER_FRAME")
    self.player_list_frame:Initialise(self.player_filter_frame.ui_frame, "MTSLDBUI_PLAYER_LIST_FRAME")

    self.title_frame.ui_frame:SetPoint("TOPLEFT", self.ui_frame, "TOPLEFT", 0, 0)
    self.profession_list_frame.ui_frame:SetPoint("TOPLEFT", self.title_frame.ui_frame, "TOPLEFT", 4, -6)
    self.skill_list_filter_frame.ui_frame:SetPoint("TOPLEFT", self.profession_list_frame.ui_frame, "TOPRIGHT", 0, -41)
    self.skill_list_frame.ui_frame:SetPoint("TOPLEFT", self.skill_list_filter_frame.ui_frame, "BOTTOMLEFT", 0, -4)
    self.skill_detail_frame.ui_frame:SetPoint("BOTTOMLEFT", self.skill_list_frame.ui_frame, "BOTTOMRIGHT", 0, 0)
    self.player_filter_frame.ui_frame:SetPoint("TOPLEFT", self.skill_detail_frame.ui_frame, "TOPRIGHT", 0, -5)
    self.player_list_frame.ui_frame:SetPoint("TOPLEFT", self.player_filter_frame.ui_frame, "BOTTOMLEFT", 0, -8)

    self.skill_list_filter_frame:SetListFrame(self.skill_list_frame)
    -- reset the filters so the default values are passed to the slill_list_frame
    self.skill_list_frame:SetDetailSelectedItemFrame(self.skill_detail_frame)
    self.skill_list_frame:SetPlayerListFrame(self.player_list_frame)
    self.player_filter_frame:SetListFrame(self.player_list_frame)

    self.player_list_frame:EnableShowSkillLevelNeeded()

    -- select the first profession
    self.profession_list_frame:ChangeNoPlayer()
    self.profession_list_frame:HandleSelectedListItem(1)
end

function MTSLUI_DATABASE_EXPLORER_FRAME:RefreshUI()
    -- Reset the filters
    self.skill_list_filter_frame:ResetFilters()
    -- auto select the first profession
    self.profession_list_frame:HandleSelectedListItem(1)
    -- update the filter player frame for possible realms
    self.player_filter_frame:ChangeCurrentProfession(self.profession_list_frame:GetCurrentProfession())
end

function MTSLUI_DATABASE_EXPLORER_FRAME:SwapToVerticalMode()
    -- resize the frames
    self.ui_frame:SetWidth(self.FRAME_WIDTH_VERTICAL_SPLIT)
    self.ui_frame:SetHeight(self.FRAME_HEIGHT_VERTICAL_SPLIT)
    self.title_frame:ResizeToVerticalMode()
    self.skill_list_filter_frame:ResizeToVerticalMode()
    self.skill_list_frame:ResizeToVerticalMode()
    -- no need to resize detail frame, always same size, just rehook it
    self.skill_detail_frame.ui_frame:ClearAllPoints()
    self.skill_detail_frame.ui_frame:SetPoint("BOTTOMLEFT", self.skill_list_frame.ui_frame, "BOTTOMRIGHT", 0, 0)
    -- no need to resize the player filter frame, just rehook it (next to detail frame)
    self.player_filter_frame.ui_frame:ClearAllPoints()
    self.player_filter_frame.ui_frame:SetPoint("TOPLEFT", self.skill_detail_frame.ui_frame, "TOPRIGHT", 0, -8)

    self.player_list_frame:ResizeToVerticalMode()
end

function MTSLUI_DATABASE_EXPLORER_FRAME:SwapToHorizontalMode()
    -- resize the frames where needed
    self.ui_frame:SetWidth(self.FRAME_WIDTH_HORIZONTAL_SPLIT)
    self.ui_frame:SetHeight(self.FRAME_HEIGHT_HORIZONTAL_SPLIT)
    self.title_frame:ResizeToHorizontalMode()
    self.skill_list_filter_frame:ResizeToHorizontalMode()
    self.skill_list_frame:ResizeToHorizontalMode()
    -- no need to resize detail frame, always same size, just rehook it
    self.skill_detail_frame.ui_frame:ClearAllPoints()
    self.skill_detail_frame.ui_frame:SetPoint("TOPLEFT", self.skill_list_frame.ui_frame, "BOTTOMLEFT", 0, 0)
    -- no need to resize the player filter frame, just rehook it (next to detail frame)
    self.player_filter_frame.ui_frame:ClearAllPoints()
    self.player_filter_frame.ui_frame:SetPoint("TOPLEFT", self.skill_list_filter_frame.ui_frame, "TOPRIGHT", 0, 0)

    self.player_list_frame:ResizeToHorizontalMode()
end
