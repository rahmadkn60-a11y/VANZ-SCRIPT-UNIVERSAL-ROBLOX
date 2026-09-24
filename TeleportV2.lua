local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LP = Players.LocalPlayer

local TeleportV2 = {}
local enabled = false
local savedCFrame, savedAnchored, savedWS, savedJP
local conn
local phantomPos, originPos
local markerPart, markerHL, markerBox, markerSphere, markerBB, markerLine
local flyWasActive = false
local flyRef = nil

local function getAnalogMove()
    local c = LP.Character
    if not c then return Vector3.zero end
    local h = c:FindFirstChildOfClass("Humanoid")
    if not h then return Vector3.zero end
    local md = h.MoveDirection
    if md.Magnitude > 0.05 then return md.Unit end
    local mv = Vector3.zero
    if UIS:IsKeyDown(Enum.KeyCode.W) then mv = mv + Vector3.new(0, 0, -1) end
    if UIS:IsKeyDown(Enum.KeyCode.S) then mv = mv + Vector3.new(0, 0, 1) end
    if UIS:IsKeyDown(Enum.KeyCode.A) then mv = mv + Vector3.new(-1, 0, 0) end
    if UIS:IsKeyDown(Enum.KeyCode.D) then mv = mv + Vector3.new(1, 0, 0) end
    if mv.Magnitude < 0.05 then return Vector3.zero end
    local cam = Workspace.CurrentCamera
    if not cam then return Vector3.zero end
    local ff = Vector3.new(cam.CFrame.LookVector.X, 0, cam.CFrame.LookVector.Z)
    if ff.Magnitude < 0.01 then ff = Vector3.new(0, 0, -1) end
    ff = ff.Unit
    local fr = Vector3.new(cam.CFrame.RightVector.X, 0, cam.CFrame.RightVector.Z)
    if fr.Magnitude < 0.01 then fr = ff:Cross(Vector3.new(0, 1, 0)) end
    fr = fr.Unit
    local wm = (ff * -mv.Z) + (fr * mv.X)
    if wm.Magnitude > 0.01 then return wm.Unit end
    return Vector3.zero
end

local function getVertical()
    if UIS:IsKeyDown(Enum.KeyCode.Space) then return 1 end
    if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then return -1 end
    return 0
end

local function getSpeed()
    local h = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if h then return h.WalkSpeed end
    return 16
end

local function checkCollision(char, fromPos, toPos)
    local pr = RaycastParams.new()
    pr.FilterType = Enum.RaycastFilterType.Exclude
    pr.FilterDescendantsInstances = {char}
    pr.IgnoreWater = true
    local dir = toPos - fromPos
    local dist = dir.Magnitude
    if dist < 0.01 then return false end
    local res = Workspace:Raycast(fromPos, dir.Unit * dist, pr)
    if res and res.Instance and res.Instance.CanCollide then return true end
    return false
end

local function createMarker(originPos)
    local mp = Instance.new("Part")
    mp.Name = "vanzOriginMarker"
    mp.Size = Vector3.new(2, 5, 1)
    mp.Position = originPos
    mp.Anchored = true
    mp.CanCollide = false
    mp.CanQuery = false
    mp.CanTouch = false
    mp.Transparency = 0.75
    mp.Color = Color3.fromRGB(180, 80, 255)
    mp.Material = Enum.Material.Neon
    mp.Parent = Workspace
    markerPart = mp
    local hl = Instance.new("Highlight")
    hl.Adornee = mp
    hl.FillColor = Color3.fromRGB(180, 80, 255)
    hl.FillTransparency = 0.5
    hl.OutlineColor = Color3.fromRGB(255, 200, 80)
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent = mp
    markerHL = hl
    local box = Instance.new("BoxHandleAdornment")
    box.Adornee = mp
    box.AlwaysOnTop = true
    box.ZIndex = 8
    box.Size = Vector3.new(2.2, 5.2, 1.2)
    box.Transparency = 0.3
    box.Color3 = Color3.fromRGB(255, 200, 80)
    box.Parent = mp
    markerBox = box
    local sph = Instance.new("SphereHandleAdornment")
    sph.Adornee = mp
    sph.AlwaysOnTop = true
    sph.ZIndex = 7
    sph.Radius = 1.5
    sph.Transparency = 0.6
    sph.Color3 = Color3.fromRGB(180, 80, 255)
    sph.Parent = mp
    markerSphere = sph
    local bb = Instance.new("BillboardGui")
    bb.Size = UDim2.new(0, 140, 0, 40)
    bb.StudsOffset = Vector3.new(0, 4, 0)
    bb.AlwaysOnTop = true
    bb.Parent = mp
    markerBB = bb
    local lbl = Instance.new("TextLabel", bb)
    lbl.Size = UDim2.new(1, 0, 0, 22)
    lbl.BackgroundTransparency = 1
    lbl.Text = "♡ ORIGIN"
    lbl.TextColor3 = Color3.fromRGB(255, 200, 80)
    lbl.TextStrokeTransparency = 0
    lbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    lbl.TextSize = 16
    lbl.Font = Enum.Font.GothamBold
    local sub = Instance.new("TextLabel", bb)
    sub.Size = UDim2.new(1, 0, 0, 16)
    sub.Position = UDim2.new(0, 0, 0, 22)
    sub.BackgroundTransparency = 1
    sub.Text = "posisi asli kamu"
    sub.TextColor3 = Color3.fromRGB(200, 200, 220)
    sub.TextStrokeTransparency = 0.3
    sub.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    sub.TextSize = 11
    sub.Font = Enum.Font.Gotham
    local line = Instance.new("Frame", TeleportV2.screen)
    line.BackgroundColor3 = Color3.fromRGB(180, 80, 255)
    line.BorderSizePixel = 0
    line.ZIndex = 5
    line.Size = UDim2.new(0, 0, 0, 1)
    markerLine = line
