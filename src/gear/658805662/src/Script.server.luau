--Made by Luckymaxer

Tool = script.Parent
Handle = Tool.Handle

Players = game:GetService("Players")
Debris = game:GetService("Debris")
InsertService = game:GetService("InsertService")

Damage = 5
Eruptions = 5
DistancePerObject = 7
TimeBetweenEruptions = 0.05
EruptionLife = 3
DamagePerTouch = 10

Counters = {}
Erupting = false
ToolEquipped = false

BasePart = Instance.new("Part")
BasePart.Name = "Part"
BasePart.Shape = Enum.PartType.Block
BasePart.FormFactor = Enum.FormFactor.Custom
BasePart.Material = Enum.Material.Plastic
BasePart.TopSurface = Enum.SurfaceType.Smooth
BasePart.BottomSurface = Enum.SurfaceType.Smooth
BasePart.Size = Vector3.new(0.2, 0.2, 0.2)
BasePart.Locked = true
BasePart.Anchored = false
BasePart.CanCollide = true

Sounds = {
	CrystalExplosion = Handle:WaitForChild("CrystalExplosion"),
}

EruptionModel = InsertService:LoadAsset(84929999)
Eruption = EruptionModel:GetChildren()[1]:Clone()
Debris:AddItem(EruptionModel, 1)

Tool.Enabled = true

for i, v in pairs(Eruption:GetChildren()) do
	if v:IsA("BasePart") then
		if v.Name == "Base" then
			v.Transparency = 0
			v.Material = Enum.Material.Slate
			v.BrickColor = BrickColor.new("Reddish brown")
		elseif v.Name == "Crystal" then
			v.Transparency = 0.6
			v.Material = Enum.Material.Slate
			v.BrickColor = BrickColor.new("Really red")
		else
			v.BrickColor = BrickColor.new("Bright red")
		end
	end
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

function ParticleExplosion(Parent, Colors) --Creates a random number of particles and lets them fall down from the sky.  
	local NumParticles = math.random(5, 15)
	for i = 0, NumParticles do
		
		--Create the parts for the particles to emit from
		local ParticlePoint = BasePart:Clone()
		ParticlePoint.Transparency = 1
		ParticlePoint.Size = Vector3.new(1, 1, 1)
		ParticlePoint.CFrame = Parent.CFrame * CFrame.new(math.random(-5, 5), math.random(4, 7), math.random(-5, 5))
		
		--Create the particles for display
		local Particle = Instance.new("Fire")
		Particle.Color = Colors[math.random(1, #Colors)]
		Particle.SecondaryColor = Particle.Color
		Particle.Heat = 9
		Particle.Size = 5
		Particle.Enabled = true
		Particle.Parent = ParticlePoint
		
		--Send them flying
		local ParticleForce = Instance.new("BodyForce")
		ParticleForce.force = (Vector3.new(math.random(-20, 20), 40, math.random(-20, 20)) * 7)
		Debris:AddItem(ParticleForce, 0.3)
		ParticleForce.Parent = ParticlePoint
		
		Debris:AddItem(ParticlePoint, (0.1 + math.random()))
		
		ParticlePoint.Parent = Parent
		
	end

end

function CrystalTouched(Hit) --Fired when the chrystal touches something
	if not Hit or not Hit.Parent then
		return
	end	
	local character = Hit.Parent
	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid or humanoid.Health == 0 then
		return
	end
	local player = Players:GetPlayerFromCharacter(character)
	if player and (player == Player or IsTeamMate(Player, player)) then
		return
	end
	local Counter = character:FindFirstChild("Counter")
	if not Counter then
		Counter = Instance.new("IntValue")
		Counter.Name = "Counter"
		Counter.Value = 0
		table.insert(Counters, {Counter = Counter, Humanoid = humanoid})
		Debris:AddItem(Counter, 0.2)
		Counter.Parent = humanoid
	end
	Counter.Value = (Counter.Value + 1)
end

function ExplodePlayers() --Find the players with a counter variable, then kill them
	for i, v in pairs(Counters) do
		if v and v.Counter and v.Humanoid then
			local humanoid = v.Humanoid
			UntagHumanoid(humanoid)
			TagHumanoid(humanoid, Player)
			humanoid:TakeDamage(v.Counter.Value * DamagePerTouch)
		end
	end
	Counters = {}
end

function DoEruption()
	if not ToolEquipped or not CheckIfAlive() then
		return
	end
	Erupting = true
	local Direction = RootPart.CFrame.lookVector
	local LastPosition = (RootPart.CFrame * CFrame.new(0, -2.5, 0)).p
	
	for i = 1, Eruptions do --Create a new crystal formation
		local EruptionClone = Eruption:Clone()
		EruptionClone.Name = "Eruption"
		local Base = EruptionClone.BaseCenter
		for i, v in pairs(EruptionClone:GetChildren()) do --Move each part into position
			if v:IsA("BasePart") and v ~= Base then
				local offset = (v.CFrame.p - Base.CFrame.p)
				v.CFrame = (v.CFrame - v.CFrame.p + (LastPosition + (Direction * DistancePerObject)) + offset)
				local TouchConn = v.Touched:connect(CrystalTouched)
				Delay(0.2, (function()
					if TouchConn then
						TouchConn:disconnect()
					end
				end))
			end
		end
	
		Base.CFrame = (Base.CFrame - Base.CFrame.p + (LastPosition + (Direction * DistancePerObject)))
		
		ParticleExplosion(Base, {BrickColor.new("Really red").Color, BrickColor.new("Bright red").Color})
		local Sound = Sounds.CrystalExplosion:Clone()
		Sound.Parent = EruptionClone
		Sound:Play()
		
		LastPosition = (LastPosition + (Direction * DistancePerObject)) --Move on to the next eruption
		
		ExplodePlayers()
		
		wait(TimeBetweenEruptions)
		
		Delay((EruptionLife - 1.5), function() --Let physics take over crystal for effect
			for i, v in pairs(EruptionClone:GetChildren()) do
				if v:IsA("BasePart") then
					v.Anchored = true
					Debris:AddItem(v, math.random())
				end
			end
		end)
			
		Debris:AddItem(EruptionClone, EruptionLife)
		EruptionClone.Parent = game:GetService("Workspace")
		
	end
	
	Erupting = false

end

function Swing()
	local SwingParticle = Instance.new("Fire")
	SwingParticle.Name = "SwingParticle"
	SwingParticle.Heat = 9
	SwingParticle.Size = 5
	SwingParticle.Enabled = true
	SwingParticle.Color = BrickColor.new("Bright red").Color
	SwingParticle.SecondaryColor = SwingParticle.Color
	Debris:AddItem(SwingParticle, 1)
	SwingParticle.Parent = Handle
	
	local Animation = Instance.new("StringValue")
	Animation.Name = "toolanim"
	Animation.Value = "Slash"
	Animation.Parent = Tool
	
	DoEruption()

end

function Activated()
	if not ToolEquipped or not CheckIfAlive() or not Tool.Enabled then
		return
	end
	Tool.Enabled = false
	Swing()
	wait(EruptionLife)
	Tool.Enabled = true
end

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and RootPart and RootPart.Parent and Player and Player.Parent) and true) or false)
end

function Equipped()
	Character = Tool.Parent
	Humanoid = Character:FindFirstChild("Humanoid")
	RootPart = Character:FindFirstChild("HumanoidRootPart")
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