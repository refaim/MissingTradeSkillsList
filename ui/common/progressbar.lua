------------------------------------------------------------------
-- Name: ProgressBar                                            --
-- Description: Contains all functionality for the progressbar  --
-- Parent Frame: MissingTradeSkillsListFrame                    --
------------------------------------------------------------------

MTSLUI_PROGRESSBAR = {
    ui_frame = {},
    FRAME_WIDTH_VERTICAL = 900,
    FRAME_WIDTH_HORIZONTAL = 515,
    FRAME_HEIGHT = 28,

    MARGIN_PROGRESS_BAR = 150,
    HEIGHT_PROGRESS_BAR = 24,

    ----------------------------------------------------------------------------------------------------------
    -- Intialises  the progressbar
    ----------------------------------------------------------------------------------------------------------
    Initialise = function(self, parent_frame, name, title_text)
        self.ui_frame = MTSLUI_TOOLS:CreateBaseFrame("Frame", name, parent_frame, nil, self.FRAME_WIDTH_VERTICAL, self.FRAME_HEIGHT, false)
        self.ui_frame.text = MTSLUI_TOOLS:CreateLabel(self.ui_frame, title_text, 5, 0, "TEXT", "LEFT")

        local pb_width = self.FRAME_WIDTH_VERTICAL - self.MARGIN_PROGRESS_BAR
        self.ui_frame.progressbar = {}

        self.ui_frame.progressbar.ui_frame = MTSLUI_TOOLS:CreateBaseFrame("Frame", name .. "_PB_frame", self.ui_frame, nil, pb_width, self.HEIGHT_PROGRESS_BAR, false)
        self.ui_frame.progressbar.ui_frame:SetPoint("TOPLEFT", self.ui_frame, "TOPLEFT", self.MARGIN_PROGRESS_BAR, -2)

        self.ui_frame.progressbar.ui_frame.texture = MTSLUI_TOOLS:CreateBaseFrame("Statusbar", name .. "_PB_Texture", self.ui_frame.progressbar.ui_frame, nil, pb_width - 6, self.HEIGHT_PROGRESS_BAR - 6, false)
        self.ui_frame.progressbar.ui_frame.texture:SetPoint("TOPLEFT", self.ui_frame.progressbar.ui_frame, "TOPLEFT", 4, -3)
        self.ui_frame.progressbar.ui_frame.texture:SetStatusBarTexture("Interface/PaperDollInfoFrame/UI-Character-Skills-Bar")

        self.ui_frame.progressbar.ui_frame.counter = MTSLUI_TOOLS:CreateBaseFrame("Frame", name .. "_PB_Counter", self.ui_frame.progressbar.ui_frame, nil, pb_width, self.HEIGHT_PROGRESS_BAR, true)
        self.ui_frame.progressbar.ui_frame.counter:SetPoint("TOPLEFT", self.ui_frame.progressbar.ui_frame, "TOPLEFT", 0, 0)
        -- Status text
        self.ui_frame.progressbar.ui_frame.counter.text = MTSLUI_TOOLS:CreateLabel(self.ui_frame.progressbar.ui_frame.counter, "", 0, 0, "LABEL", "CENTER")
    end,

    ----------------------------------------------------------------------------------------------------------
    -- Updates the values shown on the progressbar
    --
    -- @min_value           number
    -- @phase_max_value     number
    -- @max_value           number
    -- @current_value       number
    ----------------------------------------------------------------------------------------------------------
    UpdateStatusbar = function(self, min_value, phase_max_value, max_value, current_value)
        self.ui_frame.progressbar.ui_frame.texture:SetMinMaxValues(min_value, phase_max_value)
        self.ui_frame.progressbar.ui_frame.texture:SetValue(current_value)
        self.ui_frame.progressbar.ui_frame.texture:SetStatusBarColor(0.0, 1.0, 0.0, 0.95)
        if phase_max_value == max_value then
            self.ui_frame.progressbar.ui_frame.counter.text:SetText(MTSLUI_FONTS.COLORS.TEXT.NORMAL .. current_value .. "/" .. phase_max_value)
        else
            self.ui_frame.progressbar.ui_frame.counter.text:SetText(MTSLUI_FONTS.COLORS.TEXT.NORMAL .. current_value .. "/" .. phase_max_value .. "   [" ..  max_value .. "]")
        end
    end,

    ----------------------------------------------------------------------------------------------------------
    -- Switch to vertical split layout
    ----------------------------------------------------------------------------------------------------------
    ResizeToVerticalMode = function(self)
        self:ResizeToWidth(self.FRAME_WIDTH_VERTICAL)
    end,

    ----------------------------------------------------------------------------------------------------------
    -- Switch to horizontal split layout
    ----------------------------------------------------------------------------------------------------------
    ResizeToHorizontalMode = function(self)
        self:ResizeToWidth(self.FRAME_WIDTH_HORIZONTAL)
    end,

    ----------------------------------------------------------------------------------------------------------
    -- Resize the whole progressbar to a width
    --
    -- @width           Number      The number of the width of the frame
    ----------------------------------------------------------------------------------------------------------
    ResizeToWidth = function(self, width)
        -- no need for height cause its same in both modes
        self.ui_frame:SetWidth(width)
        -- resize the progressbar
        local pb_width = width - self.MARGIN_PROGRESS_BAR
        self.ui_frame.progressbar.ui_frame:SetWidth(pb_width)
        -- make fill texture smaller than border
        self.ui_frame.progressbar.ui_frame.texture:SetWidth(pb_width - 6)
        self.ui_frame.progressbar.ui_frame.counter:SetWidth(pb_width)
    end,
}
