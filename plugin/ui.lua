local _, ns = ...;
local selectedRaid;
local currentRaid;
function PD_Frame()
    if not PulseDkpMainFrame then        
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
            if button == "LeftButton" then
                self:StartMoving()
            end
        end);
        PulseDkpMainFrame:SetScript("OnMouseUp", PulseDkpMainFrame.StopMovingOrSizing);
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
    PD_NewRaidBtn:SetPoint("TOPLEFT",260, -30);
    PD_NewRaidBtn:SetSize(60, 30);
    PD_NewRaidBtn:SetText("Create");
    PD_NewRaidBtn:SetEnabled(false);
    PD_NewRaidBtn:SetScript("OnMouseUp", function(self, button)
        if(selectedRaid == nil) then 
            return ;
        end
        ns:CreateRaid(selectedRaid)
        currentRaid=ns:GetCurrentRaid();
        PD_BindCurrentRaidDetails();
        PulseDkpNewRaidFrame:Hide();
        PulseDkpCurrentRaidFrame:Show();
    end);	
    PD_addNewRaidDropDown();

end

function PD_addNewRaidDropDown()
    if PulseDkpNewRaidDropDown then
        return ;
    end
    -- Create the dropdown, and configure its appearance
    local dropdown = CreateFrame("Frame", "PulseDkpNewRaidDropDown", PulseDkpNewRaidFrame, "UIDropDownMenuTemplate");
    dropdown:SetPoint("TOPLEFT", 0,-30);
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
                if selectedRaid~= nil and selectedRaid==raid.name then
                    info.checked=true;
                end
                info.func= function() 
                    selectedRaid=raid.name; 
                    UIDropDownMenu_SetText(dropdown, selectedRaid)  
                    PulseDkpNewButton:SetEnabled(true);
                end;
                UIDropDownMenu_AddButton(info,level);
            end
        end            
    end);
end

