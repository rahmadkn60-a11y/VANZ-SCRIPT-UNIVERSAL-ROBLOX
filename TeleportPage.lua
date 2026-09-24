local Elements = require(script.Parent.Parent.Elements)

local Page = {}

function Page.render(ctx)
    local tpb = ctx.tabs.get("teleport")
    local T = ctx.theme.T

    local label = Instance.new("TextLabel", tpb)
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = "Player List (pilih satu):"
    label.TextColor3 = T.dim
    label.TextSize = 11
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left

    local frame = Instance.new("Frame", tpb)
    frame.Size = UDim2.new(1, 0, 0, 160)
    frame.BackgroundColor3 = T.bg
    frame.BorderSizePixel = 0
    frame.ClipsDescendants = true
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

    local scroll = Instance.new("ScrollingFrame", frame)
    scroll.Size = UDim2.new(1, -8, 1, -8)
    scroll.Position = UDim2.new(0, 4, 0, 4)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 4
    scroll.ScrollBarImageColor3 = T.accent
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

    local ll = Instance.new("UIListLayout", scroll)
    ll.Padding = UDim.new(0, 4)
    ll.SortOrder = Enum.SortOrder.LayoutOrder

    ctx.teleport.setFrame(scroll)

    Elements.makeButton("REFRESH LIST", function() ctx.teleport.refresh() end, tpb)
    Elements.makeButton("TELEPORT", function()
        local sel = ctx.teleport.getSelected()
        if sel then
            pcall(function() ctx.teleport.teleportTo(sel) end)
        end
    end, tpb)

    Elements.makeToggle("Follow (Diatas Target)", false, function(s) ctx.teleport.setFollow(s) end, tpb)
    Elements.makeSlider("Follow Height", 3, 20, 5, function(v) ctx.teleport.setFollowHeight(v) end, tpb)
end

return Page
