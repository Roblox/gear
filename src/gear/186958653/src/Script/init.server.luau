--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

ConfusionScript = script:WaitForChild("ConfusionScript")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

BasePart = Instance.new("Part")
BasePart.Material = Enum.Material.Plastic
BasePart.Shape = Enum.PartType.Block
BasePart.TopSurface = Enum.SurfaceType.Smooth
BasePart.BottomSurface = Enum.SurfaceType.Smooth
BasePart.FormFactor = Enum.FormFactor.Custom
BasePart.CanCollide = true
BasePart.Locked = true
BasePart.Anchored = false

BaseFlail = BasePart:Clone()
BaseFlail.Name = "Flail"
BaseFlail.Size = Vector3.new(1, 1, 2)
FlailMesh = Instance.new("SpecialMesh")
FlailMesh.MeshType = Enum.MeshType.FileMesh
FlailMesh.MeshId = "http://www.roblox.com/asset/?id=186739053"
FlailMesh.TextureId = "http://www.roblox.com/asset/?id=186516726"
FlailMesh.Offset = Vector3.new(0, 0, 0)
FlailMesh.Scale = Vector3.new(1, 1, 1)
FlailMesh.VertexColor = Vector3.new(1, 1, 1)
FlailMesh.Parent = BaseFlail

IceTexture = "http://www.roblox.com/asset/?id=186936495"

Animations = {
	HoldUp = {Animation = Tool:WaitForChild("HoldUp"), FadeTime = nil, Weight = nil, Speed = 6, Duration = 1},
	HoldUpLooped = {Animation = Tool:WaitForChild("HoldUpLooped"), FadeTime = nil, Weight = nil, Speed = 0.75, Duration = nil},
	HoldDown = {Animation = Tool:WaitForChild("HoldDown"), FadeTime = nil, Weight = nil, Speed = 6, Duration = 1},
	HoldDownLooped = {Animation = Tool:WaitForChild("HoldDownLooped"), FadeTime = nil, Weight = nil, Speed = 0.75, Duration = nil},
	HoldCompleteDown = {Animation = Tool:WaitForChild("HoldCompleteDown"), FadeTime = nil, Weight = nil, Speed = 3, Duration = 1},
	Swing = {Animation = Tool:WaitForChild("Swing"), FadeTime = nil, Weight = nil, Speed = 6, Duration = nil},
	
	R15HoldUp = {Animation = Tool:WaitForChild("R15HoldUp"), FadeTime = nil, Weight = nil, Speed = 6, Duration = 1},
	R15HoldUpLooped = {Animation = Tool:WaitForChild("R15HoldUpLooped"), FadeTime = nil, Weight = nil, Speed = 0.75, Duration = nil},
	R15HoldDown = {Animation = Tool:WaitForChild("R15HoldDown"), FadeTime = nil, Weight = nil, Speed = 6, Duration = 1},
	R15HoldDownLooped = {Animation = Tool:WaitForChild("R15HoldDownLooped"), FadeTime = nil, Weight = nil, Speed = 0.75, Duration = nil},
	R15HoldCompleteDown = {Animation = Tool:WaitForChild("R15HoldCompleteDown"), FadeTime = nil, Weight = nil, Speed = 3, Duration = 1},
	R15Swing = {Animation = Tool:WaitForChild("R15Swing"), FadeTime = nil, Weight = nil, Speed = 6, Duration = nil},	
}

Sounds = {
	Hit = Handle:WaitForChild("Hit"),
	Swing = Handle:WaitForChild("Swing"),
	Spin = Handle:WaitForChild("Spin")
}

Damages = {
	Touched = {Damage = 8},
	Hit = {Damage = 15},
	Slash = {Damage = 20},
	SwingHit = {Damage = 10},
	SwingBash = {Damage = 12.5}
}

CurrentDamage = Damages.Touched

Clicks = 0
FirstClick = false

ToolEquipped = false
MouseDown = false
Spinning = false
AnimPlaying = false

ReloadTime = 0.25

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

