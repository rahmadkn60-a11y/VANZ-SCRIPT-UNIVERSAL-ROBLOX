local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LP = Players.LocalPlayer

local Fly = {}
local flyConn, flyVel, flyAlign, flyAttach
local savedWS, savedJP
local upBtn, downBtn
local upPressed, downPressed = false, false
local flyEnabled = false
local wallhackRef = {enabled = false}

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
    local ccf = cam.CFrame
    local ff = Vector3.new(ccf.LookVector.X, 0, ccf.LookVector.Z)
    if ff.Magnitude < 0.01 then ff = Vector3.new(0, 0, -1) end
    ff = ff.Unit
    local fr = Vector3.new(ccf.RightVector.X, 0, ccf.RightVector.Z)
    if fr.Magnitude < 0.01 then fr = ff:Cross(Vector3.new(0, 1, 0)) end
    fr = fr.Unit
    local wm = (ff * -mv.Z) + (fr * mv.X)
    if wm.Magnitude > 0.01 then return wm.Unit end
    return Vector3.zero
end

local function getVertical()
    if UIS:IsKeyDown(Enum.KeyCode.Space) then return 1 end
    if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then return -1 end
    if upPressed then return 1 end
    if downPressed then return -1 end
    return 0
end

local function stop()
    flyEnabled = false
    if flyConn then flyConn:Disconnect() flyConn = nil end
    if flyVel then pcall(function() flyVel:Destroy() end) flyVel = nil end
    if flyAlign then pcall(function() flyAlign:Destroy() end) flyAlign = nil end
    if flyAttach then pcall(function() flyAttach:Destroy() end) flyAttach = nil end
    upPressed, downPressed = false, false
    if upBtn then upBtn.Visible = false end
    if downBtn then downBtn.Visible = false end
    local c = LP.Character
    if c then
        local h = c:FindFirstChildOfClass("Humanoid")
        if h then
            if savedWS then h.WalkSpeed = savedWS end
            if savedJP then h.JumpPower = savedJP end
            h.PlatformStand = false
            pcall(function() h:ChangeState(Enum.HumanoidStateType.GettingUp) end)
        end
        local hrp = c:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.AssemblyLinearVelocity = Vector3.zero end
    end
    savedWS, savedJP = nil, nil
endlocal function start()
    flyEnabled = true
    local c = LP.Character
    if not c then return end
    local hrp = c:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local h = c:FindFirstChildOfClass("Humanoid")
    if not h then return end
    savedWS, savedJP = h.WalkSpeed, h.JumpPower
    h.WalkSpeed, h.JumpPower = 0, 0
    pcall(function() h:ChangeState(Enum.HumanoidStateType.Physics) end)
    flyAttach = Instance.new("Attachment")
    flyAttach.Name = "vanzFlyAttach"
    flyAttach.Parent = hrp
    flyAlign = Instance.new("AlignOrientation")
    flyAlign.Mode = Enum.OrientationAlignmentMode.OneAttachment
    flyAlign.Attachment0 = flyAttach
    flyAlign.MaxTorque = 1e8
    flyAlign.Responsiveness = 100
    flyAlign.Parent = hrp
    flyVel = Instance.new("LinearVelocity")
    flyVel.Attachment0 = flyAttach
    flyVel.MaxForce = 1e8
    flyVel.VectorVelocity = Vector3.zero
    flyVel.RelativeTo = Enum.ActuatorRelativeTo.World
    flyVel.Parent = hrp
    upBtn.Visible = true
    downBtn.Visible = true
    flyConn = RunService.RenderStepped:Connect(function()
        if not flyEnabled then return end
        local cc = LP.Character
        if not cc then return end
        local root = cc:FindFirstChild("HumanoidRootPart")
        if not root then return end
        if not flyVel or not flyVel.Parent then return end
        if not flyAlign or not flyAlign.Parent then return end
        local mv = getAnalogMove()
        local vr = getVertical()
        local sp = (LP.Character:FindFirstChildOfClass("Humanoid") and LP.Character:FindFirstChildOfClass("Humanoid").WalkSpeed) or 16
        if sp <= 0 then sp = 16 end
        local fm = mv
        if vr ~= 0 then
            fm = Vector3.new(mv.X, 0, mv.Z) + Vector3.new(0, vr, 0)
            if fm.Magnitude > 0.01 then fm = fm.Unit end
        end
        flyVel.VectorVelocity = fm * sp
        local cam = Workspace.CurrentCamera
        if cam then flyAlign.CFrame = cam.CFrame end
    end)
end

function Fly.init(ctx)
    local T = ctx.theme.T
    local screen = ctx.screen
    upBtn = Instance.new("TextButton", screen)
    upBtn.AnchorPoint = Vector2.new(1, 1)
    upBtn.Size = UDim2.new(0, 54, 0, 54)
    upBtn.Position = UDim2.new(1, -14, 1, -156)
    upBtn.BackgroundColor3 = T.panel
    upBtn.Text = "▲"
    upBtn.TextColor3 = T.accent
    upBtn.TextSize = 24
    upBtn.Font = Enum.Font.GothamBold
    upBtn.Visible = false
    upBtn.Active = true
    upBtn.AutoButtonColor = false
    upBtn.ZIndex = 250
    Instance.new("UICorner", upBtn).CornerRadius = UDim.new(1, 0)
    upBtn.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseButton1 then
            upPressed = true
            upBtn.BackgroundColor3 = T.accent
            upBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        end
    end)
    upBtn.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseButton1 then
            upPressed = false
            upBtn.BackgroundColor3 = T.panel
            upBtn.TextColor3 = T.accent
        end
    end)

    downBtn = Instance.new("TextButton", screen)
    downBtn.AnchorPoint = Vector2.new(1, 1)
    downBtn.Size = UDim2.new(0, 54, 0, 54)
    downBtn.Position = UDim2.new(1, -14, 1, -94)
    downBtn.BackgroundColor3 = T.panel
    downBtn.Text = "▼"
    downBtn.TextColor3 = T.accent
    downBtn.TextSize = 24
    downBtn.Font = Enum.Font.GothamBold
    downBtn.Visible = false
    downBtn.Active = true
    downBtn.AutoButtonColor = false
    downBtn.ZIndex = 250
    Instance.new("UICorner", downBtn).CornerRadius = UDim.new(1, 0)
    downBtn.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseButton1 then
            downPressed = true
            downBtn.BackgroundColor3 = T.accent
            downBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        end
    end)
    downBtn.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseButton1 then
            downPressed = false
            downBtn.BackgroundColor3 = T.panel
            downBtn.TextColor3 = T.accent
        end
    end)

    Fly.set = function(state)
        if state then start() else stop() end
    end
    Fly.isEnabled = function() return flyEnabled end
    Fly.toggle = function(state)
        if state then start() else stop() end
    end
    Fly.onCharAdded = function()
        if flyEnabled then
            task.wait(0.3)
            if flyEnabled then stop() start() end
        end
    end
end

return Fly
