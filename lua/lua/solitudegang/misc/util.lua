-- Utility functions for gang system
SolitudeGang.Util = SolitudeGang.Util or {}

-- Format money with commas
function SolitudeGang.Util:FormatMoney(amount)
    return "$" .. string.Comma(amount or 0)
end

-- Format time ago
function SolitudeGang.Util:TimeAgo(timestamp)
    local diff = os.time() - timestamp
    
    if diff < 60 then
        return "Just now"
    elseif diff < 3600 then
        return math.floor(diff / 60) .. " minutes ago"
    elseif diff < 86400 then
        return math.floor(diff / 3600) .. " hours ago"
    else
        return math.floor(diff / 86400) .. " days ago"
    end
end

-- Validate gang name
function SolitudeGang.Util:IsValidGangName(name)
    if not name or name == "" then
        return false, "Gang name cannot be empty"
    end
    
    if string.len(name) < 3 then
        return false, "Gang name must be at least 3 characters"
    end
    
    if string.len(name) > 32 then
        return false, "Gang name must be at most 32 characters"
    end
    
    if not string.match(name, "^[%w%s]+$") then
        return false, "Gang name can only contain letters, numbers, and spaces"
    end
    
    return true
end

-- Get player's money (DarkRP compatible)
function SolitudeGang.Util:GetPlayerMoney(ply)
    if ply.getDarkRPVar then
        return ply:getDarkRPVar("money") or 0
    end
    return 0
end

-- Check if player can afford
function SolitudeGang.Util:CanAfford(ply, amount)
    return self:GetPlayerMoney(ply) >= amount
end

-- Color lerp
function SolitudeGang.Util:LerpColor(frac, from, to)
    return Color(
        Lerp(frac, from.r, to.r),
        Lerp(frac, from.g, to.g),
        Lerp(frac, from.b, to.b),
        Lerp(frac, from.a or 255, to.a or 255)
    )
end

-- Draw outline text
function SolitudeGang.Util:DrawOutlinedText(text, font, x, y, color, xalign, yalign, outlineColor)
    outlineColor = outlineColor or Color(0, 0, 0, 200)
    
    for offsetX = -1, 1 do
        for offsetY = -1, 1 do
            draw.SimpleText(text, font, x + offsetX, y + offsetY, outlineColor, xalign, yalign)
        end
    end
    
    draw.SimpleText(text, font, x, y, color, xalign, yalign)
end

-- Create notification
function SolitudeGang.Util:Notify(message, type)
    type = type or NOTIFY_GENERIC
    
    if CLIENT then
        notification.AddLegacy(message, type, 5)
        surface.PlaySound("buttons/button15.wav")
    end
end

-- Get rank name by member count
function SolitudeGang.Util:GetGangRankName(level)
    local ranks = {
        [1] = "Street Gang",
        [2] = "Local Crew",
        [3] = "City Syndicate",
        [4] = "Regional Cartel",
        [5] = "Crime Empire"
    }
    
    if level >= 5 then
        return "Crime Empire"
    end
    
    return ranks[level] or "Street Gang"
end

-- Calculate gang power (based on members and level)
function SolitudeGang.Util:CalculateGangPower(memberCount, level)
    return (memberCount * 10) + (level * 50)
end
