----------------------------------------------------------
-- Name: Fonts                                          --
-- Description: Contains everything about custom fonts  --
----------------------------------------------------------

---@class MTSLUI_FONTS
MTSLUI_FONTS = {
    -- Fontsize of text
    SIZE = {
        SMALL = 10,
        NORMAL = 11,
        LARGE = 13,
    },
    -- Colors available
    COLORS = {
        -- Colors used for text
        TEXT = {
            SUCCESS = "|cff1eff00",
            NORMAL = "|cffffffff",
            TITLE = "|cffffff00",
            ERROR = "|cffff0000",
            WARNING = "|cffffa500",
        },
        -- Colors use to display money
        MONEY = {
            GOLD = "|cffffd700",
            SILVER = "|cffc7c7cf",
            COPPER = "|cffeda55f"
        },
        -- Colors used for a font based on quality of an item
        ITEM_QUALITY = {
            POOR = "|cff9d9d9d",
            COMMON = "|cffffffff",
            UNCOMMON = "|cff1eff00",
            RARE = "|cff0070dd",
            EPIC = "|cffa335ee",
            LEGENDARY = "|cffff8000"
        },
        -- Colors used for a font based if an item is "available"/"learnable"
        AVAILABLE = {
            YES = "|cff1eff00",
            NO = "|cffff0000",
            LEARNABLE = "|cffffa500",
            ALL = "|cffffffff",
        },
        -- Colors of the color of factions
        FACTION = {
            HORDE = "|cff8c1616",
            NEUTRAL = "|cffffd700",
            ALLIANCE = "|cff144587",
        }
    },
    -- our saved fonts
    FONTS = {
        TEXT = nil,
        LABEL = nil,
        TITLE = nil,
    },
    AVAILABLE_FONT_SIZES = {
        {
            ["name"] = "8",
            ["id"] = 8,
        },
        {
            ["name"] = "9",
            ["id"] = 9,
        },
        {
            ["name"] = "10",
            ["id"] = 10,
        },
        {
            ["name"] = "11",
            ["id"] = 11,
        },
        {
            ["name"] = "12",
            ["id"] = 12,
        },
        {
            ["name"] = "13",
            ["id"] = 13,
        },
        {
            ["name"] = "14",
            ["id"] = 14,
        },
        {
            ["name"] = "15",
            ["id"] = 15,
        },
        {
            ["name"] = "16",
            ["id"] = 16,
        },
    },
    -- Min and max size of font
    MIN_SIZE = 8,
    MAX_SIZE = 16,

    -- Simulates a "tab"
    TAB = "     ",
}

-------------------------------------------------------------------------
-- Initialise the Fonts used in addon (only call after locale is set)
-------------------------------------------------------------------------
function MTSLUI_FONTS:Initialise()
    self.FONTS.TEXT = CreateFont("MTSL_TextText")
    self.FONTS.LABEL = CreateFont("MTSL_LabelText")
    self.FONTS.TITLE = CreateFont("MTSL_TitleText")

    self.FONTS.TEXT:SetFont("Fonts\\" .. MTSLUI_PLAYER.FONT.NAME, MTSLUI_PLAYER.FONT.SIZE.TEXT, "OUTLINE")
    self.FONTS.LABEL:SetFont("Fonts\\" .. MTSLUI_PLAYER.FONT.NAME, MTSLUI_PLAYER.FONT.SIZE.LABEL, "OUTLINE")
    self.FONTS.TITLE:SetFont("Fonts\\" .. MTSLUI_PLAYER.FONT.NAME, MTSLUI_PLAYER.FONT.SIZE.TITLE, "OUTLINE")
end

function MTSLUI_FONTS:GetTextColorByItemQuality(item_quality)
    if item_quality ~= nil then
        item_quality = string.upper(item_quality)
        -- Return the found quality
        if self.COLORS.ITEM_QUALITY[item_quality] ~= nil then
            return self.COLORS.ITEM_QUALITY[item_quality]
        end
    end
    -- default return common quality
    return self.COLORS.ITEM_QUALITY.COMMON
end

function MTSLUI_FONTS:GetAvailableFonts()
    local available_fonts
    if MTSLUI_CURRENT_LANGUAGE == "Russian" then
        available_fonts = {
            {
                ["name"] = "2002",
                ["id"] = "2002.ttf",
            },
            {
                ["name"] = "Arial Narrow",
                ["id"] = "ARIALN.ttf",
            },
            {
                ["name"] = "Friz Quadrata (Cyrilic)",
                ["id"] = "FRIZQT___CYR.ttf",
            },
        }
        -- Chinese so only Arkai
    elseif MTSLUI_CURRENT_LANGUAGE == "Chinese" then
        available_fonts = {
            {
                ["name"] = "Arkai",
                ["id"] = "ARKai_T.ttf",
            },
        }
        -- Korean, so only 2002
    elseif MTSLUI_CURRENT_LANGUAGE == "Korean" then
        available_fonts = {
            {
                ["name"] = "2002",
                ["id"] = "2002.ttf",
            },
        }
    -- all other locales
    else
        available_fonts = {
            {
                ["name"] = "2002",
                ["id"] = "2002.ttf",
            },
            {
                ["name"] = "Arial Narrow",
                ["id"] = "ARIALN.ttf",
            },
            {
                ["name"] = "Friz Quadrata",
                ["id"] = "FRIZQT__.ttf",
            },
            {
                ["name"] = "Morpheus",
                ["id"] = "morpheus.ttf",
            },
            {
                ["name"] = "Skurri",
                ["id"] = "skurri.ttf",
            },
        }
    end

    return available_fonts
end
