function CreatePlane()
	local m = Instance.new("Model")
	m.Name = "PaperPlane"
	script.Parent.Handle:clone().Parent = m
	return m
end

function SetHandleTransparency(amt)
	script.Parent.Handle.Transparency = amt
end

local dropped = false
local equipped = false
local gui = nil
local player = nil

local plane = nil

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

script.Parent.Equipped:connect(function(mouse)
	script.Parent.Handle.Float.force = Vector3.new(0, 392.4, 0)
	equipped = true
	player = game.Players:GetPlayerFromCharacter(script.Parent.Parent)
	gui = script.Parent.RCPlaneGui:Clone() --Fix implemented by Luckymaxer
	gui.Parent = player.PlayerGui	
	wait() 
	local fail = script.Parent.CamFocusFailsafe:clone()
	fail.Disabled = false
	fail.Tool.Value = script.Parent
	fail.Target.Value = player.Character.Humanoid
	--put in character
	fail.Parent = script.Parent.Parent
	---
	local turnpressed = false
	---
	gui.MainFrame.ThrowPlane.MouseButton1Down:connect(function()
		if plane then
			plane.Parent = nil
			plane = nil
		else
			plane = CreatePlane()
			plane.Handle.creator.Value = player
			plane.Parent = game.Workspace
			do
				local cf = script.Parent.Handle.CFrame
				plane.Handle.CFrame = CFrame.new(cf.p, cf.p + Vector3.new(cf.lookVector.x, 0, cf.lookVector.z))
			end
			local pplane = plane
			pplane.Handle.Touched:connect(function(part)
				if part.Parent ~= player.Character and part.Parent ~= script.Parent and part.Parent ~= pplane then
					pplane.Parent = nil
					plane = nil
				end
			end)	
			--
			local s = Instance.new("StringValue")
			s.Name = "toolanim"
			s.Value = "Slash"
			s.Parent = script.Parent
			--
			gui.MainFrame.ThrowPlane.TXT.Text = "End Flight"
			gui.MainFrame.ThrowPlane.Image = "http://www.roblox.com/asset/?id=68871964"
			SetHandleTransparency(1)
			script.Parent.CamFocus.Value = pplane.Handle
			pplane.Handle.Fly.maxForce = Vector3.new(4000, 0, 4000)
			pplane.Handle.Velocity = Vector3.new(0, 0, 0)
			local duration = 30
			while plane and duration > 0 do
				pplane.Handle.Fly.velocity = pplane.Handle.CFrame.lookVector * 15
				pplane.Handle.Bank.maxTorque = Vector3.new(40000, 0, 40000)
				local cf = pplane.Handle.CFrame
				pplane.Handle.Bank.cframe = CFrame.new(cf.p, cf.p+Vector3.new(cf.lookVector.x, 0, cf.lookVector.z))*CFrame.fromEulerAnglesXYZ(0, 0, pplane.Handle.RotVelocity.y*0.5)
				wait()
				duration = duration - wait()
			end
			if not equipped then return end
			SetHandleTransparency(0)
			script.Parent.CamFocus.Value = nil
			gui.MainFrame.ThrowPlane.TXT.Text = "Throw Plane"	
			gui.MainFrame.ThrowPlane.Image = "http://www.roblox.com/asset/?id=68381539"
		end
	end)
	gui.MainFrame.TurnLeft.MouseButton1Down:connect(function()
		if plane then
			plane.Handle.Turn.angularvelocity = Vector3.new(0, 1.2, 0)
		end	
	end)
	gui.MainFrame.TurnLeft.MouseButton1Up:connect(function()
		if plane then
			plane.Handle.Turn.angularvelocity = Vector3.new(0, 0, 0)
		end
	end)	
	gui.MainFrame.TurnRight.MouseButton1Down:connect(function()
		if plane then
			plane.Handle.Turn.angularvelocity = Vector3.new(0, -1.2, 0)			
		end
	end)
	gui.MainFrame.TurnRight.MouseButton1Up:connect(function()
		if plane then
			plane.Handle.Turn.angularvelocity = Vector3.new(0, 0, 0)
		end
	end)	
	if mouse then 	
		mouse.KeyDown:connect(function(key) 
			key = key:lower()
			if key == "a" then 
				if plane then 
					plane.Handle.Turn.angularvelocity = Vector3.new(0, 1.2, 0)
				end 
			elseif key == "d" then 
				if plane then 
					plane.Handle.Turn.angularvelocity = Vector3.new(0, -1.2, 0)
				end 
			end 
		end)
		
		mouse.KeyUp:connect(function(key) 
			key = key:lower()
			if key == "a" then 
				if plane then 
					plane.Handle.Turn.angularvelocity = Vector3.new(0, 0, 0)
				end 
			elseif key == "d" then 
				if plane then 
					plane.Handle.Turn.angularvelocity = Vector3.new(0, 0, 0)
				end 
			end 
		end)
	end 
end)

script.Parent.Unequipped:connect(function()
	equipped = false
	SetHandleTransparency(0)
	script.Parent.Handle.Float.force = Vector3.new(0, 0, 0)
	if plane then 
		plane.Parent = nil
		plane = nil
	end
	script.Parent.CamFocus.Value = nil
	if gui then
		gui:remove()
		gui = nil
	end
end)
