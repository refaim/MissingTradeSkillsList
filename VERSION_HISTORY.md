## Version History

### v1.17.1 (Nov 1, 2023)

* Fix broken dropdown controls in config window

### v1.17 (Oct 26, 2023)

* Remove Classic WoW content phases support

### v1.16.2 (Oct 25, 2023)

* Fix quests lookup

### v1.16.1 (Oct 25, 2023)

* Fix TradeSkillsData-turtle support

### v1.16 (Oct 7, 2023)

* Add recipe known status to many types of ingame tooltips
* Fix "Too many buttons" dropdown menu error

### v1.15 (Oct 6, 2023)

* Fix linking recipes to chat
* Port Classic tooltip hook to Vanilla

### v1.14 (Oct 6, 2023)

* Port to Vanilla WoW 
* Use TradeSkillsData addon instead of built-in database
* Extract Turtle-specific data into TradeSkillsData-turtle addon

### v1.13.54 (May 31, 2021)

* Updated skill, item & specialisation translations for all languages except for Korean, simplified Chinese and traditional Chinese to match live data
* Updated wrong prices from vendor to match live data

### v1.13.53 (May 30, 2021)

* Fixed bugs
  * Solved lua errors when running addon for first time
  * Updated MTSL locales
* Data patch level is now set automatic, option is removed from options menu

### v1.13.52 (May 27, 2021)

* Updated .toc for Naxx
* Overwritten data patch phase to MAX, you can still reset it with options menu if needed
* Added options
  * Show source for a recipe in the tooltip
  * Added filter option to show/hide recipes "Alliance only" & "Horde only"
  * Recipes obtainable only by opposite faction are hidden by default (Not in Database explorer)
* Fixed bugs
  * Thistle Tea (Cooking) is now only shown & counted for rogues
  * Learning / unlearning a profession now proper updates character & account explorer frame
  * Changing zone now properly changes "Current zone" in all MTSL frames
* Fixed data
  * Mooncloth Boots (Tailoring) now requires friendly with Timbermaw Hold
  * Drakk Stonehand now resides in The hinterlands
  * Ezekiel Graves was replaced with Gregory Charles as Poison trainer

### v1.13.51 (Aug 17, 2020)

* Fixed bugs
  * Unlearning a primary profession now removes it correctly from data
  * Learning a profession did not save the skills automatically gained without opening the tradeskill/craftframe
* Added code to count number of skills per profession and phase to have numbers matching the data
* Added code to check/verify the saved data when loading a character
* Added check when logging in to remove unlearned professions

### v1.13.50 (Aug 14, 2020)

* Added character explorer frame
  * View for currently logged in character the missing skills for all learned professions
  * Allows the addon to be used when another addon overrides TradeskillFrame UI (e.g. TSM)
  * Added options to set scale & UI split in options menu
  * This frame is NOT updated on new learned skills, you have to open the respective TradeskillFrame/CraftFrame first to allow updates on list
* Added/Changed the following slash commands
  * /mtsl or /mtsl char now opens the character explorer frame
  * Options menu now only accessible through /mtsl options, /mtsl config or using minimap button
* Added/Changed the following click events on minimap button
  * Ctrl + Left click : opens Character explorer
  * Ctrl + Alt + Left Click: opens Account explorer

### v1.13.49 (Aug 11, 2020)

* Drop downs with checkboxes in filterframe now keep open when selecting a checkbox until you close the list or wait a few seconds
* Fixed bugs (Remember to rescan each character affected)
  * Racial prevented herbalism skills to be proper marked as learned for Tauren
  * Starting skills learned when learning a profession are now properly shown in the account explorer
* Fixed data (Changed phase 5 to 6)
  * Ironvine Breastplate, Ironvine Gloves, Ironvine Belt (Blacksmithing)
  * Bramblewood Helm, Bramblewood Vest, Bramblewood Belt (Leatherworking)
  * Gaea's Embrace, Sylvan Crown, Sylvan Shoulders, Sylvan Vest (Tailoring)

### v1.13.48 (Jul 30, 2020)

* Fixed bugs
  * Skills obtained through "Neutral" NPC are again shown in the list
