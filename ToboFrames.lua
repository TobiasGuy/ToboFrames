-- Define a table for your addon
ToboFrames = {}

-- Default scale
local defaultScale = 1.0

-- Function to resize the character panel
function ToboFrames:ResizeFrames(scale)
    for _, Frame in ipairs(FrameNames) do
        local CurrentFrame = _G[Frame.frame]
        if CurrentFrame then
            CurrentFrame:SetScale(scale) -- Can re-enable this to remove the subframes function if I decide to go back
            -- ToboFrames:ResizeSubFrames(CurrentFrame, scale) -- Re-enable to resize subframes
        elseif Frame.addon then
            -- Register for the addon loaded event for this specific addon
            local addonLoadedFrame = CreateFrame("Frame")
            addonLoadedFrame:RegisterEvent("ADDON_LOADED")
            addonLoadedFrame:SetScript("OnEvent", function(self, event, addon)
                if event == "ADDON_LOADED" and addon == Frame.addon then
                    local scale = ToboFramesDB and ToboFramesDB.scale or defaultScale
                    local frame = _G[Frame.frame]
                    if frame then
                        frame:SetScale(scale)
                    end
                end
            end)
        end
    end
end

function ToboFrames:ResizeSubFrames(frame, scale)
    if frame and frame:IsObjectType("Frame") then
        frame:SetScale(scale)
        local i = 1
        while true do
            local child = select(i, frame:GetChildren())
            if not child then break end
            ToboFrames:ResizeSubFrames(child, scale)
            i = i + 1
        end
    end
end

-- Function to apply saved scale on login / reload
function ToboFrames:ApplySavedScale()
    local scale = ToboFramesDB and ToboFramesDB.scale or defaultScale
    ToboFrames:ResizeFrames(scale)
    print("Applied frame scale: " .. scale)
end

