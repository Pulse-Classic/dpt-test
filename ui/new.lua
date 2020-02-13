local _, ns = ...;
local selectedRaid;
function PD_addNewRaidFrame()
    local PD_NewRaid = CreateFrame("Frame", "PulseDkpNewRaidFrame",
                                   PulseDkpMainFrame);
    PD_NewRaid:SetSize(PulseDkpMainFrame:GetWidth(), 200);
    PD_NewRaid:SetPoint("TOPLEFT", 0, -40);

    local fs = PD_NewRaid:CreateFontString("PulseDkpNewRaid_TitleFont",
                                           "OVERLAY", "GameFontNormal");
    fs:SetFont("Fonts\\FRIZQT__.TTF", 12);
    fs:SetPoint("TOPLEFT", 10, -10);
    fs:SetWidth(200);
    fs:SetJustifyH("LEFT");
    fs:SetWordWrap(false);
    fs:SetText("Create a new raid:");

    local PD_NewRaidBtn = CreateFrame("Button", "PulseDkpNewButton",
                                      PulseDkpNewRaidFrame,
                                      "UIPanelButtonTemplate");
    PD_NewRaidBtn:SetPoint("TOPLEFT", 260, -30);
    PD_NewRaidBtn:SetSize(60, 30);
    PD_NewRaidBtn:SetText("Create");
    PD_NewRaidBtn:SetEnabled(false);
    PD_NewRaidBtn:SetScript("OnMouseUp", function(self, button)
        if (selectedRaid == nil) then return; end
        ns:CreateRaid(selectedRaid);
        PD_BindCurrentRaidDetails();
        PulseDkpNewRaidFrame:Hide();
        PulseDkpCurrentRaidFrame:Show();
    end);

    local PD_LoadBtn = CreateFrame("Button", "PulseDkpLoadLastButton",
                                   PulseDkpNewRaidFrame, "UIPanelButtonTemplate");
    PD_LoadBtn:SetPoint("TOPLEFT", 260, -70);
    PD_LoadBtn:SetSize(75, 30);
    PD_LoadBtn:SetText("Load last");
    PD_LoadBtn:SetEnabled(ns:GetLastUnfinishedRaid() ~= nil);
    PD_LoadBtn:SetScript("OnMouseUp",
                         function(self, button) PD_LoadLastClicked(); end);
    ns:AddNewRaidDropDown();

end

function ns:AddNewRaidDropDown()
    if PulseDkpNewRaidDropDown then return; end
    -- Create the dropdown, and configure its appearance
    local dropdown = CreateFrame("Frame", "PulseDkpNewRaidDropDown",
                                 PulseDkpNewRaidFrame, "UIDropDownMenuTemplate");
    dropdown:SetPoint("TOPLEFT", 0, -30);
    UIDropDownMenu_SetWidth(dropdown, 200);
    UIDropDownMenu_SetText(dropdown, "Select a raid..")

    -- Create and bind the initialization function to the dropdown menu
    UIDropDownMenu_Initialize(dropdown, function(self, level)
        for i = 1, #Pulse_DKP.availableRaids do
            local raid = Pulse_DKP.availableRaids[i];
            if raid ~= nil and raid.enabled == true then
                local info = UIDropDownMenu_CreateInfo();
                info.text, info.arg1 = raid.name, raid.name;
                info.checked = false;
                if selectedRaid ~= nil and selectedRaid == raid.name then
                    info.checked = true;
                end
                info.func = function()
                    selectedRaid = raid.name;
                    UIDropDownMenu_SetText(dropdown, selectedRaid)
                    PulseDkpNewButton:SetEnabled(true);
                end;
                UIDropDownMenu_AddButton(info, level);
            end
        end
    end);
end
