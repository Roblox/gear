local Tool = script.Parent
local Pumpkin = Tool.Handle

local debris = game:GetService("Debris")

local vCharacter

local blastSound

local pumpkinClone
local co

local fuseSound

Tool.Enabled = true

function explode(pumpkinClone)	
	local storeCF
	if pumpkinClone then 
		storeCF = pumpkinClone.CFrame
		if blastSound then blastSound:Play() end
		wait(3.0)

	   local sound = Instance.new("Sound") 
	   sound.SoundId = "rbxasset://sounds\\Rocket shot.wav" 
	   sound.Parent = script.Parent 
	   sound.Volume = 1 
	   sound:Play()

		e = Instance.new("Explosion")
		e.Position = pumpkinClone.Position
		e.Name = "BOOM"
		e.BlastPressure = 5000000
		e.BlastRadius = 15
		e.Parent = game.Workspace
		print("EXPLOSION")
		debris:addItem(e, 1.5)			

		tick()		

		wait(1)
		for i = 1, 9 do 
			tick()
			local eg = Pumpkin:Clone()
			eg.Parent = game.Workspace
			eg.CanCollide = true 
			eg.Size = eg.Size/4.0
			eg.Transparency = 0.0
			--eg.Anchored = true
			eg.CFrame = storeCF + Vector3.new(math.random(-10, 10)/5, 0, math.random(-10, 10)/5)
			eg.Mesh.MeshId = "http://www.roblox.com/asset/?id=62772375"
			eg.Mesh.TextureId = "http://www.roblox.com/asset/?id=62759799"
			eg.Mesh.Scale = Vector3.new(1.8, 1.8, 1.8)

			eg.Velocity = (eg.Position - storeCF.p).unit * 100.0
			
			local newScript = Tool.DropScript:Clone()
			newScript.Parent = eg
			newScript.Disabled = false

			local spark = Instance.new("Sparkles") 
			spark.Name = "Fuse" 
			spark.Parent = eg
			spark.Color = Color3.new(153/255, 102/255, 0)
		end

		if pumpkinClone then pumpkinClone:Remove() end
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

	pumpkinClone = Pumpkin:Clone()
	pumpkinClone.Transparency = 0.45 
	pumpkinClone.CanCollide = true
	pumpkinClone.Parent = game.Workspace
	Pumpkin.Transparency = 1.0
	
	local spark = Instance.new("Sparkles") 
	spark.Name = "Fuse" 
	spark.Parent = pumpkinClone
	spark.Color = Color3.new(153/255, 102/255, 0)

	if fuseSound == nil then	
		fuseSound = Instance.new("Sound")
		fuseSound.SoundId = "http://www.roblox.com/asset/?id=13378571"
		fuseSound.Parent = script.Parent	
	else 
		fuseSound:Play()		
	end

	explode(pumpkinClone)
	
	wait(7.0)
	Pumpkin.Transparency = 0.0
	Tool.Enabled = true
end

function onEquipped()
end

function onUnequipped()
	--Pumpkin.Transparency = 0.0
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