-- Function to create the UI / config frame
function ToboFrames:CreateConfigFrame()
    local configFrame = CreateFrame("Frame", "ToboFramesConfigFrame", UIParent, "BasicFrameTemplateWithInset")
    configFrame:SetSize(300, 250)
    configFrame:SetPoint("CENTER")
    configFrame:SetMovable(true)
    configFrame:EnableMouse(true)
    configFrame:RegisterForDrag("LeftButton")
    configFrame:SetScript("OnDragStart", configFrame.StartMoving)
    configFrame:SetScript("OnDragStop", configFrame.StopMovingOrSizing)
    configFrame.title = configFrame:CreateFontString(nil, "OVERLAY")
    configFrame.title:SetFontObject("GameFontHighlight")
    configFrame.title:SetPoint("CENTER", configFrame.TitleBg, "CENTER", 0, 0)
    configFrame.title:SetText("Tobo Frames")

    -- Scale slider
    local scaleSlider = CreateFrame("Slider", "ToboFramesScaleSlider", configFrame, "OptionsSliderTemplate")
    scaleSlider:SetWidth(200)
    scaleSlider:SetHeight(20)
    scaleSlider:SetPoint("TOP", configFrame, "TOP", 0, -50)
    scaleSlider:SetOrientation('HORIZONTAL')
    scaleSlider:SetMinMaxValues(0.5, 2.0)
    scaleSlider:SetValueStep(0.1)
    scaleSlider:SetValue(ToboFramesDB and ToboFramesDB.scale or defaultScale)
    scaleSlider:SetObeyStepOnDrag(true)

    -- Slider label
    scaleSlider.text = scaleSlider:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    scaleSlider.text:SetPoint("BOTTOM", scaleSlider, "TOP", 0, 0)
    scaleSlider.text:SetText("Frame Scale")

    -- Slider value display (EditBox)
    local scaleValueEditBox = CreateFrame("EditBox", "ToboFramesScaleValue", scaleSlider, "InputBoxTemplate")
    scaleValueEditBox:SetAutoFocus(false)
    scaleValueEditBox:SetWidth(50)
    scaleValueEditBox:SetHeight(20)
    scaleValueEditBox:SetPoint("TOP", scaleSlider, "BOTTOM", 0, -5)
    scaleValueEditBox:SetText(format("%.1f", scaleSlider:GetValue()))
    scaleValueEditBox:Hide()

    -- Create textbox
    scaleSlider.value = scaleSlider:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    scaleSlider.value:SetPoint("TOP", scaleSlider, "BOTTOM", 0, 0)
    scaleSlider.value:SetText(format("%.1f", scaleSlider:GetValue()))

    -- Update value display on slider change
    scaleSlider:SetScript("OnValueChanged", function(self, value)
        scaleSlider.value:SetText(format("%.1f", value))
        -- ToboFramesDB.scale = value
        -- ToboFrames:ApplySavedScale()
    end)

    -- Apply scale on slider release
    scaleSlider:SetScript("OnMouseUp", function(self)
        local value = format("%.1f", self:GetValue())
        ToboFramesDB.scale = tonumber(value)
        ToboFrames:ApplySavedScale()
    end)
    
    -- Show EditBox on right-click
    scaleSlider.value:SetScript("OnMouseUp", function(self, button)
        if button == "RightButton" then
            scaleValueEditBox:SetText(format("%.1f", ToboFramesDB.scale))
            scaleValueEditBox:Show()
            scaleValueEditBox:SetFocus()
            self:Hide()
        end
    end)

    -- Update scale on EditBox EnterPressed
    scaleValueEditBox:SetScript("OnEnterPressed", function(self)
        local value = tonumber(self:GetText())
        if value and value >= 0.5 and value <= 2.0 then
            ToboFramesDB.scale = value
            ToboFrames:ApplySavedScale()
            scaleSlider:SetValue(value)
        end
        self:Hide()
        scaleSlider.value:Show()
    end)

    -- Hide EditBox on EscapePressed
    scaleValueEditBox:SetScript("OnEscapePressed", function(self)
        self:Hide()
        scaleSlider.value:Show()
    end)

    -- Section to calculate UI scale conversions
    local customScaleLabel = configFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    customScaleLabel:SetPoint("TOP", scaleSlider, "BOTTOM", 0, -40)
    customScaleLabel:SetText("Custom Scale Calculation")

    -- First edit box
    local firstEditBox = CreateFrame("EditBox", "ToboFramesFirstEditBox", configFrame, "InputBoxTemplate")
    firstEditBox:SetAutoFocus(false)
    firstEditBox:SetWidth(50)
    firstEditBox:SetHeight(20)
    firstEditBox:SetPoint("TOP", customScaleLabel, "BOTTOM", -100, -30)

    -- Label for the first edit box
    local currentUiScaleLabel = configFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    currentUiScaleLabel:SetPoint("BOTTOMLEFT", firstEditBox, "TOPLEFT", -1, 3)
    currentUiScaleLabel:SetText("Current UI scale:")

    -- Second edit box with default value 0.71
    local secondEditBox = CreateFrame("EditBox", "ToboFramesSecondEditBox", configFrame, "InputBoxTemplate")
    secondEditBox:SetAutoFocus(false)
    secondEditBox:SetWidth(50)
    secondEditBox:SetHeight(20)
    secondEditBox:SetPoint("LEFT", firstEditBox, "RIGHT", 100, 0)
    secondEditBox:SetText("0.71")

    -- Label for the second edit box
    local desiredUiScaleLabel = configFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    desiredUiScaleLabel:SetPoint("BOTTOMLEFT", secondEditBox, "TOPLEFT", -1, 3)
    desiredUiScaleLabel:SetText("Desired UI scale:")

    -- Set Scale Button
    local setScaleButton = CreateFrame("Button", "ToboFramesSetScaleButton", configFrame, "GameMenuButtonTemplate")
    setScaleButton:SetPoint("TOP", firstEditBox, "BOTTOM", 25, -10)
    setScaleButton:SetSize(100, 25)
    setScaleButton:SetText("Set Scale")

    -- Set Scale Button OnClick script
    setScaleButton:SetScript("OnClick", function()
        local firstValue = tonumber(firstEditBox:GetText())
        local secondValue = tonumber(secondEditBox:GetText())
        if firstValue and secondValue then
            local newScale = secondValue / firstValue
            ToboFramesDB.scale = newScale
            ToboFrames:ApplySavedScale()
            scaleSlider:SetValue(newScale)
        else
            print("Invalid input. Please enter valid numbers.")
        end
    end)

    -- Show the configuration frame
    configFrame:Hide()
    self.configFrame = configFrame
end

-- Function to show the edit box for custom input
function ToboFrames:ShowEditBox(anchor)
    if not self.editBox then
        self.editBox = CreateFrame("EditBox", "ToboFramesEditBox", UIParent, "InputBoxTemplate")
        self.editBox:SetAutoFocus(true)
        self.editBox:SetWidth(100)
        self.editBox:SetHeight(30)
        self.editBox:SetPoint("CENTER", anchor, "CENTER")
        self.editBox:SetScript("OnEnterPressed", function(self)
            local value = tonumber(self:GetText())
            if value and value >= 0.5 and value <= 2.0 then
                ToboFramesDB.scale = value
                ToboFrames:ApplySavedScale()
                ToboFrames.configFrame.scaleSlider:SetValue(value)
            end
            self:Hide()
        end)
        self.editBox:SetScript("OnEscapePressed", function(self)
            self:Hide()
        end)
        self.editBox:Hide()
    end
    self.editBox:Show()
    self.editBox:SetFocus()
end

-- Function to get visible frame names and return them
function ToboFrames:GetVisibleFrames()
    self:CreateFrameListPopup()
    local popup = self.frameListPopup
    popup:Show()

    self:UpdateFrameList()
end

-- Function to toggle the configuration frame
function ToboFrames:ToggleConfigFrame()
    if not self.configFrame then
        self:CreateConfigFrame()
    end
    if self.configFrame:IsShown() then
        self.configFrame:Hide()
    else
        self.configFrame:Show()
    end
end

