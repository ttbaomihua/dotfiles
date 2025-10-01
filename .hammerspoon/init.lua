--[[
  Vim-like keybindings for Preview.app using a modal approach.
  - When Preview is active, "Normal Mode" is enabled.
  - Press 'i' to enter "Insert Mode" (disables all vim keys so you can type normally).
  - Press 'escape' to re-enter "Normal Mode".
--]]

-- Configuration
local READER = 'Preview'
local SPEED = 3

-- Create a modal object for our keybindings
local previewVim = hs.hotkey.modal.new()

-- This function will be called to enter "Normal Mode"
function enterNormalMode()
    hs.alert.show('NORMAL')
    previewVim:enter()
end

-- This function will be called to enter "Insert Mode"
function enterInsertMode()
    hs.alert.show('INSERT')
    previewVim:exit()
end

-- Define all your "Normal Mode" keybindings inside the modal
-- Scroll Down
previewVim:bind({}, 'j', nil, function()
    hs.eventtap.scrollWheel({0, -SPEED}, {})
end)

-- Scroll Up
previewVim:bind({}, 'k', nil, function()
    hs.eventtap.scrollWheel({0, SPEED}, {})
end)

-- Scroll Left
previewVim:bind({}, 'h', nil, function()
    hs.eventtap.scrollWheel({SPEED, 0}, {})
end)

-- Scroll Right
previewVim:bind({}, 'l', nil, function()
    hs.eventtap.scrollWheel({-SPEED, 0}, {})
end)

-- Next Page
previewVim:bind({}, 'N', nil, function()
    hs.eventtap.keyStroke({}, 'Right')
end)

-- Previous Page
previewVim:bind({}, 'P', nil, function()
    hs.eventtap.keyStroke({}, 'Left')
end)

-- Go to Top of Document
previewVim:bind({}, 'g', function()
    hs.eventtap.keyStroke({'cmd'}, 'Up')
end)

-- Go to Bottom of Document
previewVim:bind({'shift'}, 'g', function()
    hs.eventtap.keyStroke({'cmd'}, 'Down')
end)

-- Enter "Insert Mode"
previewVim:bind({}, 'i', enterInsertMode)

-- Create a separate, global hotkey to re-enter Normal Mode
-- This key will only be enabled when Preview is the active app.
local normalModeHotKey = hs.hotkey.bind({}, 'escape', enterNormalMode)
normalModeHotKey:disable() -- Disabled by default

-- Watch for application focus changes
function applicationWatcher(appName, event, app)
    if appName == READER then
        if event == hs.application.watcher.activated then
            -- App activated: enter normal mode and enable the escape key
            enterNormalMode()
            normalModeHotKey:enable()
        elseif event == hs.application.watcher.deactivated then
            -- App deactivated: exit vim mode and disable the escape key
            previewVim:exit()
            normalModeHotKey:disable()
        end
    end
end

-- Start the application watcher
local appWatcher = hs.application.watcher.new(applicationWatcher)
appWatcher:start()

-- Optional: Warp mouse to center of focused window
local wf = hs.window.filter.new(nil)
wf:subscribe(hs.window.filter.windowFocused, function(win)
    local f = win:frame()
    local center = { x = f.x + f.w/2, y = f.y + f.h/2 }
    hs.mouse.setAbsolutePosition(center)
end)

