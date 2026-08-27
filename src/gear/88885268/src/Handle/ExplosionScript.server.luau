local Handle = script.Parent

function createUKExplosion(startPos)
	local throwersLocation = Vector3.new()
	if Handle:FindFirstChild('vCharacterLoc') then
		throwersLocation = Handle.vCharacterLoc.Value
	end
	-- Create a rotation matrix such that the explosion is oriented towards the player
	-- multiply rotation matrix * position so that the letters position will be rotated
	local rotationCFrame = CFrame.new(startPos, startPos + (startPos - throwersLocation))  -- vTorso.CFrame.p))
	-- this is the distance between explosions, think of it as if explosions were pixels in a pixelated font
	local pixelSize = 24
	-- The distance from the start of U to the start of K
	local kOffset = pixelSize * 8
	-- Create the U
	for i = 1, 5 do
		-- left side of U
		local explosion = Instance.new('Explosion', Workspace)
		explosion.Position = rotationCFrame * (Vector3.new(0,-1 * pixelSize * i, 0))-- + startPos)
		explosion.BlastPressure = 0
		-- right side of U
		local explosion2 = Instance.new('Explosion', Workspace)
		explosion2.Position = rotationCFrame * (Vector3.new(pixelSize * 4, -1 * pixelSize * i, 0))-- + startPos)
		explosion2.BlastPressure = 0
	end
	--Bottom of U
	local explosionBottomLeft = Instance.new('Explosion', Workspace)
	explosionBottomLeft.Position = rotationCFrame * (Vector3.new(pixelSize * 1, -1 * pixelSize * 6, 0))-- + startPos)
	explosionBottomLeft.BlastPressure = 0

	--Bottom of U
	local explosionBottomLeft = Instance.new('Explosion', Workspace)
	explosionBottomLeft.Position = rotationCFrame * (Vector3.new(pixelSize * 3, -1 * pixelSize * 6, 0))-- + startPos)
	explosionBottomLeft.BlastPressure = 0

	-- Bottom middle of U
	local explosionBottomLeft = Instance.new('Explosion', Workspace)
	explosionBottomLeft.Position = rotationCFrame * (Vector3.new(pixelSize * 2, -1 * pixelSize * 6, 0))-- + startPos)
	explosionBottomLeft.BlastPressure = 0

	-- Verticle part of K
	for i = 0, 7 do
		local explosion = Instance.new('Explosion', Workspace)
		explosion.Position = rotationCFrame * (Vector3.new(kOffset,-1 * pixelSize * i, 0))-- + startPos)
		explosion.BlastPressure = 0
	end
	local middleOfK = (-3 * pixelSize)
	-- Top angled part of K
	for i = 2, 4 do
		local explosion = Instance.new('Explosion', Workspace)
		explosion.Position = rotationCFrame * (Vector3.new(kOffset + pixelSize * i, middleOfK + pixelSize * i, 0))-- + startPos)
		explosion.BlastPressure = 0
	end

	-- Bottom angled part of K
	for i = 2, 4 do
		local explosion = Instance.new('Explosion', Workspace)
		explosion.Position = rotationCFrame * (Vector3.new(kOffset + pixelSize * i, middleOfK - pixelSize * i, 0))-- + startPos)
		explosion.BlastPressure = 0
	end

end

wait(5)

Handle.Transparency = 1.0

createUKExplosion(Handle.CFrame.p + Vector3.new(75, 80, 0)) --Vector3.new(0, 200, 0))
wait(0.5)
createUKExplosion(Handle.CFrame.p + Vector3.new(75, 80, 0)) --Vector3.new(0, 200, 0))
