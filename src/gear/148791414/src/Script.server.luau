--Made by Luckymaxer
--Updated for R15 avatar by StarWars

Pies = {
	{MeshId = 18417911, TextureId = 18417918, Name = "ApplePie", Scale = Vector3.new(0.35, 0.35, 0.35), Size = Vector3.new(1, 1, 0.25), Angle = CFrame.Angles(0, -(math.pi / 2), 0), Damage = 40},
	{MeshId = 40312463, TextureId = 40311968, Name = "CherryPie", Scale = Vector3.new(0.9, 0.9, 0.9), Size = Vector3.new(1, 1, 0.25), Angle = CFrame.Angles(-(math.pi / 1.5), (math.pi / 2), 0), Damage = 15},
	{MeshId = 40312463, TextureId = 40311869, Name = "BlueberryPie", Scale = Vector3.new(0.9, 0.9, 0.9), Size = Vector3.new(1, 1, 0.25), Angle = CFrame.Angles(-(math.pi / 1.5), (math.pi / 2), 0), Damage = 15},
	{MeshId = 143518445, TextureId = 143499030, Name = "CherryPie", Scale = Vector3.new(0.5, 0.35, 0.5), Size = Vector3.new(1, 0.25, 1), Angle = CFrame.Angles(0, 0, -(math.pi / 2)), Damage = 30},
	{MeshId = 65950268, TextureId = 65950352, Name = "PumpkinPie", Scale = Vector3.new(0.9, 0.9, 0.9), Size = Vector3.new(1, 1, 0.25), Angle = CFrame.Angles((math.pi / 2.5), (math.pi / 2), 0), Damage = 35},
	{MeshId = 18453224, TextureId = 18453205, Name = "PumpkinPi", Scale = Vector3.new(0.35, 0.35, 0.35), Size = Vector3.new(1, 1, 0.25), Angle = CFrame.Angles(0, -(math.pi / 2), 0), Damage = 20},
	{MeshId = 125732887, TextureId = 125728597, Name = "PizzaPie", Scale = Vector3.new(0.6, 0.6, 0.6), Size = Vector3.new(1, 0.25, 1), Angle = CFrame.Angles(-(math.pi / 20), 0, -(math.pi / 2)), Damage = 20}
}

BaseUrl = "http://www.roblox.com/asset?id="

function FindAttachedHumanoid(part)
	local tpart = part
	while tpart.Parent do
		if tpart.Parent:FindFirstChild("Humanoid") then return tpart.Parent.Humanoid end
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
local Handle = Tool:WaitForChild("Handle")
local YellSound = Handle:WaitForChild("Sound")
local AniScript = Tool:WaitForChild("AnimationPlayerScript")
--http://www.roblox.com/Asset?ID=111898513"--http://www.roblox.com/Asset?ID=111880514"
local ThrowAnimation = "http://www.roblox.com/Asset?ID=111898867"
local R15ThrowAnimation = "http://www.roblox.com/Asset?ID=538185627"

local ThrowFace = "http://www.roblox.com/asset?id=111882478"

local ThrowTable= Instance.new("Part")
do
	--ThrowTable.Shape = "Ball"
	ThrowTable = Handle:Clone()
	ThrowTable.FormFactor = Enum.FormFactor.Custom
	ThrowTable.Size = Vector3.new(4.125, 2.25, 4.125)
	ThrowTable.CanCollide = true
	ThrowTable.Mesh.Scale = Vector3.new(1, 1, 1)
end

local LookGyro = Instance.new("BodyGyro")
LookGyro.maxTorque = Vector3.new(0,math.huge,0) 

local ActivateLock=false

