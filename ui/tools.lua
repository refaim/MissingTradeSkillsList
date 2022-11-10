-------------------------------------------------------------
-- Name: MTSLUI_Tools                                      --
-- Description: contains all shared functions regarding UI --
-------------------------------------------------------------
local _G = _G or getfenv(0)

MTSLUI_TOOLS = {
    -- flag to warn ppl to install tomtom before it can add waypoints
    tomtom_warned = false,

    ---------------------------------------------------------------------------------------
    -- Create a generic MTSLUI_FRAME
    --
    -- @type            string      Type of the frame ("Frame", "Button", "Slider")
    -- @name            string      The name of the frame
    -- @parent          ojbect      The parentframe (can be nil)
    -- @template        string      The name of the template to follow (can be nil)
    -- @width           number      The width of the frame
    -- @height          number      The height of the frame
    -- @has_backdrop    boolean     Frame has backgroound or not (can be nil)
    --
    -- returns          Frame       Returns the created frame
    ----------------------------------------------------------------------------------------
    CreateBaseFrame = function(self, type, name, parent, template, width, height, has_backdrop)
        local generic_frame = CreateFrame(type, name, parent, template)
        generic_frame:SetWidth(width)
        generic_frame:SetHeight(height)
        generic_frame:SetParent(parent)
        -- Add a background to the frame if we want it
        if has_backdrop ~= nil and has_backdrop == true then
            generic_frame:SetBackdrop({
                bgFile = "Interface/Tooltips/UI-Tooltip-Background",
                edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
                tile = true,
                tileSize = 16,
                edgeSize = 16,
                insets = { left = 4, right = 4, top = 4, bottom = 4 }
            })
            --  Black background
            generic_frame:SetBackdropColor(0,0,0,1)
        end
        -- make sure mouse is captured on our window (NO clicking through)
        generic_frame:EnableMouse(1)
        -- Disable zooming in/out
        generic_frame:EnableMouseWheel(true)
        generic_frame:Show()
        -- return the frame
        return generic_frame
    end,

    ---------------------------------------------------------------------------------------
    -- Create a generic MainFrame
    --
    -- @name_parent_class   string      The name of the parent class which will use this mainframe
    -- @name                string      The name of the frame
    -- @width               number      The width of the frame
    -- @height              number      The height of the frame
    -- @swap_frames         Array       List of frames this mainframe can swap too
    --
    -- returns              Frame       Returns the created frame
    ----------------------------------------------------------------------------------------
    CreateMainFrame = function(self, name_parent_class, name, width, height, swap_frames)
        local main_frame = self:CreateBaseFrame("Frame", name, nil, nil, width, height, true)
        -- make sure it is shown above other frames
        main_frame:SetFrameLevel(10)
        main_frame:SetToplevel(true)
        -- Set Position to center of screen
        main_frame:SetPoint("CENTER", nil, "CENTER", 0, 0)
        -- hide on creation
        main_frame:Hide()
        -- Dummy operation to do nothing, discarding the zooming in/out
        main_frame:SetScript("OnMouseWheel", function() end)
        -- Make the screen dragable/movable
        self:AddDragToFrame(main_frame)
        -- close/hide window on esc
        tinsert(UISpecialFrames, name)

        -- add the close button
        main_frame.close_button = self:CreateBaseFrame("Button", "", main_frame, "UIPanelButtonTemplate", 24, 24)
        main_frame.close_button:SetText("X")
        -- Set Position to top right of databaseframe
        main_frame.close_button:SetPoint("TOPRIGHT", main_frame, "TOPRIGHT", -2, -2)
        main_frame.close_button:SetScript("OnClick", function()
            _G[name_parent_class]:Hide()
        end)

        if swap_frames ~= nil and swap_frames ~= {} then
            local last_swap_button = main_frame.close_button

            -- Sort the buttons by button_text reversed order
            MTSL_TOOLS:SortArrayByPropertyReversed(swap_frames, "button_text")

            -- Add buttons for each explorer frame taht is provided to be able to swap too
            for _, v in pairs(swap_frames) do
                -- add the swap button
                local swap_button = self:CreateBaseFrame("Button", "", main_frame, "UIPanelButtonTemplate", 60, 24)
                swap_button:SetText(v.button_text)
                -- Set Position to top right of last button
                swap_button:SetPoint("TOPRIGHT", last_swap_button, "TOPLEFT", 0, 0)
                swap_button:SetScript("OnClick", MTSL_TOOLS:BindArgument(function(frame_name)
                    _G[frame_name]:Show()
                end, v.frame_name))
                last_swap_button = swap_button
            end
        end

        return main_frame
    end,

    ----------------------------------------------------------------------------------------
    -- Creates a checkbox for the given frame
    --
    -- @owner           Frame       The frame for which to create the label
    -- @name            String      The name of the checkbox
    -- @margin_left     Number      The margin left position
    -- @margin_top      Number      The margin top position
    --
    -- returns      Object      The created label
    ----------------------------------------------------------------------------------------
    CreateCheckbox = function(self, owner, name, margin_left, margin_top)
        local checkbox = CreateFrame("CheckButton", name, owner, "UICheckButtonTemplate");
        checkbox:SetPoint("TOPLEFT", owner, "TOPLEFT", margin_left, margin_top)
        -- ignore the event for ticking checkbox
        checkbox:SetScript("OnClick", function() end)

        return checkbox
    end,

    ----------------------------------------------------------------------------------------
    -- Creates a label for the given frame
    --
    -- @owner       Frame       The frame for which to create the label
    -- @text        String      The text to show on the label
    -- @left        Number      The left position where the label starts
    -- @top         Number      The top position where the label starts
    --
    -- returns      Object      The created label
    ----------------------------------------------------------------------------------------
    CreateLabel = function(self, owner, text, left, top, font_size, position)
        local new_label = owner:CreateFontString()
        new_label:SetFont(MTSLUI_FONTS.FONTS[font_size]:GetFont())

        new_label:SetPoint(position, left, top)
        if text ~= nil or text ~= "" then
            new_label:SetText(MTSLUI_FONTS.COLORS.TEXT.TITLE .. text)
        end
        return new_label
    end,

    ---------------------------------------------------------------------------------------
    -- Create a button with icon and text
    --
    -- @event_class     Frame       The frame for which to create the label
    -- @name            String      The name of the button
    -- @nr_in_list      Number      The number of the button in a list of buttons
    -- @btn_width       Number      The width of the button
    -- @btn_height      Number      The height of the button
    --
    -- returns      Object      The created button
    ----------------------------------------------------------------------------------------------------------
    CreateIconTextButton = function(self, event_class, name, nr_in_list, btn_width, btn_height)
        local TEXTURES_BUTTON = {
            SELECTED = "Interface\\Buttons\\UI-Listbox-Highlight",
            HIGHLIGHTED = "Interface\\Tooltips\\UI-Tooltip-Background",
            NOT_SELECTED = "",
        }

        local b = CreateFrame("Button", name, event_class.ui_frame)
        -- assume no scrollbar
        b:SetWidth(btn_width)
        b:SetHeight(btn_height)
        -- Custom textures for the button
        b:SetPushedTexture(TEXTURES_BUTTON.SELECTED)
        b:SetHighlightTexture(TEXTURES_BUTTON.HIGHLIGHTED)
        b:SetNormalTexture(TEXTURES_BUTTON.NOT_SELECTED)

        -- Add the icon to left with some margin
        local t = b:CreateTexture("btn_icon", "OVERLAY")
        t:SetTexture("Interface\\Icons\\trade_engraving")
        t:SetWidth(16)
        t:SetHeight(16)
        t:SetPoint("LEFT", 3, 0)
        b.texture = t

        b:SetScript("OnClick", function()
            event_class:HandleSelectedListItem(nr_in_list)
        end)

        b.Select = function(btn)
            btn.is_selected = 1
            btn:SetNormalTexture(TEXTURES_BUTTON.SELECTED)
        end

        b.Deselect = function(btn)
            btn.is_selected = 0
            btn:SetNormalTexture(TEXTURES_BUTTON.NOT_SELECTED)
        end

        b.IsSelected = function(btn)
            return btn.is_selected == 1
        end

        -- Add text to button, left of the icon with some margin
        b.text = self:CreateLabel(b, "-", 20, 1, "LABEL", "LEFT")

        return b
    end,

    -----------------------------------------------------------------------------------------
    -- Create a generic ScrollFrame
    --
    -- @parent_class        ojbect      The parentclass
    -- @parent_frame        ojbect      The parentframe
    -- @width               number      The width of the frame
    -- @height              number      The height of the frame
    -- @has_backdrop        boolean     Frame has backgroound or not (can be nil)
    -- @slider_steps        number      The amount of steps the slider has
    -- @height_slider_step  number      The height of 1 step in the slider
    --
    -- returns              Frame       Returns the created frame
    ----------------------------------------------------------------------------------------
    CreateScrollFrame = function(self, parent_class, parent_frame, width, height, has_backdrop, height_slider_step)
        local scroll_frame = MTSLUI_TOOLS:CreateBaseFrame("Frame", "", parent_frame, nil, width, height, has_backdrop)
        -- add the vertical slider on the right to the frame
        scroll_frame.slider = MTSL_TOOLS:CopyObject(MTSLUI_VERTICAL_SLIDER)
        scroll_frame.slider:Initialise(parent_class, scroll_frame, height, height_slider_step)
        -- Make the frame scrollable
        scroll_frame:EnableMouseWheel(true)
        -- add mousewheel event to scrollframe
        scroll_frame:SetScript("OnMouseWheel", function()
            if arg1 > 0 then
                scroll_frame.slider:ScrollUp()
            elseif arg1 < 0 then
                scroll_frame.slider:ScrollDown()
            end
        end)

        -- return the frame
        return scroll_frame
    end,

    ----------------------------------------------------------------------------------------
    -- Prints info about addon to chat
    ----------------------------------------------------------------------------------------
    PrintAboutMessage = function(self)
        MTSL_TOOLS:Print(MTSLUI_FONTS.COLORS.TEXT.TITLE .. MTSLUI_ADDON.NAME)
        MTSL_TOOLS:Print(MTSLUI_FONTS.COLORS.TEXT.TITLE .. MTSLUI_FONTS.TAB .. self:GetLocalisedLabel("author") .. MTSLUI_FONTS.COLORS.TEXT.NORMAL .. MTSLUI_ADDON.AUTHOR)
        MTSL_TOOLS:Print(MTSLUI_FONTS.COLORS.TEXT.TITLE .. MTSLUI_FONTS.TAB .. self:GetLocalisedLabel("version") .. MTSLUI_FONTS.COLORS.TEXT.NORMAL .. MTSLUI_ADDON.VERSION)
    end,

    ----------------------------------------------------------------------------------------
    -- Prints help about addon to chat
    ----------------------------------------------------------------------------------------
    PrintHelpMessage = function(self)
        self:PrintAboutMessage()
        local slashtext = "/mtsl"
        MTSL_TOOLS:Print(slashtext  .. "                     Opens the character explorer frame")
        MTSL_TOOLS:Print(slashtext .. " char")
        MTSL_TOOLS:Print(slashtext .. " config         Opens the configuration/options menu")
        MTSL_TOOLS:Print(slashtext .. " options")
        MTSL_TOOLS:Print(slashtext .. " about          Print information about this addon")
        MTSL_TOOLS:Print(slashtext .. " help            Print how to use this addon")
        MTSL_TOOLS:Print(slashtext .. " acc              Opens the account explorer frame")
        MTSL_TOOLS:Print(slashtext .. " account")
        MTSL_TOOLS:Print(slashtext .. " db               Opens the database explorer window")
        MTSL_TOOLS:Print(slashtext .. " database")
        MTSL_TOOLS:Print(slashtext .. " npc             Opens the NPC explorer window")
    end,

    ------------------------------------------------------------------------------------------------
    -- Sets the locale used ingame
    --
    -- returns              Boolean     Flag indicating if our language is supported
    ------------------------------------------------------------------------------------------------
    SetAddonLocale = function(self)
        local locale = GetLocale()
        if MTSLUI_LOCALES[locale] == nil then
            MTSL_TOOLS:Print(MTSLUI_FONTS.COLORS.TEXT.ERROR .. "MTSL: Your locale " .. locale .. " is not supported!")
            return false
        end
        MTSLUI_CURRENT_LANGUAGE = MTSLUI_LOCALES[locale]
        return true
    end,

    ------------------------------------------------------------------------------------------------
    -- Creates a TomTom waypoint if possible
    --
    -- @waypointinfo        Array           The waypointinfo containing the zonename, coords & name npc/object
    -- @item_name           String          The name of the item
    ------------------------------------------------------------------------------------------------
    CreateWayPoint = function(self, waypointinfo, item_name)
        -- check if we have coords, if not they are in a dungeon so cant set waypoint then
        if waypointinfo.x and waypointinfo.x ~= "" and waypointinfo.y and waypointinfo.y ~= "" then
            -- only add waypoint is tom tom is installed
            if IsAddOnLoaded("TomTom") and SlashCmdList["TOMTOM_WAY"] ~= nil then
                SlashCmdList["TOMTOM_WAY"](waypointinfo.zone .. " " .. waypointinfo.x .. " " .. waypointinfo.y .. " " .. waypointinfo.name .. " (" .. item_name .. ")")
            elseif not self.tomtom_warned then
                MTSL_TOOLS:Print(MTSLUI_FONTS.COLORS.TEXT.WARNING .. "MTSL: " .. self:GetLocalisedLabel("tomtom needed"))
                self.tomtom_warned = true
            end
        end
    end,

    -----------------------------------------------------------------------------------------
    -- Create a generic Drop down
    --
    -- @frame_owner         Ojbect      The parentframe
    -- @point_owner         Ojbect      The frame owner when setting point
    -- @point_anchor        String      The place where the anchor is set when setting point
    -- @margin_left         Number      The margin from left
    -- @margin_top          Number      The margin from top
    -- @initialiser         Function    The function that initialises/populates the drop down
    -- @with_dd             Number      The width of the drop down
    --
    -- returns              Frame       Returns the created frame
    ----------------------------------------------------------------------------------------
    CreateDropDown = function(self, name, frame_owner, point_owner, point_anchor, margin_left, margin_top, initialiser, width_dd)
        local drop_down = CreateFrame("Frame", name, frame_owner, "UIDropDownMenuTemplate")
        drop_down:SetPoint("TOPLEFT", point_owner, point_anchor, margin_left, margin_top)
        drop_down.initialize = initialiser
        UIDropDownMenu_SetWidth(width_dd, drop_down)
        return drop_down
    end,

    ------------------------------------------------------------------------------------------------
    -- Fill A drop down list
    --
    -- @values              Array           List containing values to add
    -- @change_handler      Function        Function that handles the change of value in the DDL
    -- @change_frame_name   String          The name of the frame to handle the change event
    ------------------------------------------------------------------------------------------------
    FillDropDown = function(self, values, change_handler, change_frame_name)
        local info = {}
        -- add all values
        for _, v in pairs(values) do
            -- already localised in array so no need to index
            info.text = v.name
            -- Dont allow it to be checked/ticked
            info.notCheckable = true
            -- top level has no submenu
            info.func = MTSL_TOOLS:BindArgument(function(value)
                if change_frame_name and _G[change_frame_name] then
                    change_handler(_G[change_frame_name], value.id, value.name)
                else
                    change_handler(value.id, value.name)
                end
                CloseDropDownMenus()
            end, v)
            info.hasArrow = false
            UIDropDownMenu_AddButton(info)
        end
    end,

    ------------------------------------------------------------------------------------------------
    -- Fill A drop down list
    --
    -- @values              Array           List containing values to add
    -- @change_handler      Function        Function that handles the change of value in the DDL
    -- @not_checkable       Boolean         Flag indiciting is the item in dropdown is not checkable or it is
    -- @change_frame_name   String          The name of the frame to handle the change event
    -- @ddl_id_name         String          The base tag for each dropdownbutton of the dropdownlist
    ------------------------------------------------------------------------------------------------
    FillDropDownCheckable = function(self, values, change_handler, change_frame_name)
        local info = {}
        -- add all values
        for _, v in pairs(values) do
            -- already localised in array so no need to index
            info.text = v.name
            info.checked = v.checked
            -- top level has no submenu
            info.func = MTSL_TOOLS:BindArgument(function(value)
                if change_frame_name and _G[change_frame_name] then
                    change_handler(_G[change_frame_name], value.id, value.name)
                else
                    change_handler(value.id, value.name)
                end
            end, v)
            -- keep it open so we can (un)check multiple items at once
            info.keepShownOnClick = true
            info.hasArrow = false
            UIDropDownMenu_AddButton(info)
        end
    end,

    ------------------------------------------------------------------------------------------------
    -- Adds a generic drag to a frame
    ------------------------------------------------------------------------------------------------
    AddDragToFrame = function(self, frame_to_drag)
        frame_to_drag:SetMovable(true)
        frame_to_drag:RegisterForDrag("LeftButton")
        frame_to_drag:SetScript("OnDragStart", function() frame_to_drag:StartMoving() end)
        frame_to_drag:SetScript("OnDragStop", function() frame_to_drag:StopMovingOrSizing() end)
    end,

    ------------------------------------------------------------------------------------------------
    -- Returns the text for a label in the current locale/language
    ------------------------------------------------------------------------------------------------
    GetLocalisedLabel = function(self, label)
        if MTSLUI_CURRENT_LANGUAGE == nil then MTSLUI_CURRENT_LANGUAGE = "English" end
        return MTSLUI_LOCALES_LABELS[label][MTSLUI_CURRENT_LANGUAGE]
    end,

    ------------------------------------------------------------------------------------------------
    -- Returns the text for a label in the current locale/language
    ------------------------------------------------------------------------------------------------
    GetLocalisedLabelSpecialAction = function(self, label)
        if MTSLUI_CURRENT_LANGUAGE == nil then MTSLUI_CURRENT_LANGUAGE = "English" end
        return MTSL_DATA["special_actions"][label]["name"][MTSLUI_CURRENT_LANGUAGE]
    end,

    ------------------------------------------------------------------------------------------------
    -- Returns the name of a data object in the current locale/language
    ------------------------------------------------------------------------------------------------
    GetLocalisedData = function(self, data)
        return data["name"][MTSLUI_CURRENT_LANGUAGE]
    end,
}
