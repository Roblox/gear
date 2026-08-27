--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

BasePart = Instance.new("Part")
BasePart.Shape = Enum.PartType.Block
BasePart.Material = Enum.Material.Plastic
BasePart.TopSurface = Enum.SurfaceType.Smooth
BasePart.BottomSurface = Enum.SurfaceType.Smooth
BasePart.FormFactor = Enum.FormFactor.Custom
BasePart.Size = Vector3.new(0.2, 0.2, 0.2)
BasePart.CanCollide = true
BasePart.Locked = true
BasePart.Anchored = false

Animations = {
	LeftSlash = {Animation = Tool:WaitForChild("LeftSlash"), FadeTime = nil, Weight = nil, Speed = nil, Duration = 0.75, Damage = 15},
	RightSlash = {Animation = Tool:WaitForChild("RightSlash"), FadeTime = nil, Weight = nil, Speed = nil, Duration = 0.75, Damage = 15},
}

Sounds = {
	Unsheath = Handle:WaitForChild("Unsheath"),
	Slash = Handle:WaitForChild("Slash"),
	Lunge = Handle:WaitForChild("Lunge"),
	ShockWave = Handle:WaitForChild("ShockWave")
}

Gravity = 196.20

Damage = 5

Equipped = false

SecondaryAttack = {
	Enabled = true,
	Active = false,
	ReloadTime = 5
}

CurrentAnimation = nil

SpecialAttacks = {
	Enabled = true,
	Active = false,
	ReloadTime = 5,
	Strike = {
		Enabled = true,
		Active = false,
		Duration = 20,
		ReloadTime = 20,
		Damage = 5,
	},
	Throw = {
		Enabled = true,
		Active = false,
		ReloadTime = 20,
		Damage = 5,
		TouchDamage = 15,
		Damage = 5,
		Radius = 50
	}
}

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

Tool.Enabled = true

