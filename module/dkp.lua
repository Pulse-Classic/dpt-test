local json = _G['json'];
local realm = GetRealmName();
local char = UnitName('player');
local _, ns = ...;
local currentItem;
SlashCmdList.PULSE_DKP = function(msg)
    local _, _, cmd, args = string.find(msg, "%s?(%w+)%s?(.*)");

    if (cmd == 'donate' or cmd == 'loot') then

        local _, _, item, charLink = string.find(args, "(.*)%s(%w+)");
        if (string.sub(item, 0, 1) ~= '|') then
            _, _, charLink, item = string.find(args, "(%w+)%s(.*)");
        end

        local itemObj = {};
        local itemString, itemName = item:match("|H(.*)|h%[(.*)%]|h");
        itemObj.itemString = itemString;
        itemObj.name = itemName;
        itemObj.time = time();

        if (itemObj.name ~= nil) then
            print(itemObj);
            ns:DistributeLoot(itemObj, charLink, item);
        end

    elseif cmd == 'create' then
        ns:CreateRaid(msg, args);
    elseif cmd == 'ps' then
        PD_AddLPImportFrame();
    elseif cmd == 'start' then
        ns:StartRaid();

    elseif cmd == 'end' then
        ns:EndRaid(msg);

    elseif cmd == 'clearraids' then
        ns:ClearRaids();

    elseif cmd == 'listraids' then
        ns:ListRaids();

        -- elseif cmd == 'drop' then
        --     local itemString, itemName = args:match("|H(.*)|h%[(.*)%]|h");
        --     item = {};
        --     itemObj.itemString = itemString;
        --     itemObj.name = itemName;
        --     ns:AddDrop(msg, item);
    elseif (cmd == 'kill' or cmd == 'wipe') then
        Pulse_DKP.currentRaid.npc = args;
        Pulse_DKP.currentRaid.chars = {};
        for i = 1, 40 do
            local char = {};
            char.name, char.rank = GetRaidRosterInfo(i);
            if char.name ~= nil then
                Pulse_DKP.currentRaid.chars[i] = {};
                Pulse_DKP.currentRaid.chars[i].name, Pulse_DKP.currentRaid.chars[i]
                    .rank = GetRaidRosterInfo(i);
            end
        end
    elseif (cmd == 'close') then
        ns:PD_CloseMainFrame();
    else
        ns:PD_OpenMainFrame();
    end
end
function ns:PD_OpenMainFrame() PD_Frame(); end
function ns:PD_CloseMainFrame() PulseDkpMainFrame:Hide(); end
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
    Pulse_DKP.currentRaid = newRaid;

    -- ns:notify(1, Pulse_DKP.currentRaid);    
end

function ns:StartRaid()
    if Pulse_DKP.currentRaid == nil then return; end

    Pulse_DKP.currentRaid.startingChars = {};

    for i = 1, 40 do
        local char = {};
        char.name, _, _, _, _, _, char.zone = GetRaidRosterInfo(i);

        if char.name ~= nil then
            tinsert(Pulse_DKP.currentRaid.startingChars, char);
        end
    end

    Pulse_DKP.currentRaid.startedOn = date("!%Y-%m-%d %H:%M");
    Pulse_DKP.raids[Pulse_DKP.currentRaid.index] = Pulse_DKP.currentRaid;
    ns:RegisterLootReady();
end

