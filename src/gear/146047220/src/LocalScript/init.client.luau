--By Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
SlowDownScript = script:WaitForChild("SlowDownScript")

Character = nil

Debris = game:GetService("Debris")

MouseDown = false

function OnTouch(Hit)
	if Hit and Hit.Parent then
		if Hit.Parent:FindFirstChild("Humanoid") and Hit.Parent ~= Character then
			if not Hit.Parent.Humanoid:FindFirstChild(SlowDownScript.Name) then
				local SlowDownScriptClone = SlowDownScript:Clone()
				SlowDownScriptClone.Parent = Hit.Parent.Humanoid
			end
			Hit.Parent.Humanoid:FindFirstChild(SlowDownScript.Name).Duration.Value = 5
			Hit.Parent.Humanoid:FindFirstChild(SlowDownScript.Name).Disabled = false
		end
	end
end

function CreateInk(Mouse)
	if Mouse.Target and (Mouse.Hit.p - Handle.Position).magnitude <= 25 then
		if not Character:FindFirstChild("InkModel") then
			local InkModel = Instance.new("Model", Character)
			InkModel.Name = "InkModel"
			local InkRemoved
			InkRemoved = InkModel.ChildRemoved:connect(function(Child)
				if #InkModel:GetChildren() == 0 then
					InkModel:Destroy()
					InkRemoved:disconnect()
				end
			end)
		end
		local Ink = Instance.new("Part")
		Ink.TopSurface = Enum.SurfaceType.Smooth
		Ink.BottomSurface = Enum.SurfaceType.Smooth
		Ink.Name = "Ink"
		Ink.Anchored = true
		Ink.CanCollide = false
		Ink.BrickColor = BrickColor.new("Black")
		Ink.FormFactor = Enum.FormFactor.Custom
		Ink.Size = Vector3.new(0.2, 0.2, 0.2)
		Debris:AddItem(Ink, 20)
		Ink.Parent = Character:FindFirstChild("InkModel")
		Ink.Touched:connect(OnTouch)
		Ink.CFrame = CFrame.new(Mouse.Hit.p)
		if Mouse.Target.Name == "Ink" and Mouse.Target.Parent == Character then
			Ink.CFrame = Ink.CFrame - Vector3.new(0, 0.2, 0)
		end
	end
end

function OnEquipped(Mouse)
	Character = Tool.Parent
	Mouse.Button1Down:connect(function()
		MouseDown = true
		Spawn(function()
			while MouseDown do
				CreateInk(Mouse)
				wait(0.01)
			end
		end)
	end)
	Mouse.Button1Up:connect(function()
		MouseDown = false
	end)
end

function OnUnequipped()
	MouseDown = false
end

Tool.Equipped:connect(OnEquipped)
Tool.Unequipped:connect(OnUnequipped)