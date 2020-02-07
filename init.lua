local frame = CreateFrame('Frame');
local realm = GetRealmName();
local _, ns = ...;
local lootButtonsRegistered;

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
function ns:UnRegisterLootReady()
    frame:UnregisterEvent('LOOT_READY');
    lootButtonsRegistered = nil;
end

function ns:Register_LootClick()
    local num = GetNumLootItems();
    if (num == 0) then return; end
    if (lootButtonsRegistered == nil) then lootButtonsRegistered = {}; end
    if (num > 4) then num = 4; end

    for i = 1, num do
        if (lootButtonsRegistered[i] == nil) then
            lootButtonsRegistered[i] = true;
            getglobal("LootButton" .. i):HookScript("OnClick", function()
                ns:FancyLootClick(i);
            end);
        end
    end
end
function ns:FancyLootClick(i)
    if ((IsShiftKeyDown() and IsAltKeyDown()) == false) then return end
    print('click: i=' .. i);

    local mob = {name = GetUnitName('target'), id = UnitGUID("target")};
    -- lootIcon, itemName, _, _, _ = GetLootSlotInfo(i);
    itemLink = GetLootSlotLink(i);
    PD_OpenRollFrame(itemLink, mob)
    print(itemLink);
end

local function Addon_OnEvent(self, event, ...)
    if event == "CHAT_MSG_ADDON" then
        local prefix, text, channel, sender, target, zoneChannelID, localID,
              name, instanceID = ...;
        if (prefix == Pulse_DKP.channel) then
            -- handle the incomming message;
            ns:messageRecieved(...);
        end

        -- elseif event == "GROUP_ROSTER_UPDATE" then
        -- print('roster updated');
        -- print(event, ...);
    elseif event == "PLAYER_LOGIN" then
        ns:init();
        C_ChatInfo.RegisterAddonMessagePrefix(Pulse_DKP.channel);
        ns:PD_AddMiniMap();
    elseif (event == 'LOOT_READY') then
        ns:dkpLootOpen();
        ns:Register_LootClick();
    end
end

frame:SetScript("OnEvent", Addon_OnEvent)
frame:RegisterEvent("CHAT_MSG_ADDON");
frame:RegisterEvent('PLAYER_LOGIN');
-- frame:RegisterEvent('GROUP_ROSTER_UPDATE');
