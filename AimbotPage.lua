local Elements = require("UI/Elements")

local Page = {}

function Page.render(ctx)
    local ab = ctx.tabs.get("aimbot")
    local T = ctx.theme.T

    Elements.makeInfo("Aimbot: lock bebas atau ke player spesifik", ab)
    Elements.makeToggle("Aimbot", false, function(s) ctx.aimbot.set(s) end, ab)
    Elements.makeToggle("Team Safe (Aimbot)", true, function(s) ctx.aimbot.setTeamSafe(s) end, ab)
    Elements.makeSlider("POV", 5, 360, 35, function(v) ctx.aimbot.setPOV(v) end, ab)

    local selector = Instance.new("Frame", ab)
    selector.Size = UDim2.new(1, 0, 0, 70)
    selector.BackgroundColor3 = T.row
    selector.BorderSizePixel = 0
    Instance.new("UICorner", selector).CornerRadius = UDim.new(0, 8)

    local title = Instance.new("TextLabel", selector)
    title.Size = UDim2.new(1, -20, 0, 20)
    title.Position = UDim2.new(0, 10, 0, 4)
    title.BackgroundTransparency = 1
    title.Text = "Lock Body Part:"
    title.TextColor3 = T.dim
    title.TextSize = 11
    title.Font = Enum.Font.Gotham
    title.TextXAlignment = Enum.TextXAlignment.Left

    local row = Instance.new("Frame", selector)
    row.Size = UDim2.new(1, -16, 0, 34)
    row.Position = UDim2.new(0, 8, 0, 28)
    row.BackgroundTransparency = 1
    local lay = Instance.new("UIListLayout", row)
    lay.FillDirection = Enum.FillDirection.Horizontal
    lay.Padding = UDim.new(0, 4)

    local options = {"Kepala", "Leher", "Badan", "Paha", "Kaki"}
    local btns = {}
    local function select(idx)
        for i, b in ipairs(btns) do
            if i == idx then
                b.BackgroundColor3 = T.accent
                b.TextColor3 = Color3.fromRGB(255, 255, 255)
            else
                b.BackgroundColor3 = T.off
                b.TextColor3 = T.text
            end
        end
        _G._vanzAimbotBodyPart = options[idx]
    end
    for i, lab in ipairs(options) do
        local btn = Instance.new("TextButton", row)
        btn.Size = UDim2.new(0, 46, 0, 30)
        btn.BackgroundColor3 = (i == 1) and T.accent or T.off
        btn.Text = lab
        btn.TextColor3 = (i == 1) and Color3.fromRGB(255, 255, 255) or T.text
        btn.TextSize = 10
        btn.Font = Enum.Font.GothamBold
        btn.LayoutOrder = i
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        btns[i] = btn
        btn.MouseButton1Click:Connect(function() select(i) end)
    end
    _G._vanzAimbotBodyPart = "Kepala"

    local lockLabel = Instance.new("TextLabel", ab)
    lockLabel.Size = UDim2.new(1, 0, 0, 20)
    lockLabel.BackgroundTransparency = 1
    lockLabel.Text = "Player List (buat Lock Target):"
    lockLabel.TextColor3 = T.dim
    lockLabel.TextSize = 11
    lockLabel.Font = Enum.Font.Gotham
    lockLabel.TextXAlignment = Enum.TextXAlignment.Left

    local lockFrame = Instance.new("Frame", ab)
    lockFrame.Size = UDim2.new(1, 0, 0, 130)
    lockFrame.BackgroundColor3 = T.bg
    lockFrame.BorderSizePixel = 0
    lockFrame.ClipsDescendants = true
    Instance.new("UICorner", lockFrame).CornerRadius = UDim.new(0, 8)

    local lockScroll = Instance.new("ScrollingFrame", lockFrame)
    lockScroll.Size = UDim2.new(1, -8, 1, -8)
    lockScroll.Position = UDim2.new(0, 4, 0, 4)
    lockScroll.BackgroundTransparency = 1
    lockScroll.BorderSizePixel = 0
    lockScroll.ScrollBarThickness = 4
    lockScroll.ScrollBarImageColor3 = T.accent
    lockScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    lockScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    local lockLay = Instance.new("UIListLayout", lockScroll)
    lockLay.Padding = UDim.new(0, 4)
    lockLay.SortOrder = Enum.SortOrder.LayoutOrder

    ctx.aimbotLock.setFrame(lockScroll)

    Elements.makeToggle("Lock Target", false, function(s) ctx.aimbotLock.setEnabled(s) end, ab)
end

return Page
