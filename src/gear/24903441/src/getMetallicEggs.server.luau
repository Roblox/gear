local Tool = script.Parent
local equipped = false
local sound = Instance.new("Sound")
sound.SoundId = "http://www.roblox.com/asset/?id=24907199"
sound.Parent = Tool.Handle

function findNearestMetallicEgg(pos)
	local metallicEggs = {}
	local dist = 50
	local list = game.Workspace:FindFirstChild("eggroot")
	if(list ~= nil) then
		list = list:GetChildren()
		for x = 1, #list do
			if (list[x].Name == "4") or  (list[x].Name == "10") or  (list[x].Name == "2") and ((list[x].Position - pos).magnitude < dist) then
				table.insert(metallicEggs,list[x])
			end
		end
	end
	return metallicEggs
end

function drawInEggs(eggsToDrawIn)
	
	for i=1,#eggsToDrawIn do
		
		local DirZ = 0
		local DirX = 0
		local DirY = 0

		if( eggsToDrawIn[i].className == "Part") then
			DirZ = Tool.Handle.Position.Z - eggsToDrawIn[i].Position.Z
			DirX = Tool.Handle.Position.X - eggsToDrawIn[i].Position.X
			DirY = Tool.Handle.Position.Y - eggsToDrawIn[i].Position.Y
		elseif (eggsToDrawIn[i]:FindFirstChild("Handle") ~= nil) then
			DirZ = Tool.Handle.Position.Z - eggsToDrawIn[i].Handle.Position.Z
			DirX = Tool.Handle.Position.X - eggsToDrawIn[i].Handle.Position.X
			DirY = Tool.Handle.Position.Y - eggsToDrawIn[i].Handle.Position.Y
		end
		local forceUnit = Vector3.new(DirX,DirY,DirZ).unit

		if (math.abs(DirZ) + math.abs(DirX) + math.abs(DirY) > 15) then
			local strength = 800
			local f = Instance.new("BodyForce")
			f.force = forceUnit * strength
			if( eggsToDrawIn[i].className == "Part") then
				f.Parent = eggsToDrawIn[i]
			else
				f.Parent = eggsToDrawIn[i].Handle
			end
			wait(0.01)
			f.Parent = nil
			
		else
			
			local v = Instance.new("BodyVelocity")
			v.velocity = Vector3.new(0,0,0)
			if( eggsToDrawIn[i].className == "Part") then
				v.Parent = eggsToDrawIn[i]
			elseif (eggsToDrawIn[i]:FindFirstChild("Handle") ~= nil) then
				v.Parent = eggsToDrawIn[i].Handle
			end
			wait(0.01)
			v.Parent = nil

			-- if egg is rusty egg, magnetize it
			if (eggsToDrawIn[i].Name == "10") and (eggsToDrawIn[i]:findFirstChild("MagnetizeEgg") == nil) then
				magnetize = Tool.MagnetizeEgg:clone()
				magnetize.Parent = eggsToDrawIn[i]
			end

		end
		
	end

end

function onEquipped()
	
	equipped = true
	findMyEggs()
	sound.Volume = 1
	sound:Play()

end

function onUnequipped()

	equipped = false
	--sound.Volume = 0
end

function findMyEggs()
	
	while equipped do

		local eggsToDrawIn = findNearestMetallicEgg(Tool.Handle.Position)
		if(eggsToDrawIn ~= nil) then
			drawInEggs(eggsToDrawIn)
		end
		wait(0.1)

	end

end

script.Parent.Equipped:connect(onEquipped)
script.Parent.Unequipped:connect(onUnequipped)
