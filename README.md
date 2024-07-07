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