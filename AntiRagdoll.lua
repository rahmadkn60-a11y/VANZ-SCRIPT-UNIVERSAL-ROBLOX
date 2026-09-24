local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LP = Players.LocalPlayer

local AntiRagdoll = {}
local enabled = false
local conn = nil

local function start()
    enabled = true
    if conn then conn:Disconnect() end
    conn = RunService.Heartbeat:Connect(function()
        if not enabled then return end
        local c = LP.Character
        if not c then return end
        local h = c:FindFirstChildOfClass("Humanoid")
        if not h then return end
        if h.PlatformStand then h.PlatformStand = false end
        local s = h:GetState()
        if s == Enum.HumanoidStateType.FallingDown or s == Enum.HumanoidStateType.Ragdoll or s == Enum.HumanoidStateType.Physics then
            pcall(function() h:ChangeState(Enum.HumanoidStateType.GettingUp) end)
        end
        pcall(function()
            h:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            h:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        end)
    end)
end

local function stop()
    enabled = false
    if conn then conn:Disconnect() conn = nil end
    local c = LP.Character
    if c then
        local h = c:FindFirstChildOfClass("Humanoid")
        if h then
            pcall(function()
                h:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
                h:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
            end)
        end
    end
end

function AntiRagdoll.init()
    AntiRagdoll.set = function(s) if s then start() else stop() end end
end

return AntiRagdoll
