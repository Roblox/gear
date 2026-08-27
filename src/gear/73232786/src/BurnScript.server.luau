local damage = 2
local interval = 0.5

local Debris = Game:GetService("Debris")
local BodyPart = script.Parent
local Humanoid
do
	if BodyPart.Parent then
		for i,v in pairs(BodyPart.Parent:GetChildren()) do
			if v:IsA"Humanoid" then
				Humanoid = v
				break
			end
		end
	end
end

if Humanoid then
	local Fire = Instance.new("Fire",BodyPart)
	Fire.Color = Color3.new(246/255,69/255,0)
	Fire.SecondaryColor = Color3.new(102/255,0,102/255)
	script.Parent = Fire

	local died = false
	Humanoid.Died:connect(function() died = true end)

	local CreatorTag = script:FindFirstChild("creator")
	if CreatorTag then
		CreatorTag = CreatorTag:Clone()
		while not died do
			local ctag = CreatorTag:Clone()
			ctag.Parent = Humanoid
			Humanoid:TakeDamage(damage)
			Debris:AddItem(ctag,interval)
			wait(interval)
		end
	else
		while not died do
			Humanoid:TakeDamage(damage)
			wait(interval)
		end
	end
end
script:Destroy()