function PD_addCurrentRaidFrame()
    local PD_CurrentRaid=CreateFrame("Frame","PulseDkpCurrentRaidFrame",PulseDkpMainFrame);
    PD_CurrentRaid:SetSize(PulseDkpMainFrame:GetWidth(),200);
    PD_CurrentRaid:SetPoint("TOPLEFT",0,-40);

    --header
    local fs=PD_CurrentRaid:CreateFontString("PulseDkpCurrentRaid_TitleFont","OVERLAY" , "GameFontNormal" );
    fs:SetFont("Fonts\\FRIZQT__.TTF",14);
    fs:SetPoint("TOPLEFT",10,-10);
    fs:SetWidth(PD_CurrentRaid:GetWidth()-100);
    fs:SetJustifyH("LEFT");
    fs:SetWordWrap(false);    
  

    -- raid date
    local fsRd=PD_CurrentRaid:CreateFontString("PulseDkpCurrentRaid_RaidDate","OVERLAY" , "GameFontNormal" );
    fsRd:SetFont("Fonts\\FRIZQT__.TTF",12);
    fsRd:SetPoint("TOPLEFT",10,-40);
    fsRd:SetWidth(PD_CurrentRaid:GetWidth()-100);
    fsRd:SetJustifyH("LEFT");
    fsRd:SetWordWrap(false);    
    fsRd:SetText("Raid date:");

    --start time
    local fsRStart=PD_CurrentRaid:CreateFontString("PulseDkpCurrentRaid_RaidStart","OVERLAY" , "GameFontNormal" );
    fsRStart:SetFont("Fonts\\FRIZQT__.TTF",12);
    fsRStart:SetPoint("TOPLEFT",10,-60);
    fsRStart:SetWidth(PD_CurrentRaid:GetWidth()-100);
    fsRStart:SetJustifyH("LEFT");
    fsRStart:SetWordWrap(false);    
    fsRStart:SetText("Started on:");

    -- end time
    local fsRS=PD_CurrentRaid:CreateFontString("PulseDkpCurrentRaid_RaidStatus","OVERLAY" , "GameFontNormal" );
    fsRS:SetFont("Fonts\\FRIZQT__.TTF",12);
    fsRS:SetPoint("TOPLEFT",10,-80);
    fsRS:SetWidth(PD_CurrentRaid:GetWidth()-100);
    fsRS:SetJustifyH("LEFT");
    fsRS:SetWordWrap(false);    
    fsRS:SetText("Status:");

    -- start raid btn   
    local PD_StartRaidBtn=CreateFrame("Button", "PulseDkpStartRaidButton", PulseDkpCurrentRaidFrame,"UIPanelButtonTemplate");    
    PD_StartRaidBtn:SetPoint("TOPRIGHT",-10, -10);
    PD_StartRaidBtn:SetSize(60, 20);
    PD_StartRaidBtn:SetText("Start raid");

    PD_StartRaidBtn:SetScript("OnMouseUp", function(self, button)
        ns:StartRaid();
        PulseDkpStartRaidButton:Hide();
        PulseDkpEndRaidButton:Show();
        PD_BindCurrentRaidDetails();
    end);	
    -- end raid btn
    local PD_EndRaidBtn=CreateFrame("Button", "PulseDkpEndRaidButton", PulseDkpCurrentRaidFrame,"UIPanelButtonTemplate");    
    PD_EndRaidBtn:SetPoint("TOPRIGHT",-10, -30);
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
    local PD_RaidDoneButton=CreateFrame("Button", "PulseDkpDoneButton", PulseDkpCurrentRaidFrame,"UIPanelButtonTemplate");    
    PD_RaidDoneButton:SetPoint("TOPRIGHT",-10, -10);
    PD_RaidDoneButton:SetSize(60, 20);
    PD_RaidDoneButton:SetText("Done");
    PD_RaidDoneButton:Hide();
    PD_RaidDoneButton:SetScript("OnMouseUp", function(self, button)
        currentRaid=nil;       
        selectedRaid=nil; 
        PulseDkpNewButton:SetEnabled(false);
        UIDropDownMenu_SetText(PulseDkpNewRaidDropDown, "Select a raid..")
        PD_CurrentRaid:Hide();
        PulseDkpCurrentRaidFrame:Hide();
        PulseDkpStartRaidButton:Show();
        PulseDkpDoneButton:Hide();
        PulseDkpNewRaidFrame:Show();
    end);	

    local consoleHr=PulseDkpCurrentRaidFrame:CreateLine();
    consoleHr:SetStartPoint('TOPLEFT',0, -100);
    consoleHr:SetStartPoint('TOPLEFT',PulseDkpCurrentRaidFrame:GetWidth(),-100);
    -- consoleHr:SetColorTexture(1,0,0,1)
    -- event console
    local sf = CreateFrame("ScrollFrame", "PulseDkpDropsFrame", PulseDkpCurrentRaidFrame, "UIPanelScrollFrameTemplate");    
    sf:SetPoint("TOPLEFT", 10, -120);
    sf:SetSize(PulseDkpMainFrame:GetWidth()-37, PulseDkpMainFrame:GetHeight()-165);

    -- EditBox
    local eb = CreateFrame("EditBox", "PulseDkpDropsBox", PulseDkpDropsFrame);
    eb:SetSize(sf:GetSize());
    eb:SetMultiLine(true);
    eb:SetAutoFocus(false); -- dont automatically focus
    eb:SetEnabled(false);
    eb:SetFontObject("ChatFontNormal");
    -- eb:SetScript("OnEscapePressed", function() f:Hide() end)
    sf:SetScrollChild(eb)
        
    PD_CurrentRaid:Hide();
end

function PD_BindCurrentRaidDetails()
    currentRaid=ns:GetCurrentRaid();

    if currentRaid == nil then
        return;
    end
    if currentRaid.name ~= nil then
        PulseDkpCurrentRaid_TitleFont:SetText("Current raid details for:    "..currentRaid.name); 
    end 
    if(currentRaid.closedOn~= nil) then
        PulseDkpCurrentRaid_RaidStatus:SetText("Raid ended on:  ".. currentRaid.closedOn.."UTC");
    else 
        PulseDkpCurrentRaid_RaidStatus:SetText("Status:         ".."Raid stil in progres, good luck!");
    end

    if(currentRaid.date~= nil) then
        PulseDkpCurrentRaid_RaidDate:SetText("Raid date:        ".. currentRaid.date);
    end
    if(currentRaid.startedOn~= nil) then
        PulseDkpCurrentRaid_RaidStart:SetText("Raid started on:        ".. currentRaid.startedOn.."UTC");
    else
        PulseDkpCurrentRaid_RaidStart:SetText("Raid haven't started yet - good luck!");
    end
    PD_addDropsToFrame();
end

function PD_addDropsToFrame()    
    local h='';
    if currentRaid ~= nil and currentRaid.drops~= nil then
        for i=1, #currentRaid.drops do
            local d=currentRaid.drops[i];            
            h=h..i..': '.. d.item..'\n';
        end
    end       
    PulseDkpDropsBox:SetText(h);    
end