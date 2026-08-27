-- Necessary only because Local Scripts stop running when a tool is backspaced, so we
--  can't rely on the LS to update Tool.Enabled as it should.
local Tool = script.Parent

wait(13)
Tool.Enabled = true

script:Destroy()
