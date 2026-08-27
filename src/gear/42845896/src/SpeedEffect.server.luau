-- assume we are in the character, let's check
function sepuku()
	script.Parent = nil
end

local debris = game:GetService("Debris")

local h = script.Parent:FindFirstChildOfClass("Humanoid")
if (h == nil) then sepuku() end

local torso = script.Parent:FindFirstChild("Torso") or script.Parent:FindFirstChild("UpperTorso")
if (torso == nil) then sepuku() end

local head = script.Parent:FindFirstChild("Head")
if (head == nil) then head = torso end

local equalizingForce = workspace.Gravity -- amount of force required to levitate a mass
local gravity = .75 -- things float at > 1
local fire = Instance.new("Fire")
fire.Color = Color3.new(0, .3, 1)
fire.SecondaryColor = Color3.new(0, 1, .5)
fire.Parent = head
fire.Heat = 10
fire.Size = 3

h.WalkSpeed = 30

local partsList = script.Parent:GetChildren()
local snowwelds = {}
local snowballs = {}

for i = 1, #partsList do
	if partsList[i]:IsA("BasePart") and partsList[i].Name ~= "Head" and partsList[i].Name ~= "HumanoidRootPart" then
		-- snowball it
		snowball = Instance.new("Part")

		snowballSize = partsList[i].Size.X
		if partsList[i].Size.Y > snowballSize then snowballSize = partsList[i].Size.Y end
		if partsList[i].Size.Z > snowballSize then snowballSize = partsList[i].Size.Z end
		snowballSize = snowballSize * math.sqrt(2)
		if partsList[i].Name == "Torso" or partsList[i].Name == "UpperTorso" then snowballSize = snowballSize * math.sqrt(2) end

		--snowball.Size = partsList[i].Size
		snowball.Size = Vector3.new(snowballSize, snowballSize, snowballSize)
		snowball.Shape = 0
		snowball.BrickColor = BrickColor.new("Institutional white")
		snowball.Material = "Concrete"
		snowball.TopSurface = "Smooth"
		snowball.BottomSurface = "Smooth"
		
		snowWeld = Instance.new("Weld")
		snowWeld.Part0 = partsList[i]
		snowWeld.Part1 = snowball
	
		snowWeld.Parent = script.Parent
		snowball.Parent = script.Parent
	
		table.insert(snowwelds, snowWeld)
		table.insert(snowballs, snowball)
	end
end


function recursiveGetLift(node)
	local m = 0
	local c = node:GetChildren()
	if (node:FindFirstChild("Head") ~= nil) then head = node:FindFirstChild("Head") end -- nasty hack to detect when your parts get blown off

	for i=1,#c do
		if c[i]:IsA("BasePart") then
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

--	debris:AddItem(force,0.5)

function pushIt()
	--local mass = recursiveGetLift(h.Parent)
	local force = torso:FindFirstChild("IceForce")
	if force == nil then
		force = Instance.new("BodyVelocity")
		force.Name = "IceForce"
		force.velocity = Vector3.new(0,0,0)
		force.P = recursiveGetLift(h.Parent)*5
		force.maxForce = 3*Vector3.new(force.P,0,force.P)
		force.Parent = torso
	end
	force.velocity = (torso.Velocity*Vector3.new(1,0,1)*3/10 + force.velocity*7/10)
end

for i = 1, 450 do -- 45 seconds
	pushIt()
	wait(.1)
end

h.WalkSpeed = 16

for i = 1, #snowwelds do
	snowwelds[i]:Destroy()
end
for i = 1, #snowballs do
	snowballs[i]:Destroy()
end

fire:Destroy()
iceForce = torso:FindFirstChild("IceForce")
if iceForce ~= nil then iceForce:Destroy() end

sepuku()
workspace:GetPropertyChangedSignal("Gravity"):Connect(function()
	equalizingForce = workspace.Gravity
end)