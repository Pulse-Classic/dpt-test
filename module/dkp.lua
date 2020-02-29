local json = _G['json'];
local realm = GetRealmName();
local char = UnitName('player');
local _, ns = ...;
local currentItem;
SlashCmdList.PULSE_DKP = function(msg)
    local _, _, cmd, args = string.find(msg, "%s?(%w+)%s?(.*)");

    if (cmd == 'loot') then

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
            ns:DistributeLoot(itemObj, charLink, item);
            PD_AddWinnersToFrame();
        end

    elseif cmd == 'create' then
        ns:CreateRaid(msg, args);
    elseif cmd == 'ps' then
        ns:AddLPImportFrame();
    elseif cmd == 'start' then
        ns:StartRaid(true);

    elseif cmd == 'end' then
        ns:EndRaid(msg);

    elseif cmd == 'clearraids' then
        ns:ClearRaids();
    elseif cmd == 'clearcurrent' then
        ns:ClearCurrent();
    elseif cmd == 'listraids' then
        ns:ListRaids();

        -- elseif cmd == 'drop' then
        --     local itemString, itemName = args:match("|H(.*)|h%[(.*)%]|h");
        --     item = {};
        --     itemObj.itemString = itemString;
        --     itemObj.name = itemName;
        --     ns:AddDrop(msg, item);
    elseif (cmd == 'wipe') then
        if not Pulse_DKP.currentRaid.wipes then
            Pulse_DKP.currentRaid.wipes = {};
        end
        local bossName = GetUnitName('target');
        if not bossName then bossName = args end

        local wipe = {boss = bossName, chars = {}};
        for i = 1, 40 do
            local name = GetRaidRosterInfo(i);
            if name ~= nil then
                tinsert(wipe.chars, GetRaidRosterInfo(i))
            end
        end
        tinsert(Pulse_DKP.currentRaid.wipes, wipe);

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
    ns:notify(Pulse_DKP.notify["CREATE"], newRaid);
end

