local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local FPSBoost = {}
local enabled = false
local conns = {}
local saved = {}

local function cleanPart(p)
    if p:IsA("ParticleEmitter") or p:IsA("Trail") or p:IsA("Beam") or p:IsA("Fire") or p:IsA("Smoke") or p:IsA("Sparkles") then
        if saved[p] == nil then saved[p] = p.Enabled end
        p.Enabled = false
    end
end

function FPSBoost.init()
    FPSBoost.set = function(state)
        enabled = state
        if state then
            saved = {}
            pcall(function()
                local terrain = Workspace:FindFirstChildOfClass("Terrain")
                if terrain then
                    saved.WaterReflectance = terrain.WaterReflectance
                    saved.WaterWaveSize = terrain.WaterWaveSize
                    saved.WaterTransparency = terrain.WaterTransparency
                    terrain.WaterReflectance = 0
                    terrain.WaterWaveSize = 0
                    terrain.WaterTransparency = 1
                    terrain.Decoration = false
                end
            end)
            saved.GlobalShadows = Lighting.GlobalShadows
            Lighting.GlobalShadows = false
            for _, p in ipairs(Workspace:GetDescendants()) do cleanPart(p) end
            table.insert(conns, Workspace.DescendantAdded:Connect(function(d)
                if enabled then cleanPart(d) end
            end))
            pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
        else
            for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
            conns = {}
            pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic end)
            for obj, val in pairs(saved) do
                if typeof(obj) == "Instance" then
                    pcall(function()
                        if obj.Parent then obj.Enabled = val end
                    end)
                end
            end
            if saved.GlobalShadows ~= nil then Lighting.GlobalShadows = saved.GlobalShadows end
        end
    end
end

return FPSBoost
