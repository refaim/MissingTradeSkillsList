----------------------------------------------------------
-- Name: FilterFrame                                    --
-- Description: Shows all the filters for a list        --
-- Parent Frame: -                                      --
----------------------------------------------------------
local _G = _G or getfenv(0)

---@class MTSLUI_FILTER_FRAME
MTSLUI_FILTER_FRAME = {
    -- Keeps the current created frame
    ui_frame = nil,
    -- width of the frame
    FRAME_WIDTH_VERTICAL = 385,
    FRAME_WIDTH_HORIZONTAL = 515,
    -- height of the frame
    FRAME_HEIGHT = 110,
    -- all contintents
    continents = {},
    -- all zones for each contintent
    zones_in_continent = {},
    -- all zones for the current continent
    current_available_zones = {},
    -- widths of the drops downs according to layout
    VERTICAL_WIDTH_DD = 173, -- (+/- half of the width of frame)
    HORIZONTAL_WIDTH_DD = 238,
    -- widths of the search box according to layout
    VERTICAL_WIDTH_TF = 268,
    HORIZONTAL_WIDTH_TF = 398,
    -- Filtering active (flag indicating if changing drop downs has effect, default on)
    filtering_active = 1,
    -- currently used profession for filtering
    current_profession = nil,
    -- array holding the values of the current filters
    filter_values = {},
    -- holding the list items for all the drop downs
    drop_down_lists = {},
}

function MTSLUI_FILTER_FRAME:Initialise(parent_frame, filter_frame_name)
    self.filter_frame_name = filter_frame_name
    self:InitialiseData()
    -- create the container frame
    self.ui_frame = MTSLUI_TOOLS:CreateBaseFrame("Frame", "", parent_frame, nil, self.FRAME_WIDTH_VERTICAL, self.FRAME_HEIGHT, false)
    -- Initialise each row of the filter frame
    self:InitialiseFirstRow()
    self:InitialiseSecondRow()
    self:InitialiseThirdRow()
    self:InitialiseFourthRow()
    -- enable filtering by default
    self:EnableFiltering()
    -- save name of each DropDown for access when resizing later
    self.drop_down_names = { "_DD_SOURCES", "_DD_FACTIONS", "_DD_SPECS", "_DD_CONTS", "_DD_ZONES" }
    -- add it to global vars to access later on
    _G[filter_frame_name] = self
    self:ResetFilters()
end

function MTSLUI_FILTER_FRAME:InitialiseFirstRow()
    -- Search box with button
    self.ui_frame.search_box = CreateFrame("EditBox", self.filter_frame_name .. "_TF", self.ui_frame)
    self.ui_frame.search_box:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    --  Black background
    self.ui_frame.search_box:SetBackdropColor(0,0,0,1)
    -- make cursor appear in the textbox
    self.ui_frame.search_box:SetTextInsets(6, 0, 0, 0)
    self.ui_frame.search_box:SetWidth(self.VERTICAL_WIDTH_TF)
    self.ui_frame.search_box:SetHeight(24)
    self.ui_frame.search_box:SetMultiLine(false)
    self.ui_frame.search_box:SetAutoFocus(false)
    self.ui_frame.search_box:SetMaxLetters(30)
    self.ui_frame.search_box:SetFontObject(GameFontNormal)
    -- search by pressing "enter" or "escape"
    self.ui_frame.search_box:SetScript("OnEnterPressed", function() _G[self.filter_frame_name]:SearchRecipes() end)
    self.ui_frame.search_box:SetScript("OnEscapePressed", function() _G[self.filter_frame_name]:SearchRecipes() end)
    self.ui_frame.search_btn = MTSLUI_TOOLS:CreateBaseFrame("Button", "", self.ui_frame, "UIPanelButtonTemplate", 118, 25)
    self.ui_frame.search_btn:SetText(MTSLUI_TOOLS:GetLocalisedLabel("search"))
    self.ui_frame.search_btn:SetScript("OnClick", function() _G[self.filter_frame_name]:SearchRecipes() end)
    -- Position the elements
    self.ui_frame.search_box:SetPoint("TOPLEFT", self.ui_frame, "TOPLEFT", 0, 0)
    self.ui_frame.search_btn:SetPoint("TOPLEFT", self.ui_frame.search_box, "TOPRIGHT", -1, 0)
