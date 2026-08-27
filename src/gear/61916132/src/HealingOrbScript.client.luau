local Tool = script.Parent
local Orb = Tool.Handle

local vCharacter
local myTorso
local myHumanoid

Tool.Enabled = true

local healAmount = 25

local infuseAnim

local dropOrb
local numberOfOrbs

local greenFire

function spray(key)
	if key:lower() == "q" and Tool.Enabled then 	
		dropOrb = Tool:FindFirstChild("DropOrb")
		numberOfOrbs = Tool:FindFirstChild("NumberOfOrbs")
		if numberOfOrbs and numberOfOrbs.Value > 0 then
			if dropOrb and dropOrb.Value == 0 then 
				dropOrb.Value = 1 
				numberOfOrbs.Value = numberOfOrbs.Value - 1
			end			
		end
	end
end

function onActivated()
	if Tool.Enabled == false then 
		return
	end

	vCharacter = Tool.Parent
	myTorso = vCharacter:FindFirstChild("Torso")
	myHumanoid = vCharacter:FindFirstChild("Humanoid")

	if myTorso == nil or myHumanoid == nil then 
		return 
	end

	Tool.Enabled = false

	infuseAnim = myHumanoid:LoadAnimation(Tool.InfuseAnim)
	if infuseAnim then infuseAnim:Play() end

	wait(0.5)

	Orb.Transparency = 1.0

	if myHumanoid.Health + healAmount < myHumanoid.MaxHealth then 
		myHumanoid.Health = myHumanoid.Health + healAmount 
	else 
		myHumanoid.Health = myHumanoid.MaxHealth
	end

	greenFire = Instance.new("Fire")
	greenFire.Color = Color3.new(0.1, 0.9, 0.1)
	greenFire.SecondaryColor = Color3.new(0.2, 0.8, 0.2)
	greenFire.Size = 3.0
	greenFire.Heat = 1.0
	greenFire.Parent = myTorso

	myHumanoid.WalkSpeed = 26.0	
	wait(5.0)
	myHumanoid.WalkSpeed = 16.0
	wait(1.0)
	Orb.Transparency = 0.0
	Tool.Enabled = true
end

function onEquipped(mouse)
	vCharacter = Tool.Parent
	myTorso = vCharacter:FindFirstChild("Torso")
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	if mouse then 
		mouse.KeyDown:connect(spray)
	end
end

function onUnequipped()
	if infuseAnim then infuseAnim:Stop() end
	if myHumanoid then 
		myHumanoid.WalkSpeed = 16.0
	end

	if greenFire then greenFire:Remove() end
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)


