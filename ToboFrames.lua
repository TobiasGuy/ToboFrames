-- Define a table for your addon
ToboFrames = {}

-- Function to resize the character panel
function ToboFrames:ResizeCharacterPanel(scale)
    if CharacterFrame then
        CharacterFrame:SetScale(scale)
    end
end

-- Function to create a slash command to set the scale
function ToboFrames:CreateSlashCommand()
    SLASH_CPR1 = "/cpr"
    SlashCmdList["CPR"] = function(msg)
        local scale = tonumber(msg)
        if scale and scale > 0 then
            ToboFrames:ResizeCharacterPanel(scale)
            print("Character panel scale set to " .. scale)
        else
            print("Usage: /cpr <scale> (e.g., /cpr 1.2)")
        end
    end
end

-- Initialize the addon
local function OnEvent(self, event, ...)
    if event == "ADDON_LOADED" and ... == "ToboFrames" then
        ToboFrames:CreateSlashCommand()
    end
end

-- Register event handler
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", OnEvent)