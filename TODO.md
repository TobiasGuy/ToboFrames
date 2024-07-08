TODO LIST

Find all frames that need resizing
Make interface with slider? or just chat command? decide later, chat command for now
Profiles? (Global profile for all characters because it's really annoying for users if not)
Figure out how to do the release version stuff on github
Post on addon site
Scale seems quite high atm, maybe dilute the numbers a bit
List of all frames that you can checkmark to resize or not? checkmark all by default (maybe add optional ones that are not enabled by default) add check when looping through FrameNames to see if it's enabled or not.
    Default button to return to default frames enabled
Think about changing name of slash command
Function to auto-resize based on UI scale, maybe have a conversion with 0.53 current and 0.71 desired for example
Functionality for classic/earlier versions of wow?
Scale addon frames?
Add your own frames to be scaled? (Also suggestions functionality for frames to be added)
Maybe make a separate .lua file for frames that need to be hooked OnShow, or a separate constructor in the same FrameNames.lua file.
Make a more elegant solution for the "elseif event == "ADDON_LOADED" and ... == "Blizzard_AchievementUI" then" so it's reusable
Make a dict of addon names corresponding frames 

DONE LIST

Store the scale chosen, default to 1
Make sure the scale applies after relog + reload
Define usage in description
Think about subframes, not exactly sure how that works