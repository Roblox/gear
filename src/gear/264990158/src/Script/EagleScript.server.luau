--Made by Luckymaxer

Eagle = script.Parent

Debris = game:GetService("Debris")

RbxUtility = LoadLibrary("RbxUtility")
Create = RbxUtility.Create

Creator = Eagle:FindFirstChild("Creator")
Target = Eagle:FindFirstChild("Target")

BodyPosition = Eagle:FindFirstChild("BodyPosition")
BodyGyro = Eagle:FindFirstChild("BodyGyro")

Rate = (1 / 60)

TargetReached = false
TargetFailed = false

Speed = 3

function TagHumanoid(humanoid, player)
	local Creator_Tag = Create("ObjectValue"){
		Name = "creator",
		Value = player,
	}
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

function GetCreator()
	local Player = Creator.Value
	if not Player or not Player.Parent or not Player:IsA("Player") then
		return
	end
	local Character = Player.Character
	if not Character or not Character.Parent then
		return
	end
	local Humanoid = Character:FindFirstChild("Humanoid")
	if not Humanoid or Humanoid.Health == 0 then
		return
	end
	return {Player = Player, Character = Character, Humanoid = Humanoid}
end

function GetTarget()
	local Character = Target.Value
	if not Character or not Character.Parent then
		return
	end
	local Humanoid = Character:FindFirstChild("Humanoid")
	if not Humanoid or Humanoid.Health == 0 then
		return
	end
	return {Character = Character, Humanoid = Humanoid}
end

function CheckIfCreatorAlive()
	return ((GetCreator() and true) or false)
end

function CheckIfTargetAlive()
	return ((GetTarget() and true) or false)
end

while CheckIfCreatorAlive() and CheckIfTargetAlive() and not TargetReached and not TargetFailed and BodyPosition.Parent and BodyGyro.Parent do
	local TargetValue = GetTarget()
	if TargetValue then
		local TargetHead = TargetValue.Character:FindFirstChild("Head")
		if not TargetHead then
			TargetFailed = true
			break
		end
		local Distance = (Eagle.Position - TargetHead.Position).Magnitude
		if Distance <= 10 then
			TargetReached = true
			break
		end
		Direction = CFrame.new(Eagle.Position, TargetHead.Position)
		BodyGyro.cframe = Direction
		BodyPosition.position = (BodyPosition.position + Direction.lookVector * Speed)
	end
	wait(Rate)
end

if TargetReached and not TargetFailed then
	local TargetValue = GetTarget()
	if TargetValue then
		local TargetCharacter = TargetValue.Character
		local TargetHead = TargetCharacter:FindFirstChild("Head")
		local TargetHumanoid = TargetCharacter:FindFirstChild("Humanoid")
		if TargetHead and TargetHumanoid and TargetHumanoid.Health > 0 then
			local GripWeld = Create("Weld"){
				Part0 = TargetHead,
				Part1 = Eagle,
				C0 = CFrame.new(0, ((TargetHead.Size.Y / 2) + (Eagle.Size.Y / 2)), 0) * CFrame.Angles(Eagle.CFrame:toEulerAnglesXYZ()),
				C1 = CFrame.new(0, 0, 0),
				Parent = Eagle,
			}
			TargetHumanoid.Sit = true
			local NewPosition = ((Eagle.CFrame * CFrame.Angles(0, (math.pi * 2), 0) + Vector3.new(0, 1000, 0)) * CFrame.new(0, 0, 1000))
			Direction = CFrame.new(Eagle.Position, NewPosition.p)
			local StartTick = tick()
			local Killed = false
			while Eagle and Eagle.Parent and BodyPosition.Parent and BodyGyro.Parent do
				if (tick() - StartTick) >= 5 and not Killed then
					Killed = true
					Debris:AddItem(Eagle, 5)
					local CurrentCreator = GetCreator()
					local CurrentTarget = GetTarget()
					if CurrentTarget and CheckIfTargetAlive() then
						local TargetHumanoid = CurrentTarget.Humanoid
						if CurrentCreator then
							UntagHumanoid(TargetHumanoid)
							TagHumanoid(TargetHumanoid, CurrentCreator.Player)
						end
						TargetHumanoid:TakeDamage(TargetHumanoid.MaxHealth)
					end
					if GripWeld and GripWeld.Parent then
						GripWeld:Destroy()
					end
				end
				BodyGyro.cframe = Direction
				BodyPosition.position = (Eagle.Position + Direction.lookVector * (Speed * 8))
				wait(Rate)
			end
		end
	end
end