* Added "Neutral" as faction in the filters
* Limited the phases in MTSL again to search for missing skills in the current set data patch level.

### v1.13.47 (Jul 29, 2020)

* Removed unused code
* Optimized searching by name of recipe
* Added raidnames for each data patch level
* Removed code for automatic current data patch level.
  * If you used it, your data patch level will be reset to 1. Use the options menu to change it!
  * Allowed to show/scan for all data patch levels in MTSL, not only up to current set level.
  * By default only phases are selected in filter frame up to selected current level.
* Changed way filters work, you can now select multiple values per filter (except for continent/zone)
* Fixed following data
  * "Pearl-handled Dagger" (Blacksmithing) is now trained at 115

### v1.13.46 (Jun 15, 2020)

* Changed/optimized the way scanning missing skills works for Enchanting
* Fixed bug
  * Kalimdor was not always present in filters for continents
  * Added missing texture icons for Fishing, Herbalism & Skinning to NPC explorer frame
* Fixed following data
  * Removed "Dawnbringer Shoulders" (Blacksmithing)
  * Enchanting skills (Russian locale) should now show properly when known
  * "Goblin Jumper Cables XL" (Engineering) now have the proper specialisation "Goblin Engineering"

### v1.13.45 (Jun 14, 2020)

* Fixed following learning skill level for data
  * Big Bronze Knife, now 105
  * Truesilver Gauntlets, now 225
  * Linen Belt, now 15
  * The Big One, now 235
  * Goblin Rocket Helmet, now 245
  * Gnomish Mind Control Cap, now 235
  * Inlaid Mithril Cylinder Plans, now 205
* Fixed following data
  * Added trainers for "Elixir of Fortitude" (Alchemy)
  * Translation mistakes in Spanish enchanting formulas with stamina
* Fixed bugs
  * Tooltip from minimap button now correctly hides when the mouse is no longer moved over the button
* Profession list in Database explorer & account explorer is not sorted/shown based on name
* Added missing translations for quest objects
* Added ability to move/drag the MTSL window seperate from TradeSkillFrame/CraftFrame. Resets position after reopening TradeSkillFrame/CraftFrame
* Added support for Fishing, Herbalism & Skinning
  * Database explorer lets you see the ranks and how to train them
  * View trainers & vendors in NPC explorer frame
  * Added skill level for characters/alts to account frame

### v1.13.44 (May 28, 2020)

* Fixed following data
  * Set phase of "Smoked Sagefish" (Cooking), "Soul Pouch" (Tailoring) to 1
  * Set phase of "Big Bag of Enchantment (Tailoring)" to 5
  * Set phase of "Runed Stygian Leggings, Boots & Belt (Tailoring)", Gurubashi Mojo Madness ("Alchemy") to 4
  * Removed double entry for "Goblin Rocket Boots (Engineering)"
  * Set skill of "Mithril Scale Pants (Blacksmith)" to 210 instead of 205
  * French translation of "Feralas" corrected to "Féralas"
  * Shifting Cloak (Leatherworking) has now correct specialisation "Elemental"
  * Removed font "Arkai" to be choosen on non Chinese locales
* Added option to select where MTSL window opens relative to button
  * You can select if window opens left or right side of the MTSL button and so allowing to overlap with the craft window

### v1.13.43 (Apr 8, 2020)

* Improved code to set a waypoint
* Improved code of the options menu frame
* Pressing "escape" while in a searchbox will also now trigger the search
* Added option to hide alts/characters in tooltip if they learned the recipe
* Added Darkmoon Faire as Holiday
* Fixed bug where text of "Current zone" & list of skills did not update when changing zones
* Fixed following data
  * Added NPC for Darkmoon Faire quests
  * Chinese translation for "Manual: Strong Anti-Venom"
  * "Blight" in Blacksmithing now requires weaponsmith specialisation
  * Gnomish Alarm-o-bot now requires gnomish engineering
  * Magnus Frostwake is no longer in Winterspring but in Western Plaguelands
  * Changed phase of schematic for steam tonk controller to 6 (unclear wether it is/will be available)

### v1.13.42 (Mar 30, 2020)

