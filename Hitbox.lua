local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local Utils = require(script.Parent.Parent.Utils)

local Hitbox = {}
local enabled = false
local size = 5
local teamSafe = true
local data = {}

local function clearTag(plr)
    local d = data[plr]
    if not d then return end
    if d.originalSize then
        pcall(function()
            if d.hrp and d.hrp.Parent then
                d.hrp.Size = d.originalSize
                d.hrp.Transparency = d.originalTransparency
                d.hrp.CanCollide = d.originalCanCollide
            end
        end)
    end
    if d.box then pcall(function() d.box:Destroy() end) end
    data[plr] = nil
end

local function applyTag(plr)
    if data[plr] then return end
    local char = plr.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local origSize, origTrans, origCol = hrp.Size, hrp.Transparency, hrp.CanCollide
    hrp.Size = Vector3.new(size, size, size)
    hrp.Transparency = 0.7
    hrp.CanCollide = false
    local box = Instance.new("BoxHandleAdornment")
    box.Name = "vanzHitboxBox"
    box.Adornee = hrp
    box.AlwaysOnTop = true
    box.ZIndex = 6
    box.Size = hrp.Size + Vector3.new(0.1, 0.1, 0.1)
    box.Transparency = 0.2
    box.Color3 = Color3.fromRGB(255, 40, 40)
    box.Parent = hrp
    data[plr] = {hrp = hrp, box = box, originalSize = origSize, originalTransparency = origTrans, originalCanCollide = origCol}
end

local function refresh()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP then
            local skip = teamSafe and Utils.isTeam(plr)
            if not skip then
                if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    if not data[plr] then
                        applyTag(plr)
                    else
                        local d = data[plr]
                        if d.hrp and d.hrp.Parent then
                            d.hrp.Size = Vector3.new(size, size, size)
                            if d.box then d.box.Size = d.hrp.Size + Vector3.new(0.1, 0.1, 0.1) end
                        end
                    end
                elseif data[plr] then
                    clearTag(plr)
                end
            elseif data[plr] then
                clearTag(plr)
            end
        end
    end
end

function Hitbox.init()
    Players.PlayerAdded:Connect(function(plr)
        task.wait(1)
        if enabled then refresh() end
        plr.CharacterAdded:Connect(function()
            task.wait(0.8)
            if enabled then clearTag(plr) refresh() end
        end)
    end)
    Players.PlayerRemoving:Connect(function(plr) clearTag(plr) end)
    task.spawn(function()
        while true do
            task.wait(0.5)
            if enabled then refresh() end
        end
    end)
    Hitbox.set = function(state)
        enabled = state
        if state then refresh() else
            for plr, _ in pairs(data) do clearTag(plr) end
            data = {}
        end
    end
    Hitbox.setTeamSafe = function(s) teamSafe = s end
    Hitbox.setSize = function(v)
        size = v
        if enabled then refresh() end
    end
end

return Hitbox
