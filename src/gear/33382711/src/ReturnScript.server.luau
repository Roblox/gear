local Hand = script.Parent
local debris = game:GetService("Debris")
local player = Hand.Player.Value
local con = nil
local bodyPos = nil

local rope = Instance.new("Part")
rope.BrickColor = BrickColor.new("Really black")
rope.TopSurface = 0
rope.BottomSurface = 0
rope.formFactor = "Symmetric"
rope.Name = "Rope"
rope.CanCollide = false
rope.Anchored = true
local mesh = Instance.new("CylinderMesh")
mesh.Parent = rope
mesh.Scale = Vector3.new(1,1,1)
rope.Parent = Hand

function adjustRope()
	if rope.Parent == nil  or Hand == nil then return end
	local pos1 = Vector3.new(Hand.Position.x,Hand.Position.y - 1.5,Hand.Position.z)
	local pos2 = player:FindFirstChild("Right Arm").Position
	rope.Size = Vector3.new(0, 1, 0)
	rope.Mesh.Scale = Vector3.new(1, (pos1-pos2).magnitude - 3, 1)
	rope.CFrame = CFrame.new((pos1 + pos2)/2, pos2) * CFrame.fromEulerAnglesXYZ(-math.pi/2,0,0)
end

function touched(part)

	if part.Parent:FindFirstChild("Humanoid") then

		Hand.Velocity = Hand.Velocity * 0
		local weld = Instance.new("Weld")
		weld.Part0 = Hand
		weld.Part1 = part
		weld.Parent = Hand
		weld.C0 = CFrame.new(part.Position - Hand.Position)
		weld.C1 = CFrame.new(Hand.CFrame.lookVector)

		bodyPos = Instance.new("BodyPosition")
		bodyPos.position = player:FindFirstChild("Right Arm").Position
		bodyPos.P = 10000
		bodyPos.D = 10000
		bodyPos.maxForce = Vector3.new(1,1,1) * bodyPos.P
		bodyPos.Parent = Hand
		debris:AddItem(Hand,8)
		con:disconnect()

		Hand.Touched:connect(function(part)
			if part.Parent == player then
				Hand:remove()
			end
		end)

	else
		Hand:remove()
	end

end

con = Hand.Touched:connect(touched)

while true do 
	adjustRope()
	if bodyPos then
		bodyPos.position = player:FindFirstChild("Right Arm").Position
	end
	if rope:FindFirstChild("Mesh") ~= nil and rope.Mesh.Scale.Y > 100 then
		Hand:remove()
	end
	wait()
end
