--Rescripted by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

AirScript = script:WaitForChild("AirScript")

Colors = {"White", "Light stone grey", "Light blue", "Pastel Blue"}

Grips = {
	Up = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
	Out = CFrame.new(0, 0, 0, 0.194998264, 0.975938141, -0.0975725725, -0.980757415, 0.194987625, -0.00973754004, 0.00952220801, 0.0975938067, 0.995180845),
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

AirBubble = BasePart:Clone()
AirBubble.Name = "Effect"
AirBubble.Shape = Enum.PartType.Ball
AirBubble.Size = Vector3.new(2, 2, 2)
AirBubble.CanCollide = false

ReloadTime = 0
Gravity = 196.20

Sounds = {
	Equip = Handle:WaitForChild("Equip"),
	WindSound = Handle:WaitForChild("WindSound")
}

MouseDown = false
ToolEquipped = false

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

Tool.Grip = Grips.Up
Tool.Enabled = true

function Fire(Direction)
	
	if not Tool.Enabled or not CheckIfAlive() then
		return
	end
	
	local SpawnPos = Handle.Position + (Direction * 7.5)
	
	local Offset = Vector3.new(
		((math.random() - 0.5) * 50),
		((math.random() - 0.5) * 50),
		((math.random() - 0.5) * 50)
	)

	local Force = 100

	local Air = AirBubble:Clone()
	Air.Transparency = (math.random() * 0.5)
	Air.CFrame = CFrame.new(SpawnPos, Vector3.new(Offset.X, Offset.Y, Offset.Z))
	Air.Velocity = (Direction * Force)
	Air.BrickColor = BrickColor.new(Colors[math.random(1, #Colors)])
	
	local Mass = (Air:GetMass() * Gravity)
	
	local BodyVelocity = Instance.new("BodyVelocity")
	BodyVelocity.maxForce = Vector3.new(Mass, Mass, Mass)
	BodyVelocity.velocity = (Direction * Force)
	BodyVelocity.Parent = Air
	
	local Creator = Instance.new("ObjectValue")
	Creator.Name = "Creator"
	Creator.Value = Player
	Creator.Parent = Air
	
	local AirScriptClone = AirScript:Clone()
	AirScriptClone.Disabled = false
	AirScriptClone.Parent = Air
	
	Debris:AddItem(Air, 2)
	
	Air.Parent = game:GetService("Workspace")

end

function CheckIfAlive()
	return (((Player and Player.Parent and Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0) and true) or false)
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	if not CheckIfAlive() then
		return
	end
	ToolEquipped = true
	Sounds.Equip:Play()
end

function Unequipped()
	for i, v in pairs(Sounds) do
		v:Stop()
	end
	Tool.Grip = Grips.Up
	MouseDown = false
	ToolEquipped = false
end

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
				Tool.Grip = Grips.Out
				Sounds.WindSound:Play()
				local Rate = (1 / 60)
				local MaxDuration = 4
				local StartTime = tick()
				if ToolUnequipped then
					ToolUnequipped:disconnect()
				end
				local CurrentlyEquipped = true
				ToolUnequipped = Tool.Unequipped:connect(function()
					CurrentlyEquipped = false
				end)
				while MouseDown and ToolEquipped and CheckIfAlive() and (tick() - StartTime) < MaxDuration do
					local TargetPos = InvokeClient("MousePosition")
					if TargetPos then
						TargetPos = TargetPos.Position
						Spawn(function()
							for i = 1, math.random(2, 3) do
								if CurrentlyEquipped then
									local Direction = (TargetPos - Handle.Position).unit
									local Offset = Vector3.new(
										((math.random() - 0.5) * 0.3),
										((math.random() - 0.5) * 0.3),
										((math.random() - 0.5) * 0.3)
									)
									Fire(Vector3.new((Direction.X + Offset.X), (Direction.Y + Offset.Y), (Direction.Z + Offset.Z)))
									wait(0.1)
								end
							end
						end)
					end
					wait(Rate)
				end
				Tool.Grip = Grips.Up
				Sounds.WindSound:Stop()
				Tool.Enabled = false
				wait(2)
				Tool.Enabled = true
			end)
		elseif not Down and MouseDown then
			MouseDown = false
		end
	end
end)

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)