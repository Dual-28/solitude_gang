-- Gang HUD display
if not CLIENT then return end

local showGangHUD = CreateClientConVar("solitudegang_showhud", "1", true, false, "Show gang HUD")

-- HUD Display
hook.Add("HUDPaint", "SolitudeGang.HUD", function()
    if not showGangHUD:GetBool() then return end
    if not SolitudeGang.Data:IsInGang() then return end
    
    local gang = SolitudeGang.Data:GetLocalGang()
    if not gang then return end
    
    local x, y = 20, ScrH() - 150
    local w, h = 250, 120
    
    -- Background
    draw.RoundedBox(6, x, y, w, h, Color(35, 35, 35, 220))
    draw.RoundedBox(6, x, y, w, 30, SolitudeGang.Theme.primary)
    
    -- Gang name
    draw.SimpleText(gang.name, "DermaDefault", x + w / 2, y + 15, SolitudeGang.Theme.text.h1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    
    -- Gang info
    local infoY = y + 40
    local lineHeight = 20
    
    draw.SimpleText("Members: " .. #gang.members .. "/" .. gang.maxMembers, "DermaDefault", x + 10, infoY, SolitudeGang.Theme.text.h1, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    infoY = infoY + lineHeight
    
    draw.SimpleText("Level: " .. gang.level, "DermaDefault", x + 10, infoY, SolitudeGang.Theme.text.h1, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    infoY = infoY + lineHeight
    
    draw.SimpleText("Bank: $" .. string.Comma(gang.bank or 0), "DermaDefault", x + 10, infoY, Color(100, 200, 100), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    infoY = infoY + lineHeight
    
    -- XP Bar
    local barX, barY = x + 10, infoY + 5
    local barW, barH = w - 20, 10
    
    draw.RoundedBox(4, barX, barY, barW, barH, Color(25, 25, 25))
    
    local progress = SolitudeGang.Data:GetLevelProgress()
    if progress > 0 then
        draw.RoundedBox(4, barX + 1, barY + 1, (barW - 2) * progress, barH - 2, Color(100, 200, 255))
    end
end)

-- Chat commands
hook.Add("OnPlayerChat", "SolitudeGang.ChatCommands", function(ply, text, teamChat, isDead)
    if ply ~= LocalPlayer() then return end
    
    local lower = string.lower(text)
    
    if lower == "/gang" or lower == "!gang" then
        RunConsoleCommand("gang_menu")
        return true
    end
    
    if lower == "/gang help" or lower == "!gang help" then
        chat.AddText(Color(100, 255, 100), "[Gang] ", Color(255, 255, 255), "Available commands:")
        chat.AddText(Color(200, 200, 200), "/gang - Open gang menu")
        chat.AddText(Color(200, 200, 200), "/gang leave - Leave your current gang")
        return true
    end
    
    if lower == "/gang leave" or lower == "!gang leave" then
        if SolitudeGang.Data:IsInGang() then
            Derma_Query("Are you sure you want to leave the gang?", "Confirm Leave", "Yes", function()
                SolitudeGang.Net:LeaveGang()
            end, "No")
        else
            chat.AddText(Color(255, 100, 100), "[Gang] ", Color(255, 255, 255), "You are not in a gang")
        end
        return true
    end
end)

-- Notify player when they join the server if they're in a gang
hook.Add("InitPostEntity", "SolitudeGang.RequestData", function()
    timer.Simple(2, function()
        SolitudeGang.Net:RequestGangData()
    end)
end)
