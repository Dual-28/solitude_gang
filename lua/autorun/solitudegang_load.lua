SolitudeGang = SolitudeGang or {}
SolitudeGang.Dir = "solitudegang"
SolitudeGang.Tests = {}

function SolitudeGang:IncludeClient(path)
    local str = self.Dir .. "/" .. path .. ".lua"

    if (CLIENT) then
        include(str)
    end

    if (SERVER) then
        AddCSLuaFile(str)
    end
end

SolitudeGang:IncludeClient("settings/theme")
SolitudeGang:IncludeClient("thirdparty/bshadows")
SolitudeGang:IncludeClient("misc/font")
SolitudeGang:IncludeClient("elements/frame")
SolitudeGang:IncludeClient("test/frame")

print("[SolitudeGang] Loaded!")