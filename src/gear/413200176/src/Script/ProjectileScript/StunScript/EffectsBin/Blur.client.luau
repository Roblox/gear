--Made by Luckymaxer

wait()

Players = game:GetService("Players")
Debris = game:GetService("Debris")

RbxUtility = LoadLibrary("RbxUtility")
Create = RbxUtility.Create

Player = Players.LocalPlayer

Camera = game:GetService("Workspace").CurrentCamera

Character = Player.Character
Humanoid = Character:FindFirstChild("Humanoid")

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
	Humanoid.WalkSpeed = 10
	local BlurWorked = false
	pcall(function()
		local BlurEffect = Create("BlurEffect"){
			Name = "Blur",
			Size = 0,
			Enabled = true,
		}
		
		Debris:AddItem(BlurEffect, 15)
		
		BlurEffect.Parent = Camera
		
		TweenNumber(BlurEffect, "Size", 35, 1.5)
		wait(7)
		TweenNumber(BlurEffect, "Size", 0, 3)
		if BlurEffect and BlurEffect.Parent then
			BlurEffect:Destroy()
		end
		BlurWorked = true
	end)
	if not BlurWorked then
		wait(12)
	end
	Humanoid.WalkSpeed = 16
end

Debris:AddItem(script, 0.5)