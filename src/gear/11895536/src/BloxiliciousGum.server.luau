--Rescripted by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Grips = {
	TakeStick = CFrame.new(1.25, -0.5, 0.200000003, 0.971011043, 0.239034176, 0.000580094696, -0.156055406, 0.632090449, 0.759018004, 0.181064576, -0.737105429, 0.651069343),
	RestoreStick = CFrame.new(0.0500000007, -0.150000006, 0.100000001, 0.613900721, 0.145039022, 0.775944352, -0.027069971, 0.986265421, -0.162935242, -0.788918972, 0.0790212676, 0.609395206),
}

Sounds = {
	OpenSound = Handle:WaitForChild("OpenSound"),
	InflateSound = Handle:WaitForChild("InflateSound"),
	PopSound = Handle:WaitForChild("PopSound"),
}

BasePart = Instance.new("Part")
BasePart.Shape = Enum.PartType.Block
BasePart.Material = Enum.Material.Plastic
BasePart.TopSurface = Enum.SurfaceType.Smooth
BasePart.BottomSurface = Enum.SurfaceType.Smooth
BasePart.FormFactor = Enum.FormFactor.Custom
BasePart.Size = Vector3.new(0.2, 0.2, 0.2)
BasePart.CanCollide = true
BasePart.Locked = true
BasePart.Anchored = false

BaseBubble = BasePart:Clone()
BaseBubble.Name = "Effect"
BaseBubble.Transparency = 0.3
BaseBubble.BrickColor = BrickColor.new("Pink")
BaseBubble.Size = Vector3.new(1, 1, 1)
BaseBubble.CanCollide = false
BubbleMesh = Instance.new("SpecialMesh")
BubbleMesh.MeshType = Enum.MeshType.Sphere
BubbleMesh.Parent = BaseBubble

MouseDown = false
ToolEquipped = false

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

Tool.Grip = Grips.RestoreStick
Tool.Enabled = true

function BlowBubble(head)
	if not head or not head.Parent then
		return
	end
	if not Bubble or not Bubble.Parent then
		Bubble = BaseBubble:Clone()
		BodyPosition = Instance.new("BodyPosition")
		BodyPosition.maxForce = Vector3.new(1e8, 1e8, 1e8)
		BodyPosition.position = Bubble.Position
		BodyPosition.Parent = Bubble
		Bubble.CFrame = CFrame.new(head.Position + (head.CFrame.lookVector * (0.6 +  (Bubble.Mesh.Scale.X * 0.5))))
		Bubble.Parent = Tool
	end
	local DesiredPosition = (head.Position + (head.CFrame.lookVector * (0.6 +  (Bubble.Mesh.Scale.X * 0.5))))
	if BodyPosition and BodyPosition.Parent then
		BodyPosition.position = DesiredPosition
	end
	Bubble.Mesh.Scale = (Bubble.Mesh.Scale + Vector3.new(0.1, 0.1, 0.1))
end

function CheckIfAlive()
	return (((Player and Player.Parent and Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Head and Head.Parent) and true) or false)
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Head = Character:FindFirstChild("Head")
	if not CheckIfAlive() then
		return
	end
	ToolEquipped = true
	Sounds.OpenSound:Play()
end

function Unequipped()
	ToolEquipped = false
	for i, v in pairs(Sounds) do
		v:Stop()
	end
	MouseDown = false
end

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
end

ServerControl.OnServerInvoke = (function(player, Mode, Value)
	if player ~= Player or not ToolEquipped or not CheckIfAlive() or not Mode or not Value then
		return
	end
	if Mode == "Button1Click" then
		local Down = Value.Down
		if Down and not MouseDown and Tool.Enabled then
			MouseDown = true
			Spawn(function()
				Tool.Enabled = false
			
				MouseDown = true
			
				Tool.Grip = Grips.TakeStick
				wait(0.5)
				Sounds.InflateSound:Play()
				
				Tool.Grip = Grips.RestoreStick
			
				local Rate = 0.05
				local Duration = 2
				local StartTime = tick()
				while MouseDown and ToolEquipped and CheckIfAlive() and (tick() - StartTime) < Duration do
					BlowBubble(Head)
					wait(Rate)
				end
				if Bubble and Bubble.Parent then
					Debris:AddItem(Bubble, 0)
					Bubble:Destroy()
				end
				Sounds.InflateSound:Stop()
				if CheckIfAlive() then
					local PopSound = Sounds.PopSound:Clone()
					Debris:AddItem(PopSound, 1.5)
					PopSound.Parent = Head
					PopSound:Play()
				end
				
				wait(1)
				
				Tool.Enabled = true
			end)
		elseif not Down and MouseDown then
			MouseDown = false
		end
	end
end)