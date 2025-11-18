-- Main gang menu panel
local PANEL = {}

function PANEL:Init()
    self:SetSize(900, 650)
    self:Center()
    self:MakePopup()
    
    -- Header
    self.header = self:Add("Panel")
    self.header:Dock(TOP)
    self.header.Paint = function(pnl, w, h)
        draw.RoundedBox(6, 0, 0, w, h, SolitudeGang.Theme.primary, true, true, false, false)
    end
    
    self.header.closeBtn = self.header:Add("DButton")
    self.header.closeBtn:Dock(RIGHT)
    self.header.closeBtn:SetWide(48)
    self.header.closeBtn.DoClick = function(pnl)
        self:Remove()
    end
    self.header.closeBtn:SetText("✕")
    self.header.closeBtn:SetFont("DermaLarge")
    self.header.closeBtn:SetTextColor(SolitudeGang.Theme.closeBtn)
    self.header.closeBtn.Paint = function(s, w, h)
        if s:IsHovered() then
            draw.RoundedBox(0, 0, 0, w, h, Color(80, 30, 30))
        end
    end
    
    self.header.title = self.header:Add("DLabel")
    self.header.title:Dock(LEFT)
    self.header.title:SetFont("DermaLarge")
    self.header.title:SetTextColor(SolitudeGang.Theme.text.h1)
    self.header.title:SetText("Gang Management")
    self.header.title:SetTextInset(16, 0)
    self.header.title:SizeToContentsX()
    
    -- Content area
    self.content = self:Add("Panel")
    self.content:Dock(FILL)
    self.content.Paint = function(pnl, w, h)
        draw.RoundedBox(0, 0, 0, w, h, SolitudeGang.Theme.background)
    end
    
    -- Sidebar for navigation
    self.sidebar = self.content:Add("Panel")
    self.sidebar:Dock(LEFT)
    self.sidebar:SetWide(200)
    self.sidebar:DockMargin(8, 8, 4, 8)
    self.sidebar.Paint = function(s, w, h)
        draw.RoundedBox(6, 0, 0, w, h, Color(35, 35, 35))
    end
    
    -- Main content panel
    self.mainPanel = self.content:Add("Panel")
    self.mainPanel:Dock(FILL)
    self.mainPanel:DockMargin(4, 8, 8, 8)
    self.mainPanel.Paint = function(s, w, h)
        draw.RoundedBox(6, 0, 0, w, h, Color(35, 35, 35))
    end
    
    self:BuildSidebar()
    self:RefreshContent()
end

