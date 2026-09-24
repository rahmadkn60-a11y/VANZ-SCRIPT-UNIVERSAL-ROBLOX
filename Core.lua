local Core = {}

function Core.init(screen, Theme)
    local T = Theme.T
    Core.screen = screen

    local main = Instance.new("Frame")
    main.Name = "Main"
    main.AnchorPoint = Vector2.new(0.5, 0.5)
    main.Size = UDim2.new(0, 280, 0.85, 0)
    main.Position = UDim2.new(0.5, 0, 0.5, 0)
    main.BackgroundColor3 = T.bg
    main.BorderSizePixel = 0
    main.Active = true
    main.Visible = true
    main.ZIndex = 10
    main.Parent = screen
    Core.main = main

    local msc = Instance.new("UISizeConstraint", main)
    msc.MaxSize = Vector2.new(300, 720)
    msc.MinSize = Vector2.new(260, 300)

    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 14)
    local ms = Instance.new("UIStroke", main)
    ms.Color = T.accent
    ms.Thickness = 1.5
    ms.Transparency = 0.3

    local tb = Instance.new("Frame", main)
    tb.Name = "TitleBar"
    tb.Size = UDim2.new(1, 0, 0, 40)
    tb.BackgroundColor3 = T.panel
    tb.BorderSizePixel = 0
    tb.ZIndex = 11
    Instance.new("UICorner", tb).CornerRadius = UDim.new(0, 14)

    local tfix = Instance.new("Frame", tb)
    tfix.Size = UDim2.new(1, 0, 0, 14)
    tfix.Position = UDim2.new(0, 0, 1, -14)
    tfix.BackgroundColor3 = T.panel
    tfix.BorderSizePixel = 0
    tfix.ZIndex = 11

    local tt = Instance.new("TextLabel", tb)
    tt.Size = UDim2.new(1, -20, 1, 0)
    tt.Position = UDim2.new(0, 14, 0, 0)
    tt.BackgroundTransparency = 1
    tt.Text = "vanz ♡ slim"
    tt.TextColor3 = T.accent
    tt.TextSize = 16
    tt.Font = Enum.Font.GothamBold
    tt.TextXAlignment = Enum.TextXAlignment.Left
    tt.ZIndex = 12

    local tabBar = Instance.new("Frame", main)
    tabBar.Name = "TabBar"
    tabBar.Size = UDim2.new(1, -12, 0, 32)
    tabBar.Position = UDim2.new(0, 6, 0, 44)
    tabBar.BackgroundColor3 = T.panel
    tabBar.BorderSizePixel = 0
    tabBar.ZIndex = 11
    Instance.new("UICorner", tabBar).CornerRadius = UDim.new(0, 8)

    local tabLayout = Instance.new("UIListLayout", tabBar)
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.Padding = UDim.new(0, 2)
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center

    local body = Instance.new("ScrollingFrame", main)
    body.Size = UDim2.new(1, -20, 1, -90)
    body.Position = UDim2.new(0, 10, 0, 82)
    body.BackgroundTransparency = 1
    body.BorderSizePixel = 0
    body.ScrollBarThickness = 6
    body.ScrollBarImageColor3 = T.accent
    body.CanvasSize = UDim2.new(0, 0, 0, 0)
    body.AutomaticCanvasSize = Enum.AutomaticSize.Y
    body.ZIndex = 11

    local bl = Instance.new("UIListLayout", body)
    bl.Padding = UDim.new(0, 6)
    bl.SortOrder = Enum.SortOrder.LayoutOrder

    local bp = Instance.new("UIPadding", body)
    bp.PaddingTop = UDim.new(0, 4)
    bp.PaddingBottom = UDim.new(0, 16)
    bp.PaddingRight = UDim.new(0, 6)

    local minBtn = Instance.new("TextButton", main)
    minBtn.AnchorPoint = Vector2.new(0, 0.5)
    minBtn.Size = UDim2.new(0, 36, 0, 36)
    minBtn.Position = UDim2.new(1, 8, 0.5, 0)
    minBtn.BackgroundColor3 = T.accent
    minBtn.Text = "—"
    minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    minBtn.TextSize = 20
    minBtn.Font = Enum.Font.GothamBold
    minBtn.ZIndex = 50
    Instance.new("UICorner", minBtn).CornerRadius = UDim.new(1, 0)
    local mbs = Instance.new("UIStroke", minBtn)
    mbs.Color = T.bg
    mbs.Thickness = 2
    mbs.Transparency = 0.3

    local logo = Instance.new("TextButton", screen)
    logo.AnchorPoint = Vector2.new(0.5, 0)
    logo.Size = UDim2.new(0, 58, 0, 58)
    logo.Position = UDim2.new(0.5, 0, 0, 12)
    logo.BackgroundColor3 = T.bg
    logo.Text = "♡"
    logo.TextColor3 = T.accent
    logo.TextSize = 28
    logo.Font = Enum.Font.GothamBold
    logo.Visible = false
    logo.Active = true
    logo.ZIndex = 100
    Instance.new("UICorner", logo).CornerRadius = UDim.new(1, 0)
    local ls = Instance.new("UIStroke", logo)
    ls.Color = T.accent
    ls.Thickness = 2
    ls.Transparency = 0.2

    minBtn.MouseButton1Click:Connect(function()
        main.Visible = false
        logo.Visible = true
    end)
    logo.MouseButton1Click:Connect(function()
        logo.Visible = false
        main.Visible = true
    end)

    Core.tabBar = tabBar
    Core.body = body
    Core.logo = logo
end

return Core
