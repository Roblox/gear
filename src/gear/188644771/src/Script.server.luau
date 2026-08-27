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
	LeftSwing = {Animation = Tool:WaitForChild("LeftSwing"), FadeTime = nil, Weight = nil, Speed = 2, Duration = 0.75},
	RightSwing = {Animation = Tool:WaitForChild("RightSwing"), FadeTime = nil, Weight = nil, Speed = 2, Duration = 0.75},
	KickHit = {Animation = Tool:WaitForChild("KickHit"), FadeTime = nil, Weight = nil, Speed = 1.5, Duration = 0.75},
	ArmsUp = {Animation = Tool:WaitForChild("ArmsUp"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil},
	ArmsOut = {Animation = Tool:WaitForChild("ArmsOut"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil}
}

Sounds = {
}

Damage = {
	Hit = 6,
	Swing = 16,
}

SpecialAttacks = {
	Enabled = true,
	Active = false,
	ReloadTime = 5,
	Rise = {
		Damage = 15,
		ReloadTime = 60,
		Duration = 60,
		Enabled = true,
		Active = false,
		SkeletalRemains = {
			{Name = "HornedVelociraptorSkull", Size = Vector3.new(1.5, 1.75, 2.25), MeshId = "http://www.roblox.com/asset/?id=14028428", TextureId = "http://www.roblox.com/asset/?id=14027832", Scale = Vector3.new(1, 1, 1), VertexColor = Vector3.new(1, 1, 1)},
			{Name = "TriceratopsSkull", Size = Vector3.new(2, 2, 3), MeshId = "http://www.roblox.com/asset/?id=13157130", TextureId = "http://www.roblox.com/asset/?id=13157137", Scale = Vector3.new(1, 1, 1), VertexColor = Vector3.new(1, 1, 1)},
			{Name = "RiddlingSkull", Size = Vector3.new(1.5, 1.5, 1.75), MeshId = "http://www.roblox.com/asset/?id=4770583", TextureId = "http://www.roblox.com/asset/?id=4770560", Scale = Vector3.new(3.2, 3.2, 3.2), VertexColor = Vector3.new(1, 1, 1)},
			{Name = "SkeletalTorsoRemains", Size = Vector3.new(1.5, 1.5, 1.75), MeshId = "http://www.roblox.com/asset/?id=36780113", TextureId = "http://www.roblox.com/asset/?id=187949411", Scale = Vector3.new(1, 1, 1), VertexColor = Vector3.new(1, 1, 1)},
			{Name = "SkeletalRightArmRemains", Size = Vector3.new(0.5, 2, 0.5), MeshId = "http://www.roblox.com/asset/?id=36780156", TextureId = "http://www.roblox.com/asset/?id=187949411", Scale = Vector3.new(1, 1, 1), VertexColor = Vector3.new(1, 1, 1)},
			{Name = "SkeletalLeftArmRemains", Size = Vector3.new(0.5, 2, 0.5), MeshId = "http://www.roblox.com/asset/?id=36780032", TextureId = "http://www.roblox.com/asset/?id=187949411", Scale = Vector3.new(1, 1, 1), VertexColor = Vector3.new(1, 1, 1)},
			{Name = "SkeletalRightLegRemains", Size = Vector3.new(0.5, 2, 0.5), MeshId = "http://www.roblox.com/asset/?id=36780195", TextureId = "http://www.roblox.com/asset/?id=187949411", Scale = Vector3.new(1, 1, 1), VertexColor = Vector3.new(1, 1, 1)},
			{Name = "SkeletalLeftLegRemains", Size = Vector3.new(0.5, 2, 0.5), MeshId = "http://www.roblox.com/asset/?id=36780079", TextureId = "http://www.roblox.com/asset/?id=187949411", Scale = Vector3.new(1, 1, 1), VertexColor = Vector3.new(1, 1, 1)}
		}
	},
	Uprise = {
		Radius = 25,
		Damage = 10,
		Duration = 15,
		ReloadTime = 45,
		Enabled = true,
		Active = false
	}
}

ReloadTime = 0.25

Clicks = 0
FirstClick = false

Gravity = 196.20

ToolEquipped = false

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

Handle.Transparency = 0
Tool.Enabled = true

ServerControl.OnServerInvoke = (function(player, Mode, Value)
	if player == Player then
		if Mode == "MouseClick" and Value.Down then
			Activated()
		elseif Mode == "KeyPress" and SpecialAttacks.Enabled and not SpecialAttacks.Active then
			local Key = Value.Key
			local ByteKey = string.byte(Key)
			local Down = Value.Down
			if Key == "x" and Down then
				SpecialAttack = SpecialAttacks.Rise
				if SpecialAttack.Enabled then
					SpecialAttacks.Enabled = false
					SpecialAttacks.Active = true
						
					SpecialAttack.Enabled = false
					SpecialAttack.Active = true
					
					local CurrentlyEquipped = true
					ToolUnequipped = Tool.Unequipped:connect(function()
						CurrentlyEquipped = false
					end)

					local RayHit, RayPos = RayCast(Torso.Position, Vector3.new(0, -1, 0), (Torso.Size.Y * 2), {Character})
					
					if RayHit and CurrentlyEquipped then
						local Animation = Animations.ArmsUp
						InvokeClient("PlayAnimation", Animation)
					
						local SkeletalRemainsPile = Instance.new("Model")
						SkeletalRemainsPile.Name = "SkeletalRemainsPile"
						local SpawnPosition = RayPos
						
						Debris:AddItem(SkeletalRemainsPile, SpecialAttack.Duration)
						SkeletalRemainsPile.Parent = game:GetService("Workspace")
						
						local CurrentPlayer = Player
						local CurrentCharacter = Character
						
						local Parts = {}
						local SkeletalRemains = SpecialAttack.SkeletalRemains
						local Rows = 20
						for i = 1, Rows do
							local NumberParts = (i * 1.25)
							local InsideRow = {}
							for ii = 1, NumberParts do
								local FillInParts = Round((i / 1), 0.5)
								for iii = 1, FillInParts do
									local Part = BasePart:Clone()
									local ObjectChosen = SkeletalRemains[math.random(1, #SkeletalRemains)]
									if i == 1 then --Make sure the top of the pile has a skull
										local SkeletonHeads = {SkeletalRemains[1], SkeletalRemains[2], SkeletalRemains[3]}
										ObjectChosen = SkeletonHeads[math.random(1, #SkeletonHeads)]
									end
									if (i > 12 and iii < (FillInParts - 10)) then
										table.insert(InsideRow, Part)
									else
										table.insert(Parts, Part)
									end
									if iii > (FillInParts - 3) then --Only make the outer layer of parts deadly
										Part.Touched:connect(function(Hit)
											if not Hit or not Hit.Parent then
												return
											end
											local character = Hit.Parent
											if CurrentCharacter == character then
												return
											end
											local humanoid = character:FindFirstChild("Humanoid")
											if humanoid and humanoid.Health > 0 then
												UntagHumanoid(humanoid)
												TagHumanoid(humanoid, CurrentPlayer)
												humanoid:TakeDamage(SpecialAttack.Damage)
											end
										end)
									end
									Part.Name = ObjectChosen.Name
									Part.Size = ObjectChosen.Size
									Part.Anchored = true
									local AddFire = math.random(1, (Rows / 4))
									if AddFire == 1 then
										local Fire = Instance.new("Fire")
										Fire.Color = Color3.new(0, 0, 0)
										Fire.SecondaryColor = Fire.Color
										Fire.Heat = 9
										Fire.Size = 5
										Fire.Enabled = true
										Fire.Parent = Part
									end
									local Mesh = Instance.new("SpecialMesh")
									Mesh.MeshType = Enum.MeshType.FileMesh
									Mesh.MeshId = ObjectChosen.MeshId
									Mesh.TextureId = ObjectChosen.TextureId
									Mesh.Scale = ObjectChosen.Scale
									Mesh.VertexColor = ObjectChosen.VertexColor
									Mesh.Parent = Part
									Part.Parent = SkeletalRemainsPile
									Part.CFrame = CFrame.new(SpawnPosition) + Vector3.new(0, -1, 0) * (i / 1)
									Part.CFrame = Part.CFrame + Vector3.new(0, 1, 0) * ((i - 10) + 10)
									Part.CFrame = Part.CFrame + CFrame.Angles(0, math.random(-360, 360), 0).lookVector * iii
									Part.CFrame = Part.CFrame * ((i == 1 and CFrame.Angles(0, math.random(-360, 360), 0)) or (i > 1 and CFrame.Angles(math.random(-360, 360), math.random(-360, 360), math.random(-360, 360))))
									Part.Parent = SkeletalRemainsPile
								end
							end
							for ii, vv in pairs(InsideRow) do
								if vv and vv.Parent then
									vv:Destroy()
								end
							end
							for ii = 1, 10 do
								for iii, vvv in pairs(Parts) do
									if vvv and vvv.Parent then
										vvv.CFrame = vvv.CFrame + Vector3.new(0, (1 / 10), 0)
									end
								end
								wait(0.0001)
							end
						end
						
						if CurrentlyEquipped then
							InvokeClient("StopAnimation", Animation)
						end
						
						if ToolUnequipped then
							ToolUnequipped:disconnect()
						end
						
					end
					
					SpecialAttack.Active = false
					SpecialAttacks.Active = false
									
					Delay(((RayHit and SpecialAttack.ReloadTime) or 0), function()
						SpecialAttack.Enabled = true
					end)
				end
			elseif Key == "v" and Down then
				SpecialAttack = SpecialAttacks.Uprise
				if SpecialAttack.Enabled then
					SpecialAttacks.Enabled = false
					SpecialAttacks.Active = true
						
					SpecialAttack.Enabled = false
					SpecialAttack.Active = true
						
					local character = Character
					local humanoid = Humanoid
					local torso = Torso
					
					local Animation = Animations.ArmsOut
					InvokeClient("PlayAnimation", Animation)
					
					local CurrentlyEquipped = true
					ToolUnequipped = Tool.Unequipped:connect(function()
						CurrentlyEquipped = false
					end)
					
					local RayHit, RayPos = RayCast(Torso.Position, Vector3.new(0, -1, 0), (Torso.Size.Y * 2), {Character})
					
					if RayHit and CurrentlyEquipped then
						local PortalPart = BasePart:Clone()
						PortalPart.Name = "PortalPart"
						PortalPart.BrickColor = BrickColor.new("Really black")
						PortalPart.Size = Vector3.new((SpecialAttack.Radius * 2), 0.2, (SpecialAttack.Radius * 2))
						PortalPart.Anchored = true
						PortalPart.CanCollide = false
						local CylinderMesh = Instance.new("CylinderMesh")
						CylinderMesh.Parent = PortalPart
						Debris:AddItem(PortalPart, SpecialAttack.Duration)
						PortalPart.Parent = game:GetService("Workspace")
						PortalPart.CFrame = CFrame.new(RayPos)
						
						local StartTick = tick()
						local SkeletalRemains = SpecialAttacks.Rise.SkeletalRemains
						local SkeletonHeads = {SkeletalRemains[1], SkeletalRemains[2], SkeletalRemains[3]}
						local CurrentPlayer = Player
						local CurrentCharacter = Character
						while (tick() - StartTick) < SpecialAttack.Duration and PortalPart and PortalPart.Parent and CheckIfAlive() and ToolEquipped do
							Spawn(function()
								for i = 1, 10 do
									local ObjectChosen = SkeletonHeads[math.random(1, #SkeletonHeads)]
									local MousePosition = InvokeClient("MousePosition")
									local Part = BasePart:Clone()
									Part.Name = ObjectChosen.Name
									Part.Size = (ObjectChosen.Size * 1.5)
									Part.Anchored = false
									Part.CanCollide = false
									Part.Touched:connect(function(Hit)
										if not Hit or not Hit.Parent then
											return
										end
										local character = Hit.Parent
										if CurrentCharacter == character then
											return
										end
										local humanoid = character:FindFirstChild("Humanoid")
										if humanoid and humanoid.Health > 0 then
											UntagHumanoid(humanoid)
											TagHumanoid(humanoid, CurrentPlayer)
											humanoid:TakeDamage(SpecialAttack.Damage)
										end
									end)
									local Fire = Instance.new("Fire")
									Fire.Color = Color3.new(0, 0, 0)
									Fire.SecondaryColor = Fire.Color
									Fire.Heat = 9
									Fire.Size = 5
									Fire.Enabled = true
									Fire.Parent = Part
									local Mesh = Instance.new("SpecialMesh")
									Mesh.MeshType = Enum.MeshType.FileMesh
									Mesh.MeshId = ObjectChosen.MeshId
									Mesh.TextureId = ObjectChosen.TextureId
									Mesh.Scale = ObjectChosen.Scale
									Mesh.VertexColor = ObjectChosen.VertexColor
									Mesh.Parent = Part
									local Mass = (Part:GetMass() * Gravity * 100)
									local BodyGyro = Instance.new("BodyGyro")
									BodyGyro.maxTorque = Vector3.new(math.huge, math.huge, math.huge)
									BodyGyro.Parent = Part
									local BodyVelocity = Instance.new("BodyVelocity")
									BodyVelocity.maxForce = Vector3.new(Mass, Mass, Mass)
									BodyVelocity.velocity = Vector3.new(0, 1, 0) * math.random(150, 200)
									BodyVelocity.Parent = Part
									Debris:AddItem(Part, 3)
									Part.Parent = game:GetService("Workspace")
									Part.CFrame = PortalPart.CFrame + (PortalPart.CFrame * CFrame.Angles(0, math.random(-360, 360), 0)).lookVector * (math.random(-(SpecialAttack.Radius * 1000), (SpecialAttack.Radius * 1000)) *  0.001)
									Part.CFrame = Part.CFrame * CFrame.Angles(0, math.random(-360, 360), 0)
									BodyGyro.cframe = Part.CFrame
									wait(math.random(0, 0.35))
								end
							end)
							wait(0.5)
						end
						
						if CurrentlyEquipped then
							InvokeClient("StopAnimation", Animation)
						end
						
						if ToolUnequipped then
							ToolUnequipped:disconnect()
						end
						
					end
					
					SpecialAttack.Active = false
					SpecialAttacks.Active = false
									
					Delay(((RayHit and SpecialAttack.ReloadTime) or 0), function()
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
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
end

function RayCast(Position, Direction, MaxDistance, IgnoreList)
	return game:GetService("Workspace"):FindPartOnRayWithIgnoreList(Ray.new(Position, Direction.unit * (MaxDistance or 999.999)), IgnoreList) 
end

function Round(Number, RoundDecimal)
	local WholeNumber, Decimal = math.modf(Number)
	return ((Decimal >= RoundDecimal and math.ceil(Number)) or (Decimal < RoundDecimal and math.floor(Number)))
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

function Activated()
	if not Tool.Enabled or not ToolEquipped or SpecialAttacks.Active then
		return
	end
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
		if Clicks == 1 then
			local SwingAnimations = {Animations.LeftSwing, Animations.RightSwing}
			local Animation = SwingAnimations[math.random(1, #SwingAnimations)]
			AnimationChosen = Animation
			InvokeClient("PlayAnimation", AnimationChosen)
			wait(AnimationChosen.Duration)
			if CurrentlyEquipped then
--				InvokeClient("StopAnimation", AnimationChosen)
			end
			AnimationChosen = nil
			wait(ReloadTime)
		elseif Clicks > 1 then
			local Animation = Animations.KickHit
			InvokeClient("PlayAnimation", Animation)
			wait(Animation.Duration / 4)
			local SkeletalRemains = SpecialAttacks.Rise.SkeletalRemains
			local SkeletonHeads = {SkeletalRemains[1], SkeletalRemains[2], SkeletalRemains[3]}
			local ObjectChosen = SkeletonHeads[math.random(1, #SkeletonHeads)]
			local MousePosition = InvokeClient("MousePosition")
			local Part = BasePart:Clone()
			Part.Name = ObjectChosen.Name
			Part.Size = ObjectChosen.Size
			Part.Anchored = false
			Part.CanCollide = false
			local Fire = Instance.new("Fire")
			Fire.Color = Color3.new(0, 0, 0)
			Fire.SecondaryColor = Fire.Color
			Fire.Heat = 9
			Fire.Size = 5
			Fire.Enabled = true
			Fire.Parent = Part
			local Mesh = Instance.new("SpecialMesh")
			Mesh.MeshType = Enum.MeshType.FileMesh
			Mesh.MeshId = ObjectChosen.MeshId
			Mesh.TextureId = ObjectChosen.TextureId
			Mesh.Scale = ObjectChosen.Scale
			Mesh.VertexColor = ObjectChosen.VertexColor
			Mesh.Parent = Part
			local Mass = (Part:GetMass() * Gravity)
			local BodyGyro = Instance.new("BodyGyro")
			BodyGyro.maxTorque = Vector3.new(math.huge, math.huge, math.huge)
			BodyGyro.Parent = Part
			local BodyPosition = Instance.new("BodyPosition")
			BodyPosition.maxForce = Vector3.new((Mass * 100), (Mass * 100), (Mass * 100))
			BodyPosition.position = (Torso.CFrame + Torso.CFrame.lookVector * (((Torso.Size.Z / 2) + (Part.Size.Z / 2)) + 0.5)).p
			BodyPosition.Parent = Part
			local BodyVelocity = Instance.new("BodyVelocity")
			BodyVelocity.maxForce = Vector3.new(0, 0, 0)
			BodyVelocity.Parent = Part
			Debris:AddItem(Part, 5)
			Part.Parent = game:GetService("Workspace")
			local OriginalCFrame = Torso.CFrame + Torso.CFrame.lookVector * (((Torso.Size.Z / 2) + (Part.Size.Z / 2)) + 0.5)
			Part.CFrame = OriginalCFrame
			local Direction = CFrame.new(Part.Position, MousePosition)
			Part.CFrame = Direction
			BodyGyro.cframe = Direction
			Part.CFrame = Part.CFrame + (Part.CFrame * CFrame.Angles(-(math.pi / 2), 0, 0)).lookVector * (Torso.Size.Y * 1)
			BodyPosition.position = Part.CFrame.p
			Part.CanCollide = true
			wait(Animation.Duration / 2)
			BodyPosition.position = OriginalCFrame.p
			local Velocity = CFrame.new(Part.Position, MousePosition).lookVector * 200
			wait(Animation.Duration / 4)
			local CurrentPlayer = Player
			local CurrentCharacter = Character
			Part.Touched:connect(function(Hit)
				if not Hit or not Hit.Parent and Hit == Handle then
					return
				end
				local character = Hit.Parent
				if CurrentCharacter == character then
					return
				end
				local humanoid = character:FindFirstChild("Humanoid")
				if humanoid and humanoid.Health > 0 then
					UntagHumanoid(humanoid)
					TagHumanoid(humanoid, CurrentPlayer)
					humanoid:TakeDamage(25)
				end
			end)
			if CurrentlyEquipped then
--				InvokeClient("StopAnimation", Animation)
			end
			BodyPosition.maxForce = Vector3.new(0, 0, 0)
			BodyVelocity.maxForce = Vector3.new(Mass, Mass, Mass)
			BodyVelocity.velocity = Velocity
			Part.Velocity = Velocity
		end
		FirstClick = false
		Clicks = 0
		Tool.Enabled = true
	end
end

function Blow(Hit)
	if not Hit or not Hit.Parent or not CheckIfAlive() then
		return
	end
	local character = Hit.Parent
	local humanoid = character:FindFirstChild("Humanoid")
	if character == Character or not humanoid or humanoid.Health == 0 then
		return
	end
	local RightArm = Character:FindFirstChild("Right Arm")
	if not RightArm then
		return
	end
	local RightGrip = RightArm:FindFirstChild("RightGrip")
	if not RightGrip or not (RightGrip.Part0 == Handle or RightGrip.Part1 == Handle) then
		return
	end
	UntagHumanoid(humanoid)
	TagHumanoid(humanoid, Player)
	humanoid:TakeDamage((AnimationChosen and Damage.Swing) or Damage.Hit)
end

function CheckIfAlive()
	return (Player and Player.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent)
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso")
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
	for i, v in pairs(Animations) do
		if v and v.Animation then
			InvokeClient("Preload", v.Animation.AnimationId)
		end
	end
	ToolEquipped = true
end

function Unequipped()
	FirstClick = false
	Clicks = 0
	for i, v in pairs({EquippedToolUnequipped, ToolUnequipped}) do
		if v then
			v:disconnect()
		end
	end
	for i ,v in pairs(Sounds) do
		InvokeClient("StopSound", v)
		v:Stop()
	end
	for i, v in pairs(Animations) do
		InvokeClient("StopAnimation", v)
	end
	ToolEquipped = false
end

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)

Handle.Touched:connect(Blow)