local json = _G['json'];
local temp = {};
local realm = GetRealmName();
local char = UnitName('player');
local _, ns = ...;

SlashCmdList.PULSE_DKP = function(msg)
    local _, _, cmd, args = string.find(msg, "%s?(%w+)%s?(.*)");

    if (cmd == 'roll' or cmd == 'roll2' or cmd == 'roll3' or cmd == 'roll4' or
        cmd == 'roll5') then
        temp.cmd = cmd;

        local itemString, itemName = args:match("|H(.*)|h%[(.*)%]|h");

        if (cmd == 'roll') then
            SendChatMessage(args .. ' roll for raid need', RAID);
        end
        if (cmd == 'roll2') then
            SendChatMessage(args .. ' roll for 100%', RAID);
        end
        if (cmd == 'roll3') then
            SendChatMessage(args .. ' roll for 50%', RAID);
        end
        if (cmd == 'roll4') then
            SendChatMessage(args .. ' roll for 25%', RAID);
        end
        if (cmd == 'roll5') then
            SendChatMessage(args .. ' roll for 10%', RAID);
        end

        temp.itemString = itemString;
        temp.itemName = itemName;
        temp.chars = ns:getRaidMembers();
        KethoEditBox_Show(json.encode(temp));
    elseif (cmd == 'donate' or cmd == 'loot') then

        local _, _, item, charLink = string.find(args, "(.*)%s(%w+)");
        if (string.sub(item, 0, 1) ~= '|') then
            _, _, charLink, item = string.find(args, "(%w+)%s(.*)");
        end
        if (cmd == 'loot') then
            SendChatMessage(charLink .. ' wins ' .. item .. ' Congrats!', RAID);
        end
        local itemObj = {};
        local itemString, itemName = item:match("|H(.*)|h%[(.*)%]|h");
        itemObj.itemString = itemString;
        itemObj.name = itemName;

        -- itemObj.name, itemObj.link, itemObj.rarity, itemObj.level, itemObj.minLevel, itemObj.type, itemObj.subType, itemObj.stackCount, itemObj.equipLoc, itemObj.texture, itemObj.sellPrice =
        -- GetItemInfo(itemName);
        if (itemObj.name ~= nil) then
            print(itemObj);
            ns:DistributeLoot(itemObj, charLink);
        end
        -- KethoEditBox_Show(json.encode(temp));
    elseif cmd == 'create' then
        ns:CreateRaid(msg, args);

    elseif cmd == 'start' then
        ns:StartRaid();

    elseif cmd == 'end' then
        ns:EndRaid(msg);

    elseif cmd == 'clearraids' then
        ns:ClearRaids();

    elseif cmd == 'listraids' then
        ns:ListRaids();

    elseif cmd == 'drop' then
        local itemString, itemName = args:match("|H(.*)|h%[(.*)%]|h");
        item = {};
        itemObj.itemString = itemString;
        itemObj.name = itemName;
        ns:AddDrop(msg, item);
    elseif (cmd == 'kill' or cmd == 'wipe') then
        temp.npc = args;
        temp.chars = {};
        for i = 1, 40 do
            local char = {};
            char.name, char.rank = GetRaidRosterInfo(i);
            if char.name ~= nil then
                temp.chars[i] = {};
                temp.chars[i].name, temp.chars[i].rank = GetRaidRosterInfo(i);
            end
        end
    elseif (cmd == 'close') then
        ns:PD_CloseMainFrame();
    else
        ns:PD_OpenMainFrame();
    end
end
function ns:PD_OpenMainFrame()
    -- PD_MainFrame:Show();
    PD_Frame();
end
function ns:PD_CloseMainFrame()
    -- PD_MainFrame:Hide();
    PulseDkpMainFrame:Hide();
end
function ns:getRaidMembers()
    local temp = {};
    for i = 1, 40 do
        local char = {};
        char.name, _, _, _, _, _, char.zone = GetRaidRosterInfo(i);

        if char.name ~= nil then tinsert(temp, char); end
    end

    return temp;
end

function ns:CreateRaid(args)
    if args == nil or string.len(args) < 2 then
        print(
            'A raid cannot be started without a name. A minimum of two characters is required. To include whitespaces, wrap your name in \'. For example: /pulse start \'Mc trash\'');
        return;
    end

    local newRaid = {};
    newRaid.chars = {};
    newRaid.name = args;
    newRaid.date = date("%Y-%m-%d");
    newRaid.createdBy = char;
    local index = 1;
    if (Pulse_DKP.raids ~= nil) then index = #Pulse_DKP.raids + 1; end
    if (Pulse_DKP.raids == nil) then Pulse_DKP.raids = {}; end

    newRaid.index = index;
    newRaid.closedOn = nil;
    newRaid.startedOn = nil;
    Pulse_DKP.raids[newRaid.index] = newRaid;
    temp = newRaid;
    C_ChatInfo.SendAddonMessage(Pulse_DKP.channel, "Created raid!", "WHISPER",
                                UnitName("player"));
    -- ns:ListRaids();
