--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

RemovalMonitor = script:WaitForChild("RemovalMonitor")

CarpetPieces = {
	{MeshId = 223079795, Angle = 160},
}

CarpetSize = Vector3.new(6, 0.5, 6.5)

BaseUrl = "http://www.roblox.com/asset/?id="

Rate = (1 / 10)

BasePart = Instance.new("Part")
BasePart.Material = Enum.Material.Plastic
BasePart.Shape = Enum.PartType.Block
BasePart.TopSurface = Enum.SurfaceType.Smooth
BasePart.BottomSurface = Enum.SurfaceType.Smooth
BasePart.FormFactor = Enum.FormFactor.Custom
BasePart.Size = Vector3.new(0.2, 0.2, 0.2)
BasePart.CanCollide = true
BasePart.Locked = true

Animations = {
	Sit = {Animation = Tool:WaitForChild("Sit"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil},
}

Grips = {
	Normal = CFrame.new(-1.5, 0, 0, 0, 0, -1, -0, 1, 0, 1, 0, 0),
	Flying = CFrame.new(-1.5, 0, -0.5, -1, 0, 0, 0, 1, 0, 0, 0, -1)
}

Flying = false
ToolEquipped = false

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

Handle.Transparency = 0
Tool.Grip = Grips.Normal
Tool.Enabled = true

function CleanUp()
	Handle.Transparency = 0
	for i, v in pairs(Tool:GetChildren()) do
		if v:IsA("BasePart") and v ~= Handle then
			v:Destroy()
		end
	end
end

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent and Player and Player.Parent) and true) or false)
end

function Activated()
	if not Tool.Enabled then
		return
	end
	Tool.Enabled = false
	Flying = not Flying
	if Flying then
		CleanUp()
		--Handle.Transparency = 1
		local CarpetParts = {}
		--[[Seat = Instance.new("Seat")
		Seat.Name = "Seat"
		Seat.Transparency = 1
		Seat.Material = Enum.Material.Plastic
		Seat.Shape = Enum.PartType.Block
		Seat.TopSurface = Enum.SurfaceType.Smooth
		Seat.BottomSurface = Enum.SurfaceType.Smooth
		Seat.FormFactor = Enum.FormFactor.Custom
		Seat.Size = Vector3.new(0.5, 0.2, 0.5)
		Seat.CanCollide = true
		Seat.Locked = true
		Seat.Disabled = false
		local SeatWeld = Instance.new("Weld")
		SeatWeld.Name = "Weld"
		SeatWeld.Part0 = Handle
		SeatWeld.Part1 = Seat
		SeatWeld.C0 = (CFrame.new(-1.5, 0, -3.25) * CFrame.Angles(0, math.pi, 0))
		SeatWeld.C1 = CFrame.new(0, 0, 0)
		SeatWeld.Parent = Seat
		Seat.Parent = Tool]]
		
		Spawn(function()
			InvokeClient("PlayAnimation", Animations.Sit)
			Tool.Grip = Grips.Flying
		end)
		
		FlightSpin = Instance.new("BodyGyro")
		FlightSpin.Name = "FlightSpin"
		FlightSpin.P = 1000000
		FlightSpin.maxTorque = Vector3.new(FlightSpin.P, FlightSpin.P, FlightSpin.P)
		FlightSpin.cframe = Torso.CFrame
		
		FlightPower = Instance.new("BodyVelocity")
		FlightPower.Name = "FlightPower"
		FlightPower.velocity = Vector3.new(0, 0, 0)
		FlightPower.P = 1000000
		FlightPower.maxForce = Vector3.new(FlightPower.P, FlightPower.P, FlightPower.P)
		FlightPower.P = 10000
		
		FlightHold = Instance.new("BodyPosition")
		FlightHold.Name = "FlightHold"
		FlightHold.P = 100000
		FlightHold.maxForce = Vector3.new(0, 0, 0)
		FlightHold.position = Torso.Position
		
		FlightSpin.Parent = Torso
		FlightPower.Parent = Torso
		FlightHold.Parent = Torso
		
		Spawn(function()
			local LastPlace = nil
			while Flying and ToolEquipped and CheckIfAlive() do
				
				local CurrentPlace = Handle.Position
				local Velocity = Torso.Velocity
				Velocity = Vector3.new(Velocity.X, 0, Velocity.Z).magnitude
				
				if LastPlace and Velocity > 10 then
					
				elseif not LastPlace then
					LastPlace = CurrentPlace
				end
				
				wait(Rate)
			end
		end)
	elseif not Flying then
		Torso.Velocity = Vector3.new(0, 0, 0)
		Torso.RotVelocity = Vector3.new(0, 0, 0)
		for i, v in pairs({FlightSpin, FlightPower, FlightHold}) do
			if v and v.Parent then
				v:Destroy()
			end
		end
		--[[if Seat and Seat.Parent and Seat.Occupant and Seat.Occupant:IsA("Humanoid") then
			local humanoid = Seat.Occupant
			humanoid.Sit = false
		end]]
		CleanUp()
		Spawn(function()
			Tool.Grip = Grips.Normal
			InvokeClient("StopAnimation", Animations.Sit)
		end)
	end
	
	wait(2)
	
	Tool.Enabled = true
end

function Equipped(Mouse)
	Character = Tool.Parent
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso")
	Player = Players:GetPlayerFromCharacter(Character)
	if not CheckIfAlive() then
		return
	end
	Tool.Grip = Grips.Normal
	ToolEquipped = true
end

function Unequipped()
	Flying = false
	for i, v in pairs({FlightSpin, FlightPower, FlightHold}) do
		if v and v.Parent then
			v:Destroy()
		end
	end
	CleanUp()
	Handle.Transparency = 0
	ToolEquipped = false
end

function OnServerInvoke(player, mode, value)
	if player ~= Player or not ToolEquipped or not value or not CheckIfAlive() then
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

CleanUp()

ServerControl.OnServerInvoke = OnServerInvoke

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)