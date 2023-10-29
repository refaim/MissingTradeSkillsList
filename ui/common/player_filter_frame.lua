--------------------------------------------------------------
-- Name: PlayerFilterFrame                                  --
-- Description: Shows all the filters for a list of players --
-- Parent Frame: -                                          --
--------------------------------------------------------------
local _G = _G or getfenv(0)

---@class MTSLUI_PLAYER_FILTER_FRAME
MTSLUI_PLAYER_FILTER_FRAME = {
    -- Keeps the current created frame
    ui_frame = nil,
    -- width of the frame
    FRAME_WIDTH = 305,
    -- height of the frame
    FRAME_HEIGHT = 49,
    -- keep track of current sort mehod (1 = name (default), 2 = level)
    current_sort = 1,
    -- keeps track of current realm used for filtering
    current_realm = nil,
    sorts = {},
    -- all contintents
    continents = {},
    -- all zones for each contintent
    zones_in_continent = {},
    -- all zones for the current continent
    current_available_zones = {},
    current_contintent_id = nil,
    current_zone_id = nil,
    -- widhts of the drops downs according to layout
    WIDTH_DD = 150,
    -- Filtering active (flag indicating if changing drop downs has effect, default on)
    filtering_active = 1,
}

function MTSLUI_PLAYER_FILTER_FRAME:Initialise(parent_frame, filter_frame_name)
    self:InitialiseData()
    -- create the container frame
    self.ui_frame = MTSLUI_TOOLS:CreateBaseFrame("Frame", "", parent_frame, nil, self.FRAME_WIDTH, self.FRAME_HEIGHT, false)
    self.filter_frame_name = filter_frame_name
    -- create a filter for sorting
    self.ui_frame.sort_by_text = MTSLUI_TOOLS:CreateLabel(self.ui_frame, MTSLUI_TOOLS:GetLocalisedLabel("sort"), 5, -5, "LABEL", "TOPLEFT")
    self.ui_frame.sort_drop_down = CreateFrame("Frame", filter_frame_name .. "_DD_SORTS", self.ui_frame, "UIDropDownMenuTemplate")
    self.ui_frame.sort_drop_down:SetPoint("TOPRIGHT", self.ui_frame, "TOPRIGHT", 10, 3)
    self.ui_frame.sort_drop_down.filter_frame_name = filter_frame_name
    self.ui_frame.sort_drop_down.initialize = MTSL_TOOLS:BindArgument(self.CreateDropDownSorting, self)
    UIDropDownMenu_SetWidth(self.WIDTH_DD, self.ui_frame.sort_drop_down)
    UIDropDownMenu_SetText(self.sorts[self.current_sort]["name"], self.ui_frame.sort_drop_down)
    -- create a filter for realms
    self.ui_frame.realm_text = MTSLUI_TOOLS:CreateLabel(self.ui_frame, MTSLUI_TOOLS:GetLocalisedLabel("realm"), 5, -35, "LABEL", "TOPLEFT")
    self.ui_frame.realm_drop_down = CreateFrame("Frame", filter_frame_name .. "_DD_REALMS", self.ui_frame, "UIDropDownMenuTemplate")
    self.ui_frame.realm_drop_down:SetPoint("TOPLEFT", self.ui_frame.sort_drop_down, "BOTTOMLEFT", 0, 2)
    self.ui_frame.realm_drop_down.filter_frame_name = filter_frame_name
    self.ui_frame.realm_drop_down.initialize = MTSL_TOOLS:BindArgument(self.CreateDropDownRealms, self, self.ui_frame.realm_drop_down.filter_frame_name)
    UIDropDownMenu_SetWidth(self.WIDTH_DD, self.ui_frame.realm_drop_down)
    if self.current_realm > 0 then
        UIDropDownMenu_SetText(MTSL_TOOLS:GetItemFromArrayByKeyValue(self.realms, "id", self.current_realms)["name"], self.ui_frame.realm_drop_down)
    else
        UIDropDownMenu_SetText(MTSLUI_TOOLS:GetLocalisedLabel("any"), self.ui_frame.realm_drop_down)
    end
    -- enable filtering by default
    self:EnableFiltering()
    -- add it to global vars to access later on
    _G[filter_frame_name] = self