end

function ns:StartRaid()
    if temp == nil then return; end

    temp.startingChars = {};

    for i = 1, 40 do
        local char = {};
        char.name, _, _, _, _, _, char.zone = GetRaidRosterInfo(i);

        if char.name ~= nil then tinsert(temp.startingChars, char); end
    end

    temp.startedOn = date("!%Y-%m-%d %H:%M");
    Pulse_DKP.raids[temp.index] = temp;
    ns:RegisterLootReady();
end

function ns:AddDrop(mob, item)
    if temp == nil then return; end

    if temp.drops == nil then temp.drops = {}; end
    local drop = {};
    drop.mob = mob;
    drop.item = item;
    drop.timestamp = date("!%Y-%m-%d %H:%M:%S")
    drop.chars = {};

    for i = 1, 40 do
        local char = {};
        char.name, char.rank, _, _, _, _, char.zone = GetRaidRosterInfo(i);
        if char.name ~= nil then tinsert(drop.chars, char); end
    end

    tinsert(temp.drops, drop);
    Pulse_DKP.raids[temp.index] = temp;

end
function ns:DistributeLoot(item, winner)
    if temp == nil then return; end

    if temp.lootWinners == nil then temp.lootWinners = {}; end
    local lootWinner = {};
    lootWinner.item = item;
    lootWinner.chars = winner;

    tinsert(temp.lootWinners, lootWinner);
    Pulse_DKP.raids[temp.index] = temp;
    print('Loot distributed');

end
function ns:EndRaid(msg)
    if temp == nil then return; end
    temp.finishingChars = {};
    for i = 1, 40 do
        local char = {};
        char.name, _, _, _, _, _, char.zone = GetRaidRosterInfo(i);

        if char.name ~= nil then tinsert(temp.finishingChars, char); end
    end
    temp.closedOn = date("!%Y-%m-%d %H:%M");
    Pulse_DKP.raids[temp.index] = temp;
    ns:UnRegisterLootReady();
end
function ns:ClearRaids() Pulse_DKP.raids = {}; end
function ns:ListRaids() KethoEditBox_Show(json.encode(Pulse_DKP.raids)); end

function ns:GetCurrentRaid()
    if temp == nil then return; end
    return temp;
end
function ns:GetLastUnfinishedRaid()
    if Pulse_DKP == nil or Pulse_DKP.raids == nil then
        return;
    else
        for i = #Pulse_DKP.raids, 1, -1 do
            if Pulse_DKP.raids[i].closedOn == nil then
                return Pulse_DKP.raids[i];
            end
        end
    end
end
function ns:SetCurrentRaid(raid) if (raid ~= nil) then temp = raid; end end
function ns:dkpLootOpen()
    local mobId = UnitGUID("target");
    local add = true;
    if temp ~= nil and temp.drops ~= nil then
        for i = 1, #temp.drops do
            if temp.drops[i].mob.id == mobId then
                add = false;
                break
            end
        end
    end
    if (add == false) then return end

    local info = GetLootInfo();
    local mob = {name = GetUnitName('target'), id = mobId};
    if (info ~= nil) then
        for i = 1, #info do
            -- local item= GetItemInfo(info[i].item);
            local t = info[i];
            ns:AddDrop(mob, t);
        end
    end

    -- print(name);
    -- local json = _G['json'];
    -- KethoEditBox_Show(json.encode(info));
    PD_BindCurrentRaidDetails();
end
function ns:GenerateItem(itemName)
    local item = {};
    local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType,
          itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice =
        GetItemInfo(itemName);

    if (itemName ~= nil) then
        item.itemName = itemName;
        item.itemLink = itemLink;
        item.itemRarity = itemRarity;
        item.itemLevel = itemLevel;
        item.itemMinLevel = itemMinLevel;
        item.itemType = itemType;
        item.itemSubType = itemSubType;
        item.itemStackCount = itemStackCount;
        item.itemEquipLoc = itemEquipLoc;
        item.itemTexture = itemTexture;
        item.itemSellPrice = itemSellPrice;
        return item;
    end

end

SLASH_PULSE_DKP1 = "/pd";

