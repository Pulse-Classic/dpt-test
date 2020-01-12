local json = _G['json'];	
local temp = {};
local realm = GetRealmName();
local char = UnitName('player');

SlashCmdList.PULSE_DKP = function (msg)	
	local _, _, cmd, args = string.find(msg, "%s?(%w+)%s?(.*)");

	if (cmd == 'roll' or cmd == 'roll2' or cmd == 'roll3' or cmd == 'roll4' or cmd == 'roll5') then
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

	
	elseif cmd == 'create' then
		CreateRaid(msg,args);	
	
	elseif cmd == 'start' then
		StartRaid();

	elseif cmd == 'end'then
		EndRaid(msg);

	elseif cmd == 'clearraids' then
		ClearRaids();	

	elseif cmd == 'listraids' then
		ListRaids();	
	
	elseif cmd == 'drop' then
		local itemString, itemName = args:match("|H(.*)|h%[(.*)%]|h");
		item={};
		item.itemString=itemString;
		item.name=itemName;
		AddDrop(msg,item);	
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
		-- print('Unknown command.');
		PulseDkpUi_Show('show me the money');
	end			
end

function CreateRaid(msg, args)
	if args == nil or string.len(args)<2 then
		print('A raid cannot be started without a name. A minimum of two characters is required. To include whitespaces, wrap your name in \'. For example: /pulse start \'Mc trash\'');
		return;
	end

	local newRaid={};
	newRaid.chars = {};
	newRaid.name=args;
	newRaid.date=date("!%Y-%m-%d %H:%M");
	newRaid.createdBy=char;
	newRaid.index=#PulseDkp.realm[realm].raids+1;
	newRaid.closedOn=nil;	
	newRaid.startedOn=nil;
	Pulse_DKP.realm[realm].raids[newRaid.index]= newRaid;
	temp=newRaid;
	ListRaids();
end

function StartRaid()
	if temp==nil then 
		return;
	end
	
	temp.startingChars={};	

	for i = 1, 40 do
		local char = {};
		char.name, _, _,_,_,_,char.zone = GetRaidRosterInfo(i);  

		if char.name ~= nil then
			tinsert(temp.startingChars,char);		
		end
	end

	temp.startedOn=date("!%Y-%m-%d %H:%M");	
	Pulse_DKP.realm[realm].raids[temp.index]=temp;	
	ListRaids();
end

function AddDrop(msg, item)
	if temp==nil then 
		return;
	end

	if temp.drops == nil then
		temp.drops={};
	end
	local drop={};
	drop.item=item;
	drop.chars={};

	for i = 1, 40 do
		local char = {};
		char.name, char.rank, _,_,_,_,char.zone = GetRaidRosterInfo(i);  

		if char.name ~= nil then
			tinsert(drop.chars,char);		
		end
	end
	
	tinsert(temp.drops, drop);
	Pulse_DKP.realm[realm].raids[temp.index]=temp;	
	print('added drop');
	
end

function EndRaid(msg)
	if temp==nil then 
		return;
	end
	temp.finishingChars={};
	for i = 1, 40 do
		local char = {};
		char.name, _, _,_,_,_,char.zone = GetRaidRosterInfo(i);  

		if char.name ~= nil then
			tinsert(temp.finishingChars,char);		
		end
	end
	temp.closedOn=date("!%Y-%m-%d %H:%M");	
	Pulse_DKP.realm[realm].raids[temp.index]=temp;	
	print('ending raid');
	temp=nil;
end
function ClearRaids()
	Pulse_DKP.realm[realm].raids={};
end
function ListRaids()
	KethoEditBox_Show(json.encode(Pulse_DKP.realm[realm].raids));	
end



function dkpLootOpen ()
	local name = GetUnitName('target');
	local info = GetLootInfo();
	local json = _G['json'];
	print(name);
	print(json.encode(info));
	-- KethoEditBox_Show(json.encode(info));
end

SLASH_PULSE_DKP1 = "/pulsedkp";