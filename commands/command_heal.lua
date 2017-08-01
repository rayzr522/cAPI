CMD = cAPI:initCommand("heal", "/heal", "Heals you")

cAPI:registerHandler(CMD, function (ply, args, isTeam)

    return heal(ply)

end)

function heal(ply)
    if ply:Health() < 100 then
        ply:SetHealth(100)
        return "You were healed"
    end
    return ""
end
