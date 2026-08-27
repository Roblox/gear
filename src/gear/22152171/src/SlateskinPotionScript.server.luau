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

local StoneSound = Instance.new("Sound")
StoneSound.Name = "Slateskin"
StoneSound.SoundId = "http://www.roblox.com/asset/?id=11450310"
StoneSound.Volume = 1
StoneSound.Parent = Tool.Handle


function slateMe(character)
	local shirt = character:FindFirstChild("Shirt")
	local pants = character:FindFirstChild("Pants")

	if (shirt ~= nil) then shirt:Remove() end
	if (pants ~= nil) then pants:Remove() end

	local c = character:GetChildren()
	for i=1,#c do
		if (c[i].className == "Part") then
			c[i].Material = Enum.Material.Slate
			c[i].BrickColor = BrickColor.new(38)
		end
		if (c[i].className == "Humanoid") then
			c[i].WalkSpeed = c[i].WalkSpeed * .9
			c[i].MaxHealth = 150
		end
	end
end

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
	DrinkSound:Remove()
	wait(3)
	
	StoneSound:Play()
	local h = Tool.Parent:FindFirstChild("Humanoid")
	if (h ~= nil) then
		slateMe(h.Parent)
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
	
	Tool.Parent.Torso["Right Shoulder"].MaxVelocity = 0.7
	Tool.Parent.Torso["Right Shoulder"].DesiredAngle = 3.6
	wait(.1)
	Tool.Parent.Torso["Right Shoulder"].MaxVelocity = 1

	local dir = h.Parent.Head.CFrame.lookVector
	p.Velocity = (dir * 45) + Vector3.new(0,45,0)
	p.CanCollide = true
	Tool.Glass.Parent = p
	p.Glass.Disabled = false
	p.Parent = game.Workspace


	script.Parent:Remove()

end

function onEquipped()
	--Tool.Handle.OpenSound:play()
end

script.Parent.Activated:connect(onActivated)
script.Parent.Equipped:connect(onEquipped)
