local UIS = game:GetService("UserInputService")
local Theme = require("Theme")
local T = Theme.T

local Elements = {}

function Elements.makeToggle(name, default, cb, parent)
    local r = Instance.new("Frame", parent)
    r.Size = UDim2.new(1, 0, 0, 42)
    r.BackgroundColor3 = T.row
    r.BorderSizePixel = 0
    Instance.new("UICorner", r).CornerRadius = UDim.new(0, 8)
    local lb = Instance.new("TextLabel", r)
    lb.Size = UDim2.new(1, -80, 1, 0)
    lb.Position = UDim2.new(0, 12, 0, 0)
    lb.BackgroundTransparency = 1
    lb.Text = name
    lb.TextColor3 = T.text
    lb.TextSize = 13
    lb.Font = Enum.Font.Gotham
    lb.TextXAlignment = Enum.TextXAlignment.Left
    local b = Instance.new("TextButton", r)
    b.Size = UDim2.new(0, 50, 0, 26)
    b.Position = UDim2.new(1, -62, 0.5, -13)
    b.BackgroundColor3 = default and T.on or T.off
    b.Text = default and "ON" or "OFF"
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.TextSize = 11
    b.Font = Enum.Font.GothamBold
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    local st = default
    b.MouseButton1Click:Connect(function()
        st = not st
        b.BackgroundColor3 = st and T.on or T.off
        b.Text = st and "ON" or "OFF"
        if cb then pcall(cb, st) end
    end)
    return r, b
end

function Elements.makeButton(name, cb, parent)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(1, 0, 0, 36)
    b.BackgroundColor3 = T.accent
    b.Text = name
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.TextSize = 13
    b.Font = Enum.Font.GothamBold
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
    b.MouseButton1Click:Connect(function()
        if cb then pcall(cb) end
    end)
    return b
end

function Elements.makeInfo(txt, parent)
    local lb = Instance.new("TextLabel", parent)
    lb.Size = UDim2.new(1, 0, 0, 44)
    lb.BackgroundColor3 = T.row
    lb.Text = txt
    lb.TextColor3 = T.dim
    lb.TextSize = 10
    lb.Font = Enum.Font.Gotham
    lb.TextWrapped = true
    Instance.new("UICorner", lb).CornerRadius = UDim.new(0, 6)
    return lb
end

function Elements.makeNum(name, default, cb, parent)
    local r = Instance.new("Frame", parent)
    r.Size = UDim2.new(1, 0, 0, 42)
    r.BackgroundColor3 = T.row
    r.BorderSizePixel = 0
    Instance.new("UICorner", r).CornerRadius = UDim.new(0, 8)
    local lb = Instance.new("TextLabel", r)
    lb.Size = UDim2.new(0, 90, 1, 0)
    lb.Position = UDim2.new(0, 12, 0, 0)
    lb.BackgroundTransparency = 1
    lb.Text = name
    lb.TextColor3 = T.text
    lb.TextSize = 13
    lb.Font = Enum.Font.Gotham
    lb.TextXAlignment = Enum.TextXAlignment.Left
    local bx = Instance.new("TextBox", r)
    bx.Size = UDim2.new(1, -120, 0, 28)
    bx.Position = UDim2.new(0, 108, 0.5, -14)
    bx.BackgroundColor3 = T.bg
    bx.Text = tostring(default)
    bx.TextColor3 = T.text
    bx.TextSize = 13
    bx.Font = Enum.Font.GothamBold
    bx.ClearTextOnFocus = false
    Instance.new("UICorner", bx).CornerRadius = UDim.new(0, 6)
    local bxs = Instance.new("UIStroke", bx)
    bxs.Color = T.accent
    bxs.Thickness = 1
    bxs.Transparency = 0.5
    bx.FocusLost:Connect(function()
        local n = tonumber(bx.Text)
        if n then
            bx.Text = tostring(n)
            if cb then pcall(cb, n) end
        else
            bx.Text = tostring(default)
        end
    end)
    return r, bx
end

function Elements.makeSlider(name, mn, mx, default, cb, parent)
    local r = Instance.new("Frame", parent)
    r.Size = UDim2.new(1, 0, 0, 54)
    r.BackgroundColor3 = T.row
    r.BorderSizePixel = 0
    Instance.new("UICorner", r).CornerRadius = UDim.new(0, 8)
    local lb = Instance.new("TextLabel", r)
    lb.Size = UDim2.new(1, -20, 0, 20)
    lb.Position = UDim2.new(0, 12, 0, 4)
    lb.BackgroundTransparency = 1
    lb.Text = name .. ": " .. default
    lb.TextColor3 = T.text
    lb.TextSize = 13
    lb.Font = Enum.Font.Gotham
    lb.TextXAlignment = Enum.TextXAlignment.Left
    local bar = Instance.new("Frame", r)
    bar.Size = UDim2.new(1, -24, 0, 8)
    bar.Position = UDim2.new(0, 12, 0, 34)
    bar.BackgroundColor3 = T.off
    bar.BorderSizePixel = 0
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)
    local fill = Instance.new("Frame", bar)
    fill.Size = UDim2.new((default - mn) / (mx - mn), 0, 1, 0)
    fill.BackgroundColor3 = T.accent
    fill.BorderSizePixel = 0
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
    local dg = false
    local function upd(inp)
        local rel = math.clamp((inp.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        local v = math.floor(mn + (mx - mn) * rel)
        fill.Size = UDim2.new(rel, 0, 1, 0)
        lb.Text = name .. ": " .. v
        if cb then pcall(cb, v) end
    end
    bar.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            dg = true
            upd(inp)
        end
    end)
    UIS.InputChanged:Connect(function(inp)
        if dg and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
            upd(inp)
        end
    end)
    UIS.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            dg = false
        end
    end)
    return r
end

return Elements
