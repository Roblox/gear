local Tool = script.Parent;


local r = game:service("RunService")

local vChar = Tool.Parent
local torso = nil
while vChar == nil or vChar.Name == "BackPack" or torso == nil do
	vChar = Tool.Parent
	if vChar ~= nil and vChar.Name ~= "BackPack" then
		torso = vChar:FindFirstChild("Torso") or vChar:FindFirstChild("UpperTorso")
	end
	wait()
end

Tool.Enabled = true

function recursiveGetLift(node)
	local m = 0
	local c = node:GetChildren()
	if (node:FindFirstChild("Head") ~= nil) then head = node:FindFirstChild("Head") end -- nasty hack to detect when your parts get blown off

	for i=1,#c do
		if c[i].className == "Part" then	
			if (head ~= nil and (c[i].Position - head.Position).magnitude < 10) then -- GROSS
				if c[i].Name == "Handle" then
					m = m + (c[i]:GetMass()) -- hack that makes hats weightless, so different hats don't change your jump height
				else
					m = m + (c[i]:GetMass())
				end
			end
		end
		m = m + recursiveGetLift(c[i])
	end
	return m
end

local floatForce = nil
local airResistanceForce = nil
local unequipped = true

function onEquip()
	unequipped = false
	if floatForce == nil then floatForce = torso:FindFirstChild("MBrellaForce") end
	if airResistanceForce == nil then airResistanceForce = torso:FindFirstChild("MBrellaAR") end
	if floatForce == nil then
		floatForce = Instance.new("BodyForce")
		floatForce.force = Vector3.new(0,recursiveGetLift(vChar)*50,0) -- will mostly negate gravity
		floatForce.Name = "MBrellaForce"
		floatForce.Parent = torso
	end
	if airResistanceForce == nil then
		airResistanceForce = Instance.new("BodyVelocity")
		airResistanceForce.P = recursiveGetLift(vChar)*130
		airResistanceForce.maxForce = Vector3.new(0,airResistanceForce.P,0)
		airResistanceForce.velocity = Vector3.new(0, 10, 0)
		airResistanceForce.Name = "MBrellaAR"
		airResistanceForce.Parent = torso
	end
end

function onUnequip()
	unequipped = true
	if floatForce ~= nil and floatForce.Parent ~= nil then
		floatForce:Destroy()
		floatForce = nil
	end
	if airResistanceForce ~= nil and airResistanceForce.Parent ~= nil then
		airResistanceForce:Destroy()
		airResistanceForce = nil
	end
end

local canFloatAwayNow = true
function floatAway()
	canFloatAwayNow = false

	local FakeUmbrella = Tool.Handle:Clone()
	FakeUmbrella.CanCollide = true
	FakeUmbrella.Position = Tool.Handle.Position
	local floatVel = Instance.new("BodyVelocity")
	floatVel.Name = "FakeUmbrellaBodyVelocity"
	floatVel.P = 100000
	floatVel.maxForce = Vector3.new(floatVel.P, floatVel.P, floatVel.P)
	floatVel.velocity = Vector3.new((math.random()-0.5)*3, 3, (math.random()-0.5)*3)
	floatVel.Parent = FakeUmbrella
	FakeUmbrella.Parent = game.Workspace
	local floatGyro = Instance.new("BodyGyro")
	floatGyro.Name = "FakeUmbrellaBodyGyro"
	floatGyro.P = 100
	floatGyro.D = 1
	floatGyro.maxTorque = Vector3.new(floatGyro.P, floatGyro.P, floatGyro.P)
	floatGyro.cframe = CFrame.new()
	floatGyro.Parent = FakeUmbrella

	Tool.Handle.Transparency = 1

	if floatForce ~= nil then floatForce.Parent = nil end
	if airResistanceForce ~= nil then airResistanceForce.Parent = nil end

	for i = 1, 10 do
		floatVel.velocity = Vector3.new((math.random()-0.5)*3, 3, (math.random()-0.5)*3)
		wait(.5)
	end

	wait(5)

	if floatForce ~= nil and not unequipped then floatForce.Parent = torso
	elseif floatForce ~= nil then floatForce:Destroy() floatForce = nil end
	if airResistanceForce ~= nil and not unequipped then airResistanceForce.Parent = torso
	elseif airResistanceForce ~= nil then airResistanceForce:Destroy() airResistanceForce = nil end

	Tool.Handle.Transparency = 0
	if FakeUmbrella ~= nil and FakeUmbrella.Parent ~= nil then FakeUmbrella.Parent = nil end
	
	canFloatAwayNow = true
end

function spinspinspin()
	for i = 1, 20 do
		angle = i*math.pi/10
		Tool.GripForward = Vector3.new(math.cos(angle), 0, math.sin(angle))
		Tool.GripRight = Vector3.new(math.sin(angle), 0, math.cos(angle))
		wait(.1)
	end
end

local last_attack = 0
function onActivated()
	if not Tool.Enabled and canFloatAwayNow then
		t = r.Stepped:wait()
		if (t - last_attack < .2) then
			floatAway()
		end
		last_attack = t
		return
	end

	t = r.Stepped:wait()
	Tool.Enabled = false
	spinspinspin()
	last_attack = t
	Tool.Enabled = true
end

script.Parent.Equipped:connect(onEquip)
script.Parent.Activated:connect(onActivated)
script.Parent.Unequipped:connect(onUnequip)