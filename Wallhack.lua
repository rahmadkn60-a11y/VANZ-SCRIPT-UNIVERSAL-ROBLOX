local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LP = Players.LocalPlayer

local Wallhack = {}
local enabled = false
local antiFall = true
local floorCheckDistance = 60
local savedCollide = {}
local lastGroundY = nil
local flyRef = {enabled = false}

function Wallhack.init(ctx)
    Wallhack.ctx = ctx
    local function findGroundBelow(char, hrp)
        local pr = RaycastParams.new()
        pr.FilterType = Enum.RaycastFilterType.Exclude
        pr.FilterDescendantsInstances = {char}
        pr.IgnoreWater = true
        local res = Workspace:Raycast(hrp.Position + Vector3.new(0, 1, 0), Vector3.new(0, -(floorCheckDistance + 1), 0), pr)
        if res and res.Instance then return true, res.Position.Y end
        local op = OverlapParams.new()
        op.FilterType = Enum.RaycastFilterType.Exclude
        op.FilterDescendantsInstances = {char}
        op.MaxParts = 30
        local p1 = Workspace:GetPartBoundsInBox(CFrame.new(hrp.Position - Vector3.new(0, 3, 0)), Vector3.new(6, 8, 6), op)
        for _, pt in ipairs(p1) do
            if pt.CanCollide and pt.Transparency < 1 then
                return true, hrp.Position.Y
            end
        end
        return false, nil
    end

    local function applyWallhack()
        local c = LP.Character
        if not c then return end
        for _, p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") then
                if savedCollide[p] == nil then savedCollide[p] = p.CanCollide end
                p.CanCollide = false
            end
        end
    end

    local function restoreWallhack()
        for p, v in pairs(savedCollide) do
            if p.Parent then pcall(function() p.CanCollide = v end) end
        end
        savedCollide = {}
        lastGroundY = nil
    end

    RunService.Stepped:Connect(function()
        if not enabled then return end
        local c = LP.Character
        if not c then return end
        local hrp = c:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        for _, p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end
        end
        if not antiFall then return end
        if flyRef.enabled then return end
        local hasGround, groundY = findGroundBelow(c, hrp)
        if hasGround then
            lastGroundY = groundY or hrp.Position.Y
            return
        end
        if not lastGroundY then lastGroundY = hrp.Position.Y end
        local hoverY = lastGroundY + 3
        if hrp.Position.Y <= hoverY + 0.5 then
            hrp.CFrame = CFrame.new(hrp.Position.X, hoverY, hrp.Position.Z)
            local v = hrp.AssemblyLinearVelocity
            hrp.AssemblyLinearVelocity = Vector3.new(v.X, 0, v.Z)
            hrp.AssemblyAngularVelocity = Vector3.zero
        end
    end)

    Wallhack.set = function(state)
        enabled = state
        if state then applyWallhack() else restoreWallhack() end
    end
    Wallhack.setAntiFall = function(s) antiFall = s end
    Wallhack.restore = restoreWallhack
    Wallhack.resetOnChar = function()
        savedCollide = {}
        lastGroundY = nil
        if enabled then applyWallhack() end
    end
    Wallhack.flyRef = flyRef
end

return Wallhack
