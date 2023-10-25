---@class MTSL_Infrastructure_PlayerRepository: MTSL_Domain_PlayerRepository
MTSL_Infrastructure_PlayerRepository = mtsl_declare_class({ implements = MTSL_Domain_PlayerRepository })

---@alias InfrastructureSavedPlayerList table<string, table<string, InfrastructureSavedPlayerData>>
---@type InfrastructureSavedPlayerList
MTSL_PLAYERS = getglobal('MTSL_PLAYERS') or {}

---@shape InfrastructureSavedPlayerData
---@field NAME string
---@field CLASS string
---@field FACTION string
---@field REALM string
---@field XP_LEVEL number
---@field TRADESKILLS table<string, InfrastructureSavedPlayerTradeSkillData>

---@shape InfrastructureSavedPlayerTradeSkillData
---@field NAME string
---@field AMOUNT_LEARNED number
---@field LEARNED_SKILLS number[]
---@field MISSING_SKILLS number[]
---@field AMOUNT_MISSING number
---@field SKILL_LEVEL number

---@return MTSL_Infrastructure_PlayerRepository
function MTSL_Infrastructure_PlayerRepository.Construct()
    return mtsl_new(MTSL_Infrastructure_PlayerRepository)
end

function MTSL_Infrastructure_PlayerRepository:FindAll()
    ---@type MTSL_Domain_Player[]
    local players = {}

    for realm, name_to_player_data in pairs(MTSL_PLAYERS) do
        for name, player_data in pairs(name_to_player_data) do
            local trade_skills = {}
            for skill_name, skill_data in pairs(player_data.TRADESKILLS) do
                local learned_skill_ids = {}
                for _, skill_id in ipairs(skill_data.LEARNED_SKILLS) do
                    tinsert(learned_skill_ids, MTSL_Domain_VO_SkillId.Construct(skill_id))
                end

                local missing_skill_ids = {}
                for _, skill_id in ipairs(skill_data.MISSING_SKILLS) do
                    tinsert(missing_skill_ids, MTSL_Domain_VO_SkillId.Construct(skill_id))
                end

                local trade_skill = MTSL_Domain_PlayerTradeSkill.Construct(
                    MTSL_Domain_VO_TradeSkillId.Construct(skill_name),
                    MTSL_Domain_VO_Level.Construct(skill_data.SKILL_LEVEL),
                    learned_skill_ids,
                    missing_skill_ids)

                tinsert(trade_skills, trade_skill)
            end

            local player = MTSL_Domain_Player.Construct(
                MTSL_Domain_VO_PlayerId.Construct(realm, name),
                MTSL_Domain_VO_PlayerClass.Construct(player_data.CLASS),
                MTSL_Domain_VO_Faction.Construct(player_data.FACTION),
                MTSL_Domain_VO_Level.Construct(player_data.XP_LEVEL),
                trade_skills)

            tinsert(players, player)
        end
    end

    return players
end

function MTSL_Infrastructure_PlayerRepository:Persist(player)
    ---@type table<string, InfrastructureSavedPlayerTradeSkillData>
    local trade_skills = {}

    for _, skill in ipairs(player:GetTradeSkills()) do
        local learned_skill_ids = {}
        for _, skill_id in ipairs(skill:GetLearnedSkillIds()) do
            tinsert(learned_skill_ids, skill_id:AsNumber())
        end

        local missing_skill_ids = {}
        for _, skill_id in ipairs(skill:GetMissingSkillIds()) do
            tinsert(missing_skill_ids, skill_id:AsNumber())
        end

        ---@type InfrastructureSavedPlayerTradeSkillData
        local skill_data = {
            NAME = skill:GetName(),
            SKILL_LEVEL = skill:GetLevel():AsNumber(),
            LEARNED_SKILLS = learned_skill_ids,
            AMOUNT_LEARNED = getn(learned_skill_ids), -- TODO это избыточная информация
            MISSING_SKILLS = missing_skill_ids, -- TODO полагаю, что это вообще не надо хранить в игроке, потому что набор скиллов может поменяться на сервере, и тогда эти данные устареют
            AMOUNT_MISSING = getn(missing_skill_ids), -- TODO это избыточная информация
        }

        trade_skills[skill:GetName()] = skill_data
    end

    MTSL_PLAYERS[player:GetRealm()][player:GetName()] = {
        NAME = player:GetName(),
        CLASS = player:GetClass():AsString(),
        FACTION = player:GetFaction():AsString(),
        REALM = player:GetRealm(),
        XP_LEVEL = player:GetLevel():AsNumber(),
        TRADESKILLS = trade_skills,
    }
end

function MTSL_Infrastructure_PlayerRepository:Remove(player_id)
    local realm = player_id:GetRealm()
    local name = player_id:GetName()

    -- TODO протестировать разыменование nil
    if MTSL_PLAYERS[realm][name] == nil then
        return false
    end

    MTSL_PLAYERS[realm][name] = nil

    if mtsl_is_empty(MTSL_PLAYERS[realm]) then
        MTSL_PLAYERS[realm] = nil
    end

    return true
end

function MTSL_Infrastructure_PlayerRepository:RemoveAll()
    MTSL_PLAYERS = --[[---@type InfrastructureSavedPlayerList]] {}
end
