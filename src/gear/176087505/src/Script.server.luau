--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Sounds = {
	Slash = Handle:WaitForChild("Slash"),
	Unsheath = Handle:WaitForChild("Unsheath")
}

Animations = {
	{Animation = Tool:WaitForChild("LeftSlash"), Speed = 2, Duration = 0.4},
	{Animation = Tool:WaitForChild("RightSlash"), Speed = 2, Duration = 0.4},
}

R15Animations = {
	{Animation = Tool:WaitForChild("R15LeftSlash"), Speed = 2, Duration = 0.4},
	{Animation = Tool:WaitForChild("R15RightSlash"), Speed = 2, Duration = 0.4}	
}

Equipped = false
Active = false

Damage = 5
SpecialDamage = 12.5

SpecialReady = false
SpecialActive = false
Kills = 0
KillsNeeded = 5

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

BasePart = Instance.new("Part")
BasePart.Material = Enum.Material.Plastic
BasePart.Shape = Enum.PartType.Block
BasePart.TopSurface = Enum.SurfaceType.Smooth
BasePart.BottomSurface = Enum.SurfaceType.Smooth
BasePart.CanCollide = false
BasePart.Anchored = true
BasePart.Locked = true

for i, v in pairs(Handle:GetChildren()) do
	if v:IsA("Sparkles") then
		v:Destroy()
	end
end

ServerControl.OnServerInvoke = (function(player, Mode, Value)
	if player ~= Player or Humanoid.Health == 0 or not Tool.Enabled then
		return
	end
	if Mode == "Click" and Value then
		Tool.Enabled = false
		Humanoid.WalkSpeed = 32
		Active = true
		Attack()
		if Humanoid and Humanoid.Parent then
			Humanoid.WalkSpeed = 16
		end
		Active = false
		Tool.Enabled = true
	elseif Mode == "KeyPress" and Value.Key == "q" and Value.Down then
		if not SpecialReady then
			return
		end
		local Radius = 50
		local Hit, HitPosition = RayCast((Torso.CFrame + Torso.CFrame.lookVector * (Radius + (Torso.Size.Z / 2))).p, Vector3.new(0, -1, 0), (Torso.Size.Y * 2), {Character})
		if Hit then
			SpecialReady = false
			SpecialActive = true
			if Sparkles and Sparkles.Parent then
				Sparkles:Destroy()
			end
			local RadiusModel = Instance.new("Model")
			RadiusModel.Name = "RadiusModel"
			local RadiusPartBase = BasePart:Clone()
			RadiusPartBase.BrickColor = BrickColor.new("Really red")
			RadiusPartBase.Transparency = 0.5
			RadiusPartBase.Size = Vector3.new((Radius * 2), 0.2, (Radius * 2))
			local CylinderMesh = Instance.new("CylinderMesh")
			CylinderMesh.Parent = RadiusPartBase
			RadiusBaseTop = RadiusPartBase:Clone()
			RadiusBaseTop.Transparency = 0.75
			RadiusBaseTop.Size = Vector3.new(RadiusBaseTop.Size.X, 1.5, RadiusBaseTop.Size.Z)
			PointLight = Instance.new("PointLight")
			PointLight.Brightness = 50
			PointLight.Color = RadiusPartBase.BrickColor.Color
			PointLight.Range = Radius
			PointLight.Shadows = true
			PointLight.Enabled = true
			PointLight.Parent = RadiusPartBase
			RadiusPartBase.Parent = RadiusModel
			RadiusBaseTop.Parent = RadiusModel
			Debris:AddItem(RadiusModel, 15)
			RadiusModel.Parent = game:GetService("Workspace")
			RadiusPartBase.CFrame = CFrame.new(HitPosition) + Vector3.new(0, (RadiusPartBase.Size.Y), 0)
			RadiusBaseTop.CFrame = RadiusPartBase.CFrame + Vector3.new(0, ((RadiusPartBase.Size.Y / 2) + (RadiusBaseTop.Size.Y / 2)), 0)
			local CurrentAnimation = 0
			for i = 1, 25 do
				if not Equipped then
					break
				end
				local TestAnimation = (CurrentAnimation + 1)
				if Animations[TestAnimation] and R15Animations[TestAnimation] then
					CurrentAnimation = TestAnimation
				else
					CurrentAnimation = 1
				end
				Humanoid.WalkSpeed = 0
				Attack(CurrentAnimation)
				Spawn(function()
					local IgnoreObjects = {Character}
					local ModelCFrame = RadiusModel:GetModelCFrame()
					local ModelSize = RadiusModel:GetModelSize()
					local NegativePartRadius = Vector3.new((ModelSize.X / 2), (ModelSize.Y / 2), (ModelSize.Z / 2))
					local PositivePartRadius = Vector3.new((ModelSize.X / 2), (ModelSize.Y / 2), (ModelSize.Z / 2))
					local Parts = game:GetService("Workspace"):FindPartsInRegion3WithIgnoreList(Region3.new(ModelCFrame.p - NegativePartRadius, ModelCFrame.p + PositivePartRadius), IgnoreObjects, 100)
					local Humanoids = {}
					for i, v in pairs(Parts) do
						if v and v.Parent then
							local character = v.Parent
							local humanoid = character:FindFirstChildOfClass("Humanoid")
							if humanoid and humanoid.Health > 0 and not CheckTableForInstance(Humanoids, humanoid) then
								humanoid:TakeDamage(SpecialDamage)
								table.insert(Humanoids, humanoid)
							end
						end
					end
				end)
			end
			if Humanoid and Humanoid.Parent then
				Humanoid.WalkSpeed = 16
			end
			if RadiusModel and RadiusModel.Parent then
				RadiusModel:Destroy()
			end
			SpecialActive = false
		end
	end
end)

