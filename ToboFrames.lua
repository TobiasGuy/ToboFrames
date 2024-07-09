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
    configFrame:SetSize(300, 200)
    configFrame:SetPoint("CENTER")
    configFrame.title = configFrame:CreateFontString(nil, "OVERLAY")
    configFrame.title:SetFontObject("GameFontHighlight")
    configFrame.title:SetPoint("CENTER", configFrame.TitleBg, "CENTER", 5, 0)
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