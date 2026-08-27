--Made by Luckymaxer
-- Updated for R15 avatars by StarWars

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

BaseUrl = "rbxassetid://"

BasePart = Instance.new("Part")
BasePart.Shape = Enum.PartType.Block
BasePart.Material = Enum.Material.Plastic
BasePart.TopSurface = Enum.SurfaceType.Smooth
BasePart.BottomSurface = Enum.SurfaceType.Smooth
BasePart.Size = Vector3.new(0.2, 0.2, 0.2)
BasePart.CanCollide = true
BasePart.Locked = true
BasePart.Anchored = false

BaseDiamond = BasePart:Clone()
BaseDiamond.Name = "Diamond"
BaseDiamond.BrickColor = BrickColor.new("Really red")
BaseDiamond.Reflectance = 0.5
BaseDiamond.Size = Vector3.new(1.35, 1.35, 1.35)
BaseDiamond.CanCollide = false
DiamondMesh = Instance.new("SpecialMesh")
DiamondMesh.MeshType = Enum.MeshType.FileMesh
DiamondMesh.MeshId = (BaseUrl .. "9756362")
DiamondMesh.TextureId = ""
DiamondMesh.Scale = Vector3.new(1, 1, 1)
DiamondMesh.VertexColor = Vector3.new(1, 1, 1)
DiamondMesh.Offset = Vector3.new(0, 0, 0)
DiamondMesh.Parent = BaseDiamond

EnchantingCircle = BasePart:Clone()
EnchantingCircle.Name = "EnchantingCircle"
EnchantingCircle.Transparency = 1
EnchantingCircle.Size = Vector3.new(1, 1, 1)
EnchantingCircle.CanCollide = false
EnchantingDecal = Instance.new("Decal")
EnchantingDecal.Texture = (BaseUrl .. "212259445")
CircleMesh = Instance.new("BlockMesh")
CircleMesh.Parent= EnchantingCircle
TopDecal = EnchantingDecal:Clone()
TopDecal.Face = Enum.NormalId.Top
TopDecal.Parent = EnchantingCircle
BottomDecal = EnchantingDecal:Clone()
BottomDecal.Face = Enum.NormalId.Bottom
BottomDecal.Parent = EnchantingCircle

Animations = {
	Swing1 = {Animation = Tool.Animations.R6:WaitForChild("Swing1"), FadeTime = nil, Weight = nil, Speed = 1.5, Duration = 0.5, Damage = {Min = 15, Max = 25}},
	Swing2 = {Animation = Tool.Animations.R6:WaitForChild("Swing2"), FadeTime = nil, Weight = nil, Speed = 1.5, Duration = 0.5, Damage = {Min = 20, Max = 35}},
	JumpAttack = {Animation = Tool.Animations.R6:WaitForChild("JumpAttack"), FadeTime = nil, Weight = nil, Speed = 1.5, Duration = 0.5, Damage = {Min = 20, Max = 25}},
	Charge = {Animation = Tool.Animations.R6:WaitForChild("Charge"), FadeTime = nil, Weight = nil, Speed = 0.25, Duration = nil},
	
	R15Swing1 = {Animation = Tool.Animations.R15:WaitForChild("Swing1"), FadeTime = nil, Weight = nil, Speed = 1.5, Duration = 0.5, Damage = {Min = 15, Max = 25}},
	R15Swing2 = {Animation = Tool.Animations.R15:WaitForChild("Swing2"), FadeTime = nil, Weight = nil, Speed = 1.5, Duration = 0.5, Damage = {Min = 20, Max = 35}},
	R15JumpAttack = {Animation = Tool.Animations.R15:WaitForChild("JumpAttack"), FadeTime = nil, Weight = nil, Speed = 1.5, Duration = 0.5, Damage = {Min = 20, Max = 25}},
	R15Charge = {Animation = Tool.Animations.R15:WaitForChild("Charge"), FadeTime = nil, Weight = nil, Speed = 0.25, Duration = nil}	
}

