--Rescripted by Luckymaxer		--Physics Collision group fix by Stickmasterluke


local PhysicsService = game:GetService("PhysicsService")
local Group = pcall(PhysicsService.GetCollisionGroupId, PhysicsService, "Bees")
if not Group then
	Group = PhysicsService:CreateCollisionGroup("Bees")
end
PhysicsService:CollisionGroupSetCollidable("Bees", "Bees", true)
PhysicsService:CollisionGroupSetCollidable("Bees", "Default", false)

Tool = script.Parent 
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

BaseUrl = "http://www.roblox.com/asset/?id="

BasePart = Instance.new("Part")
BasePart.Shape = Enum.PartType.Block
BasePart.Material = Enum.Material.Plastic
BasePart.FormFactor = Enum.FormFactor.Custom
BasePart.TopSurface = Enum.SurfaceType.Smooth
BasePart.BottomSurface = Enum.SurfaceType.Smooth
BasePart.Size = Vector3.new(0.2, 0.2, 0.2)
BasePart.Locked = true
BasePart.CanCollide = true
BasePart.Anchored = false

Gravity = workspace.Gravity
BeeDamage = 2

Bees = {}

Bee = BasePart:Clone()
Bee.Name = "Bee"
Bee.Size = Vector3.new(1, 1, 1)
BeeMesh = Instance.new("SpecialMesh")
BeeMesh.MeshType = Enum.MeshType.FileMesh
BeeMesh.MeshId = (BaseUrl .. "117466345")
BeeMesh.TextureId = (BaseUrl .. "1130407209")
BeeMesh.Scale = Vector3.new(0.75, 0.75, 0.75)
BeeMesh.Parent = Bee

FloatForce = Instance.new("BodyForce")
FloatForce.force = Vector3.new(0, (Bee:GetMass() * Gravity), 0)
FloatForce.Parent = Bee

Handle.Transparency = 0
Tool.Enabled = true

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

function IsTeamMate(Player1, Player2)
	return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
end

function FindNearestPlayer()
	local NearestTorso, NearestHumanoid 
	local MinDistance = 200
	for i, v in pairs(Players:GetChildren()) do
		if v:IsA("Player") and v ~= Player and v.Character then
			local character = v.Character
			local humanoid = character:FindFirstChild("Humanoid")
			local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
			if humanoid and humanoid.Health > 0 and torso then
				local Distance = (Torso.Position - torso.Position).magnitude
				if Distance < MinDistance then
					NearestHumanoid = humanoid
					NearestTorso = torso
				end
			end
		end
	end
	return NearestTorso, NearestHumanoid
end 

function CreateSwarm()
	
	local NumberBees = math.random(15, 19)
	
	local TargetTorso 
	local TargetHumanoid  

	local DurationTick = tick()
	local Duration = 20
	
	for i = 1, NumberBees do 
		local bee = Bee:Clone()
		PhysicsService:SetPartCollisionGroup(bee, "Bees")
		bee.CFrame = Torso.CFrame + Vector3.new(math.random(-3, 3), math.random(-1, 1), math.random(-3, 3))
		bee.Touched:connect(function(hit)
			if not hit or not hit.Parent then
				return
			end
			local character = hit.Parent
			if character:IsA("Hat") then
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
			if humanoid and humanoid.Health > 0 then
				UntagHumanoid(humanoid)
				TagHumanoid(humanoid, Player)
				humanoid:TakeDamage(BeeDamage)
			end 
		end)
		table.insert(Bees, bee)
		Debris:AddItem(bee, Duration)
		bee.Parent = game:GetService("Workspace")		
	end 
	
	if not TargetTorso or TargetHumanoid then 
		TargetTorso, TargetHumanoid = FindNearestPlayer()
	end 

	while (tick() - DurationTick) < Duration do
		local bRandom = math.random(-5, 5)
		for i, v in pairs(Bees) do 
			if TargetTorso and TargetHumanoid and TargetHumanoid.Health > 0 then 
				v.Velocity = (TargetTorso.Position - v.Position).unit * 29.0 
			else 
				TargetTorso, TargetHumanoid = FindNearestPlayer()
				if not TargetTorso or TargetHumanoid then
					v.Velocity = (Torso.Position - v.Position).unit * 15.0 					
				end
			end 
		end 
		wait(0.1)
	end
	for i, v in pairs(Bees) do
		if v and v.Parent then
			v:Destroy()
		end
	end
	
	Bees = {}
end 

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent and Player and Player.Parent) and true) or false)
end

function Activated()
	if not Tool.Enabled or not CheckIfAlive() or not ToolEquipped then
		return
	end
	
	Tool.Enabled = false
	
	Handle.Transparency = 1

	local BeeHive = Handle:Clone()
	BeeHive.Name = "BeeHive"
	BeeHive.Transparency = 0
	BeeHive.CanCollide = true
	Debris:AddItem(BeeHive, 4)
	BeeHive.Parent = game:GetService("Workspace")
	BeeHive.CFrame = Handle.CFrame
	Delay(2, function()
		if BeeHive and BeeHive.Parent then
			BeeHive:Destroy()
			CreateSwarm()
		end
	end)
	
	wait(22)
	
	Handle.Transparency = 0
	
	Tool.Enabled = true
	
end

function Equipped()
	Character = Tool.Parent
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
	Player = Players:GetPlayerFromCharacter(Character)
	if not CheckIfAlive() then
		return
	end
	ToolEquipped = true
end

function Unequipped()
	ToolEquipped = false
end

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)
workspace:GetPropertyChangedSignal("Gravity"):Connect(function()
	Gravity = workspace.Gravity
end)