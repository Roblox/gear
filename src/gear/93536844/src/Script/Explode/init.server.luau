local Model = script.Parent

local BodyColors = Model:FindFirstChild('Body Colors')
if BodyColors then -- Make BodyColors red
	local red = BrickColor.new('Bright red')
	BodyColors.HeadColor = red
	BodyColors.LeftArmColor = red
	BodyColors.LeftLegColor = red
	BodyColors.RightArmColor = red
	BodyColors.RightLegColor = red
	BodyColors.TorsoColor = red
end

local HeadMesh = nil
do -- Find HeadMesh
	local head = Model:FindFirstChild('Head')
	if head then
		HeadMesh = head:FindFirstChild('Mesh')
	end
end

-- Head flashy
if HeadMesh then
	local color = HeadMesh.VertexColor
	local red = Vector3.new(2, 0, 0)
	local function flashy(howLong)
		HeadMesh.VertexColor = red
		wait(howLong)
		HeadMesh.VertexColor = color
		wait(howLong)
	end
	local flashTime = 1
	while flashTime > 0.025 do
		flashy(flashTime)
		flashTime = flashTime * 0.75
	end
else
	wait(3)
end

Instance.new('Explosion', Workspace).Position = Model:GetModelCFrame().p

local BoomSound = script:FindFirstChild('Boom')
if BoomSound then
	local torso = Model:FindFirstChild('Torso')
	if torso then
		BoomSound.Parent = torso
	end
	BoomSound:Play()
end
