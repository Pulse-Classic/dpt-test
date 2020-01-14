function PD_Frame()
    if PulseDkpMainFrame then
        PulseDkpMainFrame:Show();
        return
    end
	local PulseDkpMainFrame = CreateFrame("Frame", "PulseDkpMainFrame", UIParent);
    PulseDkpMainFrame:SetPoint("CENTER");
    PulseDkpMainFrame:SetSize(800, 600);

    PulseDkpMainFrame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", -- this one is neat
        edgeSize = 16,
        insets = { left = 0, right = 0, top =0, bottom = 0 },
    });
    PulseDkpMainFrame:SetBackdropBorderColor(0, .44, .87, 0.5); -- darkblue
    
    PD_registerDraggable();
    PD_registerResizeable();
    PD_registerCloseButton();
    PD_addTitleFrame();
    PulseDkpMainFrame:Show();

end
function PD_registerDraggable()
        -- Movable
        PulseDkpMainFrame:SetMovable(true);
        PulseDkpMainFrame:SetClampedToScreen(true);
        PulseDkpMainFrame:SetScript("OnMouseDown", function(self, button)
            if button == "LeftButton" then
                self:StartMoving()
            end
        end);
        PulseDkpMainFrame:SetScript("OnMouseUp", PulseDkpMainFrame.StopMovingOrSizing);
end
function PD_registerResizeable()
    	-- Resizable
    PulseDkpMainFrame:SetResizable(true)
    PulseDkpMainFrame:SetMinResize(400, 300)
    
    local rb = CreateFrame("Button", "PulseDkpResizeButton", PulseDkpMainFrame);
    rb:SetPoint("BOTTOMRIGHT", -4, 4);
    rb:SetSize(16, 16);

    rb:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up");
    rb:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight");
    rb:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down");

    rb:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then
            PulseDkpMainFrame:StartSizing("BOTTOMRIGHT");
            self:GetHighlightTexture():Hide();            
        end
    end);
    rb:SetScript("OnMouseUp", function(self, button)
        PulseDkpMainFrame:StopMovingOrSizing();
        self:GetHighlightTexture():Show();
        PD_TitleFont:SetWidth(PulseDkpMainFrame:GetWidth());
    end);
end
function PD_registerCloseButton()
    local PD_CloseBtn=CreateFrame("Button", "PulseDkpCloseButton", PulseDkpMainFrame,"UIPanelButtonTemplate");
    PD_CloseBtn:SetPoint("TOPRIGHT", 1, 17);
    PD_CloseBtn:SetSize(20, 20);
    PD_CloseBtn:SetText("X");

    PD_CloseBtn:SetScript("OnMouseUp", function(self, button)
        PulseDkpMainFrame:Hide();        
    end);	
end
function PD_addTitleFrame()
    local PD_T=CreateFrame("Frame", "PulseDkpTitleFrame", PulseDkpMainFrame);
    PD_T:SetSize(PulseDkpMainFrame:GetWidth(),30);
    PD_T:SetPoint("TOPLEFT",0,0);
     
    local eb=PD_T:CreateFontString("PD_TitleFont","OVERLAY" , "GameFontNormal" );
    eb:SetFont("Fonts\\FRIZQT__.TTF",20);
    eb:SetPoint("TOPLEFT",10,-10);
    eb:SetWidth(200);
    eb:SetJustifyH("LEFT");
    eb:SetWordWrap(false);    
    eb:SetText("Pulse Dkp assistant");
    
end