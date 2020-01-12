local temp = {};
local _, ns = ...;

SlashCmdList.PULSE_DKP_TEST = function (msg)
	local _, _, cmd, args = string.find(msg, "%s?(%w+)%s?(.*)");

	if (Pulse_DKP.temptest == nil) then
		Pulse_DKP.temptest = {};
	end

	if (cmd == 'start') then
		if (Pulse_DKP.temptest.active ~= nil) then
			print('Active run started already');
			return;
		end
		Pulse_DKP.temptest.active = {};
		Pulse_DKP.temptest.active.start = {};
		Pulse_DKP.temptest.active.start.utime = time();
		Pulse_DKP.temptest.active.start.chars = ns:getRaidMembers();
		print('Started run');
	elseif (cmd == 'clear') then
		Pulse_DKP.temptest = {};
	elseif (cmd == 'status') then
		if (Pulse_DKP.temptest.active == nil) then
			print('Run not created.');
		else
			print('Run is started.');
		end
	end
end

function ns:testLootOpen ()
	if (Pulse_DKP.temptest.active == nil) then
		print('No active run exists');
		return;
	end
	if (Pulse_DKP.temptest.active.drops == nil) then
		Pulse_DKP.temptest.active.drops = {};
	end

	local name = GetUnitName('target');
	local info = GetLootInfo();

	if (info ~= nil) then
		local drop = {};
		drop.target = name;
		drop.utime = time();
		drop.chars = ns:getRaidMembers();
		drop.items = {};
		for i = 1, #info do

			local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice = GetItemInfo(info[i].item);

			if (itemName ~= nil) then
				info[i].itemName = itemName;
				info[i].itemLink = itemLink;
				info[i].itemRarity = itemRarity;
				info[i].itemLevel = itemLevel;
				info[i].itemMinLevel = itemMinLevel;
				info[i].itemType = itemType;
				info[i].itemSubType = itemSubType;
				info[i].itemStackCount = itemStackCount;
				info[i].itemEquipLoc = itemEquipLoc;
				info[i].itemTexture = itemTexture;
				info[i].itemSellPrice = itemSellPrice;
			end

			tinsert(drop.items, info[i]);

		end

		tinsert(Pulse_DKP.temptest.active.drops, drop);
		print('Loot registered.');
		return;
	end

	print('No loot');

end


SLASH_PULSE_DKP_TEST1 = '/pt';
