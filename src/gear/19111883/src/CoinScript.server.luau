local debris = game:service("Debris")
pellet = script.Parent

local heal = 2

local healsound = Instance.new("Sound")
healsound.SoundId = "http://www.roblox.com/asset/?id=15372684"
healsound.Parent = pellet
healsound.PlayOnRemove = true


function onTouched(hit)
	humanoid = hit.Parent:FindFirstChild("Humanoid")
	if humanoid~=nil then
		connection:disconnect()
		if (humanoid.Health + heal > humanoid.MaxHealth) then
			humanoid.Health = humanoid.MaxHealth
		else
			humanoid.Health = humanoid.Health + heal
		end
		pellet.Parent = nil
	end
end

pcall(function() connection = pellet.Touched:connect(onTouched) end)


wait(20)
healsound.PlayOnRemove = false
--[[wait(20)

print("am i looping?")
for i=0,10 do
	wait(.1)
	pellet.Transparency = i / 10
end

healsound.PlayOnRemove = false
wait(.5)

pellet.Parent = nil
]]
