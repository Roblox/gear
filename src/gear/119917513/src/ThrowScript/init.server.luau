--Rescripted by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

ProjectileScript = script:WaitForChild("ProjectileScript")
Remover = script:WaitForChild("Remover")

Treehouse = Tool:WaitForChild("Treehouse")

BoundingBox = Treehouse:WaitForChild("BoundingBox")

ProjectileSpeed = 100

Tool.Enabled = true

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

ServerControl.OnServerInvoke = (function(Player, Mode, Value)
	if Mode == "Button1Click" and Value.Down then
		local MousePosition = InvokeClient("MousePosition", nil)
		Activated(MousePosition)
	end
end)

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
end

function WeldInPlace(Part0, Part1, Name)
	local Weld = Instance.new("ManualWeld")
	Weld.Part0 = Part0
	Weld.Part1 = Part1
	Weld.C0 = CFrame.new()
	Weld.C1 = Part1.CFrame:inverse() * Part0.CFrame
	if Name then
		Weld.Name = Name
	end
	Weld.Parent = Part0
end

function WeldEverythingInPlace(Model, Part0)
	for i, v in pairs(Model:GetChildren()) do
		if v:IsA("BasePart") and v ~= Part0 then
			WeldInPlace(Part0, v, ("WeldTo" .. v.Name))
		elseif v:IsA("Model") then
			WeldEverythingInPlace(v, Part0)
		end
	end
end

function ApplyToModelParts(Function, Model, ...)
	for i, v in pairs(Model:GetChildren()) do
		if v:IsA("BasePart") then
			Function(v, ...)
		elseif v:IsA("Model") then
			ApplyToModelParts(Function, v, ...)
		end
	end
end

function RemakeWelds()
	WeldEverythingInPlace(Treehouse, BoundingBox)
end

function Activated(MousePosition)
	if not Tool.Enabled or not CheckIfAlive() or not MousePosition then 
		return 
	end
	
	while game:GetService("Workspace"):FindFirstChild(Player.Name .. Treehouse.Name) and Equipped do
		local Treehouse = game:GetService("Workspace"):FindFirstChild(Player.Name .. Treehouse.Name)
		if Treehouse then
			Treehouse:Destroy()
		end
		wait(0.001)
	end

	if not Equipped then
		return
	end
	
	local Direction = CFrame.new(Handle.Position, MousePosition)
	
	local TreehouseClone = Treehouse:Clone()
	TreehouseClone.Name = (Player.Name .. Treehouse.Name)

	local BoundingBoxClone = TreehouseClone:FindFirstChild("BoundingBox")
	if BoundingBoxClone then
		for i, v in pairs(BoundingBoxClone:GetChildren()) do
			if v:IsA("JointInstance") and (v.Part0 == Handle or v.Part1 == Handle) then
				v:Destroy()
			end
		end
		local Creator = Instance.new("ObjectValue")
		Creator.Name = "Creator"
		Creator.Value = Player
		Creator.Parent = TreehouseClone
		local RemoverValue = Instance.new("BoolValue")
		RemoverValue.Value = false
		RemoverValue.Name = "Remove"
		RemoverValue.Parent = TreehouseClone
		TreehouseClone.Parent = game:GetService("Workspace")
		BoundingBoxClone.CFrame = BoundingBoxClone.CFrame + Direction.lookVector * (((BoundingBoxClone.Size.Z / 2) + (Handle.Size.Z / 2)) * 3)
		local NewVelocity = Vector3.new(0, 0, 0) + Direction.lookVector * ProjectileSpeed
		
		ApplyToModelParts(function(Part)
			Part.Velocity = NewVelocity 
			Part.CanCollide = true
		end, TreehouseClone)
		BoundingBoxClone.CanCollide = false
		local BodyGyro = Instance.new("BodyGyro")
		BodyGyro.maxTorque = Vector3.new(math.huge, math.huge, math.huge)
		BodyGyro.cframe = CFrame.new(TreehouseClone:GetModelCFrame().p, Vector3.new(Torso.Position.X, TreehouseClone:GetModelCFrame().p.Y, Torso.Position.Z))
		BodyGyro.Parent = BoundingBoxClone
		local ProjectileScriptClone = ProjectileScript:Clone()
		ProjectileScriptClone.Disabled = false
		ProjectileScriptClone.Parent = TreehouseClone
		local RemoverClone = Remover:Clone()
		RemoverClone.Disabled = false
		RemoverClone.Parent = TreehouseClone
	end
	
end

function CheckIfAlive()
	return (Player and Player.Parent and Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent)
end

function Equipped()
	-- All welds are destroyed on unequip!
	RemakeWelds()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso")
	if not CheckIfAlive() then
		return
	end
	local WeldToHandle = BoundingBox:FindFirstChild("WeldToHandle")
	if WeldToHandle then
		WeldToHandle:Destroy()
	end
	local Weld = Instance.new("ManualWeld")
	Weld.Part0 = Handle
	Weld.Part1 = BoundingBox
	Weld.Name = "WeldToHandle"
	Weld.Parent = BoundingBox
	Equipped = true
end

function Unequipped()
	Equipped = false
end

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)
Tool.Activated:connect(Activated)