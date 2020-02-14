local _, ns = ...;

function ns:OpenEditFrame(item, mob, winner)
    if not Pulse_DKP then return end

    Pulse_DKP.currentItem = item;
    Pulse_DKP.currentMob = mob;
    Pulse_DKP.lootWinner = winner;

    if not PulseDkpEditWinnerFrame then
        local f = CreateFrame("Frame", "PulseDkpEditWinnerFrame", UIParent);

        f:SetSize(400, 600);
        f:SetPoint('RIGHT', PulseDkpMainFrame, 400, 0);
        f:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            edgeSize = 16,
            insets = {left = 0, right = 0, top = 0, bottom = 0}
        });
        f:SetBackdropBorderColor(0, .44, .87, 0.5); -- darkblue

        ns:RegisterFrameDraggable(f);

        tinsert(UISpecialFrames, f:GetName());
        local PD_CloseBtn = CreateFrame("Button",
                                        "PulseDkpEditRollFrameCloseButton",
                                        PulseDkpEditWinnerFrame,
                                        "UIPanelButtonTemplate");
        PD_CloseBtn:SetPoint("TOPRIGHT", 1, 17);
        PD_CloseBtn:SetSize(20, 20);
        PD_CloseBtn:SetText("X");

        PD_CloseBtn:SetScript("OnMouseUp", function(self, button)
            PulseDkpEditWinnerFrame:Hide();
        end);

        local PulseDkpEditFrameTitle = PulseDkpEditWinnerFrame:CreateFontString(
                                           "PulseDkpEditFrameTitle", "OVERLAY",
                                           "GameFontNormal");
        PulseDkpEditFrameTitle:SetFont("Fonts\\FRIZQT__.TTF", 14);
        PulseDkpEditFrameTitle:SetPoint("TOPLEFT", 10, -30);
        PulseDkpEditFrameTitle:SetWidth(PulseDkpEditWinnerFrame:GetWidth() - 10);
        PulseDkpEditFrameTitle:SetJustifyH("CENTER");
        PulseDkpEditFrameTitle:SetWordWrap(false);
        PulseDkpEditFrameTitle:SetText("Edit loot winner");

        local PulseDkpEditFrameCurrentWinner =
            PulseDkpEditWinnerFrame:CreateFontString(
                "PulseDkpEditFrameCurrentWinner", "OVERLAY", "GameFontNormal");
        PulseDkpEditFrameCurrentWinner:SetFont("Fonts\\FRIZQT__.TTF", 12);
        PulseDkpEditFrameCurrentWinner:SetPoint("TOPLEFT", 10, -50);
        PulseDkpEditFrameCurrentWinner:SetWidth(
            PulseDkpEditWinnerFrame:GetWidth() - 10);
        PulseDkpEditFrameCurrentWinner:SetJustifyH("LEFT");
        PulseDkpEditFrameCurrentWinner:SetWordWrap(false);

        local PulseDkpEditFrameSelectNewWinner =
            PulseDkpEditWinnerFrame:CreateFontString(
                "PulseDkpEditFrameSelectNewWinner", "OVERLAY", "GameFontNormal");
        PulseDkpEditFrameSelectNewWinner:SetFont("Fonts\\FRIZQT__.TTF", 12);
        PulseDkpEditFrameSelectNewWinner:SetPoint("TOPLEFT", 10, -70);
        PulseDkpEditFrameSelectNewWinner:SetWidth(
            PulseDkpEditWinnerFrame:GetWidth() - 10);
        PulseDkpEditFrameSelectNewWinner:SetJustifyH("LEFT");
        PulseDkpEditFrameSelectNewWinner:SetWordWrap(false);
        PulseDkpEditFrameSelectNewWinner:SetText("Select new winner:")

        local PulseDkSetNewLootWinner = CreateFrame("Button",
                                                    "PulseDkSetNewLootWinner",
                                                    PulseDkpEditWinnerFrame,
                                                    "UIPanelButtonTemplate");
        PulseDkSetNewLootWinner:SetPoint("TOPLEFT", 280, -90);
        PulseDkSetNewLootWinner:SetSize(110, 30);
        PulseDkSetNewLootWinner:SetText("Set new winner");
        PulseDkSetNewLootWinner:SetEnabled(Pulse_DKP.lootWinner ~= nil);
        PulseDkSetNewLootWinner:SetScript("OnMouseUp", function(self, button)
            if not StaticPopupDialogs["CONFIRM_NEW_LOOT_WINNER"] then
                StaticPopupDialogs["CONFIRM_NEW_LOOT_WINNER"] =
                    {
                        text = "Are you sure you want to update the loot winner?",
                        button1 = "Yes",
                        button2 = "No",
                        OnAccept = function()
                            ns:SetNewLootWinner();
                            PD_AddWinnersToFrame();
                        end,
                        timeout = 0,
                        whileDead = true,
                        hideOnEscape = true,
                        preferredIndex = 3 -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
                    }
            end
            StaticPopup_Show("CONFIRM_NEW_LOOT_WINNER");
        end);

        local PulseDkDeleteWinner = CreateFrame("Button", "PulseDkDeleteWinner",
                                                PulseDkpEditWinnerFrame,
                                                "UIPanelButtonTemplate");
        PulseDkDeleteWinner:SetPoint("TOPLEFT", 280, -120);
        PulseDkDeleteWinner:SetSize(110, 30);
        PulseDkDeleteWinner:SetText("Delete winner");
        PulseDkDeleteWinner:SetEnabled(Pulse_DKP.lootWinner ~= nil);
        PulseDkDeleteWinner:SetScript("OnMouseUp", function(self, button)
            if not StaticPopupDialogs["CONFIRM_DELETE_WINNER"] then
                StaticPopupDialogs["CONFIRM_DELETE_WINNER"] =
                    {
                        text = "Are you sure you want to delete the loot winner?",
                        button1 = "Yes",
                        button2 = "No",
                        OnAccept = function()
                            ns:DeleteWinner();
                            PD_AddWinnersToFrame();
                        end,
                        timeout = 0,
                        whileDead = true,
                        hideOnEscape = true,
                        preferredIndex = 3 -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
                    }
            end
            StaticPopup_Show("CONFIRM_DELETE_WINNER");
        end);

        local PD_T = CreateFrame("Frame", "PulseDkpEditRollTitleFrame",
                                 PulseDkpEditWinnerFrame);
        PD_T:SetSize(PulseDkpEditWinnerFrame:GetWidth(), 30);
        PD_T:SetPoint("TOPLEFT", 0, 0);

        local x = PD_T:CreateFontString("PD_EditRollTitleFont", "OVERLAY",
                                        "GameFontNormal");
        x:SetFont("Fonts\\FRIZQT__.TTF", 16);
        x:SetPoint("TOPLEFT", 10, -10);
        x:SetWidth(PulseDkpEditWinnerFrame:GetWidth());
        x:SetJustifyH("LEFT");
        x:SetWordWrap(false);
    end
    PD_EditRollTitleFont:SetText(item);
    ns:AddNewLootWinnerDropDown();
    if (Pulse_DKP.lootWinner ~= nil) then
        PulseDkpEditFrameCurrentWinner:SetText(
            "Current winner: " .. Pulse_DKP.lootWinner);
    end

    PulseDkpEditWinnerFrame:Show();