end

function MTSLUI_FILTER_FRAME:InitialiseSecondRow()
    -- create a filter for source type
    -- self.ui_frame.source_text = MTSLUI_TOOLS:CreateLabel(self.ui_frame, MTSLUI_TOOLS:GetLocalisedLabel("learned from"), 5, -34, "LABEL", "TOPLEFT")
    self.ui_frame.source_drop_down = CreateFrame("Frame", self.filter_frame_name .. "_DD_SOURCES", self.ui_frame, "UIDropDownMenuTemplate")
    self.ui_frame.source_drop_down:SetPoint("TOPLEFT", self.ui_frame.search_box, "BOTTOMLEFT", -15, -2)
    self.ui_frame.source_drop_down.filter_frame_name = self.filter_frame_name
    self.ui_frame.source_drop_down.initialize = MTSL_TOOLS:BindArgument(self.CreateDropDownSources, self)
    UIDropDownMenu_SetText(MTSLUI_TOOLS:GetLocalisedLabel("source"), self.ui_frame.source_drop_down)
end

function MTSLUI_FILTER_FRAME:InitialiseThirdRow()
    -- Factions drop down
    -- self.ui_frame.factions_text = MTSLUI_TOOLS:CreateLabel(self.ui_frame, MTSLUI_TOOLS:GetLocalisedLabel("faction"), 215, -34, "LABEL", "TOPLEFT")
    self.ui_frame.faction_drop_down = CreateFrame("Frame", self.filter_frame_name .. "_DD_FACTIONS", self.ui_frame, "UIDropDownMenuTemplate")
    self.ui_frame.faction_drop_down:SetPoint("TOPLEFT", self.ui_frame.source_drop_down, "BOTTOMLEFT", 0, 2)
    self.ui_frame.faction_drop_down.filter_frame_name = self.filter_frame_name
    self.ui_frame.faction_drop_down.initialize = MTSL_TOOLS:BindArgument(self.CreateDropDownFactions, self)
    UIDropDownMenu_SetText(MTSLUI_TOOLS:GetLocalisedLabel("faction"), self.ui_frame.faction_drop_down)
    -- Specialisations
    -- self.ui_frame.specs_text = MTSLUI_TOOLS:CreateLabel(self.ui_frame, MTSLUI_TOOLS:GetLocalisedLabel("specialisation"), 5, -64, "LABEL", "TOPLEFT")
    self.ui_frame.specialisation_drop_down = CreateFrame("Frame", self.filter_frame_name .. "_DD_SPECS", self.ui_frame, "UIDropDownMenuTemplate")
    self.ui_frame.specialisation_drop_down:SetPoint("TOPLEFT", self.ui_frame.faction_drop_down, "TOPRIGHT", -31, 0)
    self.ui_frame.specialisation_drop_down.filter_frame_name = self.filter_frame_name
    self.ui_frame.specialisation_drop_down.initialize = MTSL_TOOLS:BindArgument(self.CreateDropDownSpecialisations, self)
    UIDropDownMenu_SetText(MTSLUI_TOOLS:GetLocalisedLabel("specialisation"), self.ui_frame.specialisation_drop_down)
end

