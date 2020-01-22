local _, ns = ...;

function ns:notify(cmd, args)

    local msg = ns:packageMessage(cmd, args);
    C_ChatInfo.SendAddonMessage(Pulse_DKP.channel, msg, "WHISPER",
                                UnitName("player"));

end
function ns:messageRecieved(...)
    local prefix, text, channel, sender, target, zoneChannelID, localID, name,
          instanceID = ...;
    print(...);
    ns:parseMessage(text)
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
    msg = msg .. '::args';
    return msg

end

function ns:parseMessage(msg)
    -- local tablDto = table.fromstring(msg);
    -- return tablDto
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
