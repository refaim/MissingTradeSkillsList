---------------------------------------------------------
-- Name: Database Explorer Frame                       --
-- Description: The main frame to explore the database --
---------------------------------------------------------

---@class MTSLUI_ACCOUNT_EXPLORER_FRAME: MTSLUI_BASE_FRAME
---@field title_frame MTSLUI_TITLE_FRAME
---@field player_filter_frame MTSLUI_PLAYER_FILTER_FRAME
---@field player_list_frame MTSLUI_PLAYER_LIST_FRAME
---@field profession_list_frame MTSLUI_ProfessionList
---@field skill_list_filter_frame MTSLUI_FILTER_FRAME
MTSLUI_ACCOUNT_EXPLORER_FRAME = MTSL_TOOLS:CopyObject(MTSLUI_BASE_FRAME)

MTSLUI_ACCOUNT_EXPLORER_FRAME.FRAME_WIDTH_VERTICAL_SPLIT = 1272
MTSLUI_ACCOUNT_EXPLORER_FRAME.FRAME_HEIGHT_VERTICAL_SPLIT = 479

MTSLUI_ACCOUNT_EXPLORER_FRAME.FRAME_WIDTH_HORIZONTAL_SPLIT = 887
MTSLUI_ACCOUNT_EXPLORER_FRAME.FRAME_HEIGHT_HORIZONTAL_SPLIT = 738

function MTSLUI_ACCOUNT_EXPLORER_FRAME:Show()
    -- only show if not options menu open
    if MTSLUI_OPTIONS_MENU_FRAME:IsShown() then
        MTSL_TOOLS:Print(MTSLUI_FONTS.COLORS.TEXT.ERROR .. "MTSL: " .. MTSLUI_TOOLS:GetLocalisedLabel("close options menu"))
    else
        -- hide other explorerframes
        MTSLUI_CHARACTER_EXPLORER_FRAME:Hide()
        MTSLUI_DATABASE_EXPLORER_FRAME:Hide()
        MTSLUI_NPC_EXPLORER_FRAME:Hide()
        self.ui_frame:Show()
        -- update the UI of the screen
        self:RefreshUI()
    end
end

