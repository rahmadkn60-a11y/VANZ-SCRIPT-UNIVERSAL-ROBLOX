local BASE_URL = "https://raw.githubusercontent.com/rahmadkn60-a11y/VANZ-SCRIPT-UNIVERSAL-ROBLOX/refs/heads/main/loader.lua"

local Loader = loadstring(game:HttpGet(BASE_URL, true))()
_G.__VANZ_LOADER = Loader

local Players = game:GetService("Players")
local LP = Players.LocalPlayer

local Config = Loader.load("Config")
local Theme = Loader.load("Theme")
local Core = Loader.load("UI/Core")
local TabSystem = Loader.load("UI/TabSystem")

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

ctx.wallhack = Loader.load("Modules/Wallhack")
ctx.wallhack.init(ctx)
ctx.speed = Loader.load("Modules/Speed")
ctx.speed.init(ctx)
ctx.fly = Loader.load("Modules/Fly")
ctx.fly.init(ctx)
ctx.esp = Loader.load("Modules/ESP")
ctx.esp.init(ctx)
ctx.aimbot = Loader.load("Modules/Aimbot")
ctx.aimbot.init(ctx)
ctx.aimbotLock = Loader.load("Modules/AimbotLock")
ctx.aimbotLock.init(ctx)
ctx.autoDodge = Loader.load("Modules/AutoDodge")
ctx.autoDodge.init(ctx)
ctx.hitbox = Loader.load("Modules/Hitbox")
ctx.hitbox.init(ctx)
ctx.antiRagdoll = Loader.load("Modules/AntiRagdoll")
ctx.antiRagdoll.init(ctx)
ctx.fullbright = Loader.load("Modules/Fullbright")
ctx.fullbright.init(ctx)
ctx.fpsBoost = Loader.load("Modules/FPSBoost")
ctx.fpsBoost.init(ctx)
ctx.serverHop = Loader.load("Modules/ServerHop")
ctx.serverHop.init(ctx)
ctx.teleport = Loader.load("Modules/Teleport")
ctx.teleport.init(ctx)
ctx.teleportV2 = Loader.load("Modules/TeleportV2")
ctx.teleportV2.init(ctx)
ctx.radius = Loader.load("Modules/Radius")
ctx.radius.init(ctx)

-- inject fly refs buat TeleportV2
ctx.flyRef = ctx.fly
ctx.flyStart = function()
    if ctx.fly and ctx.fly.set then ctx.fly.set(true) end
end
ctx.flyStop = function()
    if ctx.fly and ctx.fly.set then ctx.fly.set(false) end
end

TabSystem.createTab("combat", "⚔")
TabSystem.createTab("visual", "👁")
TabSystem.createTab("movement", "🏃")
TabSystem.createTab("utility", "🔧")
TabSystem.createTab("teleport", "📍")
TabSystem.createTab("aimbot", "🎯")
TabSystem.switchTab("combat")

Loader.load("UI/Pages/CombatPage").render(ctx)
Loader.load("UI/Pages/VisualPage").render(ctx)
Loader.load("UI/Pages/MovementPage").render(ctx)
Loader.load("UI/Pages/UtilityPage").render(ctx)
Loader.load("UI/Pages/TeleportPage").render(ctx)
Loader.load("UI/Pages/AimbotPage").render(ctx)

LP.CharacterAdded:Connect(function()
    for name, mod in pairs(ctx) do
        if type(mod) == "table" and mod.onCharAdded then
            pcall(mod.onCharAdded)
        end
    end
end)

print("[vanz] Slim menu modular loaded (virtual loader).")
return true
