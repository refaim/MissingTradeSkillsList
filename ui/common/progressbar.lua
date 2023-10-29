------------------------------------------------------------------
-- Name: ProgressBar                                            --
-- Description: Contains all functionality for the progressbar  --
-- Parent Frame: MissingTradeSkillsListFrame                    --
------------------------------------------------------------------

---@class MTSLUI_PROGRESSBAR
MTSLUI_PROGRESSBAR = {
    ui_frame = {},
    FRAME_WIDTH_VERTICAL = 900,
    FRAME_WIDTH_HORIZONTAL = 515,
    FRAME_HEIGHT = 28,

    MARGIN_PROGRESS_BAR = 150,
    HEIGHT_PROGRESS_BAR = 24,
}

function MTSLUI_PROGRESSBAR:Initialise(parent_frame, name, title_text)
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
end

function MTSLUI_PROGRESSBAR:UpdateStatusbar(current_value, max_value)
    self.ui_frame.progressbar.ui_frame.texture:SetMinMaxValues(0, max_value)
    self.ui_frame.progressbar.ui_frame.texture:SetValue(current_value)
    self.ui_frame.progressbar.ui_frame.texture:SetStatusBarColor(0.0, 1.0, 0.0, 0.95)
    self.ui_frame.progressbar.ui_frame.counter.text:SetText(MTSLUI_FONTS.COLORS.TEXT.NORMAL .. current_value .. "/" .. max_value)
end

function MTSLUI_PROGRESSBAR:ResizeToVerticalMode()
    self:ResizeToWidth(self.FRAME_WIDTH_VERTICAL)
end

function MTSLUI_PROGRESSBAR:ResizeToHorizontalMode()
    self:ResizeToWidth(self.FRAME_WIDTH_HORIZONTAL)
end

function MTSLUI_PROGRESSBAR:ResizeToWidth(width)
    -- no need for height cause its same in both modes
    self.ui_frame:SetWidth(width)
    -- resize the progressbar
    local pb_width = width - self.MARGIN_PROGRESS_BAR
    self.ui_frame.progressbar.ui_frame:SetWidth(pb_width)
    -- make fill texture smaller than border
    self.ui_frame.progressbar.ui_frame.texture:SetWidth(pb_width - 6)
    self.ui_frame.progressbar.ui_frame.counter:SetWidth(pb_width)
end
