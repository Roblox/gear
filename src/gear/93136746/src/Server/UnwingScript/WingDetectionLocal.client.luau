--Helps detect flying gears that have local forces

local Remote = script.Parent:WaitForChild("Remote")

local Character = script.Parent.Parent

function IsCharacterFlying(char) -- helps check if person is flying
	local FlightClasses = {"BodyPosition","BodyThrust","BodyVelocity","BodyGyro"}
	local Status = false
	if char and char:FindFirstChildOfClass("Tool") then
		for _,obj in pairs(char:GetDescendants()) do
			if obj:IsA("BasePart") then
				for _,v in pairs(FlightClasses) do
					if obj:FindFirstChildOfClass(v) then
						obj:FindFirstChildOfClass(v):Destroy()
						Status = true
					end
				end
			end
		end
	end
	return Status
end

function Remote.OnClientInvoke()
	return IsCharacterFlying(Character)
end