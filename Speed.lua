local Players = game:GetService("Players")
local LP = Players.LocalPlayer

local Speed = {}
local enabled = false
local currentSpeed = 100
local conn

local function apply()
    local c = LP.Character
    if not c then return end
    local h = c:FindFirstChildOfClass("Humanoid")
    if not h then return end
    h.WalkSpeed = currentSpeed
    if conn then conn:Disconnect() end
    conn = h:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
        if enabled and h.WalkSpeed ~= currentSpeed then
            h.WalkSpeed = currentSpeed
        end
    end)
end

function Speed.init()
    Speed.set = function(state)
        enabled = state
        local c = LP.Character
        if not c then return end
        local h = c:FindFirstChildOfClass("Humanoid")
        if not h then return end
        if state then
            apply()
        else
            if conn then conn:Disconnect() conn = nil end
            h.WalkSpeed = 16
        end
    end
    Speed.setSpeed = function(n)
        currentSpeed = n
        if enabled then apply() end
    end
    Speed.onCharAdded = function()
        if enabled then
            task.wait(0.1)
            local c = LP.Character
            local h = c and c:FindFirstChildOfClass("Humanoid")
            if h then h.WalkSpeed = currentSpeed end
        end
    end
end

return Speed
