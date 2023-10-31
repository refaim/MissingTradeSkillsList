---------------------------------------------------------------
-- Name: BaseFrame                                           --
-- Description: Abstract implementation of a base frame      --
--              Copy this frame in constructor of real frame --
---------------------------------------------------------------

---@class MTSLUI_BASE_FRAME
---@field ui_frame Frame|nil
---@field skill_list_filter_frame MTSLUI_FILTER_FRAME|nil
MTSLUI_BASE_FRAME = {
    ui_frame = nil,
}

function MTSLUI_BASE_FRAME:Hide()
    self.ui_frame:Hide()
    self:ResetFilters()
end

function MTSLUI_BASE_FRAME:Show()
    self.ui_frame:Show()
    self:RefreshUI()
end

function MTSLUI_BASE_FRAME:Toggle()
    if self:IsShown() then
        self:Hide()
    else
        self:Show()
    end
end

function MTSLUI_BASE_FRAME:ResetFilters()
    if self.skill_list_filter_frame then self.skill_list_filter_frame:ResetFilters() end
    if self.skill_list_frame and self.skill_list_frame.ResetFilters then self.skill_list_frame:ResetFilters() end
end

function MTSLUI_BASE_FRAME:RefreshUI(force) end

function MTSLUI_BASE_FRAME:IsShown()
    if self.ui_frame == nil then
        return false
    end
    return self.ui_frame:IsVisible()
end

----------------------------------------------------------------------------------------------------------
-- Set the scale of the UI frame
--
-- @scale       Number      The scale of the UI frame (>= MTSLUI_SAVED_VARIABLES.MIN_SCALE, <= MTSLUI_SAVED_VARIABLES.MAX_SCALE)
----------------------------------------------------------------------------------------------------------
function MTSLUI_BASE_FRAME:SetUIScale(scale)
    self.ui_frame:SetScale(scale)
end

function MTSLUI_BASE_FRAME:SetSplitOrientation(split_orientation)
    if split_orientation == "Horizontal" then
        self:SwapToHorizontalMode()
    else
        self:SwapToVerticalMode()
    end
end

function MTSLUI_BASE_FRAME:SwapToVerticalMode() end

function MTSLUI_BASE_FRAME:SwapToHorizontalMode() end
