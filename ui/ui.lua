local _, ns = ...;
local selectedRaid;
local json = _G["json"];
local raiders;

function PD_Frame()
    if not PulseDkpMainFrame then
        local PulseDkpMainFrame = CreateFrame("Frame", "PulseDkpMainFrame",
                                              UIParent);
        PulseDkpMainFrame:SetPoint("CENTER");
        PulseDkpMainFrame:SetSize(500, 600);

        PulseDkpMainFrame:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            edgeSize = 16,
            insets = {left = 0, right = 0, top = 0, bottom = 0}
        });
        PulseDkpMainFrame:SetBackdropBorderColor(0, .44, .87, 0.5); -- darkblue
        tinsert(UISpecialFrames, PulseDkpMainFrame:GetName());
        PD_registerDraggable();
        -- PD_registerResizeable();
        PD_registerCloseButton();
        PD_addTitleFrame();
        PD_addNewRaidFrame();
        PD_addCurrentRaidFrame();
    end

    PD_BindCurrentRaidDetails();
    if Pulse_DKP.currentRaid ~= nil then PD_LoadLastClicked(); end
    PulseDkpMainFrame:Show();

end
function PD_registerDraggable()
    -- Movable
    PulseDkpMainFrame:SetMovable(true);
    PulseDkpMainFrame:SetClampedToScreen(true);
    PulseDkpMainFrame:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then self:StartMoving() end
    end);
    PulseDkpMainFrame:SetScript("OnMouseUp",
                                PulseDkpMainFrame.StopMovingOrSizing);
end
function ns:PD_AddMiniMap()
    local btn = CreateFrame("Button", "PulseDkpMiniMap", Minimap);
    btn:SetNormalTexture("Interface\\AddOns\\Pulse_dkp\\media\\pulse_dkp")
    btn:Show();
    btn:SetText("PP");
    btn:SetPoint("TOPLEFT", 0, 0);
end
function PD_MinimapClick()
    if PulseDkpMainFrame ~= nil and PulseDkpMainFrame:IsVisible() then
        PulseDkpMainFrame:Hide();
    else
        PD_Frame();
    end
end

function PD_registerCloseButton()
    local PD_CloseBtn = CreateFrame("Button", "PulseDkpCloseButton",
                                    PulseDkpMainFrame, "UIPanelButtonTemplate");
    PD_CloseBtn:SetPoint("TOPRIGHT", 1, 17);
    PD_CloseBtn:SetSize(20, 20);
    PD_CloseBtn:SetText("X");

    PD_CloseBtn:SetScript("OnMouseUp", function(self, button) PD_Close(); end);
end
function PD_Close()
    PulseDkpMainFrame:Hide();
    ns:CloseRollFrame();
end
function PD_addTitleFrame()
    local PD_T = CreateFrame("Frame", "PulseDkpTitleFrame", PulseDkpMainFrame);
    PD_T:SetSize(PulseDkpMainFrame:GetWidth(), 30);
    PD_T:SetPoint("TOPLEFT", 0, 0);

    local eb =
        PD_T:CreateFontString("PD_TitleFont", "OVERLAY", "GameFontNormal");
    eb:SetFont("Fonts\\FRIZQT__.TTF", 20);
    eb:SetPoint("TOPLEFT", 10, -10);
    eb:SetWidth(200);
    eb:SetJustifyH("LEFT");
    eb:SetWordWrap(false);
    eb:SetText("Pulse Dkp assistant");

end
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
    PD_addNewRaidDropDown();

end

function PD_addNewRaidDropDown()
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

