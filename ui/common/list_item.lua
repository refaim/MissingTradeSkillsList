----------------------------------------------------------------------
-- Name: ListItem                                                   --
-- Description: List item for scroll frame that is actually a button --
----------------------------------------------------------------------

MTSLUI_LIST_ITEM = {
    -- The "slider"
    ui_frame,
    -- Keep if it is selected or not
    is_selected = 0,
    FRAME_WIDTH_SLIDER,
    FRAME_WIDTH_NO_SLIDER,
    FRAME_HEIGHT,
    -- Different textures to use for the button
    TEXTURES = {
        SELECTED = "Interface/Buttons/UI-Listbox-Highlight",
        HIGHLIGHTED = "Interface/Tooltips/UI-Tooltip-Background",
        NOT_SELECTED = ""
    },

    ----------------------------------------------------------------------------------------------------------
    -- Intialises the SkillButton
    ----------------------------------------------------------------------------------------------------------
    Initialise = function (self, id, parent_frame, width, height, position_left, position_top)
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
    end,

    ---------------------------------------------------------------------------------------
    -- Refresh the list item
    --
    -- @text                String      Text to show on the list item
    -- @with_slider         Boolean     Flag indicating if parent list has slider active or not
    ----------------------------------------------------------------------------------------
    Refresh = function(self, text, with_slider)
        self.ui_frame.text:SetText(text)
        -- Make button smaller if slider is visible so they dont overlap
        if with_slider == 1 then
            self.ui_frame:SetWidth(self.FRAME_WIDTH_SLIDER)
        else
            self.ui_frame:SetWidth(self.FRAME_WIDTH_NO_SLIDER)
        end
    end,

    -- Resize the list item
    UpdateWidth = function(self, width)
        self.FRAME_WIDTH_NO_SLIDER = width
        self.FRAME_WIDTH_SLIDER = width - MTSLUI_VERTICAL_SLIDER.FRAME_WIDTH + 8
    end,

    ---------------------------------------------------------------------------------------
    -- Hides the button
    ----------------------------------------------------------------------------------------
    Hide = function (self)
        self.ui_frame:Hide()
    end,

    ---------------------------------------------------------------------------------------
    -- Shows the button
    ----------------------------------------------------------------------------------------
    Show = function (self)
        self.ui_frame:Show()
    end,

    ---------------------------------------------------------------------------------------
    -- Checks if button is selected
    --
    -- returns      Number      Flag that indicates if button is selected (1 = selected)
    ----------------------------------------------------------------------------------------
    IsSelected = function (self)
        return self.is_selected
    end,

    ---------------------------------------------------------------------------------------
    -- Deselects the button
    ----------------------------------------------------------------------------------------
    Deselect = function (self)
        self.is_selected = 0
        self.ui_frame:SetNormalTexture(self.TEXTURES.NOT_SELECTED)
    end,

    ---------------------------------------------------------------------------------------
    -- Selects the button
    ----------------------------------------------------------------------------------------
    Select = function (self)
        self.is_selected = 1
        self.ui_frame:SetNormalTexture(self.TEXTURES.SELECTED)
    end,
}
