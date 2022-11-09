------------------------------------------------------------------
-- Name: SaveFrame                                              --
-- Description: Save/Cancel user settings                       --
-- Parent Frame: OptionsMenuFrame                               --
------------------------------------------------------------------

MTSLOPTUI_SAVE_FRAME = {
    FRAME_HEIGHT = 30,
    BUTTON_WIDTH = 125,
    BUTTON_HEIGHT = 30,

    ---------------------------------------------------------------------------------------
    -- Initialises the titleframe
    ----------------------------------------------------------------------------------------
    Initialise = function (self, parent_frame)
        self.FRAME_WIDTH = MTSLUI_OPTIONS_MENU_FRAME.FRAME_WIDTH
        self.ui_frame = MTSLUI_TOOLS:CreateBaseFrame("Frame", "MTSLOPTUI_SaveFrame", parent_frame, nil, self.FRAME_WIDTH, self.FRAME_HEIGHT, false)
        -- below config frame
        self.ui_frame:SetPoint("TOPLEFT", parent_frame, "BOTTOMLEFT", 0, 0)
        -- calculate position
        local left = tonumber((self.FRAME_WIDTH - 4 * self.BUTTON_WIDTH)/3)
        -- Save button
        self.save_btn = MTSLUI_TOOLS:CreateBaseFrame("Button", "MTSLOPTUI_Cancel_Button", self.ui_frame, "UIPanelButtonTemplate", 2 * self.BUTTON_WIDTH, self.BUTTON_HEIGHT)
        self.save_btn:SetPoint("TOPLEFT", self.ui_frame, "TOPLEFT", left, 0)
        self.save_btn:SetText(MTSLUI_TOOLS:GetLocalisedLabel("save"))
        self.save_btn:SetScript("OnClick", function ()
            MTSLOPTUI_CONFIG_FRAME:Save()
            MTSLUI_OPTIONS_MENU_FRAME:Hide()
        end)
        -- Resetbutton
        left = left + left + 2 * self.BUTTON_WIDTH
        self.reset_btn = MTSLUI_TOOLS:CreateBaseFrame("Button", "MTSLOPTUI_Save_Button", self.ui_frame, "UIPanelButtonTemplate", self.BUTTON_WIDTH, self.BUTTON_HEIGHT)
        self.reset_btn:SetPoint("TOPLEFT", self.ui_frame, "TOPLEFT", left, 0)
        self.reset_btn:SetText(MTSLUI_TOOLS:GetLocalisedLabel("default"))
        self.reset_btn:SetScript("OnClick", function ()
            MTSLOPTUI_CONFIG_FRAME:Reset()
            MTSLUI_FONTS:Initialise()
            ReloadUI()
            MTSLUI_OPTIONS_MENU_FRAME:Show()
        end)
        -- Cancel button
        left = left + self.BUTTON_WIDTH
        self.cancel_btn = MTSLUI_TOOLS:CreateBaseFrame("Button", "MTSLOPTUI_Save_Button", self.ui_frame, "UIPanelButtonTemplate", self.BUTTON_WIDTH, self.BUTTON_HEIGHT)
        self.cancel_btn:SetPoint("TOPLEFT", self.ui_frame, "TOPLEFT", left, 0)
        self.cancel_btn:SetText(MTSLUI_TOOLS:GetLocalisedLabel("cancel"))
        self.cancel_btn:SetScript("OnClick", function ()
            MTSLUI_OPTIONS_MENU_FRAME:Hide()
        end)
    end,
}