ServerControl.OnServerInvoke = (function(player, Mode, Value)
	if player == Player and ToolEquipped and CheckIfAlive() then
		if Mode == "KeyPress" then
			local Key = Value.Key
			local Down = Value.Down
			if Key == "q" and Flail and Flail.Parent and FlailMotor and FlailMotor.Parent then
			end
		elseif Mode == "MouseClick" then
			if Value.Down then
				MouseDown = true
				Activated()
			else
				if Spinning and MouseDown then
					Tool.Enabled = false
					Sounds.Spin:Stop()
					Sounds.Swing:Play()
					Spinning = false
					local Animation = Animations.Swing
					if Humanoid and Humanoid.RigType == Enum.HumanoidRigType.R15 then
						Animation = Animations.R15Swing
					end
					FlailMotor.C0 = CFrame.Angles(0, -(math.pi / 2), 0) + Vector3.new(0, 0.0125, -1.05)
					FlailMotor.C1 = CFrame.Angles(0, -(math.pi / 2), 0) - Vector3.new(0, -0.0125, -1.95)
					FlailMotor.MaxVelocity = math.huge
					FlailMotor.DesiredAngle = 0
					FlailMotor.CurrentAngle = FlailMotor.DesiredAngle
					local HoldDown = Animations.HoldCompleteDown
					if Humanoid and Humanoid.RigType == Enum.HumanoidRigType.R15 then
						HoldDown = Animations.R15HoldCompleteDown
					end						
					local HoldDownAnimation = {Animation = HoldDown.Animation, FadeTime = HoldDown.FadeTime, Weight = HoldDown.Weight, Speed = 10, Duration = 0.5}				
					SetCurrentDamage((HoldDownAnimation.Duration / 2), Damages.SwingBash)
					InvokeClient("StopAnimation", Animation)
					InvokeClient("PlayAnimation", HoldDownAnimation)
					wait(HoldDownAnimation.Duration / 2)
					FlailMotor.MaxVelocity = -0.1
					FlailMotor.DesiredAngle = 2.75
					wait(ReloadTime * 2)
					AnimPlaying = false
					Tool.Enabled = true
				end
				MouseDown = false
			end
		end
	end
end)

