----------- Marionette --------------
-- Waits for the child of the specified parent
function WaitForChild(parent, childName)
	while not parent:FindFirstChild(childName) do parent.ChildAdded:wait() end
	return parent[childName]
end

local Tool = script.Parent
local Handle = WaitForChild(Tool, 'Handle')

local PlayersService = Game:GetService('Players')
local DebrisService = Game:GetService('Debris')
local ContentService = Game:GetService("ContentProvider")

local Marionette
local MarionetteWeld

local MarionetteGui


----- Sounds ------
--[[
local ShutDown = WaitForChild(Tool, 'ShutDown')
local PoweringUp = WaitForChild(Tool, 'PoweringUp')
local Deflect = WaitForChild(Tool, 'Deflect')
local Pulse = WaitForChild(Tool, 'Pulse')
--]]

-- Local Character Variables ----
local MyCharacter
local MyHumanoid
local MyTorso
local MyPlayer
local MyMouse
---------------------------------

-- Todo: Make it follow welds
function calculateMassRecursive(rootPart)
	local sum = 0
	if rootPart:IsA('Part') or rootPart:IsA('WedgePart') or rootPart:IsA('CornerWedgePart') or rootPart:IsA('TrussPart') then sum = sum + rootPart:GetMass() end
	for _, v in pairs(rootPart:GetChildren()) do
		sum = sum + calculateMassRecursive(v)
	end
	return sum
end

local function  IgnoreCloneCheck( objectToClone )
	if objectToClone:IsA('Script') or objectToClone:IsA('LocalScript') or not objectToClone.Archivable then
		return true
	end
	return false
end

local function AppearanceItem(item)
	if item:IsA('Shirt') or item:IsA('Pants') or item:IsA('SpecialMesh') or item:IsA('Hat') or item:IsA('Decal') or item:IsA('Face') or item:IsA('BodyColors') or item:IsA('CharacterMesh') then
		return true
	end
	return false
end

local function CopyCharacterAppearanceRecursive(newParent, oldParent)
	if #oldParent:GetChildren() == 0 then
		return nil
	end
	for k, v in pairs(oldParent:GetChildren()) do
		if AppearanceItem(v) then
			if newParent:FindFirstChild(v.Name) then
				CopyCharacterAppearanceRecursive(currClone, v)
			end
		end
	end
end

-- For now lets assume this function works
local function CopyCharacterAppearance(character, mari)
	if not mari then return end
	mari.Name = character.Name .. "'s Marionette"
	--CopyCharacterAppearanceRecursive(Marionette, character)
	for k, v in pairs(character:GetChildren()) do
		print("checking " .. v.Name)
		if AppearanceItem(v) and v.Archivable then
			print(v.Name .. " is an AppearanceItem")
			local currClone = v:Clone()
			currClone.Parent = mari
			print("Copying " .. v.Name)
		end
		for kk, vv in pairs(v:GetChildren()) do
			if AppearanceItem(vv) and vv.Archivable then
				local nextClone = vv:Clone()
				nextClone.Parent = mari:FindFirstChild(v.Name)
			end
		end
	end
end

local function AnimateMarionette(pickedTarget)
	print("Animating Marionette")
	if Marionette and Marionette:FindFirstChild('Right Arm') and pickedTarget == Marionette:FindFirstChild('Right Arm')  then
		AnimateRightArm()
	end
end

local animating = false

function SlashRightArm()
	if animating then return end
	animating = true
	print("Right Arm Clicked")
	if Marionette and Marionette:FindFirstChild('LinkedPlayer') and Marionette:FindFirstChild('LinkedPlayer').Value then
		local scriptToCopy = WaitForChild(Tool, 'AnimateSlashScript'):Clone()
		local animationToCopy = WaitForChild(Tool, "SlashAnim"):Clone()
		animationToCopy.Parent = scriptToCopy
		scriptToCopy.Parent = Marionette:FindFirstChild('LinkedPlayer').Value
		scriptToCopy.Disabled = false

		scriptToCopy = scriptToCopy:Clone()
		animationToCopy = animationToCopy:Clone()
		animationToCopy.Parent = scriptToCopy
		scriptToCopy.Parent = Marionette
		scriptToCopy.Disabled = false
	end
	wait(1)
	animating = false
end

function AnimateRightArm()
	print("Right Arm Clicked")
	if animating then return end
	animating = true
	if Marionette and Marionette:FindFirstChild('LinkedPlayer') and Marionette:FindFirstChild('LinkedPlayer').Value then
		local scriptToCopy = WaitForChild(Tool, 'AnimateArmScript'):Clone()
		local animationToCopy = WaitForChild(Tool, "Recoil"):Clone()
		animationToCopy.Parent = scriptToCopy
		scriptToCopy.Parent = Marionette:FindFirstChild('LinkedPlayer').Value
		scriptToCopy.Disabled = false

		scriptToCopy = scriptToCopy:Clone()
		animationToCopy = animationToCopy:Clone()
		animationToCopy.Parent = scriptToCopy
		scriptToCopy.Parent = Marionette
		scriptToCopy.Disabled = false
	end
	wait(1)
	animating = false
