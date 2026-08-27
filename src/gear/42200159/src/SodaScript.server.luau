local Tool = script.Parent;

enabled = true

function onActivated()
	if not enabled  then
		return
	end

	enabled = false

--	Tool.Handle.DrinkSound:Play()

	local newBomb = Tool.Handle:Clone()

	Tool.Snowball:Clone().Parent = newBomb
	newBomb.CanCollide = true

	Tool.SnowbombScript:Clone().Parent = newBomb
	newBomb.SnowbombScript.Disabled = false

	Tool.SnowballScript:Clone().Parent = newBomb

	newBomb.Parent = game.Workspace
	Tool.Handle.Transparency = 1


	wait(10)
	Tool.Handle.Transparency = 0

	wait(1)


--[[
	--local snowBalls = {}
	for i = 1, numSnowBalls do
		newSnowball = Tool.Snowball:Clone()
		newSnowball.CFrame = Tool.Handle.CFrame
		newSnowball.Transparency = 0
		newSnowball.CanCollide = true
		newSnowball.Anchored = false
		newSnowball.Velocity = Vector3.new(20*(math.random()-.5), 20, 20*(math.random()-.5))
		Tool.SnowballScript:Clone().Parent = newSnowball
		newSnowball.SnowballScript.Disabled = false
		newSnowball.Parent = game.Workspace
	end
	
	wait(10)]]--
	enabled = true

end

script.Parent.Activated:connect(onActivated)
