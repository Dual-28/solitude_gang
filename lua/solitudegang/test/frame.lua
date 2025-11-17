SolitudeGang.Tests.Frame = function()
    local frame = vgui.Create("SolitudeGang.Frame")
    frame:SetSize(800, 600)
    frame:Center()
    frame:MakePopup()
    frame:SetTitle("SolitudeGang Frame Test")
end

concommand.Add("solitudegang_test_frame", SolitudeGang.Tests.Frame)