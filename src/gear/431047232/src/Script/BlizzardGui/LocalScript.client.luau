--Made by Luckymaxer

ScreenGui = script.Parent
PlayerGui = ScreenGui.Parent
Player = PlayerGui.Parent
Frame = ScreenGui.Frame

Debris = game:GetService("Debris")

RbxUtility = LoadLibrary("RbxUtility")
Create = RbxUtility.Create

BaseUrl = "http://www.roblox.com/asset/?id="

Frame:ClearAllChildren()
Frame.Visible = true

Images = {276120078, 276120139, 276120200}

--Optimization
Random = math.random
UDim2 = UDim2.new
Rate = 0.01
BaseParticle = Create("ImageLabel"){
	Name = "Particle",
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	ZIndex = 2,
}

Directions = {
	Straight = {
		Min = UDim2(0, 30, 0, 0),
		Max = UDim2(0, 60, 0, 0)
	},
	Left = {
		Min = UDim2(0, 0, 0, -10),
		Max = UDim2(0, 0, 0, 10)
	},
	Right = {
		Min = UDim2(0, 20, 0, 0),
		Max = UDim2(0, 50, 0, 0)
	}
}

MaximumParticles = 450

LastTick = 0
WaitTime = 0

Particles = {}

function CreateParticle()
	local Direction = Random(1, 3)
	Direction = ((Direction == 1 and Directions.Straight) or (Direction == 2 and Directions.Left) or Directions.Right)
	local Size = Random(10, 25)
	local Particle = BaseParticle:Clone()
	Particle.ImageTransparency = (Random(0, 500) * 0.001)
	Particle.Rotation = Random(0, 360)
	Particle.Image = (BaseUrl .. Images[Random(1, #Images)])
	Particle.Size = UDim2(0, Size, 0, Size)
	Particle.Position = UDim2(0, (0 - Size), 0, Random(0, (Frame.Size.Y.Offset - Size)))
	Particle.Parent = Frame
	table.insert(Particles, {Frame = Particle, Direction = Direction})
end

function SpawnParticles()
	for i = 1, Random(1, 100) do 
		if #Particles < MaximumParticles then
			CreateParticle()
		else
			break
		end
	end
end

function AnimateParticles()
	for i, v in pairs(Particles) do
		local Direction = UDim2(0, Random(v.Direction.Min.X.Offset, v.Direction.Max.X.Offset), 0, Random(v.Direction.Min.Y.Offset, v.Direction.Max.Y.Offset))
		v.Frame.Position = (v.Frame.Position + UDim2(0, Direction.X.Offset, 0, Direction.Y.Offset))
		v.Rotation = ((v.Frame.Rotation >= 360 and 1) or (v.Frame.Rotation + 5))
		if v.Frame.Position.Y.Offset >= Frame.Size.Y.Offset or v.Frame.Position.X.Offset >= Frame.Size.X.Offset or v.Frame.Position.X.Offset <= (0 - v.Frame.Size.X.Offset) then
			v.Frame:Destroy()
			table.remove(Particles, i)
		end
	end
end

function FunctionParticles()
	Spawn(function()
		repeat
			if (tick() - LastTick) > WaitTime then
				LastTick = tick()
				WaitTime = 0
				SpawnParticles()
			end
			AnimateParticles()
			wait(Rate)
		until false
	end)
end

function FixScreenSize()
	Frame.Size = UDim2(0, ScreenGui.AbsoluteSize.X, 0, (ScreenGui.AbsoluteSize.Y + 36))
	Frame.Position = UDim2(0, 0, 0, -36)
end

function DestroyGui()
	Debris:AddItem(ScreenGui, 2)
end

ScreenGui.Changed:connect(function(Property)
	if Property == "AbsoluteSize" then
		FixScreenSize()
	end
end)

FixScreenSize()

FunctionParticles()