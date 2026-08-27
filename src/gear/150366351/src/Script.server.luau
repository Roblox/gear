--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

FireSound = Handle:WaitForChild("FireSound")
HitSound = Handle:WaitForChild("HitSound")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

function FindCharacterAncestor(Parent)
	if Parent and Parent ~= game:GetService("Workspace") then
		local humanoid = Parent:FindFirstChild("Humanoid")
		if humanoid then
			return Parent, humanoid
		else
			return FindCharacterAncestor(Parent.Parent)
		end
	end
	return nil
end

function RayCast(Position, Direction, MaxDistance, IgnoreList)
	return game:GetService("Workspace"):FindPartOnRayWithIgnoreList(Ray.new(Position, Direction.unit * (MaxDistance or 999.999)), IgnoreList) 
end

function TagHumanoid(humanoid, player)
	local creator_tag = Instance.new("ObjectValue")
	creator_tag.Name = "creator"
	creator_tag.Value = player
	Debris:AddItem(creator_tag, 3)
	creator_tag.Parent = humanoid
end

function UntagHumanoid(humanoid)
	for i, v in pairs(humanoid:GetChildren()) do
		if v.Name == "creator" then
			v:Destroy()
		end
	end
end

function Fire(v)

	local missile = Instance.new("Part")
	missile.Friction = 0
	missile.Elasticity = 1
	missile.Material = Enum.Material.Plastic
	missile.Shape = Enum.PartType.Ball
	missile.TopSurface = Enum.SurfaceType.Smooth
	missile.BottomSurface = Enum.SurfaceType.Smooth
	missile.Size = Vector3.new(0.5, 0.75, 0.5)
	missile.Name = "Part"
	
	local mesh = Instance.new("SpecialMesh")
	mesh.MeshType = Enum.MeshType.FileMesh
	local FlowerChance = math.random(1, 5)
	mesh.MeshId = "http://www.roblox.com/asset?id=" .. tostring((FlowerChance == 1 and 150061774) or 150061796)
	mesh.TextureId = "http://www.roblox.com/asset?id=150061826"
	mesh.Scale = ((FlowerChance == 1 and Vector3.new(3, 3, 3)) or Vector3.new(2, 2, 2))
	mesh.Parent = missile

	missile.Velocity =  v * 50
	Delay(0.5, function()
		missile.Velocity = missile.Velocity + Vector3.new(0, (100 * ((missile.Velocity.Y <= 0 and -1) or 1)), 0)
	end)
	local InitialVelocity = missile.Velocity.magnitude
	
	local force = Instance.new("BodyForce")
	force.force = Vector3.new(0, workspace.Gravity, 0) * missile:GetMass()
	
	local hitsound = HitSound:Clone()
	hitsound.Parent = missile
	
	local Debounce = false
	missile.Touched:connect(function(Hit)
		if Hit and Hit.Parent and not Debounce then
			local character, humanoid = FindCharacterAncestor(Hit.Parent)
			if character ~= Character then
				Debounce = true
				if FlowerChance > 1 then
					hitsound:Play()
					if humanoid and humanoid ~= Humanoid then
						humanoid.Sit = true
						humanoid:TakeDamage(15)
						UntagHumanoid(humanoid)
						TagHumanoid(humanoid, Player)
					end
					--Creates the bouncing effect, thanks to Oozlebachr
					missile.Velocity = CFrame.new(Vector3.new(), missile.Velocity).lookVector * InitialVelocity
					wait(1)
					Debounce = false
				else
					local Hit, EndPosition = RayCast(missile.Position, Vector3.new(0, -1, 0), (missile.Size.Y * 2), {Character})
					if Hit then
						local MissilePosition = missile.Position
						missile:Destroy()
						local FlowerRadius = 6
						local IgnoreList = {Character, missile}
						local Flowers = {}
						local FlowerModel = Instance.new("Model")
						FlowerModel.Name = "FlowerModel"
						Debris:AddItem(FlowerModel, 30)
						for i = 1, (10 + math.random(0, 20)) do
							local FlowerPosition = MissilePosition + Vector3.new(math.random(-FlowerRadius, FlowerRadius), 0, math.random(-FlowerRadius, FlowerRadius))
							local Hit2, EndPosition2 = RayCast(FlowerPosition, Vector3.new(0, -1, 0), (missile.Size.Y * 2), IgnoreList)
							if Hit2 then
								local Flower = missile:Clone()
								local Smoke = Instance.new("Smoke")
								Smoke.Color = BrickColor.new("New Yeller").Color
								Smoke.Opacity = 0.25
								Smoke.RiseVelocity = 0.06
								Smoke.Size = 0.125
								Smoke.Parent = Flower
								Flower.CanCollide = false
								Flower.Shape = Enum.PartType.Block
								Flower.FormFactor = Enum.FormFactor.Custom
								Flower.Size = Vector3.new(0.5, 0.75, 2)
								missile.Velocity = Vector3.new(0, 0, 0)
								mesh:Clone().Parent = Flower
								table.insert(IgnoreList, Flower)
								table.insert(Flowers, Flower)
								Debris:AddItem(Flower, 25)
								local Weld = Instance.new("Motor")
								Weld.Part0 = Hit2
								Weld.Part1 = Flower
								local FlowerCFrame = CFrame.new(FlowerPosition.X, (EndPosition2.Y + (Flower.Size.Y / 2)), FlowerPosition.Z)
								local ToObjectSpace = Hit2.CFrame:toObjectSpace((FlowerCFrame + Vector3.new(0, (Flower.Size.Z / 2), 0) )* CFrame.Angles(math.pi/2, 0, math.random(-math.pi, math.pi)))
								Weld.C0 = ToObjectSpace
								Debris:AddItem(Weld, 20)
								Weld.Parent = Flower
								FlowerModel.Parent = game:GetService("Workspace")
								Flower.Parent = FlowerModel
							end
						end
						local FlowerDamage = 3
						Spawn(function()
							while #FlowerModel:GetChildren() > 0 do
								for i, v in pairs(Flowers) do
									for ii, vv in pairs(Players:GetChildren()) do
										if v and v.Parent and vv and vv.Parent and vv.Character and (v.Position - vv.Character:GetModelCFrame().p).magnitude <= 5 then
											local humanoid = vv.Character:FindFirstChild("Humanoid")
											if humanoid and humanoid.Health > 0 and humanoid ~= Humanoid then
												if (humanoid.Health - FlowerDamage) <= 0 then
													UntagHumanoid(humanoid)
													TagHumanoid(humanoid, Player)
												end
												humanoid:TakeDamage(FlowerDamage)
											end
										end
									end
								end
								wait(0.25)
							end
						end)
					end
				end
			end
		end
	end)

	Debris:AddItem(missile, 20)

	missile.Parent = game:GetService("Workspace")
	
 	missile.CFrame = CFrame.new(Handle.Position, Humanoid.TargetPoint) + (Handle.CFrame.lookVector * (missile.Size.z * 2))
	
end

function Activated()

	if not Tool.Enabled or not Humanoid or not Humanoid.Parent or Humanoid.Health == 0 or not Player or not Player.Parent then
		return
	end

	Tool.Enabled = false

	local TargetPos = Humanoid.TargetPoint

	local LookAt = (TargetPos - Handle.Position).unit

	FireSound:Play()

	Fire(LookAt)

	wait(2)

	Tool.Enabled = true

end

function Equipped()
	Character = Tool.Parent
	Humanoid = Character:FindFirstChild("Humanoid")
	Player = Players:GetPlayerFromCharacter(Character)
end

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)