function PANEL:BuildSidebar()
    local buttons = {
        {name = "Overview", icon = "📊", page = "overview"},
        {name = "Members", icon = "👥", page = "members"},
        {name = "Bank", icon = "💰", page = "bank"},
        {name = "Settings", icon = "⚙", page = "settings"}
    }
    
    local yPos = 8
    for _, btnData in ipairs(buttons) do
        local btn = self.sidebar:Add("DButton")
        btn:SetPos(8, yPos)
        btn:SetSize(184, 40)
        btn:SetText("")
        btn.page = btnData.page
        
        btn.Paint = function(s, w, h)
            local col = Color(45, 45, 45)
            if s:IsHovered() or self.currentPage == btnData.page then
                col = SolitudeGang.Theme.primary
            end
            draw.RoundedBox(4, 0, 0, w, h, col)
            draw.SimpleText(btnData.icon .. " " .. btnData.name, "DermaDefault", 12, h / 2, SolitudeGang.Theme.text.h1, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
        
        btn.DoClick = function()
            self:SwitchPage(btnData.page)
        end
        
        yPos = yPos + 48
    end
end

function PANEL:SwitchPage(page)
    self.currentPage = page
    self:RefreshContent()
end

function PANEL:RefreshContent()
    self.mainPanel:Clear()
    
    if not SolitudeGang.Data:IsInGang() then
        self:ShowNoGangScreen()
        return
    end
    
    local page = self.currentPage or "overview"
    
    if page == "overview" then
        self:ShowOverview()
    elseif page == "members" then
        self:ShowMembers()
    elseif page == "bank" then
        self:ShowBank()
    elseif page == "settings" then
        self:ShowSettings()
    end
end

function PANEL:ShowNoGangScreen()
    local label = self.mainPanel:Add("DLabel")
    label:SetPos(20, 20)
    label:SetFont("DermaLarge")
    label:SetTextColor(SolitudeGang.Theme.text.h1)
    label:SetText("You are not in a gang")
    label:SizeToContents()
    
    local createBtn = self.mainPanel:Add("DButton")
    createBtn:SetPos(20, 70)
    createBtn:SetSize(200, 40)
    createBtn:SetText("")
    createBtn.Paint = function(s, w, h)
        draw.RoundedBox(6, 0, 0, w, h, SolitudeGang.Theme.primary)
        draw.SimpleText("Create Gang", "DermaDefault", w / 2, h / 2, SolitudeGang.Theme.text.h1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    createBtn.DoClick = function()
        self:ShowCreateGangDialog()
    end
end

function PANEL:ShowCreateGangDialog()
    local dialog = vgui.Create("DFrame")
    dialog:SetTitle("")
    dialog:SetSize(400, 180)
    dialog:Center()
    dialog:MakePopup()
    dialog:SetDraggable(false)
    dialog.Paint = function(s, w, h)
        draw.RoundedBox(6, 0, 0, w, h, SolitudeGang.Theme.background)
        draw.RoundedBox(6, 0, 0, w, 32, SolitudeGang.Theme.primary)
        draw.SimpleText("Create Gang", "DermaDefault", w / 2, 16, SolitudeGang.Theme.text.h1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    local nameLabel = dialog:Add("DLabel")
    nameLabel:SetPos(20, 50)
    nameLabel:SetFont("DermaDefault")
    nameLabel:SetTextColor(SolitudeGang.Theme.text.h1)
    nameLabel:SetText("Gang Name:")
    nameLabel:SizeToContents()
    
    local nameEntry = dialog:Add("DTextEntry")
    nameEntry:SetPos(20, 75)
    nameEntry:SetSize(360, 30)
    nameEntry:SetPlaceholderText("Enter gang name...")
    nameEntry.Paint = function(s, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(55, 55, 55))
        s:DrawTextEntryText(SolitudeGang.Theme.text.h1, SolitudeGang.Theme.text.h1, SolitudeGang.Theme.text.h1)
    end
    
    local createBtn = dialog:Add("DButton")
    createBtn:SetPos(20, 120)
    createBtn:SetSize(360, 40)
    createBtn:SetText("")
    createBtn.Paint = function(s, w, h)
        draw.RoundedBox(6, 0, 0, w, h, SolitudeGang.Theme.primary)
        draw.SimpleText("Create ($50,000)", "DermaDefault", w / 2, h / 2, SolitudeGang.Theme.text.h1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    createBtn.DoClick = function()
        local gangName = nameEntry:GetValue()
        if gangName and gangName ~= "" then
            SolitudeGang.Net:CreateGang(gangName)
            dialog:Close()
            self:Remove()
        end
    end
end

function PANEL:ShowOverview()
    local gang = SolitudeGang.Data:GetLocalGang()
    
    local yPos = 20
    
    -- Gang name
    local nameLabel = self.mainPanel:Add("DLabel")
    nameLabel:SetPos(20, yPos)
    nameLabel:SetFont("DermaLarge")
    nameLabel:SetTextColor(SolitudeGang.Theme.text.h1)
    nameLabel:SetText(gang.name)
    nameLabel:SizeToContents()
    
    yPos = yPos + 50
    
    -- Gang info
    local info = {
        {"Leader", gang.leader:Nick()},
        {"Members", #gang.members .. "/" .. gang.maxMembers},
        {"Level", gang.level},
        {"Bank Balance", "$" .. string.Comma(gang.bank or 0)},
        {"Created", os.date("%Y-%m-%d", gang.created)}
    }
    
    for _, data in ipairs(info) do
        local label = self.mainPanel:Add("DLabel")
        label:SetPos(20, yPos)
        label:SetFont("DermaDefault")
        label:SetTextColor(SolitudeGang.Theme.text.h1)
        label:SetText(data[1] .. ": " .. data[2])
        label:SizeToContents()
        yPos = yPos + 25
    end
    
    -- XP Bar
    yPos = yPos + 20
    local xpLabel = self.mainPanel:Add("DLabel")
    xpLabel:SetPos(20, yPos)
    xpLabel:SetFont("DermaDefault")
    xpLabel:SetTextColor(SolitudeGang.Theme.text.h1)
    xpLabel:SetText(string.format("XP: %d / %d", gang.xp or 0, SolitudeGang.Data:GetLevelXPRequired(gang.level)))
    xpLabel:SizeToContents()
    
    yPos = yPos + 25
    local xpBar = self.mainPanel:Add("Panel")
    xpBar:SetPos(20, yPos)
    xpBar:SetSize(400, 20)
    xpBar.Paint = function(s, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(25, 25, 25))
        local progress = SolitudeGang.Data:GetLevelProgress()
        draw.RoundedBox(4, 2, 2, (w - 4) * progress, h - 4, Color(100, 200, 100))
    end
end

function PANEL:ShowMembers()
    local gang = SolitudeGang.Data:GetLocalGang()
    local isLeader = SolitudeGang.Data:IsGangLeader()
    
    local memberList = self.mainPanel:Add("DScrollPanel")
    memberList:Dock(FILL)
    memberList:DockMargin(10, 10, 10, 10)
    
    for i, member in ipairs(gang.members) do
        local memberPanel = memberList:Add("Panel")
        memberPanel:Dock(TOP)
        memberPanel:DockMargin(0, 0, 0, 8)
        memberPanel:SetTall(50)
        memberPanel.Paint = function(s, w, h)
            draw.RoundedBox(6, 0, 0, w, h, Color(45, 45, 45))
            
            -- Member name
            draw.SimpleText(member:Nick(), "DermaDefault", 15, h / 2, SolitudeGang.Theme.text.h1, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            
            -- Leader badge
            if member == gang.leader then
                draw.SimpleText("[Leader]", "DermaDefault", 200, h / 2, Color(255, 215, 0), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            end
        end
        
        -- Kick button for leader
        if isLeader and member ~= gang.leader then
            local kickBtn = memberPanel:Add("DButton")
            kickBtn:SetPos(memberPanel:GetWide() - 90, 10)
            kickBtn:SetSize(80, 30)
            kickBtn:SetText("")
            kickBtn.Paint = function(s, w, h)
                draw.RoundedBox(4, 0, 0, w, h, Color(150, 50, 50))
                draw.SimpleText("Kick", "DermaDefault", w / 2, h / 2, SolitudeGang.Theme.text.h1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
            kickBtn.DoClick = function()
                SolitudeGang.Net:KickMember(member)
            end
        end
    end
    
    -- Invite button for leader
    if isLeader then
        local inviteBtn = self.mainPanel:Add("DButton")
        inviteBtn:SetPos(10, 10)
        inviteBtn:SetSize(120, 35)
        inviteBtn:SetText("")
        inviteBtn.Paint = function(s, w, h)
            draw.RoundedBox(6, 0, 0, w, h, SolitudeGang.Theme.primary)
            draw.SimpleText("Invite Player", "DermaDefault", w / 2, h / 2, SolitudeGang.Theme.text.h1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        inviteBtn.DoClick = function()
            self:ShowInviteMenu()
        end
    end
end

function PANEL:ShowInviteMenu()
    local menu = DermaMenu()
    
    for _, ply in ipairs(player.GetAll()) do
        if ply ~= LocalPlayer() and not SolitudeGang.Data:IsMemberOfLocalGang(ply) then
            menu:AddOption(ply:Nick(), function()
                SolitudeGang.Net:InvitePlayer(ply)
            end)
        end
    end
    
    menu:Open()
end

function PANEL:ShowBank()
    local gang = SolitudeGang.Data:GetLocalGang()
    
    local bankLabel = self.mainPanel:Add("DLabel")
    bankLabel:SetPos(20, 20)
    bankLabel:SetFont("DermaLarge")
    bankLabel:SetTextColor(SolitudeGang.Theme.text.h1)
    bankLabel:SetText("Gang Bank: $" .. string.Comma(gang.bank or 0))
    bankLabel:SizeToContents()
    
    -- Deposit section
    local depositLabel = self.mainPanel:Add("DLabel")
    depositLabel:SetPos(20, 80)
    depositLabel:SetFont("DermaDefault")
    depositLabel:SetTextColor(SolitudeGang.Theme.text.h1)
    depositLabel:SetText("Deposit Amount:")
    depositLabel:SizeToContents()
    
    local depositEntry = self.mainPanel:Add("DTextEntry")
    depositEntry:SetPos(20, 105)
    depositEntry:SetSize(200, 30)
    depositEntry:SetNumeric(true)
    depositEntry.Paint = function(s, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(55, 55, 55))
        s:DrawTextEntryText(SolitudeGang.Theme.text.h1, SolitudeGang.Theme.text.h1, SolitudeGang.Theme.text.h1)
    end
    
    local depositBtn = self.mainPanel:Add("DButton")
    depositBtn:SetPos(230, 105)
    depositBtn:SetSize(100, 30)
    depositBtn:SetText("")
    depositBtn.Paint = function(s, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(50, 150, 50))
        draw.SimpleText("Deposit", "DermaDefault", w / 2, h / 2, SolitudeGang.Theme.text.h1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    depositBtn.DoClick = function()
        local amount = tonumber(depositEntry:GetValue())
        if amount and amount > 0 then
            SolitudeGang.Net:DepositMoney(amount)
            depositEntry:SetValue("")
        end
    end
    
    -- Withdraw section (leader only)
    if SolitudeGang.Data:IsGangLeader() then
        local withdrawLabel = self.mainPanel:Add("DLabel")
        withdrawLabel:SetPos(20, 160)
        withdrawLabel:SetFont("DermaDefault")
        withdrawLabel:SetTextColor(SolitudeGang.Theme.text.h1)
        withdrawLabel:SetText("Withdraw Amount (Leader Only):")
        withdrawLabel:SizeToContents()
        
        local withdrawEntry = self.mainPanel:Add("DTextEntry")
        withdrawEntry:SetPos(20, 185)
        withdrawEntry:SetSize(200, 30)
        withdrawEntry:SetNumeric(true)
        withdrawEntry.Paint = function(s, w, h)
            draw.RoundedBox(4, 0, 0, w, h, Color(55, 55, 55))
            s:DrawTextEntryText(SolitudeGang.Theme.text.h1, SolitudeGang.Theme.text.h1, SolitudeGang.Theme.text.h1)
        end
        
        local withdrawBtn = self.mainPanel:Add("DButton")
        withdrawBtn:SetPos(230, 185)
        withdrawBtn:SetSize(100, 30)
        withdrawBtn:SetText("")
        withdrawBtn.Paint = function(s, w, h)
            draw.RoundedBox(4, 0, 0, w, h, Color(150, 100, 50))
            draw.SimpleText("Withdraw", "DermaDefault", w / 2, h / 2, SolitudeGang.Theme.text.h1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        withdrawBtn.DoClick = function()
            local amount = tonumber(withdrawEntry:GetValue())
            if amount and amount > 0 then
                SolitudeGang.Net:WithdrawMoney(amount)
                withdrawEntry:SetValue("")
            end
        end
    end
end

function PANEL:ShowSettings()
    local gang = SolitudeGang.Data:GetLocalGang()
    local isLeader = SolitudeGang.Data:IsGangLeader()
    
    local leaveBtn = self.mainPanel:Add("DButton")
    leaveBtn:SetPos(20, 20)
    leaveBtn:SetSize(200, 40)
    leaveBtn:SetText("")
    leaveBtn.Paint = function(s, w, h)
        draw.RoundedBox(6, 0, 0, w, h, Color(150, 50, 50))
        draw.SimpleText("Leave Gang", "DermaDefault", w / 2, h / 2, SolitudeGang.Theme.text.h1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    leaveBtn.DoClick = function()
        Derma_Query("Are you sure you want to leave the gang?", "Confirm Leave", "Yes", function()
            SolitudeGang.Net:LeaveGang()
            self:Remove()
        end, "No")
    end
    
    if isLeader then
        local disbandBtn = self.mainPanel:Add("DButton")
        disbandBtn:SetPos(20, 70)
        disbandBtn:SetSize(200, 40)
        disbandBtn:SetText("")
        disbandBtn.Paint = function(s, w, h)
            draw.RoundedBox(6, 0, 0, w, h, Color(200, 30, 30))
            draw.SimpleText("Disband Gang", "DermaDefault", w / 2, h / 2, SolitudeGang.Theme.text.h1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        disbandBtn.DoClick = function()
            Derma_Query("Are you sure you want to disband the gang? This cannot be undone!", "Confirm Disband", "Yes", function()
                SolitudeGang.Net:DisbandGang()
                self:Remove()
            end, "No")
        end
    end
end

function PANEL:PerformLayout(w, h)
    self.header:SetTall(SolitudeGang.UISizes.navbar.height)
end

function PANEL:Paint(w, h)
    local aX, aY = self:LocalToScreen()
    
    BSHADOWS.BeginShadow()
        draw.RoundedBox(6, aX, aY, w, h, SolitudeGang.Theme.background)
    BSHADOWS.EndShadow(1, 2, 2)
end

vgui.Register("SolitudeGang.GangMenu", PANEL, "EditablePanel")

-- Console command to open gang menu
concommand.Add("gang_menu", function()
    if IsValid(SolitudeGang.GangMenuPanel) then
        SolitudeGang.GangMenuPanel:Remove()
    end
    
    SolitudeGang.GangMenuPanel = vgui.Create("SolitudeGang.GangMenu")
end)
