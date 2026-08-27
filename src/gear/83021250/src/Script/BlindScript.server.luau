--Rescripted by Luckymaxer
--Fixed by TakeoHonorable

Creator = script:WaitForChild("Creator")

Character = script.Parent
Humanoid = Character:FindFirstChildOfClass("Humanoid")
Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Player = Players:GetPlayerFromCharacter(Character)

Duration = 2

function TagHumanoid(humanoid, player)
	local Creator_Tag = Instance.new("ObjectValue")
	Creator_Tag.Name = "creator"
	Creator_Tag.Value = player
	Debris:AddItem(Creator_Tag, 2)
	Creator_Tag.Parent = humanoid
end

function UntagHumanoid(humanoid)
	for i, v in pairs(humanoid:GetChildren()) do
		if v:IsA("ObjectValue") and v.Name == "creator" then
			v:Destroy()
		end
	end
end

if Player then
	PlayerGui = Player:FindFirstChild("PlayerGui")
	if PlayerGui then
		BlindGui = Instance.new("ScreenGui")
		BlindGui.Name = "BlindGui"
		BlindGui.Parent = PlayerGui 
		BlindFrame = Instance.new("Frame")
		BlindFrame.Name = "BlindFrame"
		BlindFrame.Size = UDim2.new(3, 0, 3, 0)
		BlindFrame.BackgroundColor3 = Color3.new(1, 1, 1)
		BlindFrame.Position = UDim2.new(-1.5, 0, -1.5, 0)
		BlindFrame.Parent = BlindGui
		Debris:AddItem(BlindGui, 7)
		BlindGui.Parent = PlayerGui
	end
	Fire = Instance.new("Fire")
	Debris:AddItem(Fire, 5)
	Fire.Parent = Torso
	if Creator.Value and Creator.Value.Parent and Creator.Value.Parent:IsA("Player") then
		UntagHumanoid(Humanoid)
		TagHumanoid(Humanoid, Creator.Value)
	end
	Humanoid:TakeDamage(45)
	wait(5)
	DurationTick = tick()
	while (tick() - DurationTick) < Duration do
		if Creator.Value and Creator.Value.Parent and Creator.Value.Parent:IsA("Player") then
			UntagHumanoid(Humanoid)
			TagHumanoid(Humanoid, Creator.Value)
		end
		Humanoid:TakeDamage(1.5)
		wait(0.2)
	end
end

script:Destroy()