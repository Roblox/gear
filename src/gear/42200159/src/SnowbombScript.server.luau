local numSnowBalls = 10

local mySparks = Instance.new("Sparkles")
mySparks.Parent = script.Parent

local hitsounds = {"19326853", "19326880", "19326891"}

local HitSound = Instance.new("Sound")
HitSound.SoundId = "http://www.roblox.com/asset/?id=" .. hitsounds[math.random(1,#hitsounds)]
HitSound.Parent = script.Parent
HitSound.Volume = 1
HitSound:Play()

wait(5)
mySparks:remove()

local sound = Instance.new("Sound")
		sound.SoundId = "rbxasset://sounds\\Rocket shot.wav"
		sound.Parent = script.Parent
		sound.Volume = 1
		sound:play()

local snowBalls = {}
script.Parent.Transparency = 1
script.Parent.CanCollide = false
for i = 1, numSnowBalls do
	newSnowball = script.Parent.Snowball:Clone()
	newSnowball.CFrame = script.Parent.CFrame
	newSnowball.Transparency = 0
	newSnowball.CanCollide = true
	newSnowball.Anchored = false
	newSnowball.Velocity = Vector3.new(100*(math.sin(2*math.pi*i/numSnowBalls)), 20, 100*(math.cos(2*math.pi*i/numSnowBalls)))
	newSnowball.CFrame = newSnowball.CFrame + newSnowball.Velocity/50 + Vector3.new(0,1,0)
	script.Parent.SnowballScript:Clone().Parent = newSnowball
	newSnowball.SnowballScript.Disabled = false
	newSnowball.Parent = game.Workspace
end

script.Parent:remove()
