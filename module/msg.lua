local _, ns = ...;
local json = _G['json'];

function ns:notify(cmd, args)

    local msg = ns:packageMessage(cmd, args);
    -- send tell to yourself for debugging puposes
    -- C_ChatInfo.SendAddonMessage(Pulse_DKP.channel, msg, "WHISPER",
    --                             UnitName("player"));

    C_ChatInfo.SendAddonMessage(Pulse_DKP.channel, msg, "RAID");
end
function ns:messageRecieved(...)
    local prefix, text, channel, sender, target, zoneChannelID, localID, name,
          instanceID = ...;
    -- print(...);
    local arg = ns:parseMessage(text)
    if (arg == nil or arg.cmd == nil) then return end
    local cmd = tonumber(arg.cmd);
    if (cmd == Pulse_DKP.notify["CREATE"]) then -- create raid

    elseif cmd == Pulse_DKP.notify["DROP"] then -- drop
        ns:UpdateDropFromOther(arg.args);

    elseif cmd == Pulse_DKP.notify["DROP_ATTENDEES"] then -- drop
        print(arg);
    elseif cmd == Pulse_DKP.notify["LOOT"] then -- drop
        ns:UpdateWinnerFromOther(arg.args);
    elseif cmd == Pulse_DKP.notify["DELETE_LOOT"] then -- drop
        ns:DeleteWinnerFromOther(arg.args);
    end
end

function ns:packageMessage(cmd, args)
    if (cmd == nil) then return end
    local msg = 'cmd=' .. cmd .. '//';

    if (args == nil) then return msg; end

    msg = msg .. 'args=';

    if (args ~= nil and type(args) == 'table') then
        local t = ns:tableToString(args);
        if (t ~= nil) then msg = msg .. t; end
    else
        msg = msg .. args;
    end
    return msg
end

function ns:parseMessage(msg)
    local obj = {};
    local arg = {};
    local index = 1;
    for token in string.gmatch(msg, "[^%//]+") do

        if index == 1 then obj.cmd = token:gsub("cmd=", ""); end
        if index == 2 then token = token:gsub("args=", ""); end
        if index > 1 then
            local prop, value = string.match(token, "(.*)=(.*)");
            arg[prop] = value;
        end
        index = index + 1;
    end
    obj.args = arg;
    return obj;
end
function ns:tableToString(tbl)
    if tbl == nil then return; end
    local msg = '';
    for key, value in pairs(tbl) do
        msg = msg .. key .. '=';
        if (value ~= nil and value ~= {}) then
            if (type(value) == 'table') then
                local tblmsg = ns:tableToString(value);
                if (tblmsg ~= nil) then msg = msg .. tblmsg; end
            else
                msg = msg .. tostring(value);
            end
        end
        msg = msg .. '//';
    end
    return msg;
end
