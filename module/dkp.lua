
SlashCmdList.PULSE_DKP = function (msg)

	local json = _G['json'];
	local temp = {};
	local _, _, cmd, args = string.find(msg, "%s?(%w+)%s?(.*)");

	temp.cmd = cmd;

	if (cmd == 'drop' or cmd == 'roll' or cmd == 'roll2' or cmd == 'roll3' or cmd == 'roll4' or cmd == 'roll5') then
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
		temp.chars = {};
		for i = 1, 40 do
			local char = {};
			char.name, char.rank = GetRaidRosterInfo(i);
			if char.name ~= nil then
				temp.chars[i] = {};
				temp.chars[i].name, temp.chars[i].rank = GetRaidRosterInfo(i);
			end
		end
	elseif (cmd == 'donate' or cmd == 'loot') then
		local _, _, item, char = string.find(args, "(.*)%s(%w+)");
		if (string.sub(item, 0, 1) ~= '|') then
			_, _, char, item = string.find(args, "(%w+)%s(.*)");
		end
		if (cmd == 'loot') then
			SendChatMessage(char .. ' wins ' .. item .. ' Congrats!', RAID);
		end
		local itemString, itemName = item:match("|H(.*)|h%[(.*)%]|h");
		temp.itemString = itemString;
		temp.itemName = itemName;
		temp.char = char;
	elseif (cmd == 'start' or cmd == 'end') then
		temp.chars = {};
		for i = 1, 40 do
			local char = {};
			char.name, char.rank = GetRaidRosterInfo(i);
			if char.name ~= nil then
				temp.chars[i] = {};
				temp.chars[i].name, temp.chars[i].rank = GetRaidRosterInfo(i);
			end
		end
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
	else
		print('Unknown command.');
	end

	KethoEditBox_Show(json.encode(temp));

end


function dkpLootOpen ()
	local name = GetUnitName('target');
	local info = GetLootInfo();
	local json = _G['json'];
	print(name);
	print(json.encode(info));
	-- KethoEditBox_Show(json.encode(info));
end

SLASH_PULSE_DKP1 = "/pulse";
