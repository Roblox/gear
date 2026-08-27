--// Made by StarWars
local Debris = game:GetService('Debris')

local Tool = script.Parent
local Handle = Tool:FindFirstChild("Handle")
if not Handle then return end

local Sword = require(754568173)

local Player = nil
local Character = nil
local Humanoid = nil
local Torso = nil

local EruptionID = 84929999
local Eruption = game:GetService("InsertService"):LoadAsset(EruptionID):GetChildren()[1]

local SwordData = Sword.SwordFunctions.GetData("Classic")
local SwordModel = Sword.SwordFunctions.GetSword("Classic")
local Config = Sword.SwordFunctions.CreateConfiguration(Tool, SwordData)

local UnsheathSound = Handle:WaitForChild("Unsheath")
local SlashSound = Handle:WaitForChild("Slash")

local SwingParticle = Instance.new("Fire")
SwingParticle.Color = BrickColor.new(28).Color
SwingParticle.SecondaryColor = BrickColor.new(28).Color

local Erupting = false
local Damage = 5
local Eruptions = 5
local DistancePerObject = 7
local TimeBetweenEruptions = .05
local EruptionLife = 3
local DamagePerTouch = 10

local Counters = {}

function onCrystalTouched(part)
	local Character = part.Parent
	if not Character:FindFirstChild("Humanoid") then return end

	local Player = game.Players:GetPlayerFromCharacter(Character)
	if Player == game.Players:GetPlayerFromCharacter(Tool.Parent) then return end

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

function ExplodePlayers()
	for i, v in pairs(Counters) do
		if v and v.Parent and v.Parent:IsA("Humanoid") then
			v.Parent:TakeDamage(v.Value * DamagePerTouch)
		end
	end
	Counters = {}
end

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
		Debris:AddItem(ParticleForce, .3)
		
		Debris:AddItem(ParticlePoint, .1 + math.random())
	end

end

function DoEruption()
	Erupting = true
	local Direction = Torso.CFrame.lookVector
	local LastPosition = Torso.Position + Vector3.new(0, -2.5, 0)	
	
	for i = 1, Eruptions do
		--Create a new crystal formation
		local EruptionClone = Eruption:Clone()
		EruptionClone.Name = "Eruption"
		local Children = EruptionClone:GetChildren()
		local BasePart = EruptionClone.BaseCenter
		for z = 1, #Children do
			--Move each part into position
			if(Children[z] ~= BasePart) then
				local part = Children[z]
				local offset = part.CFrame.p - BasePart.CFrame.p
				part.CFrame = part.CFrame - part.CFrame.p + (LastPosition + (Direction * DistancePerObject)) + offset
				local cobj = part.Touched:connect(onCrystalTouched)
				delay(.2, function() cobj:disconnect() end)
			end
		end
		EruptionClone.Parent = game.Workspace
		
		BasePart.CFrame = BasePart.CFrame - BasePart.CFrame.p + (LastPosition + (Direction * DistancePerObject))

		--Play the particle and sound effects
		ParticleExplosion(BasePart, {BrickColor.new(28).Color, Color3.new(70/255, 69/255, 19/255)} )
		local Sound = Tool.CrystalExplosion:Clone()
		Sound.Parent = EruptionClone
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
				Debris:AddItem(ChildrenClone[z], math.random())
			end
		end)
		
		--Clean up after ourselves
		Debris:AddItem(EruptionClone, EruptionLife)
	end
	
	Erupting = false
end

function OnActivated()
	if not Tool.Enabled then return end
	if Erupting then return end
	if not Character then return end
	Tool.Enabled = false
	local NewParticle = SwingParticle:Clone()
	NewParticle.Parent = Handle
	SlashSound:Play()
	Config.Damage.Value = SwordData.Damage.Slash
	SwordData.Functions.Slash(Player, Tool)
	Debris:AddItem(NewParticle, 1)
	
	DoEruption()
	Config.Damage.Value = 0
	wait(EruptionLife)
	Tool.Enabled = true
end

function OnEquipped()
	Character = Tool.Parent
	Player = game.Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChildOfClass('Humanoid')
	Torso = Character:FindFirstChild('HumanoidRootPart')
	
	UnsheathSound:Play()
end

function OnUnequipped()
	Player = nil
	Character = nil
	Humanoid = nil
	Torso = nil
end


Tool.Activated:Connect(OnActivated)
Tool.Equipped:Connect(OnEquipped)
Tool.Unequipped:Connect(OnUnequipped)
