game.Debris:AddItem(script.Parent, 30)

----------------------------------------

local Grenade = script.Parent
local GrenadeScript = Grenade:WaitForChild("GrenadeScript")
local Creator = GrenadeScript:WaitForChild("creator").Value
local ExplodeSound = Grenade:WaitForChild("ExplodeSound")
local Character = Creator.Character

---------------------------------------

local Handling = false
Grenade.Touched:connect(function(part)
	--ignore collisions with firer's stuff
	if Character and part:IsDescendantOf(Character) then return end
	if Handling then return end
	Handling = true

	--wait a second, this is a grenade so it won't explode on contact
	wait(0.1)

	--end grenade
	Grenade.Anchored = true
	Grenade.CanCollide = false
	Grenade.Transparency = 1

	--play soud
	ExplodeSound:Play()

	--do explode
	local BlastPart = Instance.new('Part', game.Workspace)
	BlastPart.FormFactor = 'Custom'
	BlastPart.Size = Vector3.new(1,1,1)
	BlastPart.Transparency = 0.3
	BlastPart.Anchored = true
	BlastPart.CanCollide = false
	BlastPart.CFrame = CFrame.new(Grenade.Position)*CFrame.Angles(-math.pi/2,0,0)
	local BlastCFrame = CFrame.new(Grenade.Position)*CFrame.Angles(-math.pi/2,0,0)
	local BlastMesh = Instance.new('SpecialMesh', BlastPart)
	BlastMesh.MeshId = 'http://www.roblox.com/asset/?id=1080954'
	BlastMesh.TextureId = 'http://www.roblox.com/asset/?id=37856148'
	game.Debris:AddItem(BlastPart, 10)

	delay(7*0.03, function()
		local Explosion = Instance.new('Explosion')
		Explosion.BlastPressure = 0
		Explosion.BlastRadius = 12
		Explosion.Position = Grenade.Position
		--
		local HitHumanoidMap = {}
		Explosion.Hit:connect(function(part, rad)
			if Character and part:IsDescendantOf(Character) then return end
			local hum = (part.Parent or game):FindFirstChild('Humanoid')
			if hum and hum.Parent:FindFirstChild('HumanoidRootPart') and not HitHumanoidMap[hum] then 
				HitHumanoidMap[hum] = true
				hum.Sit = true
				local tag = GrenadeScript.creator:Clone()
				tag.Parent = hum
				game.Debris:AddItem(tag, 2)
				hum:TakeDamage(20)
				local twist = Instance.new('BodyAngularVelocity', hum.Parent.HumanoidRootPart)
				twist.angularvelocity = Vector3.new(10,10,10)
				local throw = Instance.new('BodyVelocity', hum.Parent.HumanoidRootPart)
				throw.maxForce = Vector3.new(10000,10000,10000)
				throw.velocity = (hum.Parent.HumanoidRootPart.Position - Grenade.Position).unit * 40
				wait(0.5)
				twist:Destroy()
				throw:Destroy()
				hum.Sit = false
			end
		end)
		--
		Explosion.Parent = game.Workspace
	end)
	for i = 0, 1, 0.2 do
		wait()
		BlastPart.CFrame = CFrame.new(0, math.sqrt(i)*10,0)*BlastCFrame
		BlastMesh.Scale = Vector3.new(4 + 4*i, 4 + 4*i, 4 + math.sqrt(i)*24)
	end
	for i = 0, 1, 0.1 do
		wait()
		BlastPart.CFrame = CFrame.new(0,10 - i*i*4,0)*BlastCFrame
		BlastMesh.Scale = Vector3.new(8 + i*2, 8 + i*2, 28 - i*i*8)
		BlastPart.Transparency = 0.3 + 0.7*i*i
	end
	BlastPart:Destroy()

	wait(0.5)

	--and finally get rid of us
	Grenade:Destroy()
end)

