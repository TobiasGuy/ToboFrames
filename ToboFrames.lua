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
            print("Usage: /cpr <scale> (e.g., /cpr 1.2)")
        end
    end
end

-- Hook function to resize frame when it is shown
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