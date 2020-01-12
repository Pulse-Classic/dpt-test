local frame = CreateFrame('Frame');
local realm = GetRealmName();
local _, ns = ...;

function ns:init ()
	if ((Pulse_DKP == nil) or (Pulse_DKP.version < 1)) then
		Pulse_DKP = {};
	end	
	Pulse_DKP.version = 1;
end

frame:SetScript('OnEvent', function (self, event, ...)
	if (event == 'PLAYER_LOGIN') then

		ns:init();
		frame:RegisterEvent('LOOT_READY');

		frame:SetScript('OnEvent', function (self, event, bagId)
			if (event == 'LOOT_READY') then
				ns:dkpLootOpen();
			end
		end);
	end
end);
