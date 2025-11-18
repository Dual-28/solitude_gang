-- Server-side gang core functionality
if not SERVER then return end

SolitudeGang.Server = SolitudeGang.Server or {}
SolitudeGang.Server.Gangs = {}
SolitudeGang.Server.PlayerGangs = {} -- Player -> Gang ID mapping
SolitudeGang.Server.PendingInvites = {} -- Player -> {gangId, inviter}
SolitudeGang.Server.NextGangID = 1

-- Configuration
SolitudeGang.Config = {
    CreateCost = 50000,
    MaxMembers = 8,
    MaxGangNameLength = 32,
    MinGangNameLength = 3
}

-- Initialize network strings
util.AddNetworkString("SolitudeGang.SendGangData")
util.AddNetworkString("SolitudeGang.CreateGang")
util.AddNetworkString("SolitudeGang.CreateGangResponse")
util.AddNetworkString("SolitudeGang.LeaveGang")
util.AddNetworkString("SolitudeGang.LeaveGangResponse")
util.AddNetworkString("SolitudeGang.InvitePlayer")
util.AddNetworkString("SolitudeGang.ReceiveInvite")
util.AddNetworkString("SolitudeGang.AcceptInvite")
util.AddNetworkString("SolitudeGang.KickMember")
util.AddNetworkString("SolitudeGang.DisbandGang")
util.AddNetworkString("SolitudeGang.GangDisbanded")
util.AddNetworkString("SolitudeGang.MemberKicked")
util.AddNetworkString("SolitudeGang.RequestGangData")
util.AddNetworkString("SolitudeGang.DepositMoney")
util.AddNetworkString("SolitudeGang.WithdrawMoney")

-- Get player's money (DarkRP compatible)
function SolitudeGang.Server:GetPlayerMoney(ply)
    if ply.getDarkRPVar then
        return ply:getDarkRPVar("money") or 0
    end
    return 0
end

-- Set player's money (DarkRP compatible)
function SolitudeGang.Server:SetPlayerMoney(ply, amount)
    if ply.setDarkRPVar then
        ply:setDarkRPVar("money", amount)
    end
end

-- Add money to player
function SolitudeGang.Server:AddMoney(ply, amount)
    local current = self:GetPlayerMoney(ply)
    self:SetPlayerMoney(ply, current + amount)
end

-- Take money from player
function SolitudeGang.Server:TakeMoney(ply, amount)
    local current = self:GetPlayerMoney(ply)
    if current >= amount then
        self:SetPlayerMoney(ply, current - amount)
        return true
    end
    return false
end

-- Create a new gang
function SolitudeGang.Server:CreateGang(leader, gangName)
    -- Validate gang name
    if not gangName or gangName == "" then
        return false, "Invalid gang name"
    end
    
    if string.len(gangName) < SolitudeGang.Config.MinGangNameLength then
        return false, "Gang name too short (minimum " .. SolitudeGang.Config.MinGangNameLength .. " characters)"
    end
    
    if string.len(gangName) > SolitudeGang.Config.MaxGangNameLength then
        return false, "Gang name too long (maximum " .. SolitudeGang.Config.MaxGangNameLength .. " characters)"
    end
    
    -- Check if player is already in a gang
    if self.PlayerGangs[leader] then
        return false, "You are already in a gang"
    end
    
    -- Check if player has enough money
    if not self:TakeMoney(leader, SolitudeGang.Config.CreateCost) then
        return false, "You need $" .. string.Comma(SolitudeGang.Config.CreateCost) .. " to create a gang"
    end
    
    -- Create gang
    local gangId = self.NextGangID
    self.NextGangID = self.NextGangID + 1
    
    local gang = {
        id = gangId,
        name = gangName,
        leader = leader,
        members = {leader},
        created = os.time(),
        level = 1,
        xp = 0,
        bank = 0,
        maxMembers = SolitudeGang.Config.MaxMembers
    }
    
    self.Gangs[gangId] = gang
    self.PlayerGangs[leader] = gangId
    
    -- Send gang data to leader
    self:SendGangData(leader, gang)
    
    return true, "Gang created successfully!"
end

-- Get gang by ID
function SolitudeGang.Server:GetGang(gangId)
    return self.Gangs[gangId]
end

-- Get player's gang
function SolitudeGang.Server:GetPlayerGang(ply)
    local gangId = self.PlayerGangs[ply]
    if gangId then
        return self.Gangs[gangId]
    end
    return nil
end

-- Send gang data to player
function SolitudeGang.Server:SendGangData(ply, gang)
    if not gang then return end
    
    net.Start("SolitudeGang.SendGangData")
    net.WriteTable(gang)
    net.Send(ply)
