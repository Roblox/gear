local Tool = script.Parent
local santaJetPack = Tool.Handle

local mass = 0
local player = nil
local equalizingForce = 236 / 1.2 -- amount of force required to levitate a mass
local gravity = 0.80 -- things float at > 1
local moving = false

local maxFuel = 1300

local fuelGuiId = 67300201

if Tool:FindFirstChild("FuelGui") == nil then 
	local fuelGui = game:GetService("InsertService"):LoadAsset(fuelGuiId)
	if fuelGui then 
		fuelGui = fuelGui:GetChildren()
		if fuelGui then 
			fuelGui = fuelGui[1] 
			fuelGui.Parent = Tool 
		end 
	end 
end

local currfuel = Tool:FindFirstChild("CurrFuel")
while currfuel == nil do
	Tool = script.Parent
	currfuel = Tool:FindFirstChild("CurrFuel")
	wait()
end

local fuel = Tool.CurrFuel.Value

local gui = nil

local anim = nil

local jetPack = nil

local regen = false

local force = Instance.new("BodyVelocity")
force.velocity = Vector3.new(0,0,0)

local bodyGyro = Instance.new("BodyGyro")
bodyGyro.P = 20000
bodyGyro.D = 8000     
bodyGyro.maxTorque = Vector3.new(bodyGyro.P,bodyGyro.P,bodyGyro.P)

local cam = nil

local Flame = nil

function updateGUI()
	if gui and gui:FindFirstChild("Frame") then 
		gui.Frame.Size = UDim2.new(0, 32, 0.45 * (Tool.CurrFuel.Value/maxFuel), 0) -- * (Tool.CurrFuel.Value/maxFuel)) 
		gui.Frame.Position = UDim2.new(0.903, 0, 0.2 + (0.45 * (1 - Tool.CurrFuel.Value/maxFuel)), 0)
	end 
end

function thrust()
	if fuel > 0 then
		thrusting = true
		force.Parent = player.Torso
		jetPack.Flame.Fire.Enabled = true
		Tool.Handle.InitialThrust:Play()
		bodyGyro.Parent = player.Torso
		while thrusting do
			bodyGyro.cframe = cam.CoordinateFrame
			force.velocity = Vector3.new(0,cam.CoordinateFrame.lookVector.unit.y,0) * 50
			fuel = fuel - 1
			Tool.CurrFuel.Value = fuel
			if fuel <= 0 then
				if santaJetPack:FindFirstChild("EngineFail") then Tool.Handle.EngineFail:Play() end
				cutEngine()
			end
			updateGUI()
			wait()
			Tool.Handle.Thrusting:Play()
			if fuel <= 200 then
				Tool.Handle.LowFuelWarning:Play()
			end
		end
		Tool.Handle.Thrusting:Stop()
		Tool.Handle.LowFuelWarning:Stop()
	end
end

function cutEngine()
	thrusting = false
	jetPack.Flame.Fire.Enabled = false
	force.velocity = Vector3.new(0,0,0)
	force.Parent = nil
	anim:Stop()
	bodyGyro.Parent = nil
end


local head = nil
function recursiveGetLift(node)
	local m = 0
	local c = node:GetChildren()
	if (node:FindFirstChild("Head") ~= nil) then head = node:FindFirstChild("Head") end -- nasty hack to detect when your parts get blown off

	for i = 1, #c do
		if c[i].ClassName == "Part" then
			if (head ~= nil and (c[i].Position - head.Position).magnitude < 10) then -- GROSS
				if c[i].Name == "Handle" then
					m = m + (c[i]:GetMass() * equalizingForce * 1) -- hack that makes hats weightless, so different hats don't change your jump height
				else
					m = m + (c[i]:GetMass() * equalizingForce * gravity)
				end
			end
		end
		m = m + recursiveGetLift(c[i])
	end
	return m
end

function regenFuel()
	while regen do
		if fuel < maxFuel then
			fuel = fuel + 1
			Tool.CurrFuel.Value = fuel
			updateGUI()
		end
		wait(0.2)
	end
end

function equipPack()

	jetPack = Tool.Handle:clone()
	jetPack.CanCollide = false
	jetPack.Name = "JetPack"

	jetPack.Parent = game.Workspace

	Tool.Handle.Transparency = 1

	local welder = Instance.new("Weld")
	welder.Part0 = jetPack
	welder.Part1 = player.Torso
	welder.C0 = CFrame.new(Vector3.new(0, 0.75, -0.25)) * CFrame.Angles(math.pi/2, 0, 0)
	welder.Parent = jetPack

	Flame = Instance.new("Part")
	Flame.Name = "Flame"
	Flame.Transparency  =1
	Flame.CanCollide = false
	Flame.Locked = true
	Flame.formFactor = 2
	Flame.Size = Vector3.new(1,0.4,1)
	Flame.Parent = jetPack

	local Fire = Instance.new("Fire")
	Fire.Heat = -12
	Fire.Size = 4
	Fire.Enabled = false
	Fire.Parent = Flame

	local firer = Instance.new("Weld")
	firer.Part0 = jetPack.Flame
	firer.Part1 = jetPack
	firer.C0 = CFrame.new(Vector3.new(0, 2, 0)) --* CFrame.Angles(math.pi/2, 0, 0)
	firer.Parent = jetPack.Flame
end

function onEquipped(mouse)
	print("Equipped")
	player = Tool.Parent	
	jetPack = Tool.Handle:clone()
	jetPack.CanCollide = false
	jetPack.Name = "JetPack"

	jetPack.Parent = game.Workspace

	Tool.Handle.Transparency = 1

	local welder = Instance.new("Weld")
	welder.Part0 = jetPack
	welder.Part1 = player.Torso
	welder.C0 = CFrame.new(Vector3.new(0, 0.75, -0.25)) * CFrame.Angles(math.pi/2, 0, 0)
	welder.Parent = jetPack

	Flame = Instance.new("Part")
	Flame.Name = "Flame"
	Flame.Transparency  =1
	Flame.CanCollide = false
	Flame.Locked = true
	Flame.formFactor = 2
	Flame.Size = Vector3.new(1,0.4,1)
	Flame.Parent = jetPack

	local Fire = Instance.new("Fire")
	Fire.Heat = -12
	Fire.Size = 4
	Fire.Enabled = false
	Fire.Parent = Flame

	local firer = Instance.new("Weld")
	firer.Part0 = jetPack.Flame
	firer.Part1 = jetPack
	firer.C0 = CFrame.new(Vector3.new(0, 2, 0)) --* CFrame.Angles(math.pi/2, 0, 0)
	firer.Parent = jetPack.Flame

	mass = recursiveGetLift(player)
	force.P = mass * 10
	force.maxForce = Vector3.new(0,force.P,0)
	mouse.Button1Down:connect(thrust)
	mouse.Button1Up:connect(cutEngine)
	cam = game.Workspace.CurrentCamera
	anim = player.Humanoid:LoadAnimation(Tool.standstill)
	if anim then anim:Play() end
	gui = Tool.FuelGui:Clone()
	updateGUI()
	gui.Parent = game.Players:GetPlayerFromCharacter(player).PlayerGui

	regen = true
	regenFuel()
end

function onUnequipped()
	regen = false
	if force ~= nil then
		force:remove()
	end
	if bodyGyro ~= nil then
		bodyGyro:remove()
	end
	if anim ~= nil then
		anim:Stop()
		anim:remove()
	end
	if gui ~= nil then
		gui:remove()
	end
	if jetPack ~= nil then
		jetPack:remove()
		jetPack = nil
	end
	Tool.Handle.Transparency = 0
	thrusting = false 
end

Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)

