-- Client-side gang data management
SolitudeGang.Data = SolitudeGang.Data or {}
SolitudeGang.Data.LocalGang = nil -- Current player's gang information
SolitudeGang.Data.GangCache = {} -- Cache of known gangs

-- Gang structure:
-- {
--     id = number,
--     name = string,
--     leader = Player,
--     members = {Player, ...},
--     created = number (timestamp),
--     level = number,
--     xp = number,
--     bank = number,
--     maxMembers = number
-- }

function SolitudeGang.Data:SetLocalGang(gangData)
    self.LocalGang = gangData
    hook.Run("SolitudeGang.GangUpdated", gangData)
end

function SolitudeGang.Data:GetLocalGang()
    return self.LocalGang
end

function SolitudeGang.Data:IsInGang()
    return self.LocalGang ~= nil
end

function SolitudeGang.Data:IsGangLeader()
    if not self:IsInGang() then return false end
    return self.LocalGang.leader == LocalPlayer()
end

function SolitudeGang.Data:CacheGang(gangData)
    self.GangCache[gangData.id] = gangData
end

function SolitudeGang.Data:GetCachedGang(gangId)
    return self.GangCache[gangId]
end

function SolitudeGang.Data:ClearLocalGang()
    self.LocalGang = nil
    hook.Run("SolitudeGang.GangLeft")
end

-- Get gang member count
function SolitudeGang.Data:GetMemberCount()
    if not self:IsInGang() then return 0 end
    return #self.LocalGang.members
end

-- Check if player is in the local gang
function SolitudeGang.Data:IsMemberOfLocalGang(ply)
    if not self:IsInGang() then return false end
    
    for _, member in ipairs(self.LocalGang.members) do
        if member == ply then
            return true
        end
    end
    
    return false
end

-- Get gang level requirements
function SolitudeGang.Data:GetLevelXPRequired(level)
    return level * 1000 -- 1000 XP per level
end

-- Calculate gang level progress
function SolitudeGang.Data:GetLevelProgress()
    if not self:IsInGang() then return 0 end
    
    local required = self:GetLevelXPRequired(self.LocalGang.level)
    return self.LocalGang.xp / required
end
