local Lighting = game:GetService("Lighting")

local Fullbright = {}
local enabled = false
local level = 3
local saved = {}

function Fullbright.init()
    Fullbright.set = function(state)
        enabled = state
        if state then
            saved.Brightness = Lighting.Brightness
            saved.Ambient = Lighting.Ambient
            saved.OutdoorAmbient = Lighting.OutdoorAmbient
            saved.ClockTime = Lighting.ClockTime
            saved.FogEnd = Lighting.FogEnd
            saved.FogStart = Lighting.FogStart
            saved.GlobalShadows = Lighting.GlobalShadows
            Fullbright.apply()
        else
            if saved.Brightness then Lighting.Brightness = saved.Brightness end
            if saved.Ambient then Lighting.Ambient = saved.Ambient end
            if saved.OutdoorAmbient then Lighting.OutdoorAmbient = saved.OutdoorAmbient end
            if saved.ClockTime then Lighting.ClockTime = saved.ClockTime end
            if saved.FogEnd then Lighting.FogEnd = saved.FogEnd end
            if saved.FogStart then Lighting.FogStart = saved.FogStart end
            if saved.GlobalShadows ~= nil then Lighting.GlobalShadows = saved.GlobalShadows end
        end
    end
    Fullbright.apply = function()
        if not enabled then return end
        Lighting.Brightness = level
        local amb = math.clamp(level / 10, 0, 1)
        Lighting.Ambient = Color3.fromRGB(255 * amb, 255 * amb, 255 * amb)
        Lighting.OutdoorAmbient = Color3.fromRGB(255 * amb, 255 * amb, 255 * amb)
        Lighting.ClockTime = 12
        Lighting.FogEnd = 100000
        Lighting.FogStart = 100000
        Lighting.GlobalShadows = false
    end
    Fullbright.setLevel = function(v)
        level = v
        if enabled then Fullbright.apply() end
    end
end

return Fullbright