end

-- Invite player to gang
function SolitudeGang.Server:InvitePlayer(inviter, target)
    local gang = self:GetPlayerGang(inviter)
    
    if not gang then
        return false, "You are not in a gang"
    end
    
    if gang.leader ~= inviter then
        return false, "Only the gang leader can invite players"
    end
    
    if self.PlayerGangs[target] then
        return false, target:Nick() .. " is already in a gang"
    end
    
    if #gang.members >= gang.maxMembers then
        return false, "Your gang is full"
    end
    
    -- Send invite to target
    self.PendingInvites[target] = {gangId = gang.id, inviter = inviter}
    
    net.Start("SolitudeGang.ReceiveInvite")
    net.WriteString(gang.name)
    net.WriteEntity(inviter)
    net.Send(target)
    
    return true, "Invite sent to " .. target:Nick()
end

-- Accept gang invite
function SolitudeGang.Server:AcceptInvite(ply)
    local invite = self.PendingInvites[ply]
    
    if not invite then
        return false, "No pending invites"
    end
    
    local gang = self.Gangs[invite.gangId]
    
    if not gang then
        self.PendingInvites[ply] = nil
        return false, "Gang no longer exists"
    end
    
    if #gang.members >= gang.maxMembers then
        self.PendingInvites[ply] = nil
        return false, "Gang is full"
    end
    
    -- Add player to gang
    table.insert(gang.members, ply)
    self.PlayerGangs[ply] = gang.id
    self.PendingInvites[ply] = nil
    
    -- Notify all gang members
    for _, member in ipairs(gang.members) do
        self:SendGangData(member, gang)
        member:ChatPrint("[Gang] " .. ply:Nick() .. " has joined the gang!")
    end
    
    return true, "You have joined " .. gang.name
end

-- Leave gang
function SolitudeGang.Server:LeaveGang(ply)
    local gangId = self.PlayerGangs[ply]
    
    if not gangId then
        return false, "You are not in a gang"
    end
    
    local gang = self.Gangs[gangId]
    
    if gang.leader == ply then
        -- If leader leaves, disband the gang
        return self:DisbandGang(ply)
    end
    
    -- Remove player from gang
    for i, member in ipairs(gang.members) do
        if member == ply then
            table.remove(gang.members, i)
            break
        end
    end
    
    self.PlayerGangs[ply] = nil
    
    -- Notify remaining members
    for _, member in ipairs(gang.members) do
        self:SendGangData(member, gang)
        member:ChatPrint("[Gang] " .. ply:Nick() .. " has left the gang")
    end
    
    return true, "You have left the gang"
end

-- Kick member from gang
function SolitudeGang.Server:KickMember(leader, target)
    local gang = self:GetPlayerGang(leader)
    
    if not gang then
        return false, "You are not in a gang"
    end
    
    if gang.leader ~= leader then
        return false, "Only the leader can kick members"
    end
    
    if target == leader then
        return false, "You cannot kick yourself"
    end
    
    if self.PlayerGangs[target] ~= gang.id then
        return false, "That player is not in your gang"
    end
    
    -- Remove player from gang
    for i, member in ipairs(gang.members) do
        if member == target then
            table.remove(gang.members, i)
            break
        end
    end
    
    self.PlayerGangs[target] = nil
    
    -- Notify target
    net.Start("SolitudeGang.GangDisbanded")
    net.Send(target)
    target:ChatPrint("[Gang] You have been kicked from the gang")
    
    -- Notify all gang members
    net.Start("SolitudeGang.MemberKicked")
    net.WriteString(target:Nick())
    net.Send(gang.members)
    
    for _, member in ipairs(gang.members) do
        self:SendGangData(member, gang)
    end
    
    return true, "Kicked " .. target:Nick() .. " from the gang"
end

-- Disband gang
function SolitudeGang.Server:DisbandGang(leader)
    local gang = self:GetPlayerGang(leader)
    
    if not gang then
        return false, "You are not in a gang"
    end
    
    if gang.leader ~= leader then
        return false, "Only the leader can disband the gang"
    end
    
    -- Notify all members
    for _, member in ipairs(gang.members) do
        self.PlayerGangs[member] = nil
        
        net.Start("SolitudeGang.GangDisbanded")
        net.Send(member)
        
        member:ChatPrint("[Gang] The gang has been disbanded")
    end
    
    -- Remove gang
    self.Gangs[gang.id] = nil
    
    return true, "Gang disbanded successfully"
end

