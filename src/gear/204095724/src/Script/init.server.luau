--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

CameraShake = script:WaitForChild("CameraShake")

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

Animations = {
	Bash = {Animation = Tool:WaitForChild("Bash"), FadeTime = nil, Weight = nil, Speed = 2, Duration = 0.5, Damage = {Min = 10, Max = 15}},
	TwoHandBash = {Animation = Tool:WaitForChild("TwoHandBash"), FadeTime = nil, Weight = nil, Speed = 2, Duration = 0.5, Damage = {Min = 20, Max = 25}},
	HoldBash = {Animation = Tool:WaitForChild("HoldBash"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil},
	StrongBash = {Animation = Tool:WaitForChild("StrongBash"), FadeTime = nil, Weight = nil, Speed = 2, Duration = 0.5, Damage = {Min = 25, Max = 35}},
	ReleaseHoldAndBash = {Animation = Tool:WaitForChild("ReleaseHoldAndBash"), FadeTime = nil, Weight = nil, Speed = 4, Duration = 0.5, Damage = {Min = 30, Max = 40}}
}

Sounds = {
	Swing1 = Handle:WaitForChild("Swing1"),
	Swing2 = Handle:WaitForChild("Swing2"),
	Swing3 = Handle:WaitForChild("Swing3"),
	Swing4 = Handle:WaitForChild("Swing4"),
	Hit = Handle:WaitForChild("Hit"),
}

TouchDamage = {Min = 5, Max = 8}

ToolEquipped = false
MouseDown = false

Clicks = 0
FirstClick = false

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

Tool.Enabled = true

ServerControl.OnServerInvoke = (function(player, Mode, Value)
	if player == Player then
		if Mode == "MouseClick" then
			local Down = Value.Down
			if Down and not MouseDown then
				MouseDown = true
				Activated()
			elseif not Down and MouseDown then
				MouseDown = false
				if CurrentAnimation == Animations.HoldBash then
					Humanoid.WalkSpeed = 0
					local AttackSounds = {Sounds.Swing1, Sounds.Swing2, Sounds.Swing3, Sounds.Swing4}
					InvokeClient("StopAnimation", Animations.HoldBash)
					local AttackAnims = {Animations.ReleaseHoldAndBash, Animations.StrongBash}
					Attack(AttackAnims, AttackSounds)
					Humanoid.WalkSpeed = 16
				end
			end
		end
	end
end)

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
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

function SpinHead(character)
	if not character or character:FindFirstChild("SpinningHead") then
		return
	end
	local player = Players:GetPlayerFromCharacter(character)
	local torso = character:FindFirstChild("Torso")
	if not torso then
		return
	end
	local neck = torso:FindFirstChild("Neck")
	if not neck then
		return
	end
	local CameraShakeClone
	if player then
		local PlayerGui = player:FindFirstChild("PlayerGui")
		if PlayerGui then
			CameraShakeClone = CameraShake:Clone()
			local Duration = Instance.new("NumberValue")
			Duration.Name = "Duration"
			Duration.Value = 2
			Duration.Parent = CameraShakeClone
			CameraShakeClone.Disabled = false
			Debris:AddItem(CameraShakeClone, 3)
			CameraShakeClone.Parent = PlayerGui		
		end
	end
	local SpinningHead = Instance.new("StringValue")
	SpinningHead.Name = "SpinningHead"
	Debris:AddItem(SpinningHead, 3)
	SpinningHead.Parent = character
	local Frames = 16
	for i = 1, Frames do
		neck.C1 = neck.C1 * CFrame.Angles(0, 0, ((math.pi * 2) / Frames))
		wait()
	end
	neck.C1 = CFrame.new(0, -0.5, 0, -1, -0, -0, 0, 0, 1, 0, 1, 0)
	for i, v in pairs({SpinningHead, CameraShakeClone}) do
		if v and v.Parent then
			v:Destroy()
		end
	end
end

function Blow(Hit)
	if not Hit or not Hit.Parent or not CheckIfAlive() then
		return
	end
	local character = Hit.Parent
	local humanoid = character:FindFirstChild("Humanoid")
	if character == Character or not humanoid or humanoid.Health == 0 then
		return
	end
	local RightArm = Character:FindFirstChild("Right Arm")
	if not RightArm then
		return
	end
	local RightGrip = RightArm:FindFirstChild("RightGrip")
	if not RightGrip or (RightGrip.Part0 ~= RightArm and RightGrip.Part1 ~= RightArm) then
		return
	end
	
	if CurrentAnimation and CurrentAnimation ~= Animations.HoldBash then
		Sounds.Hit:Play()
	end
	
	if CurrentAnimation == Animations.TwoHandBash then
		local torso = character:FindFirstChild("Torso")
		if torso then
			torso.Velocity = CFrame.new(Torso.Position, torso.Position).lookVector * 10
			humanoid.Sit = true
		end
	elseif CurrentAnimation == Animations.Bash then
		SpinHead(character)
	elseif CurrentAnimation == Animations.StrongBash or CurrentAnimation == Animations.TwoHandBash then
	end
		
	UntagHumanoid(humanoid)
	TagHumanoid(humanoid, Player)
	
	local DamageValue = ((CurrentAnimation and CurrentAnimation.Damage) or TouchDamage)
	local DamageAmount = math.random(DamageValue.Min, DamageValue.Max)
	
	humanoid:TakeDamage(DamageAmount)
	
	if humanoid.Health == 0 then
		local head = character:FindFirstChild("Head")
		if head then
			for i, v in pairs(head:GetChildren()) do
				v:Destroy()
			end
			local Skull = Instance.new("SpecialMesh")
			Skull.MeshType = Enum.MeshType.FileMesh
			Skull.MeshId = "http://www.roblox.com/asset/?id=4770583"
			Skull.TextureId = "http://www.roblox.com/asset/?id=4770560"
			Skull.Scale = Vector3.new(3.2, 3.2, 3.2)
			Skull.VertexColor = Vector3.new(1, 1, 1)
			Skull.Parent = head
		end
	end
	
end

function Attack(PossibleAnims, PossibleSounds)
	if PossibleAnims and #PossibleAnims > 0 then
		if PossibleSounds and #PossibleSounds > 0 then
			PossibleSounds[math.random(1, #PossibleSounds)]:Play()
		end 
		CurrentAnimation = PossibleAnims[math.random(1, #PossibleAnims)]
		InvokeClient("PlayAnimation", CurrentAnimation)
		if CurrentAnimation.Duration and CurrentAnimation.Duration > 0 then
			wait(CurrentAnimation.Duration)
			CurrentAnimation = nil
		end
	end
end

function Activated()
	if not Tool.Enabled or not ToolEquipped then
		return
	end
	Clicks = (Clicks + 1)
	if not FirstClick then
		FirstClick = true
		local CurrentlyEquipped = true
		ToolUnequipped = Tool.Unequipped:connect(function()
			CurrentlyEquipped = false
		end)
		wait(0.15)
		if ToolUnequipped then
			ToolUnequipped:disconnect()
		end
		if not CurrentlyEquipped then
			return
		end
		Tool.Enabled = false
		local AttackAnims = {}
		local AttackSounds = {}
		if MouseDown and Clicks == 1 then
			AttackAnims = {Animations.HoldBash}
		else
			AttackSounds = {Sounds.Swing1, Sounds.Swing2, Sounds.Swing3, Sounds.Swing4}
			if Clicks == 1 then
				AttackAnims = {Animations.Bash}
			elseif Clicks > 1 then
				AttackAnims = {Animations.TwoHandBash}
			end
		end
		if Clicks > 1 then
			Humanoid.WalkSpeed = 0
		end
		Attack(AttackAnims, AttackSounds)
		Humanoid.WalkSpeed = 16
		FirstClick = false
		Clicks = 0
		Tool.Enabled = true
	end
end

function CheckIfAlive()
	return (((Player and Player.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0) and true) or false)
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso")
	if not CheckIfAlive() then
		return
	end
	local CurrentlyEquipped = true
	EquippedToolUnequipped = Tool.Unequipped:connect(function()
		CurrentlyEquipped = false
	end)
	if EquippedToolUnequipped then
		EquippedToolUnequipped:disconnect()
	end
	if not CurrentlyEquipped then
		return
	end
	ToolEquipped = true
	Spawn(function()
		local RightArm = Character:WaitForChild("Right Arm")
		if CurrentlyEquipped then
			InvokeClient("SetLocalTransparencyModifier", {Object = RightArm, Transparency = 0, AutoUpdate = false})
		end
	end)
end

function Unequipped()
	Clicks = 0
	FirstClick = false
	if Humanoid and Humanoid.Parent then
		Humanoid.WalkSpeed = 16
	end
	for i, v in pairs({EquippedToolUnequipped, ToolUnequipped}) do
		if v then
			v:disconnect()
		end
	end
	for i, v in pairs(Animations) do
		InvokeClient("StopAnimation", v)
	end
	ToolEquipped = false
end

Handle.Touched:connect(Blow)

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)