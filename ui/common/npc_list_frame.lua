---------------------------------------------------------------
-- Name: NpcListFrame                                        --
-- Description: Shows all npcs that meet the filter criteria --
-- Parent Frame: NpcExplorerFrame                            --
---------------------------------------------------------------

MTSLUI_NPC_LIST_FRAME = {
    -- Keeps the current created frame
    scroll_frame,
    -- Maximum amount of items shown at once
    MAX_ITEMS_SHOWN_CURRENTLY = 17, -- default mode
    MAX_ITEMS_SHOWN_VERTICAL = 17,
    MAX_ITEMS_SHOWN_HORIZONTAL = 9,
    MAX_ITEMS_SHOWN,
    ITEM_HEIGHT = 19,
    -- array holding the buttons of this frame
    LIST_BUTTONS,
    -- Offset in the list (based on slider)
    slider_offset = 1,
    -- index and id of the selected npc
    selected_list_item_index,
    selected_list_item_id,
    -- index of the selected button
    selected_button_index,
    -- Flag to check if slider is active or not
    slider_active,
    -- width of the frame
    FRAME_WIDTH = 450,
    -- height of the frame
    FRAME_HEIGHT_VERTICAL = 335,
    FRAME_HEIGHT_HORIZONTAL = 182,
    TEXTURES_FACTION = {
        ALLIANCE = MTSLUI_ADDON_PATH .. "\\Images\\alliance.blp",
        HORDE = MTSLUI_ADDON_PATH .. "\\Images\\horde.blp",
        NEUTRAL = MTSLUI_ADDON_PATH .. "\\Images\\neutral.blp",
        HOSTILE = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_8",
        ARGENT_DAWN = "Interface\\TargetingFrame\\inv_jewelry_talisman_07",
        TIMBERMAW_HOLD = "Interface\\TargetingFrame\\inv_misc_horn_01",
    },
    -- array holding the current filter values
    filter_values = {},

    ----------------------------------------------------------------------------------------------------------
    -- Intialises the NpcsListFrame
    --
    -- @parent_frame        Frame       The parent frame
    ----------------------------------------------------------------------------------------------------------
    Initialise = function(self, parent_frame)
        self.ui_frame = MTSLUI_TOOLS:CreateScrollFrame(self, parent_frame, self.FRAME_WIDTH, self.FRAME_HEIGHT_VERTICAL, true, self.ITEM_HEIGHT)
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
            -- Create a new list item (button) with icon & text
            local npc_button =  MTSLUI_TOOLS:CreateIconTextButton(self, "MTSLUI_NPC_LIST_FRAME_BTN_NPC_"..i, i, self.FRAME_WIDTH - 30, self.ITEM_HEIGHT) -- self:CreateNpcButton("MTSLUI_NPC_LIST_FRAME_BTN_NPC_"..i, i)
            -- LEFT in the button itself
            npc_button:SetPoint("TOPLEFT", self.ui_frame, "TOPLEFT", left, top)
            npc_button:Show()
            -- adjust top position for next button
            top = top - self.ITEM_HEIGHT
            -- add button to list
            table.insert(self.LIST_BUTTONS, npc_button)
        end

        -- make copy of all NPCs so we can "enrich" the data first, to optimize filtering after
        self.available_npcs = MTSL_TOOLS:CopyObject(MTSL_DATA["npcs"])
        self.available_npc_skills = {}
        -- link all skills to en
        self:EnhanceNpcData()

        self.shown_npcs = {}
        self.amount_shown_npcs = 0
    end,

    AddSkillToNpc = function(self, npc_id, npc, faction, profession, source_type, rank, skill)
        -- Check if faction is present
        if npc[faction] == nil then npc[faction] = {} end
        -- Check if profession exists
        if npc[faction][profession] == nil then npc[faction][profession] = {} end
        -- Check if source_type exists
        if npc[faction][profession][source_type] == nil then npc[faction][profession][source_type] = {} end
        -- Check if rank exists
        if npc[faction][profession][source_type]["rank_" .. rank] == nil then npc[faction][profession][source_type]["rank_" .. rank] = {} end
        -- add skill
        table.insert(npc[faction][profession][source_type]["rank_" .. rank], skill.id)
        -- also add it to full seperate list of skill to pass to skill list frame
        if self.available_npc_skills[npc_id] == nil then self.available_npc_skills[npc_id] = {} end
        if MTSL_TOOLS:GetItemFromArrayByKeyValue(self.available_npc_skills[npc_id], "id", skill.id) == nil then
            table.insert(self.available_npc_skills[npc_id], skill)
        end
    end,

    ----------------------------------------------------------------------------------------------------------
    -- Adds data from skills/recipes/quests/objects to NPC to optimize filtering afterwards
    ----------------------------------------------------------------------------------------------------------
    EnhanceNpcData = function (self)
        -- Merge data for each filter to each NPC so we access it later straightaway
        -- Available filters: name, faction, profession, source, zone
        -- Temp array to hold new data for each npc
        local npcs = {}
        -- create entry for each npc
        for _, n in pairs(self.available_npcs) do
            npcs[n.id] = {}
            -- save for each npc: NPC[Factions][Professions][Type source][rank][Skills]
            npcs[n.id][n.reacts] = {}
            npcs[n.id]["reacts"] = n.reacts
        end
        -- No need to merge name or zone, already linked to NPC
        -- Loop each profession
        for p, _ in pairs(MTSL_DATA["professions"]) do
            -- loop each skill & level
            local skills_levels = MTSL_LOGIC_PROFESSION:GetAllSkillsAndLevelsForProfession(p)
            for _, sl in pairs(skills_levels) do
                -- add trainer to each npc
                if sl.trainers then
                    for _, npc_id in pairs(sl.trainers.sources) do
                        if npcs[npc_id] == nil then
                            print(MTSLUI_FONTS.COLORS.TEXT.WARNING .. "MTSL: NPC with id " .. npc_id .. " is missing. Please report this bug!")
                        else
                            -- specific faction or Alliance/Horde/neutral/Hostile
                            local faction = npcs[npc_id]["reacts"]
                            if sl.reputation ~= nil then
                                faction = MTSL_TOOLS:GetItemFromUnsortedListById(MTSL_DATA["factions"], sl.reputation.faction_id)["name"]["English"]
                            end
                            -- specific rank or any
                            local rank = sl.rank or 0
                            -- if trainer is speciliast, use rank 5
                            if sl.specialisation ~= nil then
                                rank = 5
                            end
                            self:AddSkillToNpc(npc_id, npcs[npc_id], faction, p, "trainer", rank, sl)
                        end
                    end
                end
                -- questgiver
                if sl.quests then
                    -- loop each quest
                    for _, quest_id in pairs(sl.quests) do
                        local quest = MTSL_LOGIC_QUEST:GetQuestById(quest_id)
                        -- Each questgiver
                        if quest and quest.npcs then
                            for _, npc_id in pairs(quest.npcs) do
                                if npcs[npc_id] == nil then
                                    print(MTSLUI_FONTS.COLORS.TEXT.WARNING .. "MTSL: NPC with id " .. npc_id .. " is missing. Please report this bug!")
                                else
                                    -- specific faction or Alliance/Horde/neutral/Hostile
                                    local faction = npcs[npc_id]["reacts"]
                                    if sl.reputation ~= nil then
                                        faction = MTSL_TOOLS:GetItemFromUnsortedListById(MTSL_DATA["factions"], sl.reputation.faction_id)["name"]["English"]
                                    end
                                    -- quest specific if needed
                                    if quest.reputation ~= nil then
                                        faction = MTSL_TOOLS:GetItemFromUnsortedListById(MTSL_DATA["factions"], quest.reputation.faction_id)["name"]["English"]
                                    end
                                    self:AddSkillToNpc(npc_id, npcs[npc_id], faction, p, "questgiver", 0, sl)
                                end
                            end
                        end
                    end
                end
                -- Get the item if any
                if sl.items then
                    -- loop each item
                    for _, item_id in pairs(sl.items) do
                        local item = MTSL_LOGIC_ITEM_OBJECT:GetItemForProfessionById(item_id, p)
                        -- only check for substatus if we have an item
                        if item then
                            -- Vendors
                            if item.vendors then
                                -- Vendors
                                for _, npc_id in pairs(item.vendors.sources) do
                                    if npcs[npc_id] == nil then
                                        print(MTSLUI_FONTS.COLORS.TEXT.WARNING .. "MTSL: NPC with id " .. npc_id .. " is missing. Please report this bug!")
                                    else
                                        -- specific faction or Alliance/Horde/neutral/Hostile
                                        local faction = npcs[npc_id]["reacts"]
                                        if sl.reputation then
                                            faction = MTSL_TOOLS:GetItemFromUnsortedListById(MTSL_DATA["factions"], sl.reputation.faction_id)["name"]["English"]
                                        end
                                        -- item specific if needed
                                        if item.reputation then
                                            faction = MTSL_TOOLS:GetItemFromUnsortedListById(MTSL_DATA["factions"], item.reputation.faction_id)["name"]["English"]
                                        end
                                        self:AddSkillToNpc(npc_id, npcs[npc_id], faction, p, "vendor", 0, sl)
                                    end
                                end
                            end
                            -- Dropmob
                            if item.drops and item.drops.sources then
                                -- Vendors
                                for _, npc_id in pairs(item.drops.sources) do
                                    if npcs[npc_id] == nil then
                                        print(MTSLUI_FONTS.COLORS.TEXT.WARNING .. "MTSL: NPC with id " .. npc_id .. " is missing. Please report this bug!")
                                    else
                                        -- specific faction or Alliance/Horde/neutral/Hostile
                                        local faction = npcs[npc_id]["reacts"]
                                        if sl.reputation then
                                            faction = MTSL_TOOLS:GetItemFromUnsortedListById(MTSL_DATA["factions"], sl.reputation.faction_id)["name"]["English"]
                                        end
                                        -- item specific if needed
                                        if item.reputation then
                                            faction = MTSL_TOOLS:GetItemFromUnsortedListById(MTSL_DATA["factions"], item.reputation.faction_id)["name"]["English"]
                                        end
                                        self:AddSkillToNpc(npc_id, npcs[npc_id], faction, p, "mob", 0, sl)
                                    end
                                end
                            end
                            -- questgiver
                            if item.quests then
                                -- loop each quest
                                for _, quest_id in pairs(item.quests) do
                                    local quest = MTSL_LOGIC_QUEST:GetQuestById(quest_id)
                                    -- Each questgiver
                                    if quest and quest.npcs then
                                        for _, npc_id in pairs(quest.npcs) do
                                            if npcs[npc_id] == nil then
                                                print(MTSLUI_FONTS.COLORS.TEXT.WARNING .. "MTSL: NPC with id " .. npc_id .. " is missing. Please report this bug!")
                                            else
                                                -- specific faction or Alliance/Horde/neutral/Hostile
                                                local faction = npcs[npc_id]["reacts"]
                                                if sl.reputation then
                                                    faction = MTSL_TOOLS:GetItemFromUnsortedListById(MTSL_DATA["factions"], sl.reputation.faction_id)["name"]["English"]
                                                end
                                                -- item specific if needed
                                                if item.reputation then
                                                    faction = MTSL_TOOLS:GetItemFromUnsortedListById(MTSL_DATA["factions"], item.reputation.faction_id)["name"]["English"]
                                                end
                                                -- quest specific if needed
                                                if quest.reputation then
                                                    faction = MTSL_TOOLS:GetItemFromUnsortedListById(MTSL_DATA["factions"], quest.reputation.faction_id)["name"]["English"]
                                                end
                                                self:AddSkillToNpc(npc_id, npcs[npc_id], faction, p, "questgiver", 0, sl)
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        -- move the enhnaced data to each NPC
        for _, npc in pairs(self.available_npcs) do
            npcs[npc.id]["reacts"] = nil
            npc["enhanced"] = npcs[npc.id]
        end
    end,

    ----------------------------------------------------------------------------------------------------------
    -- Sets the frame which will show the skills obtainable from the selected npc
    --
    -- @skill_list_frame        Object      The frame to show theskills obtainable from the selected item
    ----------------------------------------------------------------------------------------------------------
    SetSkillListFrame = function(self, skill_list_frame)
        self.skill_list_frame = skill_list_frame
    end,

    ----------------------------------------------------------------------------------------------------------
    -- Updates the list of MissingNpcsListFrame
    ----------------------------------------------------------------------------------------------------------
    UpdateList = function (self)
        self.shown_npcs = self:FilterListOfNpcs()
        self.amount_shown_npcs = MTSL_TOOLS:CountItemsInArray(self.shown_npcs)
        if self.amount_shown_npcs <= 0 then
            self:NoNpcsToShow()
        end

        -- sort the list by name
        MTSL_TOOLS:SortArrayByLocalisedProperty(self.shown_npcs, "name")

        self:UpdateSlider()
        self:UpdateButtons()
    end,

    -- Filter the list of npcs based on realm and/or profession
    FilterListOfNpcs = function(self)
        local filtered_npcs = {}
        -- Loop each available npc
        for _, npc in pairs(self.available_npcs) do
            -- Check name
            local available = self:IsNpcAvailableForName(npc)
            -- if still available, check zone
            if available == true then
                available = self:IsNpcAvailableInZone(npc)
            end
            -- if still available, check rest
            if available == true then
                -- Check if have more then 1 faction (can max be 2 & second faction is always Neutral)
                if self.filter_values["faction"] and string.find(self.filter_values["faction"], '_') then
                    available = self:IsNpcAvailable(npc, string.sub(self.filter_values["faction"], 2)) or self:IsNpcAvailable(npc, "Neutral")
                else
                    available = self:IsNpcAvailable(npc, self.filter_values["faction"])
                end
            end
            -- if passed all filters add to list
            if available == true then
                table.insert(filtered_npcs, npc)
            end
        end

        return filtered_npcs
    end,

    IsNpcAvailableForName = function(self, npc)
        local available = true
        if self.filter_values["npc_name"] and self.filter_values["npc_name"] ~= "" then
            local name = string.lower(MTSLUI_TOOLS:GetLocalisedData(npc))
            local contains = string.lower(self.filter_values["npc_name"])
            local start_index, _ = string.find(name, contains)
            -- if we dont have a start index, the name does not contain the pattern
            if start_index == nil then
                available = false
            end
        end

        return available
    end,

    IsNpcAvailable = function(self, npc)
        -- loop each faction untill we find  the first skill that is available that meets the criteria
        for fk, fv in pairs(npc["enhanced"]) do
            -- Faction is ok
            if self.filter_values["faction"] == "any" or fk == self.filter_values["faction"] then
                -- Check profesions
                for pk, pv in pairs(fv) do
                    -- Profession is ok
                    if self.filter_values["profession"] == "any" or pk == self.filter_values["profession"] then
                        -- Check source type
                        for stk, stv in pairs(pv) do
                            -- Source type is ok
                            if self.filter_values["source"] == "any source" or stk == self.filter_values["source"] then
                                -- Check rank, only if source_type is trainer and rank > 0
                                if self.filter_values["source"] ~= "trainer" or (self.filter_values["source"] == "trainer" and self.filter_values["rank"] <= 0) or
                                    (self.filter_values["source"] == "trainer" and self.filter_values["rank"] > 0 and stv["rank_" .. self.filter_values["rank"]]) then
                                    -- we found a skill so return that NPC is available
                                    return true
                                end
                            end
                        end
                    end
                end
            end
        end

        return false
    end,

    IsNpcAvailableInZone = function (self, npc, zone_id)
        local available = true
        if self.filter_values["zone"] and self.filter_values["zone"] ~= 0 and npc.zone_id ~= self.filter_values["zone"] then
            available = false
        end
        return available
    end,

    UpdateSlider = function(self)
        -- no need for slider
        if self.amount_shown_npcs == nil or self.amount_shown_npcs <= self.MAX_ITEMS_SHOWN_CURRENTLY then
            self.slider_active = 0
            self.slider_offset = 1
            self.ui_frame.slider:Hide()
        else
            self.slider_active = 1
            local max_steps = self.amount_shown_npcs - self.MAX_ITEMS_SHOWN_CURRENTLY + 1
            self.ui_frame.slider:Refresh(max_steps, self.MAX_ITEMS_SHOWN_CURRENTLY)
            self.ui_frame.slider:Show()
        end
    end,

    ----------------------------------------------------------------------------------------------------------
    -- Updates the npcbuttons of MissingNpcsListFrame
    ----------------------------------------------------------------------------------------------------------
    UpdateButtons = function (self)
        local amount_to_show = self.amount_shown_npcs
        -- have more then we can show so limit
        if amount_to_show > self.MAX_ITEMS_SHOWN_CURRENTLY then
            amount_to_show = self.MAX_ITEMS_SHOWN_CURRENTLY
        end
        for i=1,amount_to_show do
            -- minus 1 because offset starts at 1
            local current_npc = self.shown_npcs[i + self.slider_offset - 1]
            -- create the text to be shown
            local text_for_button =  MTSLUI_FONTS.COLORS.AVAILABLE.NORMAL
            if current_npc.xp_level ~= nil and current_npc.xp_level ~= "" and current_npc.xp_level ~= 0 then
                text_for_button = "[" .. current_npc.xp_level["min"]
                -- show range of levels if needed
                if current_npc.xp_level["min"] ~= current_npc.xp_level["max"] then
                    text_for_button = text_for_button .. "-" .. current_npc.xp_level["max"]
                end
                -- add a + for elite
                if current_npc.xp_level.is_elite == 1 then
                    text_for_button = text_for_button .. "+"
                end
                --end the text
                text_for_button = text_for_button .. "] "
            else
                text_for_button = text_for_button .. "[-] "
            end
            -- add localised name & zone
            text_for_button = text_for_button .. MTSLUI_TOOLS:GetLocalisedData(current_npc) .. " - " ..  MTSL_LOGIC_WORLD:GetZoneNameById(current_npc.zone_id)
            -- add coords if known
            if current_npc.location ~= nil and current_npc.location.x ~= "-" and current_npc.location.x ~= "" then
                text_for_button = text_for_button .. " (" .. current_npc.location.x ..", " .. current_npc.location.y ..")"
            end
            -- update & show the button
            self.LIST_BUTTONS[i].text:SetText(text_for_button)
            -- Change texture/faction icon
            self.LIST_BUTTONS[i].texture:SetTexture(self.TEXTURES_FACTION[string.upper(current_npc.reacts)])
            self.LIST_BUTTONS[i]:Show()
            -- Change width of button based on active slider
             self.LIST_BUTTONS[i]:SetSize(self.FRAME_WIDTH - 12 - self.slider_active * 18, self.ITEM_HEIGHT)
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
        self:DeselectCurrentNpcButton()
        -- Clicked on same button so deselect it
        if self.LIST_BUTTONS[id]:IsSelected() == true then
            self.selected_list_item_index = nil
            self.selected_list_item_id = nil
            self.selected_button_index = nil
        else
            -- Subtract 1 because index starts at 1 instead of 0
            self.selected_list_item_index = self.slider_offset + id - 1
            if self.amount_shown_npcs >= self.selected_list_item_index then
                -- update the index of selected button
                self.selected_button_index = id
                self:SelectCurrentNpcButton()
                -- Show the information of the selected npc
                local selected_npc = MTSL_TOOLS:GetItemFromNamedListByIndex(self.shown_npcs, self.selected_list_item_index)
                if selected_npc ~= nil and self.skill_list_frame ~= nil then
                    self.selected_list_item_id = id
                    -- cant select item so deselect details
                    self.skill_list_frame:UpdateList(self.available_npc_skills[selected_npc.id])
                else
                    if self.skill_list_frame then self.skill_list_frame:NoSkillsToShow() end
                end
            else
                if self.skill_list_frame then self.skill_list_frame:NoSkillsToShow() end
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
                self:DeselectCurrentNpcButton()
                -- adjust index of the selected npc in the list
                local scroll_gap = offset - self.slider_offset
                if self.selected_list_item_index ~= nil then
                   self.selected_list_item_index = self.selected_list_item_index - scroll_gap
                end
                if self.selected_button_index ~= nil then
                   self.selected_button_index = self.selected_button_index - scroll_gap
                end

                -- Select the current button if visible
                self:SelectCurrentNpcButton()
                -- scrolled of screen so remove selected id
                if self.selected_button_index == nil or self.selected_button_index < 1 or self.selected_button_index > self.MAX_ITEMS_SHOWN_CURRENTLY then
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
    NoNpcsToShow = function(self)
        -- dselect current npc & button
        self:DeselectCurrentNpcButton()
        self.selected_list_item_index = nil
        self.selected_list_item_id = nil
        self.selected_button_index = nil
        -- pass it trough to the detail frame
        if self.skill_list_frame ~= nil then self.skill_list_frame:NoSkillsToShow() end
    end,

    ----------------------------------------------------------------------------------------------------------
    -- reset the position of the scroll bar & deselect current npc
    ----------------------------------------------------------------------------------------------------------
    Reset = function(self)
        -- dselect current npc & button
        self:DeselectCurrentNpcButton()
        self.selected_list_item_index = nil
        self.selected_list_item_id = nil
        self.selected_button_index = nil
        -- Scroll all way to top
        self:HandleScrollEvent(1)
    end,

    ----------------------------------------------------------------------------------------------------------
    -- Selects the current selected npcbuton
    ----------------------------------------------------------------------------------------------------------
    SelectCurrentNpcButton = function (self)
        if self.selected_button_index ~= nil and
                self.selected_button_index >= 1 and
                self.selected_button_index <= self.MAX_ITEMS_SHOWN_CURRENTLY then
            self.LIST_BUTTONS[self.selected_button_index]:Select()
        end
    end,

    ----------------------------------------------------------------------------------------------------------
    -- Deselects the current selected npcbuton
    ----------------------------------------------------------------------------------------------------------
    DeselectCurrentNpcButton = function (self)
        if self.selected_button_index ~= nil and
                self.selected_button_index >= 1 and
                self.selected_button_index <= self.MAX_ITEMS_SHOWN_CURRENTLY then
            self.LIST_BUTTONS[self.selected_button_index]:Deselect()
        end
    end,

    ----------------------------------------------------------------------------------------------------------
    -- To see if we have a npc selected or not
    ----------------------------------------------------------------------------------------------------------
    HasNpcSelected = function(self)
        return self.selected_list_item_id ~= nil
    end,

    ----------------------------------------------------------------------------------------------------------
    -- Change the name of npc searched for
    ----------------------------------------------------------------------------------------------------------
    ChangeFilters = function(self, filters)
        self.filter_values = filters
        self:RefreshList()
    end,

    ----------------------------------------------------------------------------------------------------------
    -- Refresh the contents of the list after changing zone
    ----------------------------------------------------------------------------------------------------------
    RefreshList = function(self)
        self:DeselectCurrentNpcButton()
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
        self.FRAME_HEIGHT = self.FRAME_HEIGHT_VERTICAL
        self:RefreshUI()
    end,

    -- Switch to horizontal split layout
    ResizeToHorizontalMode = function(self)
        -- adjust max items shown
        self.MAX_ITEMS_SHOWN_CURRENTLY = self.MAX_ITEMS_SHOWN_HORIZONTAL
        self.FRAME_HEIGHT = self.FRAME_HEIGHT_HORIZONTAL
        self:RefreshUI()
    end,

    -- Refresh the UI based on the splitter (only to be called from Resize methode in this class)
    RefreshUI = function(self)
        self.ui_frame:SetSize(self.FRAME_WIDTH, self.FRAME_HEIGHT)

        -- refrehs/update ui only if window is shown
        if self.ui_frame:IsVisible() then
            self:RefreshList()
        else
            self:UpdateSlider()
        end
    end,
}
