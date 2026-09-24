local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LP = Players.LocalPlayer

local Utils = require(script.Parent.Parent.Utils)
local Theme = require(script.Parent.Parent.Theme)

local Aimbot = {}
local enabled = false
local pov = 35
local conn = nil
local circleFrame = nil
local target = nil
local locked = false
local lastCamCF = nil
local outTimer = 0
local teamSafe = true
local lockEnabled = false
local lockTarget = nil

local function getBodyPartPos(char, partName)
    if not char then return nil end
    if partName == "Kepala" then
        local hd = char:FindFirstChild("Head")
        if hd and hd:IsA("BasePart") then return hd.Position end
    elseif partName == "Leher" then
        local hd = char:FindFirstChild("Head")
        if hd and hd:IsA("BasePart") then return hd.Position - Vector3.new(0, 0.5, 0) end
    elseif partName == "Badan" then
        local ut = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
        if ut and ut:IsA("BasePart") then return ut.Position end
    elseif partName == "Paha" then
        local ul = char:FindFirstChild("LeftUpperLeg") or char:FindFirstChild("RightUpperLeg")
        if ul and ul:IsA("BasePart") then return ul.Position end
        local lt = char:FindFirstChild("LowerTorso")
        if lt and lt:IsA("BasePart") then return lt.Position - Vector3.new(0, 1, 0) end
    elseif partName == "Kaki" then
        local ft = char:FindFirstChild("LeftFoot") or char:FindFirstChild("RightFoot")
        if ft and ft:IsA("BasePart") then return ft.Position end
        local ll = char:FindFirstChild("LeftLowerLeg") or char:FindFirstChild("RightLowerLeg")
        if ll and ll:IsA("BasePart") then return ll.Position end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp and hrp:IsA("BasePart") then return hrp.Position - Vector3.new(0, 2.5, 0) end
    end
    local hrp = Utils.findBestEspPart(char)
    if hrp then return hrp.Position + Vector3.new(0, 1.5, 0) end
    return nil
end

local function getTargetInCone()
    local cam = Workspace.CurrentCamera
    if not cam then return nil end
    local mc = LP.Character
    if not mc then return nil end
    if not mc:FindFirstChild("HumanoidRootPart") then return nil end
    local cl = cam.CFrame.LookVector
    local ha = pov / 2
    local bt, bd = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character then
            local skip = teamSafe and Utils.isTeam(plr)
            if not skip then
                local h = plr.Character:FindFirstChildOfClass("Humanoid")
                if h and h.Health > 0 then
                    local tp = Utils.findBestEspPart(plr.Character)
                    if tp then
                        local tt = tp.Position - cam.CFrame.Position
                        local dst = tt.Magnitude
                        if dst > 0.1 then
                            local dt = cl:Dot(tt.Unit)
                            local ag = math.deg(math.acos(math.clamp(dt, -1, 1)))
                            if ag <= ha and dst < bd then
                                bd = dst
                                bt = plr
                            end
                        end
                    end
                end
            end
        end
    end
    return bt
end

local function isTargetInCone(plr)
    if not plr or not plr.Character then return false end
    local cam = Workspace.CurrentCamera
    if not cam then return false end
    local tp = Utils.findBestEspPart(plr.Character)
    if not tp then return false end
    local tt = tp.Position - cam.CFrame.Position
    if tt.Magnitude < 0.1 then return true end
    local cl = cam.CFrame.LookVector
    local dt = cl:Dot(tt.Unit)
    local ag = math.deg(math.acos(math.clamp(dt, -1, 1)))
    return ag <= pov / 2
end

local function getLocked()
    if not lockEnabled or not lockTarget then return nil end
    if not lockTarget.Parent or not lockTarget.Character then return nil end
    local h = lockTarget.Character:FindFirstChildOfClass("Humanoid")
    if not h or h.Health <= 0 then return nil end
    return lockTarget
end

