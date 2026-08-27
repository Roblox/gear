local kit = script.Parent
local reloadTime = 30


kit.Enabled = true

function onUsed()
	if not kit.Enabled then return end
	local vChar = kit.Parent
	if vChar == nil then return end
	local hum = vChar:FindFirstChild("Humanoid")
	if hum == nil then return end

	kit.Enabled = false

	
	local targetPos = hum.TargetPoint

	local playaz = game.Players:GetPlayers()
	local closestTarget = nil
	local closestDistanceSq = 100  -- must click within 10 units of person to heal them
	local closestTorso = nil

	for i = 1, #playaz do
		pChar = playaz[i].Character
		if pChar ~= nil then
			pTorso = pChar:FindFirstChild("Torso") or pChar:FindFirstChild("UpperTorso")
			if pTorso ~= nil then
				if (pTorso.Position - targetPos):Dot(pTorso.Position - targetPos) < closestDistanceSq then
					closestTarget = pChar
					closestTorso = pTorso
					closestDistanceSq = (pTorso.Position - targetPos):Dot(pTorso.Position - targetPos)
				end
			end
		end
	end

	if closestTarget == nil then kit.Enabled = true return end
	
	kit.Handle.FirstAid:Play()

	-- otherwise, we have a target!  let the healing begin!
	local ghostKit = kit.Handle:Clone()
	ghostKit.CanCollide = false
	sparkles = Instance.new("Sparkles")
	sparkles.SparkleColor = Color3.new(0, 1, 0)
	sparkles.Parent = ghostKit

	newFloatForce = Instance.new("BodyForce")
	newFloatForce.force = Vector3.new(0, ghostKit:GetMass()*workspace.Gravity, 0)
	newFloatForce.Parent = ghostKit

	newSpinForce = Instance.new("BodyAngularVelocity")
	newSpinForce.P = 100000
	newSpinForce.maxTorque = Vector3.new(newSpinForce.P, newSpinForce.P, newSpinForce.P)
	newSpinForce.angularvelocity = Vector3.new(0, 20, 0)
	newSpinForce.Parent = ghostKit

	local newBodyPosition = Instance.new("BodyPosition")
	newBodyPosition.P = 10000
	newBodyPosition.D = 1000
	newBodyPosition.maxForce = Vector3.new(newBodyPosition.P, newBodyPosition.P, newBodyPosition.P)
	newBodyPosition.position = ghostKit.Position + Vector3.new(0, 10, 0)
	newBodyPosition.Parent = ghostKit

	ghostKit.Parent = game.Workspace
	kit.Handle.Transparency = 1

	wait(1)

	while (ghostKit.Position - closestTorso.Position):Dot(ghostKit.Position - closestTorso.Position) > 1 and closestTorso ~= nil and closestTorso.Parent ~= nil and closestTorso.Parent:FindFirstChild("Humanoid") ~= nil do
		newBodyPosition.position = closestTorso.Position
		wait(.1)
	end

	for i = 1, 10 do
		ghostKit.Transparency = i/10
		if closestTorso ~= nil then newBodyPosition.position = closestTorso.Position end
		wait(.1)
	end

	ghostKit:remove()

	if closestTorso ~= nil and closestTorso.Parent ~= nil then
		local humanoid = closestTorso.Parent:FindFirstChild("Humanoid")
		if humanoid ~= nil then
			local newHealth = humanoid.Health + humanoid.MaxHealth / 3
			if newHealth > humanoid.MaxHealth then newHealth = humanoid.MaxHealth end
			humanoid.Health = newHealth
		end
	end

	wait(reloadTime)

	kit.Handle.Transparency = 0
	kit.Enabled = true
end

function makeVisible()
	kit.Handle.Transparency = 0
end

kit.Unequipped:connect(makeVisible)
kit.Activated:connect(onUsed)
