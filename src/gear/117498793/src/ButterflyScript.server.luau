local Tool = script.Parent 
local Fly = Tool.Handle 
local Lid = Fly:WaitForChild('Lid') 

local Character
local Player 
local Torso 
local Humanoid 

local Debris = Game:GetService('Debris')
local InsertService = Game:GetService('InsertService')

local ButterflyId = 117470774

local Equipped = false 

local Butterfly = InsertService:LoadAsset(ButterflyId):GetChildren()[1]

Tool.Enabled = true 
local RawDamage = 9 

local Gravity = 196.2
local Velocity = 50.0

local LidWeld = Tool:WaitForChild('LidWeld') 

function ComputeLaunchAngle(dx, dy, grav)		
	local g = math.abs(grav)
	local inRoot = (Velocity * Velocity * Velocity * Velocity) - (g * ((g * dx * dx) + (2 * dy * Velocity * Velocity)))
	if inRoot <= 0 then
		return 0.25 * math.pi
	end
	local root = math.sqrt(inRoot)
	local inATan1 = ((Velocity * Velocity) + root) / (g*dx)

	local inATan2 = ((Velocity * Velocity) - root) / (g*dx)
	local a1 = math.atan(inATan1)
	local a2 = math.atan(inATan2)
	if a1 < a2 then return a1 end
	return a2
end

local function Poison(hPart, part)
	if hPart and hPart.Parent and part and part.Parent then 
		local humanoid = hPart.Parent:FindFirstChild('Humanoid')
		if humanoid and humanoid ~= Humanoid then 
			humanoid:TakeDamage(RawDamage)
			if humanoid.Parent:FindFirstChild('ButterflyPoisonScript') == nil then 
				local bScript = Tool:WaitForChild('ButterflyPoisonScript'):Clone()
				bScript.Parent = humanoid.Parent
				bScript.Disabled = false 
			end 
		end 
	end 
end 

local function DropPoison(body)
	if not body then return end 
	local pPart = Instance.new('Part')
	pPart.FormFactor = 3 
	pPart.Size = Vector3.new(0.5, 0.5, 0.5)
	pPart.Parent = Game.Workspace 
	pPart.CFrame = body.CFrame
	pPart.BrickColor = BrickColor.new('Bright green')	

	local fire = Instance.new('Fire')
	fire.Color = Color3.new(0, 1, 0)
	fire.Parent = pPart 

	pPart.Touched:connect(function(hPart)
		Poison(hPart, pPart)
	end)

	Debris:AddItem(pPart, 3.0)

	return pPart:Clone(), pPart
end 

local function LobPoison(torso, body)

	local missile, missile2 = DropPoison(body)
	missile2:Destroy() 

	local target = torso.Position 

	local spawnPos = (body.Position - Vector3.new(0, 3, 0)) 

	local toTarget = target - spawnPos	
	local dY = toTarget.Y
	toTarget = Vector3.new(toTarget.X, 0, toTarget.Z)
	local dXZ = toTarget.magnitude
	toTarget = toTarget.unit 

	local theta = ComputeLaunchAngle(dXZ, dY, Gravity)

	local angleY = math.sin(theta)
	local angleXZ = math.cos(theta)

	local vY = angleY *  Velocity  
	local vX = toTarget.X * angleXZ * Velocity 
	local vZ = toTarget.Z * angleXZ * Velocity 		

	missile.CFrame = CFrame.new(spawnPos)
	missile.Velocity = Vector3.new(vX, vY, vZ) 

	missile.Parent = Game.Workspace	
	missile.CanCollide = true 
	missile.Touched:connect(function(hPart)
		Poison(hPart, missile)
	end)

	Debris:AddItem(missile, 5)
end 

local function CharacterNearby(body)
	local region = Region3.new(body.Position + Vector3.new(-15, -15, -15), body.Position + Vector3.new(15, 15, 15))
	local parts = Game.Workspace:FindPartsInRegion3(region, Character, 100)
	local torso 

	for _, part in pairs(parts) do 
		if part and part.Parent and part.Parent:FindFirstChild('Torso') then 
			torso = part.Parent.Torso  
		end 
	end 

	return torso 
end

local function FlyButterFly()
	if Butterfly then 
		local body = Butterfly:WaitForChild('Body')
		local rWing = Butterfly:WaitForChild('RightWing')
		local lWing = Butterfly:WaitForChild('LeftWing')
		local rWeld = body:WaitForChild('RightWingWeld')
		local lWeld = body:WaitForChild('LeftWingWeld')

		local count = 0 
		local anglePerFrame = 0.01
		local rCFrame = rWeld.C1 
		local lCFrame = lWeld.C1 
		local targetPos

		while Equipped do 
			lWeld.C1 = lWeld.C1 * CFrame.Angles(0, anglePerFrame * (count%6), 0)
			rWeld.C1 = rWeld.C1 * CFrame.Angles(0, -anglePerFrame * (count%6), 0)		
			if count%6 == 0 then anglePerFrame = -anglePerFrame end 
			count = count + 1 
			targetPos = Torso.Position + Vector3.new(4, 4, 4)
			local distance = (Torso.Position - body.Position).magnitude 
			if distance > 8 then 
				body.Velocity = (targetPos - body.Position).unit * 15.0
				body.CFrame = CFrame.new(body.Position, Torso.Position + Vector3.new(0, 9, 0))
			end 
			if math.random() < 0.03 then 
				DropPoison(body) 
				if math.random() < 0.25 then 
					local foundTorso = CharacterNearby(body) 
					if foundTorso then 
						LobPoison(foundTorso, body) 
					end 
				end 
			end 			
			wait()	
		end 

		rWeld.C1 = rCFrame
		lWeld.C1 = lCFrame
	end 
end 

local function OnActivated()
	if Tool.Enabled == false then 
		return 
	end 

	if not Torso or not Humanoid then 
		return 
	end 

	
	if Butterfly and Butterfly.Parent then 
		return 
	end 

	Tool.Enabled = false 
	local fClone = Fly:Clone()
	Fly.Transparency = 1.0 
	Lid.Transparency = 1.0
	fClone.CanCollide = true 
	fClone.Parent = Game.Workspace

	wait(1.5)
	fClone:Destroy()

	if not Butterfly.Parent then 	
		Butterfly.Parent = Character 
		Butterfly:MoveTo(Torso.Position + Vector3.new(2, 2, 2))
		Spawn(function()
			FlyButterFly()
		end)
	end 
end 

local function OnEquipped()
	Character = Tool.Parent 
	Player = Game.Players:GetPlayerFromCharacter(Character)	

	Torso = Character:WaitForChild('Torso')
	Humanoid = Character:WaitForChild('Humanoid')
	Equipped = true 
	if LidWeld then 
		LidWeld.Parent = Tool 
	end 
end 

local function OnUnequipped()
	Equipped = false 
	Fly.Transparency = 0.5
	Lid.Transparency = 0.0  
	Tool.Enabled = true 
	Butterfly.Parent = nil 
end 


Tool.Equipped:connect(OnEquipped)
Tool.Unequipped:connect(OnUnequipped)
Tool.Activated:connect(OnActivated) 
