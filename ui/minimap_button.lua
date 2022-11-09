----------------------------------------------------------
-- Name: MinimapButton                                  --
-- Description: Controls a button around the minimap    --
-- Parent Frame: -                                      --
----------------------------------------------------------

MTSLUI_MINIMAP = {
    ui_frame,
    button_angle,
    button_radius,
    shape,
    BUTTON_DIAMETER = 24,
    HALF_BUTTON_DIAMETER = 12,

    Initialise = function(self)
        self.ui_frame = CreateFrame("Button", nil, Minimap)
        self.ui_frame:SetFrameLevel(10)
        self.ui_frame:SetToplevel(true)
        self.ui_frame:SetWidth(self.BUTTON_DIAMETER)
        self.ui_frame:SetHeight(self.BUTTON_DIAMETER)
        self.ui_frame:SetNormalTexture(MTSLUI_ADDON_PATH .. "\\Images\\minimap.blp")
        self.ui_frame:SetPushedTexture(MTSLUI_ADDON_PATH .. "\\Images\\minimap.blp")
        self.ui_frame:SetHighlightTexture(MTSLUI_ADDON_PATH .. "\\Images\\minimap.blp")

        self.mouse_down = false
        self:HookEvents()
        self:Hide()
    end,

    OnMouseDown = function (self, button)
        -- Only allow dragging with RMB
        if button == "RightButton" then
            MTSLUI_MINIMAP.mouse_down = true
        end
    end,

    OnUpdate = function(self)
        if MTSLUI_MINIMAP:IsMouseDown() == true then
            MTSLUI_MINIMAP:DragButton()
        end
    end,

    IsMouseDown = function(self)
        return self.mouse_down == true
    end,

    OnMouseUp = function (self, button)
        -- Only allow dragging with RMB
        if button == "RightButton" or MTSLUI_MINIMAP:IsMouseDown() == true then
            MTSLUI_MINIMAP.mouse_down = false
            MTSLUI_MINIMAP:DragButton()
        end
    end,

    HookEvents = function(self)
        -- Right mouse button to drag/move
        self.ui_frame:SetMovable(true)
        self.ui_frame:RegisterForDrag("RightButton")
        -- Overwrite/add extra function/events
        self.ui_frame:SetScript("OnDragStart", MTSLUI_MINIMAP.OnMouseDown)
        self.ui_frame:SetScript("OnDragStop", MTSLUI_MINIMAP.OnMouseUp)
        self.ui_frame:SetScript("OnMouseDown", MTSLUI_MINIMAP.OnMouseDown)
        self.ui_frame:SetScript("OnMouseUp", MTSLUI_MINIMAP.OnMouseUp)
        self.ui_frame:SetScript("OnUpdate",  MTSLUI_MINIMAP.OnUpdate)

        -- Show the tooltip when mouse over
        self.ui_frame:SetScript("OnEnter", function(frame)
            GameTooltip:SetOwner(frame, "ANCHOR_BOTTOMRIGHT")
            GameTooltip:SetText(MTSLUI_FONTS.COLORS.TEXT.TITLE .. MTSLUI_ADDON.NAME .. " (v" .. MTSLUI_ADDON.VERSION .. ")")
            GameTooltip:AddLine(" ", 1, 1, 1)
            GameTooltip:AddLine(MTSLUI_FONTS.COLORS.TEXT.NORMAL .. "Left Click: Open MTSL options menu", 1, 1, 1)
            GameTooltip:AddLine(" ", 1, 1, 1)
            GameTooltip:AddLine(MTSLUI_FONTS.COLORS.TEXT.NORMAL .. "Alt + Left Click: Open NPC explorer", 1, 1, 1)
            GameTooltip:AddLine(MTSLUI_FONTS.COLORS.TEXT.NORMAL .. "Ctrl + Left Click: Open Character explorer", 1, 1, 1)
            GameTooltip:AddLine(MTSLUI_FONTS.COLORS.TEXT.NORMAL .. "Shift + Left Click: Open Database explorer", 1, 1, 1)
            GameTooltip:AddLine(MTSLUI_FONTS.COLORS.TEXT.NORMAL .. "Alt + Ctrl + Left Click: Open Account explorer", 1, 1, 1)
            GameTooltip:AddLine(" ", 1, 1, 1)
            GameTooltip:AddLine(MTSLUI_FONTS.COLORS.TEXT.NORMAL .. "Right Drag: Move the minimap button", 1, 1, 1)
            GameTooltip:Show()
        end)

        -- Hide the tooltip if no longer mouse over
        self.ui_frame:SetScript("OnLeave", function(frame)
            GameTooltip:Hide()
        end)

        -- Control clicks
        self.ui_frame:SetScript("OnClick", function(self, button)
            -- only allow if leftbutton used
            if button == "LeftButton" then
                if IsControlKeyDown() and IsAltKeyDown() and not IsShiftKeyDown() then
                    MTSLUI_ACCOUNT_EXPLORER_FRAME:Toggle()
                elseif IsControlKeyDown() and not (IsAltKeyDown() or IsShiftKeyDown()) then
                    MTSLUI_CHARACTER_EXPLORER_FRAME:Toggle()
                elseif IsShiftKeyDown() and not (IsControlKeyDown() or IsAltKeyDown()) then
                    MTSLUI_DATABASE_EXPLORER_FRAME:Toggle()
                elseif IsAltKeyDown() and not (IsControlKeyDown() or IsShiftKeyDown()) then
                    MTSLUI_NPC_EXPLORER_FRAME:Toggle()
                else
                    MTSLUI_OPTIONS_MENU_FRAME:Toggle()
                end
            end
        end)
    end,

    DragButton = function(self)
        MTSLUI_MINIMAP:CalculateAngleButton()
        MTSLUI_MINIMAP:DrawButton()
    end,

    CalculateAngleButton = function(self)
        local mouse_x, mouse_y = GetCursorPosition()
        -- calculate the delta according to center of the minimap
        local scale = UIParent:GetScale()
        local left_x = Minimap:GetLeft() * scale
        local top_y = Minimap:GetTop() * scale
        local middle_x = left_x + (Minimap:GetWidth() * scale / 2)
        local middle_y = top_y - (Minimap:GetHeight() * scale / 2)

        local delta_x = mouse_x - middle_x
        local delta_y = mouse_y - middle_y

        -- Calculate the angle between center of minimap and current mousepointer
        self.button_angle = atan2(delta_y, delta_x)
        if self.button_angle < 0 then
            self.button_angle = self.button_angle + 360
        end
        -- update savedvariable
        MTSLUI_SAVED_VARIABLES:SetMinimapButtonAngle(self.button_angle)
    end,

    -- Draw the button based on current angle of the button
    DrawButton = function(self)
        local button_pos_x, button_pos_y

        -- Calculate the position of the mini map button based on minimap shape and the angle
        if self.shape == "circle" then
            button_pos_x = cos(self.button_angle) * ((Minimap:GetWidth() + self.button_radius) / 2)
            button_pos_y = sin(self.button_angle) * ((Minimap:GetHeight() + self.button_radius)/ 2)
        -- rectangular shape
        else
            local half_minimap = Minimap:GetWidth() / 2
            if self.button_angle <= 45 then
                button_pos_x = half_minimap + self.button_radius
                button_pos_y = tan(self.button_angle) * half_minimap
            elseif self.button_angle <= 90 then
                button_pos_x = tan(90 - self.button_angle) * half_minimap
                button_pos_y = half_minimap + self.button_radius
            elseif self.button_angle <= 135 then
                button_pos_x = tan(self.button_angle - 90) * half_minimap * -1
                button_pos_y = half_minimap + self.button_radius
            elseif self.button_angle <= 180 then
                button_pos_x = half_minimap * -1 - self.button_radius
                button_pos_y = tan(180 - self.button_angle) * half_minimap
            elseif self.button_angle <= 225 then
                button_pos_x = half_minimap * -1 - self.button_radius
                button_pos_y = tan(self.button_angle - 180) * half_minimap * -1
            elseif self.button_angle <= 270 then
                button_pos_x = tan(270 - self.button_angle) * half_minimap * -1
                button_pos_y = half_minimap * -1 - self.button_radius
            elseif self.button_angle <= 315 then
                button_pos_x = tan(self.button_angle - 270) * half_minimap
                button_pos_y = half_minimap * -1 - self.button_radius
            else
                button_pos_x = half_minimap
                button_pos_y = tan(360 - self.button_angle) * half_minimap * - 1
            end
        end

        self.ui_frame:ClearAllPoints()
        self.ui_frame:SetPoint("CENTER", "Minimap", "CENTER", button_pos_x, button_pos_y)
    end,

    Hide = function(self)
        self.ui_frame:Hide()
    end,

    Show = function(self)
        self.button_angle = MTSLUI_SAVED_VARIABLES:GetMinimapButtonAngle()
        self.button_radius = MTSLUI_SAVED_VARIABLES:GetMinimapButtonRadius()
        self.shape = MTSLUI_SAVED_VARIABLES:GetMinimapShape()

        self:DrawButton()

        self.ui_frame:Show()
    end,

    ResetButton = function(self)
        self.button_angle = MTSLUI_SAVED_VARIABLES.DEFAULT_MINIMAP_ANGLE
        MTSLUI_SAVED_VARIABLES:SetMinimapButtonAngle(self.button_angle)
        self:DrawButton()
    end,
}
