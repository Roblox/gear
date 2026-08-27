
local Create = LoadLibrary('RbxUtility').Create

------------------------------------------------------------------
--|                        Main Globals                        |--
------------------------------------------------------------------
local Character = script.Parent
local Torso = Character:WaitForChild('Torso')
local Humanoid = Character:WaitForChild('Humanoid')

local Glider;

local FlyingVelo;
local FlyingGyro;

local FlyAnimSource = Create'Animation'{
	Name = 'FlyGliderAnim';
	Parent = Character;
	AnimationId = 'http://www.roblox.com/asset/?id=119783214';
}
local FlyAnim = Humanoid:LoadAnimation(FlyAnimSource)


------------------------------------------------------------------
--|                     Setup functions                        |--
------------------------------------------------------------------
local function CreateGlider()
	Glider = Create'Part'{
		Parent = Character;
		FormFactor = 'Custom';
		Size = Vector3.new(0.2,0.2,0.2);
		TopSurface = 'Smooth';
		BottomSurface = 'Smooth';
		--
		Create'SpecialMesh'{
			MeshType = 'FileMesh';
			MeshId = 'http://www.roblox.com/asset/?id=119780517';
			TextureId = 'http://www.roblox.com/asset/?id=119779068';
		};
		--
		Create'Sound'{
			Name = 'Deploy';
			SoundId = 'http://www.roblox.com/asset/?id=119877640';
		};
	}
	local weld = Create'Weld'{
		Parent = Torso;
		Part0 = Torso;
		Part1 = Glider;
		C0 =  CFrame.Angles(0.2, 0, 0)*CFrame.new(0, 5.2, -0.1);
	}
end


local function StopFlying()
	Humanoid.PlatformStand = false
	Glider:Destroy()
	FlyAnimSource:Destroy()
	FlyAnim:Stop()
	FlyingGyro:Destroy()
	FlyingVelo:Destroy()
	script:Destroy()
end


local function OnPartTouched(other)
	if other.Name == 'Handle' then return end
	if not other:IsDescendantOf(Character) then
		StopFlying()
	end
end


local function RecursiveConnectTouched(obj)
	for _, ch in pairs(obj:GetChildren()) do
		if ch:IsA('BasePart') then
			ch.Touched:connect(OnPartTouched)
		else
			RecursiveConnectTouched(ch)
		end
	end
end


------------------------------------------------------------------
--|                    Flight Controlls                        |--
------------------------------------------------------------------
local CurrentFlightHeading;

local function SetupCharacterForFlight()
	Humanoid.PlatformStand = true
	--
	local torsoCF = Torso.CFrame
	local dir = Vector3.new(torsoCF.lookVector.x, 0, torsoCF.lookVector.z)
	CurrentFlightHeading = dir.unit
	--
	FlyingVelo = Create'BodyVelocity'{
		Name = 'GliderFlyingVelo';
		Parent = Torso;
		velocity = Vector3.new();
		maxForce = Vector3.new(10000,10000,10000);
	}
	FlyingGyro = Create'BodyGyro'{
		Name = 'GliderFlyingGyro';
		Parent = Torso;
		cframe = CFrame.new(Vector3.new(), CurrentFlightHeading);
		maxTorque = Vector3.new(10000,10000,10000);
	}
end


local function Slerp(t, a, b)
	local om = math.acos(math.min(1, a:Dot(b)))
	if om < 0.01 then
		return (1-t)*a +
		          t *b
	else
		return (math.sin((1-t)*om)/math.sin(om))*a +
		       (math.sin(   t *om)/math.sin(om))*b
	end
end


local TURN_ALPHA = math.pi * 0.8 -- per second
local MAX_SPEED = 40
local DESCENT_SPEED = 15

local function DoFlight(dt)
	local camCF = Workspace.CurrentCamera.CoordinateFrame
	local desiredHeading = (camCF * CFrame.Angles(0.2, 0, 0)).lookVector
	--
	-- HAXX :Dot in this case shouldn't be > 1, but it sometimes is ~1.000001 
	-- due to FP error, killing the arccos and nuking the character.
	local thetaBetween = math.acos(math.min(1, desiredHeading:Dot(CurrentFlightHeading)))
	local allowedTheta = TURN_ALPHA * dt
	if thetaBetween < allowedTheta then
		CurrentFlightHeading = desiredHeading
	else
		local frac = allowedTheta / thetaBetween
		CurrentFlightHeading = Slerp(frac, CurrentFlightHeading, desiredHeading)
	end
	if CurrentFlightHeading ~= CurrentFlightHeading then
		StopFlying()
	end
	--
	local speedMod = (-CurrentFlightHeading.y + 1) / 2 -- 1 when going straight down
	local liftMod = math.min(0, CurrentFlightHeading.y)
	--
	local dirXZ = Vector3.new(CurrentFlightHeading.x, 0, CurrentFlightHeading.z).unit
	--
	local tilt = math.min(4, math.max(-4, Torso.RotVelocity.y))
	--
	FlyingVelo.velocity = dirXZ*speedMod*MAX_SPEED + Vector3.new(0, liftMod, 0)*DESCENT_SPEED
	FlyingGyro.cframe = CFrame.new(Vector3.new(), CurrentFlightHeading) * CFrame.Angles(0, 0, tilt/8)
end


------------------------------------------------------------------
--|                        Call setup                          |--
------------------------------------------------------------------
CreateGlider()
SetupCharacterForFlight()
RecursiveConnectTouched(Character)
Glider.Deploy:Play()
FlyAnim:Play(0.2)


------------------------------------------------------------------
--|                     Main Flight Loop                       |--
------------------------------------------------------------------
local LastTime = tick()
while true do
	local thisTime = tick()
	local dt = thisTime-LastTime
	LastTime = thisTime
	--
	DoFlight(dt)
	--
	wait()
end