------------------------------------
--<#>-- Command API for GMod --<#>--
------------------------------------

-- General utility functions:
function string:append(txt)
    self = self .. txt
    return self
end

function string:split(sSeparator, nMax, bRegexp)
    assert(sSeparator ~= "")
    assert(nMax == nil or nMax >= 1)

    local aRecord = {}

    if self:len() > 0 then
        local bPlain = not bRegexp
        nMax = nMax or -1

        local nField, nStart = 1, 1
        local nFirst, nLast = self:find(sSeparator, nStart, bPlain)
        while nFirst and nMax ~= 0 do
            aRecord[nField] = self:sub(nStart, nFirst - 1)
            nField = nField + 1
            nStart = nLast + 1
            nFirst, nLast = self:find(sSeparator, nStart, bPlain)
            nMax = nMax - 1
        end
        aRecord[nField] = self:sub(nStart)
    end

    return aRecord
end

function table.range(tInput, nStart, nEnd)
    nEnd = nEnd or #tInput

    local out = tInput

    for i = 1, nStart do
        table.remove(out, i)
    end

    for i = nEnd, #tInput do
        table.remove(out, i)
    end

    return out
end

function tell(ply, msg)
    if ply == nil then
        return
    end
    if msg == nil then
        msg = ""
    end
    ply:PrintMessage(3, msg)
end

function getPlayer(name)
    for i = 1, game.MaxPlayers() do
        local ent = Entity(i)
        if
            ent ~= NULL and string.len(name) > 0 and
                (string.upper(ent:GetName()) == string.upper(name) or
                    string.sub(string.upper(ent:GetName()), 0, string.len(name)) == string.upper(name))
         then
            return ent
        end
    end
    return nil
end

-- Command API methods / objects etc.
cAPI = {}
cAPI.latestCommand = nil
cAPI.commands = {}

-- Loads a command from a string (matches the pattern commands/command_*.lua)
function cAPI:loadCommand(command)
    cAPI.latestCommand = command
    include("commands/command_" .. command .. ".lua")
    print("'" .. command .. "' loaded")
end

-- Initializes the CMD info object and returns it
function cAPI:initCommand(label, usage, desc)
    if self.latestCommand == nil then
        print("Tried to call initCommand before a command was properly loaded!")
        return {}
    end

    local CMD = {}
    CMD.id = "command_" .. self.latestCommand
    CMD.label = label
    CMD.usage = usage
    CMD.desc = desc

    self.commands[CMD.label] = {
        info = CMD,
        callback = nil
    }

    return CMD
end

function cAPI:getCommand(label)
    return self.commands[label]
end

function cAPI:getInfo(label)
    return self:getCommand(label).info
end

function cAPI:showHelp(ply)
    tell(ply, " ")
    tell(ply, "----------------------------------------------------------------------")
    for k, v in pairs(self.commands) do
        tell(ply, v.info.usage .. ": " .. v.info.desc)
    end
    tell(ply, "----------------------------------------------------------------------")
    tell(ply, " ")
end

-- Register a handler for a CMD info (WIP)
function cAPI:registerHandler(CMD, callback)
    if CMD == nil then
        print("CMD info must be provided to register a handler!")
        return
    end

    callback = callback or function(ply, args, isTeam)
            return nil
        end

    if self.commands[CMD.label] == nil then
        print("There is no command registered under that label!")
        return
    end

    if self.commands[CMD.label].callback ~= nil then
        print("There is already a handler registered for the command '" .. CMD.label .. "'")
        return
    end

    self.commands[CMD.label].callback = callback

    concommand.Add(
        CMD.label,
        function(ply, cmd, args, str)
            tell(ply, cAPI:getCommand(CMD.label).callback(ply, args, false) or cAPI:getInfo(CMD.label).usage)
        end
    )
end

hook.Add(
    "PlayerSay",
    "cAPI_handler",
    function(ply, text, isTeam)
        if not text:StartWith("/") and not text:StartWith("!") then
            return
        end

        if text:len() < 2 then
            return
        end

        local split = text:split(" ")
        local label = string.sub(split[1], 2)

        if (label == "help") then
            cAPI:showHelp(ply)
            return ""
        end

        local command = cAPI.commands[label]

        if command == nil then
            tell(ply, "Failed to find command '" .. label .. "'\nDo /help to see a list of commands.")
            return ""
        end

        tell(ply, command.callback(ply, table.range(split, 2), isTeam) or command.info.usage)
        return ""
    end
)

-------------------
-- Load commands --
-------------------

cAPI:loadCommand("tp")
cAPI:loadCommand("jump")
cAPI:loadCommand("heal")
cAPI:loadCommand("warp")
