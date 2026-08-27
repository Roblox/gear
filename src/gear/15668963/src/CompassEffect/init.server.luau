--Updated for R15 avatars by StarWars
--print("do compass")


debris = game:GetService("Debris")


-- create arrow
local p = Instance.new("Part")
p.formFactor = 2
p.Size = Vector3.new(1,.4,1)
p.Transparency = .5
p.BrickColor = BrickColor.new(119)
p.CanCollide = false
p.Locked = true
p.RotVelocity = Vector3.new(math.random(), math.random(), math.random()) * 10
local Torso = script.Parent:FindFirstChild("Torso") or script.Parent:FindFirstChild("UpperTorso")
local v = Vector3.new(Torso.CFrame.lookVector.x, 0, Torso.CFrame.lookVector.z)

p.CFrame = CFrame.new(Torso.CFrame.p + v * 8, v.unit)

local m = script.ArrowMesh:Clone() -- NASTY......... I agree
m.Parent = p



local b = Instance.new("BodyPosition")
b.position = p.Position
b.Parent = p

local g = Instance.new("BodyGyro")
g.cframe = CFrame.new(Vector3.new(0,0,0), Vector3.new(0,0,1)) -- point North
g.maxTorque = Vector3.new(7e7, 7e7, 7e7)
g.Parent = p



p.Parent = game.Workspace







debris:AddItem(p, 10)


wait(5)

script.Parent = nil