local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LP = Players.LocalPlayer

local ServerHop = {}

function ServerHop.hop(mode)
    local PlaceId = game.PlaceId
    local JobId = game.JobId
    local url = "https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100&excludeFullGames=true"
    local ok, response = pcall(function() return HttpService:JSONDecode(game:HttpGet(url)) end)
    if not ok or not response or not response.data or #response.data == 0 then
        pcall(function() TeleportService:Teleport(PlaceId, LP) end)
        return false
    end
    local servers = {}
    for _, srv in ipairs(response.data) do
        if srv.id ~= JobId and srv.playing ~= nil and srv.maxPlayers ~= nil then
            table.insert(servers, {id = srv.id, playing = srv.playing, maxPlayers = srv.maxPlayers})
        end
    end
    if #servers == 0 then
        pcall(function() TeleportService:Teleport(PlaceId, LP) end)
        return false
    end
    local chosen = nil
    if mode == "crowded" then
        table.sort(servers, function(a, b) return a.playing > b.playing end)
        for _, srv in ipairs(servers) do
            if srv.playing < srv.maxPlayers then chosen = srv break end
        end
        if not chosen then chosen = servers[1] end
    else
        table.sort(servers, function(a, b) return a.playing < b.playing end)
        for _, srv in ipairs(servers) do
            if srv.playing >= 1 and srv.playing < srv.maxPlayers then chosen = srv break end
        end
        if not chosen then chosen = servers[1] end
    end
    if chosen then
        local ok2 = pcall(function() TeleportService:TeleportToPlaceInstance(PlaceId, chosen.id, LP) end)
        if not ok2 then pcall(function() TeleportService:Teleport(PlaceId, LP) end) end
        return true
    end
    pcall(function() TeleportService:Teleport(PlaceId, LP) end)
    return false
end

function ServerHop.init() end
return ServerHop
