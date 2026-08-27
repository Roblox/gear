function WaitForChild(parent,child)
	while not parent:FindFirstChild(child) do print("roped waiting for " .. child) wait() end
	return parent[child]
end

local Tool = script.Parent
local Handle = WaitForChild(Tool,'Handle')
local lmotor = WaitForChild(Handle,'lmotor')
local rmotor = WaitForChild(Handle,'rmotor')

lmotor.AncestryChanged:connect(function()
	Spawn(function() lmotor.Parent= Handle end)
end)

rmotor.AncestryChanged:connect(function()
	Spawn(function() rmotor.Parent= Handle end)
end)

Spawn(
function()
	
	while true do
		--lmotor.DesiredAngle =(math.sin(tick())/2)+1
		--rmotor.DesiredAngle = -(math.sin(tick()-(math.pi))/2)+1
		--wait()
		lmotor.DesiredAngle =1
		rmotor.DesiredAngle = -1
		wait(.5)
		lmotor.DesiredAngle =0
		rmotor.DesiredAngle =0
		wait(.5)
	end	
end)