function MTSLUI_FILTER_FRAME:InitialiseFourthRow()
    -- Continents & zones
    -- self.ui_frame.zone_text = MTSLUI_TOOLS:CreateLabel(self.ui_frame, MTSLUI_TOOLS:GetLocalisedLabel("zone"), 5, -94, "LABEL", "TOPLEFT")
    -- Continent more split up with types as well, to reduce number of items shown
    self.ui_frame.continent_drop_down = CreateFrame("Frame", self.filter_frame_name .. "_DD_CONTS", self.ui_frame, "UIDropDownMenuTemplate")
    self.ui_frame.continent_drop_down:SetPoint("TOPLEFT", self.ui_frame.faction_drop_down, "BOTTOMLEFT", 0, 2)
    self.ui_frame.continent_drop_down.filter_frame_name = self.filter_frame_name
    self.ui_frame.continent_drop_down.initialize = MTSL_TOOLS:BindArgument(self.CreateDropDownContinents, self)
    -- default contintent "any" so no need for sub zone to show
    self.ui_frame.zone_drop_down = CreateFrame("Frame", self.filter_frame_name .. "_DD_ZONES", self.ui_frame, "UIDropDownMenuTemplate")
    self.ui_frame.zone_drop_down:SetPoint("TOPLEFT", self.ui_frame.continent_drop_down, "TOPRIGHT", -31, 0)
    self.ui_frame.zone_drop_down.filter_frame_name = self.filter_frame_name
    self.ui_frame.zone_drop_down.initialize = MTSL_TOOLS:BindArgument(self.CreateDropDownZones, self)
end

function MTSLUI_FILTER_FRAME:InitFilters()
    local filter_values = {
        skill_name = "",
        profession = nil,
        continent = 0,
        zone = 0,
    }

    for _, dropdown_list_name in ipairs({"faction", "source", "specialisation"}) do
        local dropdown = self.drop_down_lists[dropdown_list_name]
        local value = {}
        for _, entry in ipairs(dropdown) do
            tinsert(value, entry.id)
            entry.checked = true
        end
        filter_values[dropdown_list_name] = value
    end

    self.filter_values = filter_values
end

function MTSLUI_FILTER_FRAME:ResetFilters()
    self:InitFilters()
    -- reset name to search
    self.ui_frame.search_box:SetText("")
    self.ui_frame.search_box:ClearFocus()
    -- reset contintent & zone
    UIDropDownMenu_SetText(MTSLUI_TOOLS:GetLocalisedLabel("any zone"), self.ui_frame.continent_drop_down)
    UIDropDownMenu_SetText("", self.ui_frame.zone_drop_down)
    -- set the current filters to the listframe
    if self.list_frame then self.list_frame:ChangeFilters(self.filter_values) end
end

function MTSLUI_FILTER_FRAME:DontIncludeOppositeFaction()
    self.filter_values["faction"] = {}
    local horde_id = MTSL_LOGIC_FACTION_REPUTATION:GetFactionIdByName("Horde")
    local alliance_id = MTSL_LOGIC_FACTION_REPUTATION:GetFactionIdByName("Alliance")
    for _, k in pairs(self.drop_down_lists.faction) do
        -- By default do not check opposite faction
        if (MTSL_CURRENT_PLAYER.FACTION == "Alliance" and k.id ~= horde_id) or
                (MTSL_CURRENT_PLAYER.FACTION == "Horde" and k.id ~= alliance_id) then
            table.insert(self.filter_values.faction, k.id)
            k.checked = true
        else
            k.checked = nil
        end
    end
end

function MTSLUI_FILTER_FRAME:UseOnlyLearnedSpecialisations(specialisation_ids)
    self.drop_down_lists.specialisation = {
        {
            ["name"] = MTSLUI_TOOLS:GetLocalisedLabel("no specialisation"),
            -- auto check all
            ["checked"] = true,
            ["id"] = 0,
        },
    }

    -- only add current zone if possible (gives trouble while changing zones or not zone not triggering on load)
    local specs = MTSL_LOGIC_PROFESSION:GetSpecialisationsForProfession(self.current_profession)
    -- sort by name
    MTSL_TOOLS:SortArrayByLocalisedProperty(specs, "name")
    -- add each type of specialisation if we know it
    for _, v in pairs(specs) do
        if MTSL_TOOLS:ListContainsNumber(specialisation_ids, v.id) then
            local new_specialisation = {
                ["name"] = MTSLUI_TOOLS:GetLocalisedData(v),
                -- auto check all
                ["checked"] = true,
                ["id"] = v.id,
            }
            table.insert(self.drop_down_lists.specialisation, new_specialisation)
        end
    end
end

function MTSLUI_FILTER_FRAME:UseAllSpecialisations()
    self:BuildSpecialisations()
