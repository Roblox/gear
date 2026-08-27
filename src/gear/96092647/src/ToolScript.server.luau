local SkeletonBirdDuration = 5*60

function WaitForChild(parent, child)
	local result = parent:FindFirstChild(child)
	delay(3, function() if not result then print("Probably Stuck", child) end end)
	while not result do
		parent.ChildAdded:wait()
		result = parent:FindFirstChild(child)
	end
	return result
end

function WaitForChildren(parent, childTable)
	for i = 1, #childTable do
		WaitForChild(parent, childTable[i])
	end
end

local Tool = script.Parent 
local SkeletonBird = Tool.Handle


local prevHealth = 100



local healthConnect

local vCharacter
local myTorso 
local myHumanoid 

local attacking 

Tool.Enabled = true 

local connection

local debris = game:GetService("Debris")


local leftWing = WaitForChild(SkeletonBird, "LeftWing")
local rightWing = WaitForChild(SkeletonBird, "RightWing") 
local leftWeld = WaitForChild(SkeletonBird, "LeftWingWeld")
local rightWeld = WaitForChild(SkeletonBird, "RightWingWeld") 
local HandleFire = WaitForChild(SkeletonBird,"Fire")
HandleFire.Enabled = true

local SkeletonBirdClone 

function getMassOfObject(obj)
	local children 
	local mass = 0
	if type(obj) == "userdata" then 		
		children = obj:GetChildren() 	 
	elseif type(obj) == "table" then 
		children = obj 
	end 
	if children then 
		for i = 1, #children do 
			if children[i]:IsA("BasePart") then 
				mass = mass + children[i]:GetMass()
			end 
			if #children[i]:GetChildren() > 1 then 
				mass = mass + getMassOfObject(children[i])
			end 
		end 
	end  	
	return mass
end 




function HideTool()
	local partTable = {SkeletonBird, rightWing, leftWing}
	for i, v in pairs(partTable) do
		v.Transparency = 1
		local fire = v:FindFirstChild("Fire")
		if fire then fire.Enabled = false end
	end
	SkeletonBird.CanCollide = false
end

function ShowTool()
	local partTable = {SkeletonBird, rightWing, leftWing}
	local partTable = {SkeletonBird, rightWing, leftWing}
	for i, v in pairs(partTable) do
		v.Transparency = 0
		local fire = v:FindFirstChild("Fire")
		if fire then fire.Enabled = true end
	end
	SkeletonBird.CanCollide = true
end


function TrySpawnSkeletonBird()
	local oldSkeletonBirdRef = Tool.Parent:FindFirstChild("SkeletonBirdRefObject")
	if oldSkeletonBirdRef then
		if oldSkeletonBirdRef.Value and oldSkeletonBirdRef.Value.Parent then
			return false
		else
			oldSkeletonBirdRef:Destroy()
		end
	else
		WaitForChildren(SkeletonBird, {"Fire", "Mesh", "SkeletonBirdScript", "OwnerRef", "TargetPoint", "LeftWing", "RightWing"})
		WaitForChildren(SkeletonBird.LeftWing, {"Fire", "Mesh"})
		WaitForChildren(SkeletonBird.RightWing, {"Fire", "Mesh"})
		ShowTool()
		if not (SkeletonBird and SkeletonBird:FindFirstChild("LeftWing") and SkeletonBird:FindFirstChild("RightWing")) then return false end
		SkeletonBirdClone = SkeletonBird:Clone()
		SkeletonBirdClone.Name = "Torso"
		local skeletonBirdModel = Instance.new("Model")
		skeletonBirdModel.Name = "SkeletonBird"
		SkeletonBirdClone.Parent = skeletonBirdModel
		SkeletonBirdClone.OwnerRef.Value = Tool.Parent
		local skeletonBirdRefObject = WaitForChild(Tool,"SkeletonBirdRefObject"):Clone()
		SkeletonBirdClone.SkeletonBirdScript.Disabled = false

		debris:AddItem(skeletonBirdRefObject, SkeletonBirdDuration)
		skeletonBirdRefObject.Value = skeletonBirdModel
		skeletonBirdRefObject.Parent = Tool.Parent

		debris:AddItem(skeletonBirdModel, SkeletonBirdDuration + 6)
		skeletonBirdModel.Parent = game.Workspace
		return true
	end
end

function onActivated()
	local humanoid = Tool.Parent:FindFirstChild("Humanoid")
	if not (humanoid and humanoid.Health > 0) then return end
	if TrySpawnSkeletonBird() then 
		HideTool()
		return
	end
	local oldSkeletonBirdRef = Tool.Parent:FindFirstChild("SkeletonBirdRefObject")
	if oldSkeletonBirdRef then
		local skeletonBirdModel = oldSkeletonBirdRef.Value
		if skeletonBirdModel and skeletonBirdModel.Parent then
			local curSkeletonBird = skeletonBirdModel:FindFirstChild("Torso")
			if not curSkeletonBird then return end
			local skeletonBirdTarget = curSkeletonBird:FindFirstChild("TargetPoint")
			if skeletonBirdTarget then 
				skeletonBirdTarget.Value = humanoid.TargetPoint
				return
			end
		end
	end
end 


local equipDebounce = false
function onEquipped()
	if equipDebounce then return end
	equipDebounce = true
	-- Horrendous is the name, for these checks
	if leftWeld then 
		leftWeld.Parent = SkeletonBird
	end 
	if rightWeld then 
		rightWeld.Parent = SkeletonBird 
	end 

	TrySpawnSkeletonBird()

	HideTool()

	vCharacter = Tool.Parent 
	myTorso = vCharacter:FindFirstChild("Torso")
	myHumanoid = vCharacter:FindFirstChild("Humanoid")	
	wait(.5)
	equipDebounce = false
end 

function onUnequipped()
	--ShowTool()
end 

Tool.Equipped:connect(onEquipped)
Tool.Activated:connect(onActivated)
Tool.Unequipped:connect(onUnequipped)

