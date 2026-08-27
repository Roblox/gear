--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

BallistaActive = Tool:WaitForChild("BallistaActive")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

ShieldStrength = 10 
Damage = 50

Bolt = Instance.new("Part")
Bolt.Shape = Enum.PartType.Block
Bolt.FormFactor = Enum.FormFactor.Custom
Bolt.TopSurface = Enum.SurfaceType.Smooth
Bolt.BottomSurface = Enum.SurfaceType.Smooth
Bolt.CanCollide = false
Bolt.Size = Vector3.new(0.5, 0.75, 3.5)

local BoltMesh = Instance.new("SpecialMesh")
BoltMesh.MeshId = "http://www.roblox.com/asset/?id=156092226"
BoltMesh.TextureId = "http://www.roblox.com/asset/?id=156092201"
BoltMesh.Parent = Bolt
BoltMesh.Scale = Vector3.new(1.5, 1.5, 1.5)

local Float = Instance.new("BodyForce")
Float.force = Vector3.new(0, Bolt:GetMass() * 196.1, 0)
Float.Parent = Bolt

local Shield = Instance.new("Part")
Shield.Shape = Enum.PartType.Ball
Shield.TopSurface = Enum.SurfaceType.Smooth
Shield.BottomSurface = Enum.SurfaceType.Smooth
Shield.CanCollide = false
Shield.Anchored = true 
Shield.Size = Vector3.new(17, 17, 17)
Shield.Transparency = 0.9

Tool.Enabled = true

function Blow(Hit, Missile)
	if Hit.Parent then 
		humanoid = Hit.Parent:FindFirstChild("Humanoid")
	end
	Humanoid = Character:FindFirstChild("Humanoid")
	f = Missile:FindFirstChild("Fire")
	if f then 
			e = Instance.new("Explosion")
			e.Position = Missile.Position
			e.BlastRadius = 5.0
			e.BlastPressure = 1000.0
			e.Parent = game:GetService("Workspace")
	end
	if humanoid and humanoid ~= Humanoid then 		
		if f then
			if Hit.Parent:FindFirstChild("BallistaColdScript") == nil then 
				newScript = Tool.BallistaColdScript:Clone() 
				newScript.Parent = Hit.Parent 
				newScript.Disabled = false 
			end		
		end		
		creator = Missile:FindFirstChild("creator")
		if creator then creator.Parent = humanoid end
		humanoid:TakeDamage(Damage)
		Debris:AddItem(creator, 1)	
	end
end

function restore()
	wait(12.0)
	ShieldStrength = 10
end

function Protect(Hit)
	if ShieldStrength > 0 then
		if Hit.Parent then 
			humanoid = Hit.Parent:FindFirstChild("Humanoid")
		end
		if humanoid ~= nil and humanoid ~= Humanoid then 
			humanoid.WalkSpeed = 0.0
			wait(1.0)
			if humanoid.WalkSpeed == 0.0 then humanoid.WalkSpeed = 16.0 end
			ShieldStrength = ShieldStrength - 1
		end
	else
		if resCo == nil or coroutine.status(resCo) == 'dead' then
			resCo = coroutine.create(restore)
			coroutine.resume(resCo)
		end
	end
end

function Shoot(Pos, Target)
	Missile = Bolt:Clone()			
	if Ballista then
		if Target ~= Ballista.Position then
			fakeD = (Target - Ballista.Position).unit
		end
		LV = (Ballista.CFrame * CFrame.Angles(math.pi/2, 0, 0)).lookVector
		signedAngle = LV:Dot(fakeD)		
		if signedAngle < 0.5 then
			-- need to adjust fakeD			
			-- get axis of rotation
			cross = LV:Cross(fakeD)
			-- get direction of rotation
			v1 = LV * 0.866 + cross:Cross(LV) * 0.5 + cross *(cross:Dot(LV)) * 0.134
			v2 = LV * 0.866 + cross:Cross(LV) * -0.5 + cross *(cross:Dot(LV)) * 0.134
			a1 = v1:Dot(fakeD)
			a2 = v2:Dot(fakeD)
			if a1 > a2 then 
				fakeD = v1
			else
				fakeD = v2
			end
			-- rotate LV around axis of rotation by 30-degrees
		end 		
	end
	Missile.Velocity = fakeD * 120
	local sPos = Character.PrimaryPart.Position	
	sPos = sPos + fakeD.unit * 14
	Missile.CFrame = Ballista.CFrame + Ballista.CFrame.lookVector * ((Ballista.Size.Z / 2) + (Missile.Size.Z / 2) + 1.5)
	Missile.CFrame = CFrame.new(Missile.Position, Target)
	Missile.Velocity = Missile.CFrame.lookVector * 120
	Missile.Name = "Bolt"
	Missile.CanCollide = false		
	local creator_tag = Instance.new("ObjectValue")
	creator_tag.Value = vPlayer
	creator_tag.Name = "creator"
	creator_tag.Parent = Missile
	Missile.Parent = game:GetService("Workspace")	
	
	Missile.Touched:connect(function(Hit)
		Blow(Hit, Missile)
	end)	
	Debris:AddItem(Missile, 75) 
end


function Activated()
	if Tool.Enabled then
		Tool.Enabled = false
		if BallistaActive.Value == 0 then 
			BallistaActive.Value = 1
			Ballista = Handle:Clone()
			Ballista.Name = "Ballista"
			Ballista.Size = Vector3.new(8, 5, 8)
			Ballista.CFrame = Handle.CFrame
			Ballista.Position = (Torso.Position + (Torso.CFrame.lookVector * 6.0))
			Ballista.CanCollide = true
			Ballista.Parent = game:GetService("Workspace")	
			local Smoke = Instance.new("Smoke")
			Debris:AddItem(Smoke, 1.4)
			Smoke.Parent = Ballista
			Ballista.Mesh.Scale = Vector3.new(3, 3, 3)
			Head.Anchored = true
			Ratio = (Humanoid.Health / Humanoid.MaxHealth)
			Humanoid.MaxHealth = 500
			wait(0.1)
			Humanoid.Health = (Ratio * 500)
		else
			Target = Humanoid.TargetPoint		
			local Direction = (Target - Ballista.Position).unit 		
			Shoot(Direction, Target)
		end
		wait(2)
		Tool.Enabled = true
	end
end


function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Head = Character:FindFirstChild("Head")
	Torso = Character:FindFirstChild("Torso")
	if not Humanoid or not Torso then
		return
	end
end

function Unequipped()
	if Head then
		Head.Anchored = false
	end
	if Ballista then
		Ballista:Destroy()
	end
	BallistaActive.Value = 0
	Handle.Transparency = 0
	if Humanoid then
		local Ratio = (Humanoid.Health / Humanoid.MaxHealth)
		Humanoid.MaxHealth = 100
		wait(0.1)
		Humanoid.Health = Ratio * 100
	end
end

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)
