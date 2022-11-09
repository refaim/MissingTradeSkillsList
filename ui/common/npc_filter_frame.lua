-----------------------------------------------------------
-- Name: NpcFilterFrame                                  --
-- Description: Shows all the filters for a list of npcs --
-- Parent Frame: NpcExplorerFrame                        --
-----------------------------------------------------------

MTSLUI_NPC_FILTER_FRAME = {
    -- Keeps the current created frame
    ui_frame,
    -- width of the frame (only 1 width needed since vertical & horizontal mode does not stretch this)
    FRAME_WIDTH = 450, -- 385,
    -- height of the frame
    FRAME_HEIGHT = 110,
    current_rank,
    ranks = {},
    -- all contintents
    continents = {},
    -- all zones for each contintent
    zones_in_continent = {},
    -- all zones for the current continent
    current_available_zones = {},
    current_continent_id,
    current_zone_id,
    -- current specialisation for profession
    current_profession,
    -- all ranks for the current source type (only used for trainer)
    current_available_ranks = {},
    -- source type to show
    current_source_type,
    -- widths of the drops downs according to layout
    WIDTH_DD = 206, --173, -- (+/- half of the width of frame)
    -- widths of the search box according to layout
    WIDTH_TF = 335, --268,
    -- Filtering active (flag indicating if changing drop downs has effect, default on)
    filtering_active = 1,
    -- array holding the values of the current filters
    filter_values = {
        npc_name,
        faction,
        profession,
        source,
        rank,
        continent,
        zone,
    },

    ----------------------------------------------------------------------------------------------------------
    -- Intialises the MissingSkillsListFrame
    --
    -- @parent_frame        Frame       The parent frame
    ----------------------------------------------------------------------------------------------------------
    Initialise = function(self, parent_frame, filter_frame_name)
        self.filter_frame_name = filter_frame_name
        self:InitialiseData()
        -- create the container frame
        self.ui_frame = MTSLUI_TOOLS:CreateBaseFrame("Frame", "", parent_frame, nil, self.FRAME_WIDTH, self.FRAME_HEIGHT, false)
        -- Initialise each row of the filter frame
        self:InitialiseFirstRow()
        self:InitialiseSecondRow()
        self:InitialiseThirdRow()
        self:InitialiseFourthRow()
        -- save name of each DropDown for access when resizing later
        self.drop_down_names = { "_DD_FACTIONS", "_DD_PROFS", "_DD_SOURCES", "_DD_RANKS", "_DD_CONTS", "_DD_ZONES" }
        -- add it to global vars to access later on
        _G[filter_frame_name] = self
        self:ResizeToVerticalMode()
    end,

    ----------------------------------------------------------------------------------------------------------
    -- First row of the filter frame = search bar + button
    ----------------------------------------------------------------------------------------------------------
    InitialiseFirstRow = function (self)
        -- Search box with button
        self.ui_frame.search_box = CreateFrame("EditBox", self.filter_frame_name .. "_TF", self.ui_frame)
        self.ui_frame.search_box:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true,
            tileSize = 16,
            edgeSize = 16,
            insets = { left = 4, right = 4, top = 4, bottom = 4 }
        })
        --  Black background
        self.ui_frame.search_box:SetBackdropColor(0,0,0,1)
        -- make cursor appear in the textbox
        self.ui_frame.search_box:SetTextInsets(6, 0, 0, 0)
        self.ui_frame.search_box:SetWidth(self.WIDTH_TF)
        self.ui_frame.search_box:SetHeight(24)
        self.ui_frame.search_box:SetMultiLine(false)
        self.ui_frame.search_box:SetAutoFocus(false)
        self.ui_frame.search_box:SetMaxLetters(40)
        self.ui_frame.search_box:SetFontObject(GameFontNormal)
        -- search by pressing "enter"
        self.ui_frame.search_box:SetScript("OnEnterPressed", function() _G[self.filter_frame_name]:SearchNpcsByName() end)
        self.ui_frame.search_btn = MTSLUI_TOOLS:CreateBaseFrame("Button", "", self.ui_frame, "UIPanelButtonTemplate", 118, 25)
        self.ui_frame.search_btn:SetText(MTSLUI_TOOLS:GetLocalisedLabel("search"))
        self.ui_frame.search_btn:SetScript("OnClick", function() _G[self.filter_frame_name]:SearchNpcsByName() end)
        -- Position the elements
        self.ui_frame.search_box:SetPoint("TOPLEFT", self.ui_frame, "TOPLEFT", 0, 0)
        self.ui_frame.search_btn:SetPoint("TOPLEFT", self.ui_frame.search_box, "TOPRIGHT", -1, 0)
    end,

    ----------------------------------------------------------------------------------------------------------
    -- Second row of the filter frame = drop down factions & drop down profession
    ----------------------------------------------------------------------------------------------------------
    InitialiseSecondRow = function (self)
        -- Factions drop down
        self.ui_frame.faction_drop_down = CreateFrame("Frame", self.filter_frame_name .. "_DD_FACTIONS", self.ui_frame, "UIDropDownMenuTemplate")
        self.ui_frame.faction_drop_down:SetPoint("TOPLEFT", self.ui_frame.search_box, "BOTTOMLEFT", -15, -1)
        self.ui_frame.faction_drop_down.filter_frame_name = self.filter_frame_name
        self.ui_frame.faction_drop_down.initialize = self.CreateDropDownFactions
        UIDropDownMenu_SetText(MTSLUI_TOOLS:GetLocalisedLabel("any faction"), self.ui_frame.faction_drop_down)
        -- Professions
        self.ui_frame.profession_drop_down = CreateFrame("Frame", self.filter_frame_name .. "_DD_PROFS", self.ui_frame, "UIDropDownMenuTemplate")
        self.ui_frame.profession_drop_down:SetPoint("TOPLEFT", self.ui_frame.faction_drop_down, "TOPRIGHT", -31, 0)
        self.ui_frame.profession_drop_down.filter_frame_name = self.filter_frame_name
        self.ui_frame.profession_drop_down.initialize = self.CreateDropDownProfessions
        UIDropDownMenu_SetText(MTSLUI_TOOLS:GetLocalisedLabel("any profession"), self.ui_frame.profession_drop_down)
    end,

    ----------------------------------------------------------------------------------------------------------
    -- Third row of the filter frame = drop down source types & drop down rank
    ----------------------------------------------------------------------------------------------------------
    InitialiseThirdRow = function (self)
        -- create a filter for source type of npc
        self.ui_frame.source_drop_down = CreateFrame("Frame", self.filter_frame_name .. "_DD_SOURCES", self.ui_frame, "UIDropDownMenuTemplate")
        self.ui_frame.source_drop_down:SetPoint("TOPLEFT", self.ui_frame.faction_drop_down, "BOTTOMLEFT", 0, 4)
        self.ui_frame.source_drop_down.filter_frame_name = self.filter_frame_name
        self.ui_frame.source_drop_down.initialize = self.CreateDropDownSources
        UIDropDownMenu_SetText(MTSLUI_TOOLS:GetLocalisedLabel("any source"), self.ui_frame.source_drop_down)
        -- create a filter for rank of trainer
        self.ui_frame.rank_drop_down = CreateFrame("Frame", self.filter_frame_name .. "_DD_RANKS", self.ui_frame, "UIDropDownMenuTemplate")
        self.ui_frame.rank_drop_down:SetPoint("TOPLEFT", self.ui_frame.source_drop_down, "TOPRIGHT", -31, 0)
        self.ui_frame.rank_drop_down.filter_frame_name = self.filter_frame_name
        self.ui_frame.rank_drop_down.initialize = self.CreateDropDownRanks
        UIDropDownMenu_SetText("", self.ui_frame.rank_drop_down)
    end,

    ----------------------------------------------------------------------------------------------------------
    -- Fourth row of the filter frame = drop down continents & drop down zone
    ----------------------------------------------------------------------------------------------------------
    InitialiseFourthRow = function (self)
        -- Continents & zones
        -- Continent more split up with types as well, to reduce number of items shown
        self.ui_frame.continent_drop_down = CreateFrame("Frame", self.filter_frame_name .. "_DD_CONTS", self.ui_frame, "UIDropDownMenuTemplate")
        self.ui_frame.continent_drop_down:SetPoint("TOPLEFT", self.ui_frame.source_drop_down, "BOTTOMLEFT", 0, 4)
        self.ui_frame.continent_drop_down.filter_frame_name = self.filter_frame_name
        self.ui_frame.continent_drop_down.initialize = self.CreateDropDownContinents
        UIDropDownMenu_SetText(MTSLUI_TOOLS:GetLocalisedLabel("any zone"), self.ui_frame.continent_drop_down)
        -- default continent "any" so no need for sub zone to show
        self.ui_frame.zone_drop_down = CreateFrame("Frame", self.filter_frame_name .. "_DD_ZONES", self.ui_frame, "UIDropDownMenuTemplate")
        self.ui_frame.zone_drop_down:SetPoint("TOPLEFT", self.ui_frame.continent_drop_down, "TOPRIGHT", -31, 0)
        self.ui_frame.zone_drop_down.filter_frame_name = self.filter_frame_name
        self.ui_frame.zone_drop_down.initialize = self.CreateDropDownZones
        UIDropDownMenu_SetText("", self.ui_frame.zone_drop_down)
    end,

    -- Initialise the filters to default values
    InitFilters = function (self)
        self.filter_values = {
            npc_name = "",
            faction = "any",
            profession = "any",
            source = "any source",
            rank = -1,
            continent = 0,
            zone = 0,
        }
    end,

    ----------------------------------------------------------------------------------------------------------
    -- Reset the filters to default value (when parent window is hidden/closed)
    ----------------------------------------------------------------------------------------------------------
    ResetFilters = function(self)
        self:InitFilters()
        -- reset name to search
        self.ui_frame.search_box:SetText("")
        self.ui_frame.search_box:ClearFocus()
        -- reset profession
        UIDropDownMenu_SetText(MTSLUI_TOOLS:GetLocalisedLabel("any profession"), self.ui_frame.profession_drop_down)
        -- reset faction
        UIDropDownMenu_SetText(MTSLUI_TOOLS:GetLocalisedLabel("any faction"), self.ui_frame.faction_drop_down)
        -- reset type
        UIDropDownMenu_SetText(MTSLUI_TOOLS:GetLocalisedLabel("any source"), self.ui_frame.source_drop_down)
        UIDropDownMenu_SetText("", self.ui_frame.rank_drop_down)
        -- reset contintent & zone
        UIDropDownMenu_SetText(MTSLUI_TOOLS:GetLocalisedLabel("any zone"), self.ui_frame.continent_drop_down)
        UIDropDownMenu_SetText("", self.ui_frame.zone_drop_down)
        -- set the current filters to the listframe
        if self.list_frame then self.list_frame:ChangeFilters(self.filter_values) end
    end,

    ----------------------------------------------------------------------------------------------------------
    -- Sets the list frame to handle the changes in filter
    ----------------------------------------------------------------------------------------------------------
    SetListFrame = function(self, list_frame)
        self.list_frame = list_frame
        -- set the current filters to the listframe
        self.list_frame:ChangeFilters(self.filter_values)
    end,

    ----------------------------------------------------------------------------------------------------------
    -- Build the fixed arrays with all continents & zones available
    ----------------------------------------------------------------------------------------------------------
    InitialiseData = function(self)
        self:BuildFactions()
        self:BuildProfessions()
        self:BuildSources()
        self:BuildRanks()
        self:BuildContinents()
        self:BuildZones()
    end,

    -- Refresh the label of the current zone (Called after changing zone to a new area in the game EVENT ZONE_NEW_AREA)
    UpdateCurrentZone = function(self, new_zone_name)
        local new_zone = MTSL_LOGIC_WORLD:GetZoneByName(new_zone_name)
        -- only update if we actually found a zone
        if new_zone ~= nil then
            self.continents[2]["name"] = MTSLUI_TOOLS:GetLocalisedLabel("current zone") .. " (" .. new_zone_name
            if new_zone.levels then
                self.continents[2]["name"] = self.continents[2]["name"] .. ", " .. new_zone.levels.min .. "-" .. new_zone.levels.max
            end
            self.continents[2]["name"] = self.continents[2]["name"] .. ")"
            self.continents[2]["id"] = (-1 * new_zone.id)
            -- update text in dropdown itself if current is picked
            if self.current_continent_id == nil and UIDropDownMenu_GetText(self.ui_frame.continent_drop_down) ~= MTSLUI_TOOLS:GetLocalisedLabel("any zone") then
                UIDropDownMenu_SetText(self.continents[2]["name"], self.ui_frame.continent_drop_down)
                self.current_zone_id = new_zone.id
                -- Trigger Refresh
                self.list_frame:ChangeZone(self.current_zone_id)
            end
        end
    end,

    BuildRanks = function(self)
        self.ranks = {
            {
                ["name"] = MTSLUI_TOOLS:GetLocalisedLabel("any rank"),
                ["id"] = 0,
            },
        }
        -- add all ranks
        for _, v in pairs(MTSL_DATA["profession_ranks"]) do
            local new_rank = {
                ["name"] = MTSLUI_TOOLS:GetLocalisedData(v),
                ["id"] = v.id
            }
            table.insert(self.ranks, new_rank)
        end
        local new_rank = {
            ["name"] = MTSLUI_LOCALES_LABELS["specialisation"][MTSLUI_CURRENT_LANGUAGE],
            ["id"] = 5,
        }
        table.insert(self.ranks, new_rank)
    end,

    BuildSources = function(self)
        local source_types = { "any source", "mob", "questgiver", "trainer", "vendor" }
        self.sources = {}
        for _, v in pairs(source_types) do
            local new_source = {
                ["name"] = MTSLUI_TOOLS:GetLocalisedLabel(v),
                ["id"] = v,
            }
            table.insert(self.sources, new_source)
        end
    end,

    BuildFactions = function(self)
        self.factions = {
            {
                ["name"] = MTSLUI_TOOLS:GetLocalisedLabel("any faction"),
                ["id"] = "any",
            },
            -- Mobs have no faction => hostile
            {
                ["name"] = MTSLUI_TOOLS:GetLocalisedLabel("no faction"),
                ["id"] = "Hostile",
            },
            -- Alliance (id: 469)
            {
                ["name"] =  MTSL_LOGIC_FACTION_REPUTATION:GetFactionNameById(469),
                ["id"] = "Alliance",
            },
            -- Horde (id: 67)
            {
                ["name"] =  MTSL_LOGIC_FACTION_REPUTATION:GetFactionNameById(67),
                ["id"] = "Horde",
            },
            -- Neutral (id: 10000)
            {
                ["name"] = MTSLUI_TOOLS:GetLocalisedLabel("neutral"),
                ["id"] = "Neutral",
            },
        }
        -- Ids of reputations used for recipes, add those factions too
        local reputation_ids = { 59, 270, 529, 576, 609 }
        local rep_factions = {}
        for _, v in pairs(reputation_ids) do
            local new_faction = {
                ["name"] = MTSL_LOGIC_FACTION_REPUTATION:GetFactionNameById(v),
                ["id"] =  MTSL_TOOLS:GetItemFromUnsortedListById(MTSL_DATA["factions"], v)["name"]["English"],
            }
           table.insert(rep_factions, new_faction)
        end
        -- Sort them by name
        MTSL_TOOLS:SortArrayByProperty(rep_factions, "name")
        -- Add them sorted to factions
        for _, r in pairs(rep_factions) do
            table.insert(self.factions, r)
        end
    end,

    BuildProfessions = function(self)
        self.professions = {
            {
                ["name"] = MTSLUI_TOOLS:GetLocalisedLabel("any profession"),
                ["id"] = "any",
            },
        }
        -- seperate list first to have em sorted
        local profs = {}
        -- add each profession
        for k, v in pairs(MTSL_DATA["professions"]) do
           local new_profession = {
                ["name"] = v["name"][MTSLUI_CURRENT_LANGUAGE],
                ["id"] = k,
            }
            table.insert(profs, new_profession)
        end

        MTSL_TOOLS:SortArrayByProperty(profs, "name")
        -- Add them sorted
        for _, p in pairs(profs) do
            table.insert(self.professions, p)
        end
    end,

    BuildContinents = function(self)
        -- build the arrays with continents and zones
        self.continents = {
            {
                ["name"] = MTSLUI_TOOLS:GetLocalisedLabel("any zone"),
                ["id"] = 0,
            },
        }
        -- only add current zone if possible (gives trouble while changing zones or not zone not triggering on load)
        local current_zone_name = GetRealZoneText()
        local current_zone = MTSL_LOGIC_WORLD:GetZoneByName(current_zone_name)
        if current_zone ~= nil then
            local zone_filter = {
                ["name"] = MTSLUI_TOOLS:GetLocalisedLabel("current zone") .. " (" .. current_zone_name,
                -- make id negative for filter later on
                ["id"] = (-1 * current_zone.id),
            }
            if current_zone.levels then
                zone_filter["name"] = zone_filter["name"] .. ", " .. current_zone.levels.min .. "-" .. current_zone.levels.max
            end
            zone_filter["name"] = zone_filter["name"] .. ")"
            table.insert(self.continents, zone_filter)
        end
        -- add each type of "continent
        for k, v in pairs(MTSL_DATA["continents"]) do
            local new_continent = {
                ["name"] = MTSLUI_TOOLS:GetLocalisedData(v),
                ["id"] = v.id,
            }
            table.insert(self.continents, new_continent)
        end
    end,

    BuildZones = function(self)
        -- build the arrays with contintents and zones
        self.zones_in_continent = {}

        -- add each zone of current "continent unless its "Any" or "Current location"
        for k, c in pairs(MTSL_DATA["continents"]) do
            self.zones_in_continent[c.id] = {}
            for l, z in pairs(MTSL_LOGIC_WORLD:GetZonesInContinentById(c.id)) do
                local new_zone = {
                    ["name"] = MTSLUI_TOOLS:GetLocalisedData(z),
                    ["id"] = z.id,
                }
                if z.levels then
                    new_zone["name"] = new_zone["name"] .. " (" .. z.levels.min .. "-" .. z.levels.max .. ")"
                end
                table.insert(self.zones_in_continent[c.id], new_zone)
            end
            -- sort alfabethical
            MTSL_TOOLS:SortArrayByProperty(self.zones_in_continent[c.id], "name")
        end
    end,

    ----------------------------------------------------------------------------------------------------------
    -- Intialises drop down for source types
    ----------------------------------------------------------------------------------------------------------
    CreateDropDownSources = function(self)
        MTSLUI_TOOLS:FillDropDown(_G[self.filter_frame_name].sources, _G[self.filter_frame_name].ChangeSourceHandler, self.filter_frame_name)
    end,

    ChangeSourceHandler = function(self, value, text)
        -- Only trigger update if we change to a different continent
        self:ChangeSource(value, text)
    end,

    ChangeSource = function(self, id, text)
        if id and id ~= self.filter_values["source"] then
            self.filter_values["source"] = id
            UIDropDownMenu_SetText(text, self.ui_frame.source_drop_down)
            -- if changed to trainer, update that dropdown
            self.current_available_ranks = {}
            if id == "trainer" then
                self.current_available_ranks = self.ranks
            end
            MTSLUI_TOOLS:FillDropDown(self.current_available_ranks, self.ChangeRankHandler, self.ui_frame.rank_drop_down.filter_frame_name)

            if id == "trainer" then
                self.filter_values["rank"] = 0
                UIDropDownMenu_SetText(MTSLUI_TOOLS:GetLocalisedLabel("any rank"), self.ui_frame.rank_drop_down)
            else
                self.filter_values["rank"] = -1
                UIDropDownMenu_SetText("", self.ui_frame.rank_drop_down)
            end

            self:UpdateFilters()
        end
    end,

    ----------------------------------------------------------------------------------------------------------
    -- Intialises drop down for faction types
    ----------------------------------------------------------------------------------------------------------
    CreateDropDownFactions = function(self)
        MTSLUI_TOOLS:FillDropDown(_G[self.filter_frame_name].factions, _G[self.filter_frame_name].ChangeFactionHandler, self.filter_frame_name)
    end,

    ChangeFactionHandler = function(self, value, text)
        self:ChangeFilter("faction", value, self.ui_frame.faction_drop_down, text)
    end,

    ----------------------------------------------------------------------------------------------------------
    -- Intialises drop down for specialisations
    ----------------------------------------------------------------------------------------------------------
    CreateDropDownProfessions = function(self)
        MTSLUI_TOOLS:FillDropDown(_G[self.filter_frame_name].professions, _G[self.filter_frame_name].ChangeProfessionHandler, self.filter_frame_name)
    end,

    ChangeProfessionHandler = function(self, value, text)
        self:ChangeFilter("profession", value, self.ui_frame.profession_drop_down, text)
    end,

    ----------------------------------------------------------------------------------------------------------
    -- Intialises drop down for continents/zones
    ----------------------------------------------------------------------------------------------------------
    CreateDropDownContinents = function(self)
        MTSLUI_TOOLS:FillDropDown(_G[self.filter_frame_name].continents, _G[self.filter_frame_name].ChangeContinentHandler, self.filter_frame_name)
    end,

    ----------------------------------------------------------------------------------------------------------
    -- Handles DropDown Change event after changing the continent
    ----------------------------------------------------------------------------------------------------------
    ChangeContinentHandler = function(self, value, text)
        self:ChangeContinent(value, text)
    end,

    ChangeContinent = function(self, id, text)
        if id and id ~= self.filter_values["continent"] then
            UIDropDownMenu_SetText(text, self.ui_frame.continent_drop_down)
            -- do not set continent id if id < 0 or we choose "Any"
            if id <= 0 then
                self.filter_values["continent"] = nil
                -- revert negative id to positive
                self.filter_values["zone"] = math.abs(id)
                self.current_available_zones = {}
                MTSLUI_TOOLS:FillDropDown(self.current_available_zones, self.ChangeZoneHandler, self.filter_frame_name)
                UIDropDownMenu_SetText("", self.ui_frame.zone_drop_down)
            else
                -- Update the drop down with available zones for this continent
                self.current_available_zones = self.zones_in_continent[id]
                if self.current_available_zones == nil then
                    self.current_available_zones = {}
                end
                MTSLUI_TOOLS:FillDropDown(self.current_available_zones, self.ChangeZoneHandler, self.filter_frame_name)
                -- auto select first zone in the continent if possible
                self.filter_values["continent"] = id
                local key, zone = next(self.current_available_zones)
                if zone then
                    UIDropDownMenu_SetText(zone.name, self.ui_frame.zone_drop_down)
                    self.filter_values["zone"] = zone.id
                else
                    UIDropDownMenu_SetText("", self.ui_frame.zone_drop_down)
                end
            end

            self:UpdateFilters()
        end
    end,

    ----------------------------------------------------------------------------------------------------------
    -- Intialises drop down for zones
    ----------------------------------------------------------------------------------------------------------
    CreateDropDownZones = function(self)
        MTSLUI_TOOLS:FillDropDown(_G[self.filter_frame_name].current_available_zones, _G[self.filter_frame_name].ChangeZoneHandler, self.filter_frame_name)
    end,

    ----------------------------------------------------------------------------------------------------------
    -- Handles DropDown Change event after changing the zone
    ----------------------------------------------------------------------------------------------------------
    ChangeZoneHandler = function(self, value, text)
        self:ChangeFilter("zone", value, self.ui_frame.zone_drop_down, text)
    end,

    ----------------------------------------------------------------------------------------------------------
    -- Intialises drop down for ranks
    ----------------------------------------------------------------------------------------------------------
    CreateDropDownRanks = function(self)
        MTSLUI_TOOLS:FillDropDown(_G[self.filter_frame_name].current_available_ranks, _G[self.filter_frame_name].ChangeRankHandler, self.filter_frame_name)
    end,

    ----------------------------------------------------------------------------------------------------------
    -- Handles DropDown Change event after changing the rank
    ----------------------------------------------------------------------------------------------------------
    ChangeRankHandler = function(self, value, text)
        self:ChangeFilter("rank", value, self.ui_frame.rank_drop_down, text)
    end,

    ----------------------------------------------------------------------------------------------------------
    -- Handles the change of a filter
    ----------------------------------------------------------------------------------------------------------
    ChangeFilter = function(self, name_filter, value_filter, dropdown_filter, dropdown_text)
        if value_filter and value_filter ~= self.filter_values[name_filter] then
            self.filter_values[name_filter] = value_filter
            UIDropDownMenu_SetText(dropdown_text, dropdown_filter)
            self:UpdateFilters()
        end
    end,

    ----------------------------------------------------------------------------------------------------------
    -- Pass the updated filters to list_frame only if allowed
    ----------------------------------------------------------------------------------------------------------
    UpdateFilters = function(self)
        self.list_frame:ChangeFilters(self.filter_values)
    end,

    ----------------------------------------------------------------------------------------------------------
    -- Switch to vertical split layout
    ----------------------------------------------------------------------------------------------------------
    ResizeToVerticalMode = function(self)
        self.ui_frame:SetWidth(self.FRAME_WIDTH)
        self.ui_frame.search_box:SetWidth(self.WIDTH_TF)
        for _, v in pairs(self.drop_down_names) do
            UIDropDownMenu_SetWidth(self.WIDTH_DD, _G[self.filter_frame_name .. v])
        end
    end,
    ----------------------------------------------------------------------------------------------------------
    -- Switch to horizontal split layout
    ----------------------------------------------------------------------------------------------------------
    ResizeToHorizontalMode = function(self)
        self.ui_frame:SetWidth(self.FRAME_WIDTH)
        self.ui_frame.search_box:SetWidth(self.WIDTH_TF)
        for _, v in pairs(self.drop_down_names) do
            UIDropDownMenu_SetWidth(self.WIDTH_DD, _G[self.filter_frame_name .. v])
        end
    end,

    ----------------------------------------------------------------------------------------------------------
    -- Search NpcsByName
    ----------------------------------------------------------------------------------------------------------
    SearchNpcsByName = function(self)
        -- remove focus field
        local name_npc = self.ui_frame.search_box:GetText()

        -- remove leading & trailing spaces
        name_npc = string.gsub(name_npc, "^%s*(.-)%s*$", "%1")
        -- set the trimmed text into the textbox
        self.ui_frame.search_box:SetText(name_npc)

        self.filter_values["npc_name"] = name_npc
        self.ui_frame.search_box:ClearFocus()
        self:UpdateFilters()
    end,
}
