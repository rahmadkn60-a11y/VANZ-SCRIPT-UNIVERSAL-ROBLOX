local Loader = {}

local BASE = "https://raw.githubusercontent.com/rahmadkn60-a11y/VANZ-SCRIPT-UNIVERSAL-ROBLOX/refs/heads/main/"
local CACHE = {}
local LOADING = {}

local function normalize(path)
    path = path:gsub("\\", "/")
    path = path:gsub("%.lua$", "")
    return path
end

local function fetchSource(path)
    local url = BASE .. normalize(path) .. ".lua"
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

local function buildRequire(fromPath)
    return function(target)
        local fromDir = fromPath:match("^(.*)/[^/]+$") or ""
        local resolved
        if target:sub(1, 1) == "." then
            target = target:gsub("^%.%.?/", "")
            resolved = (fromDir ~= "" and (fromDir .. "/") or "") .. target
        else
            resolved = target
        end
        resolved = normalize(resolved)
        return Loader.load(resolved)
    end
end

function Loader.load(path)
    path = normalize(path)
    if CACHE[path] then return CACHE[path] end
    if LOADING[path] then
        error("[loader] circular require: " .. path)
    end
    LOADING[path] = true

    local src, url = fetchSource(path)
    local chunk, err = loadstring(src, "@" .. path)
    if not chunk then
        LOADING[path] = nil
        error("[loader] compile error di " .. path .. ": " .. tostring(err))
    end

    local env = setmetatable({
        require = buildRequire(path),
        script = {Name = path:match("([^/]+)$") or path},
        __PATH = path,
        __URL = url,
    }, {__index = getfenv and getfenv(0) or _G})

    setfenv(chunk, env)

    local ok, result = pcall(chunk)
    LOADING[path] = nil
    if not ok then
        error("[loader] runtime error di " .. path .. ": " .. tostring(result))
    end

    if result == nil then result = true end
    CACHE[path] = result
    return result
end

function Loader.clear()
    CACHE = {}
    LOADING = {}
end

function Loader.get(path)
    return CACHE[normalize(path)]
end

return Loader
