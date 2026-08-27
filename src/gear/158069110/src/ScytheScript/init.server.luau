--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

PoisonScript = script:WaitForChild("PoisonScript")

Swinging = false
SlashCoolDown = 0.7

Damage = 9

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

function Blow(Hit)
	if Hit and Hit.Parent then
		local character = Hit.Parent
		local humanoid = character:FindFirstChild("Humanoid")
		if Humanoid and Humanoid ~= humanoid and humanoid and Humanoid.Health > 0 and humanoid.Health > 0 then
			local Right_Arm = Character:FindFirstChild("Right Arm")
			if Right_Arm then
				local Joint = Right_Arm:FindFirstChild("RightGrip")
				if (Joint and (Joint.Part0 == Handle or Joint.Part1 == Handle)) then
					humanoid:TakeDamage(Damage)
					UntagHumanoid(humanoid)
					TagHumanoid(humanoid, Player)
					if Swinging and not humanoid:FindFirstChild(PoisonScript.Name) then
						local ChanceToPoison = math.random(1, 4)
						if ChanceToPoison == 1 then
							local PoisonScriptClone = PoisonScript:Clone()
							local Creator = Instance.new("ObjectValue")
							Creator.Name = "Creator"
							Creator.Value = Player
							Creator.Parent = PoisonScriptClone
							PoisonScriptClone.Disabled = false
							PoisonScriptClone.Parent = humanoid
						end
					end
				end
			end
		end
	end
end

function Activated()
	if Tool.Enabled then
		Tool.Enabled = false
		Swinging = true
		wait(SlashCoolDown)
		Swinging = false
		Tool.Enabled = true
	end
end

function Equipped(Mouse)
	Equip = true
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso")
	if not Player or not Humanoid or not Torso then
		return
	end
end

function Unequipped()
end

Handle.Touched:connect(Blow)

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)