function PD_addCurrentRaidFrame()
    local PD_CurrentRaid = CreateFrame("Frame", "PulseDkpCurrentRaidFrame",
                                       PulseDkpMainFrame);
    PD_CurrentRaid:SetSize(PulseDkpMainFrame:GetWidth(), 200);
    PD_CurrentRaid:SetPoint("TOPLEFT", 0, -40);

    -- header
    local fs = PD_CurrentRaid:CreateFontString("PulseDkpCurrentRaid_TitleFont",
                                               "OVERLAY", "GameFontNormal");
    fs:SetFont("Fonts\\FRIZQT__.TTF", 14);
    fs:SetPoint("TOPLEFT", 10, -10);
    fs:SetWidth(PD_CurrentRaid:GetWidth() - 100);
    fs:SetJustifyH("LEFT");
    fs:SetWordWrap(false);

    -- raid date
    local fsRd = PD_CurrentRaid:CreateFontString("PulseDkpCurrentRaid_RaidDate",
                                                 "OVERLAY", "GameFontNormal");
    fsRd:SetFont("Fonts\\FRIZQT__.TTF", 12);
    fsRd:SetPoint("TOPLEFT", 10, -40);
    fsRd:SetWidth(PD_CurrentRaid:GetWidth() - 100);
    fsRd:SetJustifyH("LEFT");
    fsRd:SetWordWrap(false);
    fsRd:SetText("Raid date:");

    -- start time
    local fsRStart = PD_CurrentRaid:CreateFontString(
                         "PulseDkpCurrentRaid_RaidStart", "OVERLAY",
                         "GameFontNormal");
    fsRStart:SetFont("Fonts\\FRIZQT__.TTF", 12);
    fsRStart:SetPoint("TOPLEFT", 10, -60);
    fsRStart:SetWidth(PD_CurrentRaid:GetWidth() - 100);
    fsRStart:SetJustifyH("LEFT");
    fsRStart:SetWordWrap(false);
    fsRStart:SetText("Started on:");

    -- end time
    local fsRS = PD_CurrentRaid:CreateFontString(
                     "PulseDkpCurrentRaid_RaidStatus", "OVERLAY",
                     "GameFontNormal");
    fsRS:SetFont("Fonts\\FRIZQT__.TTF", 12);
    fsRS:SetPoint("TOPLEFT", 10, -80);
    fsRS:SetWidth(PD_CurrentRaid:GetWidth() - 100);
    fsRS:SetJustifyH("LEFT");
    fsRS:SetWordWrap(false);
    fsRS:SetText("Status:");

    -- start raid btn   
    local PD_StartRaidBtn = CreateFrame("Button", "PulseDkpStartRaidButton",
                                        PulseDkpCurrentRaidFrame,
                                        "UIPanelButtonTemplate");
    PD_StartRaidBtn:SetPoint("TOPRIGHT", -10, -10);
    PD_StartRaidBtn:SetSize(60, 20);
    PD_StartRaidBtn:SetText("Start raid");

    PD_StartRaidBtn:SetScript("OnMouseUp", function(self, button)
        ns:StartRaid();
        PulseDkpStartRaidButton:Hide();
        PulseDkpEndRaidButton:Show();
        PD_BindCurrentRaidDetails();
    end);
    -- end raid btn
    local PD_EndRaidBtn = CreateFrame("Button", "PulseDkpEndRaidButton",
                                      PulseDkpCurrentRaidFrame,
                                      "UIPanelButtonTemplate");
    PD_EndRaidBtn:SetPoint("TOPRIGHT", -10, -10);
    PD_EndRaidBtn:SetSize(60, 20);
    PD_EndRaidBtn:SetText("End raid");
    PD_EndRaidBtn:Hide();
    PD_EndRaidBtn:SetScript("OnMouseUp", function(self, button)
        ns:EndRaid();
        PD_BindCurrentRaidDetails();
        PulseDkpEndRaidButton:Hide();
        PulseDkpDoneButton:Show();
    end);
    -- done btn
    local PD_RaidDoneButton = CreateFrame("Button", "PulseDkpDoneButton",
                                          PulseDkpCurrentRaidFrame,
                                          "UIPanelButtonTemplate");
    PD_RaidDoneButton:SetPoint("TOPRIGHT", -10, -10);
    PD_RaidDoneButton:SetSize(60, 20);
    PD_RaidDoneButton:SetText("Done");
    PD_RaidDoneButton:Hide();
    PD_RaidDoneButton:SetScript("OnMouseUp", function(self, button)
        Pulse_DKP.currentRaid = nil;
        selectedRaid = nil;
        PulseDkpLoadLastButton:SetEnabled(ns:GetLastUnfinishedRaid() ~= nil);
        PulseDkpNewButton:SetEnabled(false);
        UIDropDownMenu_SetText(PulseDkpNewRaidDropDown, "Select a raid..")
        PD_CurrentRaid:Hide();
        PulseDkpCurrentRaidFrame:Hide();
        PulseDkpStartRaidButton:Show();
        PulseDkpDoneButton:Hide();
        PulseDkpNewRaidFrame:Show();
    end);

    -- event console header
    local ech = PD_CurrentRaid:CreateFontString("PulseDkpEventConsoleHeader",
                                                "OVERLAY", "GameFontNormal");
    ech:SetFont("Fonts\\FRIZQT__.TTF", 14);
    ech:SetPoint("TOPLEFT", 10, -110);
    ech:SetWidth((PulseDkpMainFrame:GetWidth() / 2) - 10);
    ech:SetJustifyH("CENTER");
    ech:SetWordWrap(false);
    ech:SetText("Drops this raid");
    -- event console
    -- drops
    local sf = CreateFrame("ScrollFrame", "PulseDkpDropsFrame",
                           PulseDkpCurrentRaidFrame,
                           "UIPanelScrollFrameTemplate");
    sf:SetPoint("TOPLEFT", 10, -140);
    sf:SetSize((PulseDkpMainFrame:GetWidth() / 2 - 37), 200);

    local dropsHtml = CreateFrame("SimpleHTML", "PulseDkpDropsHtml",
                                  PulseDkpDropsFrame);
    dropsHtml:SetSize(sf:GetSize());
    dropsHtml:SetFontObject("ChatFontNormal");
    -- dropsHtml:SetScript("OnHyperlinkClick", PD_LootLinkClicked);
    sf:SetScrollChild(dropsHtml)

    -- winners

    local PulseDkpLootWinnersFrame = CreateFrame("ScrollFrame",
                                                 "PulseDkpLootWinnersFrame",
                                                 PulseDkpCurrentRaidFrame,
                                                 "UIPanelScrollFrameTemplate");
    PulseDkpLootWinnersFrame:SetPoint("TOPLEFT", 10, -375);
    PulseDkpLootWinnersFrame:SetSize((PulseDkpMainFrame:GetWidth() / 2 - 37),
                                     180);
    local PulseDkpWinnersHtml = CreateFrame("SimpleHTML", "PulseDkpWinnersHtml",
                                            PulseDkpLootWinnersFrame);
    PulseDkpWinnersHtml:SetSize(sf:GetSize());
    PulseDkpWinnersHtml:SetFontObject("ChatFontNormal");
    PulseDkpWinnersHtml:SetScript("OnHyperlinkClick", PD_WinnerLinkClicked);
    PulseDkpLootWinnersFrame:SetScrollChild(PulseDkpWinnersHtml);
    local ech = PD_CurrentRaid:CreateFontString(
                    "PulseDkpRollWInnersConsoleHeader", "OVERLAY",
                    "GameFontNormal");
    ech:SetFont("Fonts\\FRIZQT__.TTF", 14);
    ech:SetPoint("TOPLEFT", 10, -355);
    ech:SetWidth((PulseDkpMainFrame:GetWidth() / 2) - 10);
    ech:SetJustifyH("CENTER");
    ech:SetWordWrap(false);
    ech:SetText("Winners this raid");
    -- raiders header
    local raidersHeader = PD_CurrentRaid:CreateFontString(
                              "PulseDkpEventRaidersHeader", "OVERLAY",
                              "GameFontNormal");
    raidersHeader:SetFont("Fonts\\FRIZQT__.TTF", 14);
    raidersHeader:SetPoint("TOPLEFT", (PulseDkpMainFrame:GetWidth() / 2), -110);
    raidersHeader:SetWidth((PulseDkpMainFrame:GetWidth() / 2) - 10);
    raidersHeader:SetJustifyH("CENTER");
    raidersHeader:SetWordWrap(false);
    raidersHeader:SetText("Paricipants this raid");
    -- raiders
    local rf = CreateFrame("ScrollFrame", "PulseDkpRaidersFrame",
                           PulseDkpCurrentRaidFrame,
                           "UIPanelScrollFrameTemplate");
    rf:SetPoint("TOPLEFT", 10 + (PulseDkpMainFrame:GetWidth() / 2), -140);
    rf:SetSize((PulseDkpMainFrame:GetWidth() / 2 - 37),
               PulseDkpMainFrame:GetHeight() - 185);

    -- EditBox
    local rb =
        CreateFrame("EditBox", "PulseDkpRaidersBox", PulseDkpRaidersFrame);
    rb:SetSize(sf:GetSize());
    rb:SetMultiLine(true);
    rb:SetAutoFocus(false); -- dont automatically focus
    rb:SetEnabled(false);
    rb:SetFontObject("ChatFontNormal");
    -- eb:SetScript("OnEscapePressed", function() f:Hide() end)
    rf:SetScrollChild(rb)
    PD_CurrentRaid:Hide();
