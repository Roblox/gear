local Tool = script.Parent
local Handle = Tool:WaitForChild("Handle")

local Sounds = {
	Laser = {
		Sound = Handle:WaitForChild("LaserSound"),
		Playing = 0
	},
	SpeedBoost = {
		Sound = Handle:WaitForChild("SpeedBoostSound"),
		Playing = 0
	}
}

for i, v in pairs(Sounds) do
	v.Sound.ChildAdded:connect(function(Child)
		if Child:IsA("StringValue") then
			if Child.Name == "Play" then
				v.Sound:Play()
				v.Playing = v.Playing + 1
			elseif Child.Name == "Stop" then
				v.Playing = v.Playing - 1
				if v.Playing <= 0 then
					v.Sound:Stop()
				end
			end
		end
		Delay(0, function()
			if Child and Child.Parent then
				Child:Destroy()
			end
		end)
	end)
end