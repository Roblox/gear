print("run brew")


-- assume we are in the character, let's check

function sepuku()
	script.Parent = nil
end

local h = script.Parent:FindFirstChild("Humanoid")

if (h == nil) then sepuku() end

local head = script.Parent:FindFirstChild("Head")

if (head == nil) then sepuku() end

local m = head:FindFirstChild("Mesh")

if (m == nil) then sepuku() end

local oldColor = head.BrickColor
local oldScale = m.Scale

head.BrickColor = BrickColor.Random()

for i=1,10 do
	m.Scale = m.Scale * 1.05
	wait(.1)
end

wait(12)

for i=1,10 do
	m.Scale = m.Scale / 1.05
	wait(.1)
end

m.Scale = oldScale
head.BrickColor = oldColor

script.Parent = nil