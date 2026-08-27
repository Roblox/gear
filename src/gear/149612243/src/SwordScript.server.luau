Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
AnimPlaying = Tool:WaitForChild("AnimPlaying")
AnimReloading = Tool:WaitForChild("AnimReloading")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

SpecialReloadTime = 15

Damage = 10

function TagHumanoid(humanoid, player)
	local creator_Tag = Instance.new("ObjectValue")
	creator_Tag.Value = player
	creator_Tag.Name = "creator"
	creator_Tag.Parent = humanoid
end

function UntagHumanoid(humanoid)
	for i, v in pairs(humanoid:GetChildren()) do
		if v.Name == "creator" then
			v:Destroy()
		end
	end
end

function Blow(Hit)
	if not Hit or not Hit.Parent then
		return
	end
	local humanoid = Hit.Parent:findFirstChild("Humanoid")
	if humanoid and humanoid.Health > 0 and Humanoid and humanoid ~= Humanoid then

		local right_arm = Character:FindFirstChild("Right Arm")
		if right_arm then
			local joint = right_arm:FindFirstChild("RightGrip")
			if (joint and (joint.Part0 == Handle or joint.Part1 == Handle)) then
				TagHumanoid(humanoid, Player)
				humanoid:TakeDamage(Damage)
				wait(1)
				UntagHumanoid(humanoid)
			end
		end


	end
end

function Equipped(Mouse)
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso")
	if not Character or not Player or not Humanoid then
		return
	end
	AnimPlayingConnection = AnimPlaying.Changed:connect(function()
		if AnimPlaying.Value then
			local OriginalWalkSpeed = Humanoid.WalkSpeed
			Humanoid.WalkSpeed = OriginalWalkSpeed
			AnimPlaying.Value = true
			AnimReloading.Value = true
			wait(1)
			local TorsoCFrame = Torso.CFrame
			local Snake = Instance.new("Part")
			Snake.Name = "Snake"
			Snake.Material = Enum.Material.SmoothPlastic
			Snake.TopSurface = Enum.SurfaceType.Smooth
			Snake.BottomSurface = Enum.SurfaceType.Smooth
			Snake.FormFactor = Enum.FormFactor.Custom
			Snake.Size = Vector3.new(3.5, 0.75, 0.2)
			Snake.CanCollide = true
			Snake.Friction = 0
			local Mesh = Instance.new("SpecialMesh")
			Mesh.MeshType = Enum.MeshType.FileMesh
			Mesh.MeshId = "http://www.roblox.com/asset/?id=49046138"
			Mesh.TextureId = "http://www.roblox.com/asset/?id=49046409"
			Mesh.Scale = Vector3.new(0.75, 0.75, 0.75)
			Mesh.Parent = Snake
			Snake.CFrame = TorsoCFrame + TorsoCFrame.lookVector * ((Torso.Size.z / 2) + (Snake.Size.x / 2))
			Snake.CFrame = Snake.CFrame - Vector3.new(0, (Torso.Size.y * 1.5), 0)
			for i = 1, 5 do
				for i = 1, 3 do
					local SnakeClone = Snake:Clone()
					local SnakeCloneY = SnakeClone:Clone()
					SnakeCloneY.CFrame = SnakeCloneY.CFrame * CFrame.Angles(math.rad(90), 0, 0)		
					SnakeCloneY.CFrame = SnakeCloneY.CFrame + SnakeCloneY.CFrame.lookVector * ((SnakeCloneY.Size.y / 2))
					local SnakeCloneZ = SnakeCloneY:Clone()
					SnakeCloneZ.CFrame = SnakeCloneZ.CFrame
					local SnakeCloneX = SnakeCloneZ:Clone()
					SnakeCloneX.CFrame = SnakeCloneZ.CFrame * CFrame.Angles(0, math.rad(90), 0)
					SnakeCloneX.CFrame = SnakeCloneX.CFrame - SnakeCloneX.CFrame.lookVector * ((Torso.Size.x / 2) + (Snake.Size.y / 2))
					SnakeCloneX.CFrame = SnakeCloneX.CFrame + SnakeCloneX.CFrame.lookVector * ((Snake.Size.y / 2) + (i * Snake.Size.y))
					local snake = Snake:Clone()
					local BrickColor = BrickColor.new(math.random(), math.random(), math.random())
					local R, G, B = BrickColor.r, BrickColor.g, BrickColor.b
					snake.Mesh.VertexColor = Vector3.new(R, G, B)
					local BodyGyro = Instance.new("BodyGyro")
					BodyGyro.maxTorque = Vector3.new(400000, 400000, 400000)
					BodyGyro.Parent = snake
					local Force = Instance.new("BodyForce")
					Force.Parent = snake
					Debris:AddItem(snake, 5)
					snake.Parent = game:GetService("Workspace")
					snake.CFrame = SnakeCloneX.CFrame
					snake.CFrame = snake.CFrame * CFrame.Angles((math.pi / 2), (math.pi / 2), math.pi)
					BodyGyro.cframe = snake.CFrame
					Force.force = TorsoCFrame.lookVector * (Snake:GetMass() * 9.81 * 5)
					snake.Velocity = TorsoCFrame.lookVector * 50
					snake.Touched:connect(function(Hit)
						if Hit and Hit.Parent and Hit.Parent ~= Character and Hit.Parent:FindFirstChild("Humanoid") then
							local humanoid = Hit.Parent.Humanoid
							humanoid:TakeDamage(15)
						end
					end)
				end
				wait(0.125)
			end
			AnimReloading.Value = true
			AnimPlaying.Value = false
			Humanoid.WalkSpeed = OriginalWalkSpeed
			wait(SpecialReloadTime)
			AnimReloading.Value = false
		end
	end)
end

function Unequipped()
	if AnimPlayingConnection and AnimPlayingConnection.connected then
		AnimPlayingConnection:disconnect()
	end
end

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)

connection = Handle.Touched:connect(Blow)