end
function PD_LoadLastClicked()
    Pulse_DKP.currentRaid = ns:GetLastUnfinishedRaid();
    if (Pulse_DKP.currentRaid == nil) then return; end
    ns:SetCurrentRaid(Pulse_DKP.currentRaid);
    PD_BindCurrentRaidDetails();
    PulseDkpNewRaidFrame:Hide();
    if (Pulse_DKP.currentRaid.startedOn ~= nil) then
        PulseDkpStartRaidButton:Hide();
        PulseDkpEndRaidButton:Show();
        ns:RegisterLootReady();
    end
    PulseDkpCurrentRaidFrame:Show();
end
function PD_BindCurrentRaidDetails()
    if Pulse_DKP.currentRaid == nil then return; end
    if Pulse_DKP.currentRaid.name ~= nil then
        PulseDkpCurrentRaid_TitleFont:SetText(
            "Current raid details for:    " .. Pulse_DKP.currentRaid.name);
    end
    if (PulseDkpCurrentRaid_RaidStatus) then
        if (Pulse_DKP.currentRaid.closedOn ~= nil) then
            PulseDkpCurrentRaid_RaidStatus:Show();
            PulseDkpCurrentRaid_RaidStatus:SetText(
                "Raid ended on:  " .. Pulse_DKP.currentRaid.closedOn .. " UTC");
        else
            PulseDkpCurrentRaid_RaidStatus:Hide();
        end
    end

    if (Pulse_DKP.currentRaid.date ~= nil) then
        PulseDkpCurrentRaid_RaidDate:SetText(
            "Raid date:        " .. Pulse_DKP.currentRaid.date);
    end
    if (Pulse_DKP.currentRaid.startedOn ~= nil) then
        PulseDkpCurrentRaid_RaidStart:SetText(
            "Raid started on:        " .. Pulse_DKP.currentRaid.startedOn ..
                " UTC");
    else
        PulseDkpCurrentRaid_RaidStart:SetText(
            "Raid haven't started yet - good luck!");
    end
    PD_AddWinnersToFrame();
    PD_addDropsToFrame();
    PD_addRaidersToFrame();
