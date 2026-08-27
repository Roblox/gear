Tool = script.Parent
local canStealBucket = 0
local stopStealingBucket = true

function onEquipped()

	if Tool.Handle.IHasABucket.IsPlaying == false and Tool.Handle.StealingBucket.IsPlaying == false then
		Tool.Handle.IHasABucket.Volume = 0.5
		Tool.Handle.IHasABucket:Play()
	end

end

function onUnequipped()

	Tool.Handle.IHasABucket.Volume = 0
	Tool.Handle.IHasABucket:Stop()
	if stopStealingBucket then
		Tool.Handle.StealingBucket:Stop()
	end
end


Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)


function onTouched(part)
	
	wait(0.1)
	humanoid = part.Parent:findFirstChild("Humanoid")

	if humanoid ~= nil and humanoid ~= Tool.Parent:FindFirstChild("Humanoid") and canStealBucket == 0 then
		
		objects = humanoid.Parent:getChildren()

		for i = 1,#objects do
			if objects[i].className == "Tool" then
				objects[i].Parent = game.Workspace
				break
			end
		end

		
			Tool.Handle.IHasABucket:Stop()
			Tool.Handle.StealingBucket.Volume = 0.5
			Tool.Handle.StealingBucket:Play()
			stopStealingBucket = false
			Tool.Parent = humanoid.Parent
			stopStealingBucket = true
			canStealBucket  = 4
			wait(1.3)
			Tool.Handle.StealingBucket:Stop()

			--Tool.Handle.IHasABucket:Play()

	end

end


Tool.Handle.Touched:connect(onTouched)

while true do

	if canStealBucket > 0 then
		canStealBucket = canStealBucket - 1
	else
		Tool.Handle.StealingBucket:Stop()
	end
	wait(1)
end
