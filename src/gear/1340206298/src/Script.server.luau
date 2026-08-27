Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
Mesh = Handle:WaitForChild("Mesh")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

RemoteControl = Tool:WaitForChild("RemoteControl")

ServerControl = (RemoteControl:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = RemoteControl

ClientControl = (RemoteControl:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = RemoteControl

SkateboardModule = require(199238756)
SkateboardFunctions = SkateboardModule.SkateboardFunctions
Functions = SkateboardModule.Functions

Skateboard = SkateboardFunctions.GetSkateboard("Classic")
SkateboardFunctions.CreateConfiguration(Tool, Skateboard)
SkateboardPlatform = SkateboardFunctions.GetSkateboardPlatform(Skateboard)

Sounds = {
	Drop = Handle:WaitForChild("Drop")
}

ToolEquipped = false
ToolEnabled = true

Tool.Enabled = true

ServerControl.OnServerInvoke = (function(player, Mode, Value)
end)

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
end

function DropSkateboard()
	
	local MousePosition = InvokeClient("MousePosition")
	
	local DesiredAngle = (math.acos((MousePosition - Handle.Position).unit:Dot(Torso.CFrame.lookVector)))
	if DesiredAngle > (math.pi / 2) then --Prevents spawning behind character.
		--return
	end
	
	local SkateboardSize = Skateboard:GetModelSize()	
	
	local Direction = CFrame.new(Torso.Position, Vector3.new(MousePosition.X, Torso.Position.Y, MousePosition.Z))
	local SkateboardCFrame = Direction + Direction.lookVector * (((Torso.Size.Z / 2) + (SkateboardSize.Z / 2)) * 1.5)
	local SkateboardAngle = CFrame.Angles(0, 0, 0)
	
	local RayOffset = Vector3.new(-1.5, 0, -1.5)
	
	local RayPoints = { --Border points and center of skateboard used for casting rays.
		Center = Functions.PositionPart(SkateboardCFrame, 0, 0, 0),
		BackLeft = Functions.PositionPart(SkateboardCFrame, -((SkateboardSize.X / 2) + RayOffset.X), RayOffset.Y, -((SkateboardSize.Z / 2) + RayOffset.Z)),
		BackRight = Functions.PositionPart(SkateboardCFrame, ((SkateboardSize.X / 2) + RayOffset.X), RayOffset.Y, -((SkateboardSize.Z / 2) + RayOffset.Z)),
		FrontLeft = Functions.PositionPart(SkateboardCFrame, -((SkateboardSize.X / 2) + RayOffset.X), RayOffset.Y, ((SkateboardSize.Z / 2) + RayOffset.Z)),
		FrontRight = Functions.PositionPart(SkateboardCFrame, ((SkateboardSize.X / 2) + RayOffset.X), RayOffset.Y, ((SkateboardSize.Z / 2) + RayOffset.Z)),
	}
	
	local RayData = {
		Area = { --Cast ray to determine if skateboard will spawn inside something.
			Offset = Vector3.new(0, (SkateboardSize.Y / 2), 0),
			Direction = Vector3.new(0, 1, 0),
			Distance = SkateboardSize.Y
		},
		Ground = { --Cast ray to determine if the skateboard can spawn on the ground.
			Direction = Vector3.new(0, -1, 0),
			Distance = (SkateboardSize.Y * 4)
		}
	}
	
	local Ignore = {Character, Skateboard}
	
	local HighestGroundRayHit, HighestGroundRayPos --Get the highest point of elevation to spawn the skateboard.
	for i, v in pairs(RayPoints) do
		local GroundRayHit, GroundRayPos = Functions.RayCast(v.p, RayData.Ground.Direction, RayData.Ground.Distance, Ignore)
		if not HighestGroundRayPos or GroundRayPos.Y > HighestGroundRayPos.Y then
			HighestGroundRayHit, HighestGroundRayPos = GroundRayHit, GroundRayPos
		end
	end	
	
	local FullAreaIsEmpty = true --Ensure entire area is empty.
	for i, v in pairs(RayPoints) do
		local AreaIsEmpty = Functions.RegionEmpty((v.p - RayData.Area.Offset), {Min = Vector3.new(0, 0, 0), Max = (RayData.Area.Direction * RayData.Area.Distance)}, Ignore)
		if not AreaIsEmpty then
			FullAreaIsEmpty = false
		end
	end
	
	if not FullAreaIsEmpty or not HighestGroundRayHit then
		return
	end
	
	ToolEnabled = false
	
	local PosX, PosY, PosZ, R00, R01, R02, R10, R11, R12, R20, R21, R22 = SkateboardCFrame:components()
	SkateboardCFrame = CFrame.new(PosX, (HighestGroundRayPos.Y + (SkateboardSize.Y / 2)), PosZ, R00, R01, R02, R10, R11, R12, R20, R21, R22)
	
	InvokeClient("PlaySound", Sounds.Drop)
	
	Tool.Parent = nil
	
	local Platform = Skateboard:FindFirstChildWhichIsA("SkateboardPlatform")
	if Platform then
		local Mesh = Platform:FindFirstChildOfClass("SpecialMesh")
		if Mesh then
			Mesh.Offset = Vector3.new(0, -0.47, 0)
		end
	end
	SkateboardFunctions.SpawnSkateboard(Skateboard, (SkateboardCFrame * SkateboardAngle))

	Debris:AddItem(Tool, 0)	
	Tool:Destroy()
	
end

function CheckIfAlive()
	return (((Player and Player.Parent and Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent) and true) or false)
end

function Activated()
	if not ToolEquipped or not ToolEnabled or not CheckIfAlive() then
		return
	end
	DropSkateboard()
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild('UpperTorso')
	if not CheckIfAlive() then
		return
	end
	ToolEquipped = true
end

function Unequipped()
	ToolEquipped = false
end

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)