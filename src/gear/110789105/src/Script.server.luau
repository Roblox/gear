function FindAttachedHumanoid(part)
	local tpart = part
	while tpart.Parent do
		if tpart.Parent:FindFirstChild('Humanoid') then return tpart.Parent.Humanoid end
		tpart = tpart.Parent
	end
	return nil
end

function MakeValue(class,name,value,parent)
	local temp = Instance.new(class)
	temp.Name = name
	temp.Value = value
	temp.Parent = parent
	return temp
end	

local Tool = script.Parent
local Handle = Tool:WaitForChild('Handle')
local YellSound = Handle:WaitForChild('Sound')
local AniScript = Tool:WaitForChild('AnimationPlayerScript')
--http://www.roblox.com/Asset?ID=111898513'--http://www.roblox.com/Asset?ID=111880514'
local ThrowAnimation = 'http://www.roblox.com/Asset?ID=111898867'

local ThrowFace = 'http://www.roblox.com/asset?id=111882478'

local ThrowTable= Instance.new('Part')
do
	--ThrowTable.Shape = 'Ball'
	ThrowTable.FormFactor='Custom'
	ThrowTable.Size = Vector3.new(4.8, 2.43, 3.63)
	ThrowTable.CanCollide = true
	local tmesh = Instance.new('SpecialMesh')
	tmesh.MeshId = 'http://www.roblox.com/asset/?id=111868131'
	tmesh.TextureId = 'http://www.roblox.com/asset/?id=111867655'
	tmesh.Parent = ThrowTable
end

local LookGyro= Instance.new('BodyGyro')
LookGyro.maxTorque = Vector3.new(0,math.huge,0) 

local ActivateLock=false

Tool.Activated:connect(function()
	if ActivateLock then return end
	ActivateLock = true
	local character = Tool.Parent
	local humanoid = character:WaitForChild('Humanoid')
	local torso = character:WaitForChild('Torso')
	local head = character:WaitForChild('Head')
	local face = head:FindFirstChild('face')
	local oldFace =''
	if face then oldFace = face.Texture end
	humanoid.WalkSpeed = 0
	LookGyro.cframe = torso.CFrame - torso.CFrame.p
	LookGyro.Parent = torso
	
	local ntable =  ThrowTable:Clone()
	ntable.CFrame = torso.CFrame+(torso.CFrame.lookVector*3)
	ntable.Parent = Workspace	
	
	MakeValue('StringValue','aniId',ThrowAnimation,AniScript)	
	wait(.5)
	YellSound:play()
	wait(.5)	
	if face then	
		face.Texture=ThrowFace
	end
	
	
	
	local bAVel = Instance.new('BodyAngularVelocity')
	bAVel.maxTorque = Vector3.new(math.huge,math.huge,math.huge)
	bAVel.angularvelocity = ((torso.CFrame*CFrame.Angles(0,math.pi/2,0)).lookVector*10)
	bAVel.Parent = ntable
	
	local bVel = Instance.new('BodyVelocity')
	bVel.maxForce = Vector3.new(math.huge,0,math.huge)
	bVel.velocity = (torso.CFrame.lookVector*25)
	bVel.Parent = ntable

	ntable.Touched:connect(function(part)
		--print('GotTouched:' .. part.Name)
		Spawn(function()
			if part.Name == 'Terrain' then return end
			if part.Anchored then return end
			local hitHumanoid = FindAttachedHumanoid(part)
			if hitHumanoid then
				--print('HumanoidParent:'..hitHumanoid.Parent.Name)
				if hitHumanoid==humanoid then return end
				hitHumanoid.PlatformStand =true 
			end
			if part.Size.x*part.Size.y*part.Size.z<=5*9*5 then
				part.Velocity = (Vector3.new((math.random()-.5)*2,math.random(),(math.random()-.5)*2).unit)*150
			end
			wait(3)
			print('got past wait')
			if hitHumanoid then
				print('unplatformstanding')
				hitHumanoid.PlatformStand=false 
				hitHumanoid.Jump = true 
			end
		end)
	end)

	wait(6)
	LookGyro.Parent = nil
	humanoid.WalkSpeed = 16
	if face then	
		face.Texture=oldFace
	end
	ntable.CanCollide = false
	game.Debris:AddItem(ntable,5)
	ActivateLock = false
end)