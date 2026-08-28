local Tool = script.Parent
local vChar = nil
local torso = nil

local maxRange = 30

local lowerBound = nil
local upperBound = nil

local debris = game:GetService("Debris")
local r = game:GetService("RunService")

local blinkSound = Tool.Blink

function onEquipped()
	torso = nil
	vChar = Tool.Parent
	if vChar ~= nil then
		torso = vChar:FindFirstChild("Torso") or vChar:FindFirstChild("UpperTorso")
	end
end

Tool.Enabled = true

function getAABB()
	local torsoXAxis = torso.CFrame:vectorToWorldSpace(Vector3.new(1, 0, 0)).unit
	local torsoYAxis = torso.CFrame:vectorToWorldSpace(Vector3.new(0, 1, 0)).unit
	local torsoZAxis = torso.CFrame:vectorToWorldSpace(Vector3.new(0, 0, 1)).unit
	lowerBound = nil
	upperBound = nil
	-- create bounding box for blinking
	charChildren = vChar:GetChildren()
	for i = 1, #charChildren do
		local handle = nil
		if charChildren[i]:IsA("Accessory") or charChildren[i].className == "Tool" then
			handle = charChildren[i]:FindFirstChild("Handle")
		elseif charChildren[i].className == "Part" then
			handle = charChildren[i]
		end
		if handle ~= nil then
			lowCornerTC = handle.CFrame:vectorToWorldSpace(-handle.Size / 2) + handle.Position - torso.Position
			highCornerTC = handle.CFrame:vectorToWorldSpace(handle.Size / 2) + handle.Position - torso.Position
			if lowerBound == nil then lowerBound = lowCornerTC end
			if upperBound == nil then upperBound = highCornerTC end
			lowerBound = Vector3.new(math.min(lowerBound.X, lowCornerTC.X), math.min(lowerBound.Y, lowCornerTC.Y), math.min(lowerBound.Z, lowCornerTC.Z))
			upperBound = Vector3.new(math.max(upperBound.X, lowCornerTC.X), math.max(upperBound.Y, lowCornerTC.Y), math.max(upperBound.Z, lowCornerTC.Z))
			lowerBound = Vector3.new(math.min(lowerBound.X, highCornerTC.X), math.min(lowerBound.Y, highCornerTC.Y), math.min(lowerBound.Z, highCornerTC.Z))
			upperBound = Vector3.new(math.max(upperBound.X, highCornerTC.X), math.max(upperBound.Y, highCornerTC.Y), math.max(upperBound.Z, highCornerTC.Z))
		end
	end
end


function onActivated()
	if not Tool.Enabled then return end
	if torso == nil or vChar == nil then return end
	local head = vChar:FindFirstChild("Head")
	if head then
		local torsoPos = torso.Position
		local headPos = head.Position
		hum = vChar:FindFirstChild("Humanoid")
		if hum == nil then return end
		Tool.Enabled = false
		getAABB()
		print(lowerBound)
		print(upperBound)
		hum.WalkSpeed = 0
		--hum.Jump = true

		local newBG = torso:FindFirstChild("TinyFloat")
		if newBG == nil then
			newBG = Instance.new("BodyPosition")
			newBG.position = torso.Position + Vector3.new(0, 0.5, 0)
			newBG.P = 1000000
			newBG.maxForce = Vector3.new(0, newBG.P, 0)
			newBG.Name = "TinyFloat"
			newBG.Parent = torso
		end

		-- changed torsoPos for headPos here...
		local teleportSpot = hum.TargetPoint * Vector3.new(1, 0, 1) + Vector3.new(0, headPos.Y, 0)
		local teleportDir = (teleportSpot - headPos).unit
			--local highTeleportSpot = teleportSpot + Vector3.new(0, (upperBound.Y - lowerBound.Y)/2, 0)  -- allow for slight height gain in blinking
		
		local charWidth = upperBound.Z - lowerBound.Z
		local teleRise = upperBound.Y - lowerBound.Y

		tZ = teleportDir
		tY = Vector3.new(0, 1, 0)
		tX = tZ:Cross(tY).unit

		blinkSound:Play()
		local smoker = Instance.new("Part")
		smoker.Name = "NinjaSmoke"
		smoker.Transparency = 1
		smoker.CanCollide = false
		smoker.Anchored = true
		smoker.CFrame = torso.CFrame - Vector3.new(0, 4, 0)
		smoker.Parent = game.Workspace

		local smoke = Instance.new("Smoke")
		smoke.Name = "smoke"
		smoke.Color = Color3.new(.3,0,.3)
		smoke.Opacity = .9
		smoke.RiseVelocity = 2
		smoke.Parent = smoker

		local smoke2 = Instance.new("Smoke")
		smoke2.Name = "smoke2"
		smoke2.Color = Color3.new(.5, 0, .5)
		smoke2.Opacity = .8
		smoke2.RiseVelocity = 3
		smoke2.Parent = smoker

		local collision = false
		local parts = {}
		for i = maxRange, charWidth, -charWidth do ---charWidth/2 do
			teleportSpot = torsoPos + i*teleportDir
			parts = game.Workspace:FindPartsInRegion3(Region3.new(teleportSpot+lowerBound, teleportSpot+upperBound), vChar, 100)
			collision = false
			for p = 1, #parts do
				if parts[p] ~= nil and parts[p].CanCollide then collision = true break end
			end
			if not collision then
				-- teleport!!
				wait(1)
				hum.WalkSpeed = 16
				if newBG ~= nil then newBG:Destroy() end
				torso.CFrame = CFrame.new(teleportSpot, teleportSpot+tZ)
				--torso.CFrame = CFrame.new(teleportSpot+tZ*(upperBound.Z - lowerBound.Z)/2, teleportSpot+tZ*(upperBound.Z-lowerBound.Z))
				break
			end

			-- try lifting teleportSpot a bit before discounting it as blocked
			teleportSpot = teleportSpot + Vector3.new(0, teleRise, 0)
			parts = game.Workspace:FindPartsInRegion3(Region3.new(teleportSpot+lowerBound, teleportSpot+upperBound), vChar, 100)
			collision = false
			for p = 1, #parts do
				if parts[p] ~= nil and parts[p].CanCollide then collision = true break end
			end
			if not collision then
				-- teleport!!
				wait(1)
				hum.WalkSpeed = 16
				if newBG ~= nil then newBG:Destroy() end
				torso.CFrame = CFrame.new(teleportSpot, teleportSpot+tZ)
				--torso.CFrame = CFrame.new(teleportSpot+tZ*(upperBound.Z - lowerBound.Z)/2, teleportSpot+tZ*(upperBound.Z-lowerBound.Z))
				break
			end
		end
		smoker.smoke.RiseVelocity = .5
		smoker.smoke2.RiseVelocity = .75
		wait(1)
		smoker:Destroy()
		hum.WalkSpeed = 16
		if newBG ~= nil then newBG:Destroy() end
		Tool.Enabled = true
	end
end

Tool.Equipped:connect(onEquipped)
Tool.Activated:connect(onActivated)

