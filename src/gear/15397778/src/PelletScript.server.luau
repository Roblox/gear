local debris = game:service("Debris")
pellet = script.Parent


local heal = 50

local healsound = Instance.new("Sound")
healsound.SoundId = "http://www.roblox.com/asset/?id=15372684"
healsound.Parent = pellet
healsound.PlayOnRemove = true


function onTouched(hit)
	humanoid = hit.Parent:findFirstChild("Humanoid")
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


connection = pellet.Touched:connect(onTouched)


wait(20)

for i=0,9 do
	wait(.5)
	pellet.Transparency = i / 10
end

healsound.PlayOnRemove = false
wait(.5)

pellet.Parent = nil