Tool.Enabled = true

function CheckTableForInstance(Table, Instance)
	for i, v in pairs(Table) do
		if v == Instance then
			return true
		end
	end
	return false
end

function RayCast(Position, Direction, MaxDistance, IgnoreList)
	return game:GetService("Workspace"):FindPartOnRayWithIgnoreList(Ray.new(Position, Direction.unit * (MaxDistance or 999.999)), IgnoreList) 
end

function InvokeClient(Mode, Value)
	pcall(function()
		ClientControl:InvokeClient(Player, Mode, Value)
	end)
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

function Attack(AnimationNumber)
	Sounds.Slash:Play()
	AnimationNumber = AnimationNumber or math.random(1, #Animations)
	local Animation = Animations[AnimationNumber]
	if Humanoid and Humanoid.RigType == Enum.HumanoidRigType.R15 then
		Animation = R15Animations[AnimationNumber]
	end 
	InvokeClient("PlayAnimation", Animation)
	wait(Animation.Duration)
end

function Blow(Hit)
	if Hit and Hit.Parent and Active then
		local humanoid = Hit.Parent:FindFirstChild("Humanoid")
		if Character and Player and Humanoid and humanoid and humanoid ~= Humanoid and humanoid.Health > 0 and Humanoid.Health > 0 then
			local right_arm = Character:FindFirstChild("Right Arm") or Character:FindFirstChild("RightHand")
			if right_arm then
				local joint = right_arm:FindFirstChild("RightGrip")
				if joint and (joint.Part0 == Handle or joint.Part1 == Handle) then
					UntagHumanoid(humanoid)
					TagHumanoid(humanoid, Player)
					humanoid:TakeDamage(Damage)
					if humanoid.Health == 0 then
						Kills = (Kills + 1)
						if Kills >= KillsNeeded and not SpecialReady and not SpecialActive then
							SpecialReady = true
							Kills = 0
							Sparkles = Instance.new("Sparkles")
							Sparkles.SparkleColor = Color3.new((255 / 255), (170 / 255), (0 / 255))
							Sparkles.Enabled = true
							Sparkles.Parent = Handle
						end
					end
				end
			end
		end
	end
end

function Equipped()
	Equipped = true
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChildOfClass("Humanoid")
	Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
	if not Player or not Humanoid or Humanoid.Health == 0 or not Torso then
		return
	end
	Sounds.Unsheath:Play()
end

function Unequipped()
	Equipped = false
	if Humanoid and Humanoid.Parent then
		Humanoid.WalkSpeed = 16
	end
	if RadiusModel and RadiusModel.Parent then
		RadiusModel:Destroy()
	end
end

Handle.Touched:connect(Blow)

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)