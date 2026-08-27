--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
FireShield = Tool:WaitForChild("FireShield")
Special = Tool:WaitForChild("Special")
Damage = 7

SlashSound = Instance.new("Sound")
SlashSound.SoundId = "rbxasset://sounds\\Handleslash.wav"
SlashSound.Parent = Handle
SlashSound.Volume = 1

UnsheathSound = Instance.new("Sound")
UnsheathSound.SoundId = "rbxasset://sounds\\unsheath.wav"
UnsheathSound.Parent = Handle
UnsheathSound.Volume = 1

function TagHumanoid(Humanoid, Player)
	local Creator_Tag = Instance.new("ObjectValue")
	Creator_Tag.Value = Player
	Creator_Tag.Name = "creator"
	Creator_Tag.Parent = Humanoid
end

function UnTagHumanoid(Humanoid)
	if Humanoid ~= nil then
		local Tag = Humanoid:findFirstChild("creator")
		if Tag ~= nil then
			Tag.Parent = nil
		end
	end
end

FireShield.Changed:connect(function()
	if not FireShield.Value then
		wait(60)
		FireShield.Value = true
	end
end)

Special.Changed:connect(function()
	if not Special.Value then
		wait(15)
		Special.Value = true
	end
end)

Handle.Touched:connect(function(Hit)
	if Hit ~= nil and Hit.Parent ~= nil then
		local Humanoid = Hit.Parent:findFirstChild("Humanoid")
		local vCharacter = Tool.Parent
		local vPlayer = game.Players:playerFromCharacter(vCharacter)
		local Hum = vCharacter:findFirstChild("Humanoid")
		if Humanoid ~= nil and Humanoid ~= Hum and Hum ~= nil  and Humanoid.Health > 0 then
			local Right_Arm = vCharacter:FindFirstChild("Right Arm")
			if (Right_Arm ~= nil) then
				local joint = Right_Arm:FindFirstChild("RightGrip")
				if (joint ~= nil and (joint.Part0 == Handle or joint.Part1 == Handle)) then
					Humanoid:TakeDamage(Damage)
					TagHumanoid(Humanoid, vPlayer)
					wait(1)
					UnTagHumanoid(Humanoid)
				end
			end
		end
	end
end)

function Equipped(Mouse)
	UnsheathSound:Play()
	local Character = Tool.Parent
	local Humanoid = Character:findFirstChild("Humanoid")
	if Humanoid ~= nil then
		Mouse.Button1Down:connect(function()
			if Tool.Enabled and Humanoid ~= nil then
				SlashSound:Play()
			end
		end)
	end
end

Tool.Equipped:connect(Equipped)