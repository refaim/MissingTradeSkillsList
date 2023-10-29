------------------------------------------------------------------
-- Name: ResetFrame                                             --
-- Description: Reset all data or a character                   --
-- Parent Frame: OptionsMenuFrame                               --
------------------------------------------------------------------

---@class MTSLOPTUI_RESET_FRAME
MTSLOPTUI_RESET_FRAME = {
    FRAME_HEIGHT = 90,
    BUTTON_WIDTH = 200,
    BUTTON_HEIGHT = 29,

    current_realm = nil,
    current_player = nil,

    ---------------------------------------------------------------------------------------
    -- Initialises the titleframe
    ----------------------------------------------------------------------------------------
    Initialise = function(self, parent_frame)
        self.FRAME_WIDTH = MTSLUI_OPTIONS_MENU_FRAME.FRAME_WIDTH
        self.ui_frame = MTSLUI_TOOLS:CreateBaseFrame("Frame", "MTSLOPTUI_SaveFrame", parent_frame, nil, self.FRAME_WIDTH, self.FRAME_HEIGHT, false)
        -- below config frame
        self.ui_frame:SetPoint("TOPLEFT", parent_frame, "BOTTOMLEFT", 0, 0)
        -- create list of realms & list with players on a realm
        self:BuildRealmList()
        self:BuildPlayersOnCurrentRealmList()

        self.ui_frame.realm_text = MTSLUI_TOOLS:CreateLabel(self.ui_frame, MTSLUI_TOOLS:GetLocalisedLabel("realm"), 22, -30, "LABEL", "TOPLEFT")
        -- add drop down list for realm & characters
        self.ui_frame.realm_drop_down = CreateFrame("Frame", "MTSLOPTUI_RESET_FRAME_DD_REALM", self.ui_frame, "UIDropDownMenuTemplate")
        self.ui_frame.realm_drop_down:SetPoint("TOPLEFT", self.ui_frame, "TOPLEFT", 70, -22)
        self.ui_frame.realm_drop_down.initialize = MTSL_TOOLS:BindArgument(self.CreateDropDownRealms, self)
        UIDropDownMenu_SetWidth(150, self.ui_frame.realm_drop_down)
        UIDropDownMenu_SetText(self.current_realm, self.ui_frame.realm_drop_down)

        self.ui_frame.player_text = MTSLUI_TOOLS:CreateLabel(self.ui_frame, MTSLUI_TOOLS:GetLocalisedLabel("character"), 280, -30, "LABEL", "TOPLEFT")
        self.ui_frame.player_drop_down = CreateFrame("Frame", "MTSLOPTUI_RESET_FRAME_DD_PLAYER", self.ui_frame, "UIDropDownMenuTemplate")
        self.ui_frame.player_drop_down:SetPoint("TOPLEFT", self.ui_frame.realm_drop_down, "TOPRIGHT", 65, 0)
        self.ui_frame.player_drop_down.initialize = MTSL_TOOLS:BindArgument(self.CreateDropDownPlayersOnRealm, self)
        UIDropDownMenu_SetWidth(150, self.ui_frame.player_drop_down)
        UIDropDownMenu_SetText(self.current_player, self.ui_frame.player_drop_down)

        -- calculate position
        local left = MTSLUI_OPTIONS_MENU_FRAME.FRAME_WIDTH - 230
        -- Remove character button
        self.remove_btn = MTSLUI_TOOLS:CreateBaseFrame("Button", "MTSLOPTUI_RemoveChar_Button", self.ui_frame, "UIPanelButtonTemplate", self.BUTTON_WIDTH - 50, self.BUTTON_HEIGHT)
        self.remove_btn:SetPoint("TOPLEFT", self.ui_frame, "TOPLEFT", left + 50, -21)
        self.remove_btn:SetText(MTSLUI_TOOLS:GetLocalisedLabel("delete"))
        self.remove_btn:SetScript("OnClick", function()
            -- only remove if realm & player chosen
            if MTSLOPTUI_RESET_FRAME.current_realm ~= nil and MTSLOPTUI_RESET_FRAME.current_player ~= nil then
                -- If delete was succesfull, refresh the list
                if MTSL_LOGIC_SAVED_VARIABLES:RemoveCharacter(MTSLOPTUI_RESET_FRAME.current_player, MTSLOPTUI_RESET_FRAME.current_realm) then
                    -- If no other chars on realm, update realm dropdown first
                    if MTSL_LOGIC_PLAYER_NPC:CountPlayersOnRealm(MTSLOPTUI_RESET_FRAME.current_realm) <= 0 then
                        MTSLOPTUI_RESET_FRAME.current_realm = nil
                        MTSLOPTUI_RESET_FRAME:CreateDropDownRealms(1)
                    end
                    -- if we removed last char, nothing left
                    if MTSLOPTUI_RESET_FRAME.current_realm ~= nil then
                        UIDropDownMenu_SetText(MTSLOPTUI_RESET_FRAME.current_realm, MTSLOPTUI_RESET_FRAME.ui_frame.realm_drop_down)
                        -- Rebuild player dropdown
                        MTSLOPTUI_RESET_FRAME:CreateDropDownPlayersOnRealm(1)
                        UIDropDownMenu_SetText(MTSLOPTUI_RESET_FRAME.current_player, MTSLOPTUI_RESET_FRAME.ui_frame.player_drop_down)
                    else
                        UIDropDownMenu_SetText("", MTSLOPTUI_RESET_FRAME.ui_frame.realm_drop_down)
                        UIDropDownMenu_SetText("", MTSLOPTUI_RESET_FRAME.ui_frame.player_drop_down)
                    end
                end
            end
        end)
        -- Reset all
        self.ui_frame.reset_text = MTSLUI_TOOLS:CreateLabel(self.ui_frame, MTSLUI_FONTS.COLORS.TEXT.ERROR .. MTSLUI_TOOLS:GetLocalisedLabel("permanent"), 25, -75, "TITLE", "TOPLEFT")
        self.reset_btn = MTSLUI_TOOLS:CreateBaseFrame("Button", "MTSLOPTUI_ResetAll_Button", self.ui_frame, "UIPanelButtonTemplate", self.BUTTON_WIDTH + 50, self.BUTTON_HEIGHT)
        self.reset_btn:SetPoint("TOPLEFT", self.ui_frame, "TOPLEFT", left - 50, -65)
        self.reset_btn:SetText(MTSLUI_TOOLS:GetLocalisedLabel("delete all"))
        self.reset_btn:SetScript("OnClick", function()
            MTSL_LOGIC_SAVED_VARIABLES:RemoveAllCharacters()
        end)
    end,

    ----------------------------------------------------------------------------------------------------------
    -- Build a list of realms with at least one character
    ----------------------------------------------------------------------------------------------------------
    BuildRealmList = function(self)
        self.realms = {}
        for k, _ in pairs(MTSL_PLAYERS) do
            -- only add if actual players are found on the realm
            if MTSL_LOGIC_PLAYER_NPC:CountPlayersOnRealm(k) > 0 then
                local new_realm = {
                    ["name"] = k,
                    ["id"] = k
                }
                table.insert(self.realms, new_realm)
            end
        end
        -- sort on realm name
        MTSL_TOOLS:SortArrayByProperty(self.realms, "name")
        -- build list for "first" realm
        if MTSL_TOOLS:CountItemsInArray(self.realms) <= 0 and self.ui_frame.realm_drop_down ~= nil then
            self.player_on_realms = {}
        -- Auto select first one if none yet selected
        elseif self.current_realm == nil then
            local _, realm = next(self.realms)
            self.current_realm = realm.name
        end
    end,

    ----------------------------------------------------------------------------------------------------------
    -- Build a list of players for current realm
    ----------------------------------------------------------------------------------------------------------
    BuildPlayersOnCurrentRealmList = function(self)
        self.player_on_realms = {}
        if self.current_realm ~= nil and MTSL_PLAYERS[self.current_realm] ~= nil then
            for k, _ in pairs(MTSL_PLAYERS[self.current_realm]) do
                local new_player = {
                    ["name"] = k,
                    ["id"] = k
                }
                table.insert(self.player_on_realms, new_player)
            end
            -- sort on player name
            MTSL_TOOLS:SortArrayByProperty(self.player_on_realms, "name")
            -- Auto select first one
            local _, player = next(self.player_on_realms)
            self.current_player = player.name
        end
    end,

    ----------------------------------------------------------------------------------------------------------
    -- Intialises drop down for players on a realm
    ----------------------------------------------------------------------------------------------------------
    CreateDropDownRealms = function(self, level)
        MTSLOPTUI_RESET_FRAME:BuildRealmList()
        MTSLUI_TOOLS:FillDropDown(MTSLOPTUI_RESET_FRAME.realms, MTSLOPTUI_RESET_FRAME.ChangeRealmHandler)
    end,

    --------------------------------------------------------------------------------------
    -- Handles DropDown Change event after changing the realm
    ----------------------------------------------------------------------------------------------------------
    ChangeRealmHandler = function(value, text)
        -- only act if we select a new realm
        if text ~= nil and text ~= MTSLOPTUI_RESET_FRAME.current_realm then
            MTSLOPTUI_RESET_FRAME:ChangeRealm(value, text)
        end
    end,

    ChangeRealm = function(self, realm_id, realm_name)
        self.current_realm = realm_name
        UIDropDownMenu_SetText(realm_name, self.ui_frame.realm_drop_down)
        -- changed realm so update player list
        self.current_player = nil
        self:CreateDropDownPlayersOnRealm(1)
        -- update the text in dropdown
        UIDropDownMenu_SetText(self.current_player, self.ui_frame.player_drop_down)
    end,

    ----------------------------------------------------------------------------------------------------------
    -- Intialises drop down for players on a realm
    ----------------------------------------------------------------------------------------------------------
    CreateDropDownPlayersOnRealm = function(self, level)
        MTSLOPTUI_RESET_FRAME:BuildPlayersOnCurrentRealmList()
        MTSLUI_TOOLS:FillDropDown(MTSLOPTUI_RESET_FRAME.player_on_realms, MTSLOPTUI_RESET_FRAME.ChangePlayersOnRealmHandler)
    end,

    --------------------------------------------------------------------------------------
    -- Handles DropDown Change event after changing the player on the current realm
    ----------------------------------------------------------------------------------------------------------
    ChangePlayersOnRealmHandler = function(value, text)
        -- only act if we select a new player
        if value ~= nil and value ~= MTSLOPTUI_RESET_FRAME.current_player then
            MTSLOPTUI_RESET_FRAME:ChangePlayer(value, text)
        end
    end,

    ChangePlayer = function(self, value, text)
        self.current_player = text
        UIDropDownMenu_SetText(text, self.ui_frame.player_drop_down)
    end,

    -- Try to select the current logged in player in the drop down
    SelectCurrentPlayer = function(self)
        -- only select if we have the realm
        if MTSL_TOOLS:GetItemFromArrayByKeyValue(self.realms, "id", MTSL_CURRENT_PLAYER.REALM) then
            self:ChangeRealm(MTSL_CURRENT_PLAYER.REALM, MTSL_CURRENT_PLAYER.REALM)
            -- only select player if present on the realm
            if MTSL_TOOLS:GetItemFromArrayByKeyValue(self.player_on_realms, "id", MTSL_CURRENT_PLAYER.NAME) then
                self:ChangePlayer(MTSL_CURRENT_PLAYER.NAME, MTSL_CURRENT_PLAYER.NAME)
            end
        end
    end,
}
