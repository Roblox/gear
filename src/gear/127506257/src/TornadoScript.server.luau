--
local Tornado = script.Parent
local IgnoreChar = Tornado:WaitForChild('Ignore').Value

local PartInfo = {}
local StuffToDestroy = {}

local bpTable = {}
local startRadTable = {}

local NUM_STEPS = 100
local STEP_TIME = 0.1

-- Copied from HotThoth's code for the Tornade. SECRET RETEXTURE MUWAHAHAHA
Tornado.Touched:connect(function(part)
	if part.Parent and part.Parent ~= IgnoreChar then
		if part.Parent.Parent and part.Parent.Parent == IgnoreChar then 	-- check for initiating character's hat
			return 
		end		

		if part.Parent:FindFirstChildOfClass('ForceField') then
			return
		end

		part:BreakJoints()		
		
		local spinForce = part:FindFirstChild('KOSSGustTornadoSpin')
		if spinForce == nil then 
			local spinForce = Instance.new('BodyAngularVelocity')
			spinForce.P = 1000000
			spinForce.angularvelocity = Vector3.new(0,50,0)
			spinForce.maxTorque = Vector3.new(spinForce.P,spinForce.P,spinForce.P)
			spinForce.Name = 'KOSSGustTornadoSpin'
			spinForce.Parent = part
			table.insert(StuffToDestroy, spinForce)
		end
		
		local newBV = part:FindFirstChild('KOSSGustTornadoLift')
		if newBV == nil then
			newBV = Instance.new("BodyVelocity")
			newBV.Name = 'KOSSGustTornadoLift'
			newBV.P = 100000
			newBV.maxForce = Vector3.new(0, newBV.P, 0)
			newBV.velocity = Vector3.new(0, 16, 0)
			newBV.Parent = part
			table.insert(StuffToDestroy, newBV)
		end
		
		local newBP = part:FindFirstChild('KOSSGustTornadoPos')
		if newBP == nil then
			newBP = Instance.new("BodyPosition")
			newBP.Name = 'KOSSGustTornadoPos'
			newBP.P = 100000
			newBP.maxForce = Vector3.new(newBP.P, 0, newBP.P)
			newBP.position = part.Position
			newBP.Parent = part
			table.insert(bpTable, newBP)
			table.insert(startRadTable, (part.Position - Tornado.Position)*Vector3.new(1, 0, 1))
			table.insert(StuffToDestroy, newBP)
		end
	end
end)

for i = 1, NUM_STEPS do
	for i = 1, #bpTable do
		bpTable[i].position = Tornado.Position + startRadTable[i]
		startRadTable[i] = CFrame.Angles(0, .7, 0)*startRadTable[i]
	end
	wait(STEP_TIME)
end
for _, thing in pairs(StuffToDestroy) do
	thing:Destroy()
end
Tornado:Destroy()
--