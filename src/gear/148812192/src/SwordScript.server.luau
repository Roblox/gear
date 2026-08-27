--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")

Damage = 10

local SlashSound = Instance.new("Sound")
SlashSound.SoundId = "rbxasset://sounds\\Handleslash.wav"
SlashSound.Parent = Handle
SlashSound.Volume = 1
local UnsheathSound = Instance.new("Sound")
UnsheathSound.SoundId = "rbxasset://sounds\\unsheath.wav"
UnsheathSound.Parent = Handle
UnsheathSound.Volume = 1

function TagHumanoid(Humanoid, Player)
	local Creator_Tag = Instance.new("ObjectValue")
	Creator_Tag.Value = Player
	Creator_Tag.Name = "creator"
	Creator_Tag.Parent = Humanoid
end

function UntagHumanoid(Humanoid)
	if Humanoid and Humanoid.Parent then
		for i, v in pairs(Humanoid:GetChildren()) do
			if v.Name == "creator" then
				v:Destroy()
			end
		end
	end
end

Handle.Touched:connect(function(Hit)
	if Hit and Hit.Parent then
		local character = Hit.Parent
		local humanoid = character:FindFirstChild("Humanoid")
		if Humanoid and Humanoid ~= humanoid and humanoid and Humanoid.Health > 0 and humanoid.Health > 0 then
			local Right_Arm = Character:FindFirstChild("Right Arm")
			if Right_Arm then
				local Joint = Right_Arm:FindFirstChild("RightGrip")
				if (Joint and (Joint.Part0 == Handle or Joint.Part1 == Handle)) then
					humanoid:TakeDamage(Damage)
					TagHumanoid(humanoid, Player)
					wait(1)
					UntagHumanoid(humanoid)
				end
			end
		end
	end
end)

Tool.Equipped:connect(function(Mouse)
	UnsheathSound:Play()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	if not Character or not Humanoid or not Player then
		return
	end
	Mouse.Button1Down:connect(function()
		if Tool.Enabled then
			SlashSound:Play()
		end
	end)
end)