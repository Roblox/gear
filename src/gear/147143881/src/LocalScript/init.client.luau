--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
PlaySound = Handle:WaitForChild("PlaySound")
BlackHoleScript = script:WaitForChild("BlackHoleScript")

Anims = {
	Equip = Handle:WaitForChild("Equip"),
	Hold = Handle:WaitForChild("Hold"),
	LeftSlash = Handle:WaitForChild("LeftSlash"),
	RightSlash = Handle:WaitForChild("RightSlash"),
	OverHeadSwing = Handle:WaitForChild("OverHeadSwing"),
	Stab1 = Handle:WaitForChild("Stab1"),
	Stab2 = Handle:WaitForChild("Stab2"),
}

AnimSpeed = 1.2
EquipSpeed = 1.5

Damage = 25
DamageWindow = 1
SwingRate = 0.75

SwooshSounds = {91154708, 91155889}
HitSounds = {91154909, 91154932, 91154954}

Ready = false
Equipped = false
Rate = (1 / 30)
LastSwing = 0

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Handle.Touched:connect(function(Hit)
	if Ready and Equipped and Hit and Hit.Parent and not Hit:IsDescendantOf(Tool.Parent) and (tick() - LastSwing) <= DamageWindow then
		local character = Hit.Parent
		local humanoid = character:FindFirstChild("Humanoid")
		local torso = character:FindFirstChild("Torso")
		if Humanoid and humanoid and torso and humanoid ~= Humanoid and Humanoid.Health > 0 and humanoid.Health > 0 and RightArm then
			Ready = false
			
			for i,v in pairs(humanoid:GetChildren()) do
				if v.Name == "creator" then
					v:Destroy()
				end
			end

			local LocalDamage = math.floor(Damage * (0.9 + (math.random() * 0.2)))
			if (humanoid.Health - LocalDamage) <= 0 then
				local BlackHoleScriptClone = BlackHoleScript:Clone()
				BlackHoleScriptClone.creator.Value = Player
				BlackHoleScriptClone.Disabled = false
				BlackHoleScriptClone.Parent = humanoid
			else
				
				local BodyVelocity = Instance.new("BodyVelocity")
				BodyVelocity.Name = "PushBack"
				BodyVelocity.P = 100000
				BodyVelocity.maxForce = Vector3.new(BodyVelocity.P, BodyVelocity.P, BodyVelocity.P)
				BodyVelocity.velocity = (torso.Position - Torso.Position).unit * 50
				
				Debris:AddItem(BodyVelocity, 0.5)
				BodyVelocity.Parent = torso
				local creator = Instance.new("ObjectValue")
				creator.Name = "creator"
				creator.Value = Player
				creator.Parent = humanoid
				Debris:AddItem(creator, 1)
				
				humanoid:TakeDamage(LocalDamage)
			end
			PlaySound.Value = HitSounds[math.random(1,#HitSounds)]
		end
	end
end)

function Activate()
	if Equipped and (tick() - LastSwing) >= SwingRate then
		Ready = true
		PlaySound.Value = SwooshSounds[math.random(1,#SwooshSounds)]
		if AnimTrack then
			AnimTrack:Stop()
		end
		local TempAnims = {}
		for i, v in pairs(Anims) do
			if v ~= LastAnim then
				table.insert(TempAnims, v)
			end
		end
		NewAnim = TempAnims[math.random(1, #TempAnims)]
		LastAnim = NewAnim
		AnimTrack = Humanoid:LoadAnimation(NewAnim)
		if AnimTrack and Humanoid.Health > 0 then
			AnimTrack:Play(nil, nil, AnimSpeed)
		end
		LastSwing = tick()

		Tool.Enabled = false
		
		wait(SwingRate)
		
		Tool.Enabled = true
		
	end
end

function Equipped(Mouse)
	Equipped = true
	LastSwing = tick()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso")
	RightArm = Character:FindFirstChild("Right Arm")
	EquipAnim = Humanoid:LoadAnimation(Anims.Equip)
	if EquipAnim and Humanoid.Health > 0 then
		EquipAnim:Play(nil, nil, EquipSpeed)
	end
	if HoldAnim then
		HoldAnim:Stop()
	end
	HoldAnim = Humanoid:LoadAnimation(Anims.Hold)
	if HoldAnim and Humanoid.Health > 0 then
		HoldAnim:Play()
	end
end

function Unequipped()
	Equipped = false
	Ready = false
	if HoldAnim then
		HoldAnim:Stop()
	end
	if EquipAnim then
		EquipAnim:Stop()
	end
end

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)
Tool.Activated:connect(Activate)