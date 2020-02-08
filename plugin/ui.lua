local _, ns = ...;
local selectedRaid;
local currentRaid;
local json = _G["json"];
local raiders;
local currentItem;
local rollWinner;
local rollers = {};
local currentMob = {};
local lootWinner = nil;
local newLootWinner = nil;
function PD_Frame()
    if not PulseDkpMainFrame then
        local PulseDkpMainFrame = CreateFrame("Frame", "PulseDkpMainFrame",
                                              UIParent);
        PulseDkpMainFrame:SetPoint("CENTER");
        PulseDkpMainFrame:SetSize(800, 600);

        PulseDkpMainFrame:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            edgeSize = 16,
            insets = {left = 0, right = 0, top = 0, bottom = 0}
        });
        PulseDkpMainFrame:SetBackdropBorderColor(0, .44, .87, 0.5); -- darkblue

        PD_registerDraggable();
        -- PD_registerResizeable();
        PD_registerCloseButton();
        PD_addTitleFrame();
        PD_addNewRaidFrame();
        PD_addCurrentRaidFrame();
    end

    PD_BindCurrentRaidDetails();
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
-- function PD_registerResizeable()
--    PulseDkpMainFrame:SetResizable(true)
--     PulseDkpMainFrame:SetMinResize(400, 300)

--     local rb = CreateFrame("Button", "PulseDkpResizeButton", PulseDkpMainFrame);
--     rb:SetPoint("BOTTOMRIGHT", -4, 4);
--     rb:SetSize(16, 16);

--     rb:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up");
--     rb:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight");
--     rb:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down");

--     rb:SetScript("OnMouseDown", function(self, button)
--         if button == "LeftButton" then
--             PulseDkpMainFrame:StartSizing("BOTTOMRIGHT");
--             self:GetHighlightTexture():Hide();            
--         end
--     end);
--     rb:SetScript("OnMouseUp", function(self, button)
--         PulseDkpMainFrame:StopMovingOrSizing();
--         self:GetHighlightTexture():Show();
--         PD_TitleFont:SetWidth(PulseDkpMainFrame:GetWidth());
--     end);
-- end
function PD_registerCloseButton()
    local PD_CloseBtn = CreateFrame("Button", "PulseDkpCloseButton",
                                    PulseDkpMainFrame, "UIPanelButtonTemplate");
    PD_CloseBtn:SetPoint("TOPRIGHT", 1, 17);
    PD_CloseBtn:SetSize(20, 20);
    PD_CloseBtn:SetText("X");

    PD_CloseBtn:SetScript("OnMouseUp", function(self, button)
        PulseDkpMainFrame:Hide();
        PD_CloseRollFrame();
    end);
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
        ns:CreateRaid(selectedRaid)
        currentRaid = ns:GetCurrentRaid();
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
    PD_LoadBtn:SetScript("OnMouseUp", function(self, button)
        currentRaid = ns:GetLastUnfinishedRaid();
        if (currentRaid == nil) then return; end
        ns:SetCurrentRaid(currentRaid);
        PD_BindCurrentRaidDetails();
        PulseDkpNewRaidFrame:Hide();
        if (currentRaid.startedOn ~= nil) then
            PulseDkpStartRaidButton:Hide();
            PulseDkpEndRaidButton:Show();
            ns:RegisterLootReady();
        end
        PulseDkpCurrentRaidFrame:Show();
    end);
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
        currentRaid = nil;
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

function PD_BindCurrentRaidDetails()
    currentRaid = ns:GetCurrentRaid();

    if currentRaid == nil then return; end
    if currentRaid.name ~= nil then
        PulseDkpCurrentRaid_TitleFont:SetText(
            "Current raid details for:    " .. currentRaid.name);
    end
    if (currentRaid.closedOn ~= nil) then
        PulseDkpCurrentRaid_RaidStatus:Show();
        PulseDkpCurrentRaid_RaidStatus:SetText(
            "Raid ended on:  " .. currentRaid.closedOn .. " UTC");
    else
        PulseDkpCurrentRaid_RaidStatus:Hide();
    end

    if (currentRaid.date ~= nil) then
        PulseDkpCurrentRaid_RaidDate:SetText(
            "Raid date:        " .. currentRaid.date);
    end
    if (currentRaid.startedOn ~= nil) then
        PulseDkpCurrentRaid_RaidStart:SetText(
            "Raid started on:        " .. currentRaid.startedOn .. " UTC");
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
    if currentRaid ~= nil and currentRaid.lootWinners ~= nil then
        for i = 1, #currentRaid.lootWinners do
            local d = currentRaid.lootWinners[i];
            local linktext = d.item.name .. '//';
            local m = currentRaid.drops[i].mob;
            if (m ~= nil) then linktext = linktext .. m.id; end

            h = h .. "<p><a href='" .. linktext .. "'>" .. d.chars .. ' won ' ..
                    d.itemLink .. "</a></p>";

        end
    end

    h = h .. '</body></html>';
    PulseDkpWinnersHtml:SetText(h);