* Fixed bug where not all skills obtained from object were shown when filtering on that source type
* Fixed bug where TRAINER_UPDATE event did not correctly update the MTLS window
* Fixed bugs in the NPC explorer frame
* Fixed translations for profession name "Tailoring" for Spanish and Mexican Spanish, they got swapped around
* Improved coding on filter frame

### v1.13.41 (Mar 27, 2020)

* Fixed wrong Russian translations on skills & items
* Fixed bug where waypoints could not be created from a secondary source
* Fixed bug where recipes obtained from an object could not be linked to chat or have their tooltip shown
* Fixed wrong zone numbers for Ashenvale, added zone numbers to "Current zone" label as well
* Fixed bug with filter frame
  * Filters should now work correctly again
  * When opening another frame or changing profession, all filters are now reset to their default values
  * It might appear filtering is not working, but this is due to lag/caching of frames ingame, reopen the window a few times and it should work
* Limited the options for font setting to valid fonts only for your locale so text will nog longer be displayed with ????
* Account explorer no longer shows characters who haven't learned any profession
* Added coloring to show if player has the required reputation with faction or not (if one is needed)
* Changed how to insert an item to chat from Shift + Left click to Right click
* Changed the channels for linking items:
  * Added "RAID" as a possible channel to link an item too, if not in raid "SAY" will be used
  * Added Option "Auto" to set channel for all linking (Now default value, instead of "SAY")
    * When using "Auto", you select the channel when you click the item
      * Left click = SAY
      * Ctrl Click = Guild
      * Shift click = Party
      * Alt click = Raid

### v1.13.40 (Mar 23, 2020)

* Fixed wrong Russian translations on skills & items
* Added ability to insert a recipe in the current chat message
    * Shift + Click on the name of a recipe in the "Detailsframe" to insert it to current chat message

### v1.13.39 (Mar 20, 2020)

* Fixed a bug with the enhanced tooltip
* Added ability to share a recipe in chat
    * Click on the name of a recipe in the "Details" section of a spell/skill to link it to chat
    * Added options to set the channel on which to share the recipe (Say, Party or Guild)
    * If channel is set to "guild" but the player is not in a guild, say channel will be used
    * If channel is set to "party" but the player is not in a party, say channel will be used
* Added missing localisation for all the labels on the options frame

### v1.13.38 (Mar 19, 2020)

* Updated the addon icon/logo to show all 10 supported tradeskills
* Added levels to each "normal" zone in the filter frame
* Added world drop recipes to be shown for a current zone if that zone's levels are within the drop range of the recipe
* Fixed a bug with the enhanced tooltip
* Fixed a bug with the filter frame
* Fixed a bug with numbers shown in the progressbar in the MTLS window
* Checked & verfified all Tailoring data

### v1.13.37 (Mar 15, 2020)

* Added support for classic wow version 1.13.4
* Fixed bug where MTSL button was missing for Enchanting
* Checked & verfified all Leatherworking data

### v1.13.36 (Mar 9, 2020)

* Reduced amout of files in the addon and renamed a lot of files too. Make sure to **delete** your current addon folder first before extracting new version!
* Fixed bug where missing skills were no longer colored based on current skill in MTSL window
* Added localisation for Taiwanese (Traditional Chinese) [Big thanks to dalanwoopy]
* Checked & verfified all Engineering data
* Optimised a lot of code and removed unused code
* Checked & verified all phases of the skills
* All skills are translated to their respective localisation

### v1.13.35 (Feb 17, 2020)

* Enabled option again to set patch level used in addon (1-6)
  * Added option to filter to use current level (is set automaticly, based on buildnumber client)
* Changed dragging of MinimapButton to RMB, to avoid moving it while clicking it with LMB
* Added option to NPC explorer frame to show Specialisation Trainers
* Checked & verified data for Enchanting
* Dynamic filtering of skills in MTSL window
  * When player knows a specialisation, all other specialisations and their skills are hidden
  * When a player does not know any specialisation, all specialisations & skills are shown
* Fixed bugs in the options menu
  * The "Default" button will again reset the values correctly
  * The "Save" button should again work correctly

