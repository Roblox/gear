local Tool = script.Parent
local Axe = Tool.Handle

local vCharacter
local myHumanoid
local myTorso

local wave = Tool:FindFirstChild("Wave")
local drill = Tool:FindFirstChild("Drill")

function computeWeight(object) 
	local totalMass = 0
	local ch
	if object == nil then return end
	if type(object) == "table" then 
		ch = object
	else
		ch = object:GetChildren()	
	end
	for i = 1, #ch do 
		if ch[i]:IsA("BasePart") then 
			totalMass = totalMass + ch[i]:GetMass()
		end		
		totalMass = totalMass + computeWeight(ch[i])		
	end	
	return totalMass
end

while wave == nil or drill == nil do 
	wave = Tool:FindFirstChild("Wave")
	drill = Tool:FindFirstChild("Drill")
	wait()
end

wave.Changed:connect(function() 
	wave = Tool:FindFirstChild("Wave")	
	if wave and wave.Value == 1 and myTorso and myHumanoid then			
		local theta
		if myHumanoid and myTorso then 
		myHumanoid.Jumping:connect(function() 
				if myTorso:FindFirstChild("jumpBV") == nil then
					jumpBV = Instance.new("BodyVelocity")
					jumpBV.P = 50000
					jumpBV.maxForce = Vector3.new(0, jumpBV.P, 0)
					jumpBV.Name = "jumpBV"
					jumpBV.velocity = Vector3.new(0, characterMass/4.0, 0)
					jumpBV.Parent = myTorso
				end
			end)
		end
		for i = 1, 300 do 
			theta = i%6 * math.pi/3
			Tool.GripRight = Vector3.new(0, math.cos(theta), math.sin(theta))
			Tool.GripUp = Vector3.new(0, -math.sin(theta), math.cos(theta))
			wait()
		end

		if jumpBV then jumpBV:Remove() end

		Tool.GripRight = Vector3.new(0, 1, 0)
		Tool.GripUp = Vector3.new(0, 0, 1)			
		wave.Value = 0 
	end
end)

drill.Changed:connect(function()
	drill = Tool:FindFirstChild("Drill")
	if drill and drill.Value == 1 then
		local theta	
		Tool.GripUp = Vector3.new(1, 0, 0)
		Tool.GripRight = Vector3.new(0, 1, 0)
		Tool.GripForward = Vector3.new(0, 0, 1)
		for i = 1, 150 do 
			theta = i%6 * math.pi/3
			Tool.GripRight = Vector3.new(math.cos(theta), math.sin(theta), 0)
			Tool.GripUp = Vector3.new(math.sin(theta), -math.cos(theta), 0)
			wait()
		end	
		
		Tool.GripRight = Vector3.new(0, 1, 0)
		Tool.GripUp = Vector3.new(0, 0, 1)
		Tool.GripForward = Vector3.new(1, 0, 0)
		drill.Value = 0
	end
end)

function onEquipped()
	vCharacter = Tool.Parent
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	myTorso = vCharacter:FindFirstChild("Torso") or vCharacter:FindFirstChild("UpperTorso")
	characterMass = computeWeight(vCharacter)	
end

Tool.Equipped:connect(onEquipped)