function ns:StartRaid(notify)
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
    if notify and notify == true then ns:notify(Pulse_DKP.notify["START"]); end
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

    ns:notify(Pulse_DKP.notify["DROP"], copy);

    local updates = {mobid = mob, chars = {}};

    for i = 1, #drop.chars do
        tinsert(updates.chars, drop.chars[i]);
        if (i % 5 == 0 or i == #drop.chars) then
            ns:notify(Pulse_DKP.notify["DROP_ATTENDEES"], updates);
            updates.chars = {};
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
    if mob ~= nil then
        lootWinner.mobid = mob.id;
        lootWinner.mobname = mob.name;
    end
    tinsert(Pulse_DKP.currentRaid.lootWinners, lootWinner);
    Pulse_DKP.raids[Pulse_DKP.currentRaid.index] = Pulse_DKP.currentRaid;

    local flattened = {};
    flattened.itemLink = itemLink;
    flattened.chars = winner;
    if mob ~= nil then
        flattened.mobid = mob.id;
        flattened.mobid = mob.name;
    end
    flattened.itemTime = item.time;
    flattened.itemName = item.name;
    flattened.itemString = item.itemString;
    ns:notify(Pulse_DKP.notify["LOOT"], flattened);
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
function ns:ClearCurrent() Pulse_DKP.currentRaid = {}; end
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
    if not Pulse_DKP or not Pulse_DKP.currentRaid or Pulse_DKP.newLootWinner ==
        nil then return end

    for i = 1, #Pulse_DKP.currentRaid.lootWinners do
        local win = Pulse_DKP.currentRaid.lootWinners[i];
        if win ~= nil and win.itemLink == Pulse_DKP.currentItem and win.chars ==
            Pulse_DKP.lootWinner then
            Pulse_DKP.currentRaid.lootWinners[i].chars = Pulse_DKP.newLootWinner;
            ns:notify(Pulse_DKP.notify["UPDATE_WINNER"], {
                itemLink = win.itemLink,
                lootWinner = Pulse_DKP.lootWinner,
                newLootWinner = Pulse_DKP.newLootWinner
            });
            break
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
        if win ~= nil and win.itemLink == Pulse_DKP.currentItem and win.chars ==
            Pulse_DKP.lootWinner then
            ns:notify(Pulse_DKP.notify["DELETE_LOOT"], {
                itemLink = Pulse_DKP.currentItem,
                lootWinner = Pulse_DKP.lootWinner
            });
            Pulse_DKP.currentRaid.lootWinners[i] = nil;
            break
        end
    end

    Pulse_DKP.currentItem = nil;
    Pulse_DKP.newLootWinner = nil;
    Pulse_DKP.lootWinner = nil;

end

function ns:UpdateDropFromOther(drop)
    if drop == nil or Pulse_DKP.currentRaid == nil or ns:GetCurrentRaid() == nil then
        return;
    end
    if Pulse_DKP.currentRaid.drops == nil then
        Pulse_DKP.currentRaid.drops = {};
    end

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
function ns:AddWinnerFromOther(loot)
    if loot == nil or Pulse_DKP.currentRaid == nil or ns:GetCurrentRaid() == nil then
        return;
    end
    if Pulse_DKP.currentRaid.lootWinners == nil then
        Pulse_DKP.currentRaid.lootWinners = {};
    end

    local lootWinner = {};
    lootWinner.itemLink = loot.itemLink;
    lootWinner.chars = loot.chars;
    lootWinner.mobid = loot.mobid;
    lootWinner.mobname = loot.mobname;
    lootWinner.item = {
        time = loot.itemTime,
        name = loot.itemName,
        itemString = loot.itemString
    };
    tinsert(Pulse_DKP.currentRaid.lootWinners, lootWinner);
    Pulse_DKP.raids[Pulse_DKP.currentRaid.index] = Pulse_DKP.currentRaid;
    PD_BindCurrentRaidDetails();
end
function ns:DeleteWinnerFromOther(del)
    if del == nil or Pulse_DKP.currentRaid == nil or ns:GetCurrentRaid() == nil then
        return;
    end
    if Pulse_DKP.currentRaid.lootWinners == nil then return end

    for i = 1, #Pulse_DKP.currentRaid.lootWinners do
        local win = Pulse_DKP.currentRaid.lootWinners[i];
        if win ~= nil and win.itemLink == del.itemLink and win.chars ==
            del.lootWinner then
            Pulse_DKP.currentRaid.lootWinners[i] = nil;
            break
        end
    end

    Pulse_DKP.raids[Pulse_DKP.currentRaid.index] = Pulse_DKP.currentRaid;
    PD_BindCurrentRaidDetails();
end
function ns:UpdateWinnerFromOther(loot)
    if loot == nil or Pulse_DKP.currentRaid == nil or ns:GetCurrentRaid() == nil then
        return;
    end
    if Pulse_DKP.currentRaid.lootWinners == nil then
        Pulse_DKP.currentRaid.lootWinners = {};
    end

    for i = 1, #Pulse_DKP.currentRaid.lootWinners do
        local win = Pulse_DKP.currentRaid.lootWinners[i];
        if win ~= nil and win.itemLink == loot.currentItem and win.chars ==
            loot.lootWinner then
            Pulse_DKP.currentRaid.lootWinners[i].chars = loot.newLootWinner;
            break
        end
    end

    PD_BindCurrentRaidDetails();
end

function ns:CreateRaidFromOtherMessageRecieved(raid)
    if Pulse_DKP.currentRaid and Pulse_DKP.currentRaid.closedOn == nil then
        if not StaticPopupDialogs["CONFIRM_OVERWRITE_RAID"] then
            StaticPopupDialogs["CONFIRM_OVERWRITE_RAID"] =
                {
                    text = raid.createdBy .. " has started a new raid for " ..
                        raid.name ..
                        ".\n Would you like to use this as your current, active raid?",
                    button1 = "Yes",
                    button2 = "No",
                    OnAccept = function()
                        ns:CreateRaidFromOther(raid);
                    end,
                    timeout = 0,
                    whileDead = true,
                    hideOnEscape = true,
                    preferredIndex = 3 -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
                }
        end
        StaticPopup_Show("CONFIRM_OVERWRITE_RAID");

    else
        ns:CreateRaidFromOther(raid);
    end
end
function ns:CreateRaidFromOther(raid)
    local index = 1;
    if (Pulse_DKP.raids ~= nil) then index = #Pulse_DKP.raids + 1; end
    if (Pulse_DKP.raids == nil) then Pulse_DKP.raids = {}; end

    raid.index = index;
    Pulse_DKP.raids[raid.index] = raid;
    Pulse_DKP.currentRaid = raid;
    PD_BindCurrentRaidDetails();
end

function ns:AddDropAttendeesFromOther(update)

    if Pulse_DKP.currentRaid == nil or Pulse_DKP.currentRaid.drops == nil then
        return;
    end

    local drop = nil;
    local index;
    for i = 1, #Pulse_DKP.currentRaid.drops do
        if drop.mob.id == update.mobid then
            drop = Pulse_DKP.currentRaid.drops[i];
            index = i;
            break
        end
    end
    if not drop then return; end
    tinsert(Pulse_DKP.currentRaid.drops[index], update.char);
    Pulse_DKP.raids[Pulse_DKP.currentRaid.index] = Pulse_DKP.currentRaid;
    PD_BindCurrentRaidDetails();
end
SLASH_PULSE_DKP1 = "/pd";