end

function MTSLUI_FILTER_FRAME:SetListFrame(list_frame)
    self.list_frame = list_frame
    -- set the current filters to the listframe
    self:ResetFilters()
end

function MTSLUI_FILTER_FRAME:InitialiseData()
    self:BuildSources()
    self:BuildSpecialisations()
    self:BuildFactions()
    self:BuildContinents()
    self:BuildZones()
end

-- Refresh the label of the current zone (Called after changing zone to a new area in the game EVENT ZONE_NEW_AREA)
function MTSLUI_FILTER_FRAME:UpdateCurrentZone(new_zone_name)
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
        if self.filter_values["continent"] == nil and UIDropDownMenu_GetText(self.ui_frame.continent_drop_down) ~= MTSLUI_TOOLS:GetLocalisedLabel("any zone") then
           -- self:ChangeFilter("zone", self.continents[2]["id"], self.ui_frame.zone_drop_down, self.continents[2]["name"])
            self:ChangeContinent(self.continents[2]["id"], self.continents[2]["name"])
        end
    end
end

function MTSLUI_FILTER_FRAME:BuildSources()
    local source_types = { "trainer", "drop", "object", "quest", "vendor", "holiday" }
    self.drop_down_lists.source = {}
    for _, v in pairs(source_types) do
        local new_source = {
            ["name"] = MTSLUI_TOOLS:GetLocalisedLabel(v),
            -- auto check all
            ["checked"] = true,
            ["id"] = v,
        }
        table.insert(self.drop_down_lists.source, new_source)
    end
    MTSL_TOOLS:SortArrayByProperty(self.drop_down_lists.source, "name")
end

function MTSLUI_FILTER_FRAME:BuildFactions()
    self.drop_down_lists.faction = {
        -- Alliance & horde
        {
            ["name"] = MTSLUI_TOOLS:GetLocalisedLabel("alliance and horde"),
            -- auto check all
            ["checked"] = true,
            ["id"] = MTSL_LOGIC_FACTION_REPUTATION.FACTION_ID_ALLIANCE_AND_HORDE,
        },
        -- Alliance (id: 469)
        {
            ["name"] = MTSLUI_TOOLS:GetLocalisedLabel("alliance only"),
            -- auto check all
            ["checked"] = true,
            ["id"] = 469,
        },
        -- Horde (id: 67)
        {
            ["name"] = MTSLUI_TOOLS:GetLocalisedLabel("horde only"),
            -- auto check all
            ["checked"] = true,
            ["id"] = 67,
        },
        -- Neutral
        {
            ["name"] = MTSLUI_TOOLS:GetLocalisedLabel("neutral"),
            -- auto check all
            ["checked"] = true,
            ["id"] = MTSL_LOGIC_FACTION_REPUTATION.FACTION_ID_NEUTRAL,
        },
    }
    -- Ids of reputations used for recipes, add those factions too
    local reputation_ids = { 59, 270, 529, 576, 609 }
    local rep_factions = {}
    for _, v in pairs(reputation_ids) do
        local new_faction = {
            ["name"] = MTSL_LOGIC_FACTION_REPUTATION:GetFactionNameById(v),
            -- auto check all
            ["checked"] = true,
            ["id"] = v,
        }
        table.insert(rep_factions, new_faction)
    end
    -- Sort them by name
    MTSL_TOOLS:SortArrayByProperty(rep_factions, "name")
    -- Add them sorted to factions
    for _, r in pairs(rep_factions) do
        table.insert(self.drop_down_lists.faction, r)
    end
end

