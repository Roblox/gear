--Fixed by Luckymaxer

--Crystal Sword

local Tool = script.Parent
Tool.Enabled = true
local Handle = Tool.Handle
local Character = nil
local Humanoid = nil
local Player = nil

local EruptionID = 84929999
local Eruption = game:GetService("InsertService"):LoadAsset(EruptionID):GetChildren()[1]

function IsTeamMate(Player1, Player2)
	return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
end
	
function TagHumanoid(humanoid, player)
	local Creator_Tag = Instance.new("ObjectValue")
	Creator_Tag.Name = "creator";
	Creator_Tag.Value = player;
	game:GetService("Debris"):AddItem(Creator_Tag, 2)
	Creator_Tag.Parent = humanoid
end
	
function UntagHumanoid(humanoid)
	for _, v in pairs(humanoid:GetChildren()) do
		if v:IsA("ObjectValue") and v.Name == "creator" then
			v:Destroy()
		end
	end
end

EruptionChildren = Eruption:GetChildren()
if #EruptionChildren > 0 then
	for _,child in pairs(EruptionChildren) do
		if child:IsA('BasePart') then
			if child.Name == 'Base' then
				child.BrickColor = BrickColor.new(11)
			elseif child.Name == 'Crystal' then
				child.BrickColor = BrickColor.new(23)
			else
				child.BrickColor = BrickColor.new(11)
			end
		
			child.Transparency = 0.25
			child.Material = 'Ice'
		end
	end
end


local Debris = game.Debris


local Damage = 5
local Eruptions = 5
local DistancePerObject = 7
local TimeBetweenEruptions = .05
local EruptionLife = 3
local DamagePerTouch = 5

Counters = {} --Fix implemented by Luckymaxer

