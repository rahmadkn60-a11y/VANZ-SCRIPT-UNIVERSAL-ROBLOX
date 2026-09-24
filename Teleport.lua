local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LP = Players.LocalPlayer
local Utils = require(script.Parent.Parent.Utils)

local Teleport = {}
local selected = nil
local listFrame = nil
local rows = {}
local followEnabled = false
local followConn = nil
local followHeight = 5

local function refresh()
    if not listFrame then return end
    for _, row in pairs(rows) do pcall(function() row:Destroy() end) end
    rows = {}
    if selected and selected.Parent == nil then
        selected = nil
        Teleport.stopFollow()
    end
    local T = Teleport.T
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP then
            local row = Instance.new("TextButton")
            row.Size = UDim2.new(1, 0, 0, 34)
            row.BackgroundColor3 = T.row
            row.BorderSizePixel = 0
            row.Text = "  " .. plr.DisplayName .. "  (@" .. plr.Name .. ")"
            row.TextColor3 = T.text
            row.TextSize = 12
            row.Font = Enum.Font.Gotham
            row.TextXAlignment = Enum.TextXAlignment.Left
            row.AutoButtonColor = true
            row.ZIndex = 2
            Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)
            row.Parent = listFrame
            rows[plr] = row
            row.MouseButton1Click:Connect(function()
                selected = plr
                for p, r in pairs(rows) do
                    if p == plr then
                        r.BackgroundColor3 = T.sel
                        r.TextColor3 = Color3.fromRGB(255, 255, 255)
                    else
                        r.BackgroundColor3 = T.row
                        r.TextColor3 = T.text
                    end
                end
            end)
        end
    end
    if selected and rows[selected] then
        rows[selected].BackgroundColor3 = T.sel
        rows[selected].TextColor3 = Color3.fromRGB(255, 255, 255)
    end
end

local function teleportTo(plr)
    if not plr then return end
    local tc = plr.Character
    if not tc then return end
    local th = Utils.findBestEspPart(tc)
    if not th then return end
    local mc = LP.Character
    if not mc then return end
    local mh = mc:FindFirstChild("HumanoidRootPart")
    if not mh then return end
    mh.CFrame = CFrame.new(th.Position + Vector3.new(0, 5, 0))
end

function Teleport.init(ctx)
    Teleport.T = ctx.theme.T
    Teleport.screen = ctx.screen
    Players.PlayerAdded:Connect(function()
        task.wait(0.5)
        refresh()
    end)
    Players.PlayerRemoving:Connect(function(plr)
        if selected == plr then selected = nil Teleport.stopFollow() end
        task.wait(0.1)
        refresh()
    end)
    task.spawn(function()
        while true do
            task.wait(0.5)
            refresh()
        end
    end)
    Teleport.setFrame = function(f) listFrame = f end
    Teleport.getSelected = function() return selected end
    Teleport.teleportTo = teleportTo
    Teleport.refresh = refresh
    Teleport.stopFollow = function()
        followEnabled = false
        if followConn then followConn:Disconnect() followConn = nil end
    end
    Teleport.startFollow = function()
        if followConn then followConn:Disconnect() followConn = nil end
        followConn = RunService.RenderStepped:Connect(function()
            if not followEnabled or not selected then return end
            local tc = selected.Character
            if not tc then return end
            local th = Utils.findBestEspPart(tc)
            if not th then return end
            local mc = LP.Character
            if not mc then return end
            local mh = mc:FindFirstChild("HumanoidRootPart")
            if not mh then return end
            mh.CFrame = CFrame.new(th.Position + Vector3.new(0, followHeight, 0))
        end)
    end
    Teleport.setFollow = function(state)
        followEnabled = state
        if state then
            if selected then Teleport.startFollow() else followEnabled = false end
        else
            Teleport.stopFollow()
        end
    end
    Teleport.setFollowHeight = function(v) followHeight = v end
end

return Teleport
