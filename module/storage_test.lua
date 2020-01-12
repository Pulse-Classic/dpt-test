local temp = {};
local _, ns = ...;

SlashCmdList.PULSE_DKP_TEST = function (msg)
	local _, _, cmd, args = string.find(msg, "%s?(%w+)%s?(.*)");

	if (Pulse_DKP.temptest == nil) then
		Pulse_DKP.temptest = {};
	end

	if (cmd == 'create') then
		if (Pulse_DKP.temptest.active ~= nil) then
			print('Active run exists');
			return;
		end
		Pulse_DKP.temptest.active = {};
		print('Created run');
	elseif (cmd == 'start') then
		if (Pulse_DKP.temptest.active == nil) then
			print('No active run exists');
			return;
		end
		if (Pulse_DKP.temptest.active.start ~= nil) then
			print('Active run started already');
			return;
		end
		Pulse_DKP.temptest.active.start = {};
		Pulse_DKP.temptest.active.start.utime = time();
		Pulse_DKP.temptest.active.start.chars = ns:getRaidMembers();
		print('Started run');
	elseif (cmd == 'clear') then
		Pulse_DKP.temptest = {};
	elseif (cmd == 'status') then
		if (Pulse_DKP.temptest.active == nil) then
			print('Run not created.');
		elseif (Pulse_DKP.temptest.active.start == nil) then
			print('Run created, but not started.');
		end
	end
end

function ns:testLootOpen ()
end


SLASH_PULSE_DKP_TEST1 = '/pt';