local function updateCircle()
    if not circleFrame then return end
    local cam = Workspace.CurrentCamera
    if not cam then return end
    local vp = cam.ViewportSize
    local bs = math.min(vp.X, vp.Y)
    local rp = (pov / 360) * bs * 1.1
    if rp < 40 then rp = 40 end
    circleFrame.Size = UDim2.new(0, rp * 2, 0, rp * 2)
end

local function start()
    enabled = true
    if circleFrame then circleFrame.Visible = true end
    updateCircle()
    lastCamCF = Workspace.CurrentCamera and Workspace.CurrentCamera.CFrame or nil
    if conn then conn:Disconnect() end
    conn = RunService.RenderStepped:Connect(function(dt)
        if not enabled then return end
        local cam = Workspace.CurrentCamera
        if not cam then return end
        local mc = LP.Character
        if not mc or not mc:FindFirstChild("HumanoidRootPart") then return end

        local lk = getLocked()
        if lk then
            local tp = getBodyPartPos(lk.Character, _G._vanzAimbotBodyPart or "Kepala")
            if tp then
                local cp = cam.CFrame.Position
                cam.CFrame = CFrame.new(cp, tp)
            end
            return
        end

        if lastCamCF then
            local cur = cam.CFrame.LookVector
            local lst = lastCamCF.LookVector
            local dt2 = cur:Dot(lst)
            local ag = math.deg(math.acos(math.clamp(dt2, -1, 1)))
            if ag > 10.5 then
                locked = false
                target = nil
                outTimer = 0
            end
        end
        lastCamCF = cam.CFrame
        if not locked then
            local tg = getTargetInCone()
            if tg then
                target = tg
                locked = true
                outTimer = 0
            end
        end
        if locked and target then
            local tc = target.Character
            if not tc then
                locked = false target = nil return
            end
            local th = tc:FindFirstChildOfClass("Humanoid")
            if not th or th.Health <= 0 then
                locked = false target = nil return
            end
            if not isTargetInCone(target) then
                outTimer = outTimer + dt
                if outTimer > 0.3 then
                    locked = false target = nil outTimer = 0 return
                end
            else
                outTimer = 0
            end
            local tp = getBodyPartPos(target.Character, _G._vanzAimbotBodyPart or "Kepala")
            if not tp then
                locked = false target = nil return
            end
            local cp = cam.CFrame.Position
            cam.CFrame = CFrame.new(cp, tp)
        end
    end)
end

local function stop()
    enabled = false
    if conn then conn:Disconnect() conn = nil end
    if circleFrame then circleFrame.Visible = false end
    target = nil
    locked = false
    outTimer = 0
end

function Aimbot.init(ctx)
    local T = ctx.theme.T
    circleFrame = Instance.new("Frame", ctx.screen)
    circleFrame.Name = "vanzAimbotCircle"
    circleFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    circleFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    circleFrame.BackgroundTransparency = 1
    circleFrame.BorderSizePixel = 0
    circleFrame.Size = UDim2.new(0, 100, 0, 100)
    circleFrame.Visible = false
    circleFrame.ZIndex = 3
    Instance.new("UICorner", circleFrame).CornerRadius = UDim.new(1, 0)
    local st = Instance.new("UIStroke", circleFrame)
    st.Color = Theme.CA
    st.Thickness = 2
    st.Transparency = 0.15
    local dot = Instance.new("Frame", circleFrame)
    dot.AnchorPoint = Vector2.new(0.5, 0.5)
    dot.Size = UDim2.new(0, 10, 0, 10)
    dot.Position = UDim2.new(0.5, 0, 0.5, 0)
    dot.BackgroundColor3 = Theme.CA
    dot.BorderSizePixel = 0
    dot.ZIndex = 5
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

    Aimbot.set = function(state) if state then start() else stop() end end
    Aimbot.setPOV = function(v)
        pov = v
        updateCircle()
    end
    Aimbot.setTeamSafe = function(s) teamSafe = s end
    Aimbot.setLockEnabled = function(s) lockEnabled = s end
    Aimbot.setLockTarget = function(plr) lockTarget = plr end
    Aimbot.getBodyPartPos = getBodyPartPos
    Aimbot.getLocked = getLocked
end

return Aimbot