### v1.13.34 (Feb 3, 2020)

* Update skills know count number to now show the number for the current phase but also total number after all content is released
    * Updated numbers in progressbar to not only show current max amount of recipes but also the total in the end (= number between [])
    * Updated numbers in Database explorer under each profession icon to not only show current max amount of recipes but also the total in the end (= number between [])
    * Extra number between [] is not shown if current phase already has all total skills to be released
* Added NPC explorer frame (/mtsl npc or alt + left click on minimap button)
    * Shows a list of all available NPCs that teaches a skill, drop/vendor recipe or start quest
    * Ability to filter by: Name, Faction, Profession, Type/Source, trainer rank, Zone
    * Icons showing standing of NPC (skull if hostile/mob, mix Alliance/horde icon for Neutral)
    * Icons showing the profession to which the skill belongs
* Added options to config menu to allow scaling & setting of splitmode of NPC explorer frame
* Added buttons to each Explorer frame to be quickly swap to another explorer frame (Between Account, Database and NPC)
* Corrected & verified all Blacksmithing data

### v1.13.33 (Jan 24, 2020)

* Fixed bug that prevented minimap settings from being saved
* Fixed bug that prevented enhanced tooltip settings from being saved
* Added patch levels between current and max for filtering in Database & Account explorer
* Added correct XP level needed to train each rank for each profession
* Checked, Corrected & Verified all skills/items/levels of Cooking, First Aid, Mining & Poisons
* Added more localisation strings
* Fixed bug where addon frames sometimes where not always shown on top
* Improved moving minimap button code, it should move smoothly now
* Set patch level of content back to 2 instead of 3

### v1.13.32 (Jan 19, 2020)

* Added enhancement to tooltip to show status of your other characters (on same realm) for the recipe
    * Green = learned
    * Orange = not learned but high enough skill to learn
    * Red = not learned and too low skill
* Added options to optionsmenu
    * Enhance tooltip (Default on)
    * Show all alts on same realm or only only alts with same faction (Default = same faction)
* Removed options from optionsmenu
    * Set content patch/phase level (now hardcoded again)
* Added label to show content phase in detailswindow of a skill
* Fixed a bug where source type for alternative source of skill did not show properly
* Fixed a bug where searching for partial skill did not always result in correct skills list
* Fixed a bug where skills with multiple sources did not filter correctly when choosing a specific zone
* Added an option to filter by faction (Alliance, Horde or any faction that uses reputation)
* Removed labels in filter frame to save space => added text to the "Any" option for each filter

### v1.13.31 (Jan 9, 2020)

* Fixed bug that always opened MTSL window even if option was disabled
* Fixed bug in options menu where checkboxes were always shown as checked even if they were not
* Added an event to capture "ding" of player to update XP level while playing
* Fixed bug where MTSL account explorer did not work for other locales then English
* Fixed a refresh bug in MTSL account explorer when changing characters, the list did not update
* Slashcommands now work case insensitive

### v1.13.30 (Jan 8, 2020)

* Fixed the help text with wrong slashcommand text
* Added lots of missing Korean & Chinese quest names
* Added poisons
* Fixed bug where Current Zone of player did not update/display correct in the filter frame

### v1.13.29 (Jan 3, 2020)

* Fixed some wrong Chinese translations
* Added minimap button (Default on and shown at top of minimap)
    * Left Click: opens MTSL options menu
    * Ctrl + Left Click opens MTSL account explorer
    * Shift + Left Click: opens MTSL database explorer
* Added options to configure minimap button
    * Activate/Deactivate the minimap button (Default on)
    * Button radius compared to minimap edge (Default 0)
    * Shape of the minimap (Default circle)

### v1.13.28 (Dec 23, 2019)

*   Compatible game version 1.13.3
*   Added an option to directly show MTSL when opening a profession window
*   Added an option to set the current content patch level used to show data
*   Fixed some wrong Korean translations
*   Added translations for Mexican Spanish for all skills, recipes, items & specialisations. Other data is copied from Spanish

### v1.13.27 (Dec 7, 2019)

*   Checked and fixed all Alchemy data
*   Added some missing translations, almost all in-game items done
*   Comparing known skills by name without spaces to avoid conflicts with number of spaces