end

function ns:AddNewLootWinnerDropDown()
    if Pulse_DKP.currentRaid == nil then return; end
    if not PulseDkpNewLootWinnerDropDown then
        -- Create the dropdown, and configure its appearance
        local PulseDkpNewLootWinnerDropDown =
            CreateFrame("Frame", "PulseDkpNewLootWinnerDropDown",
                        PulseDkpEditWinnerFrame, "UIDropDownMenuTemplate");
        PulseDkpNewLootWinnerDropDown:SetPoint("TOPLEFT", -7, -90);
        UIDropDownMenu_SetWidth(PulseDkpNewLootWinnerDropDown, 200);
        UIDropDownMenu_SetText(PulseDkpNewLootWinnerDropDown,
                               Pulse_DKP.lootWinner);
    end

    UIDropDownMenu_Initialize(PulseDkpNewLootWinnerDropDown,
                              function(self, level)
        for i = 1, 40 do
            local name, rank, subgroup, _level, class, fileName, zone, online,
                  isDead, role, isML = GetRaidRosterInfo(i);
            if name ~= nil then
                local info = UIDropDownMenu_CreateInfo();
                info.text, info.arg1 = name, name;
                info.checked = name == Pulse_DKP.lootWinner;
                info.func = function()
                    Pulse_DKP.newLootWinner = name;
                    UIDropDownMenu_SetText(PulseDkpNewLootWinnerDropDown,
                                           Pulse_DKP.newLootWinner);
                end;
                UIDropDownMenu_AddButton(info, level);
            end
        end
    end);

    PulseDkpNewLootWinnerDropDown:Show();
end
