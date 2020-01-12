local frame = CreateFrame('Frame');
local realm = GetRealmName();
local _, ns = ...;

function ns:init ()
	if ((Pulse_DKP == nil) or (Pulse_DKP.version < 1)) then
		Pulse_DKP = {};
	end
	Pulse_DKP.version = 1;
end

frame:RegisterEvent('PLAYER_LOGIN');
frame:SetScript('OnEvent', function (self, event, ...)
	if (event == 'PLAYER_LOGIN') then
		ns:init();
		frame:RegisterEvent('LOOT_READY');		
		frame:RegisterEvent('RAID_INSTANCE_WELCOME');
		
		frame:SetScript('OnEvent', function (self, event, bagId)
			if (event == 'LOOT_READY') then
				ns:dkpLootOpen();
				ns:testLootOpen();
			end		
			if (event == 'RAID_INSTANCE_WELCOME') then
				print('RAID_INSTANCE_WELCOME');
			end
		end);
	end
	-- if (event == 'RAID_ROSTER_UPDATE') then		
	-- 	print('RAID_ROSTER_UPDATE');
	-- 	-- frame:RegisterEvent('LOOT_READY');		
	-- 	-- frame:SetScript('OnEvent', function (self, event, bagId)
	-- 	-- 	if (event == 'LOOT_READY') then
	-- 	-- 		ns:dkpLootOpen();
	-- 	-- 		ns:testLootOpen();
	-- 	-- 	end
	-- 	-- end);
	-- end
end);



