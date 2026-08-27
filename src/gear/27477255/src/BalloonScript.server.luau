local Tool = script.Parent
local upAndAway = false
local humanoid = nil
local head = nil
local upAndAwayForce = Instance.new("BodyForce")

local equalizingForce = 236 / 1.2 -- amount of force required to levitate a mass
local gravity = 1.05 -- things float at > 1

local height = nil
local maxRise =  200

function onTouched(part)

	local h = part.Parent:FindFirstChild("Humanoid")
	if h ~= nil then
		upAndAway = true
		Tool.Handle.Anchored = false
	end

end

function onEquipped()

	Tool.Handle.Mesh.MeshId = "http://www.roblox.com/asset/?id=25498565"
	upAndAway = true
	upAndAwayForce.Parent = Tool.Handle
	Tool.GripPos = Vector3.new(0,-1,0)
	Tool.GripForward = Vector3.new(0,1,0)
	Tool.GripRight = Vector3.new(0,0,-1)
	Tool.GripUp = Vector3.new(1,0,0)
	height = Tool.Parent.Torso.Position.y
	local lift = recursiveGetLift(Tool.Parent)
	float(lift)
end

function onUnequipped()

	upAndAway = false
	Tool.GripForward = Vector3.new(1,0,0)
	Tool.GripRight = Vector3.new(0,0,1)
	Tool.GripUp = Vector3.new(0,1,0)
	Tool.Handle.Mesh.Scale = Vector3.new(1,1,1)

end

Tool.Unequipped:connect(onUnequipped)
Tool.Equipped:connect(onEquipped)
Tool.Handle.Touched:connect(onTouched)

function recursiveGetLift(node)
	local m = 0
	local c = node:GetChildren()
	if (node:FindFirstChild("Head") ~= nil) then head = node:FindFirstChild("Head") end -- nasty hack to detect when your parts get blown off

	for i=1,#c do
		if c[i].className == "Part" then	
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

function updateBalloonSize()

	local range = (height + maxRise) - Tool.Handle.Position.y

	print(range)
	
	if range > 100 then
		Tool.Handle.Mesh.Scale = Vector3.new(1,1,1)
	elseif range < 100 and range > 50 then
		Tool.Handle.Mesh.Scale = Vector3.new(2,2,2)
	elseif range < 50 then
		Tool.Handle.Mesh.Scale = Vector3.new(3,3,3)
	end

end


function float(lift)

	while upAndAway do

		upAndAwayForce.force = Vector3.new(0,lift * 0.98,0)
		upAndAwayForce.Parent = Tool.Handle
		wait(3)

		upAndAwayForce.force = Vector3.new(0,lift * 0.92,0)
		wait(2)

		if Tool.Handle.Position.y > height + maxRise then
			upAndAway = false
			Tool.Handle.Pop:Play()
			Tool.GripPos = Vector3.new(0,-0.4,0)
			Tool.Handle.Mesh.MeshId = "http://www.roblox.com/asset/?id=26725510"
			upAndAwayForce.Parent = nil
		end

		updateBalloonSize()

	end

end