ServerControl.OnServerInvoke = (function(player, Mode, Value)
	if player == Player and Equipped and CheckIfAlive() then
		if Mode == "KeyPress" and SpecialAttacks.Enabled and not SpecialAttacks.Active and Tool.Enabled then
			local Key = Value.Key
			local Down = Value.Down
			local SpecialAttack = nil
			if Key == "q" and Down then
				
				SpecialAttack = SpecialAttacks.Strike
				
				if SpecialAttack.Enabled and not SpecialAttack.Active then
				
					SpecialAttacks.Enabled = false
					SpecialAttacks.Active = true
						
					SpecialAttack.Enabled = false
					SpecialAttack.Active = true
					
					local CurrentlyEquipped = true
					if ActivatedToolUnequipped then
						ActivatedToolUnequipped:disconnect()
					end
					ActivatedToolUnequipped = Tool.Unequipped:connect(function()
						CurrentlyEquipped = false
						if ActivatedToolUnequipped then
							ActivatedToolUnequipped:disconnect()
						end
					end)
					local MousePosition = InvokeClient("MousePosition")
					local Swords = {}
					local SwordClone = Handle:Clone()
					SwordClone.Name = "Sword"
					SwordClone.Size = (SwordClone.Size * 2)
					SwordClone.Mesh.Scale = (SwordClone.Mesh.Scale * 2)
					SwordClone.CanCollide = true
					table.insert(Swords, SwordClone)
					for i = 1, math.random(75, 100) do
						local SecondarySword = SwordClone:Clone()
						SecondarySword.Size = (SecondarySword.Size / 4)
						SecondarySword.Mesh.Scale = (SecondarySword.Mesh.Scale / 4)
						table.insert(Swords, SecondarySword)
					end
					local OriginalStartPosition = Head.Position + Vector3.new(0, 1, 0) * 25
					for i, v in pairs(Swords) do
						if v then
							local Mass = (v:GetMass() * Gravity * 2)
							local BodyPosition = Instance.new("BodyPosition")
							BodyPosition.maxForce = Vector3.new(Mass, Mass, Mass)
							BodyPosition.position = OriginalStartPosition
							BodyPosition.Parent = v
							local BodyGyro = Instance.new("BodyGyro")
							BodyGyro.maxTorque = Vector3.new(math.huge, math.huge, math.huge)
							BodyGyro.Parent = v
							local BodyVelocity = Instance.new("BodyVelocity")
							BodyVelocity.maxForce = Vector3.new(0, 0, 0)
							BodyVelocity.Parent = v
							local Radius = 10
							local Offset = ((v ~= SwordClone and Vector3.new((math.random(-(Radius * 100), (Radius * 100)) * 0.01), (math.random(-(Radius * 100), (Radius * 100)) * 0.01), (math.random(-(Radius * 100), (Radius * 100)) * 0.01))) or Vector3.new(0, 0, 0))
							Swords[i] = {Sword = v, Mass = Mass, BodyPosition = BodyPosition, BodyGyro = BodyGyro, BodyVelocity = BodyVelocity, Offset = Offset}
							v.CFrame = CFrame.new(OriginalStartPosition + Offset)
							Debris:AddItem(v, 30)
							v.Parent = game:GetService("Workspace")
						end
					end
					local WaitTick = tick()
					while (tick() - WaitTick) < 3 and CurrentlyEquipped do
						MousePosition = InvokeClient("MousePosition")
						for i, v in pairs(Swords) do
							if v.Sword and v.Sword.Parent then
								local StartPosition = (Vector3.new(Head.Position.X, OriginalStartPosition.Y, Head.Position.Z) + v.Offset)
								local Direction = CFrame.new(StartPosition, MousePosition)
								v.BodyPosition.position = StartPosition
								v.BodyVelocity.velocity = Direction.lookVector * 250
								v.BodyGyro.cframe = Direction
							end
						end
						wait()
					end
					if CurrentlyEquipped then
						for i, v in pairs(Swords) do
							if v.Sword and v.Sword.Parent then
								local Untouched = true
								v.Sword.Touched:connect(function(Hit)
									if not Hit or not Hit.Parent or Hit.Name == "Sword" then
										return
									end
									local character = Hit.Parent
									if character:IsA("Hat") or character:IsA("Tool") then
										character = character.Parent
									end
									if character == Character then
										return
									end
									local humanoid = character:FindFirstChild("Humanoid")
									if humanoid and humanoid.Health > 0 then
										UntagHumanoid(humanoid)
										TagHumanoid(humanoid, Player)
										humanoid:TakeDamage(((v.Sword == SwordClone and humanoid.MaxHealth) or SpecialAttack.Damage))
									end
									if Untouched then
										local BodyPosition = Instance.new("BodyPosition")
										BodyPosition.maxForce = Vector3.new(math.huge, math.huge, math.huge)
										BodyPosition.position = v.Sword.Position
										BodyPosition.Parent = v.Sword
										v.Sword.Velocity = Vector3.new(0, 0, 0)
										v.Sword.RotVelocity = Vector3.new(0, 0, 0)
										Untouched = false
									end
								end)
							end
						end
						for i = 1, #Swords do
							for ii = 1, math.random(2, 10) do
								local v = Swords[ii]
								if v and v.Sword and v.Sword.Parent then
									v.Sword.CFrame = CFrame.new(v.Sword.Position, MousePosition)
									v.BodyVelocity.maxForce = Vector3.new(v.Mass, v.Mass, v.Mass)
									v.Sword.Velocity = (v.BodyVelocity.velocity / 2)
									if v.BodyPosition and v.BodyPosition.Parent then
										v.BodyPosition:Destroy()
									end
								end
								table.remove(Swords, ii)
							end
							wait(0.1)
						end
						Delay(3, function()
							for i, v in pairs(Swords) do
								if v.Sword and v.Sword.Parent then
									v.Sword:Destroy()
								end
							end
						end)
					else
						for i, v in pairs(Swords) do
							if v.Sword and v.Sword.Parent then
								v.Sword:Destroy()
							end
						end
					end
					SpecialAttack.Active = false
					SpecialAttacks.Active = false
					Delay(SpecialAttack.ReloadTime, function()
						SpecialAttack.Enabled = true
					end)
				end
			elseif Key == "e" and Down then
				
				SpecialAttack = SpecialAttacks.Throw
				
				if SpecialAttack.Enabled and not SpecialAttack.Active then
				
					SpecialAttacks.Enabled = false
					SpecialAttacks.Active = true
						
					SpecialAttack.Enabled = false
					SpecialAttack.Active = true
					
					local CurrentlyEquipped = true
					if ActivatedToolUnequipped then
						ActivatedToolUnequipped:disconnect()
					end
					ActivatedToolUnequipped = Tool.Unequipped:connect(function()
						CurrentlyEquipped = false
						if ActivatedToolUnequipped then
							ActivatedToolUnequipped:disconnect()
						end
					end)
					
					local MousePosition = InvokeClient("MousePosition")
					local Distance = (Handle.Position - MousePosition).magnitude
					SwordClone = Handle:Clone()
					SwordClone.Name = "Sword"
					SwordClone.CanCollide = true
					SwordClone.Size = (SwordClone.Size * 3)
					SwordClone.Mesh.Scale = (SwordClone.Mesh.Scale * 3)
					local Mass = (SwordClone:GetMass() * Gravity * 2)
					local BodyPosition = Instance.new("BodyPosition")
					BodyPosition.maxForce = Vector3.new(math.huge, math.huge, math.huge)
					BodyPosition.position = Head.Position + Vector3.new(0, 1, 0) * (Distance / 2)
					BodyPosition.position = BodyPosition.position + CFrame.new(BodyPosition.position, Vector3.new(MousePosition.X, BodyPosition.position.Y, MousePosition.Z)).lookVector * (Distance / 2)
					BodyPosition.Parent = SwordClone
					local BodyGyro = Instance.new("BodyGyro")
					BodyGyro.maxTorque = Vector3.new(math.huge, math.huge, math.huge)
					BodyGyro.cframe = CFrame.new(SwordClone.Position) * CFrame.Angles(-(math.pi / 2), 0, 0)
					BodyGyro.Parent = SwordClone
					SwordClone.CFrame = Handle.CFrame
					Debris:AddItem(SwordClone, 20)
					SwordClone.Parent = game:GetService("Workspace")
					wait(5)
					if CurrentlyEquipped then
						local Direction = CFrame.new(SwordClone.Position, MousePosition)
						BodyGyro.cframe = Direction
						local BodyVelocity = Instance.new("BodyVelocity")
						BodyVelocity.maxForce = Vector3.new(Mass, Mass, Mass)
						BodyVelocity.velocity = Direction.lookVector * 500
						SwordClone.Velocity = BodyVelocity.velocity
						if BodyPosition and BodyPosition.Parent then
							BodyPosition:Destroy()
						end
						local Untouched = true
						SwordClone.Touched:connect(function(Hit)
							if not Hit or not Hit.Parent or Hit.Name == "Sword" then
								return
							end
							local character = Hit.Parent
							if character:IsA("Hat") or character:IsA("Tool") then
								character = character.Parent
							end
							if character == Character then
								return
							end
							local humanoid = character:FindFirstChild("Humanoid")
							if humanoid and humanoid.Health > 0 then
								UntagHumanoid(humanoid)
								TagHumanoid(humanoid, Player)
								humanoid:TakeDamage(SpecialAttack.TouchDamage)
							end
							if Untouched then
								Untouched = false
								local BodyPosition = Instance.new("BodyPosition")
								BodyPosition.maxForce = Vector3.new(math.huge, math.huge, math.huge)
								BodyPosition.position = SwordClone.Position
								BodyPosition.Parent = SwordClone
								SwordClone.Velocity = Vector3.new(0, 0, 0)
								SwordClone.RotVelocity = Vector3.new(0, 0, 0)
								local ShockWave = BasePart:Clone()
								ShockWave.Name = "ShockWave"
								ShockWave.Transparency = 1
								ShockWave.Size = Vector3.new(0.2, 4, 0.2)
								ShockWave.Anchored = true
								ShockWave.CanCollide = false
								local Mesh = Instance.new("SpecialMesh")
								Mesh.MeshType = Enum.MeshType.Brick
								Mesh.Scale = Vector3.new(1, 0, 1)
								Mesh.Parent = ShockWave
								local ShockWaveTransparency = 0.125
								for i = 1, 2 do
									local Decal = Instance.new("Decal")
									Decal.Texture = "http://www.roblox.com/asset?id=183210124"
									Decal.Transparency = ShockWaveTransparency
									Decal.Face = ((i == 1 and Enum.NormalId.Top) or Enum.NormalId.Bottom)
									Decal.Parent = ShockWave
								end
								
								local ShockWaveCFrame = (CFrame.new(SwordClone.Position) - Vector3.new(0, (SwordClone.Size.Z / 4), 0)) * CFrame.Angles(math.pi, 0, 0)
								
								Debris:AddItem(ShockWave, 5)
								
								local Sound = Sounds.ShockWave:Clone()
								Sound.Parent = SwordClone
								Sound:Play()
								
								ShockWave.Parent = game:GetService("Workspace")
								ShockWave.CFrame = CFrame.new(Handle.Position)
								
								ShockWave.Touched:connect(function(Hit)		
									if not Hit or not Hit.Parent then
										return
									end
									local character = Hit.Parent
									if character:IsA("Hat") or character:IsA("Tool") then
										character = character.Parent
									end
									if character == Character then
										return
									end
									local humanoid = character:FindFirstChild("Humanoid")
									local torso = character:FindFirstChild("Torso")
									if not humanoid or humanoid.Health == 0 or not Torso then
										return
									end
									UntagHumanoid(humanoid)
									TagHumanoid(humanoid, Player)
									humanoid:TakeDamage(SpecialAttack.Damage)
									humanoid.Sit = true
									local PushBack = CFrame.new(torso.Position, ShockWave.Position).lookVector * -50
									PushBack = Vector3.new(PushBack.X, -math.random(10, 50), PushBack.Z)
									torso.Velocity = PushBack
								end)				
								
								local Radius = 50
								local Transparency = (1 - ShockWaveTransparency)
								for i = 1, 25 do
									if ShockWave and ShockWave.Parent then
										local RadiusSize = ((SpecialAttack.Radius / 25) * i)
										for ii, vv in pairs(ShockWave:GetChildren()) do
											if vv:IsA("Decal") then
												vv.Transparency = ((Transparency / 25) * i)
											end
										end
										ShockWave.Size = Vector3.new(RadiusSize, ShockWave.Size.Y, RadiusSize)
										ShockWave.CFrame = ShockWaveCFrame
									end
									wait(0.025)
								end
								if ShockWave and ShockWave.Parent then
									ShockWave:Destroy()
								end
							end
						end)
						BodyPosition.position = MousePosition
					end
					SpecialAttack.Active = false
					SpecialAttacks.Active = false
					Delay(SpecialAttack.ReloadTime, function()
						SpecialAttack.Enabled = true
					end)
				end
			end
			if SpecialAttack then
				wait(SpecialAttacks.ReloadTime)
				SpecialAttacks.Enabled = true
			end
		end
	end
end)

