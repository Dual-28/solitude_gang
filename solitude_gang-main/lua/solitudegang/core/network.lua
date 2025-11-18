-- Client-side network handling for gang system
SolitudeGang.Net = SolitudeGang.Net or {}

-- Network string definitions
if CLIENT then
    -- Receive gang data from server
    net.Receive("SolitudeGang.SendGangData", function()
        local gangData = net.ReadTable()
        SolitudeGang.Data:SetLocalGang(gangData)
        
        chat.AddText(Color(100, 255, 100), "[Gang] ", Color(255, 255, 255), "Gang data updated!")
    end)
    
    -- Receive gang creation response
    net.Receive("SolitudeGang.CreateGangResponse", function()
        local success = net.ReadBool()
        local message = net.ReadString()
        
        if success then
            chat.AddText(Color(100, 255, 100), "[Gang] ", Color(255, 255, 255), message)
            local gangData = net.ReadTable()
            SolitudeGang.Data:SetLocalGang(gangData)
        else
            chat.AddText(Color(255, 100, 100), "[Gang] ", Color(255, 255, 255), message)
        end
    end)
    
    -- Receive gang leave response
    net.Receive("SolitudeGang.LeaveGangResponse", function()
        local success = net.ReadBool()
        local message = net.ReadString()
        
        if success then
            SolitudeGang.Data:ClearLocalGang()
            chat.AddText(Color(100, 255, 100), "[Gang] ", Color(255, 255, 255), message)
        else
            chat.AddText(Color(255, 100, 100), "[Gang] ", Color(255, 255, 255), message)
        end
    end)
    
    -- Receive gang invite
    net.Receive("SolitudeGang.ReceiveInvite", function()
        local gangName = net.ReadString()
        local inviter = net.ReadEntity()
        
        local dialog = vgui.Create("DFrame")
        dialog:SetTitle("")
        dialog:SetSize(350, 150)
        dialog:Center()
        dialog:MakePopup()
        dialog:SetDraggable(false)
        dialog.Paint = function(s, w, h)
            draw.RoundedBox(6, 0, 0, w, h, SolitudeGang.Theme.background)
            draw.RoundedBox(6, 0, 0, w, 32, SolitudeGang.Theme.primary)
            draw.SimpleText("Gang Invitation", "HudDefault", w / 2, 16, SolitudeGang.Theme.text.h1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        
        local messageLabel = dialog:Add("DLabel")
        messageLabel:SetPos(10, 45)
        messageLabel:SetSize(330, 60)
        messageLabel:SetFont("HudDefault")
        messageLabel:SetTextColor(SolitudeGang.Theme.text.h1)
        messageLabel:SetText(string.format("%s has invited you to join\n'%s'", inviter:Nick(), gangName))
        messageLabel:SetWrap(true)
        
        local yesBtn = dialog:Add("DButton")
        yesBtn:SetPos(10, 110)
        yesBtn:SetSize(160, 32)
        yesBtn:SetText("")
        yesBtn.Paint = function(s, w, h)
            draw.RoundedBox(4, 0, 0, w, h, SolitudeGang.Theme.primary)
            draw.SimpleText("Accept", "HudDefault", w / 2, h / 2, SolitudeGang.Theme.text.h1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        yesBtn.DoClick = function()
            SolitudeGang.Net:AcceptInvite()
            dialog:Close()
        end
        
        local noBtn = dialog:Add("DButton")
        noBtn:SetPos(180, 110)
        noBtn:SetSize(160, 32)
        noBtn:SetText("")
        noBtn.Paint = function(s, w, h)
            draw.RoundedBox(4, 0, 0, w, h, Color(80, 40, 40))
            draw.SimpleText("Decline", "HudDefault", w / 2, h / 2, SolitudeGang.Theme.text.h1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        noBtn.DoClick = function()
            chat.AddText(Color(255, 100, 100), "[Gang] ", Color(255, 255, 255), "You declined the invitation")
            dialog:Close()
        end
    end)
    
    -- Receive gang disbanded notification
    net.Receive("SolitudeGang.GangDisbanded", function()
        SolitudeGang.Data:ClearLocalGang()
        chat.AddText(Color(255, 100, 100), "[Gang] ", Color(255, 255, 255), "Your gang has been disbanded!")
    end)
    
    -- Receive member kicked notification
    net.Receive("SolitudeGang.MemberKicked", function()
        local memberName = net.ReadString()
        chat.AddText(Color(255, 200, 100), "[Gang] ", Color(255, 255, 255), memberName .. " was kicked from the gang")
        
        -- Refresh gang data
        timer.Simple(0.1, function()
            SolitudeGang.Net:RequestGangData()
        end)
    end)
end

-- Client functions to send requests to server
function SolitudeGang.Net:CreateGang(gangName)
    net.Start("SolitudeGang.CreateGang")
    net.WriteString(gangName)
    net.SendToServer()
end

function SolitudeGang.Net:LeaveGang()
    net.Start("SolitudeGang.LeaveGang")
    net.SendToServer()
end

function SolitudeGang.Net:InvitePlayer(target)
    net.Start("SolitudeGang.InvitePlayer")
    net.WriteEntity(target)
    net.SendToServer()
end

function SolitudeGang.Net:AcceptInvite()
    net.Start("SolitudeGang.AcceptInvite")
    net.SendToServer()
end

function SolitudeGang.Net:KickMember(target)
    net.Start("SolitudeGang.KickMember")
    net.WriteEntity(target)
    net.SendToServer()
end

function SolitudeGang.Net:DisbandGang()
    net.Start("SolitudeGang.DisbandGang")
    net.SendToServer()
end

function SolitudeGang.Net:RequestGangData()
    net.Start("SolitudeGang.RequestGangData")
    net.SendToServer()
end

function SolitudeGang.Net:DepositMoney(amount)
    net.Start("SolitudeGang.DepositMoney")
    net.WriteUInt(amount, 32)
    net.SendToServer()
end

function SolitudeGang.Net:WithdrawMoney(amount)
    net.Start("SolitudeGang.WithdrawMoney")
    net.WriteUInt(amount, 32)
    net.SendToServer()
end