function MTSLUI_ACCOUNT_EXPLORER_FRAME:Initialise()
    local swap_frames = {
        {
            button_text = "CHAR",
            frame_name = "MTSLUI_CHARACTER_EXPLORER_FRAME",
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
    self.ui_frame = MTSLUI_TOOLS:CreateMainFrame("MTSLUI_ACCOUNT_EXPLORER_FRAME", "MTSLUI_AccountFrame", self.FRAME_WIDTH_VERTICAL_SPLIT, self.FRAME_HEIGHT_VERTICAL_SPLIT, swap_frames)

    self.title_frame = MTSL_TOOLS:CopyObject(MTSLUI_TITLE_FRAME)
    self.player_filter_frame = MTSL_TOOLS:CopyObject(MTSLUI_PLAYER_FILTER_FRAME)
    self.player_list_frame = MTSL_TOOLS:CopyObject(MTSLUI_PLAYER_LIST_FRAME)
    self.profession_list_frame = MTSL_TOOLS:CopyObject(MTSLUI_ProfessionList)
    self.skill_list_filter_frame = MTSL_TOOLS:CopyObject(MTSLUI_FILTER_FRAME)
    self.skill_list_frame = MTSL_TOOLS:CopyObject(MTSLUI_LIST_FRAME)
    self.skill_detail_frame = MTSL_TOOLS:CopyObject(MTSLUI_SKILL_DETAIL_FRAME)

    self.title_frame:Initialise(self.ui_frame, "Account Explorer", self.FRAME_WIDTH_VERTICAL_SPLIT - 5, self.FRAME_WIDTH_HORIZONTAL_SPLIT - 5)
    self.player_filter_frame:Initialise(self.title_frame.ui_frame, "MTSLACCUI_PLAYER_FILTER_FRAME")
    self.player_list_frame:Initialise(self.player_filter_frame.ui_frame, "MTSLACCUI_PLAYER_LIST_FRAME")
    self.profession_list_frame:Initialise(self.player_list_frame.ui_frame, self.skill_list_filter_frame, self.skill_list_frame)
    self.skill_list_filter_frame:Initialise(self.profession_list_frame:GetFrame(), "MTSLACCUI_SKILL_LIST_FILTER_FRAME")
    self.skill_list_frame:Initialise(self.skill_list_filter_frame.ui_frame, "MTSLACCUI_SKILL_LIST_FRAME")
    self.skill_detail_frame:Initialise(self.skill_list_frame.ui_frame, "MTSLACCUI_SKILL_DETAIL_FRAME")

    self.title_frame.ui_frame:SetPoint("TOPLEFT", self.ui_frame, "TOPLEFT", 0, 0)
    self.player_list_frame.ui_frame:SetPoint("BOTTOMLEFT", self.ui_frame, "BOTTOMLEFT", 3, 3)
    self.player_filter_frame.ui_frame:SetPoint("BOTTOMLEFT", self.player_list_frame.ui_frame, "TOPLEFT", 0, 5)
    self.profession_list_frame:GetFrame():SetPoint("TOPLEFT", self.player_filter_frame.ui_frame, "TOPRIGHT", -6, 1)
    self.skill_list_filter_frame.ui_frame:SetPoint("TOPLEFT", self.profession_list_frame:GetFrame(), "TOPRIGHT", 0, 0)
    self.skill_list_frame.ui_frame:SetPoint("TOPLEFT", self.skill_list_filter_frame.ui_frame, "BOTTOMLEFT", 1, -5)
    self.skill_detail_frame.ui_frame:SetPoint("BOTTOMLEFT", self.skill_list_frame.ui_frame, "BOTTOMRIGHT", 0, 0)

    self.player_filter_frame:SetListFrame(self.player_list_frame)
    self.player_list_frame:SetProfessionListFrame(self.profession_list_frame)
    self.skill_list_filter_frame:SetListFrame(self.skill_list_frame)
    self.skill_list_frame:SetDetailSelectedItemFrame(self.skill_detail_frame)

    -- select the first player
    self.player_list_frame:HandleSelectedListItem(1)
end

function MTSLUI_ACCOUNT_EXPLORER_FRAME:RefreshUI()
    -- auto select the first player
    self.player_list_frame:UpdateList()
    self.player_list_frame:HandleSelectedListItem(1)
end

function MTSLUI_ACCOUNT_EXPLORER_FRAME:SwapToVerticalMode()
    -- resize the frames
    self.ui_frame:SetWidth(self.FRAME_WIDTH_VERTICAL_SPLIT)
    self.ui_frame:SetHeight(self.FRAME_HEIGHT_VERTICAL_SPLIT)
    self.title_frame:ResizeToVerticalMode()

    self.player_list_frame:ResizeToVerticalMode()

    self.skill_list_filter_frame:ResizeToVerticalMode()
    self.skill_list_frame:ResizeToVerticalMode()
    -- no need to resize detail frame, always same size, just rehook it
    self.skill_detail_frame.ui_frame:ClearAllPoints()
    self.skill_detail_frame.ui_frame:SetPoint("BOTTOMLEFT", self.skill_list_frame.ui_frame, "BOTTOMRIGHT", 0, 0)
end

function MTSLUI_ACCOUNT_EXPLORER_FRAME:SwapToHorizontalMode()
    -- resize the frames where needed
    self.ui_frame:SetWidth(self.FRAME_WIDTH_HORIZONTAL_SPLIT)
    self.ui_frame:SetHeight(self.FRAME_HEIGHT_HORIZONTAL_SPLIT)
    self.title_frame:ResizeToHorizontalMode()

    self.player_list_frame:ResizeToHorizontalMode()

    self.skill_list_filter_frame:ResizeToHorizontalMode()
    self.skill_list_frame:ResizeToHorizontalMode()
    -- no need to resize detail frame, always same size, just rehook it
    self.skill_detail_frame.ui_frame:ClearAllPoints()
    self.skill_detail_frame.ui_frame:SetPoint("TOPLEFT", self.skill_list_frame.ui_frame, "BOTTOMLEFT", 0, 2)
end

function MTSLUI_ACCOUNT_EXPLORER_FRAME:ChangeToPlayer(realm_name, player_name)
    self.profession_list_frame:SetPlayer({NAME = player_name, REALM = realm_name})
end
