local Tool = script.Parent
local Egg = Tool.Handle

local debris = game:GetService("Debris")

local vCharacter

local blastSound

local eggClone
local co

Tool.Enabled = true

function explode(eggClone)	
	if eggClone then 
		if blastSound then blastSound:Play() end
		wait(3.0)

	   local sound = Instance.new("Sound") 
	   sound.SoundId = "rbxasset://sounds\\Rocket shot.wav" 
	   sound.Parent = script.Parent 
	   sound.Volume = 1 
	   sound:Play()

		e = Instance.new("Explosion")
		e.Position = eggClone.Position
		e.Name = "BOOM"
		e.BlastPressure = 500000
		e.BlastRadius = 12.5
		e.Parent = game.Workspace
		print("EXPLOSION")
		debris:addItem(e, 1.5)	

		egg1 = Egg:Clone()
		egg1.Parent = game.Workspace
		egg1.CanCollide = true
		egg1.Transparency = 0.0
		egg1.CFrame = eggClone.CFrame + Vector3.new(0.5, 0, 0)
		egg1.Mesh.TextureId = "http://www.roblox.com/asset/?id=50444489"
		egg1.Mesh.Scale = Vector3.new(0.75, 0.75, 0.75)

		newScript = Tool.DropScript:Clone()
		newScript.Parent = egg1
		newScript.Disabled = false

		boom = Tool.boomScript:Clone()
		boom.Parent = egg1
	
		spark = Instance.new("Sparkles") 
		spark.Name = "Fuse" 
		spark.Parent = egg1
	
		egg2 = Egg:Clone()
		egg2.Parent = game.Workspace
		egg2.CanCollide = true
		egg2.Transparency = 0.0
		egg2.CFrame = eggClone.CFrame + Vector3.new(0, 0, 0.5)
		egg2.Mesh.TextureId = "http://www.roblox.com/asset/?id=50444489"
		egg2.Mesh.Scale = Vector3.new(0.75, 0.75, 0.75)
		
		newScript2 = Tool.DropScript:Clone()
		newScript2.Parent = egg2
		newScript2.Disabled = false
		
		boom2 = Tool.boomScript:Clone()
		boom2.Parent = egg2
		
		spark2 = Instance.new("Sparkles") 
		spark2.Name = "Fuse" 
		spark2.Parent = egg2

		eggClone:Remove()	
	end
end

function onActivated()
	if Tool.Enabled == false then 
		return
	end
	Tool.Enabled = false

	vCharacter = Tool.Parent
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	if myHumanoid == nil then 
		return
	end

	eggClone = Egg:Clone()
	eggClone.CanCollide = true
	eggClone.Parent = game.Workspace
	Egg.Transparency = 1.0
	
	local spark = Instance.new("Sparkles") 
	spark.Name = "Fuse" 
	spark.Parent = eggClone
	
	FuseSound = Instance.new("Sound") 
	FuseSound.SoundId = "http://www.roblox.com/asset/?id=11565378" 
	FuseSound.Parent = Tool
	FuseSound.Volume = 1.0
	FuseSound:Play() 		

	explode(eggClone)
	
	wait(9.0)
	Egg.Transparency = 0.0
	Tool.Enabled = true
end

function onEquipped()
end

function onUnequipped()
	--Egg.Transparency = 0.0
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
