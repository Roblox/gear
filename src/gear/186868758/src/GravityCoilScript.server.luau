-------- OMG HAX

r = game:service("RunService")


Tool = script.Parent

local equalizingForce = 236 / 1.2 -- amount of force required to levitate a mass
local gravity = .75 -- things float at > 1

local ghostEffect = nil
local massCon1 = nil
local massCon2 = nil


local head = nil
function recursiveGetLift(root)
	local force = 0
	
	for _, obj in pairs(root:GetChildren()) do
		if obj:IsA("BasePart") then
			force = force + obj:GetMass() * equalizingForce * gravity
		end
		force = force + recursiveGetLift(obj)
	end
	
	return force
end


function onMassChanged(child, char)
	print("Mass changed:" .. child.Name .. "    " .. char.Name)
	if (ghostEffect ~= nil) then
		ghostEffect.force = Vector3.new(0, recursiveGetLift(char) ,0)
	end
end



function UpdateGhostState(isUnequipping)

	if isUnequipping == true then
		ghostEffect:Remove()
		ghostEffect = nil
		massCon1:disconnect()
		massCon2:disconnect()
	else
		if ghostEffect == nil then
			local char = Tool.Parent
			if char == nil then return end
			ghostEffect = Instance.new("BodyForce")
			ghostEffect.Name = "GravityCoilEffect"
			ghostEffect.force = Vector3.new(0, recursiveGetLift(char) ,0)
			ghostEffect.Parent = char.Head
			ghostChar = char
			massCon1 = char.ChildAdded:connect(function(child)  onMassChanged(child, char) end)
			massCon2 = char.ChildRemoved:connect(function(child)  onMassChanged(child, char) end)
		end
	end
	

end



function onEquipped()
	Tool.Handle.CoilSound:Play()
	UpdateGhostState(false)
end

function onUnequipped()
	UpdateGhostState(true)
end


script.Parent.Equipped:connect(onEquipped)
script.Parent.Unequipped:connect(onUnequipped)




