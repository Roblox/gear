--Fixed by Luckymaxer

local fire = script.Parent:FindFirstChild("Fire")
local light = script.Parent:FindFirstChild("PointLight")

function largestSide(length,width,height)

	local large = 0
	if length > width then
		large = length
	else
		large = width
	end
	if large < height then
		large = height
	end
	if large > 30 then
		return 30
	end
	return large

end

local largestSize = largestSide(script.Parent.Size.x,script.Parent.Size.y,script.Parent.Size.z)
local interval = largestSize/15

while fire and light and fire.Size <= largestSize do
	fire.Size = fire.Size + interval
	light.Range=fire.Size*6
	wait(1)
	fire = script.Parent:FindFirstChild("Fire")
	light = script.Parent:FindFirstChild("PointLight")
end

wait(3)

fire = script.Parent:FindFirstChild("Fire")
light = script.Parent:FindFirstChild("PointLight")
while fire and light and fire.Size > 2 do
	fire.Size = fire.Size - interval
	light.Range=fire.Size*6
	wait(1)
	fire = script.Parent:FindFirstChild("Fire")
	light = script.Parent:FindFirstChild("PointLight")
end

if fire and light then
	fire.Enabled = false
	light.Enabled=false
end

wait(1)

script:remove()