--Rescripted by Luckymaxer

Figure = script.Parent

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Functions = require(script:WaitForChild("Functions"))
Creator = Figure:WaitForChild("Creator")

Humanoid = Figure:WaitForChild("Humanoid")
Torso = Figure:WaitForChild("Torso")
Throwable = Figure:WaitForChild("Throwable")

RbxUtility = LoadLibrary("RbxUtility")
Create = RbxUtility.Create

ThrowDamage = 15
ThrowChance = 0.05
Duration = 10

Rate = (1 / 60)

Sounds = {
	Throw = script:WaitForChild("Throw"),
	Swoosh = script:WaitForChild("Swoosh"),
	Smack = script:WaitForChild("Smack"),
}

LastThrowTime = 0

Humanoid.Health = Humanoid.MaxHealth

function CheckIfAlive()
	return (((Figure and Figure.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Throwable and Throwable.Parent) and true) or false)
end

function GetCreator()
	local CreatorValue = Creator.Value
	return ((CreatorValue and CreatorValue.Parent and ((CreatorValue:IsA("Player") and CreatorValue) or Players:GetPlayerFromCharacter(CreatorValue))) or nil)
end

function FindClosestPlayer()
	local MaxDistance = 150
	local ClosestPlayer = {Player = nil, Distance = MaxDistance}
	local SearchVec = Vector3.new(MaxDistance, MaxDistance, MaxDistance)
	local SearchRegion = Region3.new((Torso.Position - SearchVec), (Torso.Position + SearchVec))
	local Creator = GetCreator()
	local CreatorCharacter = ((Creator and Creator.Character) or nil)
	local PartsInRegion = Functions.GetParts(SearchRegion, 500, {Figure, CreatorCharacter})
	for i, v in pairs(PartsInRegion) do
		local PartDistance = (Torso.Position - v.Position).Magnitude
		local character = v.Parent
		local humanoid = character:FindFirstChild("Humanoid")
		if humanoid and humanoid:IsA("Humanoid") and humanoid.Health > 0 and PartDistance < ClosestPlayer.Distance then
			ClosestPlayer.Player = character
			ClosestPlayer.Distance = PartDistance
		end
	end
	return ClosestPlayer.Player
end

function ThrowableReachedTarget(Part, TargetHumanoid)
	local SmackSound = Sounds.Smack:Clone()
	SmackSound.Parent = Part
	SmackSound:Play()
	if TargetHumanoid.Health > 0 then
		Functions.UntagHumanoid(TargetHumanoid)
		Functions.TagHumanoid(TargetHumanoid, GetCreator())
		TargetHumanoid:TakeDamage(ThrowDamage)
	end
	Part.Transparency = 1
	Part.CanCollide = false
	Part.Anchored = true
	Debris:AddItem(Part, 1)
end

function PickNewTarget(Part)
	local Homing = Part:FindFirstChild('Homing')
	if Homing then
		local TargetPlayer = FindClosestPlayer(Part.Position)
		if TargetPlayer then
			local humanoid = TargetPlayer:FindFirstChild("humanoid")
			local head = TargetPlayer:FindFirstChild("Head")
			if humanoid and humanoid.Health > 0 and head then
				Homing.Target = head
				return
			end
		end
		Homing:Destroy()
	end
	Part.CanCollide = false
end

function TargetModelChanged(Property, Part, Target)
	if Property == "Parent" and not Target.Parent then
		PickNewTarget(Part)
	end
end

while CheckIfAlive() do
	local Creator = GetCreator()
	if Creator then
		local CreatorCharacter = Creator.Character
		if CreatorCharacter and CreatorCharacter.Parent then
			local CreatorHumanoid = CreatorCharacter:FindFirstChild("Humanoid")
			local CreatorTorso = CreatorCharacter:FindFirstChild("Torso")
			if CreatorHumanoid and CreatorHumanoid.Health > 0 and CreatorTorso then
				Humanoid:MoveTo(CreatorTorso.Position + Vector3.new(-4, 0, -4))
			end
		end
		local Now = tick()
		if (Now - LastThrowTime) > 0.5 and math.random() <= ThrowChance then
			LastThrow = Now
			local TargetPlayer = FindClosestPlayer(Torso.Position)
			if TargetPlayer then
				local TargetHumanoid = TargetPlayer:FindFirstChild("Humanoid")
				local TargetHead = TargetPlayer:FindFirstChild("Head")
				if TargetHumanoid and TargetHumanoid.Health > 0 and TargetHead then
					local Sound = Sounds.Throw:Clone()
					Debris:AddItem(Sound, 1.5)
					Sound.Parent = Throwable
					Sound:Play()
					local Projectile = Throwable:Clone()
					Projectile.Name = "Projectile"
					local Homing = Create("RocketPropulsion"){
						Name = "Homing",
						Target = TargetHead,
					}
					Homing.ReachedTarget:connect(function()
						ThrowableReachedTarget(Projectile, TargetHumanoid)
					end)
					TargetPlayer.Changed:connect(function(Property)
						TargetModelChanged(Property, Projectile, TargetPlayer)
					end)
					Homing.Parent = Projectile
					Debris:AddItem(Projectile, Duration)
					Projectile.Velocity = Vector3.new(0, 100, 0)
					Projectile.Parent = game:GetService("Workspace")
					wait(0.5)
					if Projectile and Projectile.Parent then
						local Sound = Sounds.Swoosh:Clone()
						Sound.Parent = Projectile
						Sound:Play()
						Projectile.Size = Vector3.new(0.5, 1, 0.5)
						Projectile.CanCollide = true
						Homing:Fire()
					end
				end
			end
		end
	end
	wait(Rate)
end

Debris:AddItem(Figure, 0)