function InvokeClient(Mode, Value)
	local ReturnValue = nil
	pcall(function()
		ReturnValue = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ReturnValue
end

function RayCast(Position, Direction, MaxDistance, IgnoreList)
	return game:GetService("Workspace"):FindPartOnRayWithIgnoreList(Ray.new(Position, Direction.unit * (MaxDistance or 999.999)), IgnoreList) 
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

function Blow(Part)
	Part.Touched:connect(function(Hit)
		if not Hit or not Hit.Parent or not Equipped or not CheckIfAlive() or SpecialAttacks.Active then
			return
		end
		local RightArm = Character:FindFirstChild("Right Arm")
		if not RightArm then
			return
		end
		local RightGrip = RightArm:FindFirstChild("RightGrip")
		if not RightGrip or (RightGrip.Part0 ~= Handle and RightGrip.Part1 ~= Handle) then
			return
		end
		local character = Hit.Parent
		local humanoid = character:FindFirstChild("Humanoid")
		if character ~= Character and humanoid and humanoid.Health > 0 then
			local DamageValue = ((CurrentAnimation and CurrentAnimation.Damage) or Damage)
			UntagHumanoid(humanoid)
			TagHumanoid(humanoid, Player)
			humanoid:TakeDamage(DamageValue)
		end
	end)
end

function Activated()
	if not Tool.Enabled or not Equipped or SecondaryAttack.Active or SpecialAttacks.Active then
		return
	end
	local CurrentlyEquipped = true
	ToolUnequipped = Tool.Unequipped:connect(function()
		CurrentlyEquipped = false
	end)
	Tool.Enabled = false
	local SlashAnims = {Animations.LeftSlash, Animations.RightSlash}
	local SlashAnim = SlashAnims[math.random(1, #SlashAnims)]
	CurrentAnimation = SlashAnim
	InvokeClient("PlayAnimation", CurrentAnimation)
	InvokeClient("PlaySound", Sounds.Slash)
	wait(CurrentAnimation.Duration)
	if not CurrentlyEquipped then
		return
	end
	InvokeClient("StopAnimation", CurrentAnimation)
	CurrentAnimation = nil
	InvokeClient("DisableJump", false)
	InvokeClient("StopAnimation", CurrentAnimation)
	CurrentAnimation = nil
	Tool.Enabled = true
end
function CheckIfAlive()
	return (Player and Player.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Head and Head.Parent and Torso and Torso.Parent)
end

function Equipped(Mouse)
	Equipped = true
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Head = Character:WaitForChild("Head")
	Torso = Character:FindFirstChild("Torso")
	if not CheckIfAlive() then
		return
	end
	Sounds.Unsheath:Play()
end

function Unequipped()
	Equipped = false
	CurrentAnimation = nil
	for i, v in pairs({ToolUnequipped, ActivatedToolUnequipped}) do
		if v then
			v:disconnect()
		end
	end
	if SwordClone and SwordClone.Parent then
		SwordClone:Destroy()
	end
	for i, v in pairs(Animations) do
		if v and v.Parent then
			InvokeClient("StopAnimation", v)
		end
	end
	for i, v in pairs(Sounds) do
		if v and v.Parent then
			v:Stop()
			InvokeClient("StopSound", v)
		end
	end
end

Blow(Handle)

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)