local egg = script.Parent
local debris = game:GetService("Debris")

local fuseSound = Instance.new("Sound")
fuseSound.SoundId = "http://www.roblox.com/asset/?id=13378571"
fuseSound.Parent = script.Parent
fuseSound:Play()

wait(3.0)

local sound = Instance.new("Sound") 
sound.SoundId = "rbxasset://sounds\\Rocket shot.wav" 
sound.Parent = script.Parent 
sound.Volume = 1 
sound:play() 

local e = Instance.new("Explosion")
e.Name ="EXPLODE"
e.Parent = game.Workspace
e.Position = egg.Position
e.BlastPressure = 500000
e.BlastRadius = 7.5

debris:addItem(e, 2.0)

if egg then egg:Remove() end
