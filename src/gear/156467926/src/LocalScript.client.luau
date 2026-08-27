--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Anims = {Tool:WaitForChild("LeftSlash"), Tool:WaitForChild("RightSlash")}

PlaySound = Tool:WaitForChild("PlaySound")
SlashSound = Handle:WaitForChild("Slash")

Debris = game:GetService("Debris")
Players = game:GetService("Players")

OverseerAISpawnRadius = 10

Damage = 10

CanPush = false

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

function GetAllParts(Parent)
	local Parts = {}
	local function GetParts(Parent)
		for i, v in pairs(Parent:GetChildren()) do
			GetParts(v)
			if v:IsA("BasePart") then
				table.insert(Parts, v)
			end
		end
	end
	GetParts(Parent)
	return Parts
end

function Blow(Hit)
	if Hit and Hit.Parent then
		local humanoid = Hit.Parent:FindFirstChild("Humanoid")
		if Character and Player and Humanoid and humanoid and humanoid ~= Humanoid and humanoid.Health > 0 and Humanoid.Health > 0 then
			local right_arm = Character:FindFirstChild("Right Arm")
			if right_arm then
				local joint = right_arm:FindFirstChild("RightGrip")
				if joint and (joint.Part0 == Handle or joint.Part1 == Handle) then
					UntagHumanoid(humanoid)
					TagHumanoid(humanoid, Player)
					humanoid:TakeDamage(Damage)
					local torso = Hit.Parent:FindFirstChild("Torso")
					if torso and CanPush then
						humanoid.Sit = true
						torso.Velocity = CFrame.new(Handle.Position, torso.Position).lookVector * 125
					end
				end
			end
		end
	end
end

function Activated()
	if Tool.Enabled then
		local Animation = Anims[math.random(1, #Anims)]
		CurrentAnim = Humanoid:LoadAnimation(Animation)
		PlaySound.Value = SlashSound.Name
		Tool.Enabled = false
		CurrentAnim:Play(nil, nil, 1.25)
		CanPush = true
		wait(0.5)
		CanPush = false
		Tool.Enabled = true
	end
end

function Equipped(Mouse)
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso")
	if not Tool.Enabled then
		wait(0.5)
		Tool.Enabled = true
	end
end

function Unequipped()
	if CurrentAnim then
		CurrentAnim:Stop()
	end
end

Handle.Touched:connect(Blow)

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)