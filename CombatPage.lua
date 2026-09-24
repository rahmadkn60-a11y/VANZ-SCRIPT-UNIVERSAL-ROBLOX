local Elements = require("UI/Elements")

local Page = {}

function Page.render(ctx)
    local cb = ctx.tabs.get("combat")
    Elements.makeInfo("Combat: Radius, Auto Dodge, Hitbox, Anti-Ragdoll", cb)
    Elements.makeToggle("Radius Indicator", false, function(s)
        if s then ctx.radius.set(true) else ctx.radius.set(false) end
    end, cb)
    Elements.makeSlider("Radius Size", 5, 50, 10, function(v) ctx.radius.setSize(v) end, cb)
    Elements.makeToggle("Auto Dodge", false, function(s) ctx.autoDodge.set(s) end, cb)
    Elements.makeToggle("Team Safe (Dodge)", true, function(s) ctx.autoDodge.setTeamSafe(s) end, cb)
    Elements.makeSlider("Dodge Radius", 5, 30, 12, function(v) ctx.autoDodge.setRadius(v) end, cb)
    Elements.makeSlider("Dodge Distance", 5, 50, 20, function(v) ctx.autoDodge.setDistance(v) end, cb)
    Elements.makeToggle("Hitbox Expander", false, function(s) ctx.hitbox.set(s) end, cb)
    Elements.makeToggle("Team Safe (Hitbox)", true, function(s) ctx.hitbox.setTeamSafe(s) end, cb)
    Elements.makeSlider("Hitbox Size", 1, 20, 5, function(v) ctx.hitbox.setSize(v) end, cb)
    Elements.makeToggle("Anti Ragdoll", false, function(s) ctx.antiRagdoll.set(s) end, cb)
end

return Page
