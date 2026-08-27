Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

BaseUrl = "http://www.roblox.com/asset/?id="

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

DamageScript = script:WaitForChild("DamageScript")

Animations = {
	Hold = {Animation = Tool:WaitForChild("Hold"), FadeTime = nil, Weight = nil, Speed = nil},
	Spin = {Animation = Tool:WaitForChild("Spin"), FadeTime = nil, Weight = nil, Speed = 0.5},
	
	R15Hold = {Animation = Tool:WaitForChild("R15Hold"), FadeTime = nil, Weight = nil, Speed = nil},
	R15Spin = {Animation = Tool:WaitForChild("R15Spin"), FadeTime = nil, Weight = nil, Speed = 0.5}	
}

Sounds = {
	Spin = Handle:WaitForChild("Spin"),
	Swish = Handle:WaitForChild("Swish"),
	HitGround = Handle:WaitForChild("HitGround"),
}

Damage = {Min = 10, Max = 20}
ThrowVelocity = {Min = 50, Max = 100}

ReloadTime = 3

Spinning = false
ToolEquipped = false

Gravity = workspace.Gravity
Rate = (1 / 60)

Weight = Instance.new("Model")
Weight.Name = "Weight"
Pole = BasePart:Clone()
Pole.Name = "Pole"
Pole.Transparency = 0
Pole.Size = Vector3.new(7, 0.5, 0.5)
Pole.Parent = Weight
PoleMesh = Instance.new("SpecialMesh")
PoleMesh.MeshType = Enum.MeshType.FileMesh
PoleMesh.MeshId = (BaseUrl .. "232700238")
PoleMesh.TextureId = (BaseUrl .. "232700611")
PoleMesh.Scale = Vector3.new(4.5, 2, 2)
PoleMesh.VertexColor = Vector3.new(1, 1, 1)
PoleMesh.Offset = Vector3.new(0, 0, 0)
PoleMesh.Parent = Pole
LeftWeights = BasePart:Clone()
LeftWeights.Name = "LeftWeights"
LeftWeights.Transparency = 1
LeftWeights.Size = Vector3.new(1.2, 1.8, 1.8)
LeftWeights.Parent = Weight
LeftWeightsWeld = Instance.new("Weld")
LeftWeightsWeld.Part0 = Pole
LeftWeightsWeld.Part1 = LeftWeights
LeftWeightsWeld.C0 = CFrame.new(2.55, 0, 0)
LeftWeightsWeld.Parent = LeftWeights
RightWeights = BasePart:Clone()
RightWeights.Name = "RightWeights"
RightWeights.Transparency = 1
RightWeights.Size = Vector3.new(1.2, 1.8, 1.8)
RightWeights.Parent = Weight
RightWeightsWeld = Instance.new("Weld")
RightWeightsWeld.Part0 = Pole
RightWeightsWeld.Part1 = RightWeights
RightWeightsWeld.C0 = CFrame.new(-2.55, 0, 0)
RightWeightsWeld.Parent = RightWeights

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

Handle.Transparency = 0
Tool.Enabled = true

for i, v in pairs(Tool:GetChildren()) do
	if v:IsA("BasePart") and v ~= Handle then
		v:Destroy()
	end
end

if Tool:FindFirstChild("Display") then
	Tool.Display:Destroy()
end

function Clamp(Number, Min, Max)
	return math.max(math.min(Max, Number), Min)
end

function GetPercentage(Start, End, Number)
	return (((Number - Start) / (End - Start)) * 100)
end

function Round(Number, RoundDecimal)
	local WholeNumber, Decimal = math.modf(Number)
	return ((Decimal >= RoundDecimal and math.ceil(Number)) or (Decimal < RoundDecimal and math.floor(Number)))
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
	Spawn(function()
		local Limbs = {"Left Arm", "Right Arm", "LeftHand", "RightHand", "LeftLowerArm", "RightLowerArm", "LeftUpperArm", "RightUpperArm"}
		for i, v in pairs(Limbs) do
			local Limb = Character:FindFirstChild(v)
			if Limb then
				Spawn(function()
					InvokeClient("SetLocalTransparencyModifier", {Object = Limb, Transparency = 0, AutoUpdate = false})
				end)
			end
		end
		for i, v in pairs(Tool:GetChildren()) do
			if v:IsA("BasePart") and v ~= Handle then
				v:Destroy()
			end
		end
		if LeftArm then
			FakeHandle = Handle:Clone()
			FakeHandle.Name = "FakeHandle"
			local FakeHandleWeld = Instance.new("Weld")
			FakeHandleWeld.Part0 = LeftArm
			FakeHandleWeld.Part1 = FakeHandle
			local Offset = -1
			if LeftArm.Name == "LeftHand" then
				Offset = -0.2
			end
			FakeHandleWeld.C0 = CFrame.new(0, Offset, 0, 1, 0, -0, 0, 0, 1, 0, -1, -0)
			FakeHandleWeld.C1 = Tool.Grip
			FakeHandleWeld.Parent = FakeHandle
			FakeHandle.Parent = Tool
		end
		
		if Head then 
			HeadHandle = Handle:Clone()
			HeadHandle.Name = "HeadHandle"
			local FakeHandleWeld = Instance.new("Weld")
			FakeHandleWeld.Part0 = Head
			FakeHandleWeld.Part1 = HeadHandle
			FakeHandleWeld.C0 = CFrame.new()
			FakeHandleWeld.C1 = CFrame.new(0, 0, 0.75, 1, 0, -0, 0, 0, 1, 0, -1, -0)
			FakeHandleWeld.Parent = HeadHandle
			HeadHandle.Parent = Tool
		end
		local Animation = Animations.Hold
		if Humanoid and Humanoid.RigType == Enum.HumanoidRigType.R15 then
			Animation = Animations.R15Hold
		end
		InvokeClient("PlayAnimation", Animation)
	end)
	ToolEquipped = true
