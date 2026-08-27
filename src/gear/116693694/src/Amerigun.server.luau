-- SolarCrane

function New(ty)
	return function(data)
		local obj = Instance.new(ty)
		for k, v in pairs(data) do
			if type(k) == 'number' then
				v.Parent = obj
			else
				if type(v) == 'function' then
					obj[k]:connect(v)
				else
					obj[k] = v
				end
			end
		end
		return obj
	end
end

function GetRandomFloat(minimum, maximum)
	local unitRandom = math.random()
	local interval = maximum - minimum
	-- there is potential overflow here if the interval is larger than max float
	if interval <= 0 then
		print('GetRandomFloat: The range beween minimum and maximum is less than zero.')
		return nil
	end
	local randomNum = (unitRandom * interval) + minimum
	return randomNum
end

function GetRandomUnitVector()
	return Vector3.new(GetRandomFloat(-1,1), GetRandomFloat(-1,1), GetRandomFloat(-1,1)).unit
end

local COOLDOWN_TIME = 3
local MAX_RANGE = 300
local DAMAGE = 70

local COLORS = {'Institutional white', 'Bright red', 'Really blue'}

local PlayersService = Game:GetService('Players')
local DebrisService = Game:GetService('Debris')

local Tool = script.Parent
local Handle = Tool:WaitForChild('Handle')
local MyMouse = nil
local MyPlayer = nil
local MyCharacter = nil
local MyTorso = nil
local MyHumanoid = nil
local MyMouse = nil
local ChargeBall = nil
local Particles = {}
do
	local particles_mt = {}
	particles_mt.__mode = "v"
	setmetatable(Particles, particles_mt)
end
local LastActivation = tick()


function CreatePart(from, to, name, color, light)
	local length = math.min((to-from).magnitude, 5)
	return New'Part'{
		TopSurface = 'Smooth',
		BottomSurface = 'Smooth',
		Transparency = 0,
		CanCollide = false,
		FormFactor = 'Custom',
		Size = Vector3.new(1,1,length),
		light,
		Name = name,
		BrickColor = BrickColor.new(color),
		CFrame = CFrame.new((from + to) / 2, to),
		Anchored = true,
	}
end

-- Returns the ancestor that contains a Humanoid, if it exists
local function FindCharacterAncestor(subject)
	if subject and subject ~= Workspace then
		local humanoid = subject:FindFirstChild('Humanoid')
		if humanoid then
			return subject, humanoid
		else
			return FindCharacterAncestor(subject.Parent)
		end
	end
	return nil
end

function TagHumanoid(humanoid, player)
	-- Add more tags here to customize what tags are available.
	while humanoid:FindFirstChild('creator') do
		humanoid:FindFirstChild('creator'):Destroy()
	end 
	local creatorTag = Instance.new("ObjectValue")
	creatorTag.Value = player
	creatorTag.Name = "creator"
	DebrisService:AddItem(creatorTag, 1.5)
	creatorTag.Parent = humanoid
end

