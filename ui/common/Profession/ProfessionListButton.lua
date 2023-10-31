---@class MTSLUI_ProfessionListButton: MTSL_PoolObject
---@field __ui_frame Frame
---@field __button Button
---@field __selected_background Frame
---@field __icon Texture
---@field __label FontString
MTSLUI_ProfessionListButton = {
    __initialized = false,
}

---@param width number
---@param height number
---@param texture_id string
---@param onclick function
function MTSLUI_ProfessionListButton:Initialise(width, height, texture_id, onclick)
    if self.__ui_frame == nil then
        local ui_frame = CreateFrame("Frame", nil, nil, nil)
        ui_frame:EnableMouse(true)

        local button = --[[---@type Button]] CreateFrame("Button", nil, ui_frame)
        button:SetWidth(21)
        button:SetHeight(21)

        local bg = MTSLUI_TOOLS:CreateBaseFrame("Frame", nil, ui_frame, nil, 1, 1, true)
        bg:SetBackdropColor(1, 1, 0, 0.40)
        bg:SetBackdropBorderColor(1, 1, 0, 1)

        local icon = button:CreateTexture(nil, "ARTWORK")

        local label = MTSLUI_TOOLS:CreateLabel(button, nil, 0, -12, "LABEL", "BOTTOM")

        self.__ui_frame = ui_frame
        self.__button = button
        self.__selected_background = bg
        self.__icon = icon
        self.__label = label
    end

    self.__ui_frame:SetWidth(width)
    self.__ui_frame:SetHeight(height)
    self.__ui_frame:SetScript("OnClick", onclick)

    self.__selected_background:SetWidth(width + 1)
    self.__selected_background:SetHeight(height + 5)
    self.__selected_background:SetPoint("CENTER")
    self.__selected_background:Hide()

    self.__button:SetPoint("CENTER", self.__selected_background, "CENTER", 0, 6)

    self.__icon:SetTexture(texture_id)
end

function MTSLUI_ProfessionListButton:Deinitialise()
    self.__ui_frame:SetParent(nil)
    self.__ui_frame:SetScript("OnClick", nil)

    self.__selected_background:Hide()

    self.__icon:SetTexture("")

    self.__label:SetText("")
end

---@return Frame
function MTSLUI_ProfessionListButton:GetUserInterfaceFrame()
    return self.__ui_frame
end

function MTSLUI_ProfessionListButton:Select()
    self.__selected_background:Show()
end

function MTSLUI_ProfessionListButton:Deselect()
    self.__selected_background:Hide()
end
