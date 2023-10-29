------------------------------------------------------------------
-- Name: TitleFrame                                             --
-- Description: The tile frame of the databasefame              --
-- Parent Frame: DatabaseFrame                                  --
------------------------------------------------------------------

---@class MTSLUI_TITLE_FRAME
MTSLUI_TITLE_FRAME = {
    FRAME_WIDTH_VERTICAL = 1165,
    FRAME_WIDTH_HORIZONTAL = 810,
    FRAME_HEIGHT = 30,
}

function MTSLUI_TITLE_FRAME:Initialise(parent_frame, type_frame, frame_width_vertical, frame_width_horizontal)
    self.FRAME_WIDTH_VERTICAL = frame_width_vertical
    self.FRAME_WIDTH_HORIZONTAL = frame_width_horizontal
    self.ui_frame = MTSLUI_TOOLS:CreateBaseFrame("Frame", "", parent_frame, nil, self.FRAME_WIDTH_VERTICAL, self.FRAME_HEIGHT, false)
    self.ui_frame:SetPoint("TOPLEFT", parent_frame, "TOPLEFT", 0, 0)
    -- Title text
    local title_text = MTSLUI_FONTS.COLORS.TEXT.TITLE ..MTSLUI_ADDON.NAME .. MTSLUI_FONTS.COLORS.TEXT.NORMAL .. " (by " .. MTSLUI_ADDON.AUTHOR .. ") " .. MTSLUI_FONTS.COLORS.TEXT.TITLE  .. "v" .. MTSLUI_ADDON.VERSION .. MTSLUI_FONTS.COLORS.TEXT.NORMAL
    if type_frame ~= nil and type_frame ~= "" then
        title_text = title_text .. " - " .. type_frame
    end
    self.ui_frame.text = MTSLUI_TOOLS:CreateLabel(self.ui_frame, title_text, 0, 0, "TITLE", "CENTER")
    -- Make the screen dragable/movable by clicking through to main frame
    self.ui_frame:EnableMouse(false)
end

function MTSLUI_TITLE_FRAME:ResizeToVerticalMode()
    -- no need for height cause its same in both modes
    self.ui_frame:SetWidth(self.FRAME_WIDTH_VERTICAL)
end

function MTSLUI_TITLE_FRAME:ResizeToHorizontalMode()
    -- no need for height cause its same in both modes
    self.ui_frame:SetWidth(self.FRAME_WIDTH_HORIZONTAL)
end
