----------------------------------------------------------
-- Name: SkillListFrame                                 --
-- Description: Shows all the skills for one profession --
-- Parent Frame: DatabaseFrame, AccountFrame, MTSL      --
----------------------------------------------------------

MTSLUI_LIST_FRAME = {
    -- Keeps the current created frame
    scroll_frame = nil,
    -- Maximum amount of items shown at once
    MAX_ITEMS_SHOWN_CURRENTLY = 16, -- default mode
    MAX_ITEMS_SHOWN_VERTICAL = 16,
    MAX_ITEMS_SHOWN_HORIZONTAL = 7,
    MAX_ITEMS_SHOWN = nil,
    ITEM_HEIGHT = 19,
    -- array holding the buttons of this frame
    LIST_BUTTONS = nil,
    -- Offset in the list (based on slider)
    slider_offset = 1,
    -- index and id of the selected skill
    selected_list_item_index = nil,
    selected_list_item_id = nil,
    -- index of the selected button
    selected_button_index = nil,
    -- Flag to check if slider is active or not
    slider_active = nil,
    -- width of the frame
    FRAME_WIDTH_VERTICAL = 385,
    FRAME_WIDTH_HORIZONTAL = 515,
    -- height of the frame
    FRAME_HEIGHT_VERTICAL = 315,
    FRAME_HEIGHT_HORIZONTAL = 147,
    -- show all by default
    current_zone = 0,
    -- list of missing skills
    missing_skills = {},

    ----------------------------------------------------------------------------------------------------------
    -- Intialises the MissingSkillsListFrame
    --
    -- @parent_frame        Frame       The parent frame
    ----------------------------------------------------------------------------------------------------------
    Initialise = function(self, parent_frame)
        self.ui_frame = MTSLUI_TOOLS:CreateScrollFrame(self, parent_frame, self.FRAME_WIDTH_VERTICAL, self.FRAME_HEIGHT_VERTICAL, true, self.ITEM_HEIGHT)
        -- Create the buttons
        self.LIST_BUTTONS = {}
        local left = 6
        local top = -6
        -- Determine the number of max items ever shown
        self.MAX_ITEMS_SHOWN = self.MAX_ITEMS_SHOWN_VERTICAL
        if self.MAX_ITEMS_SHOWN_HORIZONTAL > self.MAX_ITEMS_SHOWN then
            self.MAX_ITEMS_SHOWN = self.MAX_ITEMS_SHOWN_HORIZONTAL
        end
        -- initialise all buttons
        for i=1,self.MAX_ITEMS_SHOWN do
            -- Create a new list item (button) by making a copy of MTSLUI_LIST_ITEM
            local skill_button = MTSL_TOOLS:CopyObject(MTSLUI_LIST_ITEM)
            skill_button:Initialise(i, self, self.FRAME_WIDTH_VERTICAL - 7, self.ITEM_HEIGHT, left, top)
            -- adjust top position for next button
            top = top - self.ITEM_HEIGHT
            -- add button to list
            table.insert(self.LIST_BUTTONS, skill_button)
        end

        self.profession_name = ""
        -- default sort by name
        self.current_sort = 1
        -- Default database wide
        self:UpdatePlayerLevels(0, 0)
        self.profession_skills = {}
        self.shown_skills = {}
        self.amount_shown_skills = 0
        self.player_list_frame = nil
    end,

    ----------------------------------------------------------------------------------------------------------
    -- Sets the frame which will show the details of selected item
    --
    -- @detail_item_frame       Object      The frame to show the details of the selected item
    ----------------------------------------------------------------------------------------------------------
    SetDetailSelectedItemFrame = function(self, detail_item_frame)
        self.detail_item_frame = detail_item_frame
    end,

    ----------------------------------------------------------------------------------------------------------
    -- Sets the frame which will show the list of players who have learned the choosen profession
    ----------------------------------------------------------------------------------------------------------
    SetPlayerListFrame = function(self, list_frame)
        self.player_list_frame = list_frame
    end,

    ----------------------------------------------------------------------------------------------------------
    -- Update the levels for the player for which the list is shown
    --
    -- @current_xp_level        Number      The number of the xp level
    -- @current_skill_level     Number      The number of the skill for the profession
    ----------------------------------------------------------------------------------------------------------
    UpdatePlayerLevels = function(self, current_xp_level, current_skill_level)
        self.current_xp_level = current_xp_level
        self.current_skill_level = current_skill_level
    end,

    ----------------------------------------------------------------------------------------------------------
    -- Updates the list of MissingSkillsListFrame
    ----------------------------------------------------------------------------------------------------------
    UpdateList = function(self, missing_skills)
        self.profession_skills = missing_skills

        self.shown_skills = MTSL_LOGIC_PROFESSION:FilterListOfSkills(self.profession_skills, self.profession_name,
                self.filter_values["skill_name"], self.filter_values["source"], self.filter_values["specialisation"],
                self.filter_values["phase"], self.filter_values["zone"], self.filter_values["faction"])

        self.amount_shown_skills = MTSL_TOOLS:CountItemsInArray(self.shown_skills)

        -- sort the list
        self:SortSkills(self.current_sort)

        self:UpdateSlider()
        self:UpdateButtons()
    end,

    UpdateSlider = function(self)
        -- no need for slider
        if self.amount_shown_skills == nil or self.amount_shown_skills <= self.MAX_ITEMS_SHOWN_CURRENTLY then
            self.slider_active = 0
            self.ui_frame.slider:Hide()
        else
            self.slider_active = 1
            local max_steps = self.amount_shown_skills - self.MAX_ITEMS_SHOWN_CURRENTLY + 1
            self.ui_frame.slider:Refresh(max_steps, self.MAX_ITEMS_SHOWN_CURRENTLY)
            self.ui_frame.slider:Show()
        end
    end,

    ----------------------------------------------------------------------------------------------------------
    -- Updates the skillbuttons of MissingSkillsListFrame
    ----------------------------------------------------------------------------------------------------------
    UpdateButtons = function(self)
        for i=1,self.MAX_ITEMS_SHOWN_CURRENTLY do
            if self.MAX_ITEMS_SHOWN_CURRENTLY == self.MAX_ITEMS_SHOWN_HORIZONTAL then
                self.LIST_BUTTONS[i]:UpdateWidth(self.FRAME_WIDTH_HORIZONTAL - 12)
            else
                self.LIST_BUTTONS[i]:UpdateWidth(self.FRAME_WIDTH_VERTICAL - 12)
            end
            if self.amount_shown_skills >= i then
                -- 1 cause offset starts at 1 too,
                local skill_for_button = self.shown_skills  [i + self.slider_offset - 1]
                -- Check if button has text to display, otherwise hide it
                if skill_for_button ~= nil then
                    -- create the text to be shown
                    local text_for_button = MTSLUI_FONTS.COLORS.AVAILABLE.YES
                    -- if skill_level = 0 => databasewide, all text is "white"
                    if self.current_skill_level == 0 or self.current_skill_level == nil then
                        text_for_button = MTSLUI_FONTS.COLORS.AVAILABLE.ALL
                    elseif skill_for_button.min_skill > self.current_skill_level then
                            text_for_button =  MTSLUI_FONTS.COLORS.AVAILABLE.NO
                    end
                    text_for_button = text_for_button .. "[" .. skill_for_button.min_skill .. "] "
                    text_for_button = text_for_button .. MTSLUI_FONTS.COLORS.TEXT.NORMAL .. MTSLUI_TOOLS:GetLocalisedData(skill_for_button)
                    -- update & show the button
                    self.LIST_BUTTONS[i]:Refresh(text_for_button, self.slider_active)
                    self.LIST_BUTTONS[i]:Show()
                    -- button is unavaible so hide it
                else
                    self.LIST_BUTTONS[i]:Hide()
                end
            else
                self.LIST_BUTTONS[i]:Hide()
            end
        end
        -- hide the remaining buttons not shown when using horizontal split
        for i=self.MAX_ITEMS_SHOWN_CURRENTLY + 1,self.MAX_ITEMS_SHOWN do
            self.LIST_BUTTONS[i]:Hide()
        end
    end,

    ----------------------------------------------------------------------------------------------------------
    -- Handles the event when skill button is pushed
    --
    -- @id      Number      The id (= index) of button that is pushed
    ----------------------------------------------------------------------------------------------------------
    HandleSelectedListItem = function(self, id)
        -- Clicked on same button so deselect it
        if self.LIST_BUTTONS[id]:IsSelected() == 1 then
            self.selected_list_item_index = nil
            self.selected_list_item_id = nil
            self.selected_button_index = nil
            self.LIST_BUTTONS[id]:Deselect()
            self.detail_item_frame:ShowNoSkillSelected()
        else
            -- Deselect the current button if visible
            self:DeselectCurrentSkillButton()
            -- Subtract 1 because index starts at 1 instead of 0
            self.selected_list_item_index = self.slider_offset + id - 1
            if self.amount_shown_skills >= self.selected_list_item_index then
                -- update the index of selected button
                self.selected_button_index = id
                self:SelectCurrentSkillButton()
                -- Show the information of the selected skill
                local selected_skill = self.shown_skills[self.selected_list_item_index]
                if selected_skill ~= nil then
                    self.selected_list_item_id = selected_skill.id
                    -- cant select item so deselect details
                    self.detail_item_frame:ShowDetailsOfSkill(selected_skill, self.profession_name, self.current_xp_level, self.current_skill_level)
                    -- if we have a player list frame added, trigger update there as well
                    if self.player_list_frame ~= nil then
                        self.player_list_frame:ChangeProfessionSkill(self.profession_name, selected_skill)
                    end
                else
                    if self.detail_item_frame then self.detail_item_frame:ShowNoSkillSelected() end
                    -- if we have a player list frame added, trigger update there as well
                    if self.player_list_frame ~= nil then self.player_list_frame:NoPlayersToShow() end
                end
            else
                if self.detail_item_frame then self.detail_item_frame:ShowNoSkillSelected() end
                -- if we have a player list frame added, trigger update there as well
                if self.player_list_frame ~= nil then self.player_list_frame:NoPlayersToShow() end
            end
        end
    end,

    ----------------------------------------------------------------------------------------------------------
    -- Handles the event when we scroll
    --
    -- @offset  Number
    ----------------------------------------------------------------------------------------------------------
    HandleScrollEvent = function(self, offset)
        -- Only handle the event if slider is visible
        if self.slider_active == 1 then
            -- Update the index of the selected skill if any
            if self.selected_list_item_index ~= nil then
                -- Deselect the current button if visible
                self:DeselectCurrentSkillButton()
                -- adjust index of the selected skill in the list
                local scroll_gap = offset - self.slider_offset
                if self.selected_list_item_index ~= nil then
                   self.selected_list_item_index = self.selected_list_item_index - scroll_gap
                end
                if self.selected_button_index ~= nil then
                   self.selected_button_index = self.selected_button_index - scroll_gap
                end

                -- Select the current button if visible
                self:SelectCurrentSkillButton()
                -- scrolled of screen so remove selected id
                if self.selected_button_index == nil or self.selected_button_index < 1 or self.selected_button_index > self.MAX_ITEMS_SHOWN_CURRENTLY then
                    self.selected_list_item_id = nil
                end
            end
            -- Update the offset for the slider
            self.slider_offset = offset
            -- update the text on the buttons based on the new "visible" skills
            self:UpdateButtons()
        end
    end,

    ----------------------------------------------------------------------------------------------------------
    -- The list is empty
    ----------------------------------------------------------------------------------------------------------
    NoSkillsToShow = function(self)
        -- deselect current skill & button
        self:DeselectCurrentSkillButton()
        self.selected_list_item_index = nil
        self.selected_list_item_id = nil
        self.selected_button_index = nil
        -- pass it trough to the detail frame
        self.detail_item_frame:ShowNoSkillSelected()
    end,

    ----------------------------------------------------------------------------------------------------------
    -- reset the position of the scroll bar & deselect current skill
    ----------------------------------------------------------------------------------------------------------
    Reset = function(self)
        -- dselect current skill & button
        self:DeselectCurrentSkillButton()
        self.selected_list_item_index = nil
        self.selected_list_item_id = nil
        self.selected_button_index = nil
        -- Scroll all way to top
        self:HandleScrollEvent(1)
    end,

    ----------------------------------------------------------------------------------------------------------
    -- Selects the current selected skillbuton
    ----------------------------------------------------------------------------------------------------------
    SelectCurrentSkillButton = function(self)
        if self.selected_button_index ~= nil and
                self.selected_button_index >= 1 and
                self.selected_button_index <= self.MAX_ITEMS_SHOWN_CURRENTLY then
            self.LIST_BUTTONS[self.selected_button_index]:Select()
        end
    end,

    ----------------------------------------------------------------------------------------------------------
    -- Deselects the current selected skillbuton
    ----------------------------------------------------------------------------------------------------------
    DeselectCurrentSkillButton = function(self)
        if self.selected_button_index ~= nil and
                self.selected_button_index >= 1 and
                self.selected_button_index <= self.MAX_ITEMS_SHOWN_CURRENTLY then
            self.LIST_BUTTONS[self.selected_button_index]:Deselect()
        end
    end,

    ----------------------------------------------------------------------------------------------------------
    -- To see if we have a skill selected or not
    ------------------------------------------------------------     ----------------------------------------------
    HasSkillSelected = function(self)
        return self.selected_list_item_id ~= nil
    end,

    ----------------------------------------------------------------------------------------------------------
    -- Sort skills
    ----------------------------------------------------------------------------------------------------------
    SortSkills = function(self)
        -- Only sort if list is not empty
        if self.amount_shown_skills > 0 then
            if self.current_sort == 1 then
                table.sort(self.shown_skills, function(a, b)
                    if a.min_skill < b.min_skill then
                        return true
                    elseif a.min_skill > b.min_skill then
                        return false
                    -- equal skill so return alphabetical
                    else
                        return MTSLUI_TOOLS:GetLocalisedData(a) < MTSLUI_TOOLS:GetLocalisedData(b)
                    end
                end)
            else
                MTSL_TOOLS:SortArrayByLocalisedProperty(self.shown_skills, "name")
            end
        end
    end,

    ----------------------------------------------------------------------------------------------------------
    -- Change the sort order of the list with shown skills
    ----------------------------------------------------------------------------------------------------------
    ChangeSort = function(self, new_sort)
        -- Only change if new one
        if self.current_sort ~= new_sort then
            self.current_sort = new_sort
            self:RefreshList()
        end
    end,

    ----------------------------------------------------------------------------------------------------------
    -- Change the profession to be used in the list
    ----------------------------------------------------------------------------------------------------------
    ChangeProfession = function(self, profession_name, list_skills)
        -- Only change if new one
        if self.profession_name ~= profession_name then
            self.profession_name = profession_name
            self:UpdateList(list_skills)
            -- Auto select first skill of the profession
            self:RefreshList()
        end
    end,

    ChangeFilters = function(self, filters)
        self.filter_values = filters
        self:RefreshList()
    end,

    ----------------------------------------------------------------------------------------------------------
    -- Refresh the contents of the list after changing zone
    ----------------------------------------------------------------------------------------------------------
    RefreshList = function(self)
        self:DeselectCurrentSkillButton()
        self.selected_list_item_index = nil
        self.selected_button_index = nil
        self.selected_list_item_id = nil
        self:UpdateList(self.profession_skills)
        -- auto select the first one
        self:HandleSelectedListItem(1)
    end,

    -- Switch to vertical split layout
    ResizeToVerticalMode = function(self)
        -- adjust max items shown
        self.MAX_ITEMS_SHOWN_CURRENTLY = self.MAX_ITEMS_SHOWN_VERTICAL
        self:RefreshUI()
    end,

    -- Switch to horizontal split layout
    ResizeToHorizontalMode = function(self)
        -- adjust max items shown
        self.MAX_ITEMS_SHOWN_CURRENTLY = self.MAX_ITEMS_SHOWN_HORIZONTAL
        self:RefreshUI()
    end,

    -- Refresh the UI based on the splitter (only to be called from Resize methode in this class)
    RefreshUI = function(self)
        if self.MAX_ITEMS_SHOWN_CURRENTLY == self.MAX_ITEMS_SHOWN_HORIZONTAL then
            self.ui_frame:SetWidth(self.FRAME_WIDTH_HORIZONTAL)
            self.ui_frame:SetHeight(self.FRAME_HEIGHT_HORIZONTAL)
        else
            self.ui_frame:SetWidth(self.FRAME_WIDTH_VERTICAL)
            self.ui_frame:SetHeight(self.FRAME_HEIGHT_VERTICAL)
        end
        -- update the width of the list items (no need to update all, others will be hidden)
        self:UpdateButtons()
        -- refrehs/update ui only if window is shown
        if self.ui_frame:IsVisible() then
            self:RefreshList()
        else
            self:UpdateSlider()
        end
    end,
}
