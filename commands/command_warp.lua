WARPS = {
    path = "cAPI/warp/warps.txt",
    list = {},
    valid = {},
    init = function()

        file.CreateDir("cAPI")
        file.CreateDir("cAPI/warp")

        local lines = file.Read(WARPS.path, "DATA")

        if lines == nil then
            return
        end

        local map = game.GetMap()

        print("[WARPS] Attempting to load warps from:\n"..lines)
        lines = lines:split("\n")

        for k,v in pairs(lines) do

            local data = v:split(":")

            if #data ~= 8 then
                continue
            end

            local id = data[8].."_"..data[1]

            print("[WARPS] Loading warp '"..id.."'")

            WARPS.list[id] = {
                name = data[1] or "null",
                x = tonumber(data[2]) or 0,
                y = tonumber(data[3]) or 0,
                z = tonumber(data[4]) or 0,
                pitch = tonumber(data[5]) or 0,
                yaw = tonumber(data[6]) or 0,
                roll = tonumber(data[7]) or 0,
                map = data[8]
            }

            if data[8] == map then
                WARPS.valid[data[1]] = WARPS.list[id]
            end

        end
    end,
    saveWarps = function()

        local output = ""
        local map = game.GetMap()
        for k,v in pairs(WARPS.list) do
            output = output..v.name..":"..v.x..":"..v.y..":"..v.z..":"..v.pitch..":"..v.yaw..":"..v.roll..":"..map.."\n"
        end
        print("Saving '"..output.."' to the file at '"..WARPS.path.."'")
        file.Write(WARPS.path, output)

    end,
    available = function()
        return "Available warps: "..table.concat(table.GetKeys(WARPS.valid), ", ")
    end,
    setWarp = function(name, ply)

        local pos = ply:GetPos()
        local angle = ply:EyeAngles()
        local map = game.GetMap()
        local newWarp = {
            name = name or "null",
            x = pos.x or 0,
            y = pos.y or 0,
            z = pos.z or 0,
            pitch = angle.pitch or 0,
            yaw = angle.yaw or 0,
            roll = angle.roll or 0,
            map = game.GetMap()
        }
        WARPS.list[map.."_"..name] = newWarp
        WARPS.valid[name] = newWarp

        WARPS.saveWarps()

    end,
    deleteWarp = function(name)
        local map = game.GetMap()
        local id = map.."_"..name
        if WARPS.valid[name] ~= null then
            WARPS.valid[name] = nil
            WARPS.list[id] = nil
            WARPS.saveWarps()
            return true
        end
        return false
    end
}

WARPS.init()

CMD = cAPI:initCommand("warp", "/warp [name]", "Teleports you to the specified warp")
cAPI:registerHandler(CMD, function(ply, args, isTeam)

    if #args < 1 then

        return WARPS.available()

    end

    if WARPS.valid[args[1]] == nil then

        tell(ply, "The warp '"..args[1].."' does not exist")
        return WARPS.available()

    end

    local warp = WARPS.valid[args[1]]

    ply:SetPos(Vector(warp.x, warp.y, warp.z))
    ply:SetEyeAngles(Angle(warp.pitch, warp.yaw, warp.roll))
    return "Warped to '"..args[1].."'"

end)

CMD_2 = cAPI:initCommand("setwarp", "/setwarp <name>", "Sets the specified warp to your location")
cAPI:registerHandler(CMD_2, function(ply, args, isTeam)

    if #args < 1 then
        return
    end

    WARPS.setWarp(args[1], ply)
    return "Set '"..args[1].."' to "..tostring(ply:GetPos())

end)

CMD_3 = cAPI:initCommand("delwarp", "/delwarp <name>", "Deletes the specified warp")
cAPI:registerHandler(CMD_3, function(ply, args, isTeam)

    if #args < 1 then
        return
    end

    if WARPS.deleteWarp(args[1]) then
        return "Removed the warp '"..args[1].."'"
    end

    tell(ply, "The warp '"..args[1].."' does not exist")
    return WARPS.available()

end)
