
local frame = CreateFrame('Frame');

function initPulse ()
	if ((Pulse_DKP == nil) or (Pulse_DKP.version < 1)) then
		Pulse_DKP = {};
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
