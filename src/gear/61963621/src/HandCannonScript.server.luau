--Fixed by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Tool.Enabled = true 

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

Rocket = BasePart:Clone()
Rocket.Size = Vector3.new(0.5, 0.5, 0.5)
Rocket.Transparency = 0.4
Rocket.Shape = Enum.PartType.Ball
Rocket.Name = "Projectile"
RocketMesh = Instance.new("SpecialMesh")
RocketMesh.MeshType = "FileMesh"
RocketMesh.Name = "Mesh"
RocketMesh.MeshId = "http://www.roblox.com/asset/?id=48423624"
RocketMesh.TextureId = "http://www.roblox.com/asset/?id=48598142"
RocketMesh.Scale = Vector3.new(0.005, 0.005, 0.005)
RocketMesh.Parent = Rocket

newBV = Instance.new("BodyVelocity")
newBV.P = 1000
newBV.maxForce = Vector3.new(newBV.P, newBV.P, newBV.P)
newBV.Name = "BV"

newBT = Instance.new("BodyThrust")
newBT.Name = "BT"

newBF = Instance.new("BodyPosition")
newBF.P = 10000
newBF.maxForce = Vector3.new(newBF.P, newBF.P, newBF.P)
newBF.Name = "BF"

local fireSound
local boom

local RocketClone = {}

local damage = 15

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

function blow(part, hit)
	if hit.Name ~= "RocketClone" and hit.Parent ~= vCharacter and hit.Parent ~= Tool and part then
		local player = Players:GetPlayerFromCharacter(hit.Parent)
		if player and (not player.Neutral and player.TeamColor == Player.TeamColor) then
			return
		end
		humanoid = hit.Parent:FindFirstChild("Humanoid")
		local e = Instance.new("Explosion")
		e.Name = "SPLODE"
		e.BlastPressure = 5000
		e.BlastRadius = 5
		e.Position = part.Position		
		Debris:AddItem(e, 1.0)				
		vCharacter = Tool.Parent
		vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)
		if humanoid and vPlayer then 
			tagHumanoid(humanoid, vPlayer)
			humanoid:TakeDamage(damage)			
		end
	end
end

function tagHumanoid(humanoid, player)
	if humanoid ~= nil then 
		creatorTag = Instance.new("ObjectValue")
		creatorTag.Name = "creator"
		creatorTag.Parent = humanoid
		creatorTag.Value = player
		Debris:AddItem(creatorTag, 1)
	end
end

function shoot(pos)
	vCharacter = Tool.Parent	
	if vCharacter == nil or vCharacter:FindFirstChild("Humanoid") == nil then 		
		return
	end	

	vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)
	if vPlayer == nil then 		
		return
	end	

	local radius = 0.25
	local sign = -1

	for a = 1, 5 do
		if fireSound then fireSound:Play()end	
		for i = 1, 4 do 
			RocketClone[i] = Rocket:Clone()
			RocketClone[i].CanCollide = false

			local spawnPos = Handle.Position
			spawnPos = spawnPos + pos.unit * 5.0			
			if i == 1 then
				RocketClone[i].CFrame = CFrame.new(spawnPos, spawnPos + pos) + radius * Vector3.new(0, 1, 0)
			elseif i == 2 then
				RocketClone[i].CFrame = CFrame.new(spawnPos, spawnPos + pos) + radius * Vector3.new(0, -1, 0)
			elseif i == 3 then 
				RocketClone[i].CFrame = CFrame.new(spawnPos, spawnPos + pos) + radius * Vector3.new(1, 0, 0)
			else 
				RocketClone[i].CFrame = CFrame.new(spawnPos, spawnPos + pos) + radius * Vector3.new(-1, 0 ,0)
			end
			RocketClone[i].Velocity = pos * 60.0	
			RocketClone[i].Name ="RocketClone"
			RocketClone[i].Parent = game.Workspace					

			local RocketCloneFloat = Instance.new("BodyForce")
			RocketCloneFloat.force =  Vector3.new(0.0, RocketClone[i]:GetMass() * 196.1, 0.0)
			RocketCloneFloat.Parent = RocketClone[i]

			RocketClone[i].Touched:connect(function(hit) blow(RocketClone[i], hit) end)
		
			Debris:AddItem(RocketClone[i], 6)
		end
		wait(0.4)
	end
end

function onActivated()
	if Tool.Enabled == false then 
		return
	end
	Tool.Enabled = false

	vCharacter = Tool.Parent
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	if myHumanoid == nil then 
		print("Humanoid not found")
		return
	end

	myTorso = vCharacter:FindFirstChild("Torso")
	if myTorso == nil then 
		print("Torso not found")
		return
	end

	boom = Tool:FindFirstChild("BOOM")
	
	target = InvokeClient("MousePosition")
	lookAt = (target - Handle.Position).unit
	
	myHumanoid.WalkSpeed = 0.0
	myTorso.Anchored = true

	fireSound = Handle:FindFirstChild("FireSound")	
	shoot(lookAt)	
	myHumanoid.WalkSpeed = 16.0
	myTorso.Anchored = false
	wait(4.5)	
	Tool.Enabled = true
end

function onEquipped()
	vCharacter = Tool.Parent
	Player = Players:GetPlayerFromCharacter(vCharacter)
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	if Player and myHumanoid then 
		ratio = myHumanoid.Health/myHumanoid.MaxHealth
		myHumanoid.MaxHealth = 200
		myHumanoid.Health = ratio * 200
		while myHumanoid.Health < ratio * 200 do 
			myHumanoid.Health = ratio * 200
			wait()
		end
	end
end

function onUnequipped()
	if fireSound then fireSound:Stop()end
	if boom then boom:Stop() end

	if myHumanoid then 
		myHumanoid.WalkSpeed = 16.0 
		ratio = myHumanoid.Health/myHumanoid.MaxHealth 
		myHumanoid.Health = ratio * 100
		myHumanoid.MaxHealth = 100
	end
	if myTorso then myTorso.Anchored = false end
end

function OnServerInvoke(player, mode, value)
end

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
end

ServerControl.OnServerInvoke = OnServerInvoke

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)