end
function PD_addDropsToFrame()
    local h = '<html><body>';
    if currentRaid ~= nil and currentRaid.drops ~= nil then
        for i = 1, #currentRaid.drops do
            local d = currentRaid.drops[i];
            local linktext = d.item.item .. '//';
            local m = currentRaid.drops[i].mob;
            if (m ~= nil) then linktext = linktext .. m.id; end

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
    if currentRaid ~= nil and currentRaid.startingChars ~= nil then
        for i = 1, #currentRaid.startingChars do
            local d = currentRaid.startingChars[i];
            added[d.name] = true;
            h = h .. i .. ': ' .. d.name .. ' (present from the start)\n';
        end
    end

    if currentRaid ~= nil and currentRaid.drops ~= nil then
        for i = 1, #currentRaid.drops do
            local drop = currentRaid.drops[i];
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

    local name, mob = link:match("(.*)//(.*)");
    for i = 1, #currentRaid.lootWinners do
        local loot = currentRaid.lootWinners[i];
        if (loot.mobid == mob and loot.item.name == name) then

            PD_OpenRollFrame(loot.itemLink,
                             {id = loot.mobid, name = loot.mobname}, loot.chars);
            break
        end
    end
    -- PD_OpenRollFrame(name, {id = mob, name = ''}, true);
end

function PD_OpenRollFrame(item, mob, winner)
    currentItem = item;
    currentMob = mob;
    lootWinner = winner;

    if not PulseDkpRollFrame then
        local PulseDkpRollFrame = CreateFrame("Frame", "PulseDkpRollFrame",
                                              UIParent);

        PulseDkpRollFrame:SetSize(400, 600);
        PulseDkpRollFrame:SetPoint('RIGHT', PulseDkpMainFrame, 400, 0);
        PulseDkpRollFrame:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            edgeSize = 16,
            insets = {left = 0, right = 0, top = 0, bottom = 0}
        });
        PulseDkpRollFrame:SetBackdropBorderColor(0, .44, .87, 0.5); -- darkblue

        -- PD_registerRollframeDraggable();
        PD_registerRollFrameCloseButton();

        local PulsDkpStartRollBtn = CreateFrame("Button", "PulsDkpStartRollBtn",
                                                PulseDkpRollFrame,
                                                'UIPanelButtonTemplate');
        PulsDkpStartRollBtn:SetText("Main spec roll");
        PulsDkpStartRollBtn:SetSize(100, 30);
        PulsDkpStartRollBtn:SetPoint('TOPLEFT', 10, -40);
        PulsDkpStartRollBtn:SetScript("OnMouseUp", function(...)
            PD_StartRoll('Main spec roll');
        end);

        local PulsDkpOffSpecRollBtn = CreateFrame("Button",
                                                  "PulsDkpOffSpecRollBtn",
                                                  PulseDkpRollFrame,
                                                  'UIPanelButtonTemplate');
        PulsDkpOffSpecRollBtn:SetText("Off spec roll");
        PulsDkpOffSpecRollBtn:SetSize(100, 30);
        PulsDkpOffSpecRollBtn:SetPoint('TOPLEFT', 110, -40);
        PulsDkpOffSpecRollBtn:SetScript("OnMouseUp", function(...)
            PD_StartRoll('Off spec roll');
        end);
        local PulsDkpEndRollBtn = CreateFrame("Button", "PulsDkpEndRollBtn",
                                              PulseDkpRollFrame,
                                              'UIPanelButtonTemplate');
        PulsDkpEndRollBtn:SetText("End roll");
        PulsDkpEndRollBtn:SetSize(60, 30);
        PulsDkpEndRollBtn:SetPoint('TOPRIGHT', -10, -40);
        PulsDkpEndRollBtn:SetScript("OnMouseUp", function(...)
            PD_EndRoll();
        end);
    end
    if (lootWinner ~= nil) then
        PulsDkpStartRollBtn:Hide();
        PulsDkpOffSpecRollBtn:Hide();
        PulsDkpEndRollBtn:Hide();
        PD_AddEditLootWinnerFrame();
    else
        PulsDkpStartRollBtn:Show();
        PulsDkpOffSpecRollBtn:Show();
        PD_AddRollersFrame();
        PD_HideEditWinnerControls();
    end
    PD_addRollFrameTitle(item);
    PulseDkpRollFrame:SetScript("OnEvent", PulseDkpRollFrame_OnEvent)
    PulseDkpRollFrame:Show();
