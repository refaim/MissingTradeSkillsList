---@shape TradeSkillsData
---@field AMOUNT_RANKS table<ProfessionId, number>
---@field MIN_PATCH_LEVEL Phase
---@field MAX_PATCH_LEVEL Phase
---@field CURRENT_PATCH_LEVEL Phase
---@field PHASE_IDS number[]
---@field continents Entity[]
---@field factions Entity[]
---@field holidays Holiday[]
---@field items table<ProfessionId, Item[]>
---@field levels table<ProfessionId, ProfessionLevel[]>
---@field npcs NPC[]
---@field objects Object[]
---@field professions table<ProfessionId, Entity>
---@field profession_ranks table<string, Entity>
---@field quests Quest[]
---@field reputation_levels Entity[]
---@field skills table<ProfessionId, Skill[]>
---@field special_actions table<string, Entity>
---@field specialisations table<ProfessionId, Specialisation[]>
---@field zones Zone[]


------------------------------------------------- Shared -------------------------------------------------
---@alias ProfessionId "Alchemy" | "Blacksmithing" | "Cooking" | "Enchanting" | "Engineering" | "First Aid" | "Fishing" | "Herbalism" | "Leatherworking" | "Mining" | "Poisons" | "Skinning" | "Tailoring"

---@alias Language "Chinese" | "English" | "French" | "German" | "Korean" | "Mexican" | "Portuguese" | "Russian" | "Spanish" | "Taiwanese"
---@alias Translation table<Language, string>

---@alias Phase 1 | 2 | 3 | 4 | 5 | 6

---@shape LevelRange
---@field min number
---@field max number

---@shape Location
---@field x string
---@field y string

---@shape EmptyLocation: Location
---@field x "-"
---@field y "-"

---@shape Entity
---@field id number
---@field name Translation


------------------------------------------------- Holidays -------------------------------------------------
---@shape Holiday
---@field id number
---@field name Translation
---@field phase Phase


---------------------------------------------------- Items -------------------------------------------------
---@alias ItemQuality "common" | "uncommon" | "rare" | "epic"

---@shape ItemLevelRange
---@field min_xp_level number
---@field max_xp_level number

---@shape ItemWorldDropInfo
---@field range ItemLevelRange

---@shape ItemSourceDropInfo
---@field sources number[]

---@shape Item
---@field id number
---@field name Translation
---@field quality ItemQuality
---@field phase Phase

---@shape DropItem: Item
---@field drops ItemWorldDropInfo | ItemSourceDropInfo

---@shape QuestItem: Item
---@field quests number[]

---@shape TrainerInfo
---@field price number
---@field sources number[]

------------------------------------------------- Levels -------------------------------------------------
---@shape ProfessionLevel
---@field id number
---@field name Translation
---@field min_skill number
---@field max_skill number
---@field min_xp_level number
---@field phase Phase
---@field rank number

---@shape TrainedProfessionLevel
---@field trainers TrainerInfo


------------------------------------------------- NPCs -------------------------------------------------
---@alias Reaction "Alliance" | "Horde" | "Hostile" | "Neutral"

---@shape NPCLevelInfo
---@field min number | "??"
---@field max number | "??"
---@field is_elite 0 | 1

---@shape NPC
---@field id number
---@field name Translation
---@field phase Phase
---@field reacts Reaction
---@field xp_level NPCLevelInfo
---@field zone_id number

---@shape WorldNPC: NPC
---@field location Location

------------------------------------------------- Objects -------------------------------------------------
---@shape Object
---@field id number
---@field location Location
---@field name Translation
---@field phase Phase
---@field zone_id number


------------------------------------------------- Quests -------------------------------------------------
---@shape Quest
---@field id number
---@field min_xp_level number
---@field name Translation
---@field phase Phase

---@shape NpcQuest: Quest
---@field npcs number[]

---@shape ObjectQuest: Quest
---@field objects number[]

---@shape ItemQuest: Quest
---@field items number[]

---@shape SpecialActionQuest: Quest
---@field special_action string


------------------------------------------------- Skills -------------------------------------------------
---@shape Skill
---@field id number
---@field name Translation
---@field min_skill number
---@field phase Phase

---@shape TrainedSkill: Skill
---@field trainers TrainerInfo

---@shape SpecialActionSkill: Skill
---@field special_action string

------------------------------------------------- Specialisations -------------------------------------------------
---@shape Specialisation
---@field id number
---@field name Translation
---@field min_skill number
---@field phase Phase
---@field quests number[]


------------------------------------------------- Zones -------------------------------------------------
---@shape Zone
---@field cont_id number
---@field id number
---@field name Translation
---@field levels LevelRange
