Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

SpeedBoostGui = script:WaitForChild("SpeedBoostGui")

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

SpeedBoost = {
	MaxFuel = 100,
	CurrentFuel = 100,
	IncreaseRate = 0.25,
	DecreaseRate = 0.5,
	UsageRate = (1 / 30),
	Regenerating = false,
	Active = false
}

Gravity = workspace.Gravity

Equipped = false

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

Handle.Transparency = 0
Tool.Enabled = true

ServerControl.OnServerInvoke = (function(player, Mode, Value)
	if player == Player then
		if Mode == "MouseClick" and Value.Down then
			Activated()
		elseif Mode == "KeyPress" and Value.Key == "0" then
			if Value.Down and not SpeedBoost.Active and SpeedBoost.CurrentFuel > (SpeedBoost.MaxFuel / 2) then
				if Humanoid and Humanoid.Parent then
					Humanoid.WalkSpeed = 32
				end
				SpeedBoost.Active = true
				while Equipped and SpeedBoost.Active and SpeedBoost.CurrentFuel > 0 do
					SpeedBoost.CurrentFuel = (SpeedBoost.CurrentFuel - SpeedBoost.DecreaseRate)
					FuelDisplay.Size = UDim2.new((1 / (SpeedBoost.MaxFuel / SpeedBoost.CurrentFuel)), 0, 1, 0)
					wait(SpeedBoost.Rate)
				end
				if Equipped and Humanoid and Humanoid.Parent then
					Humanoid.WalkSpeed = 24
				end
				SpeedBoost.Active = false
				SpeedBoost.CurrentFuel = ((SpeedBoost.CurrentFuel < 0 and 0) or SpeedBoost.CurrentFuel)
				RegenerateFuel()
			else
				if Equipped and Humanoid and Humanoid.Parent then
					Humanoid.WalkSpeed = 24
				end
				SpeedBoost.Active = false
				RegenerateFuel()
			end
		end
	end
end)

function InvokeClient(Mode, Value)
	pcall(function()
		local ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
		return ClientReturn
	end)
end

function RegenerateFuel()
	Spawn(function()
		if SpeedBoost.Regenerating then
			return
		end
		while --[[Equipped and]] not SpeedBoost.Active and SpeedBoost.CurrentFuel < SpeedBoost.MaxFuel do
			SpeedBoost.Regenerating = true
			SpeedBoost.CurrentFuel = (SpeedBoost.CurrentFuel + SpeedBoost.IncreaseRate)
			FuelDisplay.Size = UDim2.new((1 / (SpeedBoost.MaxFuel / SpeedBoost.CurrentFuel)), 0, 1, 0)
			wait(SpeedBoost.UsageRate)
		end
		SpeedBoost.Regenerating = false
		SpeedBoost.CurrentFuel = ((SpeedBoost.CurrentFuel > SpeedBoost.MaxFuel and SpeedBoost.MaxFuel) or SpeedBoost.CurrentFuel)
	end)
end

function Activated()
	if not Tool.Enabled then
		return
	end
end

function weldAttachments(attach1, attach2)
    local weld = Instance.new("Motor6D")
    weld.Part0 = attach1.Parent
    weld.Part1 = attach2.Parent
    weld.C0 = attach1.CFrame
    weld.C1 = attach2.CFrame
    weld.Parent = attach1.Parent
    return weld
end