end
function PD_StartRoll(specString)
    PulseDkpRollFrame:RegisterEvent('CHAT_MSG_SYSTEM');
    PulsDkpEndRollBtn:Show();
    rollWinner = nil;
    SendChatMessage(specString .. " for " .. currentItem, "RAID_WARNING");
end
function PD_EndRoll()
    if rollWinner ~= nil then
        local itemObj = {};
        local itemString, itemName = currentItem:match("|H(.*)|h%[(.*)%]|h");
        itemObj.itemString = itemString;
        itemObj.name = itemName;
        itemObj.time = time();
        ns:DistributeLoot(itemObj, rollWinner, currentItem, currentMob);
        SendChatMessage("Roll for " .. currentItem ..
                            " ended. Congratulations to " .. rollWinner .. "!",
                        "RAID_WARNING");
        PD_AddWinnersToFrame();

    else
        SendChatMessage("Roll for " .. currentItem .. " ended. No winner.",
                        "RAID_WARNING");
    end
    rollWinner = nil;
    currentItem = nil;
    currentMob = nil;
    rollers = {};
    PD_UpdateRollersHtml();
    PulsDkpEndRollBtn:Hide();
    PulsDkpStartRollBtn:Hide();
    PulsDkpOffSpecRollBtn:Hide();
    PulseDkpRollFrame:UnregisterEvent('CHAT_MSG_SYSTEM');
end
function PulseDkpRollFrame_OnEvent(self, event, ...)

    if (event == "CHAT_MSG_SYSTEM") then
        local msg = ...;
        if (msg:match("(.*)%srolls%s(.*)") ~= nil) then
            PD_UpdateParseRollString(msg:match("(.*)%srolls%s(.*)"))
        end
    end
end
function PD_UpdateParseRollString(name, unparsedRoll)

    local roll, range = unparsedRoll:match("(.*)%s(.*)");

    if (range ~= '(1-100)') then return; end
    local found = false;
    for i = 1, #rollers do
        if (rollers[i].name == name) then
            found = true;
            break
        end
    end
    if (found == true) then return; end
    tinsert(rollers, {name = name, roll = roll, lp = 0});
    table.sort(rollers, PD_SortRolls);
    PD_UpdateRollersHtml();
end
function PD_SortRolls(a, b)
    if a.lp == b.lp then return a.roll > b.roll end
    return a.lp > b.lp;
end

function PD_UpdateRollersHtml()
    local html = '<html><body>';
    if rollers ~= nil then
        for i = 1, #rollers do
            local a = '<p><a href="' .. rollers[i].name .. '">';

            if (rollers[i].name == rollWinner) then a = a .. '>>>'; end
            a = a .. rollers[i].name .. ' rolled ' .. rollers[i].roll ..
                    ' with a loot priority of (' .. rollers[i].lp .. ')</a></p>';
            html = html .. a
        end
    end
    html = html .. '</body></html>';
    PulseDkpRollersHtml:SetText(html);

