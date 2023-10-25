---@class MTSL_Domain_Player
---@field __id MTSL_Domain_VO_PlayerId
---@field __level MTSL_Domain_VO_Level
---@field __class MTSL_Domain_VO_PlayerClass
---@field __faction MTSL_Domain_VO_Faction
---@field __trade_skills MTSL_Domain_PlayerTradeSkill[]
MTSL_Domain_Player = mtsl_declare_class({})

---@param id MTSL_Domain_VO_PlayerId
---@param level MTSL_Domain_VO_Level
---@param class MTSL_Domain_VO_PlayerClass
---@param faction MTSL_Domain_VO_Faction
---@param trade_skills MTSL_Domain_PlayerTradeSkill[]
---@return MTSL_Domain_Player
function MTSL_Domain_Player.Construct(id, class, faction, level, trade_skills)
    local object = mtsl_new(MTSL_Domain_Player)

    object.__id = id

    assert(mtsl_instance_of(level, MTSL_Domain_VO_Level))
    object.__level = level

    assert(mtsl_instance_of(class, MTSL_Domain_VO_PlayerClass))
    object.__class = class

    assert(mtsl_instance_of(faction, MTSL_Domain_VO_Faction))
    object.__faction = faction

    assert(mtsl_list_of(trade_skills, MTSL_Domain_PlayerTradeSkill))
    object.__trade_skills = trade_skills

    return object
end

---@return MTSL_Domain_VO_PlayerId
function MTSL_Domain_Player:GetId()
    return self.__id
end

---@return string
function MTSL_Domain_Player:GetName()
    return self.__id:GetName()
end

---@return string
function MTSL_Domain_Player:GetRealm()
    return self.__id:GetRealm()
end

---@return MTSL_Domain_VO_Level
function MTSL_Domain_Player:GetLevel()
    return self.__level
end

---@return MTSL_Domain_VO_PlayerClass
function MTSL_Domain_Player:GetClass()
    return self.__class
end

---@return MTSL_Domain_VO_Faction
function MTSL_Domain_Player:GetFaction()
    return self.__faction
end

---@param id MTSL_Domain_VO_TradeSkillId
---@return boolean
function MTSL_Domain_Player:HasTradeSkill(id)
    for _, v in ipairs(self:GetTradeSkills()) do
        if v:GetId():EqualsTo(id) then
            return true
        end
    end
    return false
end

---@param id MTSL_Domain_VO_TradeSkillId
---@return MTSL_Domain_PlayerTradeSkill
function MTSL_Domain_Player:GetTradeSkill(id)
    for _, v in ipairs(self:GetTradeSkills()) do
        if v:GetId():EqualsTo(id) then
            return v
        end
    end
    assert(false)
end

---@return MTSL_Domain_PlayerTradeSkill[]
function MTSL_Domain_Player:GetTradeSkills()
    return self.__trade_skills
end
