local PANEL = {}

function PANEL:Init()
    self.header = self:Add("Panel")
    self.header:Dock(TOP)
    self.header.Paint = function(pnl, w, h)
        draw.RoundedBox(6, 0, 0, w, h, SolitudeGang.Theme.primary, true, true, false, false)
    end

    self.header.closeBtn = self.header:Add("DButton")
    self.header.closeBtn:Dock(RIGHT)
    self.header.closeBtn.DoClick = function(pnl)
        self:Remove()
    end
    self.header.closeBtn:SetText("X")
    self.header.closeBtn:SetFont("HudDefault")
    self.header.closeBtn:SetTextColor(SolitudeGang.Theme.closeBtn)
    self.header.closeBtn.Paint = function(s, w, h)
    end

    self.header.title = self.header:Add("DLabel")
    self.header.title:Dock(LEFT)
    self.header.title:SetFont("HudDefault")
    self.header.title:SetTextColor(SolitudeGang.Theme.text.h1)
    self.header.title:SetTextInset(16, 0)

    self.content = self:Add("Panel")
    self.content:Dock(FILL)
    self.content.Paint = function(pnl, w, h)
        draw.RoundedBox(0, 0, 0, w, h, SolitudeGang.Theme.background)
    end

    self.gangNameLabel = self.content:Add("DLabel")
    self.gangNameLabel:SetFont("HudDefault")
    self.gangNameLabel:SetTextColor(SolitudeGang.Theme.text.h1)
    self.gangNameLabel:SetText("Gang Name:")
    self.gangNameLabel:SizeToContents()

    self.priceLabel = self.content:Add("DLabel")
    self.priceLabel:SetFont("HudDefault")
    self.priceLabel:SetTextColor(SolitudeGang.Theme.text.h1)
    self.priceLabel:SetText("Price: $50,000")
    self.priceLabel:SizeToContents()

    self.gangNameInput = self.content:Add("DTextEntry")
    self.gangNameInput:SetSize(300, 32)
    self.gangNameInput:SetPlaceholderText("Enter gang name...")
    self.gangNameInput:SetFont("HudDefault")
    self.gangNameInput.Paint = function(s, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(55, 55, 55))
        s:DrawTextEntryText(SolitudeGang.Theme.text.h1, SolitudeGang.Theme.text.h1, SolitudeGang.Theme.text.h1)
    end

    self.createBtn = self.content:Add("DButton")
    self.createBtn:SetSize(300, 36)
    self.createBtn:SetText("")
    self.createBtn.Paint = function(s, w, h)
        draw.RoundedBox(6, 0, 0, w, h, SolitudeGang.Theme.primary)
        draw.SimpleText("Create Gang", "HudDefault", w / 2, h / 2, SolitudeGang.Theme.text.h1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    self.createBtn.DoClick = function()
        self:Remove()
        self:ShowConfirmDialog()
    end
end

function PANEL:ShowConfirmDialog()
    local dialog = vgui.Create("DFrame")
    dialog:SetTitle("")
    dialog:SetSize(300, 150)
    dialog:Center()
    dialog:MakePopup()
    dialog:SetDraggable(false)
    dialog.Paint = function(s, w, h)
        draw.RoundedBox(6, 0, 0, w, h, SolitudeGang.Theme.background)
        draw.RoundedBox(6, 0, 0, w, 28, SolitudeGang.Theme.primary)
    end

    local messageLabel = dialog:Add("DLabel")
    messageLabel:SetPos(10, 40)
    messageLabel:SetSize(280, 60)
    messageLabel:SetFont("HudDefault")
    messageLabel:SetTextColor(SolitudeGang.Theme.text.h1)
    messageLabel:SetText("Do you wish to create a gang?\nIt will cost $50,000")
    messageLabel:SetWrap(true)

    local yesBtn = dialog:Add("DButton")
    yesBtn:SetPos(10, 110)
    yesBtn:SetSize(135, 32)
    yesBtn:SetText("")
    yesBtn.Paint = function(s, w, h)
        draw.RoundedBox(4, 0, 0, w, h, SolitudeGang.Theme.primary)
        draw.SimpleText("Yes", "HudDefault", w / 2, h / 2, SolitudeGang.Theme.text.h1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    yesBtn.DoClick = function()
        -- TODO: Add gang creation logic here
        dialog:Close()
    end

    local noBtn = dialog:Add("DButton")
    noBtn:SetPos(155, 110)
    noBtn:SetSize(135, 32)
    noBtn:SetText("")
    noBtn.Paint = function(s, w, h)
        draw.RoundedBox(4, 0, 0, w, h, SolitudeGang.Theme.primary)
        draw.SimpleText("No", "HudDefault", w / 2, h / 2, SolitudeGang.Theme.text.h1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    noBtn.DoClick = function()
        dialog:Close()
    end
end

function PANEL:SetTitle(text)
    self.header.title:SetText(text)
    self.header.title:SizeToContentsX()
end

function PANEL:PerformLayout(w, h)
    self.header:SetTall(SolitudeGang.UISizes.navbar.height)

    local contentW = 300
    local startX = (w - contentW) / 2
    local startY = (h - 120) / 4

    self.gangNameLabel:SetPos(startX, startY)
    self.gangNameInput:SetPos(startX, startY + 30)
    self.createBtn:SetPos(startX, startY + 70)
end

function PANEL:Paint(w, h)
    local aX, aY = self:LocalToScreen()

    BSHADOWS.BeginShadow()
        draw.RoundedBox(6, aX, aY, w, h, SolitudeGang.Theme.background)
    BSHADOWS.EndShadow(1, 2, 2)
end

vgui.Register("SolitudeGang.Frame", PANEL, "EditablePanel")