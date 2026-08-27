--Made by Luckymaxer

ScreenGui = script.Parent
PlayerGui = ScreenGui.Parent
Player = PlayerGui.Parent
Frame = ScreenGui.Frame

Debris = game:GetService("Debris")

Frame:ClearAllChildren()

Connection = ScreenGui:WaitForChild("Connection")

Colors = {Color3.new(170, 170, 127), Color3.new(138, 138, 103)}

Directions = {
	Straight = {
		Min = UDim2.new(0, 30, 0, 0),
		Max = UDim2.new(0, 60, 0, 0)
	},
	Left = {
		Min = UDim2.new(0, 0, 0, -10),
		Max = UDim2.new(0, 0, 0, 10)
	},
	Right = {
		Min = UDim2.new(0, 20, 0, 0),
		Max = UDim2.new(0, 50, 0, 0)
	}
}

MaximumParticles = 350

LastTick = 0
WaitTime = 0

Particles = {}

function CreateParticle(Color)
	local Particle = Instance.new("ImageLabel")
	Particle.Name = "Particle"
	Particle.ZIndex = 1
	Particle.BackgroundColor3 = Color3.new((Color.r / 255), (Color.g / 255), (Color.b / 255))
	Particle.BorderColor3 = Particle.BackgroundColor3
	Particle.BorderSizePixel = 0
	Particle.Size = UDim2.new(0, math.random(3, 4), 0, math.random(3, 4))
	Particle.Position = UDim2.new(0, (0 - Particle.Size.X.Offset), 0, math.random(0, (Frame.Size.Y.Offset - Particle.Size.Y.Offset)))
	Direction = math.random(1, 3)
	Direction = ((Direction == 1 and Directions.Straight) or (Direction == 2 and Directions.Left) or Directions.Right)
	Particle.Parent = Frame
	table.insert(Particles, {Frame = Particle, Direction = Direction})
end

function SpawnParticles()
	if #Particles < MaximumParticles then
		for i = 1, math.random(1, 100) do 
			if #Particles < MaximumParticles then
				CreateParticle(Colors[math.random(1, #Colors)])
			else
				break
			end
		end
	end
end

function AnimateParticles()
	for i, v in pairs(Particles) do
		local Direction = UDim2.new(0, math.random(v.Direction.Min.X.Offset, v.Direction.Max.X.Offset), 0, math.random(v.Direction.Min.Y.Offset, v.Direction.Max.Y.Offset))
		v.Frame.Position = v.Frame.Position + UDim2.new(0, Direction.X.Offset, 0, Direction.Y.Offset)
		if v.Frame.Position.Y.Offset >= Frame.Size.Y.Offset or v.Frame.Position.X.Offset >= Frame.Size.X.Offset or v.Frame.Position.X.Offset <= (0 - v.Frame.Size.X.Offset) then
			v.Frame:Destroy()
			table.remove(Particles, i)
		end
	end
end

function FunctionParticles()
	Spawn(function()
		repeat
			if not Connection.Value then
				DestroyGui()
			end
			if (tick() - LastTick) > WaitTime then
				LastTick = tick()
				WaitTime = math.random(0.1, 0.25)
				SpawnParticles()
			end
			AnimateParticles()
			wait(0.01)
		until false
	end)
end

function FixScreenSize()
	Frame.Size = UDim2.new(0, ScreenGui.AbsoluteSize.X, 0, ScreenGui.AbsoluteSize.Y)
end

function DestroyGui()
	Debris:AddItem(ScreenGui, 2)
end

ScreenGui.Changed:connect(function(Property)
	if Property == "AbsoluteSize" then
		FixScreenSize()
	end
end)

if not Connection.Value then
	DestroyGui()
end

FixScreenSize()

FunctionParticles()