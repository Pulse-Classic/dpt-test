local _, ns = ...;
function ns:AddLPImportFrame()
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
