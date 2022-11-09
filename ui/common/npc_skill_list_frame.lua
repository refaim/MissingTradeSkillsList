---------------------------------------------
-- Name: NpcSkillListFrame                 --
-- Description: Shows all skill of one npc --
-- Parent Frame: NpcExplorerFrame          --
---------------------------------------------

MTSLUI_NPC_SKILL_LIST_FRAME = {
    -- Keeps the current created frame
    scroll_frame = nil,
    -- Maximum amount of items shown at once
    MAX_ITEMS_SHOWN_CURRENTLY = 23, -- default mode
    MAX_ITEMS_SHOWN_VERTICAL = 23,
    MAX_ITEMS_SHOWN_HORIZONTAL = 7,
    ITEM_HEIGHT = 19,
    -- array holding the buttons of this frame
    LIST_BUTTONS = nil,
    -- Offset in the list (based on slider)
    slider_offset = 1,
    -- index and id of the selected npc
    selected_list_item_index = nil,
    selected_list_item_id = nil,
    -- index of the selected button
    selected_button_index = nil,
    -- Flag to check if slider is active or not
    slider_active = nil,
    -- width of the frame
    FRAME_WIDTH_VERTICAL = 385,
    FRAME_WIDTH_HORIZONTAL = 450, -- same width as the npc filter frame
    -- height of the frame
    FRAME_HEIGHT_VERTICAL = 448, -- for 25 items, so 19 / item + margin
    FRAME_HEIGHT_HORIZONTAL = 145, -- for 7 items, so 19 / item + margin
    -- textures representing the icon of the profession
    TEXTURES_PROFESSION = {
        ["Alchemy"] = "trade_alchemy",
        ["Blacksmithing"] = "trade_blacksmithing",
        ["Enchanting"] = "trade_engraving",
        ["Engineering"] = "trade_engineering",
        ["Herbalism"] = "spell_nature_naturetouchgrow",
        ["Leatherworking"] = "inv_misc_armorkit_17",
        ["Mining"] = "trade_mining",
        ["Skinning"] = "inv_misc_pelt_wolf_01",
        ["Tailoring"] = "trade_tailoring",
        ["Cooking"] = "inv_misc_food_15",
        ["First Aid"] = "spell_holy_sealofsacrifice",
        ["Fishing"] = "trade_fishing",
        ["Poisons"] =  "trade_brewpoison",
    },

    ----------------------------------------------------------------------------------------------------------
    -- Intialises the NpcsListFrame
    --
    -- @parent_frame        Frame       The parent frame
    ----------------------------------------------------------------------------------------------------------
    Initialise = function(self, parent_frame)
        self.ui_frame = MTSLUI_TOOLS:CreateScrollFrame(self, parent_frame, self.FRAME_WIDTH_VERTICAL, self.FRAME_HEIGHT_VERTICAL, true, self.ITEM_HEIGHT)
        -- Create the buttons
        self.PROF_BGS = {}
        self.LIST_BUTTONS = {}
        local left = 6
        local top = -6
        self.MAX_ITEMS_SHOWN = self.MAX_ITEMS_SHOWN_VERTICAL
        if self.MAX_ITEMS_SHOWN_HORIZONTAL > self.MAX_ITEMS_SHOWN then self.MAX_ITEMS_SHOWN = self.MAX_ITEMS_SHOWN_HORIZONTAL end
        -- initialise all buttons
        for i=1,self.MAX_ITEMS_SHOWN do
            -- Create a new list item (button) with icon & text
            local skill_button =  MTSLUI_TOOLS:CreateIconTextButton(self, "MTSLUI_NPC_SKILL_LIST_FRAME_BTN_PROF_"..i, i, self.FRAME_WIDTH_VERTICAL - 30, self.ITEM_HEIGHT)
            -- LEFT in the button itself
            skill_button:SetPoint("TOPLEFT", self.ui_frame, "TOPLEFT", left, top)
            skill_button:Show()
            -- adjust top position for next button
            top = top - self.ITEM_HEIGHT
            -- add button to list
            table.insert(self.LIST_BUTTONS, skill_button)
        end

        self.FRAME_WIDTH = self.FRAME_WIDTH_VERTICAL
        self.FRAME_HEIGHT = self.FRAME_HEIGHT_VERTICAL

        self.skills_of_npc = {}
        self.amount_skills_of_npc = 0

        self:UpdateList()
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
    -- Updates the skill list of the current npc
    ----------------------------------------------------------------------------------------------------------
    UpdateList = function (self, skills_of_npc)
        self.skills_of_npc = skills_of_npc
        self.amount_skills_of_npc = MTSL_TOOLS:CountItemsInArray(self.skills_of_npc)

        if self.amount_skills_of_npc <= 0 then
            self.amount_skills_of_npc = 0
            self:NoSkillsToShow()
        end

        -- sort the list by name
        MTSL_TOOLS:SortArrayByLocalisedProperty(self.skills_of_npc, "name")

        self:UpdateSlider()
        self:UpdateButtons()
        -- Auto select the first item if we can
        if self.detail_item_frame ~= nil then self:HandleSelectedListItem(1) end
    end,

    UpdateSlider = function(self)
        -- no need for slider
        if self.amount_skills_of_npc == nil or self.amount_skills_of_npc <= self.MAX_ITEMS_SHOWN_CURRENTLY then
            self.slider_active = 0
            self.ui_frame.slider:Hide()
        else
            self.slider_active = 1
            local max_steps = self.amount_skills_of_npc - self.MAX_ITEMS_SHOWN_CURRENTLY + 1
            self.ui_frame.slider:Refresh(max_steps, self.MAX_ITEMS_SHOWN_CURRENTLY)
            self.ui_frame.slider:Show()
        end
    end,

    ----------------------------------------------------------------------------------------------------------
    -- Updates the npcbuttons of MissingNpcsListFrame
    ----------------------------------------------------------------------------------------------------------
    UpdateButtons = function (self)
        local amount_to_show = self.amount_skills_of_npc
        local slider_active = 0
        -- have more then we can show so limit
        if amount_to_show > self.MAX_ITEMS_SHOWN_CURRENTLY then
            amount_to_show = self.MAX_ITEMS_SHOWN_CURRENTLY
            slider_active = 1
        end
        for i=1,amount_to_show do
            -- minus 1 because offset starts at 1
            local current_skill = self.skills_of_npc[i + self.slider_offset - 1]
            -- Get the profession name of the skill
            local profession_name = MTSL_LOGIC_PROFESSION:GetProfessionNameBySkill(current_skill)
            if self.TEXTURES_PROFESSION[profession_name] ~= nil then
                self.LIST_BUTTONS[i].texture:SetTexture("Interface\\Icons\\" .. self.TEXTURES_PROFESSION[profession_name])
            else
                self.LIST_BUTTONS[i].texture:SetTexture("")
            end
            -- create the text to be shown
            local text_for_button =  MTSLUI_FONTS.COLORS.TEXT.NORMAL .. "[" .. current_skill.min_skill .. "] " .. MTSLUI_TOOLS:GetLocalisedData(current_skill)
            -- update & show the button
            self.LIST_BUTTONS[i].text:SetText(text_for_button)
            -- Move past the icon + some margin
            self.LIST_BUTTONS[i].text:SetPoint("LEFT", 22, 1)
            self.LIST_BUTTONS[i]:Show()
            -- Change width of button based on active slider
            self.LIST_BUTTONS[i]:SetWidth(self.FRAME_WIDTH - 12 - 18 * slider_active)
            self.LIST_BUTTONS[i]:SetHeight(self.ITEM_HEIGHT)
        end
        -- hide the remaining buttons not shown when using horizontal split
        for i=amount_to_show + 1,self.MAX_ITEMS_SHOWN do
            self.LIST_BUTTONS[i]:Hide()
        end
    end,

    ----------------------------------------------------------------------------------------------------------
    -- Handles the event when npc button is pushed
    --
    -- @id      Number      The id (= index) of button that is pushed
    ----------------------------------------------------------------------------------------------------------
    HandleSelectedListItem = function(self, id)
        self:DeselectCurrentSkillButton()
        -- Clicked on same button so deselect it
        if self.LIST_BUTTONS[id]:IsSelected() == true then
            self.selected_list_item_index = nil
            self.selected_list_item_id = nil
            self.selected_button_index = nil
        else
            -- Subtract 1 because index starts at 1 instead of 0
            self.selected_list_item_index = self.slider_offset + id - 1
            if self.amount_skills_of_npc >= self.selected_list_item_index then
                -- update the index of selected button
                self.selected_button_index = id
                self:SelectCurrentSkillButton()
                -- Show the information of the selected npc
                local selected_skill = self.skills_of_npc[self.selected_list_item_index]
                if selected_skill then
                    local profession_name = MTSL_LOGIC_PROFESSION:GetProfessionNameBySkill(selected_skill)
                    self.selected_list_item_id = selected_skill.id
                    -- cant select item so deselect details
                    self.detail_item_frame:ShowDetailsOfSkill(selected_skill, profession_name, 0, 0)
                else
                    self.detail_item_frame:ShowNoSkillSelected()
                end
            else
                self.detail_item_frame:ShowNoSkillSelected()
            end
        end
    end,

    ----------------------------------------------------------------------------------------------------------
    -- Handles the event when we scroll
    --
    -- @offset  Number
    ----------------------------------------------------------------------------------------------------------
    HandleScrollEvent = function (self, offset)
        -- Only handle the event if slider is visible
        if self.slider_active == 1 then
            -- Update the index of the selected npc if any
            if self.selected_list_item_index ~= nil then
                -- Deselect the current button if visible
                self:DeselectCurrentSkillButton()
                -- adjust index of the selected npc in the list
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
                if self.selected_button_index == nil or self.selected_button_index < 1 or self.selected_button_index > self.MAX_ITEMS_SHOWN_HORIZONTAL then
                    self.selected_list_item_id = nil
                end
            end
            -- Update the offset for the slider
            self.slider_offset = offset
            -- update the text on the buttons based on the new "visible" npcs
            self:UpdateButtons()
        end
    end,

    ----------------------------------------------------------------------------------------------------------
    -- The list is empty
    ----------------------------------------------------------------------------------------------------------
    NoSkillsToShow = function(self)
        -- dselect current npc & button
        self:DeselectCurrentSkillButton()
        self.selected_list_item_index = nil
        self.selected_list_item_id = nil
        self.selected_button_index = nil
        -- hide slider and buttons
        self.amount_skills_of_npc = 0
        self:UpdateSlider()
        self:UpdateButtons()
        -- pass it trough to the detail frame
        if self.detail_item_frame ~= nil then
            self.detail_item_frame:ShowNoSkillSelected()
        end
    end,

    ----------------------------------------------------------------------------------------------------------
    -- reset the position of the scroll bar & deselect current npc
    ----------------------------------------------------------------------------------------------------------
    Reset = function(self)
        -- dselect current npc skill  & button
        self:DeselectCurrentSkillButton()
        self.selected_list_item_index = nil
        self.selected_list_item_id = nil
        self.selected_button_index = nil
        -- Scroll all way to top
        self:HandleScrollEvent(1)
    end,

    ----------------------------------------------------------------------------------------------------------
    -- Selects the current selected npc skill buton
    ----------------------------------------------------------------------------------------------------------
    SelectCurrentSkillButton = function (self)
        if self.selected_button_index ~= nil and
                self.selected_button_index >= 1 and
                self.selected_button_index <= self.MAX_ITEMS_SHOWN_CURRENTLY then
            self.LIST_BUTTONS[self.selected_button_index]:Select()
        end
    end,

    ----------------------------------------------------------------------------------------------------------
    -- Deselects the current selected npc skill buton
    ----------------------------------------------------------------------------------------------------------
    DeselectCurrentSkillButton = function (self)
        if self.selected_button_index ~= nil and
                self.selected_button_index >= 1 and
                self.selected_button_index <= self.MAX_ITEMS_SHOWN_CURRENTLY then
            self.LIST_BUTTONS[self.selected_button_index]:Deselect()
        end
    end,

    ----------------------------------------------------------------------------------------------------------
    -- To see if we have a skill selected or not
    ----------------------------------------------------------------------------------------------------------
    HasSkillSelected = function(self)
        return self.selected_list_item_id ~= nil
    end,

    ----------------------------------------------------------------------------------------------------------
    -- Refresh the contents of the list after changing zone
    ----------------------------------------------------------------------------------------------------------
    RefreshList = function(self)
        self:DeselectCurrentSkillButton()
        self.selected_list_item_index = nil
        self.selected_button_index = nil
        self.selected_list_item_id = nil
        self:UpdateList()
        -- auto select the first one
        self:HandleSelectedListItem(1)
    end,

    -- Switch to vertical split layout
    ResizeToVerticalMode = function(self)
        -- adjust max items shown
        self.MAX_ITEMS_SHOWN_CURRENTLY = self.MAX_ITEMS_SHOWN_VERTICAL

        self.FRAME_WIDTH = self.FRAME_WIDTH_VERTICAL
        self.FRAME_HEIGHT = self.FRAME_HEIGHT_VERTICAL

        self:RefreshUI()
    end,

    -- Switch to horizontal split layout
    ResizeToHorizontalMode = function(self)
        -- adjust max items shown
        self.MAX_ITEMS_SHOWN_CURRENTLY = self.MAX_ITEMS_SHOWN_HORIZONTAL

        self.FRAME_WIDTH = self.FRAME_WIDTH_HORIZONTAL
        self.FRAME_HEIGHT = self.FRAME_HEIGHT_HORIZONTAL

        self:RefreshUI()
    end,

    -- Refresh the UI based on the splitter (only to be called from Resize methode in this class)
    RefreshUI = function(self)
        self.ui_frame:SetWidth(self.FRAME_WIDTH)
        self.ui_frame:SetHeight(self.FRAME_HEIGHT)

        -- refrehs/update ui only if window is shown
        if self.ui_frame:IsVisible() then
            self:RefreshList()
        else
            self:UpdateSlider()
        end
    end,
}
