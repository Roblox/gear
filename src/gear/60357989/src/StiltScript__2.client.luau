local Tool = script.Parent
local Stilt = Tool.Handle

local vCharacter
local myTorso

local leftStiltWeld
local rightStiltWeld

local leftStilt
local rightStilt

local bambooMesh = Instance.new("SpecialMesh")
bambooMesh.MeshId = "http://www.roblox.com/asset/?id=60354828" --60354121" --60353110" --60288010"
bambooMesh.TextureId = "http://www.roblox.com/asset/?id=60257648"
bambooMesh.Scale = Vector3.new(0.75, 0.75, 0.75)

Tool.Enabled = true 

local stiltWalkAnim
local stiltActive

local animationScript


function onActivated()
	if Tool.Enabled == false then 
		return
	end

	stiltActive = Tool:FindFirstChild("StiltActive")
	if stiltActive and stiltActive.Value == 0 then
		stiltActive.Value = 1
		Tool.Enabled = false 

		vCharacter = Tool.Parent
		myTorso = vCharacter:FindFirstChild("Torso")
		myHumanoid = vCharacter:FindFirstChild("Humanoid")
		if myTorso == nil or myHumanoid == nil then 
			return 
		end	
		leftStiltWeld = myTorso:FindFirstChild("LeftStiltWeld")
		rightStiltWeld = myTorso:FindFirstChild("RightStiltWeld")
		leftStilt = vCharacter:FindFirstChild("LeftStilt")
		rightStilt = vCharacter:FindFirstChild("RightStilt")
		if not leftStilt and not rightStilt then
			rightStilt = Instance.new("Part")
			rightStilt.CanCollide = true
			rightStilt.Name = "LeftStilt"			
			rightStilt.FormFactor = 3
			rightStilt.Shape = "Block"
			rightStilt.Size = Vector3.new(0.4, 6, 0.4)
			rightStilt.Parent = vCharacter

			local rightStiltMesh = bambooMesh:Clone()
			rightStiltMesh.Parent = rightStilt

			rightStiltWeld = Instance.new("Weld")		
			rightStiltWeld.Name = "RightStiltWeld"
			rightStiltWeld.Part0 = myTorso
			rightStiltWeld.Part1 = rightStilt
			rightStiltWeld.C1 = CFrame.new(Vector3.new(-1, 2, 0))
			rightStiltWeld.Parent = myTorso

			leftStilt = Instance.new("Part")
			leftStilt.CanCollide = true 
			leftStilt.Name = "RightStilt"
			leftStilt.FormFactor = 3
			leftStilt.Shape = "Block"
			leftStilt.Size = Vector3.new(0.4, 6, 0.4)
			leftStilt.Parent = vCharacter

			local leftStiltMesh = bambooMesh:Clone()
			leftStiltMesh.MeshId = "http://www.roblox.com/asset/?id=60355643" --60353110" --60288863"
			leftStiltMesh.Parent = leftStilt

			leftStiltWeld = Instance.new("Weld")
			leftStiltWeld.Name = "LeftStiltWeld"
			leftStiltWeld.Part0 = myTorso
			leftStiltWeld.Part1 = leftStilt
			leftStiltWeld.C1 = CFrame.new(Vector3.new(1, 2, 0))
			leftStiltWeld.Parent = myTorso

			myHumanoid.Jump = true		
			
			print("Stilt Created")
		end 

		stiltWalkAnim = myHumanoid:LoadAnimation(Tool.StiltWalkAnim)
		if stiltWalkAnim then stiltWalkAnim:Play() end		
		
		Stilt.Transparency = 1.0	

		animateScript = Tool:FindFirstChild("StiltAnimateScript")
		if animateScript then 
			animateScript = animateScript:Clone()
			animateScript.Parent = vCharacter
			animateScript.Disabled = false
		end

		wait(2.0)
		Tool.Enabled = true
	end
end

function onEquipped()	
end

function onUnequipped()
	Stilt.Transparency = 0.0
	if leftStilt then leftStilt:Remove() leftStilt = nil end
	if rightStilt then rightStilt:Remove() rightStilt = nil end
	stiltActive = Tool:FindFirstChild("StiltActive")
	if stiltActive then stiltActive.Value = 0 end
	if stiltWalkAnim then stiltWalkAnim:Stop() end

	local checkScript = vCharacter:FindFirstChild("StiltAnimateScript")
	if checkScript then checkScript:Remove() end
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
