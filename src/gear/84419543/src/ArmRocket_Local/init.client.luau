local Tool = script.Parent --Fix implemented by Luckymaxer
while not Tool:FindFirstChild('Handle') do Tool.ChildAdded:wait() end
local Handle = Tool.Handle
local Equipped = false
local Player;
local RightShoulder;
local RightArm;
local RightWeld;
local Torso;
local Mouse;

local function Slerp(t, a, b)
	local om = math.acos(a:Dot(b))
	return (math.sin((1-t)*om)/math.sin(om))*a + 
	       (math.sin(t*om)/math.sin(om))*b
end

local function GetFireCFrame()
	local from = (Torso.CFrame*CFrame.new(1.5, 0.5, 0)).p
	local fireDir = (Mouse.Hit.p-from).unit
	local torsoDir = Torso.CFrame.lookVector
	--
	local theta = math.acos(torsoDir:Dot(fireDir))
	if theta > math.pi/2 then
		fireDir = Slerp((math.pi/2)/theta, torsoDir, fireDir)
	end
	return CFrame.new(from, from+fireDir)
end

Tool.Equipped:connect(function(mouse)
	Mouse = mouse
	Equipped = true
	--
	Player = game.Players:GetPlayerFromCharacter(Tool.Parent)
	Torso = Player.Character:FindFirstChild('Torso')
	if not Torso then return end
	RightArm = Player.Character:FindFirstChild('Right Arm')
	if not RightArm then return end
	RightShoulder = Torso:FindFirstChild('Right Shoulder')
	if not RightShoulder then return end
	--
	local LastFireTime = 0
	mouse.Button1Down:connect(function()
		if tick()-LastFireTime < 1.4 then return end
		LastFireTime = tick()
		--
		Handle.FireSound:Play()
		--
		local fireHeading = GetFireCFrame()
		local Rocket = Instance.new('Part')
		Rocket.FormFactor = 'Custom'
		Rocket.Size = Vector3.new(0.5,2,0.5)
		Rocket.CanCollide = false
		local Mesh = Instance.new('SpecialMesh', Rocket)
		Mesh.MeshId = 'http://www.roblox.com/asset/?id=31601976'
		Mesh.TextureId = 'http://www.roblox.com/asset/?id=31601599'
		local ExplodeSound = Instance.new('Sound', Rocket)
		ExplodeSound.Name = 'ExplodeSound'
		ExplodeSound.SoundId = 'http://www.roblox.com/asset/?id=81116747'
		local SwooshSound = Instance.new('Sound', Rocket)
		SwooshSound.Name = 'SwooshSound'
		SwooshSound.SoundId = 'rbxasset://sounds/Rocket whoosh 01.wav'
		local Go = Instance.new('BodyVelocity', Rocket)
		Go.maxForce = Vector3.new(100000,100000,100000)
		Go.velocity = fireHeading.lookVector*120
		--
		Rocket.CFrame = fireHeading*CFrame.new(0,0,-2)*CFrame.Angles(math.pi/2,0,0)
		--
		local sc = script.RocketScript:Clone()
		sc.creator.Value = Player
		sc.Parent = Rocket
		sc.Disabled = false
		--
		Rocket.Parent = game.Workspace
		--
		Handle.Transparency = 1
		RightArm.Transparency = 1
		for i = 1,15 do
			wait()
			local trans = 1-i/15 
			Handle.Transparency = trans
			RightArm.Transparency = trans
		end
		Handle.Transparency = 0
		RightArm.Transparency = 0
	end)
	--
	RightShoulder.Part1 = nil
	RightWeld = Instance.new('Motor', Torso)
	RightWeld.Part0 = Torso
	RightWeld.Part1 = RightArm
	--
	while Equipped do
		local timeSinceLastFire = (tick()-LastFireTime)
		local DesiredArmCF;
		if timeSinceLastFire > 1.4 then
			local fire = GetFireCFrame()
			DesiredArmCF = fire*CFrame.Angles(math.pi/2,0,0)*CFrame.new(0,-0.5,0)
		elseif timeSinceLastFire > 1.0 then
			local frac = (timeSinceLastFire-1.0)/0.4
			local from = (Torso.CFrame*CFrame.new(1.5, 0.5, 0)).p
			local to = (Torso.CFrame*
			            CFrame.new(1.5, 0.5, 0)*
			            CFrame.Angles(0, math.pi/2*frac, 0)*
			            CFrame.new(1.5, 0, 0)).p
			local dirCur = (to-from).unit
			local dirWant = GetFireCFrame().lookVector
			local dir = Slerp(frac, dirCur, dirWant)
			DesiredArmCF = CFrame.new(from, from+dir)*CFrame.Angles(math.pi/2,0,0)*CFrame.new(0,-0.5,0)				
		else
			local frac = timeSinceLastFire/1.0
			local from = (Torso.CFrame*CFrame.new(1.5*frac, 0.5, 0)).p
			local to = (Torso.CFrame*CFrame.new(3, 0, 0)).p
			DesiredArmCF = CFrame.new(from, to)*CFrame.Angles(math.pi/2,0,0)*CFrame.new(0,-0.5,0)			
		end
		local newC1 = DesiredArmCF:inverse()*Torso.CFrame*CFrame.Angles(0,0,math.pi/2)
		RightWeld.C0 = CFrame.new()
		RightWeld.C1 = newC1
		--
		wait()
	end
end)

Tool.Unequipped:connect(function(mouse)
	Equipped = false
	if RightShoulder then
		RightWeld:Destroy()
		RightWeld = nil
		RightShoulder.Part1 = RightArm
		RightShoulder = nil
	end
end)