--Creates a random number of particles and lets them fall down from the sky.  
function ParticleExplosion(Parent, Colors)
	local NumParticles = math.random(5,15)
	for i = 0, NumParticles do
		--Create the parts for the particles to emit from
		local ParticlePoint = Instance.new("Part")
		ParticlePoint.Size = Vector3.new(1,1,1)
		ParticlePoint.Parent = Parent
		ParticlePoint.Position = Parent.Position + Vector3.new(math.random(-5,5), math.random(4, 7), math.random(-5,5)	)
		ParticlePoint.Transparency = 1
		
		--Create the particles for display
		local Particle = Instance.new("Fire")
		local Color = Colors[math.random(1, #Colors)]
		Particle.Color = Color
		Particle.SecondaryColor = Color
		Particle.Parent = ParticlePoint

		--Send them flying
		local ParticleForce = Instance.new("BodyForce")
		ParticleForce.Parent = ParticlePoint
		ParticleForce.force = Vector3.new(math.random(-20,20), 40, math.random(-20,20)) * 7
		
		local DespawnScript = script:WaitForChild("Despawn"):Clone()
		DespawnScript.Parent = ParticlePoint
		DespawnScript:WaitForChild("Time").Value = .1 + math.random()
		DespawnScript.Disabled = false
	end

end


--Fired when the crystal touches something
--Add to the player's touched counter.  Damage will be done based on this number later
function onCrystalTouched(part)
	local Character = part.Parent
	if not Character:FindFirstChildOfClass("Humanoid") then return end
	
	if Humanoid == Character:FindFirstChildOfClass("Humanoid") then return end

	local Counter = Character:FindFirstChild("Counter")
	if not Counter then --If we don't have a counter, add a new one
		Counter = Instance.new("IntValue")
		Counter.Name = "Counter"
		Counter.Value = 0
		Counter.Parent = Character.Humanoid
		table.insert(Counters, Counter)
		Debris:AddItem(Counter, .2)
	end

	Counter.Value = Counter.Value + 1
end

--Find the players with a counter variable, then kill them
--If they survive, knock them over
function ExplodePlayers()
	for i, v in pairs(Counters) do
		if v and v.Parent and v.Parent:IsA("Humanoid") and v.Parent ~= Humanoid and not IsTeamMate(Player,game:GetService("Players"):GetPlayerFromCharacter(v.Parent.Parent)) then
			UntagHumanoid(v.Parent)
			TagHumanoid(v.Parent,Player)
			v.Parent:TakeDamage(v.Value * DamagePerTouch)
		end
	end
	Counters = {}
end


Erupting  = false
function DoEruption()
	Erupting = true
	local Torso = Character:FindFirstChild("HumanoidRootPart")
	local Direction = Torso.CFrame.lookVector
	local LastPosition = Torso.Position + Vector3.new(0, -2.5, 0)
	
	for i = 1, Eruptions do
		--Create a new crystal formation
		local EruptionClone = Eruption:Clone()
		--Clean up after ourselves
		Debris:AddItem(EruptionClone, EruptionLife)
		EruptionClone.Name = "Eruption"
		local Children = EruptionClone:GetChildren()
		local BasePart = EruptionClone.BaseCenter
		for z = 1, #Children do
			--Move each part into position
			if(Children[z] ~= BasePart) then
				local part = Children[z]
				part.Material = Enum.Material.Glass
				local offset = part.CFrame.p - BasePart.CFrame.p
				part.CFrame = part.CFrame - part.CFrame.p + (LastPosition + (Direction * DistancePerObject)) + offset
				local cobj = part.Touched:Connect(onCrystalTouched)
				delay(.5, function() cobj:Disconnect() end)
			end
		end
		EruptionClone.Parent = workspace
		
		BasePart.CFrame = BasePart.CFrame - BasePart.CFrame.p + (LastPosition + (Direction * DistancePerObject))

		--Play the particle and sound effects
		ParticleExplosion(BasePart, {BrickColor.new(11).Color, BrickColor.new(23).Color} )
		local Sound = script.CrystalExplosion:Clone()
		Sound.Parent = BasePart
		Sound:Play()

		--Move on to the next eruption
		LastPosition = LastPosition + (Direction * DistancePerObject)

		--Kill any fool that happened to get caught in the explosion
		ExplodePlayers()

		wait(TimeBetweenEruptions)

		--Let physics take over crystal for effect
		delay(EruptionLife - 1.5, function()
			local ChildrenClone = Children
			for z= 1, #ChildrenClone do
				ChildrenClone[z].Anchored = false
				local DespawnScript = script:WaitForChild("Despawn"):Clone()
				DespawnScript.Parent = ChildrenClone[z]
				DespawnScript:WaitForChild("Time").Value = math.random()
				DespawnScript.Disabled = false
				--Debris:AddItem(ChildrenClone[z], math.random())
			end
		end)
		

	end
	
	Erupting = false

end


--Swing the sword
function Swing()
	--Add a particle effect to the sword when you swing it to make it seem powerful
	local SwingParticle = Instance.new("Fire")
	SwingParticle.Name = "SwingParticle"
	SwingParticle.Parent = Handle

	local Color = BrickColor.new(23).Color
	SwingParticle.Color = Color
	SwingParticle.SecondaryColor = Color
	Debris:AddItem(SwingParticle, 1)

	--Play the swing animation
	local Animation = Instance.new("StringValue")
	Animation.Name = "toolanim"
	Animation.Value = "Slash"
	Animation.Parent = Tool

	--How do i shot crystals?
	DoEruption()

end



function onActivated()
	if not Tool.Enabled then return end
	if Erupting then return end
	if not Character then return end
	Tool.Enabled = false
	
	Swing()

	wait(EruptionLife)
	Tool.Enabled = true

end
Tool.Activated:Connect(onActivated)

local Touch
function onEquipped()
	Character = Tool.Parent
	Humanoid = Tool.Parent:FindFirstChildOfClass("Humanoid")
	Player = game:GetService("Players"):GetPlayerFromCharacter(Character)
	Touch = Handle.Touched:Connect(function(hit)
		if not hit or not hit.Parent then return end
		local Hum = hit.Parent:FindFirstChildOfClass("Humanoid")
		if not Hum or Hum ~= Humanoid or IsTeamMate(Player,game:GetService("Players"):GetPlayerFromCharacter(Hum.Parent)) then return end
		Humanoid:TakeDamage(Damage)
	end)
end
Tool.Equipped:Connect(onEquipped)

function onUnequipped()
	if Touch then Touch:Disconnect();Touch=nil end
end
Tool.Unequipped:Connect(onUnequipped)