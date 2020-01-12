local _, ns = ...;

function PD_MainFrame_OnLoad()
	-- PD_BindCurrentRaid();
end

function LoadRaidHistory()

end

function GetHistoryTemplateItem(raidItem)
	if (raidItem == nil) then
		return
	end
end

function PD_MainFrame_Close()
	PD_MainFrame:Hide();
end

function PD_CreateRaid()
	print (PD_NewRaidName:GetText());
	print(ns);
	ns:CreateRaid(nil, PD_NewRaidName:GetText());
	PD_BindCurrentRaid();
end

function PD_BindCurrentRaid()
	print('binding current')
	local tmp=ns:GetCurrentRaid();
	
	if(tmp == nil )then 
		return;
	end
	print('binding currn2');
	PDCurrentRaidName:SetText(tmp.name);
	PDCurrentRaidDate:SetText(tmp.date);
end
