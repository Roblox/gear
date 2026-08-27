local tool = script.Parent
local assets = require(277359293)
local colors = require(script.Colors)
local tween = require(script.PropertyInterpolator)

local equipped = false
local equippedCharacter = nil
local equippedPlayer = nil
local started = false

tool.Equipped:connect(function()
	equipped = true
	equippedCharacter = tool.Parent
	equippedPlayer = game.Players:GetPlayerFromCharacter(equippedCharacter)
end)

tool.Unequipped:connect(function()
	equipped = false
	equippedCharacter = nil
	equippedPlayer = nil
end)

function start(point)
	if started then return end
	started = true
	
	local character = equippedCharacter
	
	local humanoid = character.Humanoid
	local track = humanoid:LoadAnimation(tool.GrenadeToss)
	track:Play(0)
	
	wait(0.5)
	local emitter = Instance.new'Part'
	emitter.Name = 'Emitter'
	emitter.CanCollide = false
	emitter.Transparency = 1
	emitter.FormFactor = 'Custom'
	emitter.Size = Vector3.new(1, 1, 1)*0.2
	emitter.Parent = tool.Handle
	local emitterWeld = Instance.new'Weld'
	emitterWeld.Part0 = tool.Handle
	emitterWeld.Part1 = emitter
	emitterWeld.Parent = emitter
	emitterWeld.C0 = CFrame.new(0, 0.5, 0)
	local fire = script.FireParticle:Clone()
	fire.Parent = emitter
	fire.Enabled = true
	local fuse = script.Fuse:Clone()
	fuse.Parent = tool.Handle
	fuse:Play()
	
	wait(1)
	local bomb = tool.Handle:Clone()
	bomb.Fuse:Destroy()
	fuse.Parent = bomb
	tool.Handle.Transparency = 1
	bomb.Name = 'DinoBomb'
	bomb.Parent = character
	bomb.CanCollide = true
	emitter:Destroy()
	local v = Instance.new'BodyVelocity'
	v.velocity = (point - character.HumanoidRootPart.Position).unit*50
	v.maxForce = v.maxForce*Vector3.new(1,0,1)
	v.Parent = bomb
	
	wait(1)
	local pos = bomb.Position
	local e = Instance.new'Explosion'
	e.Position = pos
	e.BlastPressure = 0
	e.DestroyJointRadiusPercent = 0
	e.ExplosionType = 'NoCraters'
	e.Parent = workspace
	bomb:Destroy()
	local floor, floorPos, floorNorm = workspace:FindPartOnRay(
		Ray.new(
			pos,
			Vector3.new(0, -100, 0)
		)
	)
	local outerRing = Instance.new'Part'
	outerRing.BrickColor = BrickColor.new'Really red'
	outerRing.Material = 'Neon'
	outerRing.CFrame = CFrame.new(floorPos)
	outerRing.Anchored = true
	outerRing.CanCollide = false
	outerRing.Locked = true
	outerRing.FormFactor = 'Custom'
	outerRing.Size = Vector3.new(1, 0.2, 1)
	local oc = Instance.new'CylinderMesh'
	oc.Parent = outerRing
	oc.Scale = Vector3.new(0, 1, 0)
	local innerRing = outerRing:Clone()
	innerRing.CFrame = outerRing.CFrame * CFrame.new(0, 0.2, 0)
	innerRing.BrickColor = BrickColor.new'Really black'
	outerRing.Parent = workspace
	innerRing.Parent = workspace
	local s = script.Explosion:Clone()
	s.Parent = innerRing
	s:Play()
	local t = 0.5
	tween(outerRing.Mesh, 'Scale', 'Vector3', nil, Vector3.new(15, 1, 15), t, 'Bounce')
	tween(innerRing.Mesh, 'Scale', 'Vector3', nil, Vector3.new(14, 1, 14), t, 'Bounce'):wait()
	
	for i=1, 14 do
		-- PLUSHIES!
		local size = math.random()*5+1
		local psize = size*1.2
		local new = assets.Dino:Clone()
		new.Material = 'Fabric'
		new.Name = 'DinoPlushie'
		new.CFrame = CFrame.new(pos + floorNorm*psize) * CFrame.Angles(math.random()*math.pi*2, math.random()*math.pi*2, math.random()*math.pi*2)
		new.Velocity = (floorNorm*3+Vector3.new(math.random()-0.5, math.random()-0.5, math.random()-0.5).unit).unit * (10*Vector3.new(psize,psize,psize).magnitude/2)
		new.Locked = true
		new.Size = Vector3.new(1,1,1)*psize
		new.TopSurface = 0
		new.BottomSurface = 0
		local mesh = Instance.new'FileMesh'
		mesh.MeshId = 'rbxassetid://273348860'
		mesh.TextureId = colors[math.random(1, #colors)]
		mesh.Scale = Vector3.new(1,1,1)*size
		mesh.VertexColor = Vector3.new(math.random()-.5, math.random()-.5, math.random()-.5).unit*0.2 + Vector3.new(1,1,1)
		mesh.Parent = new
		new.Parent = workspace
		local s = script.Pop:Clone()
		s.Parent = new
		s.Pitch = 0.75+math.random()*0.5
		s:Play()
		
		game.Debris:AddItem(new, 30)
		wait(0.1)
	end
	
	tween(outerRing.Mesh, 'Scale', 'Vector3', nil, Vector3.new(), t, 'RevBounce')
	tween(innerRing.Mesh, 'Scale', 'Vector3', nil, Vector3.new(), t, 'RevBounce'):wait()
	outerRing:Destroy()
	innerRing:Destroy()
	
	wait(30)
	tool.Handle.Transparency = 0
	started = false
end

tool.Input.OnServerEvent:connect(function(client, name, down, ...)
	if name == 'MB1' then
		if down then
			start(...)
		end
	end
end)