Tool.Activated:connect(function()
	if ActivateLock then return end
	ActivateLock = true
	local character = Tool.Parent
	local humanoid = character:WaitForChild("Humanoid")
	local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
	local head = character:WaitForChild("Head")
	local face = head:FindFirstChild("face")
	local oldFace =""
	if face then oldFace = face.Texture end
	humanoid.WalkSpeed = 0
	LookGyro.cframe = torso.CFrame - torso.CFrame.p
	LookGyro.Parent = torso

	local TorsoLookVector = torso.CFrame.lookVector
	
	local ntable =  ThrowTable:Clone()
	ntable.CFrame = torso.CFrame+(TorsoLookVector * 3)
	local TableClone = ntable:Clone()
	local TableCloneY = TableClone:Clone()
	TableCloneY.CFrame = TableCloneY.CFrame * CFrame.Angles(math.rad(90), 0, 0)		
	TableCloneY.CFrame = TableCloneY.CFrame + TableCloneY.CFrame.lookVector * ((TableCloneY.Size.y / 2))
	local TableCloneZ = TableCloneY:Clone()
	TableCloneZ.CFrame = TableCloneZ.CFrame

	ntable.Parent = Workspace	
	
	local PiesUsing = {}

	for i = 1, 3 do
		local TableCloneX = TableCloneZ:Clone()
		TableCloneX.CFrame = TableCloneZ.CFrame * CFrame.Angles(0, math.rad(90)--[[math.rad(((i == 1 and 90) or (i == 2 and -90) or 0))]], 0)
		local ChosenPie = Pies[math.random(1, #Pies)]
		local Pie = Instance.new("Part")
		Pie.Name = ChosenPie.Name
		Pie.FormFactor = Enum.FormFactor.Custom
		Pie.Size = ChosenPie.Size
		TableCloneX.CFrame = TableCloneX.CFrame - TableCloneX.CFrame.lookVector * (ntable.Size.x)
		TableCloneX.CFrame = TableCloneX.CFrame + TableCloneX.CFrame.lookVector * ((ntable.Size.x / 2) + (i * Pie.Size.x))
		Pie.TopSurface = Enum.SurfaceType.Smooth
		Pie.BottomSurface = Enum.SurfaceType.Smooth
		table.insert(PiesUsing, Pie)
		local Mesh = Instance.new("SpecialMesh")
		Mesh.MeshType = Enum.MeshType.FileMesh
		Mesh.MeshId = BaseUrl .. ChosenPie.MeshId
		Mesh.TextureId = BaseUrl .. ChosenPie.TextureId
		Mesh.Scale = ChosenPie.Scale
		Mesh.Parent = Pie
		Pie.Anchored = false
		game:GetService("Debris"):AddItem(Pie, 10)
		local HitDebounce = false
		Pie.Touched:connect(function(Hit)
			if Hit and Hit.Parent and Hit.Parent ~= character and not HitDebounce then
				local HitHumanoid = Hit.Parent:FindFirstChild("Humanoid")
				if HitHumanoid and HitHumanoid.Health > 0 then
					HitDebounce = true
					local creator = Instance.new("ObjectValue")
					creator.Value = game:GetService("Players"):GetPlayerFromCharacter(character)
					creator.Name = "creator"
					game:GetService("Debris"):AddItem(Pie, 3)
					creator.Parent = HitHumanoid
					HitHumanoid:TakeDamage(ChosenPie.Damage)
				end
			end
		end)
		Pie.Parent = Workspace
		Pie.CFrame = TableCloneX.CFrame * ChosenPie.Angle
		local Gyro = Instance.new("BodyGyro")
		Gyro.maxTorque = Vector3.new(400000, 400000, 400000)
		Gyro.cframe = Pie.CFrame
		Gyro.Parent = Pie
		local Position = Instance.new("BodyPosition")
		Position.position = Pie.Position
		Position.maxForce = Vector3.new(math.huge, 0, math.huge)
		Position.Parent = Pie
	end
	
	if humanoid then
		if humanoid.RigType == Enum.HumanoidRigType.R6 then
			MakeValue("StringValue","aniId",ThrowAnimation,AniScript)
		elseif humanoid.RigType == Enum.HumanoidRigType.R15 then
			MakeValue("StringValue","aniId",R15ThrowAnimation,AniScript)
		end
	end	
	wait(.5)
	YellSound:play()
	wait(.5)	
	if face then	
		face.Texture=ThrowFace
	end
	
	for i, v in pairs(PiesUsing) do
		if v and v.Parent then
			v.BodyPosition:Destroy()
			
			v.Velocity = TorsoLookVector * 100
			
			local Force = Instance.new("BodyForce")
			Force.force = Vector3.new(0, (v:GetMass() * 9.81 * 5), 0)
			Force.Parent = v
		
		end
	end
	
	local bAVel = Instance.new("BodyAngularVelocity")
	bAVel.maxTorque = Vector3.new(math.huge,math.huge,math.huge)
	bAVel.angularvelocity = ((torso.CFrame*CFrame.Angles(0,math.pi/2,0)).lookVector*10)
	bAVel.Parent = ntable
	
	local bVel = Instance.new("BodyVelocity")
	bVel.maxForce = Vector3.new(math.huge,0,math.huge)
	bVel.velocity = (torso.CFrame.lookVector*25)
	bVel.Parent = ntable

	ntable.Touched:connect(function(part)
		--print("GotTouched:" .. part.Name)
		Spawn(function()
			if part.Name == "Terrain" then return end
			if part.Anchored then return end
			local hitHumanoid = FindAttachedHumanoid(part)
			if hitHumanoid then
				--print("HumanoidParent:"..hitHumanoid.Parent.Name)
				if hitHumanoid==humanoid then return end
				hitHumanoid.PlatformStand =true 
			end
			if part.Size.x*part.Size.y*part.Size.z<=5*9*5 then
				part.Velocity = (Vector3.new((math.random()-.5)*2,math.random(),(math.random()-.5)*2).unit)*150
			end
			wait(3)
			--print("got past wait")
			if hitHumanoid then
				--print("unplatformstanding")
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