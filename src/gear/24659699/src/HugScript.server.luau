local Tool = script.Parent;

enabled = true



s1 = Instance.new("Sound")
s1.SoundId = "http://www.roblox.com/asset/?id=24477781"
s1.Parent = Tool.Handle

s2 = Instance.new("Sound")
s2.SoundId = "http://www.roblox.com/asset/?id=24477809"
s2.Parent = Tool.Handle

s3 = Instance.new("Sound")
s3.SoundId = "http://www.roblox.com/asset/?id=24478553"
s3.Parent = Tool.Handle

s4 = Instance.new("Sound")
s4.SoundId = "http://www.roblox.com/asset/?id=24483366"
s4.Parent = Tool.Handle

local sayings = {s1,s2,s3,s4}


function onActivated()
	if not enabled  then
		return
	end

	enabled = false
	
	Tool.GripForward = Vector3.new(0.0384, -0.128, 0.991)
	Tool.GripPos = Vector3.new(-2.3, -0.8, 0.5)
	Tool.GripRight = Vector3.new(-0.958, -0.287, 0)
	Tool.GripUp = Vector3.new(-0.285, 0.949, 0.134)

	sayings[math.random(1,#sayings)]:Play()
	wait(2)

	Tool.GripForward = Vector3.new(-0, 0, 1)
	Tool.GripPos = Vector3.new(0, -0.3, 0.4)
	Tool.GripRight = Vector3.new(1, 0, 0)
	Tool.GripUp = Vector3.new(0, 1, 0)

	
	enabled = true

end

function onEquipped()
	for i=1,#sayings do
		sayings[i].Volume = 1
	end
end

function onUnequipped()
	for i=1,#sayings do
		sayings[i].Volume = 0
	end
end

script.Parent.Activated:connect(onActivated)
script.Parent.Equipped:connect(onEquipped)
script.Parent.Unequipped:connect(onUnequipped)