end
function PD_AddWinnersToFrame()
    local h = '<html><body>';
    if Pulse_DKP.currentRaid ~= nil and Pulse_DKP.currentRaid.lootWinners ~= nil then
        for i = 1, #Pulse_DKP.currentRaid.lootWinners do
            local d = Pulse_DKP.currentRaid.lootWinners[i];
            local linktext = d.item.name .. '//';
            linktext = linktext .. d.mobid;
            h = h .. "<p><a href='" .. linktext .. "'>" .. d.chars .. ' won ' ..
                    d.itemLink .. "</a></p>";

        end
    end

    h = h .. '</body></html>';
    PulseDkpWinnersHtml:SetText(h);
end
function PD_addDropsToFrame()
    local h = '<html><body>';
    if Pulse_DKP.currentRaid ~= nil and Pulse_DKP.currentRaid.drops ~= nil then
        for i = 1, #Pulse_DKP.currentRaid.drops do
            local d = Pulse_DKP.currentRaid.drops[i];
            local linktext = d.item.item .. '//';
            local m = Pulse_DKP.currentRaid.drops[i].mob;
            if (m ~= nil and m.id ~= nil) then
                linktext = linktext .. m.id;
            end

            h = h .. "<p><a href='" .. linktext .. "'>" .. d.item.item ..
                    "</a></p>";

        end
    end

    h = h .. '</body></html>';
    PulseDkpDropsHtml:SetText(h);
end

