-- Sound used provided by Sedi on www.freesound.org

local Tool = script.Parent;
local SnowHat = require(215075770)
SnowHat.Parent = Tool

enabled = true

function onActivated()
	if not enabled  then
		return
	end

	if Tool.Parent == nil or Tool.Parent.Name == "Backpack" then return end
	local head = Tool.Parent:FindFirstChild("Head")
	if head == nil then return end

	enabled = false

	Tool.Handle.DrinkSound:Play()

	--wait(1)
	for i = 1, 10 do
		local angle = i*math.pi*2/5
		Tool.GripUp = Vector3.new(math.sin(angle), 0, math.cos(angle))
		Tool.GripRight = Vector3.new(math.cos(angle), 0, -math.sin(angle))
		wait(.1)
	end

	local newIgloo = Tool.SnowHat:Clone()
	--newIgloo.CFrame = Tool.Handle.CFrame
	local translationVector = head.Position - newIgloo.Handle.Position + Vector3.new(0, 2, 0)
	local newIglooParts = newIgloo:GetChildren()
	
	--local headOrientation = head.CFrame - head.Position
	--local randomOrientation = math.random(0, 179)*math.pi/180

	-- Vector3.new(0,3,0)

	for i = 1, #newIglooParts do
		newIglooParts[i].CFrame = newIglooParts[i].CFrame + translationVector
		--newIglooParts[i].CFrame = (newIglooParts[i].CFrame - newIgloo.Handle.Position)*CFrame.Angles(0, math.pi/2, 0) + head.Position --+ newIgloo.Handle.Position + translationVector
		if newIglooParts[i].Name ~= "Handle" then newIglooParts[i].CanCollide = true end
	end

	newIgloo.Handle.CFrame = head.CFrame + Vector3.new(0, 3, 0)

	newIgloo.Handle.Transparency = 0
	newIgloo.Parent = game.Workspace

	for i = 0, 14 do
		newIgloo.Handle.Transparency = i/20
		wait(1)
	end
	
	newIgloo:remove()
	
	wait(1)
	enabled = true
end

script.Parent.Activated:connect(onActivated)
