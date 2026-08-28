egg = script.Parent
debris = game:GetService("Debris")

FuseSound = Instance.new("Sound") 
FuseSound.SoundId = "http://www.roblox.com/asset/?id=11565378" 
FuseSound.Parent = script.Parent 
FuseSound:Play() 

wait(3.0)

local sound = Instance.new("Sound") 
sound.SoundId = "rbxasset://sounds\\Rocket shot.wav" 
sound.Parent = script.Parent 
sound.Volume = 1 
sound:Play() 

e = Instance.new("Explosion")
e.Name ="EXPLODE"
e.Parent = game.Workspace
e.Position = egg.Position
e.BlastPressure = 500000
e.BlastRadius = 5.0

debris:addItem(e, 2.0)
egg:Remove()
