--Made by Luckymaxer
--Updated for R15 avatar by StarWars

Ball = script.Parent

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Sounds = {
	Hit = Ball:WaitForChild("Hit"),
	HitGround = Ball:WaitForChild("HitGround"),
	HitWater = Ball:WaitForChild("HitWater"),
	SplashWater = Ball:WaitForChild("SplashWater"),
	Pop = Ball:WaitForChild("Pop"),
}

Sounds.Pop.PlayOnRemove = true

Ball.Transparency = 0
Ball.CanCollide = true

HitDelay = {Debounce = 0, Delay = 1}
HitForce = {Min = 8, Max = 60}
FloatForce = {Min = 40, Max = 65}
LastSplash = {Debounce = 0, Delay = 1.5}

function CheckTableForString(Table, String)
	for i, v in pairs(Table) do
		if string.find(string.lower(String), string.lower(v)) then
			return true
		end
	end
	return false
end

function CheckIntangible(Hit)
	local ProjectileNames = {"Water", "Arrow", "Projectile", "Effect", "Rail", "Laser", "Bullet"}
	if Hit and Hit.Parent then
		if ((not Hit.CanCollide or CheckTableForString(ProjectileNames, Hit.Name)) and not Hit.Parent:FindFirstChild("Humanoid")) then
			return true
		end
	end
	return false
end

function CastRay(StartPos, Vec, Length, Ignore, DelayIfHit)
	local Ignore = ((type(Ignore) == "table" and Ignore) or {Ignore})
	local RayHit, RayPos, RayNormal, RayMaterial = game:GetService("Workspace"):FindPartOnRayWithIgnoreList(Ray.new(StartPos, Vec * Length), Ignore)
	if RayHit and CheckIntangible(RayHit) then
		if DelayIfHit then
			wait()
		end
		RayHit, RayPos, RayNormal, RayMaterial = CastRay((RayPos + (Vec * 0.01)), Vec, (Length - ((StartPos - RayPos).magnitude)), Ignore, DelayIfHit)
	end
	return RayHit, RayPos, RayNormal, RayMaterial
end

function PlaySound(Sound, Pitch)
	if not Sound then
		return
	end
	local Pitch = (Pitch or Sound.Pitch)
	local SoundPart = Instance.new("Part")
	SoundPart.Name = "Effect"
	SoundPart.Transparency = 1
	SoundPart.Material = Enum.Material.Plastic
	SoundPart.Shape = Enum.PartType.Block
	SoundPart.TopSurface = Enum.SurfaceType.Smooth
	SoundPart.BottomSurface = Enum.SurfaceType.Smooth
	SoundPart.FormFactor = Enum.FormFactor.Custom
	SoundPart.Size = Vector3.new(0.2, 0.2, 0.2)
	SoundPart.CanCollide = false
	SoundPart.Anchored = true
	SoundPart.Locked = true
	SoundPart.Archivable = true
	local Sound = Sound:Clone()
	Sound.Pitch = Pitch
	Sound.Parent = SoundPart
	Debris:AddItem(SoundPart, 1.5)
	SoundPart.CFrame = Ball.CFrame
	SoundPart.Parent = game:GetService("Workspace")
	Sound:Play()
end

function BallHit(Hit)
	if not Hit or not Hit.Parent then
		return
	end
	
	local RayHit, RayPos, RayNormal, RayMaterial = CastRay(Ball.Position, Vector3.new(0, -1, 0), (Ball.Size.Y * 1.5), {Ball}, false)
	
	local DelayedHit = false
	local Now = tick()
	local TimeSinceLastHit = (Now - HitDelay.Debounce)
	if TimeSinceLastHit >= HitDelay.Delay then
		HitDelay.Debounce = Now
	else
		DelayedHit = true
		return
	end
	
	local character = Hit.Parent
	local humanoid = character:FindFirstChild("Humanoid")
	local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
	
	if humanoid and humanoid.Health > 0 and torso then
		
		if DelayedHit then
			return
		end
		
		HitDelay.Delay = 1
		
		local HitDirection = (torso.Velocity.Unit * Vector3.new(1, 0, 1))--CFrame.new(Hit.Position, Ball.Position).lookVector
		Ball.Velocity = (Vector3.new(0, math.random(FloatForce.Min, FloatForce.Max), 0) + (HitDirection * math.random(HitForce.Min, HitForce.Max)))
		Ball.CFrame = (Ball.CFrame + Vector3.new(0, 0.01, 0))
		
		PlaySound(Sounds.Hit, (math.random(500, 1500) * 0.001))
		
	elseif Ball.Velocity.Magnitude > 1.5 then
		
		HitDelay.Delay = 0.25
		
		if RayHit then
			if RayMaterial == Enum.Material.Water then
				if (Now - LastSplash.Debounce) >= LastSplash.Delay then
					LastSplash.Debounce = Now
					PlaySound(Sounds.SplashWater)
				else
					if DelayedHit then
						return
					end
					PlaySound(Sounds.HitWater)
				end
				
			else
				PlaySound(Sounds.HitGround)
			end
		end
		
	end
	
end

PlaySound(Sounds.Hit)

Ball.Touched:connect(BallHit)