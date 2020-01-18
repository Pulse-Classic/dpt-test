local frame = CreateFrame('Frame');
local realm = GetRealmName();
local _, ns = ...;
function ns:init()
    if ((Pulse_DKP == nil) or (Pulse_DKP.version < 1)) then Pulse_DKP = {}; end

    Pulse_DKP.availableRaids = {};
    tinsert(Pulse_DKP.availableRaids, {name = "Onyxia's Lair", enabled = true});
    tinsert(Pulse_DKP.availableRaids, {name = "Molten Core", enabled = true});
    tinsert(Pulse_DKP.availableRaids, {name = "Blackwing Lair", enabled = false});
    tinsert(Pulse_DKP.availableRaids, {name = "Zul'Gurub", enabled = false});
    tinsert(Pulse_DKP.availableRaids,
            {name = "Temple of Ahn'Qiraj", enabled = false});
    tinsert(Pulse_DKP.availableRaids,
            {name = "Ruins of Ahn'Qiraj", enabled = false});
    Pulse_DKP.version = 1;
    Pulse_DKP.channel = "RK_DKP";
end

function ns:RegisterLootReady() frame:RegisterEvent('LOOT_READY'); end
function ns:UnRegisterLootReady() frame:UnregisterEvent('LOOT_READY'); end

local function Addon_OnEvent(self, event, ...)
    if event == "CHAT_MSG_ADDON" then
        local prefix, text, channel, sender, target, zoneChannelID, localID,
              name, instanceID = ...;
        if (prefix == Pulse_DKP.channel) then
            -- handle the incomming message;
            -- print(...);
        end

    elseif event == "PLAYER_LOGIN" then
        ns:init();
        local successfulRequest = C_ChatInfo.RegisterAddonMessagePrefix(
                                      Pulse_DKP.channel);
    elseif (event == 'LOOT_READY') then
        ns:dkpLootOpen();
    end
end

frame:SetScript("OnEvent", Addon_OnEvent)
frame:RegisterEvent("CHAT_MSG_ADDON");
frame:RegisterEvent('PLAYER_LOGIN');
