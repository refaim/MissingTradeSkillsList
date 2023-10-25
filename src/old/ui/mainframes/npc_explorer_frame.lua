---------------------------------------------------------
-- Name: Database Explorer Frame                       --
-- Description: The main frame to explore the database --
---------------------------------------------------------
MTSLUI_NPC_EXPLORER_FRAME = MTSL_TOOLS:CopyObject(MTSLUI_BASE_FRAME)

MTSLUI_NPC_EXPLORER_FRAME.FRAME_WIDTH_VERTICAL_SPLIT = 1356 -- 1291
MTSLUI_NPC_EXPLORER_FRAME.FRAME_HEIGHT_VERTICAL_SPLIT = 478

MTSLUI_NPC_EXPLORER_FRAME.FRAME_WIDTH_HORIZONTAL_SPLIT = 971
MTSLUI_NPC_EXPLORER_FRAME.FRAME_HEIGHT_HORIZONTAL_SPLIT = 470

    ---------------------------------------------------------------------------------------
    -- Shows the frame
    ----------------------------------------------------------------------------------------
function MTSLUI_NPC_EXPLORER_FRAME:Show()
    -- only show if not options menu open
    if MTSLUI_OPTIONS_MENU_FRAME:IsShown() then
        MTSL_TOOLS:Print(MTSLUI_FONTS.COLORS.TEXT.ERROR .. "MTSL: " .. MTSLUI_TOOLS:GetLocalisedLabel("close options menu"))
    else
        -- hide other explorerframes
        MTSLUI_ACCOUNT_EXPLORER_FRAME:Hide()
        MTSLUI_CHARACTER_EXPLORER_FRAME:Hide()
        MTSLUI_DATABASE_EXPLORER_FRAME:Hide()
        self.ui_frame:Show()
        -- update the UI of the screen
        self:RefreshUI()
    end
end

----------------------------------------------------------------------------------------------------------
-- Intialises the MissingTradeSkillFrame
--
-- @parent_frame        Frame       The parent frame
----------------------------------------------------------------------------------------------------------
function MTSLUI_NPC_EXPLORER_FRAME:Initialise()
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
            button_text = "CHAR",
            frame_name = "MTSLUI_CHARACTER_EXPLORER_FRAME",
        },
    }
    self.ui_frame = MTSLUI_TOOLS:CreateMainFrame("MTSLUI_NPC_EXPLORER_FRAME", "MTSLUI_NpcFrame", self.FRAME_WIDTH_VERTICAL_SPLIT, self.FRAME_HEIGHT_VERTICAL_SPLIT, swap_frames)

    -- Create the frames inside this frame
    self:CreateCompontentFrames()
    self:LinkFrames()

    -- select the first npc
    self.npc_list_frame:HandleSelectedListItem(1)
end

function MTSLUI_NPC_EXPLORER_FRAME:CreateCompontentFrames()
    -- Copy & init the title frame
    self.title_frame = MTSL_TOOLS:CopyObject(MTSLUI_TITLE_FRAME)
    self.title_frame:Initialise(self.ui_frame, "NPC Explorer", self.FRAME_WIDTH_VERTICAL_SPLIT - 5, self.FRAME_WIDTH_HORIZONTAL_SPLIT - 5)
    -- position in left top corner of main frame
    self.title_frame.ui_frame:SetPoint("TOPLEFT", self.ui_frame, "TOPLEFT", 0, 0)
    -- Copy & init the filter frame
    self.npc_list_filter_frame = MTSL_TOOLS:CopyObject(MTSLUI_NPC_FILTER_FRAME)
    self.npc_list_filter_frame:Initialise(self.title_frame.ui_frame, "MTSLNPCUI_NPC_LIST_FILTER_FRAME")
    -- Copy & init the list frame
    self.npc_list_frame = MTSL_TOOLS:CopyObject(MTSLUI_NPC_LIST_FRAME)
    self.npc_list_frame:Initialise(self.title_frame.ui_frame, "MTSLNPCUI_NPC_LIST_FRAME")
    -- overwrite default width to match the larger filter frame
    self.npc_list_frame.ui_frame:SetWidth(self.npc_list_filter_frame.ui_frame:GetWidth())
    -- position under the filter frame
    self.npc_list_filter_frame.ui_frame:SetPoint("TOPLEFT", self.title_frame.ui_frame, "BOTTOMLEFT", 3, 3)
    self.npc_list_frame.ui_frame:SetPoint("TOPLEFT", self.npc_list_filter_frame.ui_frame, "BOTTOMLEFT", 0, -3)
    -- Copy & init the list frame
    self.skill_list_frame = MTSL_TOOLS:CopyObject(MTSLUI_NPC_SKILL_LIST_FRAME)
    self.skill_list_frame:Initialise(self.ui_frame, "MTSLNPCUI_SKILL_LIST_FRAME")
    -- position under the filter frame
    self.skill_list_frame.ui_frame:SetPoint("BOTTOMLEFT", self.npc_list_frame.ui_frame, "BOTTOMRIGHT", 0, 0)
    -- Copy & init the skill detail frame
    self.skill_detail_frame = MTSL_TOOLS:CopyObject(MTSLUI_SKILL_DETAIL_FRAME)
    -- adjust the height to make it fit the height of skill_list_frame
    -- adjust the height of the alternative source panel
    self.skill_detail_frame.FRAME_HEIGHT = self.skill_list_frame.ui_frame:GetHeight()
    self.skill_detail_frame.FRAME_ALT_SOURCES_HEIGHT = 112
    self.skill_detail_frame:Initialise(self.skill_list_frame.ui_frame, "MTSLNPCUI_SKILL_DETAIL_FRAME")
    self.skill_detail_frame.ui_frame:SetPoint("BOTTOMLEFT", self.skill_list_frame.ui_frame, "BOTTOMRIGHT", 0, 0)
