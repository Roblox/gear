local accel = 1.6 -- 0.8
local angleAccel = 2.4 -- 1.2

wait(0.5)

local throwPlane = nil
local GPAcceleration = 0
local GPPoint = Vector3.new()

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

script.Parent.GuiEvent.OnServerEvent:connect(function(client, action, event)
	if client.Character == script.Parent.Parent then
		if action == 'ThrowPlane' then
			if event == 'Button1Down' then
				if throwPlane then
					throwPlane()
				end
			end
		end
	end
end)

function CreatePlane()

	
	--This call will cause a "wait" until the data comes back
	--[[local root = game:GetService("InsertService"):LoadAsset(31184482)

	local instances = root:GetChildren()
	if #instances == 0 then
		root:Remove()
		return nil
	end

	root = root:FindFirstChild("RCCar")
	root.Name = "RCCar"
	]]--

	local root = require(215583981):Clone()
	root.Name = "RCCar"
	root.Transparency = 0
	root.Anchored = false
	root.CanCollide = true

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

script.Parent.Equipped:connect(function()

	script.Parent.Handle.Float.force = Vector3.new(0, 392, 0)
	equipped = true
	player = game.Players:GetPlayerFromCharacter(script.Parent.Parent)
	gui = script.Parent.PaperPlaneGui:clone()
	gui.Parent = player.PlayerGui
	script.Parent.StartGuiEvents:FireClient(player, gui)
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
	throwPlane = function()
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
					player.Character.Torso.Humanoid.Anchored = false
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
	end
end)

script.Parent.Input.OnServerEvent:connect(function(client, key, down)
	if client.Character == script.Parent.Parent then
		(down and onKeyDown or onKeyUp)(key) -- mmm
	end
end)

script.Parent.GamepadInput.OnServerEvent:connect(function(client, type, ...)
	if client.Character == script.Parent.Parent then
		if type == 'Acceleration' then
			GPAcceleration = ...
			local gpaDead = GPAcceleration.unit * (GPAcceleration.magnitude > 0.25 and GPAcceleration.magnitude or 0)
			
			plane.Turn.angularVelocity = Vector3.new(0, gpaDead.x*angleAccel, 0)
		elseif type == 'Thumbstick1' then
			GPPoint = ...
			
			if GPPoint > 0 and not gasDown then
				gasDown = true
				gui.MainFrame.Gas.Selected = true
				while gasDown do
					if velocityConstant < math.min(maxForwardSpeed, maxForwardSpeed*GPPoint) then
						velocityConstant = velocityConstant + accel
					end
					wait(0.03)
				end
			elseif GPPoint <= 0 and gasDown then
				gui.MainFrame.Gas.Selected = false
				gasDown = false
			end
		end
	end
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
		if throwPlane then throwPlane=nil end
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
end)
