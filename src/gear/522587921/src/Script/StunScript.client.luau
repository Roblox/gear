--Made by Luckymaxer

wait()

Players = game:GetService("Players")
Debris = game:GetService("Debris")

RbxUtility = LoadLibrary("RbxUtility")
Create = RbxUtility.Create

Player = Players.LocalPlayer

Character = Player.Character
Humanoid = Character:FindFirstChild("Humanoid")

function ShakeCam()
	local Camera = game:GetService("Workspace").CurrentCamera
	local CameraRotation = (Camera.CoordinateFrame - Camera.CoordinateFrame.p)
	local CameraScroll = (Camera.CoordinateFrame.p - Camera.Focus.p).Magnitude
	local NewCFrame = CFrame.new(Camera.Focus.p) * CameraRotation * CFrame.fromEulerAnglesXYZ(math.random(-10, 10) / 40, math.random(-10, 10) / 40, math.random(-10, 10) / 40)
	Camera.CoordinateFrame = NewCFrame * CFrame.new(0, 0, CameraScroll)
end

function TweenNumber(Object, Property, Goal, Time)
	Time = (Time * 30)
	local Increment = ((Goal - Object[Property]) / Time)
	for i = 1, Time do
		Object[Property] = (Object[Property] + Increment)
		wait()
	end
	return true
end

if Humanoid then
	Humanoid.WalkSpeed = 6
	local BlurWorked = false
	pcall(function()
		Spawn(function()
			for i = 1, math.random(5, 10) do
				ShakeCam()
				wait(1 / 30)
			end
		end)
		local Camera = game:GetService("Workspace").CurrentCamera
		local BlurEffect = Create("BlurEffect"){
			Name = "Blur",
			Size = 0,
			Enabled = true,
		}
		
		Debris:AddItem(BlurEffect, 15)
		
		BlurEffect.Parent = Camera
		
		TweenNumber(BlurEffect, "Size", 35, 1)
		wait(4)
		TweenNumber(BlurEffect, "Size", 0, 2)
		if BlurEffect and BlurEffect.Parent then
			BlurEffect:Destroy()
		end
		BlurWorked = true
	end)
	if not BlurWorked then
		wait(3)
	end
	Humanoid.WalkSpeed = 16
end

Debris:AddItem(script, 0.5)