end
function PD_AddEditLootWinnerFrame()
    if not PulseDkpEditWinnerFrame then
        local PulseDkpEditFrameTitle = PulseDkpRollFrame:CreateFontString(
                                           "PulseDkpEditFrameTitle", "OVERLAY",
                                           "GameFontNormal");
        PulseDkpEditFrameTitle:SetFont("Fonts\\FRIZQT__.TTF", 14);
        PulseDkpEditFrameTitle:SetPoint("TOPLEFT", 10, -30);
        PulseDkpEditFrameTitle:SetWidth(PulseDkpRollFrame:GetWidth() - 10);
        PulseDkpEditFrameTitle:SetJustifyH("CENTER");
        PulseDkpEditFrameTitle:SetWordWrap(false);

        local PulseDkpEditFrameCurrentWinner =
            PulseDkpRollFrame:CreateFontString("PulseDkpEditFrameCurrentWinner",
                                               "OVERLAY", "GameFontNormal");
        PulseDkpEditFrameCurrentWinner:SetFont("Fonts\\FRIZQT__.TTF", 12);
        PulseDkpEditFrameCurrentWinner:SetPoint("TOPLEFT", 10, -50);
        PulseDkpEditFrameCurrentWinner:SetWidth(
            PulseDkpRollFrame:GetWidth() - 10);
        PulseDkpEditFrameCurrentWinner:SetJustifyH("LEFT");
        PulseDkpEditFrameCurrentWinner:SetWordWrap(false);

        local PulseDkpEditFrameSelectNewWinner =
            PulseDkpRollFrame:CreateFontString(
                "PulseDkpEditFrameSelectNewWinner", "OVERLAY", "GameFontNormal");
        PulseDkpEditFrameSelectNewWinner:SetFont("Fonts\\FRIZQT__.TTF", 12);
        PulseDkpEditFrameSelectNewWinner:SetPoint("TOPLEFT", 10, -70);
        PulseDkpEditFrameSelectNewWinner:SetWidth(
            PulseDkpRollFrame:GetWidth() - 10);
        PulseDkpEditFrameSelectNewWinner:SetJustifyH("LEFT");
        PulseDkpEditFrameSelectNewWinner:SetWordWrap(false);
        PulseDkpEditFrameSelectNewWinner:SetText("Select new winner:")

        local PulseDkSetNewLootWinner = CreateFrame("Button",
                                                    "PulseDkSetNewLootWinner",
                                                    PulseDkpRollFrame,
                                                    "UIPanelButtonTemplate");
        PulseDkSetNewLootWinner:SetPoint("TOPLEFT", 280, -90);
        PulseDkSetNewLootWinner:SetSize(110, 30);
        PulseDkSetNewLootWinner:SetText("Set new winner");
        PulseDkSetNewLootWinner:SetEnabled(lootWinner ~= nil);
        PulseDkSetNewLootWinner:SetScript("OnMouseUp", function(self, button)
            if not StaticPopupDialogs["CONFIRM_NEW_LOOT_WINNER"] then
                StaticPopupDialogs["CONFIRM_NEW_LOOT_WINNER"] =
                    {
                        text = "Are you sure you want to update the loot winner?",
                        button1 = "Yes",
                        button2 = "No",
                        OnAccept = function()
                            PD_SetNewLootWinner();
                        end,
                        timeout = 0,
                        whileDead = true,
                        hideOnEscape = true,
                        preferredIndex = 3 -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
                    }
            end
            StaticPopup_Show("CONFIRM_NEW_LOOT_WINNER");
        end);
    end

    PD_AddNewLootWinnerDropDown();
    if (lootWinner ~= nil) then
        PulseDkpEditFrameCurrentWinner:SetText("Current winner: " .. lootWinner);
    end

    PulseDkpEditFrameTitle:SetText("Edit loot winner");
end
function PD_HideEditWinnerControls()
    PulseDkpEditFrameTitle:Hide();
    PulseDkpEditFrameCurrentWinner:Hide();
    PulseDkpEditFrameSelectNewWinner:Hide();
    PulseDkSetNewLootWinner:Hide();
    PulseDkpNewLootWinnerDropDown:Hide();
end
function PD_SetNewLootWinner()
    if currentRaid == nil then return; end

    for i = 1, #currentRaid.lootWinners do
        local win = currentRaid.lootWinners[i];
        if win.mobid == currentMob.id and win.itemLink == currentItem and
            win.chars == lootWinner then
            currentRaid.lootWinners[i].chars = newLootWinner;
        end
    end

    newLootWinner = nil;
    lootWinner = nil;
    PD_AddWinnersToFrame();
    PD_CloseRollFrame();
end
function PD_AddNewLootWinnerDropDown()
    if currentRaid == nil then return; end

    if not PulseDkpNewLootWinnerDropDown then
        -- Create the dropdown, and configure its appearance
        local PulseDkpNewLootWinnerDropDown =
            CreateFrame("Frame", "PulseDkpNewLootWinnerDropDown",
                        PulseDkpRollFrame, "UIDropDownMenuTemplate");
        PulseDkpNewLootWinnerDropDown:SetPoint("TOPLEFT", -7, -90);
        UIDropDownMenu_SetWidth(PulseDkpNewLootWinnerDropDown, 200);
        UIDropDownMenu_SetText(PulseDkpNewLootWinnerDropDown, lootWinner)
    end
    -- Create and bind the initialization function to the dropdown menu
    local itemString, itemName = currentItem:match("|H(.*)|h%[(.*)%]|h");
    for i = 1, #currentRaid.drops do
        local d = currentRaid.drops[i];

        if d.mob.id == currentMob.id and d.item.item == itemName then
            UIDropDownMenu_Initialize(PulseDkpNewLootWinnerDropDown,
                                      function(self, level)
                for index, value in pairs(d.chars) do
                    local char = value.name;
                    local info = UIDropDownMenu_CreateInfo();
                    info.text, info.arg1 = char, char;
                    info.checked = char == lootWinner;
                    info.func = function()
                        newLootWinner = char;
                        UIDropDownMenu_SetText(PulseDkpNewLootWinnerDropDown,
                                               newLootWinner);
                    end;
                    UIDropDownMenu_AddButton(info, level);
                end
            end);
            return;
        end
    end

