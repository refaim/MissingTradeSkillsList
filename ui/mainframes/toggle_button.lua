------------------------------------------------------------------
-- Name: ToggleButton                                           --
-- Description: Contains all functionality for the togglebutton --
------------------------------------------------------------------

---@class MTSLUI_TOGGLE_BUTTON: MTSLUI_BASE_FRAME
MTSLUI_TOGGLE_BUTTON = MTSL_TOOLS:CopyObject(MTSLUI_BASE_FRAME)

MTSLUI_TOGGLE_BUTTON.FRAME_WITDH = 60
MTSLUI_TOGGLE_BUTTON.FRAME_HEIGHT = 20

function MTSLUI_TOGGLE_BUTTON:Initialise()
    self.ui_frame = MTSLUI_TOOLS:CreateBaseFrame("Button", "MTSLUI_ToggleButton", nil, "UIPanelButtonTemplate", self.FRAME_WITDH, self.FRAME_HEIGHT)
    self.ui_frame:SetText("MTSL")
    self.ui_frame:SetScript("OnClick", function()
        MTSLUI_MISSING_TRADESKILLS_FRAME:Toggle()
    end)
    -- Hide by default after creating
    self:Hide()
end

function MTSLUI_TOGGLE_BUTTON:SwapToCraftMode()
    if CraftFrame then
        self:ReanchorToNewParent(CraftFrame)
    end
end

function MTSLUI_TOGGLE_BUTTON:SwapToTradeSkillMode()
    if TradeSkillFrame then
        self:ReanchorToNewParent(TradeSkillFrame)
    end
end

function MTSLUI_TOGGLE_BUTTON:ReanchorButton()
    self:ReanchorToNewParent(self.ui_frame:GetParent())
end

function MTSLUI_TOGGLE_BUTTON:Show()
    self:ReanchorToNewParent(self.ui_frame:GetParent())
    self.ui_frame:Show()
end

function MTSLUI_TOGGLE_BUTTON:ReanchorToNewParent(parent_frame)
    -- gaps to default BLizzard UI (default right hook)
    local gap_left = -33
    local gap_top = -13
    if MTSLUI_SAVED_VARIABLES:GetMTSLLocationButton() == "left" then
        gap_left = 0
        gap_top = 0
    end

    if SkilletFrame ~= nil then
        -- Overwrite parent frame of Blizzard UI to Skillet-Classic addon
        parent_frame = SkilletFrame
        gap_left = 0
        gap_top = 0
    elseif ATSWFrame ~= nil then
        -- Overwrite parent frame of Blizzard UI to AdvancedTradeSkillWindow addon
        parent_frame = ATSWFrame
    end

    if parent_frame ~= nil then
        self.ui_frame:SetParent(parent_frame)
        self.ui_frame:ClearAllPoints()
        if MTSLUI_SAVED_VARIABLES:GetMTSLLocationButton() == "right" then
            self.ui_frame:SetPoint("BOTTOMRIGHT", parent_frame, "TOPRIGHT", gap_left, gap_top)
        else
            self.ui_frame:SetPoint("BOTTOMLEFT", parent_frame, "TOPLEFT", gap_left, gap_top)
        end
        MTSLUI_MISSING_TRADESKILLS_FRAME.ui_frame:ClearAllPoints()
        -- Adjust position of the frame relative to button
        if MTSLUI_SAVED_VARIABLES:GetMTSLLocationFrame() == "right" then
            MTSLUI_MISSING_TRADESKILLS_FRAME.ui_frame:SetPoint("TOPLEFT", self.ui_frame, "TOPRIGHT", 0, 0)
        else
            MTSLUI_MISSING_TRADESKILLS_FRAME.ui_frame:SetPoint("TOPRIGHT", self.ui_frame, "TOPLEFT", 0, 0)
        end

        -- clear any current selection of the craftskill window
        MTSLUI_MISSING_TRADESKILLS_FRAME:NoSkillSelected()
    end
end