Sounds = {
	Slash = Handle:WaitForChild("Slash"),
	Explosion = Handle:WaitForChild("Explosion"),
}

TouchDamage = {Min = 10, Max = 10}

ToolEquipped = false
Attacking = false
MouseDown = false
FullyCharged = false
SpecialActive = false
SpecialReloadTime = 20

Clicks = 0
FirstClick = false

Gravity = workspace.Gravity
Rate = (1 / 60)

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

for i, v in pairs(Tool:GetChildren()) do
	if v:IsA("BasePart") and v ~= Handle then
		v:Destroy()
	end
end

Tool.Enabled = true

function RayCast(Position, Direction, MaxDistance, IgnoreList)
	local IgnoreList = ((type(IgnoreList) == "table" and IgnoreList) or {IgnoreList})
	return game:GetService("Workspace"):FindPartOnRayWithIgnoreList(Ray.new(Position, Direction.unit * (MaxDistance or 5000)), IgnoreList)
end

function IsTeamMate(Player1, Player2)
	return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
end

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

function CheckTableForInstance(Table, Instance)
	for i, v in pairs(Table) do
		if v == Instance then
			return true
		end
	end
	return false
end

function Blow(Hit)
	if not Hit or not Hit.Parent or not CheckIfAlive() then
		return
	end
	
	local character = Hit.Parent
	
	local player = Players:GetPlayerFromCharacter(character)
	if player and IsTeamMate(Player, player) then
		return
	end
	
	local humanoid = character:FindFirstChild("Humanoid")
	if character == Character or not humanoid or humanoid.Health == 0 then
		return
	end
	
	local RightArm = Character:FindFirstChild("Right Arm") or Character:FindFirstChild("RightHand")
	if not RightArm then
		return
	end
	local RightGrip = RightArm:FindFirstChild("RightGrip")
	if not RightGrip or (RightGrip.Part0 ~= RightArm and RightGrip.Part1 ~= RightArm) then
		return
	end
	
	UntagHumanoid(humanoid)
	TagHumanoid(humanoid, Player)
	
	local DamageValue = ((CurrentAnimation and CurrentAnimation.Damage) or TouchDamage)
	local DamageAmount = math.random(DamageValue.Min, DamageValue.Max)
	
	humanoid:TakeDamage(DamageAmount)
	
end