end
-- function PD_registerRollframeDraggable()
--     -- Movable
--     PulseDkpRollFrame:SetMovable(true);
--     PulseDkpRollFrame:SetClampedToScreen(true);
--     PulseDkpRollFrame:SetScript("OnMouseDown", function(self, button)
--         if button == "LeftButton" then self:StartMoving() end
--     end);
--     PulseDkpRollFrame:SetScript("OnMouseUp",
--                                 PulseDkpRollFrame.StopMovingOrSizing);
-- end
function PD_AddRollersFrame()
    local ech = PulseDkpRollFrame:CreateFontString(
                    "PulseDkpRollersConsoleHeader", "OVERLAY", "GameFontNormal");
    ech:SetFont("Fonts\\FRIZQT__.TTF", 12);
    ech:SetPoint("TOPLEFT", 10, -80);
    ech:SetWidth((PulseDkpMainFrame:GetWidth() / 2) - 10);
    ech:SetJustifyH("CENTER");
    ech:SetWordWrap(false);
    ech:SetText("Rollers:");

    local sf = CreateFrame("ScrollFrame", "PulseDkpRollersScrollFrame",
                           PulseDkpRollFrame, "UIPanelScrollFrameTemplate");
    sf:SetPoint("TOPLEFT", 10, -100);
    sf:SetSize((PulseDkpRollFrame:GetWidth() - 35), 200);

    local PulseDkpRollersHtml = CreateFrame("SimpleHTML", "PulseDkpRollersHtml",
                                            PulseDkpRollFrame);
    PulseDkpRollersHtml:SetSize(sf:GetSize());
    PulseDkpRollersHtml:SetFontObject("ChatFontNormal");
    PulseDkpRollersHtml:SetScript("OnHyperlinkClick", PD_RollerLinkClicked);
    sf:SetScrollChild(PulseDkpRollersHtml)
end
function PD_RollerLinkClicked(...)
    local self, link, text, button = ...;
    if (link == nil) then return; end
    rollWinner = link;
    PD_UpdateRollersHtml();
end
function PD_registerRollFrameCloseButton()
    local PD_CloseBtn = CreateFrame("Button", "PulseDkpRollFrameCloseButton",
                                    PulseDkpRollFrame, "UIPanelButtonTemplate");
    PD_CloseBtn:SetPoint("TOPRIGHT", 1, 17);
    PD_CloseBtn:SetSize(20, 20);
    PD_CloseBtn:SetText("X");

    PD_CloseBtn:SetScript("OnMouseUp",
                          function(self, button) PD_CloseRollFrame(); end);
end
function PD_CloseRollFrame()
    if (PulseDkpRollFrame) then PulseDkpRollFrame:Hide(); end
end
function PD_addRollFrameTitle(item)
    if (not PulseDkpRollTitleFrame) then
        local PD_T = CreateFrame("Frame", "PulseDkpRollTitleFrame",
                                 PulseDkpRollFrame);
        PD_T:SetSize(PulseDkpRollFrame:GetWidth(), 30);
        PD_T:SetPoint("TOPLEFT", 0, 0);

        local PD_RollTitleFont = PD_T:CreateFontString("PD_RollTitleFont",
                                                       "OVERLAY",
                                                       "GameFontNormal");
        PD_RollTitleFont:SetFont("Fonts\\FRIZQT__.TTF", 16);
        PD_RollTitleFont:SetPoint("TOPLEFT", 10, -10);
        PD_RollTitleFont:SetWidth(PulseDkpRollFrame:GetWidth());
        PD_RollTitleFont:SetJustifyH("LEFT");
        PD_RollTitleFont:SetWordWrap(false);
    end
    PD_RollTitleFont:SetText(item);

end
