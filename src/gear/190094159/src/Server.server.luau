--Updated for R15 avatars by StarWars
local Tool = script.Parent
local Handle = Tool:WaitForChild("Handle")
local Remote = Tool:WaitForChild("Remote")
local ProjectileScript = Tool:WaitForChild("ProjectileScript")
local HB = game:GetService("RunService").Heartbeat

local AttackAble = true
local AttackReloadTime = 5

function createRocket()
	local rocket = Instance.new("Part")
	rocket.CanCollide = false
	rocket.FormFactor = "Custom"
	rocket.Size = Vector3.new(0.5, 0.5, 1)
	rocket.TopSurface = "Smooth"
	rocket.BottomSurface = "Smooth"
	
	local mesh = Instance.new("SpecialMesh")
	mesh.MeshType = "FileMesh"
	mesh.MeshId = "http://www.roblox.com/asset/?id=189741947"
	mesh.TextureId = "http://www.roblox.com/asset/?id=189741994"
	mesh.Parent = rocket
	
	local bv = Instance.new("BodyVelocity")
	bv.Parent = rocket
	
	local fire = Instance.new("Fire")
	fire.Size = 1
	fire.Heat = 0
	fire.Parent = rocket
	
	local ps = ProjectileScript:Clone()
	ps.Disabled = false
	ps.Parent = rocket
	
	local explodeSound = Instance.new("Sound")
	explodeSound.Name = "ExplodeSound"
	explodeSound.Pitch = math.random(90, 110)/100
	explodeSound.Volume = 0.75
	explodeSound.SoundId = "http://www.roblox.com/asset/?id=83594590"
	explodeSound.Parent = rocket
	
	local thrustSound = Instance.new("Sound")
	thrustSound.Name = "ThrustSound"
	thrustSound.Pitch = math.random(90, 110)/100
	thrustSound.Looped = true
	thrustSound.SoundId = "http://www.roblox.com/asset/?id=12222095"
	thrustSound.Parent = rocket
	
	return rocket
end

function createFakeRocket()
	local fake = createRocket()
	for _, obj in pairs(fake:GetChildren()) do
		if not obj:IsA("SpecialMesh") then
			obj:Destroy()
		end
	end
	return fake
end

function destroyRocket(rocket)
	rocket.ProjectileScript.Disabled = true
	rocket.Anchored = true
	rocket.Transparency = 1
	rocket.Fire.Enabled = false
	rocket.ExplodeSound:Play()
	rocket.ThrustSound:Stop()
	game:GetService("Debris"):AddItem(rocket)
end

function getPlayer()
	return game:GetService("Players"):GetPlayerFromCharacter(Tool.Parent)
end

function lerp(a, b, t)
	return a + (b - a) * t
end

function launchRocket(targetPosition)
	Handle.LaunchSound.Pitch = math.random(90, 110)/100
	Handle.LaunchSound:Play()
	
	local rocket = createRocket()
	local bv = rocket.BodyVelocity
	
	rocket.CFrame = Handle.CFrame * CFrame.new(0, 0.3, -2)
	rocket.Velocity = rocket.CFrame.lookVector
	rocket.Parent = workspace
	rocket.ThrustSound:Play()
	
	local speed = 50
	local a = rocket.CFrame.lookVector * (speed / 2)
	local b = Vector3.new(0, speed, 0)
	local t = 0
	while t < 1 do
		bv.velocity = lerp(a, b, t)
		t = t + HB:wait()
	end
	wait(1)
	
	local ray = Ray.new(rocket.Position, targetPosition - rocket.Position)
	local part, pos = workspace:FindPartOnRay(ray)
	targetPosition = pos
	
	local diveSpeed = 150
	local vector = targetPosition - rocket.Position
	bv.velocity = vector.unit * diveSpeed
	wait(vector.magnitude / diveSpeed)
	
	Instance.new("Explosion", workspace).Position = rocket.Position
	destroyRocket(rocket)
end

function grabRocket()
	local char = Tool.Parent
	local larm = char:FindFirstChild("Left Arm") or char:FindFirstChild("LeftHand")
	if larm then
		local fake = createFakeRocket()
		fake.Parent = char
		local weld = Instance.new("Weld")
		weld.Part0 = larm
		weld.Part1 = fake
		weld.C0 = CFrame.new(-0.5, larm.Name == "LeftHand" and 0 or -1, 0) * CFrame.Angles(0, math.pi/2, 0)
		weld.Parent = weld.Part0
		return fake
	end
end

function reloadSequence()
	local humanoid = Tool.Parent:FindFirstChild("Humanoid")
	if humanoid and humanoid.RigType == Enum.HumanoidRigType.R15 then
		Remote:FireClient(getPlayer(), "PlayAnimation", "R15Reload")
	else
		Remote:FireClient(getPlayer(), "PlayAnimation", "Reload")
	end
	wait(0.25)
	local rocket = grabRocket()
	wait(0.25)
	Handle.ReloadSound.Pitch = math.random(90, 110)/100
	Handle.ReloadSound:Play()
	if rocket then
		rocket:Destroy()
	end
end

function activate(targetPosition)
	if not AttackAble then return end
	
	AttackAble = false
	delay(1, function()
		delay(AttackReloadTime, function()
			AttackAble = true
		end)
		for t = 0, AttackReloadTime - 1 do
			delay(t, reloadSequence)
		end
	end)
	
	local spread = 6
	delay(0, function()
		launchRocket(targetPosition)
	end)
	delay(1/5, function()
		launchRocket(targetPosition + Vector3.new(spread, 0, 0))
	end)
	delay(2/5, function()
		launchRocket(targetPosition + Vector3.new(0, 0, spread))
	end)
	delay(3/5, function()
		launchRocket(targetPosition + Vector3.new(-spread, 0, 0))
	end)
	delay(4/5, function()
		launchRocket(targetPosition + Vector3.new(0, 0, -spread))
	end)
end

function onRemote(player, func, ...)
	if player ~= getPlayer() then return end
	
	if func == "Activate" then
		activate(...)
	end
end

Remote.OnServerEvent:connect(onRemote)