-- Deposit money to gang bank
function SolitudeGang.Server:DepositMoney(ply, amount)
    local gang = self:GetPlayerGang(ply)
    
    if not gang then
        return false, "You are not in a gang"
    end
    
    if amount <= 0 then
        return false, "Invalid amount"
    end
    
    if not self:TakeMoney(ply, amount) then
        return false, "You don't have enough money"
    end
    
    gang.bank = gang.bank + amount
    
    -- Notify all gang members
    for _, member in ipairs(gang.members) do
        self:SendGangData(member, gang)
        member:ChatPrint("[Gang] " .. ply:Nick() .. " deposited $" .. string.Comma(amount))
    end
    
    return true, "Deposited $" .. string.Comma(amount) .. " to gang bank"
end

-- Withdraw money from gang bank
function SolitudeGang.Server:WithdrawMoney(ply, amount)
    local gang = self:GetPlayerGang(ply)
    
    if not gang then
        return false, "You are not in a gang"
    end
    
    if gang.leader ~= ply then
        return false, "Only the leader can withdraw money"
    end
    
    if amount <= 0 then
        return false, "Invalid amount"
    end
    
    if gang.bank < amount then
        return false, "Not enough money in gang bank"
    end
    
    gang.bank = gang.bank - amount
    self:AddMoney(ply, amount)
    
    -- Notify all gang members
    for _, member in ipairs(gang.members) do
        self:SendGangData(member, gang)
        member:ChatPrint("[Gang] Leader withdrew $" .. string.Comma(amount))
    end
    
    return true, "Withdrew $" .. string.Comma(amount) .. " from gang bank"
end

-- Network receivers
net.Receive("SolitudeGang.CreateGang", function(len, ply)
    local gangName = net.ReadString()
    local success, message = SolitudeGang.Server:CreateGang(ply, gangName)
    
    net.Start("SolitudeGang.CreateGangResponse")
    net.WriteBool(success)
    net.WriteString(message)
    if success then
        local gang = SolitudeGang.Server:GetPlayerGang(ply)
        net.WriteTable(gang)
    end
    net.Send(ply)
end)

net.Receive("SolitudeGang.LeaveGang", function(len, ply)
    local success, message = SolitudeGang.Server:LeaveGang(ply)
    
    net.Start("SolitudeGang.LeaveGangResponse")
    net.WriteBool(success)
    net.WriteString(message)
    net.Send(ply)
end)

net.Receive("SolitudeGang.InvitePlayer", function(len, ply)
    local target = net.ReadEntity()
    local success, message = SolitudeGang.Server:InvitePlayer(ply, target)
    
    if message then
        ply:ChatPrint("[Gang] " .. message)
    end
end)

net.Receive("SolitudeGang.AcceptInvite", function(len, ply)
    local success, message = SolitudeGang.Server:AcceptInvite(ply)
    
    if message then
        ply:ChatPrint("[Gang] " .. message)
    end
end)

net.Receive("SolitudeGang.KickMember", function(len, ply)
    local target = net.ReadEntity()
    local success, message = SolitudeGang.Server:KickMember(ply, target)
    
    if message then
        ply:ChatPrint("[Gang] " .. message)
    end
end)

net.Receive("SolitudeGang.DisbandGang", function(len, ply)
    local success, message = SolitudeGang.Server:DisbandGang(ply)
    
    if message then
        ply:ChatPrint("[Gang] " .. message)
    end
end)

net.Receive("SolitudeGang.RequestGangData", function(len, ply)
    local gang = SolitudeGang.Server:GetPlayerGang(ply)
    if gang then
        SolitudeGang.Server:SendGangData(ply, gang)
    end
end)

net.Receive("SolitudeGang.DepositMoney", function(len, ply)
    local amount = net.ReadUInt(32)
    local success, message = SolitudeGang.Server:DepositMoney(ply, amount)
    
    if message then
        ply:ChatPrint("[Gang] " .. message)
    end
end)

net.Receive("SolitudeGang.WithdrawMoney", function(len, ply)
    local amount = net.ReadUInt(32)
    local success, message = SolitudeGang.Server:WithdrawMoney(ply, amount)
    
    if message then
        ply:ChatPrint("[Gang] " .. message)
    end
end)

-- Clean up on player disconnect
hook.Add("PlayerDisconnected", "SolitudeGang.PlayerDisconnected", function(ply)
    SolitudeGang.Server.PendingInvites[ply] = nil
end)

-- Send gang data on spawn
hook.Add("PlayerSpawn", "SolitudeGang.PlayerSpawn", function(ply)
    timer.Simple(1, function()
        if IsValid(ply) then
            local gang = SolitudeGang.Server:GetPlayerGang(ply)
            if gang then
                SolitudeGang.Server:SendGangData(ply, gang)
            end
        end
    end)
end)

print("[SolitudeGang] Server initialized!")
