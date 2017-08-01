CMD = cAPI:initCommand("tp", "/tp <player>", "Teleports you to a player")

cAPI:registerHandler(CMD, function (ply, args, isTeam)

    if #args < 1 then
        return
    end

    local ent = getPlayer(args[1])

    if ent == nil then
        return "Could not find that player"
    end

    tp(ply, ent)
    tell(ent, ply:GetName().." teleported to you")
    return "Teleported you to "..ent:GetName()

end)

function tp ( e1, e2 )
    local target = e2:GetPos()
    target:Add( Vector(0, 0, 100) )
    e1:SetPos(target)
end