end

function MTSLUI_NPC_EXPLORER_FRAME:LinkFrames()
    --self.npc_list_frame:SetFilterFrame(self.npc_list_filter_frame)
    self.npc_list_filter_frame:SetListFrame(self.npc_list_frame)
    self.npc_list_frame:SetSkillListFrame(self.skill_list_frame)
    self.skill_list_frame:SetDetailSelectedItemFrame(self.skill_detail_frame)
end

----------------------------------------------------------------------------------------------------------
-- Refresh the ui of the addon
----------------------------------------------------------------------------------------------------------
function MTSLUI_NPC_EXPLORER_FRAME:RefreshUI()
    -- Reset the filters
    self.npc_list_filter_frame:ResetFilters()
end

----------------------------------------------------------------------------------------------------------
-- Swap to Vertical Mode (Default mode, means list left & details right)
----------------------------------------------------------------------------------------------------------
function MTSLUI_NPC_EXPLORER_FRAME:SwapToVerticalMode()
    -- resize the frames
    self.ui_frame:SetWidth(self.FRAME_WIDTH_VERTICAL_SPLIT)
    self.ui_frame:SetHeight(self.FRAME_HEIGHT_VERTICAL_SPLIT)
    self.title_frame:ResizeToVerticalMode()
    self.npc_list_filter_frame:ResizeToVerticalMode()
    self.npc_list_frame:ResizeToVerticalMode()
    -- resize & rehook skill list frame (next to npc list frame)
    self.skill_list_frame:ResizeToVerticalMode()
    self.skill_list_frame.ui_frame:ClearAllPoints()
    self.skill_list_frame.ui_frame:SetPoint("BOTTOMLEFT", self.npc_list_frame.ui_frame, "BOTTOMRIGHT", 0, 0)
    -- adjust the height to make it fit the height of skill_list_frame
    self.skill_detail_frame.ui_frame:SetHeight(self.skill_list_frame.ui_frame:GetHeight())

    self:RefreshUI()
end

----------------------------------------------------------------------------------------------------------
-- Swap to Horizontal Mode (means list on top & details below)
----------------------------------------------------------------------------------------------------------
function MTSLUI_NPC_EXPLORER_FRAME:SwapToHorizontalMode()
    -- resize the frames where needed
    self.ui_frame:SetWidth(self.FRAME_WIDTH_HORIZONTAL_SPLIT)
    self.ui_frame:SetHeight(self.FRAME_HEIGHT_HORIZONTAL_SPLIT)
    self.title_frame:ResizeToHorizontalMode()
    self.npc_list_filter_frame:ResizeToHorizontalMode()
    self.npc_list_frame:ResizeToHorizontalMode()
    -- resize & rehook skill list frame (under the npc list frame)
    self.skill_list_frame:ResizeToHorizontalMode()
    self.skill_list_frame.ui_frame:ClearAllPoints()
    self.skill_list_frame.ui_frame:SetPoint("TOPLEFT", self.npc_list_frame.ui_frame, "BOTTOMLEFT", 0, 0)
    -- adjust the height to make it fit the height of filter frame + list frame + skill_list_frame + gap between
    local height = self.npc_list_filter_frame.ui_frame:GetHeight() + self.npc_list_frame.ui_frame:GetHeight() + self.skill_list_frame.ui_frame:GetHeight() + 2
    self.skill_detail_frame.ui_frame:SetHeight(height)

    self:RefreshUI()
end
