local tool = script.Parent
local launchEgg = tool:WaitForChild("LaunchEgg")

local CollectableEgg = require(tool:WaitForChild("CollectableEgg"))
local Settings = require(tool:WaitForChild("Settings"))

local lastLaunch = 0

tool.LaunchEgg.OnServerInvoke = function(player, origin, target)
	if target ~= nil and typeof(target) ~= "Vector3" or typeof(origin) ~= "Vector3" then return end
	
	if tick() - lastLaunch > Settings.Cooldown then
		local character = player.Character
		if player.Character and player.Character.PrimaryPart then
			
			lastLaunch = tick()
			CollectableEgg.new(player, origin, target, Settings.Egg, Settings.MaxDist, Settings.DespawnTime)
			
			return true
		end
	end
end
