local Elements = require(script.Parent.Parent.Elements)
local Players = game:GetService("Players")
local LP = Players.LocalPlayer

local Page = {}

function Page.render(ctx)
    local ub = ctx.tabs.get("utility")
    local vu = game:GetService("VirtualUser")

    Elements.makeInfo("Utility: FPS Boost, Anti-AFK, Teleport V2, Server Hop", ub)
    Elements.makeToggle("FPS Boost", false, function(s) ctx.fpsBoost.set(s) end, ub)

    local antiAfk = false
    LP.Idled:Connect(function()
        if antiAfk then
            vu:CaptureController()
            vu:ClickButton2(Vector2.new())
        end
    end)
    Elements.makeToggle("Anti-AFK", false, function(s) antiAfk = s end, ub)
    Elements.makeToggle("Teleport V2", false, function(s) ctx.teleportV2.set(s) end, ub)

    Elements.makeInfo("Server Hop: Ramai = player terbanyak. Sepi = player paling sedikit.", ub)
    Elements.makeButton("🔥 HOP RAMAI", function() ctx.serverHop.hop("crowded") end, ub)
    Elements.makeButton("❄ HOP SEPI", function() ctx.serverHop.hop("empty") end, ub)
end

return Page