function ns:AddDrop(mob, item)
    if Pulse_DKP.currentRaid == nil then return; end

    if Pulse_DKP.currentRaid.drops == nil then
        Pulse_DKP.currentRaid.drops = {};
    end
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

    tinsert(Pulse_DKP.currentRaid.drops, drop);
    Pulse_DKP.raids[Pulse_DKP.currentRaid.index] = Pulse_DKP.currentRaid;
    local copy = {}

    copy.mobid = mob.id;
    copy.quantity = item.quantity;
    copy.roll = item.roll;
    copy.mobname = mob.name;
    copy.locked = item.locked;
    copy.quality = item.quality;
    copy.item = item.item;
    copy.texture = item.texture;

    ns:notify(2, copy);

    local updates = {mobid = mob, chars = {}};
    local index = 0;
    for i = 1, #drop.chars do
        updates.chars[index] = drop.chars[i];
        index = index + 1;
        if (index == 5 or i == #drop.chars) then
            ns:notify(10, updates);
            updates.chars = {};
            index = 0;
        end
    end
end
function ns:DistributeLoot(item, winner, itemLink, mob)
    if Pulse_DKP.currentRaid == nil then return; end

    if Pulse_DKP.currentRaid.lootWinners == nil then
        Pulse_DKP.currentRaid.lootWinners = {};
    end
    local lootWinner = {};
    lootWinner.item = item;
    lootWinner.itemLink = itemLink;
    lootWinner.chars = winner;
    lootWinner.mobid = mob.id;
    lootWinner.mobname = mob.name;
    tinsert(Pulse_DKP.currentRaid.lootWinners, lootWinner);
    Pulse_DKP.raids[Pulse_DKP.currentRaid.index] = Pulse_DKP.currentRaid;
    print('Loot distributed');

end
function ns:EndRaid(msg)
    if Pulse_DKP.currentRaid == nil then return; end
    Pulse_DKP.currentRaid.finishingChars = {};
    for i = 1, 40 do
        local char = {};
        char.name, _, _, _, _, _, char.zone = GetRaidRosterInfo(i);

        if char.name ~= nil then
            tinsert(Pulse_DKP.currentRaid.finishingChars, char);
        end
    end
    Pulse_DKP.currentRaid.closedOn = date("!%Y-%m-%d %H:%M");
    Pulse_DKP.raids[Pulse_DKP.currentRaid.index] = Pulse_DKP.currentRaid;
    ns:UnRegisterLootReady();
end
function ns:ClearRaids() Pulse_DKP.raids = {}; end
function ns:ListRaids() KethoEditBox_Show(json.encode(Pulse_DKP.raids)); end

function ns:GetCurrentRaid()
    if Pulse_DKP.currentRaid == nil then return; end
    return Pulse_DKP.currentRaid;
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
function ns:SetCurrentRaid(raid)
    if (raid ~= nil) then Pulse_DKP.currentRaid = raid; end
end
function ns:dkpLootOpen()
    local mobId = UnitGUID("target");
    local add = true;
    if Pulse_DKP.currentRaid ~= nil and Pulse_DKP.currentRaid.drops ~= nil then
        for i = 1, #Pulse_DKP.currentRaid.drops do
            if Pulse_DKP.currentRaid.drops[i].mob.id == mobId then
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
            local t = info[i];
            ns:AddDrop(mob, t);
        end
    end
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
function ns:UpdateDropFromOther(drop)
    if drop == nil or Pulse_DKP.currentRaid == nil or ns:GetCurrentRaid() == nil then return; end
    if Pulse_DKP.currentRaid.drops == nil then Pulse_DKP.currentRaid.drops = {}; end

    local mobid, mobname = drop.mobid, drop.mobname;
    local dropIndex;

    for i = 1, #Pulse_DKP.currentRaid.drops do
        local d = Pulse_DKP.currentRaid.drops[i];
        if d ~= nil and d.mob ~= nil and d.mob.id == mobid and d.item.item ==
            drop.item then

            dropIndex = i;
            break
        end
    end
    if (dropIndex ~= nil) then return; end

    local item = {};
    for key, value in pairs(drop) do
        if (key ~= "mobid" and key ~= "mobname") then item[key] = value; end
    end

    local d = {mob = {name = mobname, id = mobid}, item = item};
    tinsert(Pulse_DKP.currentRaid.drops, d);
    PD_BindCurrentRaidDetails();
end
function ns:ParseLPStandings(lpString)

    if not lpString then return end

    local workString = lpString:gsub("{", "");
    workString = workString:gsub("}", "");
    local parsedLp = {};
    for token in string.gmatch(workString, "[^%,]+") do
        token = token:gsub('"', "");
        local prop, value = string.match(token, "(.*):(.*)");
        parsedLp[prop] = tonumber(value);
    end
    Pulse_DKP.LP = parsedLp;
end

function ns:SetNewLootWinner()
    if not Pulse_DKP or not Pulse_DKP.currentRaid then return end

    for i = 1, #Pulse_DKP.currentRaid.lootWinners do
        local win = Pulse_DKP.currentRaid.lootWinners[i];
        if win.mobid == Pulse_DKP.currentMob.id and win.itemLink ==
            Pulse_DKP.currentItem and win.chars == Pulse_DKP.lootWinner then
            Pulse_DKP.currentRaid.lootWinners[i].chars = Pulse_DKP.newLootWinner;
        end
    end
    Pulse_DKP.currentItem = nil;
    Pulse_DKP.newLootWinner = nil;
    Pulse_DKP.lootWinner = nil;

end
function ns:DeleteWinner()
    if not Pulse_DKP or not Pulse_DKP.currentRaid then return end

    for i = 1, #Pulse_DKP.currentRaid.lootWinners do
        local win = Pulse_DKP.currentRaid.lootWinners[i];
        if win.mobid == Pulse_DKP.currentMob.id and win.itemLink ==
            Pulse_DKP.currentItem and win.chars == Pulse_DKP.lootWinner then
            Pulse_DKP.currentRaid.lootWinners[i] = nil;
        end
    end
    Pulse_DKP.currentItem = nil;
    Pulse_DKP.newLootWinner = nil;
    Pulse_DKP.lootWinner = nil;

end
SLASH_PULSE_DKP1 = "/pd";

