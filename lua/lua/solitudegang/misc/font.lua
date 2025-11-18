function SolitudeGang:CreateFont(name, size, weight)
    surface.CreateFont("SolitudeGang." .. name, {
        font = "HudDefault",
        size = size or 16,
        weight = weight or 500
    })
end