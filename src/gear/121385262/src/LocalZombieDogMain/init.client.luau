local ZombieDog = script:WaitForChild('ZombieDog')
while not ZombieDog.Value do ZombieDog.Changed:wait() end
ZombieDog = ZombieDog.Value

local DogTorso = ZombieDog:WaitForChild('DogTorso')

local Character = script.Parent
local Torso = Character:WaitForChild('Torso')

local Humanoid = ZombieDog.Humanoid

local ANIM_Idle = Humanoid:LoadAnimation(ZombieDog:WaitForChild('ANIM_Idle'))
local ANIM_Run =  Humanoid:LoadAnimation(ZombieDog:WaitForChild('ANIM_Run'))
local ANIM_Sit =  Humanoid:LoadAnimation(ZombieDog:WaitForChild('ANIM_Sit'))

local SitValue = ZombieDog:WaitForChild('Sit')
local SitGyro = Instance.new('BodyGyro')
SitGyro.maxTorque = Vector3.new(10000000, 0, 10000000)
SitGyro.Parent = ZombieDog.Torso
SitGyro.cframe = CFrame.new(Vector3.new(0, 0, 0), Vector3.new(0, 0, 1))

local DeadWeight = (CFrame.new(Torso.Position, DogTorso.Position)*CFrame.new(0, 0, -5)).p

local IsRunning = false
Spawn(function()
	ANIM_Idle:Play()
	while true do
		local speed = (DogTorso.Velocity - Vector3.new(0, DogTorso.Velocity.y, 0)).magnitude
		if speed > 0.1 then
			if not IsRunning then
				IsRunning = true
				print("Run")
				ANIM_Idle:Stop()
				ANIM_Run:Play()
			end
		else
			if IsRunning then
				IsRunning = false
				print("Stop")
				ANIM_Run:Stop()
				ANIM_Idle:Play()
			end
		end
		wait()
	end
end)

SitValue.Changed:connect(function()
	if SitValue.Value then
		-- Go into sitting mode
		ANIM_Sit:Play()
		Humanoid.WalkSpeed = 0	
		SitGyro.maxTorque = Vector3.new(0, 10000000, 0)
		SitGyro.cframe = CFrame.new(DogTorso.Position, Torso.Position)
	else
		-- Go into movement mode
		ANIM_Sit:Stop()
		SitGyro.maxTorque = Vector3.new(10000000, 0, 10000000)
		SitGyro.cframe = CFrame.new(DogTorso.Position, Torso.Position)
	end
end)

Spawn(function()
	while Humanoid.Health > 0 do
		if SitValue.Value then
			-- Update the sit gyro, pointing the dog at us.
			SitGyro.cframe = CFrame.new(DogTorso.Position, Torso.Position)
		else
			-- Check if we need to jump
			if not Humanoid.Jump and not SitValue.Value then
				local castFrom = DogTorso.CFrame*CFrame.new(0, -1, -1.3)*CFrame.Angles(-math.pi/4+0.30, 0, 0)
				local castRay = Ray.new(castFrom.p, castFrom.p + castFrom.lookVector)
				local ignore = {}
				local part, at = game.Workspace:FindPartOnRay(castRay, ZombieDog)
				while part and (not part.CanCollide or part:IsDescendantOf(ZombieDog) or part:IsDescendantOf(Character)) do
					table.insert(ignore, part)
					part, at = game.Workspace:FindPartOnRayWithIgnoreList(castRay, ignore)
				end
				if part then
					if (at - castFrom.p).magnitude < 2.3 then
						Humanoid.Jump = true
						ZombieDog.Torso.Velocity = Vector3.new(ZombieDog.Torso.Velocity.x, 20, ZombieDog.Torso.Velocity.z)
					end		
				end
			end
			
			-- Update deadweight.
			DeadWeight = (CFrame.new(Torso.Position, DeadWeight)*CFrame.new(0, 0, -5)).p	
			
			-- Move dog towards deadweight.
			Humanoid:MoveTo(DeadWeight, Torso)
				
			-- Update dog move speed.
			local dist = (Torso.Position - DogTorso.Position).magnitude
			local frac = math.min(1, dist / 40)
			Humanoid.WalkSpeed = math.sqrt(frac)*16
			if IsRunning then
				ANIM_Run:AdjustSpeed(math.max(1, math.sqrt(frac)*5), 0)
			end
		end
		wait()
	end
	script:Destroy()
end)

ZombieDog.DogTorso.ClickDetector.MouseClick:connect(function(player)
	if player == game.Players:GetPlayerFromCharacter(Character) then
		SitValue.Value = not SitValue.Value
	end
end)