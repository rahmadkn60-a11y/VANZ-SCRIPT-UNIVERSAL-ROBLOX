local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LP = Players.LocalPlayer
local Utils = require(script.Parent.Parent.Utils)
local Theme = require(script.Parent.Parent.Theme)

local Radius = {}
local enabled = false
local size = 10
local adornment = nil
local conn = nil
local offsetY = -2.5

local function create()
    if adornment then return end
    local char = LP.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local ad = Instance.new("CylinderHandleAdornment")
    ad.Name = "vanzRadiusInd"
    ad.Adornee = hrp
    ad.AlwaysOnTop = true
    ad.ZIndex = 5
    ad.Height = 0.2
    ad.Radius = size
    ad.Color3 = Theme.CT
    ad.Transparency = 0.3
    ad.CFrame = CFrame.new(0, offsetY, 0) * CFrame.Angles(math.rad(90), 0, 0)
    ad.Parent = hrp
    adornment = ad
end

local function destroy()
    if adornment then
        pcall(function() adornment:Destroy() end)
        adornment = nil
    end
end

local function updateColor()
    if not adornment then return end
    local char = LP.Character
    if not char then return end
    local myHrp = char:FindFirstChild("HumanoidRootPart")
    if not myHrp then return end
    local threat = false
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character then
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.Health > 0 then
                if (hrp.Position - myHrp.Position).Magnitude <= size and not Utils.isTeam(plr) then
                    threat = true
                    break
                end
            end
        end
    end
    if threat then
        adornment.Color3 = Theme.CE
        adornment.Transparency = 0.15
    else
        adornment.Color3 = Theme.CT
        adornment.Transparency = 0.3
    end
end

local function start()
    enabled = true
    create()
    if conn then conn:Disconnect() end
    conn = RunService.RenderStepped:Connect(function()
        if not enabled then return end
        if not adornment or not adornment.Parent then create() return end
        adornment.Radius = size
        updateColor()
    end)
end

local function stop()
    enabled = false
    if conn then conn:Disconnect() conn = nil end
    destroy()
end

function Radius.init()
    Radius.set = function(s) if s then start() else stop() end end
    Radius.setSize = function(v)
        size = v
        if adornment then adornment.Radius = v end
    end
    Radius.onCharAdded = function()
        if enabled then
            task.wait(0.3)
            destroy()
            create()
        end
    end
end

return Radius
