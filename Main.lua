local Players = game:GetService("Players")
local LP = Players.LocalPlayer

local Config = require(script.Parent.Config)
local Theme = require(script.Parent.Theme)
local Core = require(script.Parent.UI.Core)
local TabSystem = require(script.Parent.UI.TabSystem)

local cleanupList = {"vanzSlimMenu"}
for _, n in ipairs(cleanupList) do
    pcall(function()
        if gethui then
            local h = gethui()
            local o = h:FindFirstChild(n)
            if o then o:Destroy() end
        end
    end)
    pcall(function()
        local o = game:GetService("CoreGui"):FindFirstChild(n)
        if o then o:Destroy() end
    end)
    pcall(function()
        local o = LP.PlayerGui:FindFirstChild(n)
        if o then o:Destroy() end
    end)
end

local parentGui = LP:WaitForChild("PlayerGui")
pcall(function()
    if gethui then
        local h = gethui()
        if h then parentGui = h end
    end
end)

local screen = Instance.new("ScreenGui")
screen.Name = "vanzSlimMenu"
screen.ResetOnSpawn = false
screen.IgnoreGuiInset = true
screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screen.DisplayOrder = 999999
screen.Enabled = true
screen.Parent = parentGui

Core.init(screen, Theme)
TabSystem.init(Core)

local ctx = {
    screen = screen,
    core = Core,
    tabs = TabSystem,
    theme = Theme,
    flags = {},
    body = Core.body,
}

require(script.Parent.Modules.Wallhack).init(ctx)
require(script.Parent.Modules.Speed).init(ctx)
require(script.Parent.Modules.Fly).init(ctx)
require(script.Parent.Modules.ESP).init(ctx)
require(script.Parent.Modules.Aimbot).init(ctx)
require(script.Parent.Modules.AimbotLock).init(ctx)
require(script.Parent.Modules.AutoDodge).init(ctx)
require(script.Parent.Modules.Hitbox).init(ctx)
require(script.Parent.Modules.AntiRagdoll).init(ctx)
require(script.Parent.Modules.Fullbright).init(ctx)
require(script.Parent.Modules.FPSBoost).init(ctx)
require(script.Parent.Modules.ServerHop).init(ctx)
require(script.Parent.Modules.Teleport).init(ctx)
require(script.Parent.Modules.TeleportV2).init(ctx)
require(script.Parent.Modules.Radius).init(ctx)

TabSystem.createTab("combat", "⚔")
TabSystem.createTab("visual", "👁")
TabSystem.createTab("movement", "🏃")
TabSystem.createTab("utility", "🔧")
TabSystem.createTab("teleport", "📍")
TabSystem.createTab("aimbot", "🎯")
TabSystem.switchTab("combat")

require(script.Parent["UI/Pages"].CombatPage).render(ctx)
require(script.Parent["UI/Pages"].VisualPage).render(ctx)
require(script.Parent["UI/Pages"].MovementPage).render(ctx)
require(script.Parent["UI/Pages"].UtilityPage).render(ctx)
require(script.Parent["UI/Pages"].TeleportPage).render(ctx)
require(script.Parent["UI/Pages"].AimbotPage).render(ctx)

LP.CharacterAdded:Connect(function()
    for name, mod in pairs(ctx.flags) do
        if type(mod) == "table" and mod.onCharAdded then
            pcall(mod.onCharAdded)
        end
    end
end)

print("[vanz] Slim menu modular loaded.")
return true
