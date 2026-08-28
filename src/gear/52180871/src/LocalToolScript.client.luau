local accel = 2.0
local angleAccel = 2.8

local firePart

wait(0.5)
script.Parent.CamFocus.Changed:connect(function()
	local o = script.Parent.CamFocus.Value
	if o then
		wait()
		game.Workspace.CurrentCamera.CameraType = 1
		game.Workspace.CurrentCamera.CameraSubject = o
	else
		wait()
		game.Workspace.CurrentCamera.CameraType = 5	
		game.Workspace.CurrentCamera.CameraSubject = game.Players.LocalPlayer.Character.Humanoid	
	end
end)

local mouseCon = nil

local startSound = Instance.new("Sound")
startSound.Name = "startSound"
startSound.SoundId = "http://www.roblox.com/asset/?id=31245452"
startSound:Play()

local idleSound = Instance.new("Sound")
idleSound.Name = "idleSound"
idleSound.SoundId = "http://www.roblox.com/asset/?id=31245465"
idleSound.Looped = true
idleSound:Play()

local hardStopSound = Instance.new("Sound")
hardStopSound.Name = "hardStopSound"
hardStopSound.SoundId = "http://www.roblox.com/asset/?id=31245495"
hardStopSound:Play()

local squealTires = hardStopSound:clone()
squealTires.Name = "squealTires"
squealTires.Looped = true

function CreatePlane()

	
	--This call will cause a "wait" until the data comes back
	local root = game:GetService("InsertService"):LoadAsset(52158011)

	local instances = root:GetChildren()
	if #instances == 0 then
		root:Remove()
		return nil
	end

	root = root:FindFirstChild("MonstaTruckHandle")
	root.Name = "RCMonsterTruck"

	startSound.Parent = root
	idleSound.Parent = root
	hardStopSound.Parent = root
	squealTires.Parent = root

	return root
end

local dropped = false
local equipped = false
local gui = nil
local player = nil
local velocityConstant = 0
local gasDown = false
local brakeDown = false
local plane =  nil

--local smoke = Instance.new("Smoke")

local friction = 0.97
local maxForwardSpeed = 100
local maxReverseSpeed = -60

local keyUp = nil
local keyDown = nil

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

function killSmoke()
	smoke.Parent = nil
	squealTires.Looped = false
	squealTires:Stop()
end

script.Parent.Equipped:connect(function(mouse) print("Connecting in Local Script")

	script.Parent.Handle.Float.force = Vector3.new(0, 392, 0)
	equipped = true
	player = game.Players:GetPlayerFromCharacter(script.Parent.Parent)
	gui = script.Parent.PaperPlaneGui:clone()
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
	mouseCon = gui.MainFrame.ThrowPlane.MouseButton1Down:connect(function()
		if plane then
			plane.Parent = nil
			plane = nil
			player.Character.Torso.Anchored = false
			if keyUp then keyUp:disconnect() end
			if keyDown then keyDown:disconnect() end
		else
			plane = CreatePlane()		
			player.Character.Torso.Anchored = true
			plane.AncestryChanged:connect(function(child,parent)
				if parent == nil then
					--player.Character.Torso.Humanoid.Anchored = false		
					player.Character.Torso.Anchored = false
					if keyUp then keyUp:disconnect() end
					if keyDown then keyDown:disconnect() end
					plane = nil
				end
			end)

			velocityConstant = 0
			gasDown = false
			brakeDown = false

			plane.Parent = game.Workspace
			startSound:Play()
			do
				plane.Position = script.Parent.Handle.Position + (-script.Parent.Handle.CFrame.lookVector * 5)
				local cf = script.Parent.Handle.CFrame
				plane.CFrame = CFrame.new(plane.Position, plane.Position + Vector3.new(-cf.lookVector.x, 0, -cf.lookVector.z))
				--plane.CFrame = CFrame.new(plane.Position, plane.Position + Vector3.new(-cf.lookVector.x, 0, -cf.lookVector.z))*CFrame.Angles(-math.pi/2,0,0)
			end
			local pplane = plane
			--
			keyDown = mouse.KeyDown:connect(onKeyDown)
			keyUp = mouse.KeyUp:connect(onKeyUp)
			script.Parent.Plane.Value = plane
			idleSound:Play()
		
			while plane do
				script.Parent.VelocityConstant.Value = velocityConstant
				velocityConstant = velocityConstant * friction
				wait()
			end

			if not equipped then return end
			script.Parent.CamFocus.Value = nil
			gui.MainFrame.ThrowPlane.TXT.Text = "Throw Plane"
		end
	end)
end)

function onKeyDown(key)
	key:lower()
	if key == "w" then
		gasDown = true
		gui.MainFrame.Gas.Selected = true
		while gasDown do
			if velocityConstant < maxForwardSpeed then
				velocityConstant = velocityConstant + accel
			end
			wait(0.03)
		end
	elseif key == "s" then
		brakeDown = true
		gui.MainFrame.Brake.Selected = true
		if velocityConstant > 0 and plane.Velocity.magnitude > 5 then
			hardStopSound.Volume = 1 * math.abs(velocityConstant/maxForwardSpeed)
			hardStopSound:Play()
		end
		while brakeDown do
			if velocityConstant > maxReverseSpeed then
				velocityConstant = velocityConstant - accel
			end
			wait(0.03)
		end
	elseif key == "a" then
		if plane then
			plane.Turn.angularvelocity = Vector3.new(0, plane.Turn.angularvelocity.y + angleAccel, 0)
			gui.MainFrame.TurnLeft.Selected = true
		end
	elseif key == "d" then
		if plane then
			plane.Turn.angularvelocity = Vector3.new(0, plane.Turn.angularvelocity.y - angleAccel, 0)
			gui.MainFrame.TurnRight.Selected = true
		end
	end

end

function onKeyUp(key)
	key:lower()
	if key == "w" then
		print(velocityConstant)
		gui.MainFrame.Gas.Selected = false
		gasDown = false
	elseif key == "s" then
		gui.MainFrame.Brake.Selected = false
		brakeDown = false
	elseif key == "a"then
		if plane then
			gui.MainFrame.TurnLeft.Selected = false
			plane.Turn.angularvelocity = Vector3.new(0, plane.Turn.angularvelocity.y - angleAccel, 0)
		end
	elseif key == "d" then
		if plane then
			gui.MainFrame.TurnRight.Selected = false
			plane.Turn.angularvelocity = Vector3.new(0, plane.Turn.angularvelocity.y + angleAccel, 0)
		end
	end
end

script.Parent.Unequipped:connect(function()
	if player ~= nil and player.Character ~= nil and player.Character:FindFirstChild("Torso") ~= nil then
		player.Character.Torso.Anchored = false
		if keyUp then keyUp:disconnect() end
		if keyDown then keyDown:disconnect() end
		if mouseCon then mouseCon:disconnect() end
		equipped = false
			if plane then 
			plane.Parent = nil
			plane = nil
		end
		script.Parent.CamFocus.Value = nil
		if gui then
			gui:remove()
			gui = nil
		end
	end
	if startSound then startSound:Stop() end
	if idleSound then idleSound:Stop() end
	if hardStopSound then hardStopSound:Stop() end
	if squealTires then squealTires:Stop() end
end)
