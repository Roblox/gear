-- Miiiinndd the drop!
local Workspace = game.Workspace
local Debris = game.Debris

local Radius = 10

local Tool = script.Parent
local Handle = Tool:WaitForChild("Handle")
local Character = nil
local PowerUp = Handle:WaitForChild("PowerUp")
local PowerDown = Handle:WaitForChild("PowerDown")
local UseSound = Handle:WaitForChild("Use")

local Lifting = Tool:WaitForChild("Lifting")
local otherParts = {}
local liftingForces = {}


local function ParticlePart(PrimaryColor, SecondaryColor)
	local part = Instance.new('Part')
	part.Transparency = 0
	part.Size = Vector3.new(1, 1, 1)
	
	local effect = Instance.new('Fire')
	effect.Color = PrimaryColor
	effect.SecondaryColor = SecondaryColor
	effect.Size = 3
	effect.Parent = part

	return part
end

local function RecursiveModelMass(Model)
	local mass = 0
	for _, v in pairs(Model:GetChildren()) do
		mass = mass + RecursiveModelMass(v)
	end
	if Model:IsA('BasePart') then
		mass = mass + Model:GetMass()
	end
	print(Model, mass)
	return mass
end


function ThrowToPoint(location)
	Lifting.Value = false

	for _, v in pairs(otherParts) do
		v.CanCollide = true
		game.Debris:AddItem(v, 1.5)
		v.Touched:connect(function(part) 
			if not part then return end
			local character = part.Parent
			if not character then return end
			if character == Character then return end
			local humanoid = character:FindFirstChild('Humanoid')
			if not humanoid then return end
		
			humanoid:TakeDamage(2) -- Get hit!
			 
		end)
	end
	
	for _, v in pairs(liftingForces) do
		if v.Parent and (v.Parent.Name == 'Torso' or v.Parent.Name == 'UpperTorso') then
			game.Debris:AddItem(v, 1.5)
		end
		v.position = location
		
	end
	
end

function LiftArea(location)
	Lifting.Value = true
	-- Create the effect
	otherParts = {}
	for i = 1, 5 do
		otherParts[i] = ParticlePart(BrickColor.new(28).Color, Color3.new(70/255, 69/255, 19/255))
		otherParts[i].Position = location + Vector3.new(math.cos(math.rad((i/5) * 360 + math.random(-180, 180))) * Radius, 2, math.sin(math.rad((i/5) * 360 + math.random(-180, 180))) * Radius)
		otherParts[i].CanCollide = false
		otherParts[i].Parent = Workspace
		

		local target = otherParts[i].Position + Vector3.new(0, 5, 0)
		local force = Instance.new('BodyPosition')
		force.D = .9 + math.random(-.1, .1)
		force.P = 100 + math.random(-15, 15)
		force.maxForce = Vector3.new(500, 500, 500)
		force.position = target
		table.insert(liftingForces, force)
		force.Parent = otherParts[i]
			
	
		local mesh = Instance.new('SpecialMesh')
		mesh.MeshId = 'http://www.roblox.com/asset/?id=1290033'
		mesh.TextureId = 'http://www.roblox.com/asset/?id=1290030'
		mesh.Parent = otherParts[i]

	end

	-- Find any players unlucky enough to be near the hit
	local players = game.Players:GetPlayers()
	for _, v in pairs(players) do
		local character = v.Character
		if character and character ~= Tool.Parent then
			local torso = character:FindFirstChild('Torso') or character:FindFirstChild("UpperTorso")
			if torso then
				if (torso.Position - location).magnitude <= Radius then
					character.Humanoid.Sit = true
			
					local target = torso.Position + Vector3.new(0, 5, 0)
					local force = Instance.new('BodyPosition')
					force.D = .99 + math.random(-.1, .1)
					force.P = 196.2 + math.random(-15, 15) + RecursiveModelMass(character) * 500
					force.maxForce = Vector3.new(5000, 10000, 5000)
					force.position = target
					table.insert(liftingForces, force)
		
					force.Parent = torso
				end
			end
		end
	end

	delay(4, function()
		if not Lifting.Value then return end

		Lifting.Value = false
		
		for _, v in pairs(liftingForces) do
				if v.Parent and v.Parent:IsA('BasePart') then v.Parent.CanCollide = true end
				v:Destroy()
				for _, p in pairs(otherParts) do
					game.Debris:AddItem(p, 1.5)
				end
		end
		
	end)

end


function ShootTracer(target)
	local direction = (target - Handle.Position).unit

	UseSound:Play()	


	local fireEffect = ParticlePart(Color3.new(85 / 255, 1, 1), Color3.new(170 / 255, 1, 1))
	fireEffect.Position = Handle.Position + (direction * 4)
	fireEffect.Transparency = 1
	local force = Instance.new('BodyVelocity')
	force.P = 1000
	force.maxForce = Vector3.new(1000, 1000, 1000)
	force.velocity = direction * 100
	
	force.Parent = fireEffect

	fireEffect.Touched:connect(function(part) 
		if Lifting.Value then
			ThrowToPoint(fireEffect.Position)
		else	
			LiftArea(fireEffect.Position)
		end
		fireEffect:Destroy() 
	end)
	
		
	fireEffect.Parent = Workspace	
end




Tool.Enabled = true
function onActivated()
	if not Tool.Enabled then return end
	Tool.Enabled = false	

	
	wait(2)
	Tool.Enabled = true	
end
Tool.Activated:connect(onActivated)
	

function onEquipped()
	Character = Tool.Parent
	PowerUp:Play()
end
Tool.Equipped:connect(onEquipped)


function onUnequipped()
	Character = nil
	PowerDown:Play()
end

Tool.Unequipped:connect(onUnequipped)

function onMessageRecieved(message)
	if message:IsA("Vector3Value") and message.Name == "GloveTarget" then
		ShootTracer(message.Value)
		message:Destroy()
	end
end
Tool.ChildAdded:connect(onMessageRecieved)


