--[[
	Copied into the character to disable jumping
--]]

local humanoid = script:WaitForChild'Humanoid'.Value
local jumpCon = humanoid.Changed:connect(function(prop)
	if prop == 'Jump' and humanoid.Jump == true then
		humanoid.Jump = false
	end
end)

wait(script:WaitForChild'Lifetime'.Value)

jumpCon:disconnect()

wait(script.ExtraLifetime.Value)

script:Destroy()