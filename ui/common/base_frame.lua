---------------------------------------------------------------
-- Name: BaseFrame                                           --
-- Description: Abstract implementation of a base frame      --
--              Copy this frame in constructor of real frame --
---------------------------------------------------------------

---@class MTSLUI_BASE_FRAME
MTSLUI_BASE_FRAME = {
    ui_frame = nil,

    ----------------------------------------------------------------------------------------------------------
    -- Hides the frame
    ----------------------------------------------------------------------------------------------------------
    Hide = function(self)
        self.ui_frame:Hide()
        self:ResetFilters()
    end,

    ----------------------------------------------------------------------------------------------------------
    -- Shows the frame
    ----------------------------------------------------------------------------------------------------------
    Show = function(self)
        self.ui_frame:Show()
        -- update the UI of the screen
        self:RefreshUI()
    end,

    ----------------------------------------------------------------------------------------------------------
    -- Toggle the frame
    ----------------------------------------------------------------------------------------------------------
    Toggle = function(self)
        if self:IsShown() then
            self:Hide()
        else
            self:Show()
        end
    end,

    ----------------------------------------------------------------------------------------------------------
    -- Reset the filters in the filter frame if the baseframe has one
    ----------------------------------------------------------------------------------------------------------
    ResetFilters = function(self)
        if self.skill_list_filter_frame then self.skill_list_filter_frame:ResetFilters() end
        if self.skill_list_frame and self.skill_list_frame.ResetFilters then self.skill_list_frame:ResetFilters() end
    end,

    ----------------------------------------------------------------------------------------------------------
    -- Refresh the UI of the addon (to be overwritten in the real frame)
    ----------------------------------------------------------------------------------------------------------
    RefreshUI = function(self)
    end,

    ----------------------------------------------------------------------------------------------------------
    -- Check if frame is shown/visible
    --
    -- returns      boolean      Visibility of the frame
    ----------------------------------------------------------------------------------------------------------
    IsShown = function(self)
        if self.ui_frame == nil then
            return false
        end
        return self.ui_frame:IsVisible()
    end,

    ----------------------------------------------------------------------------------------------------------
    -- Set the scale of the UI frame
    --
    -- @scale       Number      The scale of the UI frame (>= MTSLUI_SAVED_VARIABLES.MIN_SCALE, <= MTSLUI_SAVED_VARIABLES.MAX_SCALE)
    ----------------------------------------------------------------------------------------------------------
    SetUIScale = function(self, scale)
        self.ui_frame:SetScale(scale)
    end,

    ----------------------------------------------------------------------------------------------------------
    -- Set the Split orientation Mode (Horizontal or Vertical) and swap to the mode
    --
    -- @split_orientation       String          The orientation of the splitter (Horizontal or Vertical
    ----------------------------------------------------------------------------------------------------------
    SetSplitOrientation = function(self, split_orientation)
        if split_orientation == "Horizontal" then
            self:SwapToHorizontalMode()
        else
            self:SwapToVerticalMode()
        end
    end,

    ----------------------------------------------------------------------------------------------------------
    -- Swap to Vertical Mode (Default mode, means list left & details right)
    -- (to be overwritten in the real frame)
    ----------------------------------------------------------------------------------------------------------
    SwapToVerticalMode = function(self)
    end,

    ----------------------------------------------------------------------------------------------------------
    -- Swap to Horizontal Mode (means list on top & details below)
    -- (to be overwritten in the real frame)
    ----------------------------------------------------------------------------------------------------------
    SwapToHorizontalMode = function(self)
    end,
}