function MTSLUI_FILTER_FRAME:BuildSpecialisations()
    self.drop_down_lists.specialisation = {
        {
            ["name"] = MTSLUI_TOOLS:GetLocalisedLabel("no specialisation"),
            ["checked"] = true,
            ["id"] = 0,
        },
    }
    -- only add current zone if possible (gives trouble while changing zones or not zone not triggering on load)
    local specs = MTSL_LOGIC_PROFESSION:GetSpecialisationsForProfession(self.current_profession)
    -- add any specialisation
    if MTSL_TOOLS:CountItemsInNamedArray(specs) > 0 then
        -- sort by name
        MTSL_TOOLS:SortArrayByLocalisedProperty(specs, "name")
        -- add each type of specialisation
        for _, v in pairs(specs) do
            local new_specialisation = {
                ["name"] = MTSLUI_TOOLS:GetLocalisedData(v),
                ["checked"] = true,
                ["id"] = v.id,
            }
            table.insert(self.drop_down_lists.specialisation, new_specialisation)
        end
    end
end

function MTSLUI_FILTER_FRAME:BuildContinents()
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
    -- it might not be able to get real zone text now so add filter element
    else
        local zone_filter = {
            ["name"] = MTSLUI_TOOLS:GetLocalisedLabel("current zone") .. " ()",
            -- make id negative for filter later on
            ["id"] = 0,
        }
        table.insert(self.continents, zone_filter)
    end
    -- add each type of "continent
    for _, v in pairs(TRADE_SKILLS_DATA["continents"]) do
        local new_continent = {
            ["name"] = MTSLUI_TOOLS:GetLocalisedData(v),
            ["id"] = v.id,
        }
        table.insert(self.continents, new_continent)
    end
end

function MTSLUI_FILTER_FRAME:BuildZones()
    -- build the arrays with contintents and zones
    self.zones_in_continent = {}

    -- add each zone of current "continent unless its "Any" or "Current location"
    for _, c in pairs(TRADE_SKILLS_DATA["continents"]) do
        self.zones_in_continent[c.id] = {}
        for _, z in pairs(MTSL_LOGIC_WORLD:GetZonesInContinentById(c.id)) do
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
end

function MTSLUI_FILTER_FRAME:CreateDropDownSources()
    MTSLUI_TOOLS:FillDropDownCheckable(_G[self.filter_frame_name].drop_down_lists["source"], _G[self.filter_frame_name].ChangeSourceHandler, self.filter_frame_name)
end

function MTSLUI_FILTER_FRAME:ChangeSourceHandler(value, text)
    self:ChangeCheckboxValue("source", value)
end

function MTSLUI_FILTER_FRAME:ChangeCheckboxValue(value_name, value)
    local dropdownitem = MTSL_TOOLS:GetItemFromArrayByKeyValue(self.drop_down_lists[value_name], "id", value)
    if dropdownitem then
        if dropdownitem.checked == true then
            dropdownitem.checked = nil
        else
            dropdownitem.checked = true
        end
        self:RebuildFilterValuesForValue(value_name)
    end
end

function MTSLUI_FILTER_FRAME:RebuildFilterValuesForValue(value_name)
    -- Rebuild the list with filter values
    self.filter_values[value_name] = {}
    for _, v in pairs(self.drop_down_lists[value_name]) do
        if v.checked == true then
            table.insert(self.filter_values[value_name], v.id)
        end
    end
    self:UpdateFilters()
end

function MTSLUI_FILTER_FRAME:CreateDropDownFactions()
    MTSLUI_TOOLS:FillDropDownCheckable(_G[self.filter_frame_name].drop_down_lists.faction, _G[self.filter_frame_name].ChangeFactionHandler, self.filter_frame_name)
end

function MTSLUI_FILTER_FRAME:ChangeFactionHandler(value, text)
    self:ChangeCheckboxValue("faction", value)
end

function MTSLUI_FILTER_FRAME:CreateDropDownSpecialisations()
    MTSLUI_TOOLS:FillDropDownCheckable(_G[self.filter_frame_name].drop_down_lists.specialisation, _G[self.filter_frame_name].ChangeSpecialisationHandler, self.filter_frame_name)
end

function MTSLUI_FILTER_FRAME:ChangeSpecialisationHandler(value, text)
    self:ChangeCheckboxValue("specialisation", value)
end

function MTSLUI_FILTER_FRAME:CreateDropDownContinents()
    MTSLUI_TOOLS:FillDropDown(_G[self.filter_frame_name].continents, _G[self.filter_frame_name].ChangeContinentHandler, self.filter_frame_name)