function ChargeUp(starModel)
	local chargeSound = Handle:FindFirstChild('Charge')

	delay(0.25, function()
		if chargeSound then
			chargeSound:Play()
		end
	end)
	local chargeUpBall = New'Part'{
		Name = "ChargeUpBall",
		FormFactor = 'Custom',
		Size = Vector3.new(1,1,1),
		TopSurface = 'Smooth',
		BottomSurface = 'Smooth',
		BrickColor = BrickColor.new('Institutional white'),
		Transparency = 0.5,
		New'SpecialMesh'{
			Scale = Vector3.new(0.1,0.1,0.1),
			MeshType = 'Sphere'
		},
		Parent = MyCharacter
	}
	New'ManualWeld'{
		Part0 = Handle,
		Part1 = chargeUpBall,
		C0 = CFrame.new(0,0,-1.6),
		Parent = chargeUpBall
	}
	DebrisService:AddItem(chargeUpBall, 3)
	Spawn(function()
		for starCount = 1, 20 do
			local star = New'Part'{
				FormFactor = 'Custom',
				Size = Vector3.new(0.4,0.4,0.4),
				TopSurface = 'Smooth',
				BottomSurface = 'Smooth',
				BrickColor = BrickColor.new(COLORS[math.random(1, #COLORS)]),
				New'PointLight'{
					Brightness = 4,
					Range = 4
				},
				CanCollide = false,
				CFrame = CFrame.new(chargeUpBall.CFrame.p + GetRandomFloat(15,20) * GetRandomUnitVector()),
				Parent = starModel
			}
			star.Velocity = (MyTorso.CFrame.p - star.CFrame.p).unit:Cross(CFrame.Angles(GetRandomFloat(0, math.pi*2),0,0) * Vector3.new(0,1,0)) * 50
			local propulsion = New'RocketPropulsion'{
				Target = chargeUpBall,
				CartoonFactor = 1,
				TargetRadius = 2.337,
				MaxSpeed = 35,
				TurnD = 1000,
				TurnP = 400000,
				ThrustP = 55,
				MaxTorque = Vector3.new(400000, 400000, 400000),
				ReachedTarget = function ()
					--print("Reached target")
					if chargeUpBall and chargeUpBall:FindFirstChild('Mesh') then
						chargeUpBall.Mesh.Scale = chargeUpBall.Mesh.Scale + Vector3.new(0.1,0.1,0.1)
					end
					if star then
						star:Destroy()
					end
				end
			}
			for i = 1, 2 do
				local starClone = star:Clone()
				starClone.Parent = starModel
				New'ManualWeld'{
					Part0 = star,
					Part1 = starClone,
					C0 = CFrame.Angles(GetRandomFloat(math.pi/8, 3 * math.pi/8),
						GetRandomFloat(math.pi/8, 3 * math.pi/8),
						GetRandomFloat(math.pi/8, 3 * math.pi/8)),
					Parent = star
				}
			end
			table.insert(Particles, star)
			propulsion.Parent = star
			propulsion:Fire()
			wait(0.05)
		end
	end)
	--wait(0.5)
	return chargeUpBall
end

function Shoot()
	local starModel = New'Model'{
		Name = "StarModel",
		Parent = Workspace
	}
	DebrisService:AddItem(starModel, 8)
	ChargeBall = ChargeUp(starModel)
	--MyMouse.TargetFilter = starModel
	wait(1)
	local shootSound = Handle:FindFirstChild('Shoot')
	if shootSound then
		shootSound:Play()
	end
	ChargeBall.Mesh.Changed:connect(function(prop)
		if ChargeBall and ChargeBall:FindFirstChild('Mesh') then -- and #Particles == 0 then
			-- Rainbow code!
			local hitObj, hitPos = Workspace:FindPartOnRayWithIgnoreList(Ray.new(ChargeBall.CFrame.p,(MyHumanoid.TargetPoint - ChargeBall.CFrame.p).unit * MAX_RANGE), {MyCharacter, starModel, rayModel})--, starModel})
			local hitChar = FindCharacterAncestor(hitObj)
			if hitChar and hitChar:FindFirstChild('Humanoid') then
				TagHumanoid(hitChar.Humanoid, MyPlayer)
				hitChar.Humanoid:TakeDamage(DAMAGE)
			end
			local ray
			if hitPos then
				ray = Ray.new(ChargeBall.CFrame.p, hitPos - ChargeBall.CFrame.p)
			else
				ray = Ray.new(ChargeBall.CFrame.p, (MyHumanoid.TargetPoint - ChargeBall.CFrame.p).unit * MAX_RANGE)
			end
			local stepDir = ray.Direction.unit
			local rayModel = New'Model'{
				Name = 'RayModel',
				Parent = Workspace
			}
			DebrisService:AddItem(rayModel, 0.5)
			for i = 0, ray.Direction.magnitude / 5 do
				local whiteRay = CreatePart(ray.Origin + stepDir*i*5 - Vector3.new(0,1,0),
											ray.Origin + stepDir*(i+1)*5 - Vector3.new(0,1,0),
											'White',
											'Institutional white',
											New'PointLight'{
					Brightness = 0.5,
					Range = 8,
					Color = Color3.new(255,255,255),
				})
				local redRay = CreatePart((ray.Origin + stepDir*i*5),
										(ray.Origin + stepDir*(i+1)*5),
										'Red',
										'Bright red',
										New'PointLight'{
					Brightness = 4,
					Range = 8,
					Color = Color3.new(255,0,0),
				})
				local blueRay = CreatePart((ray.Origin + stepDir*i*5) - Vector3.new(0,2,0),
											(ray.Origin + stepDir*(i+1)*5) - Vector3.new(0,2,0),
											'Blue',
											'Really blue',
											New'PointLight'{
					Brightness = 4,
					Range = 8,
					Color = Color3.new(0,0,255),
				})
				whiteRay.Parent = rayModel
				redRay.Parent = rayModel
				blueRay.Parent = rayModel
			end
			ChargeBall:Destroy()
			ChargeBall = nil
			for i = 1, 10 do
				wait(0.12)
				for _, child in pairs(starModel:GetChildren()) do
					if child:IsA('BasePart') then
						child.Transparency = math.min(1, child.Transparency + 0.1)
						if child.Transparency == 1 then
							child:Destroy()
						end
					end
				end
			end
		end
	end)
end


function CanShoot()
	return tick() - LastActivation > COOLDOWN_TIME and
			not ChargeBall and
			MyCharacter and
			MyCharacter:FindFirstChild('Right Shoulder', true) and
			MyHumanoid and
			MyHumanoid.Health > 0
end

function OnActivated()
	if CanShoot() then
		Tool.Enabled = false
		delay(COOLDOWN_TIME, function() Tool.Enabled = true end)
		LastActivation = tick()
		Shoot()
	end
end

function OnEquipped(mouse)
	MyCharacter = Tool.Parent
	MyPlayer = PlayersService:GetPlayerFromCharacter(MyCharacter)
	MyHumanoid = MyCharacter:FindFirstChild('Humanoid')
	MyTorso = MyCharacter:FindFirstChild('Torso')
	MyMouse = MyPlayer:GetMouse()
end

function OnUnequipped()
	local shootSound = Handle:FindFirstChild('Shoot')
	if shootSound then
		shootSound:Stop()
	end
	local chargeSound = Handle:FindFirstChild('Charge')
	if chargeSound then
		chargeSound:Stop()
	end
end




Tool.Activated:connect(OnActivated)
Tool.Equipped:connect(OnEquipped)
Tool.Unequipped:connect(OnUnequipped)

