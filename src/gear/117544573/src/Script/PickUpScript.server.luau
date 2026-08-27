--Rescripted by Luckymaxer

Part = script.Parent

Debris = game:GetService("Debris")

Creator = Part:FindFirstChild("Creator")

Sounds = {
	PickUp = Part:WaitForChild("PickUpSound")
}

Enabled = true

function Touched(Hit)
	if not Hit or not Hit.Parent or not Enabled then
		return
	end
	local character = Hit.Parent
	if Creator and Creator.Value and Creator.Value:IsA("Player") and character == Creator.Value.Character then
		return
	end
	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid or humanoid.Health == 0 then
		return
	end
	Enabled = false
	Debris:AddItem(Part, 1.5)
	Part.Transparency = 1
	Sounds.PickUp:Play()	
end

Part.Touched:connect(Touched)