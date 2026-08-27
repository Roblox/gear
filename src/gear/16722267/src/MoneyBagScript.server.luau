--Updated for R15 avatars by StarWars
local Tool = script.Parent;
debris = game:GetService("Debris")

enabled = true

local sounds = {Tool.Handle.MoneySound1, Tool.Handle.MoneySound2, Tool.Handle.MoneySound3}
local buck = nil


buck = Instance.new("Part")
buck.formFactor = 2
buck.Size = Vector3.new(2,.4,1)
buck.BrickColor = BrickColor.new(28)
buck.TopSurface = 0
buck.BottomSurface = 0
buck.Elasticity = .01 

local d = Instance.new("Decal")
d.Face = 4
d.Texture = "http://www.roblox.com/asset/?id=16658163"
d.Parent = buck

local d2 = d:Clone()
d2.Face = 1
d2.Parent = buck

function isTurbo(character)
	return character:FindFirstChild("Monopoly") ~= nil
end

function MakeABuck(pos)

	local limit = 5
	if (isTurbo(Tool.Parent) == true) then
		limit = 15 -- LOL!
	end

	for i=1,limit do

		local b = buck:Clone()
		local v = Vector3.new(math.random() - .5, math.random() - .5, math.random() - .5).unit
		b.CFrame = CFrame.new(pos + (v * 2) + Vector3.new(0,4,0), v)
		b.Parent = game.Workspace
		debris:AddItem(b, 60)
	end

end

function onActivated()
	if not enabled  then
		return
	end

	enabled = false

	local char = Tool.Parent

	sounds[math.random(3)]:Play()

	MakeABuck(Tool.Handle.Position)
	
	local Torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
	local RightArm = char:FindFirstChild("Right Arm") or char:FindFirstChild("RightUpperArm")
	local RightShoulder = Torso:FindFirstChild("Right Shoulder") or RightArm:FindFirstChild("RightShoulder")

	RightShoulder.MaxVelocity = 0.5
	RightShoulder.DesiredAngle = 3
	wait(.2)
	RightShoulder.MaxVelocity = 0.5
	RightShoulder.DesiredAngle = 3
	wait(.2)
	RightShoulder.MaxVelocity = 0.5
	RightShoulder.DesiredAngle = 3
	wait(.2)
	RightShoulder.MaxVelocity = 0.5
	RightShoulder.DesiredAngle = 3
	wait(.2)


	RightShoulder.MaxVelocity = 1

--[[
	Tool.GripForward = Vector3.new(0,-1,0)
	Tool.GripPos = Vector3.new(0,0,2)
	Tool.GripRight = Vector3.new(1,0,0)
	Tool.GripUp = Vector3.new(0,0,-1)
]]--
	enabled = true

end



script.Parent.Activated:connect(onActivated)