end

function MTSLUI_PLAYER_FILTER_FRAME:SetListFrame(list_frame)
    self.list_frame = list_frame
end

function MTSLUI_PLAYER_FILTER_FRAME:InitialiseData()
    self.sorts = {
        {
            ["name"] = MTSLUI_TOOLS:GetLocalisedLabel("level"),
            ["id"] = 1,
        },
        {
            ["name"] = MTSLUI_TOOLS:GetLocalisedLabel("name"),
            ["id"] = 2,
        },
        {
            ["name"] = MTSLUI_TOOLS:GetLocalisedLabel("realm"),
            ["id"] = 3,
        },
    }
    self.current_sort = 1
    self.current_profession = ""
    self:BuildRealms()
    -- auto select the "any" realm
    self.current_realm = 0
end

function MTSLUI_PLAYER_FILTER_FRAME:BuildRealms()
    -- build the arrays with contintents and zones
    self.realms = {
        {
            ["name"] = MTSLUI_TOOLS:GetLocalisedLabel("any"),
            ["id"] = "any",
        }
    }

    local used_realms
    if self.current_profession == "" or self.current_profession == nil then
        used_realms = MTSL_LOGIC_PLAYER_NPC:GetRealmsWithPlayers()
    else
        used_realms = MTSL_LOGIC_PLAYER_NPC:GetRealmsWithPlayersKnowingProfession(self.current_profession)
    end

    local i = 1
    -- add each type of "continent
    while used_realms[i] ~= nil do
        local new_realm = {
            ["name"] = used_realms[i],
            ["id"] = used_realms[i]
        }
        table.insert(self.realms, new_realm)
        i = i + 1
    end
end

function MTSLUI_PLAYER_FILTER_FRAME:CreateDropDownRealms()
    MTSLUI_TOOLS:FillDropDown(self.realms, self.ChangeRealmHandler, self.filter_frame_name)
end

function MTSLUI_PLAYER_FILTER_FRAME:ChangeRealmHandler(value, text)
    -- Only trigger update if we change to a different zone
    if value ~= nil and value ~= self.current_realm then
        self:ChangeRealm(value, text)
    end
end

function MTSLUI_PLAYER_FILTER_FRAME:ChangeRealm(id, text)
    self.current_realm = id
    UIDropDownMenu_SetText(text, self.ui_frame.realm_drop_down)
    -- Apply filter if we may
    if self:IsFilteringEnabled() then
        self.list_frame:ChangeRealm(id)
    end
end

function MTSLUI_PLAYER_FILTER_FRAME:CreateDropDownSorting()
    MTSLUI_TOOLS:FillDropDown(self.sorts, self.ChangeSortHandler, self.filter_frame_name)
end

function MTSLUI_PLAYER_FILTER_FRAME:ChangeSortHandler(value, text)
    -- Only trigger update if we change to a different way to sort
    if value ~= nil and self.current_sort ~= value then
        self:ChangeSorting(value, text)
    end
end

function MTSLUI_PLAYER_FILTER_FRAME:ChangeSorting(value, text)
    self.current_sort = value
    UIDropDownMenu_SetText(text, self.ui_frame.sort_drop_down)
    -- Apply filter if we may
    if self:IsFilteringEnabled() then
        self.list_frame:ChangeSort(value)
    end
end

function MTSLUI_PLAYER_FILTER_FRAME:IsFilteringEnabled()
    return self.filtering_active == 1
end

function MTSLUI_PLAYER_FILTER_FRAME:EnableFiltering()
    self.filtering_active = 1
end

function MTSLUI_PLAYER_FILTER_FRAME:DisableFiltering()
    self.filtering_active = 0
end

function MTSLUI_PLAYER_FILTER_FRAME:ChangeCurrentProfession(profession_name)
    -- only swap if we picked a new one
    if self.current_profession ~= profession_name  then
        self.current_profession = profession_name
        self:BuildRealms()
    end
end
