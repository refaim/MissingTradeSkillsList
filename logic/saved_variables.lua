------------------------------------------------------
-- Contains all functions for addon/saved variables --
------------------------------------------------------
----------------------------------
-- Creates all saved variables --
----------------------------------
MTSL_PLAYERS = {}

MTSL_LOGIC_SAVED_VARIABLES = {
    ------------------------------------------------------------------------------------------------
    -- Reset the saved players
    ------------------------------------------------------------------------------------------------
    RemoveAllCharacters = function(self)
        MTSL_PLAYERS = {}
    end,

    ------------------------------------------------------------------------------------------------
    -- Removes a character from the saved data
    --
    -- @name        String      The name of the character
    -- @realm       String      The name of the realm
    ------------------------------------------------------------------------------------------------
    RemoveCharacter = function(self, name, realm)
        local success = true
        if realm ~= nil and name ~= nil then
            if MTSL_PLAYERS[realm] == nil then
                print(MTSLUI_FONTS.COLORS.TEXT.ERROR .. "MTSL: Realm " .. realm .. " does not exist in saved data! Names are case sensitive")
                success = false
            elseif MTSL_PLAYERS[realm][name] == nil then
                print(MTSLUI_FONTS.COLORS.TEXT.ERROR .. "MTSL: Realm " .. realm .. " does not have saved data for " .. name .. "! Names are case sensitive")
                success = false
            else
                MTSL_PLAYERS[realm][name] = nil
                print(MTSLUI_FONTS.COLORS.TEXT.SUCCESS .. "MTSL: Removed " .. name .. " on realm " .. realm .. " from the saved data! Logout to complete.")
                -- check if realm is emppty, if so remove it as well
                if MTSL_LOGIC_PLAYER_NPC:CountPlayersOnRealm(realm) <= 0 then
                    MTSL_PLAYERS[realm] = nil
                end
            end
        else
            print(MTSLUI_FONTS.COLORS.TEXT.ERROR .. "MTSL: Realm and character name are needed to delete a character")
            success = false
        end
        return success
    end,
}
