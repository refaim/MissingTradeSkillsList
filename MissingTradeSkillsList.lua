---------------------
-- Start the addon --
---------------------

-- Initialise our event handler
MTSLUI_EVENT_HANDLER:Initialise()

-- Add slash command for addon & use eventhandler to handle it
SLASH_MTSL1 = "/mtsl"
SLASH_MTSL2 = "/MTSL"

------------------------------------------------------------------------------------------------
-- Handles the event when slashcommand is typed in chat
------------------------------------------------------------------------------------------------
function SlashCmdList.MTSL(msg, editbox)
    -- Only execute if addon is fully loaded
    if MTSLUI_EVENT_HANDLER:IsAddonLoaded() then
        MTSLUI_EVENT_HANDLER:SLASH_COMMAND(msg)
    else
        MTSL_TOOLS:Print(MTSLUI_FONTS.COLORS.TEXT.ERROR .. "MTSL: " .. MTSLUI_TOOLS:GetLocalisedLabel("addon not loaded"))
    end
end
