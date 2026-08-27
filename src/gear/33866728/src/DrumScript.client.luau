--Rescripted by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")

Gui = Tool:WaitForChild("DrumGui")

Sounds = {}

for i, v in pairs(Handle:GetChildren()) do
	if v:IsA("Sound") then
		Sounds[v.Name] = v
	end
end

function StopSounds()
	for i, v in pairs(Sounds) do
		v:Stop()
	end
end

function SetGui(Key, Enabled)
	local Frame = GuiClone.Frame:FindFirstChild(Key)
	if Frame then
		Frame.Visible = Enabled
	end
end

function Equipped(Mouse)
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	PlayerGui = Player:FindFirstChild("PlayerGui")
	Humanoid = Character:FindFirstChild("Humanoid")
	if not Player or not PlayerGui or not Humanoid or Humanoid.Health == 0 then
		return
	end
	GuiClone = Gui:Clone()
	GuiClone.Parent = PlayerGui
	Mouse.KeyDown:connect(function(Key)
		Key = Key:lower()
		if Key == "g" then
			Sounds.HiHat:Play()
		elseif Key == "h" then
			Sounds.Snare:Play()
		elseif Key == "j" then
			Sounds.Tom2:Play()
		elseif Key == "k" then
			Sounds.Tom3:Play()
		elseif Key == "y" then
			Sounds.Crash:Play()
		elseif Key == "u" then
			Sounds.Tom1:Play()
		elseif Key == "t" then
			Sounds.Ride:Play()
		elseif Key == "n" then
			Sounds.Kick:Play()
		end
		SetGui(Key, true)
	end)
	Mouse.KeyUp:connect(function(Key)
		SetGui(Key, false)
	end)
end

function Unequipped()
	StopSounds()
	if GuiClone and GuiClone.Parent then
		GuiClone:Destroy()
	end
end

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)