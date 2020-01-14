local _, ns = ...;
local jsn = _G["json"];
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
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", 
        edgeSize = 16,
        insets = { left = 0, right = 0, top =0, bottom = 0 },
    });
    PulseDkpMainFrame:SetBackdropBorderColor(0, .44, .87, 0.5); -- darkblue
    
    PD_registerDraggable();
    PD_registerResizeable();
    PD_registerCloseButton();
    PD_addTitleFrame();
    PD_addNewRaidFrame();
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
function PD_addNewRaidFrame()
    local PD_NewRaid=CreateFrame("Frame","PulseDkpNewRaidFrame",PulseDkpMainFrame);
    PD_NewRaid:SetSize(PulseDkpMainFrame:GetWidth(),200);
    PD_NewRaid:SetPoint("TOPLEFT",0,-40);

    local fs=PD_NewRaid:CreateFontString("PulseDkpNewRaid_TitleFont","OVERLAY" , "GameFontNormal" );
    fs:SetFont("Fonts\\FRIZQT__.TTF",12);
    fs:SetPoint("TOPLEFT",10,-10);
    fs:SetWidth(200);
    fs:SetJustifyH("LEFT");
    fs:SetWordWrap(false);    
    fs:SetText("Create a new raid:");

    local PD_NewRaidBtn=CreateFrame("Button", "PulseDkpNewButton", PulseDkpNewRaidFrame,"UIPanelButtonTemplate");    
    PD_NewRaidBtn:SetPoint("TOPLEFT",200, -50);
    PD_NewRaidBtn:SetSize(60, 20);
    PD_NewRaidBtn:SetText("Create");

    PD_NewRaidBtn:SetScript("OnMouseUp", function(self, button)
        print("new raid");
        
    end);	
    PD_addNewRaidDropDown();

end
local selectedRaid="nothing";
function PD_addNewRaidDropDown()
    if PulseDkpNewRaidDropDown then
        return ;
    end
    -- Create the dropdown, and configure its appearance
    local dropdown = CreateFrame("Frame", "PulseDkpNewRaidDropDown", PulseDkpNewRaidFrame, "UIDropDownMenuTemplate");
    dropdown:SetPoint("TOPLEFT", 10,-30);
    UIDropDownMenu_SetWidth(dropdown, 200);
    UIDropDownMenu_SetText(dropdown, "Select a raid..")

    -- Create and bind the initialization function to the dropdown menu
    UIDropDownMenu_Initialize(dropdown, function(self,level)
        for i=1, #Pulse_DKP.availableRaids do            
            local raid=Pulse_DKP.availableRaids[i];
            if raid ~=nil and raid.enabled==true then                
                local info = UIDropDownMenu_CreateInfo();
                info.text, info.arg1 =raid.name, raid.name;                
                info.checked =false;
                if selectedRaid==raid.name then
                    info.checked=true;
                end
                info.func= function() 
                    selectedRaid=raid.name; 
                    UIDropDownMenu_SetText(dropdown, selectedRaid)  
                    print('selected:' .. raid.name)                    ;
                end;
                UIDropDownMenu_AddButton(info,level);
            end
        end            
    end);
end

