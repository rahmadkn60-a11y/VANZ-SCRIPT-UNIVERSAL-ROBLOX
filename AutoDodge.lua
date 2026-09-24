local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LP = Players.LocalPlayer
local Utils = require(script.Parent.Parent.Utils)

local AutoDodge = {}
local enabled = false
local teamSafe = true
local conn = nil
local radius = 12
local distance = 20
local cooldown = 0.3
local lastTime = 0
local indicator = nil

local function getAttackerDir(myHrp)
    local threatDir = Vector3.zero
    local count = 0
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character then
            local skip = teamSafe and Utils.isTeam(plr)
            if not skip then
                local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                local h = plr.Character:FindFirstChildOfClass("Humanoid")
                if hrp and h and h.Health > 0 then
                    local diff = hrp.Position - myHrp.Position
                    local dist = diff.Magnitude
                    if dist <= radius and dist > 0.5 then
                        local dirToMe = (myHrp.Position - hrp.Position).Unit
                        local dot = hrp.CFrame.LookVector:Dot(dirToMe)
                        if dot > 0.3 then
                            threatDir = threatDir + dirToMe
                            count = count + 1
                        end
                    end
                end
            end
        end
    end
    local myChar = LP.Character
    if myChar then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj ~= myChar then
                local n = obj.Name:lower()
                if n:find("projectile") or n:find("bullet") or n:find("grenade") or n:find("bomb") or n:find("arrow") or n:find("throw") then
                    local dist = (obj.Position - myHrp.Position).Magnitude
                    if dist <= radius then
                        threatDir = threatDir + (myHrp.Position - obj.Position).Unit
                        count = count + 1
                    end
                end
            end
        end
    end
    if count > 0 then return threatDir.Unit end
    return nil
end

local function flash()
    if not indicator then return end
    indicator.Visible = true
    indicator.TextTransparency = 0
    indicator.BackgroundTransparency = 0.3
    task.spawn(function()
        task.wait(0.3)
        for i = 1, 10 do
            task.wait(0.03)
            indicator.TextTransparency = i / 10
            indicator.BackgroundTransparency = 0.3 + (i / 10) * 0.7
        end
        indicator.Visible = false
    end)
end

local function start()
    enabled = true
    if not indicator then
        indicator = Instance.new("TextLabel", AutoDodge.screen)
        indicator.Name = "vanzDodgeInd"
        indicator.AnchorPoint = Vector2.new(0.5, 0)
        indicator.Size = UDim2.new(0, 180, 0, 30)
        indicator.Position = UDim2.new(0.5, 0, 0, 60)
        indicator.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
        indicator.BackgroundTransparency = 0.3
        indicator.Text = "DODGED!"
        indicator.TextColor3 = Color3.fromRGB(255, 255, 255)
        indicator.TextSize = 16
        indicator.Font = Enum.Font.GothamBold
        indicator.Visible = false
        indicator.ZIndex = 300
        Instance.new("UICorner", indicator).CornerRadius = UDim.new(0, 8)
    end
    if conn then conn:Disconnect() end
    conn = RunService.Stepped:Connect(function(_, dt)
        if not enabled then return end
        local now = tick()
        if now - lastTime < cooldown then return end
        local myChar = LP.Character
        if not myChar then return end
        local myHrp = myChar:FindFirstChild("HumanoidRootPart")
        if not myHrp then return end
        local threatDir = getAttackerDir(myHrp)
        if not threatDir then return end
        lastTime = now
        local newPos = myHrp.Position + threatDir * distance
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = {myChar}
        params.IgnoreWater = true
        local groundRes = Workspace:Raycast(newPos + Vector3.new(0, 5, 0), Vector3.new(0, -100, 0), params)
        if groundRes and groundRes.Instance then
            newPos = Vector3.new(newPos.X, groundRes.Position.Y + 3, newPos.Z)
        end
        myHrp.CFrame = CFrame.new(newPos) *
