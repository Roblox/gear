--Fixed by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

BallistaActive = Tool:FindFirstChild("BallistaActive")
FireBolt = Tool:FindFirstChild("FireBolt")

BallistaColdScript = script:WaitForChild("BallistaColdScript")

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

Damage = 75

Bolt = BasePart:Clone()
Bolt.CanCollide = false
Bolt.Size = Vector3.new(1, 7, 1)
BoltMesh = Instance.new("SpecialMesh")
BoltMesh.MeshType = Enum.MeshType.FileMesh
BoltMesh = Instance.new("SpecialMesh")
BoltMesh.MeshId = "http://www.roblox.com/asset/?id=55901026"
BoltMesh.TextureId = "http://www.roblox.com/asset/?id=55727398"
BoltMesh.Parent = Bolt
BoltMesh.Scale = Vector3.new(1.5, 1.5, 1.5)

Float = Instance.new("BodyForce")
Float.force = Vector3.new(0, (Bolt:GetMass() * 196.20), 0)
Float.Parent = Bolt

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

BallistaActive.Value = false
FireBolt.Value = false
Tool.Enabled = true

function blow(hit, missile)
	if not hit or not hit.Parent then
		return
	end
	local character = hit.Parent
	if character:IsA("Hat") or character:IsA("Tool") then
		character = hit.Parent
	end
	if character == Character then
		return
	end
	local player = Players:GetPlayerFromCharacter(character)
	if player and (not player.Neutral and player.TeamColor == Player.TeamColor) then
		return
	end
	local fire = missile:FindFirstChild("Fire")
	if fire then
		local e = Instance.new("Explosion")
		e.Position = missile.Position
		e.BlastRadius = 5.0
		e.BlastPressure = 1000.0
		e.Parent = game:GetService("Workspace")
	end
	local humanoid = hit.Parent:FindFirstChild("Humanoid")
	if humanoid and humanoid.Health > 0 then
		if not character:FindFirstChild(BallistaColdScript.Name) then
			local newScript = BallistaColdScript:Clone()
			newScript.Disabled = false
			newScript.Parent = character
		end
		local creator = missile:FindFirstChild("creator")
		if creator then
			creator.Parent = humanoid
		end
		humanoid:TakeDamage(Damage)
		Debris:AddItem(creator, 1)
	end
end

function shoot(pPos, target)
	local missile = Bolt:Clone()
	local fakeD
	if Ballista and Ballista.Parent then
		if target ~= Ballista.Position then
			fakeD = (target - Ballista.Position).unit
		end
		local LV = (Ballista.CFrame * CFrame.Angles(math.pi/2, 0, 0)).lookVector
		local signedAngle = LV:Dot(fakeD)		
		if signedAngle < 0.5 then
			-- need to adjust fakeD			
			-- get axis of rotation
			local cross = LV:Cross(fakeD)
			-- get direction of rotation
			local v1 = LV * 0.866 + cross:Cross(LV) * 0.5 + cross *(cross:Dot(LV)) * 0.134
			local v2 = LV * 0.866 + cross:Cross(LV) * -0.5 + cross *(cross:Dot(LV)) * 0.134
			local a1 = v1:Dot(fakeD)
			local a2 = v2:Dot(fakeD)
			if a1 > a2 then 
				fakeD = v1
			else
				fakeD = v2
			end
			-- rotate LV around axis of rotation by 30-degrees
		end 		
	end
	if FireBolt.Value then
		local fire = Instance.new("Fire")
		fire.Color = Color3.new(0, 204/255, 1)
		fire.Parent = missile
	end
	missile.Velocity = fakeD * 120.0
	local sPos = Character.PrimaryPart.Position	
	sPos = sPos + fakeD.unit * 14.0
	missile.CFrame = CFrame.new(sPos, sPos + fakeD) * CFrame.Angles(math.pi/2, 0, math.pi)		
	missile.Name = "BOLT"
	missile.CanCollide = false		
	local creator_tag = Instance.new("ObjectValue")
	creator_tag.Value = Player
	creator_tag.Name = "creator"
	creator_tag.Parent = missile
	missile.Parent = game.Workspace	
	missile.Touched:connect(function(hit)
		blow(hit, missile)
	end)	
	Debris:AddItem(missile, 75) 
end


function Activated()
	if not Tool.Enabled or not CheckIfAlive() then
		return
	end
	Tool.Enabled = false
	if not BallistaActive.Value then 
		BallistaActive.Value = true
		Ballista = Handle:Clone()
		Ballista.Name = "Handle"
		Handle.Transparency = 1.0
		Ballista.Size = Vector3.new(8, 10, 7.5)
		Ballista.CFrame = Handle.CFrame
		Ballista.Position = (Torso.Position + (Torso.CFrame.lookVector * 6.0))
		Ballista.CanCollide = true
		Ballista.Parent = game:GetService("Workspace")

		local smoke = Instance.new("Smoke")
		Debris:AddItem(smoke, 1.4)
		smoke.Parent = Ballista

		Ballista.Mesh.Scale = Vector3.new(1.5, 1.5, 1.5)
		Torso.Anchored = true
		ratio = Humanoid.Health/Humanoid.MaxHealth
		Humanoid.MaxHealth = 500
		Humanoid.Health = ratio * 500
		wait(1.4)
	else
		target = InvokeClient("MousePosition")	
		direction = (target - Ballista.Position).unit
		shoot(direction, target)
	end
	wait(2.0)
	Tool.Enabled = true
end

function CheckIfAlive()
	return (((Player and Player.Parent and Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent) and true) or false)
end

function Equipped()
	Character = Tool.Parent
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso")
	Player = Players:GetPlayerFromCharacter(Character)
	if not CheckIfAlive() then
		return
	end
	ToolEquipped = true
end

function Unequipped()
	if Torso and Torso.Parent then
		Torso.Anchored = false
	end
	for i, v in pairs({Ballista}) do
		if v and v.Parent then
			v:Destroy()
		end
	end
	Handle.Transparency = 0
	if Humanoid then 
		ratio = Humanoid.Health/Humanoid.MaxHealth
		Humanoid.MaxHealth = 100
		Humanoid.Health = ratio * 100
	end
	BallistaActive.Value = false
	ToolEquipped = false
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

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)
