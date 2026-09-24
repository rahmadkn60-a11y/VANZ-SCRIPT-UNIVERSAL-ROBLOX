local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LP = Players.LocalPlayer

local AimbotLock = {}
local lockListFrame = nil
local rows = {}
local standaloneConn = nil
local lockTarget = nil
local lockEnabled = false

local function refresh()
    if not lockListFrame then return end
    for _, row in pairs(rows) do pcall(function() row:Destroy() end) end
    rows = {}
    if lockTarget and lockTarget.Parent == nil then
        lockTarget = nil
        lockEnabled = false
        if standaloneConn then standaloneConn:Disconnect() standaloneConn = nil end
    end
    local T = AimbotLock.T
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP then
            local row = Instance.new("TextButton")
            row.Size = UDim2.new(1, 0, 0, 30)
            row.BackgroundColor3 = T.row
            row.BorderSizePixel = 0
            row.Text = "  " .. plr.DisplayName .. "  (@" .. plr.Name .. ")"
            row.TextColor3 = T.text
            row.TextSize = 11
            row.Font = Enum.Font.Gotham
            row.TextXAlignment = Enum.TextXAlignment.Left
            row.AutoButtonColor = true
            row.ZIndex = 2
            Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)
            row.Parent = lockListFrame
            rows[plr] = row
            row.MouseButton1Click:Connect(function()
                lockTarget = plr
                for p, r in pairs(rows) do
                    if p == plr then
                        r.BackgroundColor3 = T.sel
                        r.TextColor3 = Color3.fromRGB(255, 255, 255)
                    else
                        r.BackgroundColor3 = T.row
                        r.TextColor3 = T.text
                    end
                end
                AimbotLock.setLockTarget(plr)
                if lockEnabled then AimbotLock.apply() end
            end)
        end
    end
    if lockTarget and rows[lockTarget] then
        rows[lockTarget].BackgroundColor3 = T.sel
        rows[lockTarget].TextColor3 = Color3.fromRGB(255, 255, 255)
    end
end

function AimbotLock.init(ctx)
    AimbotLock.T = ctx.theme.T
    AimbotLock.screen = ctx.screen
    AimbotLock.aimbot = ctx.aimbot

    Players.PlayerAdded:Connect(function()
        task.wait(0.5)
        refresh()
    end)
    Players.PlayerRemoving:Connect(function(plr)
        if lockTarget == plr then
            lockTarget = nil
            lockEnabled = false
            if standaloneConn then standaloneConn:Disconnect() standaloneConn = nil end
        end
        task.wait(0.1)
        refresh()
    end)
    task.spawn(function()
        while true do
            task.wait(0.5)
            refresh()
        end
    end)

    AimbotLock.setFrame = function(frame)
        lockListFrame = frame
    end
    AimbotLock.apply = function()
        if standaloneConn then standaloneConn:Disconnect() standaloneConn = nil end
        if not lockEnabled or not lockTarget then return end
        standaloneConn = RunService.RenderStepped:Connect(function()
            if not lockEnabled then return end
            local cam = Workspace.CurrentCamera
            if not cam then return end
            local locked = AimbotLock.aimbot.getLocked and AimbotLock.aimbot.getLocked()
            if not locked then return end
            local tp = AimbotLock.aimbot.getBodyPartPos(locked.Character, _G._vanzAimbotBodyPart or "Kepala")
            if not tp then return end
            local cp = cam.CFrame.Position
            cam.CFrame = CFrame.new(cp, tp)
        end)
    end
    AimbotLock.setEnabled = function(s)
        lockEnabled = s
        if s then
            if lockTarget then AimbotLock.apply() else lockEnabled = false end
        else
            if standaloneConn then standaloneConn:Disconnect() standaloneConn = nil end
        end
    end
    AimbotLock.setLockTarget = function(plr)
        if AimbotLock.aimbot.setLockTarget then AimbotLock.aimbot.setLockTarget(plr) end
    end
end

return AimbotLock