end

local function destroyMarker()
    for _, o in ipairs({markerPart, markerHL, markerBox, markerSphere, markerBB, markerLine}) do
        if o then pcall(function() o:Destroy() end) end
    end
    markerPart, markerHL, markerBox, markerSphere, markerBB, markerLine = nil, nil, nil, nil, nil, nil
end

local function stop()
    if not enabled then return end
    enabled = false
    if conn then conn:Disconnect() conn = nil end
    local char = LP.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            if phantomPos then hrp.CFrame = CFrame.new(phantomPos) end
            hrp.Anchored = false
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
        end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.PlatformStand = false
            pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Physics, false) end)
            hum.WalkSpeed = savedWS or 16
            if savedJP then hum.JumpPower = savedJP end
            pcall(function() hum:ChangeState(Enum.HumanoidStateType.GettingUp) end)
            task.wait(0.1)
            pcall(function() hum:ChangeState(Enum.HumanoidStateType.Running) end)
        end
    end
    destroyMarker()
    local flyRestart = flyWasActive
    flyWasActive = false
    if flyRestart and flyRef and flyRef.enabled then
        task.wait(0.15)
        if TeleportV2.flyStart then TeleportV2.flyStart() end
    end
    savedCFrame, savedAnchored, savedWS, savedJP = nil, nil, nil, nil
    phantomPos, originPos = nil, nil
end

local function start()
    local char = LP.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    flyWasActive = flyRef and flyRef.enabled
    if flyWasActive and TeleportV2.flyStop then TeleportV2.flyStop() end
    enabled = true
    savedCFrame = hrp.CFrame
    savedAnchored = hrp.Anchored
    savedWS = hum.WalkSpeed
    savedJP = hum.JumpPower
    phantomPos = hrp.Position
    originPos = hrp.Position
    createMarker(originPos)
    hrp.Anchored = true
    pcall(function()
        hum:SetStateEnabled(Enum.HumanoidStateType.Physics, true)
        hum:ChangeState(Enum.HumanoidStateType.Physics)
    end)
    if conn then conn:Disconnect() end
    conn = RunService.RenderStepped:Connect(function(dt)
        if not enabled then return end
        local c = LP.Character
        if not c then return end
        local root = c:FindFirstChild("HumanoidRootPart")
        if not root then return end
        local move = getAnalogMove()
        local vertical = getVertical()
        local speed = getSpeed()
        if speed <= 0 then speed = 16 end
        local fm = move
        if vertical ~= 0 then
            fm = Vector3.new(move.X, 0, move.Z) + Vector3.new(0, vertical, 0)
            if fm.Magnitude > 0.01 then fm = fm.Unit end
        end
        if fm.Magnitude < 0.01 then return end
        local distance = speed * dt
        local toPos = phantomPos + fm * distance
        if checkCollision(c, phantomPos, toPos) then return end
        phantomPos = toPos
        root.CFrame = CFrame.new(toPos) * (root.CFrame - root.Position)
    end)
    if markerLine then
        task.spawn(function()
            while enabled do
                task.wait()
                local cam = Workspace.CurrentCamera
                if cam and markerLine and markerLine.Parent then
                    local origin = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y)
                    if phantomPos and originPos then
                        local pos1, on1 = cam:WorldToViewportPoint(phantomPos)
                        local pos2, on2 = cam:WorldToViewportPoint(originPos)
                        if on1 and on2 and pos1.Z > 0 and pos2.Z > 0 then
                            markerLine.Visible = true
                            local target = Vector2.new(pos2.X, pos2.Y)
                            local diff = target - origin
                            local length = diff.Magnitude
                            local angle = math.deg(math.atan2(diff.Y, diff.X))
                            markerLine.Position = UDim2.new(0, origin.X, 0, origin.Y)
                            markerLine.Size = UDim2.new(0, length, 0, 2)
                            markerLine.Rotation = angle
                        else
                            markerLine.Visible = false
                        end
                    end
                end
            end
        end)
    end
end

function TeleportV2.init(ctx)
    TeleportV2.screen = ctx.screen
    TeleportV2.flyRef = ctx.flyRef
    TeleportV2.flyStart = ctx.flyStart
    TeleportV2.flyStop = ctx.flyStop
    TeleportV2.set = function(s) if s then start() else stop() end end
    TeleportV2.onCharAdded = function() if enabled then stop() end end
end

return TeleportV2