end

function MTSLUI_FILTER_FRAME:ChangeContinentHandler(value, text)
    -- Only trigger update if we change to a different continent
    if value ~= nil and value ~= self.current_continent_id then
        self:ChangeContinent(value, text)
    end
end

function MTSLUI_FILTER_FRAME:ChangeContinent(id, text)
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
        local _, zone = next(self.current_available_zones)
        if zone then
            UIDropDownMenu_SetText(zone.name, self.ui_frame.zone_drop_down)
            self.filter_values["zone"] = zone.id
        else
            UIDropDownMenu_SetText("", self.ui_frame.zone_drop_down)
        end
    end

    self:UpdateFilters()
end

function MTSLUI_FILTER_FRAME:CreateDropDownZones()
    MTSLUI_TOOLS:FillDropDown(_G[self.filter_frame_name].current_available_zones, _G[self.filter_frame_name].ChangeZoneHandler, self.filter_frame_name)
end

function MTSLUI_FILTER_FRAME:ChangeZoneHandler(value, text)
    self:ChangeFilter("zone", value, self.ui_frame.zone_drop_down, text)
end

function MTSLUI_FILTER_FRAME:ChangeFilter(name_filter, value_filter, dropdown_filter, dropdown_text)
    if value_filter and value_filter ~= self.filter_values[name_filter] then
        self.filter_values[name_filter] = value_filter
        UIDropDownMenu_SetText(dropdown_text, dropdown_filter)
        self:UpdateFilters()
    end
end

function MTSLUI_FILTER_FRAME:ResizeToVerticalMode()
    self.ui_frame:SetWidth(self.FRAME_WIDTH_VERTICAL)
    self.ui_frame.search_box:SetWidth(self.VERTICAL_WIDTH_TF)
    for _, v in pairs(self.drop_down_names) do
        UIDropDownMenu_SetWidth(self.VERTICAL_WIDTH_DD, _G[self.filter_frame_name .. v])
    end
end

function MTSLUI_FILTER_FRAME:ResizeToHorizontalMode()
    self.ui_frame:SetWidth(self.FRAME_WIDTH_HORIZONTAL)
    self.ui_frame.search_box:SetWidth(self.HORIZONTAL_WIDTH_TF)
    for _, v in pairs(self.drop_down_names) do
        UIDropDownMenu_SetWidth(self.HORIZONTAL_WIDTH_DD, _G[self.filter_frame_name .. v])
    end
end

function MTSLUI_FILTER_FRAME:IsFilteringEnabled()
    return self.filtering_active == 1
end

function MTSLUI_FILTER_FRAME:EnableFiltering()
    self.filtering_active = 1
end

function MTSLUI_FILTER_FRAME:DisableFiltering()
    self.filtering_active = 0
end

function MTSLUI_FILTER_FRAME:ChangeProfession(profession_name)
    -- Only change if new one
    if self.current_profession ~= profession_name then
        self.current_profession = profession_name
        self:ResetFilters()
        -- Make sure a drop down is hidden before updating specialisations one
        self.ui_frame.specialisation_drop_down:Hide()
        -- Update the list of specialisations for the current profession
        self:BuildSpecialisations()
        self:CreateDropDownSpecialisations()
        -- Show it again after rebuild
        self.ui_frame.specialisation_drop_down:Show()
        self:UpdateFilters()
    end
end

function MTSLUI_FILTER_FRAME:UpdateFilters()
    if self:IsFilteringEnabled() then
        self.list_frame:ChangeFilters(self.filter_values)
    end
end

function MTSLUI_FILTER_FRAME:SearchRecipes()
    -- remove focus field
    local name_recipe = self.ui_frame.search_box:GetText()

    -- remove leading & trailing spaces
    name_recipe = string.gsub(name_recipe, "^%s*(.-)%s*$", "%1")
    -- set the trimmed text into the textbox
    self.ui_frame.search_box:SetText(name_recipe)

    self.filter_values["skill_name"] = name_recipe
    self.ui_frame.search_box:ClearFocus()
    self:UpdateFilters()
end