function PD_addRaidersToFrame()

    local added = {};
    local h = '';
    if Pulse_DKP.currentRaid ~= nil and Pulse_DKP.currentRaid.startingChars ~=
        nil then
        for i = 1, #Pulse_DKP.currentRaid.startingChars do
            local d = Pulse_DKP.currentRaid.startingChars[i];
            added[d.name] = true;
            h = h .. i .. ': ' .. d.name .. ' (present from the start)\n';
        end
    end

    if Pulse_DKP.currentRaid ~= nil and Pulse_DKP.currentRaid.drops ~= nil then
        for i = 1, #Pulse_DKP.currentRaid.drops do
            local drop = Pulse_DKP.currentRaid.drops[i];
            if drop ~= nil and drop.chars ~= nil then
                for x = 1, #drop.chars do
                    local char = drop.chars[x];
                    if added[char.name] == nil then
                        added[char.name] = true;
                        h = h .. i .. ': ' .. char.name .. '\n';
                    end
                end
            end
        end
    end
    -- print('raiders'..h);
    PulseDkpRaidersBox:SetText(h);
end

function PD_WinnerLinkClicked(...)
    local self, link, text, button = ...;

    if (link == nil) then return; end

    local name, mobid = link:match("(.*)//(.*)");
    for i = 1, #Pulse_DKP.currentRaid.lootWinners do
        local loot = Pulse_DKP.currentRaid.lootWinners[i];
        if (loot.mobid == mobid and loot.item.name == name) then
            ns:OpenEditFrame(loot.itemLink,
                             {id = loot.mobid, name = loot.mobname}, loot.chars);
            break
        end
    end
end

function PD_AddLPImportFrame()
    if not PulseDkpLPImportFrame then
        local PulseDkpLPImportFrame = CreateFrame("Frame",
                                                  "PulseDkpLPImportFrame",
                                                  UIParent);
        PulseDkpLPImportFrame:SetPoint("CENTER");
        PulseDkpLPImportFrame:SetSize(600, 400);

        PulseDkpLPImportFrame:SetBackdrop(
            {
                bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
                edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
                edgeSize = 16,
                insets = {left = 0, right = 0, top = 0, bottom = 0}
            });
        PulseDkpLPImportFrame:SetBackdropBorderColor(0, .44, .87, 0.5); -- darkblue
        tinsert(UISpecialFrames, PulseDkpLPImportFrame:GetName());

        local title = PulseDkpLPImportFrame:CreateFontString("PD_RollTitleFont",
                                                             "OVERLAY",
                                                             "GameFontNormal");
        title:SetFont("Fonts\\FRIZQT__.TTF", 14);
        title:SetPoint("TOPLEFT", 10, -10);
        title:SetWidth(PulseDkpLPImportFrame:GetWidth());
        title:SetJustifyH("LEFT");
        title:SetWordWrap(false);
        title:SetText("Paste LP Json below:");
    end

    local sf = CreateFrame("ScrollFrame", "PulseDkpLPImportFrameScrollFrame",
                           PulseDkpLPImportFrame, "UIPanelScrollFrameTemplate")
    sf:SetPoint("TOPLEFT", 10, -30);
    sf:SetSize(560, 335);
    -- EditBox
    local eb = CreateFrame("EditBox", "PulseDkpLPImportFrameScrollFrameEditBox",
                           PulseDkpLPImportFrameScrollFrame)
    eb:SetSize(sf:GetSize())
    eb:SetMultiLine(true);
    eb:SetAutoFocus(true);
    eb:SetFontObject("ChatFontNormal")
    eb:SetScript("OnEscapePressed", function() PulseDkpLPImportFrame:Hide() end)
    sf:SetScrollChild(eb)

    local PulseDkpImportBtn = CreateFrame("Button", "PulseDkpImportBtn",
                                          PulseDkpLPImportFrame,
                                          "UIPanelButtonTemplate");
    PulseDkpImportBtn:SetPoint("BOTTOMRIGHT", -5, 5);
    PulseDkpImportBtn:SetSize(75, 30);
    PulseDkpImportBtn:SetText("Import");
    PulseDkpImportBtn:SetScript("OnMouseUp", function()
        ns:ParseLPStandings(PulseDkpLPImportFrameScrollFrameEditBox:GetText());
        PulseDkpLPImportFrame:Hide();
    end);

    PulseDkpLPImportFrame:Show();

end
