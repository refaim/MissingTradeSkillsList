----------------------------------------------------------------------
-- Name: VerticalSlider                                             --
-- Description: Contains all functionality for the vertical slider  --
-- Parent Frame: -                                                  --
----------------------------------------------------------------------

MTSLUI_VERTICAL_SLIDER = {
    ui_frame = nil,
    -- Scroll 5 items at a time
    SLIDER_STEP = 5,
    -- width of the slider
    FRAME_WIDTH = 25,
    STEP_HEIGHT = 20,

    ----------------------------------------------------------------------------------------------------------
    -- Intialises the VerticalSlider
    --
    -- @parent_class        Class       The lua class that owns the slider_frame
    -- @parent_frame        frame       The parent frame
    -- @slider_steps        Number      The mount of steps the vertical slider has
    -- @height_step         Number      The height of 1 step in the slider
    ----------------------------------------------------------------------------------------------------------
    Initialise = function(self, parent_class, parent_frame, height, height_step)
        self.STEP_HEIGHT = height_step
        -- create a container frame for the border
        self.ui_frame = MTSLUI_TOOLS:CreateBaseFrame("Frame", "", parent_frame, nil, self.FRAME_WIDTH, height, false)
        self.ui_frame:SetPoint("TOPRIGHT", parent_frame, "TOPRIGHT", 0, 0)
        -- place the slider inside the container frame
        self.ui_frame.slider = MTSLUI_TOOLS:CreateBaseFrame("Slider", "", self.ui_frame, "UIPanelScrollBarTemplate", self.FRAME_WIDTH, height - 40, false)
        self.ui_frame.slider:SetPoint("TOPLEFT", self.ui_frame, "TOPLEFT", 0, -20)
        -- parent ui_frame handles the scrolling event
        self.ui_frame.slider:SetScript("OnValueChanged", function()
            local value = arg1
            if value ~= nil then
                -- round the value to an integer
                value = math.ceil(value-0.5)
                parent_class:HandleScrollEvent(value)
            end
        end)
        -- Enable scrolling with mousewheel
        self.ui_frame.slider:EnableMouseWheel(true)
        self.ui_frame.slider:SetScript("OnMouseWheel", function()
            if arg1 > 0 then
                self:ScrollUp()
            elseif arg1 < 0 then
                self:ScrollDown()
            end
        end)
    end,

    ---------------------------------------------------------------------------------------
    -- Returns the slider
    --
    -- returns      Slider      The cslider
    ----------------------------------------------------------------------------------------
    GetSlider = function(self)
        return self.ui_frame.slider
    end,

    ---------------------------------------------------------------------------------------
    -- Returns the value of the current slider
    --
    -- returns      Number      The current value of the slider
    ----------------------------------------------------------------------------------------
    GetSliderValue = function(self)
        return self.ui_frame.slider:GetValue()
    end,

    ---------------------------------------------------------------------------------------
    -- Sets the value of the current slider
    --
    -- @value      Number      The new value of the slider
    ----------------------------------------------------------------------------------------
    SetSliderValue = function(self, value)
        self.ui_frame.slider:SetValue(value)
    end,

    ---------------------------------------------------------------------------------------
    -- Scrolls the slider up by SLIDER_STEP
    ----------------------------------------------------------------------------------------
    ScrollUp = function(self)
        local new_value = self:GetSliderValue() - self.SLIDER_STEP
        -- Set the new value of the slider, this executes "OnValueChanged"
        -- Does not set new value if not in MinMaxValues range
        self:SetSliderValue(new_value)
    end,

    ---------------------------------------------------------------------------------------
    -- Scrolls the slider down by SLIDER_STEP
    ----------------------------------------------------------------------------------------
    ScrollDown = function(self)
        local new_value = self:GetSliderValue() + self.SLIDER_STEP
        -- Set the new value of the slider, this executes "OnValueChanged"
        -- Does not set new value if not in MinMaxValues range
        self:SetSliderValue(new_value)
    end,

    ---------------------------------------------------------------------------------------
    -- Refresh the slider
    -- When opening other tradeskill ui_frame, amount of staps might have to be altered
    --
    -- @max_steps               number      Total amount of steps the slider has
    -- @amount_visibile_steps   number      The amount of visible steps/items in the slider
    ----------------------------------------------------------------------------------------
    Refresh = function(self, max_steps, amount_visibile_steps)
        -- Calculate the height (-4 for borders)
        local height = amount_visibile_steps * self.STEP_HEIGHT + self.STEP_HEIGHT/2 + 2
        self:SetHeight(height)
        self.ui_frame.slider:SetMinMaxValues(1, max_steps)
        -- Select top step
        self:SetSliderValue(1)
    end,

    ---------------------------------------------------------------------------------------
    -- Hides the slider
    ----------------------------------------------------------------------------------------
    Hide = function(self)
        self.ui_frame:Hide()
    end,

    ---------------------------------------------------------------------------------------
    -- Shows the slider
    ----------------------------------------------------------------------------------------
    Show = function(self)
        self.ui_frame:Show()
    end,

    ---------------------------------------------------------------------------------------
    -- Sets the height of  the slider
    ----------------------------------------------------------------------------------------
    SetHeight = function(self, height)
        self.ui_frame:SetHeight(height)
        self.ui_frame.slider:SetHeight(height - 40)
    end,
}
