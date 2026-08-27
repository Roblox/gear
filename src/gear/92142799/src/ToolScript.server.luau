local PhoenixDuration = 5*60

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
local Phoenix = Tool.Handle


local prevHealth = 100



local healthConnect

local vCharacter
local myTorso 
local myHumanoid 

local attacking 

Tool.Enabled = true 

local connection

local debris = game:GetService("Debris")


local leftWing = WaitForChild(Phoenix, "LeftWing")
local rightWing = WaitForChild(Phoenix, "RightWing") 
local leftWeld = WaitForChild(Phoenix, "LeftWingWeld")
local rightWeld = WaitForChild(Phoenix, "RightWingWeld") 
local HandleFire = WaitForChild(Phoenix,"Fire")
HandleFire.Enabled = true

local PhoenixClone 

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
	local partTable = {Phoenix, rightWing, leftWing}
	for i, v in pairs(partTable) do
		v.Transparency = 1
		local fire = v:FindFirstChild("Fire")
		if fire then fire.Enabled = false end
	end
	Phoenix.CanCollide = false
end

function ShowTool()
	local partTable = {Phoenix, rightWing, leftWing}
	local partTable = {Phoenix, rightWing, leftWing}
	for i, v in pairs(partTable) do
		v.Transparency = 0
		local fire = v:FindFirstChild("Fire")
		if fire then fire.Enabled = true end
	end
	Phoenix.CanCollide = true
end


function TrySpawnPhoenix()
	local oldPhoenixRef = Tool.Parent:FindFirstChild("PhoenixRefObject")
	if oldPhoenixRef then
		if oldPhoenixRef.Value and oldPhoenixRef.Value.Parent then
			return false
		else
			oldPhoenixRef:Destroy()
		end
	else
		WaitForChildren(Phoenix, {"Fire", "Mesh", "PhoenixScript", "OwnerRef", "TargetPoint", "LeftWing", "RightWing"})
		WaitForChildren(Phoenix.LeftWing, {"Fire", "Mesh"})
		WaitForChildren(Phoenix.RightWing, {"Fire", "Mesh"})
		ShowTool()
		if not (Phoenix and Phoenix:FindFirstChild("LeftWing") and Phoenix:FindFirstChild("RightWing")) then return false end
		PhoenixClone = Phoenix:Clone()
		PhoenixClone.Name = "Torso"
		local phoenixModel = Instance.new("Model")
		phoenixModel.Name = "Phoenix"
		PhoenixClone.Parent = phoenixModel
		PhoenixClone.OwnerRef.Value = Tool.Parent
		local phoenixRefObject = WaitForChild(Tool,"PhoenixRefObject"):Clone()
		PhoenixClone.PhoenixScript.Disabled = false

		debris:AddItem(phoenixRefObject, PhoenixDuration)
		phoenixRefObject.Value = phoenixModel
		phoenixRefObject.Parent = Tool.Parent

		debris:AddItem(phoenixModel, PhoenixDuration + 6)
		phoenixModel.Parent = game.Workspace
		return true
	end
end

function onActivated()
	local humanoid = Tool.Parent:FindFirstChild("Humanoid")
	if not (humanoid and humanoid.Health > 0) then return end
	if TrySpawnPhoenix() then 
		HideTool()
		return
	end
	local oldPhoenixRef = Tool.Parent:FindFirstChild("PhoenixRefObject")
	if oldPhoenixRef then
		local phoenixModel = oldPhoenixRef.Value
		if phoenixModel and phoenixModel.Parent then
			local curPhoenix = phoenixModel:FindFirstChild("Torso")
			if not curPhoenix then return end
			local phoenixTarget = curPhoenix:FindFirstChild("TargetPoint")
			if phoenixTarget then 
				phoenixTarget.Value = humanoid.TargetPoint
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
		leftWeld.Parent = Phoenix
	end 
	if rightWeld then 
		rightWeld.Parent = Phoenix 
	end 

	TrySpawnPhoenix()

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

