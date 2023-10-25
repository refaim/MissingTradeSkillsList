---@return MTSL_Domain_Player[]
function MTSL_Domain_PlayerRepository:FindAll() end

---@param player MTSL_Domain_Player
function MTSL_Domain_PlayerRepository:Persist(player) end

---@param player_id MTSL_Domain_VO_PlayerId
---@return boolean
function MTSL_Domain_PlayerRepository:Remove(player_id) end

function MTSL_Domain_PlayerRepository:RemoveAll() end
