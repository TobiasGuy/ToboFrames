-- Define a table for your addon
ToboFrames = {}

-- Default scale
local defaultScale = 1.0

-- Function to resize the character panel
function ToboFrames:ResizeFrames(scale)
    for _, Frame in ipairs(FrameNames) do
        local CurrentFrame = _G[Frame]
        if CurrentFrame then
            CurrentFrame:SetScale(scale)
        end
    end
end

-- Function to apply saved scale on login / reload
function ToboFrames:ApplySavedScale()
    local scale = ToboFramesDB and ToboFramesDB.scale or defaultScale
    ToboFrames:ResizeFrames(scale)
    print("Applied saved frame scale: " .. scale)
end

-- Function to create a slash command to set the scale
function ToboFrames:CreateSlashCommand()
    SLASH_CPR1 = "/cpr"
    SlashCmdList["CPR"] = function(msg)
        local scale = tonumber(msg)
        if scale and scale > 0 then
            ToboFramesDB.scale = scale
            ToboFrames:ResizeFrames(scale)
            print("Character panel scale set to " .. scale)
        else
            print("Usage: /cpr <scale> (e.g., /cpr 1.2)")
        end
    end
end

-- Initialize the addon
local function OnEvent(self, event, ...)
    if event == "ADDON_LOADED" and ... == "ToboFrames" then
        ToboFramesDB = ToboFramesDB or {}
        ToboFrames:CreateSlashCommand()
        ToboFrames:ApplySavedScale()
    end
end

-- Register event handler
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", OnEvent)