### v1.13.26 (Nov 17, 2019)

*   Fixed wrong quest data
*   Fixed some wrong translations
*   Fixed some wrong profession data
*   Fixed all remaining spells with minimum skill of 0 to have correct minimum skill needed to learn
*   Fixed bug that prevented correct update of player list frame

### v1.13.25 (Nov 8, 2019)

*   Added specialisations as skills too
*   Fixed some wrong recipes
*   Added holidays as source type
*   Added label to show the holiday needed to get a skill
*   Added label to show the sourcetype of a sources of a skill (e.g.: if skill is obtained from recipe, you can also see the sourcetype of the recipe)
*   Fixed bug when using the sourcetype filter
*   Fixed bug when using the phase filter

### v1.13.24 (Oct 27, 2019)

*   Fixed some Blacksmithing data
*   Added translations to some of the options menu labels/buttons
*   Added label for "realm" and "character" in options menu
*   Improved French localization
*   Translated all special actions to each locale

### v1.13.23 (Oct 26, 2019)

*   Added option to change font type & size of Titles, labels & text
    *   UI will auto reload if changed
    *   Does not affect buttons & dropdowns
*   Improved French localization

### v1.13.22 (Oct 25, 2019)

*   Fixed bug for addon not working for engineering by adding ranks to the levels
*   Default selected current character in mtsl options screen

### v1.13.21 (Oct 24, 2019)

*   Added specialisations to spells (Blacksmithing, Engineering & Leatherworking)
*   Fixed some engineering recipes
*   Fixed bug with lower trained ranks still shown in list
*   Only hooked MTSL to SkilletFrame if also used/visible
*   Replaced sort option by level/name by option to search by (partial) name
*   Added filter option for source type of skill (Trainer, Quest, Vendor, Drop, Object)
*   Added filter option for specialisations

### v1.13.20 (Oct 13, 2019)

*   Fixed wrong translations
*   Fixed some lua errrors
*   TradeSkillFrame & CraftFrame are now draggable
*   Added menu option to hook MTSL button left or right on TradeSkillFrame/CraftFrame
*   Support for SkilletFrame for CraftFrame as well

### v1.13.19 (Oct 12, 2019)

*   Account Explorer uses different code to show learned skills (**resave all players/professions**)
*   Colored skill level in Account Explorer to show status
    *   Green : learned
    *   Orange : can be learned
    *   Red : can not be learned
*   Changes to options menu:
    *   Added UI split-orientation option for all 3 main windows (will reset current saved scale!)
    *   Redesigned scaling to drop downs for compacter/better view
*   Fixed some wrong translations
*   Account explorer & options menu window is now movable/draggable
*   Refactored UI code making all 3 main windows appear/use same code
*   Split up datafile with continents & zones
*   Moved "Kalimdor" up in filterlist before "The Eastern Kingdoms"
*   Numerous code fixing for smaller filesize addon & faster running
*   Sort players by name/realm in Account Explorer & Database explorer view
*   Filters players by realm in Account Explorer & Database explorer view

### v1.13.18 (Oct 1, 2019)

*   Changed way options/config is saved so current saved scale will be reset first time!
*   Fixed scaling bug
*   Fixed some wrong translations
*   Split the location filter up into 2 dropdowns (1 for continent & 1 for subzone)
*   Added "continents" for Dungeon, Raid & BG to "lighten" the mount of subzones in each drop down
*   Added a configuration menu (/mtsl or /mtsl config or /mtsl options) to allow more user UI tweaking
    *   Choose splitdirection (Horizontal/Vertical) for MTSL main window (NOT Account or Database explorer)
    *   UI Scaling for each Frame (Keep in mind that if other addon scales window, it adds to that scale)
    *   Choose default font (not yet available)
    *   Remove a character
    *   Clear all saved data and restore default values
*   Slash commands for user config have been removed

### v1.13.17 (Sep 29, 2019)

*   Translated all built-in MTSL labels (Report mistakes or improvements in opened Issues tickets)
*   Added support for Skillet-Classic addon

### v1.13.16 (Sep 29, 2019)

