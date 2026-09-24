local Elements = require("UI/Elements")
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LP = Players.LocalPlayer

local Page = {}

function Page.render(ctx)
    local mb = ctx.tabs.get("movement")
    Elements.makeInfo("Movement: Wallhack, Speed, Jump, Fly", mb)
    Elements.makeToggle("Wallhack", false, function(s) ctx.wallhack.set(s) end, mb)
    Elements.makeToggle("Anti Fall to Void", true, function(s) ctx.wallhack.setAntiFall(s) end, mb)
    Elements.makeToggle("Speed Hack", false, function(s) ctx.speed.set(s) end, mb)
    Elements.makeNum("Speed", 100, function(n) ctx.speed.setSpeed(n) end, mb)

    local infJump = false
    UIS.JumpRequest:Connect(function()
        if infJump then
            local c = LP.Character
            if c then
                local h = c:FindFirstChildOfClass("Humanoid")
                if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
            end
        end
    end)
    Elements.makeToggle("Infinite Jump", false, function(s) infJump = s end, mb)
    Elements.makeToggle("Fly", false, function(s) ctx.fly.set(s) end, mb)
end

return Page
