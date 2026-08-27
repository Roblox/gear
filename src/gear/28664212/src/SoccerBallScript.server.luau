local Tool = script.Parent
local debris = game:GetService("Debris")
local human = nil
local passing = false

Tool.Handle.CanCollide = true

function onTouched(part)

	if passing then
		local pos = Tool.Handle.Position
		Tool.Parent = game.Workspace
		Tool.Handle.Position = pos
		return
	end

	local humanoid = part.Parent:FindFirstChild("Humanoid")
	if humanoid ~= nil and humanoid ~= human then

		-- steal the ball!
		Tool.Parent = humanoid.Parent
		wait(0.7)

	end

end


function onEquipped()

	human = Tool.Parent:FindFirstChild("Humanoid")
	Tool.Handle.boo:Stop()

	Tool.GripPos = Vector3.new(1.5,-2,0.8)

end

function onUnequipped()

	if Tool.Parent.Name ==  "Backpack" then
		Tool.Handle.boo:Play()
	end

end

function passBallTo(humanoid)

	if humanoid ~= nil and humanoid ~= "changer" and game.Players:FindFirstChild(humanoid) ~= nil then
		passing = true

		local currPlayer = Tool.Parent.Torso
		local lookAt = currPlayer.CFrame.lookVector.unit
		local outFrontBuffer = 5
		local denom = math.abs(lookAt.x) + math.abs(lookAt.z)

		local xPos = (lookAt.x/denom) * outFrontBuffer
		local zPos = (lookAt.Z/denom) * outFrontBuffer

		local bodyPos = Instance.new("BodyPosition")
		bodyPos.position = game.Workspace:FindFirstChild(humanoid, false):FindFirstChild("Right Leg", false).Position
		bodyPos.P = 2000
		bodyPos.maxForce = Vector3.new(bodyPos.P,bodyPos.P,bodyPos.P)
		debris:AddItem(bodyPos,5)
		wait(0.1)
		local pos = Tool.Handle.Position
		Tool.Parent = game.Workspace
		Tool.Handle.Position = Vector3.new(pos.x + xPos, pos.y, pos.z + zPos)
		bodyPos.Parent = Tool.Handle
		Tool.Handle.kick:Play()
		wait(0.1)

		passing = false
	end

end


Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
Tool.Handle.Touched:connect(onTouched)
Tool.PersonToPassTo.Changed:connect(passBallTo)
