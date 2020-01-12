local frame = CreateFrame('Frame');
local realm = GetRealmName();

function initPulse ()
	print('init pulse dkp module')
	if ((Pulse_DKP == nil) or (Pulse_DKP.version < 1)) then
		Pulse_DKP = {};
	end
	if (Pulse_DKP.realm == nil) then
		Pulse_DKP.realm = {};
	end
	if (Pulse_DKP.realm[realm] == nil) then
		Pulse_DKP.realm[realm] = {};
	end
	Pulse_DKP.version = 1;
end

frame:SetScript('OnEvent', function (self, event, ...)
	if (event == 'PLAYER_LOGIN') then

		initPulse();
		frame:RegisterEvent('LOOT_READY');

		frame:SetScript('OnEvent', function (self, event, bagId)			
			if (event == 'LOOT_READY') then
				dkpLootOpen();
			end
		end);
	end
end);