end

function Unequipped()
	if FakeHandle and FakeHandle.Parent then
		FakeHandle:Destroy()
	end
	
	if HeadHandle and HeadHandle.Parent then
		HeadHandle:Destroy()
	end
	for i, v in pairs(Sounds) do
		v:Stop()
	end
	Spinning = false
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
	if Mode == "MouseClick" then
		local Down = Value.Down
		if Down and Tool.Enabled and not Spinning then
			Spinning = true
			Sounds.Spin.Pitch = 1
			Sounds.Spin:Stop()
			Spawn(function()
				local StartTime = tick()
				local EndTime = (StartTime + 2.5)
				local MaxSpeed = 1.5
				local Animation = Animations.Spin
				if Humanoid and Humanoid.RigType == Enum.HumanoidRigType.R15 then
					Animation = Animations.R15Spin
				end
				DesiredSpeed = Animation.Speed
				DesiredDamage = Damage.Min
				DesiredThrowVelocity = ThrowVelocity.Min
				while ToolEquipped and Spinning and CheckIfAlive() do
					local CurrentTime = tick()
					local CurrentCharge = math.abs(CurrentTime - StartTime)
					local ChargePercent = Clamp(GetPercentage(StartTime, EndTime, CurrentTime), 0, 100)
					local ChargePercentToDecimal = (ChargePercent * 0.01)
					DesiredSpeed = Clamp((MaxSpeed * ChargePercentToDecimal), Animation.Speed, MaxSpeed)
					DesiredDamage = Clamp((Damage.Max * ChargePercentToDecimal), Damage.Min, Damage.Max)
					DesiredThrowVelocity = Clamp((ThrowVelocity.Max * ChargePercentToDecimal), ThrowVelocity.Min, ThrowVelocity.Max)
					if DesiredSpeed >= 1 and not Sounds.Spin.IsPlaying then
						Sounds.Spin:Play()
					end
					Sounds.Spin.Pitch = Clamp((1 * ChargePercentToDecimal), 1, 1.75)
					InvokeClient("PlayAnimation", {Animation = Animation.Animation, FadeTime = Animation.FadeTime, Weight = Animation.Weight, Speed = DesiredSpeed})
					wait(Rate)
				end
			end)
		elseif not Down and Spinning then
			Spinning = false
			Sounds.Spin:Stop()
			if DesiredSpeed and DesiredSpeed > 1 then
				Tool.Enabled = false
				Sounds.Swish:Play()
				local TargetPosition = InvokeClient("MousePosition").Position
				local Weights = {
					{Arm = Character:FindFirstChild("Left Arm") or Character:FindFirstChild("LeftHand"), Weight = FakeHandle},
					{Arm = Character:FindFirstChild("Right Arm") or Character:FindFirstChild("RightHand"), Weight = Handle}
				}
				for i, v in pairs(Weights) do
					if v.Arm and v.Arm.Parent and v.Weight and v.Weight.Parent then
						local StartPosition = v.Weight.CFrame
						local Direction = CFrame.new(StartPosition.p, TargetPosition)
						local WeightClone = Weight:Clone()
						for i, v in pairs(WeightClone:GetChildren()) do
							if v:IsA("BasePart") then
								v.CanCollide = false
							end
						end
						WeightClone.Pole.CFrame = (StartPosition + Direction.lookVector * (Pole.Size.Z * 2))
						WeightClone.Pole.Velocity = Direction.lookVector * DesiredThrowVelocity
						local HitGround = Sounds.HitGround:Clone()
						HitGround.Parent = WeightClone.Pole
						local DamageScriptClone = DamageScript:Clone()
						local Creator = Instance.new("ObjectValue")
						Creator.Name = "Creator"
						Creator.Value = Player
						Creator.Parent = DamageScriptClone
						local Damage = Instance.new("NumberValue")
						Damage.Name = "Damage"
						Damage.Value = DesiredDamage
						Damage.Parent = DamageScriptClone
						DamageScriptClone.Disabled = false
						DamageScriptClone.Parent = WeightClone
						Debris:AddItem(WeightClone, 5)
						WeightClone.Parent = game:GetService("Workspace")
					end
				end
				Spawn(function()
					for i, v in pairs({Handle, FakeHandle}) do
						v.Transparency = 1
					end
					wait(ReloadTime)
					for i, v in pairs({Handle, FakeHandle}) do
						v.Transparency = 0
					end
					Tool.Enabled = true
				end)
			end
			Spawn(function()
				local Animation = Animations.Spin
				if Humanoid and Humanoid.RigType == Enum.HumanoidRigType.R15 then
					Animation = Animations.R15Spin
				end
				InvokeClient("StopAnimation", {Animation = Animation.Animation, FadeTime = nil})
			end)
		end
	end
end)

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)

workspace:GetPropertyChangedSignal("Gravity"):Connect(function()
	Gravity = workspace.Gravity
end)