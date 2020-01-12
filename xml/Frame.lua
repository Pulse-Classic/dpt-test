local _, ns = ...;
function PD_MainFrame_OnLoad()
	PD_BindCurrentRaid();
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
	local tmp=ns:GetCurrentRaid();
	prin('binding current')
	if(tmp == nil )then 
		return;
	end
	prin('binding currn2');
	PDCurrentRaidName:SetText(tmp.name);
	PDCurrentRaidDate:SetText(date("!%Y-%m-%d %H:%M",tmp.date));
end
