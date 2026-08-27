--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")

EquipAnim = Tool:WaitForChild("Equip")
IdleAnim = Tool:WaitForChild("Idle")
SlashAnim = Tool:WaitForChild("Slash")

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	if not Player or not Humanoid or Humanoid.Health == 0 then
		return
	end
	EquipTrack = Humanoid:LoadAnimation(EquipAnim)
	if EquipTrack then
		EquipTrack:Play()
	end
	IdleTrack = Humanoid:LoadAnimation(IdleAnim)
	if IdleTrack then
		IdleTrack:Play()
	end
	SlashTrack = Humanoid:LoadAnimation(SlashAnim)
end

function Changed(Property)
	if Property == "Enabled" and not Tool.Enabled then
		if SlashTrack then
			SlashTrack:Play()
		end
	end
end

function Unequipped()
	if EquipTrack then
		EquipTrack:Stop()
	end
	if IdleTrack then
		IdleTrack:Stop()
	end
	if SlashTrack then
		SlashTrack:Stop()
	end
end

Tool.Changed:connect(Changed)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)