# ToboFrames
 World of Warcraft addon for resizing blizzard frames on lower UI scales

## 1.0 Initialising .lua and .toc
First commit
Initialised ToboFrames.toc, ToboFrames.lua

## 1.1 Character panel resizer
Initialised Libs\Libs.xml
Added interface number 100207
Made feature to resize character panel with /cpr chat command, wanted to get something quick and easy that works so I can test (start small)
Keeping track of things to do in TODO.md

## 1.2 Adding multiple frames
Initialised FrameNames.lua
Made the function resize all frames within the FrameNames.lua file, just added a few frames for now. Lots of frames to add there

## 1.3 Saving scale
Slash command now saves the scale
Applied scale on login/reload
Made default scale 1.0

## 1.4 Define Usage
Defined usage in description

## 1.5 Scale subframes
Added the function to resize all subframes of each frame being resized.
This made everything weird though so it's disabled.
Think I don't need to have this and it all happens naturally, functionality is there though if it's needed for something later

## 1.6 Adding more frames
Fixed wording in slash command
Started to add more frames
Need to find a way to find all frames I want quicker
Created a bug where some frames do not get resized on login, but will get resized after slash command

## 1.6.5 Bugfix on login
Added event listener for PLAYER_LOGIN to call the ApplySavedScale function instead of on ADDON_LOADED because some frames are not loaded at this point
This did not work for AchievementFrame (and probably more frames I have not found yet) so I added a check for "event == "ADDON_LOADED" and ... == "Blizzard_AchievementUI" and then resized the AchievementFrame there, as it is tied to the addon Blizzard_AchievementUI. Need to make a more reusable solution for this
Made a HookFrame function, did not work as I wanted it to, leaving it there incase there's a use in the future. Should clean up later if it goes unused

## 1.7 Addon frames
Removed some commented out code to clean things up a bit
Changed FrameNames.lua to have a section for addon frames
Made the code handling addon frames more reusable so this should fix my problem for everything I need
Added MacroFrame to the addon frames list

## 1.8 Adding a lot more frames
As the title says, added a ton of frames, not entirely sure on things I'm missing, think I have a lot of things covered. Next expansion might take some work to upkeep though in hindsight lmao

### 1.8.1 Updating todo list

