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

function SolitudeGang:IncludeServer(path)
    local str = self.Dir .. "/" .. path .. ".lua"

    if (SERVER) then
        include(str)
    end
end

-- Load server-side files
SolitudeGang:IncludeServer("server/core")

-- Load settings and theme
SolitudeGang:IncludeClient("settings/theme")

-- Load third-party libraries
SolitudeGang:IncludeClient("thirdparty/bshadows")

-- Load utilities
SolitudeGang:IncludeClient("misc/font")
SolitudeGang:IncludeClient("misc/util")

-- Load core systems
SolitudeGang:IncludeClient("core/data")
SolitudeGang:IncludeClient("core/network")

-- Load UI elements
SolitudeGang:IncludeClient("elements/frame")
SolitudeGang:IncludeClient("elements/gangmenu")

-- Load client features
SolitudeGang:IncludeClient("client/hud")

-- Load tests
SolitudeGang:IncludeClient("test/frame")

print("[SolitudeGang] Loaded!")