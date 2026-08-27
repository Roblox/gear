local Player = game:GetService("Players").LocalPlayer
local UIS = game:GetService("UserInputService")
local Mouse = Player:GetMouse()
local Tool = script.Parent
local Remote = Tool:WaitForChild("Remote")
local Tracks = {}
local InputType = Enum.UserInputType
local RenderStepped = game:GetService("RunService").RenderStepped

local BeganConnection, EndedConnection

function playAnimation(animName, ...)
	if Tracks[animName] then
		Tracks[animName]:Play()
	else
		local anim = Tool:FindFirstChild(animName)
		if anim and Tool.Parent and Tool.Parent:FindFirstChild("Humanoid") then
			Tracks[animName] = Tool.Parent.Humanoid:LoadAnimation(anim)
			playAnimation(animName, ...)
		end
	end
end

function stopAnimation(animName)
	if Tracks[animName] then
		Tracks[animName]:Stop()
	end
end

function inputBegan(input)
	if input.UserInputType == InputType.MouseButton1 then
		Remote:FireServer("LeftDown")
	end
end

function inputEnded(input)
	if input.UserInputType == InputType.MouseButton1 then
		Remote:FireServer("LeftUp")
	end
end

function getFluteFrame(flute)
	return flute.CFrame * CFrame.Angles(-math.pi/2, 0, 0) * CFrame.new(0, 2, 8)
end

function fade(outTime, pauseTime, inTime)
	local sg = Instance.new("ScreenGui")
	sg.Parent = Player.PlayerGui
	
	local fg = Instance.new("Frame")
	fg.Size = UDim2.new(3, 0, 3, 0)
	fg.Position = UDim2.new(-1, 0, -1, 0)
	fg.BackgroundColor3 = Color3.new(0, 0, 0)
	fg.BackgroundTransparency = 1
	fg.Parent = sg
	
	spawn(function()
		local t = tick()
		
		while fg.BackgroundTransparency > 0 do
			local now = tick()
			local dt = now - t
			t = now
			
			fg.BackgroundTransparency = fg.BackgroundTransparency - (1 / outTime) * dt
			
			RenderStepped:wait()
		end
		
		wait(pauseTime)
		
		while fg.BackgroundTransparency < 1 do
			local now = tick()
			local dt = now - t
			t = now
			
			fg.BackgroundTransparency = fg.BackgroundTransparency + (1 / inTime) * dt
			
			RenderStepped:wait()
		end
		
		sg:Destroy()
	end)
end

function onFluteLaunch(flute)
	local origCam = workspace.CurrentCamera:Clone()
	
	local bv = Instance.new("BodyVelocity", flute)
	bv.maxForce = Vector3.new(1e9, 1e9, 1e9)
	bv.velocity = Vector3.new()
	
	local bg = Instance.new("BodyGyro", flute)
	bg.maxTorque = Vector3.new(1e9, 1e9, 1e9)
	
	local speed = 8
	local maxSpeed = 256
	local acceleration = 32
	
	local cam = Instance.new("Camera")
	cam.CameraType = "Scriptable"
	cam.CoordinateFrame = origCam.CoordinateFrame
	cam.Parent = workspace
	workspace.CurrentCamera = cam
	
	cam:Interpolate(getFluteFrame(flute), CFrame.new(), 1.5)
	fade(0.75, 0.8, 0.25)
	wait(1.5)

	local sound = flute.Thrust
	sound.Parent = workspace
	sound:Play()
	
	--remove the sound on death
	local connection
	connection = Player.Character.Humanoid.Died:connect(function()
		sound:Destroy()
		connection:disconnect()
	end)
	
	local t = tick()
	while flute.Parent and not flute.Anchored do
		local now = tick()
		local dt = now - t
		t = now
		
		local left = (Mouse.ViewSizeX - Mouse.ViewSizeY) / 2
		local nx = (Mouse.X - left) / Mouse.ViewSizeY - 0.5
		local ny = Mouse.Y / Mouse.ViewSizeY - 0.5
		
		bg.cframe = CFrame.Angles(-ny, 0, nx)
		bv.velocity = (flute.CFrame * CFrame.Angles(-math.pi/2, 0, 0)).lookVector * speed
		cam.CoordinateFrame = getFluteFrame(flute)
		
		speed = speed + acceleration * dt
		if speed > maxSpeed then
			speed = maxSpeed
		end
		
		sound.Pitch = 0.5 + (speed / maxSpeed)
		
		RenderStepped:wait()
	end
	
	sound:Destroy()
	
	wait(1.5)
	
	origCam.Parent = workspace
	origCam.CameraType = "Custom"
	origCam.CameraSubject = Player.Character.Humanoid
	workspace.CurrentCamera = origCam
end

function onRemote(func, ...)
	if func == "PlayAnimation" then
		playAnimation(...)
	elseif func == "StopAnimation" then
		stopAnimation(...)
	elseif func == "FluteLaunch" then
		onFluteLaunch(...)
	end
end

function onEquip()
	BeganConnection = UIS.InputBegan:connect(inputBegan)
	EndedConnection = UIS.InputEnded:connect(inputEnded)
end

function onUnequip()
	if BeganConnection then
		BeganConnection:disconnect()
		BeganConnection = nil
	end
	
	if EndedConnection then
		EndedConnection:disconnect()
		EndedConnection = nil
	end
end

Tool.Equipped:connect(onEquip)
Tool.Unequipped:connect(onUnequip)
Remote.OnClientEvent:connect(onRemote)