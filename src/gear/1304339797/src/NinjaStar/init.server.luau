local GearService = require(1075123174)

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
Mesh = Handle:WaitForChild("Mesh")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

StarScript = script:WaitForChild("StarScript")

Velocity = 50

Sounds = {
	Fire = Handle:WaitForChild("Fire"),
	Hit = Handle:WaitForChild("Hit")
}

local Star = Instance.new("Part")
Star.Name = "NinjaStar"
Star.Shape = Enum.PartType.Block
Star.Material = Enum.Material.Plastic
Star.TopSurface = Enum.SurfaceType.Smooth
Star.BottomSurface = Enum.SurfaceType.Smooth
Star.Size = Vector3.new(1, 0.4, 1)
Star.CanCollide = true
Star.Locked = true
Star.Anchored = false
Mesh:Clone().Parent = Star
local BackStar = Star:Clone()
local BackAttachment = Instance.new("Attachment")
BackAttachment.Orientation = Vector3.new(-90, -90, 0)
BackAttachment.Position = Vector3.new(0, -0.2, 0)
BackAttachment.Axis = Vector3.new(0, 0, 1)
BackAttachment.SecondaryAxis = Vector3.new(1, 0, 0)
BackAttachment.Name = "BodyBackAttachment"
BackAttachment.Parent = BackStar

StarScript:Clone().Parent = Star
Sounds.Hit:Clone().Parent = Star

Loaded = true
ToolEquipped = false
local CurrentBackStar = nil


ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

Handle.Transparency = 0
Tool.Enabled = true

function Fire(TargetPosition)
	CurrentBackStar.Transparency = 1
	Handle.Transparency = 1	
	Sounds.Fire:Play()
	
	local Direction = CFrame.new(Handle.Position, TargetPosition)
	
	local StartPosition = (Handle.CFrame + Direction.lookVector * 10)
	local Orientation = Handle.CFrame - Handle.CFrame.p

	local star = Star:clone()
	star.CFrame = CFrame.new(StartPosition.p) * Orientation
	star.Velocity = (Direction.lookVector * 80)
	star.RotVelocity = Vector3.new(0, 0, 80)

	local force = Instance.new("BodyForce")
	force.force = Vector3.new(0, 40, 0)
	force.Parent = star

	star.StarScript.Disabled = false

	local CreatorTag = Instance.new("ObjectValue")
	CreatorTag.Value = Player
	CreatorTag.Name = "creator"
	CreatorTag.Parent = star
	
	Debris:AddItem(star, 10)
	
	star.Parent = workspace

end


function Activated()
	if not Tool.Enabled or not CheckIfAlive() or not ToolEquipped then
		return
	end
	if Loaded then
		Tool.Enabled = false
		Loaded = false
		Fire(InvokeClient("MousePosition").Position)
		wait(0.4)
		Handle.Transparency = 1
		CurrentBackStar.Transparency = 0		
		Tool.Enabled = true
	else
		Handle.Transparency = 0
		CurrentBackStar.Transparency = 1
		Loaded = true
	end
end

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Player and Player.Parent) and true) or false)
end

function Equipped(Mouse)
	Character = Tool.Parent
	Humanoid = Character:FindFirstChild("Humanoid")
	Player = Players:GetPlayerFromCharacter(Character)
	if not CheckIfAlive() then
		return
	end
	ToolEquipped = true
	
	CurrentBackStar = BackStar:Clone()
	CurrentBackStar.Parent = Character
	local Torso = Character:FindFirstChild("UpperTorso") or Character:FindFirstChild("Torso")
	if Torso then
		 GearService:WeldToAttachment(CurrentBackStar:FindFirstChild("BodyBackAttachment"), Torso:FindFirstChild("BodyBackAttachment"))
	end
	CurrentBackStar.Transparency = 1
	Handle.Transparency = 0
end

function Unequipped()
	ToolEquipped = false
	Handle.Transparency = 0 
	if CurrentBackStar then
		CurrentBackStar:Destroy()
	end
end

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
end

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)