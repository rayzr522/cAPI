CMD = cAPI:initCommand("jump", "/jump", "Sends you flying!")

cAPI:registerHandler(
    CMD,
    function(ply, args, isTeam)
        jump(ply)
        return ""
    end
)

function jump(ply)
    ply:SetVelocity(ply:EyeAngles():Forward() * 2000)
end
