local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LP = Players.LocalPlayer

local Utils = require(script.Parent.Parent.Utils)
local Theme = require(script.Parent.Parent.Theme)

local ESP = {}
local enabled = false
local espData = {}

local function createTag(plr)
    if espData[plr] then return end
    local char = plr.Character
    if not char then return end
    local hrp = Utils.findBestEspPart(char)
    local hd = Utils.findHeadPart(char)
    local h = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not h then return end
    local col = Utils.getPlayerColor(plr, Theme.CT, Theme.CE, Theme.CU)
    local box = Instance.new("BoxHandleAdornment")
    box.Name = "vanzESPBox"
    box.Adornee = hrp
    box.AlwaysOnTop = true
    box.ZIndex = 4
    box.Size = Vector3.new(2, 5, 1) + Vector3.new(0.2, 0.2, 0.2)
    box.Transparency = 0.5
    box.Color3 = col
    box.Parent = hrp

    local hl = Instance.new("Highlight")
    hl.Name = "vanzESPHL"
    hl.Adornee = char
    hl.FillColor = col
    hl.FillTransparency = 0.6
    hl.OutlineColor = col
    hl.OutlineTransparency = 0.2
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent = char

    local bb = Instance.new("BillboardGui")
    bb.Name = "vanzESPBB"
    bb.Size = UDim2.new(0, 160, 0, 50)
    bb.StudsOffset = Vector3.new(0, 3.2, 0)
    bb.AlwaysOnTop = true
    bb.Parent = hd or hrp

    local nl = Instance.new("TextLabel", bb)
    nl.Size = UDim2.new(1, 0, 0, 16)
    nl.BackgroundTransparency = 1
    nl.Text = plr.DisplayName .. " (@" .. plr.Name .. ")"
    nl.TextColor3 = col
    nl.TextStrokeTransparency = 0
    nl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    nl.TextSize = 12
    nl.Font = Enum.Font.GothamBold

    local hb = Instance.new("Frame", bb)
    hb.Size = UDim2.new(1, 0, 0, 6)
    hb.Position = UDim2.new(0, 0, 0, 20)
    hb.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    hb.BorderSizePixel = 0
    Instance.new("UICorner", hb).CornerRadius = UDim.new(1, 0)

    local hf = Instance.new("Frame", hb)
    hf.Size = UDim2.new(1, 0, 1, 0)
    hf.BackgroundColor3 = Color3.fromRGB(80, 220, 120)
    hf.BorderSizePixel = 0
    Instance.new("UICorner", hf).CornerRadius = UDim.new(1, 0)

    local ht = Instance.new("TextLabel", bb)
    ht.Size = UDim2.new(1, 0, 0, 14)
    ht.Position = UDim2.new(0, 0, 0, 28)
    ht.BackgroundTransparency = 1
    ht.Text = "100 / 100"
    ht.TextColor3 = Color3.fromRGB(200, 240, 210)
    ht.TextStrokeTransparency = 0
    ht.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    ht.TextSize = 11
    ht.Font = Enum.Font.Gotham

    local line = Instance.new("Frame", ESP.screen)
    line.Name = "vanzESPLine_" .. plr.Name
    line.BackgroundColor3 = col
    line.BorderSizePixel = 0
    line.ZIndex = 2
    line.Size = UDim2.new(0, 0, 0, 1)

    espData[plr] = {box = box, hl = hl, bb = bb, line = line, nameLbl = nl, hf = hf, ht = ht, lastColor = col, lastChar = char}
end

local function destroyTag(plr)
    local d = espData[plr]
    if not d then return end
    pcall(function() d.box:Destroy() end)
    pcall(function() d.hl:Destroy() end)
    pcall(function() d.bb:Destroy() end)
    pcall(function() d.line:Destroy() end)
    espData[plr] = nil
end

local function clearAll()
    for plr, _ in pairs(espData) do destroyTag(plr) end
    espData = {}
end

local function refresh()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP then
            if plr.Character then
                local h = plr.Character:FindFirstChildOfClass("Humanoid")
                if h and h.Health > 0 then
                    if not espData[plr] then
                        createTag(plr)
                    elseif espData[plr].lastChar ~= plr.Character then
                        destroyTag(plr)
                        task.wait()
                        createTag(plr)
                    end
                elseif espData[plr] then
                    destroyTag(plr)
                end
            elseif espData[plr] then
                destroyTag(plr)
            end
        end
    end
end

function ESP.init(ctx)
    ESP.screen = ctx.screen
    Players.PlayerAdded:Connect(function(plr)
        task.wait(1)
        if enabled then refresh() end
        plr.CharacterAdded:Connect(function()
            task.wait(0.8)
            if enabled then destroyTag(plr) refresh() end
        end)
    end)
    Players.PlayerRemoving:Connect(function(plr) destroyTag(plr) end)
    task.spawn(function()
        while true do
            task.wait(1)
            if enabled then refresh() end
        end
    end)

    RunService.RenderStepped:Connect(function()
        if not enabled then return end
        local cam = Workspace.CurrentCamera
        if not cam then return end
        local ox = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y)
        for plr, d in pairs(espData) do
            local char = plr.Character
            if char then
                local hrp = Utils.findBestEspPart(char)
                local hd = Utils.findHeadPart(char)
                local h = char:FindFirstChildOfClass("Humanoid")
                if hrp and h then
                    if d.lastChar ~= char then
                        d.lastChar = char
                        pcall(function() d.hl.Adornee = char end)
                        pcall(function() d.bb.Parent = hd or hrp end)
                    end
                    local col = Utils.getPlayerColor(plr, Theme.CT, Theme.CE, Theme.CU)
                    if col ~= d.lastColor then
                        d.lastColor = col
                        pcall(function() d.box.Color3 = col end)
                        pcall(function()
                            d.hl.FillColor = col
                            d.hl.OutlineColor = col
                        end)
                        pcall(function()
                            d.nameLbl.TextColor3 = col
                            d.line.BackgroundColor3 = col
                        end)
                    end
                    d.box.Adornee = hrp
                    local pct = math.clamp(h.Health / math.max(h.MaxHealth, 1), 0, 1)
                    d.hf.Size = UDim2.new(pct, 0, 1, 0)
                    d.hf.BackgroundColor3 = Color3.fromRGB(math.floor(255 * (1 - pct)), math.floor(220 * pct), 80)
                    d.ht.Text = math.floor(h.Health) .. " / " .. math.floor(h.MaxHealth)
                    d.nameLbl.Text = plr.DisplayName .. " (@" .. plr.Name .. ")"
                    local pos, os = cam:WorldToViewportPoint(hrp.Position)
                    if os and pos.Z > 0 then
                        d.line.Visible = true
                        local tg = Vector2.new(pos.X, pos.Y)
                        local df = tg - ox
                        local ln = df.Magnitude
                        local an = math.deg(math.atan2(df.Y, df.X))
                        d.line.Position = UDim2.new(0, ox.X, 0, ox.Y)
                        d.line.Size = UDim2.new(0, ln, 0, 1)
                        d.line.Rotation = an
                    else
                        d.line.Visible = false
                    end
                end
            end
        end
    end)

    ESP.set = function(state)
        enabled = state
        if state then refresh() else clearAll() end
    end
end

return ESP
