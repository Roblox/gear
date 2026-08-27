--Made by Luckymaxer

Character = script.Parent
Humanoid = Character:FindFirstChild("Humanoid")
Head = Character:FindFirstChild("Head")
Torso = Character:FindFirstChild("Torso")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Player = Players:GetPlayerFromCharacter(Character)

Mode = script:FindFirstChild("Mode")

CoughSound = script:WaitForChild("CoughSound")

RbxUtility = LoadLibrary("RbxUtility")
Create = RbxUtility.Create

BasePart = Create("Part"){
	Shape = Enum.PartType.Block,
	Material = Enum.Material.Plastic,
	FormFactor = Enum.FormFactor.Custom,
	TopSurface = Enum.SurfaceType.Smooth,
	BottomSurface = Enum.SurfaceType.Smooth,
	Size = Vector3.new(0.2, 0.2, 0.2),
	Locked = true,
	CanCollide = true,
	Anchored = false,
}

Animations = {
	Eat = {Animation = script:WaitForChild("Eat"), FadeTime = nil, Weight = nil, Speed = 0.8, Duration = 2.2},
	Scream = {Animation = script:WaitForChild("Scream"), FadeTime = nil, Weight = nil, Speed = 4},
	Cough = {Animation = script:WaitForChild("Cough"), FadeTime = nil, Weight = nil, Speed = nil},
}

AnimationTracks = {}

ServerControl = (script:FindFirstChild("ServerControl") or Create("RemoteFunction"){
	Name = "ServerControl",
	Parent = script,
})

ClientControl = (script:FindFirstChild("ClientControl") or Create("RemoteFunction"){
	Name = "ClientControl",
	Parent = script,
})

function DestroyScript()
	Debris:AddItem(script, 0.5)
end

function ToggleControllability(Disabled)
	Humanoid.WalkSpeed = 16
	if HumanoidJump then
		HumanoidJump:disconnect()
	end
	if Disabled then
		Humanoid.WalkSpeed = 0
		HumanoidJump = Humanoid.Changed:connect(function(Property)
			if Property == "Jump" then
				Humanoid.Jump = false
			end
		end)
	end
end

function Eat()
	local Animation = Animations.Eat
	local SpeedRate = 2
	local Speed = (Animation.Speed * SpeedRate)
	Spawn(function()
		InvokeClient("PlayAnimation", {Animation = Animation.Animation, FadeTime = Animation.FadeTime, Weight = Animation.Weight, Speed = Speed})
	end)
	wait(Animation.Duration / SpeedRate)
end

function Vomit()
	local Colors = {"Camo", "Earth green", "Bright green", "Dark green"}
	for i = 1, math.random(5, 10) do
		for ii = 1, math.random(10, 15) do
			local Part = BasePart:Clone()
			Part.BrickColor = BrickColor.new(Colors[math.random(1, #Colors)])
			Part.Name = "Effect"
			Part.CanCollide = false
			Part.Velocity = (Head.CFrame.lookVector + Vector3.new(math.random(-1, 1), 0, math.random(-1, 1)) * 5)
			Part.CFrame = (CFrame.new(Head.Position) + Head.CFrame.lookVector * ((Head.Size.Z / 2) + 0.5))
			Debris:AddItem(Part, 5)
			Part.Parent = game:GetService("Workspace")
		end
		wait(0.1)
	end
end

function Scream()
	local Parts = {}
	for i, v in pairs(Character:GetChildren()) do
		if v:IsA("BasePart") then
			table.insert(Parts, {Part = v, BrickColor = v.BrickColor})
			v.BrickColor = BrickColor.new("Really red")
		end
	end
	local FlamePart = BasePart:Clone()
	FlamePart.Name = "Effect"
	FlamePart.Transparency = 1
	FlamePart.CanCollide = false
	local Flames = Create("Fire"){
		Color = Color3.new((236 / 255), (139 / 255), (70 / 255)),
		SecondaryColor = Color3.new((139 / 255), (80 / 255), (55 / 255)),
		Heat = 25,
		Size = 5,
		Enabled = true,
		Parent = FlamePart,
	}
	local FlameWeld = Create("Weld"){
		Part0 = Head,
		Part1 = FlamePart,
		C0 = (CFrame.new(0, 0, -(Head.Size.Z / 2)) * CFrame.Angles((math.pi / 2), 0, 0)),
		Parent = FlamePart,
	}
	FlamePart.Parent = Character
	local ScreamDuration = 5
	local Animation = Animations.Scream
	Spawn(function()
		InvokeClient("PlayAnimation", Animation)
	end)
	local ScreamStart = tick()
	local Movement = {Time = 0, Delay = 0}
	local RandomWalk = nil
	while (tick() - ScreamStart) < ScreamDuration do
		if (tick() - Movement.Time) >= Movement.Delay then
			RandomWalk = (Torso.CFrame + (Torso.CFrame * CFrame.Angles(0, (math.random(-3600, 3600) * 0.001), 0)).lookVector * math.random(4, 12)).p
			Movement.Time = tick()
			Movement.Delay = (math.random(500, 750) * 0.001)
		end
		Humanoid:MoveTo(RandomWalk)
		wait()
	end
	Spawn(function()
		InvokeClient("StopAnimation", {Animation = Animation.Animation, FadeTime = 0.25})
	end)
	for i, v in pairs(Parts) do
		if v and v.Part then
			v.Part.BrickColor = v.BrickColor
		end
	end
	if FlamePart and FlamePart.Parent then
		FlamePart:Destroy()
	end
end

function OnServerInvoke(player, mode, value)
	if player ~= Player or not value then
		return
	end
end

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
end

ServerControl.OnServerInvoke = OnServerInvoke

if not Character or not Character.Parent or not Humanoid or Humanoid.Health <= 0 or not Head or not Torso or not Player or not Mode then
	DestroyScript()
	return
end

if Mode.Value == 1 then
	Scream()
elseif Mode.Value == 2 then
	ToggleControllability(true)
	Eat()
	Vomit()
	wait(1)
	ToggleControllability(false)
elseif Mode.Value == 3 then
	ToggleControllability(true)
	Humanoid.WalkSpeed = 8
	InvokeClient("PlayAnimation", Animations.Cough)
	local Sound = CoughSound:Play()
	Debris:AddItem(Sound, 1.5)
	CoughSound.Parent = Head
	CoughSound:Play()
	wait(1.5)
	ToggleControllability(false)
end

DestroyScript()