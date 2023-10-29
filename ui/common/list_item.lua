----------------------------------------------------------------------
-- Name: ListItem                                                   --
-- Description: List item for scroll frame that is actually a button --
----------------------------------------------------------------------

---@class MTSLUI_LIST_ITEM
MTSLUI_LIST_ITEM = {
    -- The "slider"
    ui_frame = nil,
    -- Keep if it is selected or not
    is_selected = 0,
    FRAME_WIDTH_SLIDER = nil,
    FRAME_WIDTH_NO_SLIDER = nil,
    FRAME_HEIGHT = nil,
    -- Different textures to use for the button
    TEXTURES = {
        SELECTED = "Interface/Buttons/UI-Listbox-Highlight",
        HIGHLIGHTED = "Interface/Tooltips/UI-Tooltip-Background",
        NOT_SELECTED = ""
    },
}

function MTSLUI_LIST_ITEM:Initialise(id, parent_frame, width, height, position_left, position_top)
    self.FRAME_WIDTH_NO_SLIDER = width
    self.FRAME_WIDTH_SLIDER = width - MTSLUI_VERTICAL_SLIDER.FRAME_WIDTH + 8
    self.FRAME_HEIGHT = height
    self.ui_frame = MTSLUI_TOOLS:CreateBaseFrame("Button", "", parent_frame.ui_frame, nil, self.FRAME_WIDTH_NO_SLIDER, self.FRAME_HEIGHT)
    self.ui_frame:SetPoint("TOPLEFT", parent_frame.ui_frame, "TOPLEFT", position_left, position_top)

    -- set the id (= index) of the button so we later know which one is pushed
    self.ui_frame:SetID(id)
    -- strip textures
    self.ui_frame:SetNormalTexture(self.TEXTURES.NOT_SELECTED)
    self.ui_frame:SetPushedTexture(self.TEXTURES.NOT_SELECTED)
    self.ui_frame:SetDisabledTexture(self.TEXTURES.NOT_SELECTED)
    -- set own textures
    self.ui_frame:SetHighlightTexture(self.TEXTURES.HIGHLIGHTED)

    self.ui_frame.text = self.ui_frame:CreateFontString()
    self.ui_frame.text:SetFont(MTSLUI_FONTS.FONTS.LABEL:GetFont())
    self.ui_frame.text:SetPoint("LEFT",5,0)

    self.is_selected = 0

    self.ui_frame:SetScript("OnClick", function()
        parent_frame:HandleSelectedListItem(id)
    end)
end

function MTSLUI_LIST_ITEM:Refresh(text, with_slider)
    self.ui_frame.text:SetText(text)
    -- Make button smaller if slider is visible so they dont overlap
    if with_slider == 1 then
        self.ui_frame:SetWidth(self.FRAME_WIDTH_SLIDER)
    else
        self.ui_frame:SetWidth(self.FRAME_WIDTH_NO_SLIDER)
    end
end

function MTSLUI_LIST_ITEM:UpdateWidth(width)
    self.FRAME_WIDTH_NO_SLIDER = width
    self.FRAME_WIDTH_SLIDER = width - MTSLUI_VERTICAL_SLIDER.FRAME_WIDTH + 8
end

function MTSLUI_LIST_ITEM:Hide()
    self.ui_frame:Hide()
end

function MTSLUI_LIST_ITEM:Show()
    self.ui_frame:Show()
end

function MTSLUI_LIST_ITEM:IsSelected()
    return self.is_selected
end

function MTSLUI_LIST_ITEM:Deselect()
    self.is_selected = 0
    self.ui_frame:SetNormalTexture(self.TEXTURES.NOT_SELECTED)
end

function MTSLUI_LIST_ITEM:Select()
    self.is_selected = 1
    self.ui_frame:SetNormalTexture(self.TEXTURES.SELECTED)
end
