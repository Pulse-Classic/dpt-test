local frame = CreateFrame('Frame');
local realm = GetRealmName();
local _, ns = ...;
function ns:init ()
	if ((Pulse_DKP == nil) or (Pulse_DKP.version < 1)) then
		Pulse_DKP = {};
	end
	
	Pulse_DKP.availableRaids={};
	tinsert(Pulse_DKP.availableRaids, {name="Onyxia's Lair", enabled=true});
	tinsert(Pulse_DKP.availableRaids, {name="Molten Core", enabled=true});
	tinsert(Pulse_DKP.availableRaids, {name="Blackwing Lair", enabled=false});
	tinsert(Pulse_DKP.availableRaids, {name="Zul'Gurub", enabled=false});
	tinsert(Pulse_DKP.availableRaids, {name="Temple of Ahn'Qiraj", enabled=false});
	tinsert(Pulse_DKP.availableRaids, {name="Ruins of Ahn'Qiraj", enabled=false});		 
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
			-- if (event == 'RAID_INSTANCE_WELCOME') then
			-- 	print('RAID_INSTANCE_WELCOME');
			-- 	print('Entering '..GetZoneText());
			-- end
		end);
	end
end);

-- function ns:RegisterLootReady()
-- 	frame:RegisterEvent('LOOT_READY');		
-- end
-- function ns:UnRegisterLootReady()
-- 	frame:UnregisterEvent('LOOT_READY');		
-- end

