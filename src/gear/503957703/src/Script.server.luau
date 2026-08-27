--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

BaseUrl = "http://www.roblox.com/asset/?id="

BasePart = Instance.new("Part")
BasePart.Material = Enum.Material.Plastic
BasePart.Shape = Enum.PartType.Block
BasePart.TopSurface = Enum.SurfaceType.Smooth
BasePart.BottomSurface = Enum.SurfaceType.Smooth
BasePart.FormFactor = Enum.FormFactor.Custom
BasePart.Size = Vector3.new(0.2, 0.2, 0.2)
BasePart.Locked = true
BasePart.CanCollide = true
BasePart.Anchored = false

BaseSlime = BasePart:Clone()
BaseSlime.Name = "Slime"
BaseSlime.BrickColor = BrickColor.new("Lime green")
BaseSlime.Size = Vector3.new(0.5, 1.25, 0.5)
BaseSlime.CanCollide = false
SlimeMesh = Instance.new("CylinderMesh")
SlimeMesh.Scale = (Vector3.new(1, 1, 1) * BaseSlime.Size)
SlimeMesh.VertexColor = Vector3.new(1, 1, 1)
SlimeMesh.Offset = Vector3.new(0, 0, 0)
SlimeMesh.Parent = BaseSlime

Animations = {}

Sounds = {
	Fire = Handle:WaitForChild("Fire"),
	Splat = Handle:WaitForChild("Splat"),
}

ReloadTime  = 0.25

ToolEquipped = false

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

Tool.Enabled = true

function IsTeamMate(Player1, Player2)
	return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
end

function TagHumanoid(humanoid, player)
	local Creator_Tag = Instance.new("ObjectValue")
	Creator_Tag.Name = "creator"
	Creator_Tag.Value = player
	Debris:AddItem(Creator_Tag, 2)
	Creator_Tag.Parent = humanoid
end

function UntagHumanoid(humanoid)
	for i, v in pairs(humanoid:GetChildren()) do
		if v:IsA("ObjectValue") and v.Name == "creator" then
			v:Destroy()
		end
	end
end

function CoverScreen(player)
	local PlayerGui = player:FindFirstChild("PlayerGui")
	if PlayerGui then
		
		local Images = {220334579, 220334748, 220334782, 220334826}

		local ScreenGui = Instance.new("ScreenGui") 
		ScreenGui.Name = "SlimeSplatter"
		local MainFrame = Instance.new("Frame") 
		MainFrame.Name = "Splater"
		MainFrame.Position = UDim2.new(0, 0, 0, 0) 
		MainFrame.Size = UDim2.new(1, 0, 1, 0) 
		MainFrame.BackgroundColor = BrickColor.new(1, 1, 1)
		MainFrame.Transparency = 1
		MainFrame.BorderColor = BrickColor.new(1, 1, 1)
		MainFrame.Parent = ScreenGui
	
		local Splatter = Instance.new("ImageLabel")
		local Size = ((math.random() * 0.5) + 0.5)
		Splatter.Size = UDim2.new(Size, 0, Size, 0)
		Splatter.Position = UDim2.new((math.random() - (Size / 2)), 0, (math.random() - (Size / 2)),0)
		Splatter.SizeConstraint = Enum.SizeConstraint.RelativeXX
		Splatter.Transparency = 1
		Splatter.Image = (BaseUrl .. Images[math.random(1, #Images)])
		Splatter.Parent = MainFrame

		Debris:AddItem(Splatter, (5 + (math.random() * 2)))
	
		for i = 1, 5 do
			local Splatter = Instance.new("ImageLabel")
			local Size = ((math.random() * 0.2) + 0.1)
			Splatter.Size = UDim2.new(Size,0, Size, 0)
			Splatter.Position = UDim2.new((math.random() - (Size / 2)), 0, (math.random() - (Size / 2)), 0)
			Splatter.SizeConstraint = Enum.SizeConstraint.RelativeXX
			Splatter.Transparency = 1
			Splatter.Image = (BaseUrl.. Images[math.random(1, #Images)])
			Splatter.Parent = MainFrame
			Debris:AddItem(Splatter, (3 + (math.random() * 6)))
		end
	
		Debris:AddItem(ScreenGui, 5)
		
		ScreenGui.Parent = PlayerGui
	
	end
end

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Head and Head.Parent) and true) or false)
end

function Activated()
	local MouseData = InvokeClient("MouseData")
	if not MouseData or not MouseData.Position then
		return
	end
	if not Tool.Enabled or not ToolEquipped or not CheckIfAlive() then
		return
	end
	Tool.Enabled = false
	Sounds.Fire.Pitch = (math.random(1250, 2500) * 0.001)
	Sounds.Fire:Play()
	local StartPosition = (Handle.CFrame * CFrame.new(0, 0.2, -((Handle.Size.Z / 2) + (BaseSlime.Size.Y / 2) + 0.5)))
	local TargetPosition = MouseData.Position
	local TargetDirection = CFrame.new(StartPosition.p, TargetPosition)
	local Force = 250
	local Velocity = (TargetDirection.lookVector * Force)
	local Slime = BaseSlime:Clone()
	Slime.CFrame = (TargetDirection * CFrame.Angles((math.pi / 2), 0, 0))
	Slime.Velocity = Velocity
	local Gravity = 196.20
	local Weight = (Slime:GetMass() * Gravity)
	local BodyVelocity = Instance.new("BodyVelocity")
	BodyVelocity.Name = "BodyVelocity"
	BodyVelocity.MaxForce = Vector3.new(Weight, Weight, Weight)
	BodyVelocity.Velocity = Velocity
	BodyVelocity.Parent = Slime
	local SplatSound = Sounds.Splat:Clone()
	SplatSound.Parent = Slime
	local AlreadyHit = false
	Slime.Touched:connect(function(Hit)
		if not Hit or not Hit.Parent or AlreadyHit then
			return
		end
		local character = Hit.Parent
		if character:IsA("Hat") or character:IsA("Tool") then
			character = character.Parent
		end
		if character == Character then
			return
		end
		local humanoid = character:FindFirstChild("Humanoid")
		if humanoid and humanoid.Health > 0 then
			local player = Players:GetPlayerFromCharacter(character)
			if not player or (player and (player ~= Player and not IsTeamMate(Player, player))) then
				if player then
					CoverScreen(player)
				end
			end
			UntagHumanoid(humanoid)
			TagHumanoid(humanoid, Player)
			humanoid:TakeDamage(8)
		end
		AlreadyHit = true
		SplatSound.Pitch = (math.random(900, 1100) * 0.001)
		SplatSound:Play()
		Slime.Anchored = true
		Slime.CanCollide = false
		Slime.Transparency = 1
		Debris:AddItem(Slime, 0.5)
	end)
	Debris:AddItem(Slime, 3)
	Slime.Parent = game:GetService("Workspace")
	wait(ReloadTime)
	Tool.Enabled = true
end

function Equipped()
	Character = Tool.Parent
	Humanoid = Character:FindFirstChild("Humanoid")
	Head = Character:FindFirstChild("Head")
	Player = Players:GetPlayerFromCharacter(Character)
	if not CheckIfAlive() then
		return
	end
	ToolEquipped = true
end

function Unequipped()
	ToolEquipped = false
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