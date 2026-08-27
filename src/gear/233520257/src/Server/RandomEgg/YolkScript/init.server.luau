local Yolk = script.Parent

local SlipSound = script:WaitForChild("SlipSound",5)

SlipSound.Parent = Yolk

function IsInTable(Table,Value)
	for _,v in pairs(Table) do
		if v == Value then
			return true
		end
	end
	return false
end

local TaggedHumanoids = {}

Yolk.Touched:Connect(function(hit)
	if not hit or not hit.Parent then return end
	local Hum = hit.Parent:FindFirstChildOfClass("Humanoid")
	if not Hum or Hum.Health <= 0 or IsInTable(TaggedHumanoids,Hum) then return end 
	TaggedHumanoids[#TaggedHumanoids+1] = Hum
	SlipSound:Play()
	Hum.Jump = true
	Hum.Sit = true
	wait(1)
	Hum.Sit = false
	for i,v in pairs(TaggedHumanoids) do
		if v == Hum then
			table.remove(TaggedHumanoids,i)
		end
	end
end)

delay(10,function()
	Yolk:Destroy()
end)