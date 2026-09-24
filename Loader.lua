local Loader = {}

local BASE = "https://raw.githubusercontent.com/rahmadkn60-a11y/VANZ-SCRIPT-UNIVERSAL-ROBLOX/refs/heads/main/"
local CACHE = {}
local LOADING = {}

-- Mapping: nama virtual -> nama file asli di GitHub (semua di root)
local PATH_MAP = {
    ["Config"] = "Config.lua",
    ["Theme"] = "Theme.lua",
    ["Utils"] = "Utils.lua",
    ["UI/Core"] = "Core.lua",
    ["UI/TabSystem"] = "TabSystem.lua",
    ["UI/Elements"] = "Elements.lua",
    ["UI/Pages/CombatPage"] = "CombatPage.lua",
    ["UI/Pages/VisualPage"] = "VisualPage.lua",
    ["UI/Pages/MovementPage"] = "MovementPage.lua",
    ["UI/Pages/UtilityPage"] = "UtilityPage.lua",
    ["UI/Pages/TeleportPage"] = "TeleportPage.lua",
    ["UI/Pages/AimbotPage"] = "AimbotPage.lua",
    ["Modules/Wallhack"] = "Wallhack.lua",
    ["Modules/Speed"] = "Speed.lua",
    ["Modules/Fly"] = "Fly.lua",
    ["Modules/ESP"] = "ESP.lua",
    ["Modules/Aimbot"] = "Aimbot.lua",
    ["Modules/AimbotLock"] = "AimbotLock.lua",
    ["Modules/AutoDodge"] = "AutoDodge.lua",
    ["Modules/Hitbox"] = "Hitbox.lua",
    ["Modules/AntiRagdoll"] = "AntiRagdoll.lua",
    ["Modules/Fullbright"] = "Fullbright.lua",
    ["Modules/FPSBoost"] = "FPSBoost.lua",
    ["Modules/ServerHop"] = "ServerHop.lua",
    ["Modules/Teleport"] = "Teleport.lua",
    ["Modules/TeleportV2"] = "TeleportV2.lua",
    ["Modules/Radius"] = "Radius.lua",
}

local function normalize(path)
    path = path:gsub("\\", "/")
    path = path:gsub("%.lua$", "")
    return path
end

local function resolvePath(virtual)
    virtual = normalize(virtual)
    if PATH_MAP[virtual] then
        return PATH_MAP[virtual]
    end
    return virtual .. ".lua"
end

local function fetchSource(virtual)
    local file = resolvePath(virtual)
    local url = BASE .. file .. "?t=" .. tostring(math.floor(tick() * 1000))
    local ok, res = pcall(function()
        return game:HttpGet(url, true)
    end)
    if not ok or not res or res == "" then
        error("[loader] gagal fetch: " .. url)
    end
    if res:find("404: Not Found") then
        error("[loader] 404: " .. url)
    end
    return res, url
end

local function buildRequire(fromVirtual)
    return function(target)
        local fromDir = fromVirtual:match("^(.*)/[^/]+$") or ""
        local resolved
        if target:sub(1, 1) == "." then
            target = target:gsub("^%.%.?/", "")
            resolved = (fromDir ~= "" and (fromDir .. "/") or "") .. target
        else
            resolved = target
        end
        return Loader.load(resolved)
    end
end

function Loader.load(virtual)
    virtual = normalize(virtual)
    if CACHE[virtual] then return CACHE[virtual] end
    if LOADING[virtual] then
        error("[loader] circular require: " .. virtual)
    end
    LOADING[virtual] = true

    local src, url = fetchSource(virtual)
    local chunk, err = loadstring(src, "@" .. virtual)
    if not chunk then
        LOADING[virtual] = nil
        error("[loader] compile error di " .. virtual .. ": " .. tostring(err))
    end

    local env = setmetatable({
        require = buildRequire(virtual),
        script = {Name = virtual:match("([^/]+)$") or virtual},
        __PATH = virtual,
        __URL = url,
    }, {__index = getfenv and getfenv(0) or _G})

    setfenv(chunk, env)

    local ok, result = pcall(chunk)
    LOADING[virtual] = nil
    if not ok then
        error("[loader] runtime error di " .. virtual .. ": " .. tostring(result))
    end

    if result == nil then result = true end
    CACHE[virtual] = result
    return result
end

function Loader.clear()
    CACHE = {}
    LOADING = {}
end

function Loader.get(virtual)
    return CACHE[normalize(virtual)]
end

return Loader
