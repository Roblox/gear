Tool = script.Parent
local canStealBucket = 0
local gameStart = false
local stopStealingBucket = true
local e = Instance.new("Explosion")
e.BlastRadius = 2
e.BlastPressure = 10000
enabled = true
local player = nil
local redColor = Vector3.new(1,0,0)

function onEquipped()

	Tool.Handle.StealingBucket:Stop()
	player = Tool.Parent
	p = game.Players:GetPlayerFromCharacter(player)
	if p ~= nil and gameStart == false then
		local gui = Tool.HotPotatoGui:clone()
		gui.Parent = p.PlayerGui
	end
	if gameStart then
		Tool.Handle.IHasABucket.Looped = true
		Tool.Handle.IHasABucket:Play()
	end
end

function onUnequipped()

	if Tool.Parent.Parent.className ==  "Player" and gameStart == false then
		localGui = Tool.Parent.Parent.PlayerGui
		toRemove = localGui:FindFirstChild("HotPotatoGui")
		if toRemove ~= nil then
			toRemove:remove()
		end
	end
	if gameStart == false then
		Tool.Handle.IHasABucket.Looped = false
		Tool.Handle.IHasABucket:Stop()
	end
end

function onActivated()

	if not enabled  then
		return
	end

	enabled = false

	player = Tool.Parent
	p = game.Players:GetPlayerFromCharacter(player)
	if p ~= nil then
		hpGui = p.PlayerGui:FindFirstChild("HotPotatoGui")
		if hpGui ~= nil then
			hpGui:remove()
		end
	end

	gameStart = true
	Tool.Handle.IHasABucket.Looped = true
	Tool.Handle.IHasABucket:Play()

	enabled = true

end


Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
Tool.Activated:connect(onActivated)


function onTouched(part)
	
	wait(0.1)
	humanoid = part.Parent:findFirstChild("Humanoid")

	if humanoid ~= nil and humanoid ~= Tool.Parent:FindFirstChild("Humanoid") and canStealBucket == 0 and gameStart == true then
		
		objects = humanoid.Parent:getChildren()

		for i = 1,#objects do
			if objects[i].className == "Tool" then
				objects[i].Parent = game.Workspace
			end
		end

		Tool.Parent = humanoid.Parent
			Tool.Handle.IHasABucket.Looped = true
			Tool.Handle.IHasABucket:Play()
		canStealBucket  = 2

	end

end


Tool.Handle.Touched:connect(onTouched)

while true do

	if gameStart then

		if Tool.Handle.Mesh.VertexColor == redColor then
			Tool.Handle.Mesh.VertexColor = Vector3.new(1,1,1)
		else
			Tool.Handle.Mesh.VertexColor = redColor
		end

		if player ~= nil and Tool.Parent ~= player then
			otherTools = player:GetChildren()
			for i = 1,#otherTools do
				if otherTools[i].className == "Tool" then
					otherTools[i].Parent = game.Workspace
				end
			end
			Tool.Parent = player
		end
		
		fate = math.random(1,15)
		if fate == 5 and Tool.Parent ~= game.Workspace and gameStart == true then
			
			Tool.Handle.StealingBucket:Play()
			Tool.Handle.IHasABucket:Stop()
			Tool.Handle.IHasABucket.Looped = false
			e.Position = Tool.Handle.Position
			local origPosition = Tool.Handle.Position
			Tool.Handle.Position = Vector3.new(0,100000,0)
			Tool.Handle.Transparency = 1
			Tool.Parent = game.Workspace
			e.Parent = game.Workspace
			gameStart = false
			fate = 0

			wait(2)

			e.Parent = nil
			wait(1)
			
			Tool.Handle.Transparency = 0
			Tool.Handle.Position = origPosition
			Tool.Handle.Mesh.VertexColor = Vector3.new(1,1,1)

		end

		if canStealBucket > 0 then
			canStealBucket = canStealBucket - 1
		end
	end
	wait(1)

end