end

local function CopyCharacterSimple(character)
	local newChar = Game:GetService("InsertService"):LoadAsset(88117081):GetChildren()[1]
	for k, parts in pairs(newChar:GetChildren()) do
		for j, child in pairs(parts:GetChildren()) do
			if child:IsA('SpecialMesh') or child:IsA('Sound') then child:Destroy() end
		end
	end
	newChar.Humanoid.Health = newChar.Humanoid.MaxHealth
	CopyCharacterAppearance(character, newChar)
	return newChar
end

local function FindCharacterAtMouse()
	if MyMouse then
		local target = MyMouse.Target
		if target and target.Parent then
			if PlayersService:GetPlayerFromCharacter(target.Parent) then
				return target.Parent
			end 
		end
	end
	return nil
end

local function DestroyMarionette()
	if Marionette then
		Marionette:Destroy()
		MarionetteWeld:Destroy()
		Marionette = nil
		MarionetteWeld = nil
	end
end 

local function AddFloatingForce(object, mass)
	local floatingForce = Instance.new('BodyForce')
	floatingForce.force = Vector3.new(0, 196.2 * mass, 0)
	floatingForce.Parent = object
	return floatingForce
end

local function ActivatePlayerControls()
	if MarionetteGui then
		local marionetteFrame = MarionetteGui:FindFirstChild('Frame')
		if marionetteFrame then
			marionetteFrame.Instructions.Visible = false
			marionetteFrame.SpinArms.Visible = true
			marionetteFrame.SpinArms.Active = true
			marionetteFrame.Slash.Visible = true
			marionetteFrame.Slash.Active = true
		end
	end
end

local function OnActivate()
	--TODO: Debounce check this stuff yo~
	print("Activated")
	local pickedTarget = FindCharacterAtMouse()
	if pickedTarget then
		print("picked")

		DestroyMarionette()
		Marionette = CopyCharacterSimple(pickedTarget)
		local otherChar = Instance.new('ObjectValue')
		otherChar.Value = pickedTarget
		otherChar.Name = "LinkedPlayer"
		otherChar.Parent = Marionette
		if Marionette then
			for k, v in pairs(Marionette:GetChildren()) do
				if v:IsA('Part') then
					AddFloatingForce(v, v:GetMass())
				end
			end
			Marionette.Humanoid.PlatformStand = true
			ActivatePlayerControls()
			--clonedCopy:MoveTo(Handle.CFrame.p + Handle.CFrame.lookVector)
			MarionetteWeld = Instance.new('Weld')
			MarionetteWeld.Part0 = Marionette.Torso
			MarionetteWeld.Part1 = Handle
			MarionetteWeld.C0 = CFrame.new(0, 1.3, 0.4)
			MarionetteWeld.Parent = Handle
			Marionette.Parent = Tool
			local mass = calculateMassRecursive(Marionette)
		end
	end
end

local function AddGui()
	local theGui = Tool:FindFirstChild('MarionetteGui')
	MarionetteGui = theGui:Clone()
	MarionetteGui.Parent = MyPlayer.PlayerGui
	local marionetteFrame = MarionetteGui.Frame
	-- Add more buttons here
	marionetteFrame.SpinArms.Visible = false
	marionetteFrame.SpinArms.Active = false
	marionetteFrame.SpinArms.MouseButton1Click:connect(AnimateRightArm)
	marionetteFrame.Slash.Visible = false
	marionetteFrame.Slash.Active = false
	marionetteFrame.Slash.MouseButton1Click:connect(SlashRightArm)
end

local function OnEquip(mouse)
	MyCharacter = Tool.Parent
	print(MyCharacter.Name)
	MyHumanoid = WaitForChild(MyCharacter, 'Humanoid')
	MyTorso = WaitForChild(MyCharacter, 'Torso')
	if mouse then
		MyMouse = mouse
	end
	MyPlayer = PlayersService:GetPlayerFromCharacter(MyCharacter)
	AddGui()
end

local function OnUnequip()
	-- Get rid of this stuff when you unequip otherwise will do painful things when requipped
	DestroyMarionette()
	if MarionetteGui then
		MarionetteGui:Destroy()
		MarionetteGui = nil
	end
end

Tool.Equipped:connect(OnEquip)
Tool.Unequipped:connect(OnUnequip)
Tool.Activated:connect(OnActivate)