function ToboFrames:UpdateFrameList(searchTerm)
    local popup = self.frameListPopup
    local scrollChild = popup.scrollChild

    -- Clear previous content
    if scrollChild.frameTexts then
        for _, frameText in ipairs(scrollChild.frameTexts) do
            frameText:Hide()
            frameText:SetParent(nil)
        end
    end
    scrollChild.frameTexts = {}

    -- Reset scroll child height
    scrollChild:SetHeight(1)

    local frameNames = {}
    local frameList = EnumerateFrames()
    while frameList do
        if frameList:IsVisible() and frameList:GetName() then
            local frameName = frameList:GetName()
            if not searchTerm or searchTerm == "Search" or frameName:lower():find(searchTerm:lower()) then
                table.insert(frameNames, frameName)
            end
        end
        frameList = EnumerateFrames(frameList)
    end

    -- Sort frame names alphabetically
    table.sort(frameNames)

    local yOffset = 0
    for _, frameName in ipairs(frameNames) do
        local frameText = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        frameText:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 5, -yOffset)
        frameText:SetText(frameName)
        yOffset = yOffset + 20
        table.insert(scrollChild.frameTexts, frameText)
    end

    scrollChild:SetHeight(math.max(yOffset, scrollChild:GetParent():GetHeight()))
end

-- Function to make the popup for the list of frames returned from GetVisibleFrames
function ToboFrames:CreateFrameListPopup()
    if self.frameListPopup then
        return
    end

    local popup = CreateFrame("Frame", "ToboFramesListPopup", UIParent, "BasicFrameTemplateWithInset")
    popup:SetSize(300, 400)
    popup:SetPoint("CENTER")
    popup:SetMovable(true)
    popup:EnableMouse(true)
    popup:RegisterForDrag("LeftButton")
    popup:SetScript("OnDragStart", popup.StartMoving)
    popup:SetScript("OnDragStop", popup.StopMovingOrSizing)
    
    popup.title = popup:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    popup.title:SetPoint("TOP", popup, "TOP", 0, -5)
    popup.title:SetText("Visible Frames")

    -- Create search box
    popup.searchBox = CreateFrame("EditBox", nil, popup, "InputBoxTemplate")
    popup.searchBox:SetPoint("TOPLEFT", popup, "TOPLEFT", 12, -25)
    popup.searchBox:SetPoint("RIGHT", popup, "RIGHT", -30, 0)
    popup.searchBox:SetHeight(20)
    popup.searchBox:SetTextColor(1, 1, 1, 1)
    popup.searchBox:SetText("Search")
    popup.searchBox:SetAutoFocus(false)
    popup.searchBox:SetScript("OnEditFocusGained", function(self)
        if self:GetText() == "Search" then
            self:SetText("")
        end
    end)
    popup.searchBox:SetScript("OnEditFocusLost", function(self)
        if self:GetText() == "" then
            self:SetText("Search")
        end
    end)
    popup.searchBox:SetScript("OnTextChanged", function(self)
        local text = self:GetText()
        if text ~= "Search" then
            ToboFrames:UpdateFrameList(text)
        end
    end)

    -- Create the scroll frame
    local scrollFrame = CreateFrame("ScrollFrame", nil, popup, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", popup.searchBox, "BOTTOMLEFT", 0, -10)
    scrollFrame:SetPoint("BOTTOMRIGHT", popup, "BOTTOMRIGHT", -30, 10)

    -- Create the scroll child frame
    local scrollChild = CreateFrame("Frame")
    scrollFrame:SetScrollChild(scrollChild)
    scrollChild:SetSize(scrollFrame:GetWidth(), 1)

    popup.scrollFrame = scrollFrame
    popup.scrollChild = scrollChild

    self.frameListPopup = popup
end

-- Function to create a slash command to set the scale
function ToboFrames:CreateSlashCommand()
    SLASH_CPR1 = "/cpr"
    SlashCmdList["CPR"] = function(msg)
        local scale = tonumber(msg)
        if scale and scale > 0 then
            ToboFramesDB.scale = scale
            ToboFrames:ResizeFrames(scale)
            print("Frame scale set to " .. scale)
        else
            ToboFrames:ToggleConfigFrame()
        end
    end

    SLASH_GETFRAMES1 = "/getframes"
    SlashCmdList["GETFRAMES"] = function(msg)
        ToboFrames:GetVisibleFrames()
    end
end

-- Hook function to resize frame when it is shown
-- CURRENTLY UNUSED
function ToboFrames:HookFrame(Frame, scale)
    local frame = _G[Frame]
    -- local scale = ToboFramesDB and ToboFramesDB.scale or defaultScale
    if frame then
        frame:HookScript("OnShow", function()
            ToboFrames:ResizeFrames(frame, scale) 
        end)
    end
end

-- Initialize the addon
local function OnEvent(self, event, ...)
    if event == "ADDON_LOADED" and ... == "ToboFrames" then
        ToboFramesDB = ToboFramesDB or {}
        ToboFrames:CreateSlashCommand()
    elseif event == "PLAYER_LOGIN" then
        ToboFrames:ApplySavedScale()
    -- elseif event == "ADDON_LOADED" and ... == "Blizzard_AchievementUI" then
    --     local scale = ToboFramesDB and ToboFramesDB.scale or defaultScale
    --     AchievementFrame:SetScale(scale)
    end
end

-- Register event handler
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", OnEvent)