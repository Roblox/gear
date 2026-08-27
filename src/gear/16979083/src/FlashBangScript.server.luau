--Updated for R15 avatars by StarWars
local Tool = script.Parent;




local GlassBreak = Instance.new("Sound")
GlassBreak.Name = "GlassBreak"
GlassBreak.SoundId = "http://www.roblox.com/asset/?id=16976189"
GlassBreak.Volume = 1
GlassBreak.Parent = Tool.Handle





function onActivated()
	if not Tool.Enabled  then
		return
	end

	Tool.Enabled = false
	

	wait(1)
	
	local player = game.Players:GetPlayerFromCharacter(Tool.Parent)
	local h = Tool.Parent:FindFirstChild("Humanoid")
	if (h == nil or player == nil) then
		Tool.Enabled = true
		return
	end

	
	local Character = Tool.Parent
	local Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
	local RightArm = Character:FindFirstChild("Right Arm") or Character:FindFirstChild("RightUpperArm")
	local RightShoulder = Torso:FindFirstChild("Right Shoulder") or RightArm:FindFirstChild("RightShoulder")

	local p = Tool.Handle:Clone()
	GlassBreak.Parent = p
	p.Transparency = 0
	
	RightShoulder.MaxVelocity = 0.7
	RightShoulder.DesiredAngle = 3.6
	wait(.1)
	RightShoulder.MaxVelocity = 1

	local tosser = Instance.new("ObjectValue")
	tosser.Value = player
	tosser.Name = "Tosser"
	tosser.Parent = p

	local dir = h.Parent.Head.CFrame.lookVector
	p.Velocity = (dir * 45) + Vector3.new(0,45,0)
	p.CanCollide = true
	Tool.Glass:Clone().Parent = p
	p.Glass.Disabled = false
	p.Parent = game.Workspace

	wait(14)
	p.Transparency = 1
	Tool.Enabled = true

end

function onEquipped()
	--Tool.Handle.OpenSound:play()
end

script.Parent.Activated:connect(onActivated)
script.Parent.Equipped:connect(onEquipped)
