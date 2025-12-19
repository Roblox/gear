--Updated for R15 avatar by StarWars

local Tool = script.Parent;




local GlassBreak = Instance.new("Sound")
GlassBreak.Name = "GlassBreak"
GlassBreak.SoundId = "http://www.roblox.com/asset/?id=11415738"
GlassBreak.Volume = 1
GlassBreak.Parent = Tool.Handle

local DrinkSound = Instance.new("Sound")
DrinkSound.Name = "Drink"
DrinkSound.SoundId = "http://www.roblox.com/asset/?id=10722059"
DrinkSound.Volume = .5
DrinkSound.Parent = Tool.Handle

function onActivated()
	if not Tool.Enabled  then
		return
	end

	Tool.Enabled = false
	Tool.GripForward = Vector3.new(0,-.759,-.651)
	Tool.GripPos = Vector3.new(1.5,-.35,.1)
	Tool.GripRight = Vector3.new(1,0,0)
	Tool.GripUp = Vector3.new(0,.651,-.759)


	DrinkSound:Play()
	DrinkSound:Destroy()
	wait(3)
	
	local h = Tool.Parent:FindFirstChild("Humanoid")
	if (h ~= nil) then
		h.Health = h.MaxHealth
	else
		return
	end

	Tool.GripForward = Vector3.new(-.976,0,-0.217)
	Tool.GripPos = Vector3.new(0.1,0,.1)
	Tool.GripRight = Vector3.new(.217,0,-.976)
	Tool.GripUp = Vector3.new(0,1,0)

	wait(1)

	local p = Tool.Handle:Clone()
	GlassBreak.Parent = p
	p.Transparency = 0
	local Torso = Tool.Parent:FindFirstChild("Torso") or Tool.Parent:FindFirstChild("RightUpperArm")
	
	if Torso then
		local RightArm = Torso:FindFirstChild("Right Shoulder") or Torso:FindFirstChild("RightShoulder")
		if RightArm then
			RightArm.MaxVelocity = 0.7
			RightArm.DesiredAngle = 3.6
			wait(.1)
			RightArm.MaxVelocity = 1
		end
	end

	local dir = h.Parent.Head.CFrame.lookVector
	p.Velocity = (dir * 60) + Vector3.new(0,30,0)
	p.CanCollide = true
	Tool.Glass.Parent = p
	p.Glass.Disabled = false
	p.Parent = game.Workspace


	script.Parent:Destroy()

end

function onEquipped()
	--Tool.Handle.OpenSound:play()
end

script.Parent.Activated:connect(onActivated)
script.Parent.Equipped:connect(onEquipped)
