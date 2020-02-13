local _, ns = ...;
local rollers = {};

function PD_OpenRollFrame(item, mob, winner)
    Pulse_DKP.currentItem = item;
    Pulse_DKP.currentMob = mob;
    Pulse_DKP.lootWinner = winner;

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

        ns:RegisterFrameDraggable(PulseDkpRollFrame);
        ns:RegisterRollFrameCloseButton();
        tinsert(UISpecialFrames, PulseDkpRollFrame:GetName());
        local PulsDkpStartRollBtn = CreateFrame("Button", "PulsDkpStartRollBtn",
                                                PulseDkpRollFrame,
                                                'UIPanelButtonTemplate');
        PulsDkpStartRollBtn:SetText("Main spec roll");
        PulsDkpStartRollBtn:SetSize(100, 30);
        PulsDkpStartRollBtn:SetPoint('TOPLEFT', 10, -40);
        PulsDkpStartRollBtn:SetScript("OnMouseUp", function(...)
            ns:StartRoll('Main spec roll');
        end);

        local PulsDkpOffSpecRollBtn = CreateFrame("Button",
                                                  "PulsDkpOffSpecRollBtn",
                                                  PulseDkpRollFrame,
                                                  'UIPanelButtonTemplate');
        PulsDkpOffSpecRollBtn:SetText("Off spec roll");
        PulsDkpOffSpecRollBtn:SetSize(100, 30);
        PulsDkpOffSpecRollBtn:SetPoint('TOPLEFT', 110, -40);
        PulsDkpOffSpecRollBtn:SetScript("OnMouseUp", function(...)
            ns:StartRoll('Off spec roll');
        end);
        local PulsDkpEndRollBtn = CreateFrame("Button", "PulsDkpEndRollBtn",
                                              PulseDkpRollFrame,
                                              'UIPanelButtonTemplate');
        PulsDkpEndRollBtn:SetText("End roll");
        PulsDkpEndRollBtn:SetSize(60, 30);
        PulsDkpEndRollBtn:SetPoint('TOPRIGHT', -10, -40);
        PulsDkpEndRollBtn:SetScript("OnMouseUp", function(...)
            ns:EndRoll();
        end);
        PulseDkpRollFrame:SetScript("OnEvent", PulseDkpRollFrame_OnEvent)
    end
    PulsDkpStartRollBtn:Show();
    PulsDkpOffSpecRollBtn:Show();
    ns:AddRollersFrame();
    ns:AddRollFrameTitle(item);

    PulseDkpRollFrame:Show();
    ns:SetRollerFramePoint();
end

function ns:StartRoll(specString)
    PulseDkpRollFrame:RegisterEvent('CHAT_MSG_SYSTEM');
    PulsDkpEndRollBtn:Show();
    Pulse_DKP.rollWinner = nil;
    SendChatMessage(specString .. " for " .. Pulse_DKP.currentItem,
                    "RAID_WARNING");
end
function ns:SetRollerFramePoint()
    if PulseDkpRollFrame and PulseDkpMainFrame:IsVisible() then
        PulseDkpRollFrame:ClearAllPoints();
        PulseDkpRollFrame:SetPoint('RIGHT', PulseDkpMainFrame, 400, 0);
    end
end
function ns:EndRoll()
    if Pulse_DKP.rollWinner ~= nil then
        local itemObj = {};
        local itemString, itemName = Pulse_DKP.currentItem:match(
                                         "|H(.*)|h%[(.*)%]|h");
        itemObj.itemString = itemString;
        itemObj.name = itemName;
        itemObj.time = time();
        ns:DistributeLoot(itemObj, Pulse_DKP.rollWinner, Pulse_DKP.currentItem,
                          Pulse_DKP.currentMob);
        SendChatMessage("Roll for " .. Pulse_DKP.currentItem ..
                            " ended. Congratulations to " .. Pulse_DKP.rollWinner .. "!",
                        "RAID_WARNING");
        PD_AddWinnersToFrame();

    else
        SendChatMessage("Roll for " .. Pulse_DKP.currentItem ..
                            " ended. No winner.", "RAID_WARNING");
    end
    Pulse_DKP.rollWinner = nil;
    Pulse_DKP.currentItem = nil;
    Pulse_DKP.currentMob = nil;
    rollers = {};
    ns:UpdateRollersHtml();
    PulseDkpRollFrame:UnregisterEvent('CHAT_MSG_SYSTEM');
    PulseDkpRollFrame:Hide();
end
function PulseDkpRollFrame_OnEvent(self, event, ...)

    if (event == "CHAT_MSG_SYSTEM") then
        local msg = ...;
        if (msg:match("(.*)%srolls%s(.*)") ~= nil) then
            ns:UpdateParseRollString(msg:match("(.*)%srolls%s(.*)"))
        end
    end
end
function ns:UpdateParseRollString(name, unparsedRoll)

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
    local lp = 0;
    if Pulse_DKP.LP ~= nil and Pulse_DKP.LP[name] ~= nil then
        lp = Pulse_DKP.LP[name];
    end
    tinsert(rollers, {name = name, roll = roll, lp = lp});
    table.sort(rollers, PD_SortRolls);
    ns:UpdateRollersHtml();
end
function PD_SortRolls(a, b)
    if a.lp == b.lp then return a.roll > b.roll end
    return a.lp > b.lp;
end

function ns:UpdateRollersHtml()
    local html = '<html><body>';
    if rollers ~= nil then
        for i = 1, #rollers do
            local a = '<p><a href="' .. rollers[i].name .. '">';

            if (rollers[i].name == Pulse_DKP.rollWinner) then a = a .. '>>>'; end
            a = a .. rollers[i].name .. ' rolled ' .. rollers[i].roll ..
                    ' with a loot priority of (' .. rollers[i].lp .. ')</a></p>';
            html = html .. a
        end
    end
    html = html .. '</body></html>';
    PulseDkpRollersHtml:SetText(html);
end

function ns:RegisterFrameDraggable(frame)
    if frame == nil then return; end

    frame:SetMovable(true);
    frame:SetClampedToScreen(true);
    frame:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then self:StartMoving() end
    end);
    frame:SetScript("OnMouseUp", frame.StopMovingOrSizing);
end

function ns:AddRollersFrame()
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
    PulseDkpRollersHtml:SetScript("OnHyperlinkClick", RollerLinkClicked);
    sf:SetScrollChild(PulseDkpRollersHtml)
end
function RollerLinkClicked(...)

    local self, link, text, button = ...;
    if (link == nil) then return; end
    Pulse_DKP.rollWinner = link;
    ns:UpdateRollersHtml();
end
function ns:RegisterRollFrameCloseButton()
    local PD_CloseBtn = CreateFrame("Button", "PulseDkpRollFrameCloseButton",
                                    PulseDkpRollFrame, "UIPanelButtonTemplate");
    PD_CloseBtn:SetPoint("TOPRIGHT", 1, 17);
    PD_CloseBtn:SetSize(20, 20);
    PD_CloseBtn:SetText("X");

    PD_CloseBtn:SetScript("OnMouseUp", function(self, button)
        if (PulseDkpRollFrame) then PulseDkpRollFrame:Hide(); end
    end);
end

function ns:AddRollFrameTitle(item)
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
