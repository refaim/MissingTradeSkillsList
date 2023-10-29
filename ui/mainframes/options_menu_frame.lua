--------------------------------------------------
-- Name: OptionsMenuFrame                       --
-- Description: Shows user configurable options --
--      Font                                    --
--      Scale for each frame                    --
--      Layout MTSL frame                       --
--------------------------------------------------

---@class MTSLUI_OPTIONS_MENU_FRAME: MTSLUI_BASE_FRAME
MTSLUI_OPTIONS_MENU_FRAME = MTSL_TOOLS:CopyObject(MTSLUI_BASE_FRAME)

-- Add or overwrite baseframe
    -- Addon frame
MTSLUI_OPTIONS_MENU_FRAME.FRAME_WIDTH = 1100
MTSLUI_OPTIONS_MENU_FRAME.FRAME_HEIGHT = 680

    ---------------------------------------------------------------------------------------
    -- Shows the frame
    ----------------------------------------------------------------------------------------
function MTSLUI_OPTIONS_MENU_FRAME:Show()
    -- Make sure any other open windows are closed
    MTSLUI_MISSING_TRADESKILLS_FRAME:Hide()
    MTSLUI_ACCOUNT_EXPLORER_FRAME:Hide()
    MTSLUI_CHARACTER_EXPLORER_FRAME:Hide()
    MTSLUI_DATABASE_EXPLORER_FRAME:Hide()
    MTSLUI_NPC_EXPLORER_FRAME:Hide()
    -- show the options
    self.ui_frame:Show()
    -- auto select the current player in the drop down to remove data
    MTSLOPTUI_RESET_FRAME:SelectCurrentPlayer()
end

----------------------------------------------------------------------------------------------------------
-- Intialises the MissingTradeSkillFrame
--
-- @parent_frame        Frame       The parent frame
----------------------------------------------------------------------------------------------------------
function MTSLUI_OPTIONS_MENU_FRAME:Initialise()
    self.ui_frame = MTSLUI_TOOLS:CreateMainFrame("MTSLUI_OPTIONS_MENU_FRAME", "MTSLUI_Options_Menu_Frame", self.FRAME_WIDTH, self.FRAME_HEIGHT)
    -- Create the frames inside this frame
    self:CreateCompontentFrames()
end

function MTSLUI_OPTIONS_MENU_FRAME:CreateCompontentFrames()
    -- initialise the content frames
    self.title_frame = MTSL_TOOLS:CopyObject(MTSLUI_TITLE_FRAME)
    self.title_frame:Initialise(self.ui_frame, MTSLUI_TOOLS:GetLocalisedLabel("options"), self.FRAME_WIDTH, self.FRAME_WIDTH)
    MTSLOPTUI_CONFIG_FRAME:Initialise(self.title_frame.ui_frame)
    MTSLOPTUI_SAVE_FRAME:Initialise(MTSLOPTUI_CONFIG_FRAME.ui_frame)
    MTSLOPTUI_RESET_FRAME:Initialise(MTSLOPTUI_SAVE_FRAME.ui_frame)
end
