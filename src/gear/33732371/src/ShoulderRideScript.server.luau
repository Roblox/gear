local Tool = script.Parent;

enabled = true
local riding = false

s1 = Instance.new("Sound")
s1.SoundId = "http://www.roblox.com/asset/?id=33722410"
s1.Parent = Tool.Handle

s2 = Instance.new("Sound")
s2.SoundId = "http://www.roblox.com/asset/?id=33722464"
s2.Parent = Tool.Handle

s3 = Instance.new("Sound")
s3.SoundId = "http://www.roblox.com/asset/?id=33722497"
s3.Parent = Tool.Handle

s4 = Instance.new("Sound")
s4.SoundId = "http://www.roblox.com/asset/?id=33722522"
s4.Parent = Tool.Handle

s5 = Instance.new("Sound")
s5.SoundId = "http://www.roblox.com/asset/?id=33722614"
s5.Parent = Tool.Handle

s6 = Instance.new("Sound")
s6.SoundId = "http://www.roblox.com/asset/?id=33722645"
s6.Parent = Tool.Handle

s7 = Instance.new("Sound")
s7.SoundId = "http://www.roblox.com/asset/?id=33722676"
s7.Parent = Tool.Handle

s8 = Instance.new("Sound")
s8.SoundId = "http://www.roblox.com/asset/?id=33722692"
s8.Parent = Tool.Handle

s9 = Instance.new("Sound")
s9.SoundId = "http://www.roblox.com/asset/?id=33722731"
s9.Parent = Tool.Handle

s10 = Instance.new("Sound")
s10.SoundId = "http://www.roblox.com/asset/?id=33722758"
s10.Parent = Tool.Handle


local goSayings = {s1,s2,s3,s4,s5,s6}
local noGoSayings = {s9,s10}
local putAwaySayings = {s7,s8}
local allSayings = {s1, s2, s3, s4, s5, s6, s7, s8, s9, s10}
local multiClicks = 0

function onActivated()
	if not enabled  then
		return
	end

	enabled = false
	multiClicks = multiClicks + 1
	
	if multiClicks > 10 then
		noGoSayings[math.random(1,#noGoSayings)]:Play()
		wait(5.5)
	elseif not riding then
		riding = true
		Tool.GripForward = Vector3.new(-0, 0, 1)		
		Tool.GripPos = Vector3.new(2.8,0.7,1.0)
		Tool.GripRight = Vector3.new(1, 0, 0)
		Tool.GripUp = Vector3.new(0, -1, 0)

		goSayings[math.random(1,#goSayings)]:Play()
		wait(2)
	else
		riding = false
		Tool.GripForward = Vector3.new(-0, 0, 1)
		Tool.GripPos = Vector3.new(0.36, 0.0, -0.4)
		Tool.GripRight = Vector3.new(1, 0, 0)
		Tool.GripUp = Vector3.new(0, -1, 0)

		putAwaySayings[math.random(1,#putAwaySayings)]:Play()
		wait(2)
	end
	
	enabled = true
	wait(22)
	multiClicks = multiClicks - 1
end

function onEquipped()
	for i=1,#allSayings do
		allSayings[i].Volume = 1
	end
end

function onUnequipped()
	for i=1,#allSayings do
		allSayings[i].Volume = 0
	end
end

script.Parent.Activated:connect(onActivated)
script.Parent.Equipped:connect(onEquipped)
script.Parent.Unequipped:connect(onUnequipped)