*   Added check to only add "current zone" to list of zone filter when possible (does not always find the zone)

### v1.13.15 (Sep 29, 2019)

*   Added content phases to items
    *   Only shows obtainable (current in game) skills next to tradeskill/craft window
    *   Ability to show items only for current phase or all in Database explorer
*   Ability to sort (name, level) or (name & realm) in Account & Database Explorer
*   Ability to filter on zone (All, current, specific zone) in Database Explorer
    *   World drops ignored when filtering on specific zone
*   Ability to filter on zone (All, current) in MTSL window
*   Translated some of the MTSL labels

### v1.13.14 (Sep 27, 2019)

*   Added support for Chinese & Korean locales
*   Translated all the NPC's, objects & quests to have their localised name
*   Changed default font to Arial Narrow to save space

### v1.13.13 (Sep 24, 2019)

*   Added checks for hunter beast training

### v1.13.12 (Sep 22, 2019)

*   Fixed some wrong translations
*   Fixed Account explorer when a character has no known tradeskills
*   Fixed width of selected/hoovered listitems to fill the frame
*   Expanded width of listframes to show all text (French text was sometimes outside frame)
*   Added localised names for factions

### v1.13.11 (Sep 22, 2019)

*   Added localised names for zones (TomTom waypoints should now work in all supported languages)
*   Fixed bug where Enchanting was no longer available for addon
*   Fixed some wrong data

### v1.13.10 (Sep 20, 2019)

*   Added Account explorer window (/mtsl acc or /mtsl account)
*   Added colors for factions (red = Horde, blue = Alliance)
*   Added frames to visible see which profession is selected in Database & Account explorer
*   Added extra check for craftwindows, only "Enchanting" will trigger MTSL

### v1.13.09 (Sep 16, 2019)

*   Added integration for TomTom waypoints. (Needs TomTom installed)
    *   Click on a name of NPC/object to get add a waypoint
    *   Only tested on English client
    *   Warning will be printed if TomTom is not installed (only 1 time)
*   Database Explorer window now also hides if u press "Esc" key
*   Fixed bug with Fontsize of labels
*   Fixed bug with Russian naming for Mining profession
*   Fixed a bug in code for event "TRAINER_UPDATE"
*   Fixed some wrong data

### v1.13.08 (Sep 16, 2019)

*   Russian characters are now shown properly
*   Added additional check for poisons of rogues
*   Removed debugging prints

### v1.13.07 (Sep 15, 2019)

*   Fixed bug that Poisons frame of rogue was seen as Tradeskill (TradeSkill might be added later on)
*   Characters are once again saved!
*   Added conversion for old saved data to new structure
*   Able to remove saved data for a character (use /mtsl remove <name char> <name realm>)
*   Able to reset the saved data (use /mtsl reset)

### v1.13.06 (Sep 15, 2019)

*   Added support all languages (Built-in labels & texts still in English)
*   Added scaling of Database Explorer.
    *   use /mtsl scale <scale number> to set it (0.5-1.25)
    *   Scale is saved
*   Trainer update event only triggers refresh of skills if trainer of the current shown profession is opened
*   Crafting items should not trigger update/refresh of UI

### v1.13.05 (Sep 13, 2019)

*   Added tooltips on mouse over for skills & recipes
*   Added message if quest not available for your faction
*   Added character view panel to Database Explorer which lets you see if characters can learn the skill
*   Database Explorer window is draggable
*   Automatic selecting first skill (if one is available) when opening/showing the window

### v1.13.04 (Sep 13, 2019)

*   Added Database explorer window:
    *   Check out any skill for any profession
    *   to open: use /mtsl db or /mstl database

### v1.13.03 (Sep 11, 2019)

*   Fixed UI for main scrollbar
*   Changed scrolling to 5 items at a time
*   Moved the MTSL button above the tradeskill/craft window to avoid overlap other addons
*   Fixed the layout when a skill has multiple sources (Bug nr 2)

### v1.13.02 (Sep 9, 2019)

*   Added check for locales. Only enUS or enGB are supported and will load

### v1.13.01 (Sep 9, 2019)

*   Initial version
