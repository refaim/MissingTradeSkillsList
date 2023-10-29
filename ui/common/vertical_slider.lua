----------------------------------------------------------------------
-- Name: VerticalSlider                                             --
-- Description: Contains all functionality for the vertical slider  --
-- Parent Frame: -                                                  --
----------------------------------------------------------------------

---@class MTSLUI_VERTICAL_SLIDER
MTSLUI_VERTICAL_SLIDER = {
    ui_frame = nil,
    -- Scroll 5 items at a time
    SLIDER_STEP = 5,
    -- width of the slider
    FRAME_WIDTH = 25,
    STEP_HEIGHT = 20,
}

----------------------------------------------------------------------------------------------------------
-- Intialises the VerticalSlider
--
-- @parent_class        Class       The lua class that owns the slider_frame
-- @parent_frame        frame       The parent frame
-- @slider_steps        Number      The mount of steps the vertical slider has
-- @height_step         Number      The height of 1 step in the slider
----------------------------------------------------------------------------------------------------------
function MTSLUI_VERTICAL_SLIDER:Initialise(parent_class, parent_frame, height, height_step)
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
end

function MTSLUI_VERTICAL_SLIDER:GetSlider()
    return self.ui_frame.slider
end

function MTSLUI_VERTICAL_SLIDER:GetSliderValue()
    return self.ui_frame.slider:GetValue()
end

function MTSLUI_VERTICAL_SLIDER:SetSliderValue(value)
    self.ui_frame.slider:SetValue(value)
end

function MTSLUI_VERTICAL_SLIDER:ScrollUp()
    local new_value = self:GetSliderValue() - self.SLIDER_STEP
    -- Set the new value of the slider, this executes "OnValueChanged"
    -- Does not set new value if not in MinMaxValues range
    self:SetSliderValue(new_value)
end

function MTSLUI_VERTICAL_SLIDER:ScrollDown()
    local new_value = self:GetSliderValue() + self.SLIDER_STEP
    -- Set the new value of the slider, this executes "OnValueChanged"
    -- Does not set new value if not in MinMaxValues range
    self:SetSliderValue(new_value)
end

---------------------------------------------------------------------------------------
-- Refresh the slider
-- When opening other tradeskill ui_frame, amount of staps might have to be altered
--
-- @max_steps               number      Total amount of steps the slider has
-- @amount_visibile_steps   number      The amount of visible steps/items in the slider
----------------------------------------------------------------------------------------
function MTSLUI_VERTICAL_SLIDER:Refresh(max_steps, amount_visibile_steps)
    -- Calculate the height (-4 for borders)
    local height = amount_visibile_steps * self.STEP_HEIGHT + self.STEP_HEIGHT/2 + 2
    self:SetHeight(height)
    self.ui_frame.slider:SetMinMaxValues(1, max_steps)
    -- Select top step
    self:SetSliderValue(1)
end

function MTSLUI_VERTICAL_SLIDER:Hide()
    self.ui_frame:Hide()
end

function MTSLUI_VERTICAL_SLIDER:Show()
    self.ui_frame:Show()
end

function MTSLUI_VERTICAL_SLIDER:SetHeight(height)
    self.ui_frame:SetHeight(height)
    self.ui_frame.slider:SetHeight(height - 40)
end
