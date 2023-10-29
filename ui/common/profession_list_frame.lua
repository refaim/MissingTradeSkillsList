----------------------------------------------------------------------------------
-- Name: ProfessionListFrame                                                    --
-- Description: Shows available professions in the MTSL database                --
-- Parent Frame: DatabaseFrame                                                  --
----------------------------------------------------------------------------------

---@class MTSLUI_PROFESSION_LIST_FRAME
MTSLUI_PROFESSION_LIST_FRAME = {
    -- Keeps the current created frame
    ui_frame = nil,
    -- height of an item to select in the list
    ITEM_HEIGHT = 36,
    -- width of the frame
    FRAME_WIDTH = 66,
    -- height of the frame
    FRAME_HEIGHT = 465,
    selected_index = nil,
}

function MTSLUI_PROFESSION_LIST_FRAME:Initialise(parent_frame, frame_name)
    -- container frame (no scroll
    self.ui_frame = MTSLUI_TOOLS:CreateBaseFrame("Frame", "", parent_frame, nil, self.FRAME_WIDTH, self.FRAME_HEIGHT, false)
    -- default database wide
    self:ChangeNoPlayer()
    -- Create the background frames for the buttons
    self.PROF_BGS = {}
    -- Create the buttons
    self.PROF_BUTTONS = {}
    local top = -2
    local i = 1
    while self.shown_professions[i] ~= nil do
        -- create background frame
        local bg_frame = MTSLUI_TOOLS:CreateBaseFrame("Frame", "", self.ui_frame, nil, self.FRAME_WIDTH + 1, self.ITEM_HEIGHT + 5, true)
        -- yellow border & transparant fill
        bg_frame:SetBackdropColor(1, 1, 0, 0.40)
        bg_frame:SetBackdropBorderColor(1, 1, 0, 1)
        bg_frame:SetPoint("TOPLEFT", self.ui_frame, "TOPLEFT", 0, top + 5)
        -- hide on create
        bg_frame:Hide()
        table.insert(self.PROF_BGS, bg_frame)
        -- Create a new list item (button) by making a copy of MTSLUI_LIST_ITEM
        local skill_button = self:CreateProfessionButton(frame_name .. "_BTN_PROF_"..i, i)
        skill_button:SetPoint("CENTER", bg_frame, "CENTER", 0, 6)
        -- adjust top position for next button
        top = top - self.ITEM_HEIGHT
        -- add button to list
        table.insert(self.PROF_BUTTONS, skill_button)

        local skills_amount = MTSL_LOGIC_PROFESSION:GetTotalNumberOfAvailableSkillsForProfession(self.shown_professions[i], {})
        skill_button.text = MTSLUI_TOOLS:CreateLabel(skill_button, tostring(skills_amount), 0, -12, "LABEL", "BOTTOM")

        i = i + 1
    end
end

function MTSLUI_PROFESSION_LIST_FRAME:SetFilterFrame(filter_frame)
    self.filter_frame = filter_frame
end

function MTSLUI_PROFESSION_LIST_FRAME:SetListFrame(list_item_frame)
    self.list_item_frame = list_item_frame
end

function MTSLUI_PROFESSION_LIST_FRAME:CreateProfessionButton(name, i)
    local event_class = self
    -- Create the button:
    local button = CreateFrame("Button", name, event_class.ui_frame)
    button:SetWidth(21)
    button:SetHeight(21)
    -- Add the icon:
    local icon = button:CreateTexture(nil, "ARTWORK")
    icon:SetAllPoints(true)
    icon:SetTexture(MTSLUI_PROFESSION_TEXTURES[self.shown_professions[i]])
    button.icon = icon

    button:SetScript("OnClick", function()
        event_class:HandleSelectedListItem(i)
    end)
    return button
end

function MTSLUI_PROFESSION_LIST_FRAME:ChangePlayer(player_name, player_realm)
    self.current_player = MTSL_LOGIC_PLAYER_NPC:GetPlayerOnRealm(player_name, player_realm)
    -- remove current selected profession, to force update later
    self.selected_index = nil
    self.list_item_frame.profession_name = nil
    local professions_to_show = MTSL_LOGIC_PLAYER_NPC:GetKnownProfessionsForPlayer(player_realm, player_name)
    self:UpdateProfessions(professions_to_show)
end

function MTSLUI_PROFESSION_LIST_FRAME:ChangeNoPlayer()
    self.shown_professions = {}
    for k, _ in pairs(TRADE_SKILLS_DATA["professions"]) do
        table.insert(self.shown_professions, k)
    end
    self.current_player = nil
    -- remove current selected profession, to force update later
    self.selected_index = nil
    if self.list_item_frame then
        self.list_item_frame.profession_name = nil
        self:UpdateProfessions(self.shown_professions)
    end
end

function MTSLUI_PROFESSION_LIST_FRAME:UpdateProfessions(professions)
    -- Get the localised name for each profession
    local localised_prof_names = {}
    if professions ~= nil then
        for _, k in pairs(professions) do
            local localised_prof_name = MTSL_LOGIC_PROFESSION:GetLocalisedProfessionNameFromEnglishName(k)
            table.insert(localised_prof_names, localised_prof_name)
        end
    end
    localised_prof_names = MTSL_TOOLS:SortArray(localised_prof_names)
    -- Convert sorted array back to English names
    local english_prof_names = {}
    for _, k in pairs(localised_prof_names) do
        table.insert(english_prof_names, MTSL_LOGIC_PROFESSION:GetEnglishProfessionNameFromLocalisedName(k))
    end
    -- sort the list
    self.shown_professions = english_prof_names

    local first_button_shown = 0
    if self.shown_professions ~= nil and not MTSL_TOOLS:TableEmpty(self.shown_professions) then
        local top = -2
        local i = 1
        while self.PROF_BUTTONS[i] ~= nil do
            self.PROF_BGS[i]:Hide()
            if self.shown_professions[i] ~= nil then
                self.PROF_BGS[i]:SetPoint("TOPLEFT", self.ui_frame, "TOPLEFT", 0, top + 5)
                self.PROF_BUTTONS[i].icon:SetTexture(MTSLUI_PROFESSION_TEXTURES[self.shown_professions[i]])
                self.PROF_BUTTONS[i]:SetPoint("CENTER", self.PROF_BGS[i], "CENTER", 0, 6)
                -- update date text best on player or overall
                if self.current_player ~= nil then
                    self.PROF_BUTTONS[i].text:SetText(MTSL_LOGIC_PLAYER_NPC:GetAmountOfLearnedSkillsForProfession(self.current_player.NAME, self.current_player.REALM, self.shown_professions[i]))
                    -- show all overall
                else
                    local skills_amount = MTSL_LOGIC_PROFESSION:GetTotalNumberOfAvailableSkillsForProfession(self.shown_professions[i], {})
                    self.PROF_BUTTONS[i].text:SetText(tostring(skills_amount))
                end
                self.PROF_BUTTONS[i]:Show()
                top = top - self.ITEM_HEIGHT
                if first_button_shown == 0 then
                    first_button_shown = i
                end
            else
                self.PROF_BUTTONS[i]:Hide()
            end
            i = i + 1
        end
    else
        local i = 1
        while self.PROF_BUTTONS[i] ~= nil do
            self.PROF_BGS[i]:Hide()
            self.PROF_BUTTONS[i]:Hide()
            i = i + 1
        end
    end
    -- Auto click/select first profession/button if possible
    if first_button_shown > 0 then
        self:HandleSelectedListItem(first_button_shown)
        -- enabke the effects of filtering
        self.filter_frame:EnableFiltering()
        --nothing to select so clear detail screen
    else
        self.selected_index = nil
        -- disable the effects of filtering
        self.filter_frame:DisableFiltering()
        -- clear the shown contents
        self.list_item_frame:UpdateList(nil)
        self.list_item_frame:NoSkillsToShow()
    end
end

function MTSLUI_PROFESSION_LIST_FRAME:UpdateButtonsToShowAmountMissingSkills()
    local i = 1
    while self.PROF_BUTTONS[i] ~= nil do
        if self.shown_professions[i] ~= nil then
            local title_text = MTSL_LOGIC_PLAYER_NPC:GetAmountMissingSkillsForProfessionCurrentPlayer(self.shown_professions[i])
            self.PROF_BUTTONS[i].text:SetText(title_text)
        end
        i = i + 1
    end
end

function MTSLUI_PROFESSION_LIST_FRAME:HandleSelectedListItem(index)
    -- only change if we selected a new profession
    if self.selected_index ~= index then
        -- Deselect the old BG_Frame by hiding it
        if self.selected_index ~= nil then
            self.PROF_BGS[self.selected_index]:Hide()
        end
        self.selected_index = index
        self.PROF_BGS[self.selected_index]:Show()

        local prof_skills
        -- Get all available skills for the profession if no player is selected
        if self.current_player == nil then
            prof_skills = MTSL_LOGIC_PROFESSION:GetAllSkillsAndLevelsForProfession(self.shown_professions[index])
        -- get the known skills for the current player
        else
            prof_skills = MTSL_LOGIC_PLAYER_NPC:GetLearnedSkillsForPlayerForProfession(self.current_player.NAME, self.current_player.REALM, self.shown_professions[index])
        end
        if self.filter_frame ~= nil then
            self.filter_frame:ChangeProfession(self.shown_professions[index])
        end
        self.list_item_frame:ChangeProfession(self.shown_professions[index], prof_skills)
    end
end

function MTSLUI_PROFESSION_LIST_FRAME:GetCurrentProfession()
    if self.selected_index ~= nil and self.shown_professions[self.selected_index] ~= nil then
        return self.shown_professions[self.selected_index]
    end
    return "Any"
end

function MTSLUI_PROFESSION_LIST_FRAME:ShowNoProfessions()
    self:UpdateProfessions(nil)
end