function EquipShoes()
	if not Character or not Character.Parent then
		return
	end
	local Shoe = BasePart:Clone()
	Shoe.CanCollide = false
	Shoe.Size = Vector3.new(1.181, 1.726, 1.237)
	local Mesh = Instance.new("SpecialMesh")
	Mesh.MeshType = Enum.MeshType.FileMesh
	Mesh.Scale = Vector3.new(1, 1, 1)
	Mesh.TextureId = "rbxassetid://1230433331"
	Mesh.Parent = Shoe
	local Attachment = Instance.new("Attachment")
	Attachment.CFrame = CFrame.new(0, 0.3, 0.2, -1, 0, 0, 0, 0, 1, 0, 1, -0)
	Attachment.Parent = Shoe 
	LeftLeg = Character:FindFirstChild("Left Leg") or Character:FindFirstChild("LeftFoot")
	RightLeg = Character:FindFirstChild("Right Leg") or Character:FindFirstChild("RightFoot")
	local Offset = Humanoid and Humanoid.RigType == Enum.HumanoidRigType.R6 and -0.2 or 0
	if LeftLeg then	
		LeftShoe = Shoe:Clone()
		LeftShoe.Name = "LeftShoe"
		LeftShoe.Mesh.MeshId = "rbxassetid://909445948"		
		local LeftAttachment = LeftShoe:FindFirstChildOfClass("Attachment")
		if LeftAttachment then 
			LeftAttachment.Name = "LeftAnkleRigAttachment"	
		end
		local LeftAnkleAttachment = LeftLeg:FindFirstChild("LeftAnkleRigAttachment")
		if LeftAnkleAttachment then 
			weldAttachments(LeftAttachment, LeftAnkleAttachment)
		else
			local LeftWeld = Instance.new("Motor6D")
			LeftWeld.Part0 = LeftLeg
			LeftWeld.Part1 = LeftShoe
			
			LeftWeld.C0 = LeftAttachment.CFrame
			LeftWeld.C1 = CFrame.new(0, 0.52, 0.8)
			LeftWeld.Parent = LeftShoe
		end
		local Attachment0 = Instance.new("Attachment")
		Attachment0.CFrame = CFrame.new(-1.49999964, -2.3499999, 0.49999997, 1, 0, 0, 0, 1, 0, 0, 0, 1)
		Attachment0.Parent = Humanoid.RootPart 
		local Attachment1 = Instance.new("Attachment")				
		Attachment1.CFrame = CFrame.new(-0.550000072, -2.3499999, 0.49999997, 1, 0, 0, 0, 1, 0, 0, 0, 1)
		Attachment1.Parent = Humanoid.RootPart  
		local Trail = Instance.new("Trail")
		Trail.Texture = "rbxassetid://1230455325"
		Trail.Attachment0 = Attachment0
		Trail.Attachment1 = Attachment1	
		Trail.TextureMode = Enum.TextureMode.Static	
		Trail.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1)})	
		Trail.Lifetime = 10					
		Trail.Parent = Humanoid.RootPart  		
		
		LeftShoe.Parent = Character 
	end
	if RightLeg then
		RightShoe = Shoe:Clone()
		RightShoe.Name = "RightShoe"
		RightShoe.Mesh.MeshId = "rbxassetid://909446254"		
		
		local RightAttachment = RightShoe:FindFirstChildOfClass("Attachment")
		if RightAttachment then 
			RightAttachment.Name = "RightAnkleRigAttachment"	
		end	
		local RightAnkleAttachment = RightLeg:FindFirstChild("RightAnkleRigAttachment")
		if RightAnkleAttachment then 
			weldAttachments(RightAttachment, RightAnkleAttachment)
		else
			local RightWeld = Instance.new("Motor6D")
			RightWeld.Part0 = RightLeg
			RightWeld.Part1 = RightShoe
			RightWeld.C0 = RightAttachment.CFrame
			RightWeld.C1 = CFrame.new(0, 0.52, 0.8)
			RightWeld.Parent = RightShoe
		
		end
		local Attachment0 = Instance.new("Attachment")
		Attachment0.CFrame = CFrame.new(0.500000417, -2.3499999, 0.49999997, 1, 0, 0, 0, 1, 0, 0, 0, 1)
		Attachment0.Parent = Humanoid.RootPart 
		local Attachment1 = Instance.new("Attachment")				
		Attachment1.CFrame = CFrame.new(1.44999993, -2.3499999, 0.49999997, 1, 0, 0, 0, 1, 0, 0, 0, 1)
		Attachment1.Parent = Humanoid.RootPart 
		local Trail = Instance.new("Trail")
		Trail.Texture = "rbxassetid://1230455325"
		Trail.Attachment0 = Attachment0
		Trail.Attachment1 = Attachment1	 				
		Trail.TextureMode = Enum.TextureMode.Static	
		Trail.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1)})
		Trail.Lifetime = 10
		Trail.Parent = Humanoid.RootPart  	
		
		RightShoe.Parent = Character
	end
end

function GetTotalMass(Parent)
	local Mass = 0
	local function GetMass(Parent)
		for i, v in pairs(Parent:GetChildren()) do
			if v:IsA("BasePart") then
				Mass = (Mass + v:GetMass())
			end
			GetMass(v)
		end
	end
	GetMass(Parent)
	return Mass
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
	if not Player or not Humanoid or Humanoid.Health == 0 or not Torso then
		return
	end
	PlayerGui = Player:FindFirstChild("PlayerGui")
	Handle.Transparency = 1
	local Unequipped = false
	ToolUnequipped = Tool.Unequipped:connect(function()
		Unequipped = true
	end)
	wait()
	if not Unequipped and Humanoid.Parent then
		Equipped = true
		HumanoidJumped = Humanoid.Jumping:connect(function(Boolean)
			if Boolean and SpeedBoost.Active then
				if BodyVelocity and BodyVelocity.Parent then
					BodyVelocity:Destroy()
				end
				local Mass = (GetTotalMass(Character) * Gravity)
				BodyVelocity = Instance.new("BodyVelocity")
				BodyVelocity.maxForce = Vector3.new(0, (Mass), 0)
				BodyVelocity.velocity = Vector3.new(0, 1, 0) * 20
				Debris:AddItem(BodyVelocity, 0.5)
				BodyVelocity.Parent = Torso
			end
		end)
		if PlayerGui then
			SpeedBoostGuiClone = SpeedBoostGui:Clone()
			FuelDisplay = SpeedBoostGuiClone.Frame.FuelDisplay
			FuelDisplay.Size = UDim2.new((1 / (SpeedBoost.MaxFuel / SpeedBoost.CurrentFuel)), 0, 1, 0)
			SpeedBoostGuiClone.Parent = PlayerGui
		end
		EquipShoes()
		Humanoid.WalkSpeed = 20
		Humanoid.StateChanged:Connect(function(oldState, newState)
			local Enabled = true
			if newState == Enum.HumanoidStateType.FallingDown or newState == Enum.HumanoidStateType.Freefall or newState == Enum.HumanoidStateType.Jumping then
				Enabled = false
			end
			for _, v in next, Humanoid.RootPart:GetChildren() do
				if v:IsA("Trail") then
					v.Enabled = Enabled
				end
			end				
		end)
		RegenerateFuel()
	end
end

function Unequipped()
	Equipped = false
	Handle.Transparency = 0
	for i, v in pairs({ToolUnequipped, HumanoidJumped}) do
		if v then
			v:disconnect()
		end
	end
	for i, v in pairs({LeftShoe, RightShoe, SpeedBoostGuiClone, BodyVelocity}) do
		if v and v.Parent then
			v:Destroy()
		end
	end
	if Humanoid and Humanoid.Parent then
		Humanoid.WalkSpeed = 16
	end
	
	for _, v in next, Humanoid.RootPart:GetChildren() do
		if v:IsA("Trail") or v.Name == "Attachment0" or v.Name == "Attachment1" then
			v:Destroy()
		end
	end
end

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)

workspace:GetPropertyChangedSignal("Gravity"):Connect(function()
	Gravity = workspace.Gravity
end)