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
sound:play() 

e = Instance.new("Explosion")
e.Name ="EXPLODE"
e.Parent = game.Workspace
e.Position = egg.Position
e.BlastPressure = 500000
e.BlastRadius = 7.5

debris:addItem(e, 2.0)

egg1 = egg:Clone()
egg1.Parent = game.Workspace
egg1.CanCollide = true
egg1.Transparency = 0.0
egg1.CFrame = egg.CFrame --+ Vector3.new(0.5, 0, 0)
egg1.Mesh.TextureId = "http://www.roblox.com/asset/?id=50446376"
egg1.Mesh.Scale = Vector3.new(0.5, 0.5, 0.5)

egg1.DropScript.Disabled = true

newScript = egg.boomScript:Clone()
newScript.Parent = egg1
newScript.Disabled = false

spark = Instance.new("Sparkles") 
spark.Name = "Fuse" 
spark.Parent = egg1

egg2 = egg:Clone()
egg2.Parent = game.Workspace
egg2.CanCollide = true
egg2.Transparency = 0.0
egg2.CFrame = egg.CFrame --+ Vector3.new(0, 0, 0.5)
egg2.Mesh.TextureId = "http://www.roblox.com/asset/?id=50446376"
egg2.Mesh.Scale = Vector3.new(0.5, 0.5, 0.5)

egg2.DropScript.Disabled = true

newScript2 = egg.boomScript:Clone()
newScript2.Parent = egg2
newScript2.Disabled = false

spark = Instance.new("Sparkles") 
spark.Name = "Fuse" 
spark.Parent = egg2

egg:Remove()
