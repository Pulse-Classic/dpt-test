local _, ns = ...;

function PD_MainFrame_OnLoad()
	-- PD_InitRaidDropDown();
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

-- function PD_InitRaidDropDown()
-- 	print('test');
-- 	-- ns:GetAvailableRaids();
-- 	-- local raids=ns:GetAvailableRaids();
-- 	-- if raids ==  nil then 
-- 	-- 	print('raids =nil');
-- 	-- 	return;
-- 	-- end
-- 	-- local menu={
-- 	-- 	{ text = "Chose a raid..", isTitle = true}
-- 	-- };
	
-- 	-- for i=1, #raids do
-- 	-- 	local tmp = raids[i];
-- 	-- 	if tmp ~= nil and tmp.enabled then
-- 	-- 		tinsert(menu,{text=tmp.name, function() print(tmp.name); end });
-- 	-- 	end
-- 	-- end
-- 	-- menuFrame = CreateFrame("Frame", "PD_NewRaidFrame", PD_NewRaidFrame, "UIDropDownMenuTemplate");
-- 	-- menuFrame:SetPoint("Center", UIParent, "Center")
-- 	-- EasyMenu(menu, menuFrame, menuFrame, 0 , 0, "MENU");
-- end

	
-- 	local menu = {
-- 		{ text = "Select an Option", isTitle = true},
-- 		{ text = "Option 1", func = function() print("You've chosen option 1"); end },
-- 		{ text = "Option 2", func = function() print("You've chosen option 2"); end },
-- 		{ text = "More Options", hasArrow = true,
-- 			menuList = {
-- 				{ text = "Option 3", func = function() print("You've chosen option 3"); end }
-- 			} 
-- 		}
-- 	}
-- 	-- Note that this frame must be named for the dropdowns to work.
-- 	local menuFrame = CreateFrame("Frame", "ExampleMenuFrame", PD_NewRaidFrame, "UIDropDownMenuTemplate")
	
-- 	-- Make the menu appear at the cursor: 
-- 	EasyMenu(menu, menuFrame, "cursor", 0 , 0, "MENU");
-- 	-- Or make the menu appear at the frame:
-- 	menuFrame:SetPoint("Center", UIParent, "Center")
-- 	EasyMenu(menu, menuFrame, menuFrame, 0 , 0, "MENU");
-- end
