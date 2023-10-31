---@alias MTSLUI_ProfessionListPlayer {NAME: string, REALM: string}

---@class MTSLUI_ProfessionList
---@field __FRAME_WIDTH number
---@field __FRAME_HEIGHT number
---@field __ITEM_HEIGHT number
---@field __ui_frame Frame
---@field __button_pool MTSL_ObjectPool<MTSLUI_ProfessionListButton>
---@field __displayed_buttons MTSLUI_ProfessionListButton[]
---@field filter_frame MTSLUI_FILTER_FRAME
---@field list_item_frame MTSLUI_LIST_FRAME
---@field __player MTSLUI_ProfessionListPlayer|nil
---@field __selected_profession ProfessionId|nil
MTSLUI_ProfessionList = {
    __FRAME_WIDTH = 66,
    __FRAME_HEIGHT = 465,
    __ITEM_HEIGHT = 36,
    __displayed_buttons = {},
    __player = nil,
    __selected_profession = nil, -- TODO set
}

function MTSLUI_ProfessionList:Initialise(parent_frame, filter_frame, list_frame)
    self.filter_frame = filter_frame
    self.list_item_frame = list_frame

    self.__ui_frame = MTSLUI_TOOLS:CreateBaseFrame("Frame", nil, parent_frame, nil, self.__FRAME_WIDTH, self.__FRAME_HEIGHT, false)

    self.__button_pool = MTSL_TOOLS:CopyObject(--[[---@type MTSL_ObjectPool<MTSLUI_ProfessionListButton>]] MTSL_ObjectPool)
    self.__button_pool:Construct(MTSLUI_ProfessionListButton)

    --self:SetPlayer(nil) --TODO это надо убрать
end

---@return Frame
function MTSLUI_ProfessionList:GetFrame()
    return self.__ui_frame
end

---@param player MTSLUI_ProfessionListPlayer|nil
function MTSLUI_ProfessionList:SetPlayer(player)
    self.__player = player
    self:__Render()
end

function MTSLUI_ProfessionList:__Render()
    local professions = {}
    if self.__player ~= nil then
        local player = --[[---@type MTSLUI_ProfessionListPlayer]] self.__player
        professions = MTSL_LOGIC_PLAYER_NPC:GetKnownProfessionsForPlayer(player.REALM, player.NAME)
    else
        for k, _ in pairs(TRADE_SKILLS_DATA["professions"]) do
            tinsert(professions, k)
        end
    end
    MTSL_TOOLS:SortArray(professions)

    self:__RenderButtons(professions)

    if getn(professions) > 0 then
        -- self:HandleSelectedListItem(first_button_shown) TODO
        self.filter_frame:EnableFiltering()
    else
        self.filter_frame:DisableFiltering()
        self.list_item_frame:UpdateList(nil)
        self.list_item_frame:NoSkillsToShow()
    end

    --if self.list_item_frame ~= nil then
    --    self.list_item_frame.profession_name = nil --TODO ZALEPA
    --end
end

---@param professions ProfessionId[]
function MTSLUI_ProfessionList:__RenderButtons(professions) -- TODO передавать сюда сразу и число навыков для каждой профессии, которое надо вывести
    for _, button in self.__displayed_buttons do
        self.__button_pool:Release(button)
    end

    local top = -2
    for _, profession in professions do
        local button = self.__button_pool:Get()
        local texture = MTSLUI_PROFESSION_TEXTURES[profession]
        button:Initialise(self.__FRAME_WIDTH, self.__ITEM_HEIGHT, texture, function () end) --TODO onclick !!!

        if profession == self.__selected_profession then
            button:Select()
        end

        local button_frame = button:GetUserInterfaceFrame()
        button_frame:SetPoint("TOPLEFT", self.__ui_frame, "TOPLEFT", 0, top + 5)
        top = top - self.__ITEM_HEIGHT

        --            if self.current_player ~= nil then
        --                self.__buttons[i].text:SetText(MTSL_LOGIC_PLAYER_NPC:GetAmountOfLearnedSkillsForProfession(self.current_player.NAME, self.current_player.REALM, self.__shown_professions[i]))
        --                -- show all overall
        --            else
        --                local skills_amount = MTSL_LOGIC_PROFESSION:GetTotalNumberOfAvailableSkillsForProfession(self.__shown_professions[i], {})
        --                self.__buttons[i].text:SetText(tostring(skills_amount))
        --            end

        tinsert(self.__displayed_buttons, button)
    end

    -- TODO если ничего не выбрано, то выбрать первую
end

function MTSLUI_ProfessionList:__OnProfessionSelect()

end

function MTSLUI_ProfessionList:UpdateButtonsToShowAmountMissingSkills()
    --local i = 1
    --while self.__buttons[i] ~= nil do
    --    if self.__shown_professions[i] ~= nil then
    --        local title_text = MTSL_LOGIC_PLAYER_NPC:GetAmountMissingSkillsForProfessionCurrentPlayer(self.__shown_professions[i])
    --        self.__buttons[i].text:SetText(title_text)
    --    end
    --    i = i + 1
    --end
end

---@param index number
function MTSLUI_ProfessionList:HandleSelectedListItem(index)
    ---- only change if we selected a new profession
    --if self.selected_index ~= index then
    --    -- Deselect the old BG_Frame by hiding it
    --    if self.selected_index ~= nil then
    --        self.__button_backgrounds[self.selected_index]:Hide()
    --    end
    --    self.selected_index = index
    --    self.__button_backgrounds[self.selected_index]:Show()
    --
    --    local prof_skills
    --    -- Get all available skills for the profession if no player is selected
    --    if self.current_player == nil then
    --        prof_skills = MTSL_LOGIC_PROFESSION:GetAllSkillsAndLevelsForProfession(self.__shown_professions[index])
    --        -- get the known skills for the current player
    --    else
    --        prof_skills = MTSL_LOGIC_PLAYER_NPC:GetLearnedSkillsForPlayerForProfession(self.current_player.NAME, self.current_player.REALM, self.__shown_professions[index])
    --    end
    --    if self.filter_frame ~= nil then
    --        self.filter_frame:ChangeProfession(self.__shown_professions[index])
    --    end
    --    self.list_item_frame:ChangeProfession(self.__shown_professions[index], prof_skills)
    --end
end

function MTSLUI_ProfessionList:GetCurrentProfession()
    --if self.selected_index ~= nil and self.__shown_professions[self.selected_index] ~= nil then
    --    return self.__shown_professions[self.selected_index]
    --end
    return "Any"
end

function MTSLUI_ProfessionList:ShowNoProfessions()
    self:UpdateProfessions(nil)
end
