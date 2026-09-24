local Players = game:GetService("Players")
local LP = Players.LocalPlayer

local Utils = {}

function Utils.getPlayerColor(plr, CT, CE, CU)
    if plr == LP then return CT end
    if LP.Team and plr.Team then
        return (plr.Team == LP.Team) and CT or CE
    end
    if LP.TeamColor and plr.TeamColor then
        return (plr.TeamColor == LP.TeamColor) and CT or CE
    end
    return CU
end

function Utils.isEnemy(plr)
    if plr == LP then return false end
    if LP.Team and plr.Team then return plr.Team ~= LP.Team end
    if LP.TeamColor and plr.TeamColor then return plr.TeamColor ~= LP.TeamColor end
    return true
end

function Utils.isTeam(plr)
    if plr == LP then return true end
    if LP.Team and plr.Team then return plr.Team == LP.Team end
    if LP.TeamColor and plr.TeamColor then return plr.TeamColor == LP.TeamColor end
    return false
end

function Utils.findBestEspPart(char)
    if not char then return nil end
    local pri = {"HumanoidRootPart", "UpperTorso", "Torso", "Head", "LowerTorso"}
    for _, n in ipairs(pri) do
        local p = char:FindFirstChild(n)
        if p and p:IsA("BasePart") then return p end
    end
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") then return p end
    end
    return nil
end

function Utils.findHeadPart(char)
    if not char then return nil end
    local hd = char:FindFirstChild("Head")
    if hd and hd:IsA("BasePart") then return hd end
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") and p.Name:lower():find("head") then
            return p
        end
    end
    return nil
end

return Utils
