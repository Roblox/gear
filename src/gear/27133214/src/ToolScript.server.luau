local dropped = false
local equipped = false
local gui = nil
local player = nil
local look = nil
local whereToZoom = nil
local zoomFactor = 20
local balance = 0
local initPos = nil
local bodyPos = nil
local binocBodyPos = nil
local binocPoint = nil
local animup = nil

function createBinocPoint(h)

	whereToZoom = h.CFrame.lookVector.unit

	binocPoint = Instance.new("Part")
	binocPoint.Size = Vector3.new(1,1,1)
	binocPoint.Transparency = 1
	binocPoint.CFrame = h.CFrame
	binocPoint.Parent = game.Workspace
	binocPoint.Position = Vector3.new(h.Position.x,h.Position.y,h.Position.z) + (whereToZoom * 17)
	binocPoint.CanCollide = false

	binocBodyPos = Instance.new("BodyPosition")
	binocBodyPos.P = 10000
	binocBodyPos.D = 1000
	binocBodyPos.maxForce = Vector3.new(10000,10000,10000)
	binocBodyPos.position = binocPoint.Position
	binocBodyPos.Parent = binocPoint

	local binocBodyGyro = Instance.new("BodyGyro")
	binocBodyGyro.cframe = binocPoint.CFrame
	binocBodyGyro.P = 100000
	binocBodyGyro.D = 1
	binocBodyGyro.maxTorque = Vector3.new(100000,100000,100000)
	binocBodyGyro.Parent = binocPoint
	
	local sound = script.Parent.Handle.zoomOut:clone()
	sound.Parent = binocPoint
end

script.Parent.Changed:connect(function(pr)
	if pr == "Parent" then
		if script.Parent.Parent == game.Workspace then --dropped
			dropped = true	
			script.Parent.Handle.CanCollide = true
		elseif dropped then
			dropped = false
			script.Parent.Handle.CanCollide = false
		end
	end
end)

script.Parent.Equipped:connect(function()
	equipped = true
	player = game.Players:GetPlayerFromCharacter(script.Parent.Parent)
	gui = script.Parent.BinocGui:clone() --Fix implemented by Luckymaxer
	gui.Parent = player.PlayerGui
	-- enable failsafe
	wait() --needed, strange error occurs when no wait is put here
	local fail = script.Parent.CamFocusFailsafe:clone()
	fail.Disabled = false
	fail.Tool.Value = script.Parent
	fail.Target.Value = player.Character.Humanoid
	--put in character
	fail.Parent = script.Parent.Parent
	---
	local turnpressed = false
	---
	gui.ActivateFrame.Activate.MouseButton1Down:connect(function()
		gui.ActivateFrame.Activate.Visible = false
		gui.ActivateFrame.Deactivate.Visible = true
		gui.ControlsFrame.Visible = true
		gui.BinocFrame.Visible = true
		
		local torso = script.Parent.Parent:FindFirstChild("Torso", false)
		local head = script.Parent.Parent:FindFirstChild("Head", false)
		createBinocPoint(head)
		script.Parent.CamFocus.Value = binocPoint
		initPos = torso.Position

		bodyPos = Instance.new("BodyPosition")
		bodyPos.position = torso.Position
		bodyPos.maxForce = Vector3.new(90000,90000,90000)
		bodyPos.P = 90000
		bodyPos.D = 10
		bodyPos.Name = "bodyPos"
		bodyPos.Parent = torso

		humanoid = script.Parent.Parent:FindFirstChild("Humanoid", false)
		script.Parent.GripPos = Vector3.new(1.5,-1.3,-0.3)

		local head = script.Parent.Parent:FindFirstChild("Head", false)
		look = head.CFrame.lookVector.unit
	end)

	gui.ActivateFrame.Deactivate.MouseButton1Down:connect(function()
		gui.ActivateFrame.Activate.Visible = true
		gui.ActivateFrame.Deactivate.Visible = false
		gui.BinocFrame.Visible = false
		gui.ControlsFrame.Visible = false
		script.Parent.CamFocus.Value = nil

		if bodyPos then
			bodyPos:remove()
			bodyPos = nil
		end
		script.Parent.GripPos = Vector3.new(0, 0, 0.7)
		binocPoint:remove()
		balance = 0
	end)

	gui.ControlsFrame.PanLeft.MouseButton1Down:connect(function()

		if binocPoint and balance > -1 then
			balance = balance - 1
			local leftX = (look.x * math.cos(-math.pi/2)) - (look.z * math.sin(-math.pi/2))
			local leftZ = (look.x * math.sin(-math.pi/2)) - (look.z * math.cos(-math.pi/2))
			binocBodyPos.position = Vector3.new(binocPoint.Position.x + (leftX* zoomFactor),
				binocPoint.Position.y,binocPoint.Position.z  + (leftZ* zoomFactor))
		end

	end)
	gui.ControlsFrame.PanRight.MouseButton1Down:connect(function()

		if binocPoint and balance < 1 then
			balance = balance + 1
			local rightX = (look.x * math.cos(math.pi/2)) - (look.z * math.sin(math.pi/2))
			local rightZ = (look.x * math.sin(math.pi/2)) - (look.z * math.cos(math.pi/2))
			binocBodyPos.position = Vector3.new(binocPoint.Position.x + (rightX * zoomFactor) ,
				binocPoint.Position.y,binocPoint.Position.z + (rightZ* zoomFactor))
		end

	end)
	gui.ControlsFrame.ZoomIn.MouseButton1Down:connect(function()

		if binocPoint then
			
			local diff = Vector2.new(binocPoint.Position.x - initPos.x,binocPoint.Position.z - initPos.z)
			if diff.magnitude < 150 then
				binocPoint.zoomOut:Play()
				binocBodyPos.position = Vector3.new(binocPoint.Position.x + (whereToZoom.x * zoomFactor),
					binocPoint.Position.y,binocPoint.Position.z + (whereToZoom.z * zoomFactor))
			end
		end

	end)
	gui.ControlsFrame.ZoomOut.MouseButton1Down:connect(function()

		if binocPoint then

			xMag = binocPoint.Position.x - initPos.x
			zMag = binocPoint.Position.z - initPos.z
			totalDist = xMag + zMag
			if totalDist > 60 then
				binocPoint.zoomOut:Play()
				binocBodyPos.position = Vector3.new(binocPoint.Position.x + (whereToZoom.x * -zoomFactor), 
					binocPoint.Position.y,binocPoint.Position.z + (whereToZoom.z * -zoomFactor))
			end

		end

	end)

end)

script.Parent.Unequipped:connect(function()
	equipped = false
	script.Parent.CamFocus.Value = nil
	if bodyPos then
		bodyPos:remove()
		bodyPos = nil
	end
	if gui then
		gui:remove()
		gui = nil
	end
end)
