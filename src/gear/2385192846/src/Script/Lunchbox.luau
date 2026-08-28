-- Created by StarWars
local module = {}

local Debris = game:GetService("Debris")

local openDelay = {Delay = 0.5, Now = tick(), Auto = 2}
local rand = Random.new()

function module:Throw(model, sandwichPart)
	local lid = model:WaitForChild("Lid")
	local bottom = model:WaitForChild("Bottom")
	local hinge = bottom:WaitForChild("Hinge")
	local baseSandwich = sandwichPart:Clone()
	
	local opened = false
	
	local function openLunchbox()
		if opened then return end
		
		opened = true
		
		hinge.DesiredAngle = rand:NextNumber(1, 1.75)
		wait(0.25)
		
		for i = 1, 3 do
			local newPart = baseSandwich:Clone()
			newPart.CFrame = (bottom.CFrame + Vector3.new(0, 1, 0) * 2)
			local force = rand:NextNumber(50, 100)
			local velocity = Vector3.new(0, 1, 0) * force
			velocity = velocity + Vector3.new(rand:NextNumber(-25, 25), 0, rand:NextNumber(-25, 25))
			newPart.Velocity = velocity
			newPart.RotVelocity = Vector3.new(rand:NextNumber(-3.6, 3.6), rand:NextNumber(-3.6, 3.6), rand:NextNumber(-3.6, 3.6))
			newPart.CFrame = newPart.CFrame * CFrame.new(rand:NextNumber(-0.5, 0.5), rand:NextNumber(0, 0.5), rand:NextNumber(-0.5, 0.5)) * CFrame.Angles(math.rad(rand:NextNumber(-180, 180)), math.rad(rand:NextNumber(-180, 180)), math.rad(rand:NextNumber(-180, 180)))

			Debris:AddItem(newPart, 3)
			
			newPart.Parent = workspace
		end
	end
	
	spawn(function()
		while bottom.Velocity.Magnitude > 5 do
			wait()
		end
		
		openLunchbox()
	end)
	
	delay(openDelay.Auto, openLunchbox)
end

return module
