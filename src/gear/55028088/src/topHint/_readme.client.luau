--
-- Top Hint
--
--  * This is a string of text that's top-centered in the window. (White text on black background)
--  * It should be used for messages from the client, and never from the place creator. 
--
-- FEATURES:
--  * Auto-hides previous messages before showing yours.
--  * Always centered, regardless of length.
--  * Clicking the message hides it.
-- 
-- USE IT FOR:
--  * Quick task-related (non-essential) hints
--  * Showing the current modal state
--  * Tool hints (for the currently equipped tool)
--  * Keyboard shortcuts
--
-- NEVER USE IT FOR:
--  * Essential information (Use a popup instead)
--  * Messages from users or place creators.  This is for client messages only.
--
-- ARGUMENTS:
--  Label:  The message
--  Width:  Text and background width (pixels) -- This should be removed when textWidth is added to Lua
--  Time:   Seconds before hiding itself (If 0, it never hides)
--
-- USAGE:
local topHint = script.Parent.topHint  -- path to topHint ScreenGui
topHint.Add.Label.Value = "Press D to return to main menu."
topHint.Add.Width.Value = 290
topHint.Add.Time.Value = 7
topHint.Add.Disabled = true  -- flip it off then on, in case it's currently running.
topHint.Add.Disabled = false
--
-- TO HIDE MANUALLY:
topHint.Delete.Disabled = false
-- Clicking the message also hides it.