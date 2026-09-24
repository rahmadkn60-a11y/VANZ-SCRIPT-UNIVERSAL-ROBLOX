local Elements = require(script.Parent.Parent.Elements)

local Page = {}

function Page.render(ctx)
    local vb = ctx.tabs.get("visual")
    Elements.makeInfo("Visual: ESP + Fullbright", vb)
    Elements.makeToggle("ESP", false, function(s) ctx.esp.set(s) end, vb)
    Elements.makeToggle("Fullbright", false, function(s) ctx.fullbright.set(s) end, vb)
    Elements.makeSlider("Brightness", 0, 10, 3, function(v) ctx.fullbright.setLevel(v) end, vb)
end

return Page