function InvokeClient(Mode, Value)
	local ReturnValue = nil
	pcall(function()
		ReturnValue = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ReturnValue
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

function SetCurrentDamage(Delay, Damage)
	Spawn(function()
		CurrentDamage = Damage
		if not ToolEquipped or not Delay then
			return
		end
		if DelayToolUnequipped then
			DelayToolUnequipped:disconnect()
		end
		local CurrentlyEquipped = true
		DelayToolUnequipped = Tool.Unequipped:connect(function()
			CurrentlyEquipped = false
		end)
		wait(Delay)
		if not DelayToolUnequipped.connected then
			return
		end
		if DelayToolUnequipped then
			DelayToolUnequipped:disconnect()
		end
		if not CurrentlyEquipped then
			return
		end
		CurrentDamage = Damages.Touched
	end)
end

function CreateFlail()
	if not Flail or not Flail.Parent or not FlailMotor or not FlailMotor.Parent then
		if Flail and Flail.Parent then
			Flail:Destroy()
		end
		for i, v in pairs(Tool:GetChildren()) do
			if v:IsA("BasePart") and v.Name == "Flail" then
				v:Destroy()
			end
		end
		Flail = BaseFlail:Clone()
		Flail.CanCollide = false
		FlailMotor = Instance.new("Motor6D")
		FlailMotor.Name = "Motor"
		FlailMotor.Part0 = Handle
		FlailMotor.Part1 = Flail
		FlailMotor.C0 = CFrame.Angles(0, -(math.pi / 2), 0) + Vector3.new(0, 0.0125, -1.05)
		FlailMotor.C1 = CFrame.Angles(0, -(math.pi / 2), 0) - Vector3.new(0, -0.0125, -1.95)
		FlailMotor.MaxVelocity = -0.1
		FlailMotor.DesiredAngle = 2.75
		FlailMotor.CurrentAngle = FlailMotor.DesiredAngle
		FlailMotor.Parent = Flail
		Flail.Parent = Tool
		Flail.Touched:connect(function(Hit)
			if not Hit or not Hit.Parent then
				return
			end
			local character = Hit.Parent
			if character == Character then
				return
			end
			local humanoid = character:FindFirstChild("Humanoid")
			local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
			if humanoid and humanoid.Health > 0 then
				Sounds.Hit:Play()
				UntagHumanoid(humanoid)
				TagHumanoid(humanoid, Player)
				humanoid:TakeDamage(CurrentDamage.Damage)
				if CurrentDamage == Damages.Slash then
					torso.Velocity = CFrame.new(Handle.Position, torso.Position).lookVector * 100
				elseif CurrentDamage == Damages.SwingHit then
					torso.Velocity = CFrame.new(Handle.Position, torso.Position).lookVector * 50
				elseif CurrentDamage == Damages.SwingBash then
					local ConfusionScriptClone = humanoid:FindFirstChild("ConfusionScript")
					if not ConfusionScriptClone then
						ConfusionScriptClone = ConfusionScript:Clone()
						local DurationValue = Instance.new("NumberValue")
						DurationValue.Name = "Duration"
						DurationValue.Value = 5
						DurationValue.Parent = ConfusionScriptClone
						ConfusionScriptClone.Disabled = false
						ConfusionScriptClone.Parent = humanoid
					end
				end
			end
		end)
	end
end

function Activated()
	if not ToolEquipped or not CheckIfAlive() and Flail and Flail.Parent and FlailMotor and FlailMotor.Parent then
		return
	end
	Clicks = (Clicks + 1)
	if not Tool.Enabled then
		return
	end
	if not FirstClick then
		FirstClick = true
		local CurrentlyEquipped = true
		ToolUnequipped = Tool.Unequipped:connect(function()
			CurrentlyEquipped = false
		end)
		wait(0.15)
		Tool.Enabled = false
		if ToolUnequipped then
			ToolUnequipped:disconnect()
		end
		if not CurrentlyEquipped or AnimPlaying then
			return
		end
		if Clicks > 1 then
			AnimPlaying = true
			local HoldUp = Animations.HoldUp
			local HoldDown = Animations.HoldCompleteDown
			if Humanoid and Humanoid.RigType == Enum.HumanoidRigType.R15 then
				HoldUp = Animations.R15HoldUp
				HoldDown = Animations.R15HoldCompleteDown
			end				
			local HoldUpAnimation = {Animation = HoldUp.Animation, FadeTime = HoldUp.FadeTime, Weight = HoldUp.Weight, Speed = 15, Duration = 0.5}
			local HoldDownAnimation = {Animation = HoldDown.Animation, FadeTime = HoldDown.FadeTime, Weight = HoldDown.Weight, Speed = 10, Duration = 0.5}
		
			SetCurrentDamage((HoldUpAnimation.Duration + (HoldDownAnimation.Duration / 2)), Damages.Slash)
			FlailMotor.DesiredAngle = 0
			InvokeClient("PlayAnimation", HoldUpAnimation)
			wait(HoldUpAnimation.Duration)
			Sounds.Swing:Play()
			InvokeClient("PlayAnimation", HoldDownAnimation)
			wait(HoldDownAnimation.Duration / 2)
			FlailMotor.DesiredAngle = 2.75
			wait(HoldDownAnimation.Duration / 2)
			AnimPlaying = false
		else
			if MouseDown and not Spinning then
				AnimPlaying = true
				Spinning = true
				Sounds.Spin:Play()
				local Animation = Animations.Swing
				if Humanoid and Humanoid.RigType == Enum.HumanoidRigType.R15 then
					Animation = Animations.R15Swing
				end
				InvokeClient("PlayAnimation", Animation)
				FlailMotor.C0 = CFrame.Angles(0,0,0) + Vector3.new(0, 0.0125, -1.05)
				FlailMotor.C1 = CFrame.Angles((math.pi / 2), 0, 0) - Vector3.new(0, -0.0125, -1.95)
				FlailMotor.MaxVelocity = -0.15
				FlailMotor.DesiredAngle = 999999999
				SetCurrentDamage(nil, Damages.SwingHit)
			else
				AnimPlayng = true
				local HoldUp = Animations.HoldUp				
				local HoldDown = Animations.HoldDown
				if Humanoid and Humanoid.RigType == Enum.HumanoidRigType.R15 then
					HoldUp = Animations.R15HoldUp
					HoldDown = Animations.R15HoldDown
				end
				local HoldUpAnimation = {Animation = HoldUp.Animation, FadeTime = HoldUp.FadeTime, Weight = HoldUp.Weight, Speed = 15, Duration = 0.5}
				local HoldDownAnimation = {Animation = HoldDown.Animation, FadeTime = HoldDown.FadeTime, Weight = HoldDown.Weight, Speed = 15, Duration = 0.5}			
				SetCurrentDamage((HoldUpAnimation.Duration + (HoldDownAnimation.Duration / 2)), Damages.Hit)
				InvokeClient("PlayAnimation", HoldUpAnimation)
				FlailMotor.DesiredAngle = (0 - (math.random(0, 50) * 0.01))
				wait(HoldUpAnimation.Duration)
				Sounds.Swing:Play()
				InvokeClient("PlayAnimation", HoldDownAnimation)
				FlailMotor.DesiredAngle = (2.75 + (math.random(0, 75) * 0.01)) 
				wait(HoldDownAnimation.Duration / 2)
				FlailMotor.DesiredAngle = 2.75
				AnimPlaying = false
			end
		end
		if not MouseDown then
			wait(ReloadTime)
		end
		FirstClick = false
		Clicks = 0
		Tool.Enabled = true
	end
end

function CheckIfAlive()
	return (Player and Player.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0)
end

function Equipped(Mouse)
	ToolEquipped = true
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	if not CheckIfAlive() then
		return
	end
	for i, v in pairs(Animations) do
		InvokeClient("Preload", v.Animation.AnimationId)
	end
	for i, v in pairs(Sounds) do
		InvokeClient("Preload", v.SoundId)
	end
	Spawn(function()
		CreateFlail()
	end)
end

function Unequipped()
	ToolEquipped = false
	MouseDown = false
	Spinning = false
	AnimPlaying = false
	Clicks = 0
	FirstClick = false
	SetCurrentDamage(nil, Damages.Touched)
	Spawn(function()
		CreateFlail()
	end)
	for i, v in pairs({ToolUnequipped, DelayToolUnequipped}) do
		if v then
			v:disconnect()
		end
	end
	for i, v in pairs(Animations) do
		InvokeClient("StopAnimation", v)
	end
	for i, v in pairs(Sounds) do
		v:Stop()
		InvokeClient("StopSound", v)
	end
end

for i, v in pairs(Tool:GetChildren()) do
	if v:IsA("BasePart") and v ~= Handle then
		v:Destroy()
	end
end

CreateFlail()
Tool.Enabled = true

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)