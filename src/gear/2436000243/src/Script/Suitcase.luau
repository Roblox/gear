-- Created by StarWars
local module = {}

local Debris = game:GetService("Debris")

local openDelay = {Delay = 0.5, Now = tick(), Auto = 2}
local rand = Random.new()

function module:Throw(part, nifflerModel)
	local baseModel = nifflerModel:Clone()
	
	local opened = false
	
	local function openSuitcase()
		if opened then return end
		
		opened = true
		
		wait(0.25)
		
		for i = 1, 3 do
			local newPart = baseModel:Clone()
			newPart:MakeJoints()
			
			newPart:SetPrimaryPartCFrame(part.CFrame + Vector3.new(0, 1, 0) * 2)
			
			local force = rand:NextNumber(50, 100)
			local velocity = Vector3.new(0, 1, 0) * force
			velocity = velocity + Vector3.new(rand:NextNumber(-25, 25), 0, rand:NextNumber(-25, 25))
			newPart.PrimaryPart.Velocity = velocity
			newPart.PrimaryPart.RotVelocity = Vector3.new(rand:NextNumber(-3.6, 3.6), rand:NextNumber(-3.6, 3.6), rand:NextNumber(-3.6, 3.6))
			newPart:SetPrimaryPartCFrame(newPart.PrimaryPart.CFrame * CFrame.new(rand:NextNumber(-0.5, 0.5), rand:NextNumber(0, 0.5), rand:NextNumber(-0.5, 0.5)) * CFrame.Angles(math.rad(rand:NextNumber(-180, 180)), math.rad(rand:NextNumber(-180, 180)), math.rad(rand:NextNumber(-180, 180))))

			Debris:AddItem(newPart, 10)
			
			newPart.Parent = workspace
			
			local hum = newPart:FindFirstChildOfClass("Humanoid")
			if hum then
				hum:Move(Vector3.new(rand:NextNumber(-1, 1), 0, rand:NextNumber(-1, 1)))
			end			
		end
	end
	
	spawn(function()
		while part.Velocity.Magnitude > 5 do
			wait()
		end
		
		part.Anchored = true
		part.CanCollide = false
		part.Size = Vector3.new(2.337, 2.189, 1.998)
		part.Mesh.MeshId = "rbxassetid://2435962211"
		part.CFrame = part.CFrame * CFrame.new(0, 0.2215, 0)
		openSuitcase()
	end)
	
	delay(openDelay.Auto, openSuitcase)
end

return module