function Attack(PossibleAnims, PossibleSounds)
	if PossibleAnims and #PossibleAnims > 0 then
		if PossibleSounds and #PossibleSounds > 0 then
			PossibleSounds[math.random(1, #PossibleSounds)]:Play()
		end 
		CurrentAnimation = PossibleAnims[math.random(1, #PossibleAnims)]
		InvokeClient("PlayAnimation", CurrentAnimation)
		if CurrentAnimation.Duration and CurrentAnimation.Duration > 0 then
			wait(CurrentAnimation.Duration)
			CurrentAnimation = nil
		end
	end
end

function MotionEffect()
	local TransparencyRate = 100
	local OriginalTransparency = 0.75
	while ToolEquipped and Attacking do
		local FakeHandle = Handle:Clone()
		for i, v in pairs(FakeHandle:GetChildren()) do
			if not v:IsA("DataModelMesh") then
				v:Destroy()
			end
		end
		FakeHandle.Name = "FakeHandle"
		FakeHandle.Anchored = true
		FakeHandle.CanCollide = false
		FakeHandle.Locked = true
		FakeHandle.Transparency = OriginalTransparency
		Spawn(function()
			for i = 1, (FakeHandle.Transparency * TransparencyRate) do
				FakeHandle.Transparency = FakeHandle.Transparency + (OriginalTransparency / TransparencyRate)
				wait(Rate)
			end
			if FakeHandle and FakeHandle.Parent then
				FakeHandle:Destroy()
			end
		end)
		Debris:AddItem(FakeHandle, 5)
		FakeHandle.Parent = Tool
		wait(Rate)
	end
end

function Activated()
	if not Tool.Enabled or not ToolEquipped then
		return
	end
	Attacking = true
	Clicks = (Clicks + 1)
	if not FirstClick then
		FirstClick = true
		local CurrentlyEquipped = true
		ToolUnequipped = Tool.Unequipped:connect(function()
			CurrentlyEquipped = false
		end)
		wait(0.15)
		if ToolUnequipped then
			ToolUnequipped:disconnect()
		end
		if not CurrentlyEquipped then
			return
		end
		Tool.Enabled = false
		Attacking = true
		Spawn(MotionEffect)
		local AttackAnims = {}
		local AttackSounds = {}
		if MouseDown and Clicks == 1 and not SpecialActive then
			local ChargeAnim = Animations.Charge
			if Humanoid and Humanoid.RigType == Enum.HumanoidRigType.R15 then
				ChargeAnim = Animations.R15Charge
			end
			AttackAnims = {ChargeAnim}
			Spawn(function()
				if not SpecialActive then
					local MaxChargeTime = 15
					local FullyChargedTime = 3
					local ChargeTick = tick()
					local DiamondTick = tick()
					local DiamondRadius = 12
					local DiamondOffset = 6
					local DiamondVelocity = 50
					local CreatedCircle = false
					EnchantmentCircle = EnchantingCircle:Clone()
					EnchantmentCircle.Mesh.Scale = Vector3.new(DiamondRadius, 0.2, DiamondRadius)
					while MouseDown and ToolEquipped and CheckIfAlive() and (tick() - ChargeTick) < MaxChargeTime do
						if not FullyCharged and (tick() - ChargeTick) >= FullyChargedTime then
							FullyCharged = true
						elseif FullyCharged then
							if EnchantmentCircle and EnchantmentCircle.Parent then
								local Weld = EnchantmentCircle:FindFirstChild("CircleMotor")
								if not Weld or not Weld.Part0 or not Weld.Part1 then
									if Weld and Weld.Parent then
										Weld:Destroy()
									end
									Weld = Instance.new("Motor6D")
									Weld.Name = "CircleMotor"
									Weld.Part0 = EnchantmentCircle
									Weld.Part1 = Torso
									Weld.C0 = CFrame.new(0, ((Torso.Size.Y * 1.5)), 0) * CFrame.Angles((math.pi / 2), 0, 0)
									Weld.C1 = CFrame.new() * CFrame.Angles((math.pi / 2), 0, 0)
									Weld.DesiredAngle = 999999
									Weld.MaxVelocity = 0.02
									Weld.Parent = EnchantmentCircle
								end
							end
							if not CreatedCircle then
								CreatedCircle = true
								EnchantmentCircle.Parent = Tool
								EnchantmentCircle.CFrame = Torso.CFrame
							end
							if (tick() - DiamondTick) >= 0.5 then
								DiamondTick = tick()
								for i = 1, math.random(1, 1) do
									local Diamond = BaseDiamond:Clone() 
									local DiamondSize = (math.random(500, 1500) * 0.001)
									local DiamondHeight = (math.random(3000, 5000) * 0.001)
									Diamond.Size = Vector3.new(DiamondSize, DiamondHeight, DiamondSize)
									Diamond.Mesh.Scale = (BaseDiamond.Size * Diamond.Size)
									Diamond.CFrame = Torso.CFrame + (Torso.CFrame * CFrame.Angles(0, math.random(-360, 360), 0)).lookVector * ((DiamondRadius / 2) - (math.random(0, (DiamondOffset * 1000)) * 0.001))
									local Mass = (Diamond:GetMass() * Gravity)
									local BodyGyro = Instance.new("BodyGyro")
									BodyGyro.maxTorque = Vector3.new(0, 0, 0)
									BodyGyro.cframe = Diamond.CFrame
									BodyGyro.Parent = Diamond
									local BodyVelocity = Instance.new("BodyVelocity")
									BodyVelocity.maxForce = Vector3.new(0, Mass, 0)
									BodyVelocity.velocity = (Vector3.new(0, 1, 0) * DiamondVelocity)
									BodyVelocity.Parent = Diamond
									Diamond.Velocity = (Vector3.new(0, 1, 0) * DiamondVelocity)
									local Touched = false
									Diamond.Touched:connect(function(Hit)
										if not Hit or not Hit.Parent or Touched then
											return
										end
										local character = Hit.Parent
										if character:IsA("Accessory") then
											character = character.Parent
										end
										if character == Character then
											return
										end
										local player = Players:GetPlayerFromCharacter(character)
										if player and IsTeamMate(Player, player) then
											return
										end
										local humanoid = character:FindFirstChild("Humanoid")
										if not humanoid or humanoid.Health == 0 then
											return
										end
										UntagHumanoid(humanoid)
										TagHumanoid(humanoid, Player)
										humanoid:TakeDamage(12.5)
										Touched = true
									end)
									Debris:AddItem(Diamond, 2)
									Diamond.Parent = game:GetService("Workspace")
								end
							end
						end
						wait(Rate)
					end
					if (tick() - ChargeTick) >= MaxChargeTime then
						FullyCharged = false
						Spawn(function()
							local Animation = Animations.Charge
							if Humanoid and Humanoid.RigType == Enum.HumanoidRigType.R15 then
								Animation = Animations.R15Charge
							end
							InvokeClient("StopAnimation", Animation)
						end)
						SpecialActive = true
						Delay((SpecialReloadTime / 2), (function()
							SpecialActive = false
						end))
					end
					if EnchantmentCircle and EnchantmentCircle.Parent then
						EnchantmentCircle:Destroy()
					end
				end
			end)
		else
			AttackSounds = {Sounds.Slash}
			AttackAnims = {Animations.Swing1, Animations.Swing2}
			if Humanoid and Humanoid.RigType == Enum.HumanoidRigType.R15 then
				AttackAnims = {Animations.R15Swing1, Animations.R15Swing2}
			end
		end
		Attack(AttackAnims, AttackSounds)
		FirstClick = false
		Clicks = 0
		Attacking = false
		Tool.Enabled = true
	end
end

function CheckIfAlive()
	return (((Player and Player.Parent and Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent) and true) or false)
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("HumanoidRootPart")
	if not CheckIfAlive() then
		return
	end
	local CurrentlyEquipped = true
	EquippedToolUnequipped = Tool.Unequipped:connect(function()
		CurrentlyEquipped = false
	end)
	if EquippedToolUnequipped then
		EquippedToolUnequipped:disconnect()
	end
	if not CurrentlyEquipped then
		return
	end
	MouseDown = false
	ToolEquipped = true
end

function Unequipped()
	Clicks = 0
	FirstClick = false
	FullyCharged = false
	Attacking = false
	MouseDown = false
	SpecialActive = false
	if EnchantmentCircle and EnchantmentCircle.Parent then
		EnchantmentCircle:Destroy()
	end
	for i, v in pairs({EquippedToolUnequipped, ToolUnequipped}) do
		if v then
			v:disconnect()
		end
	end
	Spawn(function()
		for i, v in pairs(Animations) do
			InvokeClient("StopAnimation", v)
		end
	end)
	ToolEquipped = false
end

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
end

ServerControl.OnServerInvoke = (function(player, Mode, Value)
	if player == Player and ToolEquipped and CheckIfAlive() then
		if Mode == "MouseClick" then
			local Down = Value.Down
			if Down and not MouseDown then
				MouseDown = true
				Activated()
			elseif not Down and MouseDown then
				MouseDown = false
				local Animation = Animations.Charge
				if Humanoid.RigType == Enum.HumanoidRigType.R15 then
					Animation = Animations.R15Charge
				end
				InvokeClient("StopAnimation", Animations.Charge)
				if FullyCharged and not SpecialActive then
					if CurrentAnimation == Animation and FullyCharged then
						SpecialActive = true
						FullyCharged = false
						local JumpAnim = Animations.JumpAttack
						if Humanoid.RigType == Enum.HumanoidRigType.R15 then
							JumpAnim = Animations.R15JumpAttack
						end
						local AttackAnims = {JumpAnim}
						local AttackSounds = {Sounds.Explosion}
						Attack(AttackAnims, AttackSounds)
						local BigDiamond = BaseDiamond:Clone()
						BigDiamond.Anchored = true
						BigDiamond.Size = Vector3.new(10, 10, 10)
						BigDiamond.Mesh.Scale = (BaseDiamond.Size * BigDiamond.Size)
						BigDiamond.CFrame = Torso.CFrame + Torso.CFrame.lookVector * ((Torso.Size.Z / 2) + BigDiamond.Size.Z)
						local ExplosionSound = Sounds.Explosion:Clone()
						ExplosionSound.Parent = BigDiamond
						Debris:AddItem(BigDiamond, 5)
						BigDiamond.Parent = game:GetService("Workspace")
						Delay(1, function()
							ExplosionSound:Play()
							BigDiamond.Transparency = 1
							Delay(1, function()
								if BigDiamond and BigDiamond.Parent then
									BigDiamond:Destroy()
								end
							end)
							local DiamondCFrame = BigDiamond.CFrame
							local DiamondVelocity = 200
							for i = 1, math.random(75, 100) do
								local Diamond = BaseDiamond:Clone()
								local DiamondSize = (math.random(3000, 5000) * 0.001)
								local DiamondHeight = (math.random(3000, 5000) * 0.001)
								Diamond.Size = Vector3.new(DiamondSize, DiamondHeight, DiamondSize)
								Diamond.Mesh.Scale = (BaseDiamond.Size * Diamond.Size)
								Diamond.CFrame = DiamondCFrame * CFrame.Angles((math.random(-3600, 3600) * 0.001), (math.random(-3600, 3600) * 0.001), (math.random(-3600, 3600) * 0.001))
								local Direction = (Diamond.CFrame * CFrame.Angles((math.pi / 2), 0, 0)).lookVector
								local BodyGyro = Instance.new("BodyGyro")
								BodyGyro.maxTorque = Vector3.new(0, 0, 0)
								BodyGyro.cframe = Diamond.CFrame
								BodyGyro.Parent = Diamond
								local Mass = (Diamond:GetMass() * Gravity)
								local BodyVelocity = Instance.new("BodyVelocity")
								BodyVelocity.maxForce = Vector3.new(0, Mass, 0)
								BodyVelocity.velocity = (Direction * DiamondVelocity)
								BodyVelocity.Parent = Diamond
								Diamond.Velocity = (Direction * DiamondVelocity)
								Diamond.Touched:connect(function(Hit)
									if not Hit or not Hit.Parent then
										return
									end
									local character = Hit.Parent
									if character:IsA("Accessory") then
										character = character.Parent
									end
									if character == Character then
										return
									end
									local player = Players:GetPlayerFromCharacter(character)
									if player and IsTeamMate(Player, player) then
										return
									end
									local humanoid = character:FindFirstChild("Humanoid")
									if not humanoid or humanoid.Health == 0 then
										return
									end
									UntagHumanoid(humanoid)
									TagHumanoid(humanoid, Player)
									humanoid:TakeDamage(50)
								end)
								Debris:AddItem(Diamond, 0.75)
								Diamond.Parent = game:GetService("Workspace")
							end
						end)
						wait(SpecialReloadTime)
						SpecialActive = false
					end
				end
			end
		end
	end
end)

Handle.Touched:connect(Blow)

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)
workspace:GetPropertyChangedSignal("Gravity"):Connect(function()
	Gravity = workspace.Gravity
end)