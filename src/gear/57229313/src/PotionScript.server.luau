local Tool = script.Parent
local Juice = Tool.Handle

local vCharacter
local myTorso
local myHumanoid
local myHead

Tool.Enabled = true

local juiceSound 
local sparkles

local connection 

newBV = Instance.new("BodyVelocity")
newBV.P = 10000
newBV.maxForce = Vector3.new(0.0, newBV.P, 0.0)
newBV.Name = "BootsBV" 

function onJump()
	print("Jumping")
	vCharacter = Tool.Parent
	myTorso = vCharacter:FindFirstChild("Torso")     	
	BV = newBV:Clone()
	BV.velocity = Vector3.new(0.0, 20.0, 0.0)
	BV.Parent = myTorso          
	wait(2.0)
	children = myTorso:GetChildren()
	for i = 1, #children do
		if children[i].Name == "BootsBV" then
			children[i]:Remove()               
		end
	end     
end 

function onActivated()
	if Tool.Enabled == false then 
		return
	end
	
	Tool.Enabled = false
	juiceSound = Juice:FindFirstChild("JuiceSound")
	if juiceSound then juiceSound:Play() end
	vCharacter = Tool.Parent
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	myHead = vCharacter:FindFirstChild("Head")
	if myHumanoid == nil then 
		return
	end
	if myHead then 
		sparkles = Instance.new("Sparkles")
		sparkles.Parent = myHead
		sparkles.Color = Color3.new(102, 153, 0)
	end
	
	myHumanoid.WalkSpeed = 24.0
	ratio = myHumanoid.Health/myHumanoid.MaxHealth
	myHumanoid.MaxHealth = 250
	wait(0.10)
	myHumanoid.Health = ratio * 250
	if connection == nil then connection = myHumanoid.Jumping:connect(onJump) print(connection) end 
	wait(0.5)
	Juice.Transparency = 1.0
	wait(15.0)
	if sparkles then sparkles:Remove() end
	Juice.Transparency = 0.0
	Tool.Enabled = true
end

function onEquipped()
end

function onUnequipped()
	if juiceSound then juiceSound:Stop() end
	--[[if myHumanoid then 
		myHumanoid.WalkSpeed = 16.0
		myHumanoid.Health = myHumanoid.Health/myHumanoid.MaxHealth * 100
		myHumanoid.MaxHealth = 100
		wait(0.10)
		
	end]]
	if connection then connection:disconnect() connection = nil end 
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)