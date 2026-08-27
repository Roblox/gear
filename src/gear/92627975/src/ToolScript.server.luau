local FalconDuration = 5*60

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
local Falcon = Tool.Handle


local prevHealth = 100



local healthConnect

local vCharacter
local myTorso
local myHumanoid

local attacking

Tool.Enabled = true

local connection

local debris = game:GetService("Debris")


local leftWing = WaitForChild(Falcon, "LeftWing")
local rightWing = WaitForChild(Falcon, "RightWing")
local leftWeld = WaitForChild(Falcon, "LeftWingWeld")
local rightWeld = WaitForChild(Falcon, "RightWingWeld")

local FalconClone

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
	local partTable = {Falcon, rightWing, leftWing}
	for i, v in pairs(partTable) do
		v.Transparency = 1
	end
	Falcon.CanCollide = false
end

function ShowTool()
	local partTable = {Falcon, rightWing, leftWing}
	local partTable = {Falcon, rightWing, leftWing}
	for i, v in pairs(partTable) do
		v.Transparency = 0
	end
	Falcon.CanCollide = true
end


function TrySpawnFalcon()
	local oldFalconRef = Tool.Parent:FindFirstChild("FalconRefObject")
	if oldFalconRef then
		if oldFalconRef.Value and oldFalconRef.Value.Parent then
			return false
		else
			oldFalconRef:Destroy()
		end
	else
		WaitForChildren(Falcon, {"Mesh", "FalconScript", "OwnerRef", "TargetPoint", "LeftWing", "RightWing"})
		WaitForChildren(Falcon.LeftWing, {"Mesh"})
		WaitForChildren(Falcon.RightWing, {"Mesh"})
		ShowTool()
		if not (Falcon and Falcon:FindFirstChild("LeftWing") and Falcon:FindFirstChild("RightWing")) then return false end
		FalconClone = Falcon:Clone()
		FalconClone.Name = "Torso"
		local falconModel = Instance.new("Model")
		falconModel.Name = "Falcon"
		FalconClone.Parent = falconModel
		FalconClone.OwnerRef.Value = Tool.Parent
		local falconRefObject = WaitForChild(Tool,"FalconRefObject"):Clone()
		FalconClone.FalconScript.Disabled = false

		debris:AddItem(falconRefObject, FalconDuration)
		falconRefObject.Value = falconModel
		falconRefObject.Parent = Tool.Parent

		debris:AddItem(falconModel, FalconDuration + 6)
		falconModel.Parent = game.Workspace
		return true
	end
end

function onActivated()
	local humanoid = Tool.Parent:FindFirstChild("Humanoid")
	if not (humanoid and humanoid.Health > 0) then return end
	if TrySpawnFalcon() then
		HideTool()
		return
	end
	local oldFalconRef = Tool.Parent:FindFirstChild("FalconRefObject")
	if oldFalconRef then
		local falconModel = oldFalconRef.Value
		if falconModel and falconModel.Parent then
			local curFalcon = falconModel:FindFirstChild("Torso")
			if not curFalcon then return end
			local falconTarget = curFalcon:FindFirstChild("TargetPoint")
			if falconTarget then
				falconTarget.Value = humanoid.TargetPoint
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
		leftWeld.Parent = Falcon
	end
	if rightWeld then
		rightWeld.Parent = Falcon
	end

	TrySpawnFalcon()

	HideTool()

	vCharacter = Tool.Parent
	myTorso = vCharacter:FindFirstChild("Torso") or vCharacter:FindFirstChild("UpperTorso")
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
