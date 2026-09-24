local TabSystem = {}

function TabSystem.init(Core)
    TabSystem.core = Core
    TabSystem.tabs = {}
    TabSystem.current = nil
end

function TabSystem.switchTab(name)
    local Theme = require("Theme")
    local T = Theme.T
    for tName, tData in pairs(TabSystem.tabs) do
        if tData.frame then tData.frame.Visible = false end
        if tData.btn then
            tData.btn.BackgroundColor3 = T.off
            tData.btn.TextColor3 = T.text
        end
    end
    local t = TabSystem.tabs[name]
    if t then
        t.frame.Visible = true
        t.btn.BackgroundColor3 = T.accent
        t.btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        TabSystem.current = name
    end
end

function TabSystem.createTab(name, label)
    local Theme = require("Theme")
    local T = Theme.T
    local Core = TabSystem.core
    local btn = Instance.new("TextButton", Core.tabBar)
    btn.Size = UDim2.new(0, 44, 0, 26)
    btn.BackgroundColor3 = T.off
    btn.Text = label or name
    btn.TextColor3 = T.text
    btn.TextSize = 10
    btn.Font = Enum.Font.GothamBold
    btn.LayoutOrder = #TabSystem.tabs + 1
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    local frame = Instance.new("Frame", Core.body)
    frame.Size = UDim2.new(1, 0, 0, 0)
    frame.AutomaticSize = Enum.AutomaticSize.Y
    frame.BackgroundTransparency = 1
    frame.Visible = false
    frame.LayoutOrder = 1
    local fl = Instance.new("UIListLayout", frame)
    fl.Padding = UDim.new(0, 6)
    fl.SortOrder = Enum.SortOrder.LayoutOrder
    TabSystem.tabs[name] = {btn = btn, frame = frame, label = label or name}
    btn.MouseButton1Click:Connect(function() TabSystem.switchTab(name) end)
    return frame
end

function TabSystem.get(name)
    return TabSystem.tabs[name] and TabSystem.tabs[name].frame
end

return TabSystem
