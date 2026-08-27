--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
Helix = Handle:WaitForChild("Helix")
Spread = Handle:WaitForChild("Spread")
Sparks = Handle:WaitForChild("Sparks")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

DeathEffect = script:WaitForChild("DeathEffect")

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

Animations = {
	Equip = {Animation = Tool:WaitForChild("Equip"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil},
	Spin = {Animation = Tool:WaitForChild("Spin"), FadeTime = nil, Weight = nil, Speed = 1, Duration = nil, Damage = {Min = 10, Max = 10}},
	Slash1 = {Animation = Tool:WaitForChild("Slash1"), FadeTime = nil, Weight = nil, Speed = 2, Duration = 0.5, AttackWindow = {Start = 0.2, End = 0.4}, Damage = {Min = 19, Max = 26}},
	Slash2 = {Animation = Tool:WaitForChild("Slash2"), FadeTime = nil, Weight = nil, Speed = 1.5, Duration = 0.5, AttackWindow = {Start = 0.3, End = 0.5}, Damage = {Min = 24, Max = 30}},
}

Sounds = {
	Unsheath = Handle:WaitForChild("Unsheath"),
	Slash = Handle:WaitForChild("Slash"),
	Spin = Handle:WaitForChild("Spin")
}

TouchDamage = {Min = 0, Max = 0}

FirstClick = false
Clicks = 0

Gravity = 196.20
Rate = (1 / 60)

Spinning = false
SpinningEnabled = true
AttackEnabled = true
DashEnabled = true
ToolEquipped = false

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

for i, v in pairs(Tool:GetChildren()) do
	if v:IsA("BasePart") and v ~= Handle then
		v:Destroy()
	end
end
for i, v in pairs({Helix, Spread}) do
	v.Enabled = false
end
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

function Blow(Part)
	local TouchedConnection = Part.Touched:connect(function(Hit)
		if not Hit or not Hit.Parent or not CheckIfAlive() then
			return
		end
		
		local character = Hit.Parent
		
		local player = Players:GetPlayerFromCharacter(character)
		if player and (IsTeamMate(Player, player) or player == Player) then
			return
		end
		
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
		
		if not CurrentAnimation or CurrentAnimation.AttackDebounce then
			return
		end
		
		if CurrentAnimation.AttackWindow then
			if not CurrentAnimation.Start then
				return
			end
			local AnimationDuration = (tick() - CurrentAnimation.Start)
			if AnimationDuration < CurrentAnimation.AttackWindow.Start or AnimationDuration > CurrentAnimation.AttackWindow.End then
				return
			end
		end
		
		Spawn(function()
			local Animation = CurrentAnimation
			Animation.AttackDebounce = true
			wait(0.1)
			Animation.AttackDebounce = false
		end)
		
		UntagHumanoid(humanoid)
		TagHumanoid(humanoid, Player)
		
		local DamageValue = ((CurrentAnimation and CurrentAnimation.Damage) or TouchDamage)
		local FinalizedDamage = math.random(DamageValue.Min, DamageValue.Max)
		
			local HealthAfter = (humanoid.Health - FinalizedDamage)
			
			humanoid:TakeDamage(FinalizedDamage)
			
			if HealthAfter <= 0 then
				local Direction = CFrame.new(Torso.Position, Hit.Position).lookVector
				Direction = Vector3.new(Direction.X, 1, Direction.Z)
				local DeathEffectScript = DeathEffect:Clone()
				DeathEffectScript.WindDirection.Value = Direction
				DeathEffectScript.Force.Value = Vector3.new(15, 5, 12.5)
				DeathEffectScript.Disabled = false
				DeathEffectScript.Parent = character
			end
	end)
	return TouchedConnection
end

function Attack(PossibleAnims)
	if not CheckIfAlive() or not ToolEquipped then
		return
	end
	if PossibleAnims and #PossibleAnims > 0 then
		local CurrentlyEquipped = true
		if ToolUnequipped1 then
			ToolUnequipped1:disconnect()
		end
		ToolUnequipped1 = Tool.Unequipped:connect(function()
			CurrentlyEquipped = false
			if ToolUnequipped1 then
				ToolUnequipped1:disconnect()
			end
		end)
		local Animation = PossibleAnims[math.random(1, #PossibleAnims)]
		CurrentAnimation = Animation.Animation
		local AttackAnimation = CurrentAnimation
		InvokeClient("PlayAnimation", CurrentAnimation)
		local LeftSparks = FakeHandle:FindFirstChild("Sparks")
		for i, v in pairs({Sparks, LeftSparks}) do
			if v then
				v.Enabled = true
			end
		end
		AttackAnimation.Start = tick()
		Spawn(function()
			for i, v in pairs(Animation.Sounds) do
				if not CurrentlyEquipped then
					break
				end
				if v.Delay > 0 then
					wait(v.Delay)
				end
				if not CurrentlyEquipped then
					break
				end
				v.Sound:Play()
			end
			if ToolUnequipped1 then
				ToolUnequipped1:disconnect()
			end
		end)
		if AttackAnimation.Duration and AttackAnimation.Duration > 0 then
			wait(AttackAnimation.Duration)
			AttackAnimation.Start = nil
			for i, v in pairs({Sparks, LeftSparks}) do
				if v then
					v.Enabled = false
				end
			end
			InvokeClient("StopAnimation", AttackAnimation)
			CurrentAnimation = nil
		end
	end
end

function Dash()
	if not CheckIfAlive() or not ToolEquipped or not DashEnabled then
		return
	end
	DashEnabled = false
	local CurrentlyEquipped = true
	if ToolUnequipped2 then
		ToolUnequipped2:disconnect()
	end
	ToolUnequipped2 = Tool.Unequipped:connect(function()
		CurrentlyEquipped = false
		if ToolUnequipped2 then
			ToolUnequipped2:disconnect()
		end
	end)
	Humanoid.WalkSpeed = 60
	local AttackAnims = {
		{Animation = Animations.Slash2, Sounds = {{Delay = 0, Sound = Sounds.Slash}}}
	}
	Spawn(function()
		Attack(AttackAnims)
	end)
	wait(Animations.Slash2.Duration)
	if CheckIfAlive() and ToolEquipped and CurrentlyEquipped then
		Humanoid.WalkSpeed = 16
	end
	Spawn(function()
		wait(2)
		DashEnabled = true
	end)
end

function CreateDualWield()
	if FakeHandle and FakeHandle.Parent then
		FakeHandle:Destroy()
	end
	local LeftArm = Character:FindFirstChild("Left Arm")
	if LeftArm then
		FakeHandle = Handle:Clone()
		FakeHandle.Name = "FakeHandle"
		local LeftGrip = Instance.new("Weld")
		LeftGrip.Part0 = LeftArm
		LeftGrip.Part1 = FakeHandle
		LeftGrip.C0 = CFrame.new(0, -1, 0, 1, 0, -0, 0, 0, 1, 0, -1, -0)
		LeftGrip.C1 = (Tool.Grip * CFrame.Angles(0, 0, -math.pi))
		LeftGrip.Parent = FakeHandle
		Blow(FakeHandle)
		FakeHandle.Parent = Tool
	end
end

function Activated()
	if not Tool.Enabled or not ToolEquipped or Spinning then
		return
	end
	Clicks = (Clicks + 1)
	if not FirstClick then
		FirstClick = true
		local CurrentlyEquipped = true
		ToolUnequipped = Tool.Unequipped:connect(function()
			CurrentlyEquipped = false
		end)
		wait(0.2)
		if ToolUnequipped then
			ToolUnequipped:disconnect()
		end
		if not CurrentlyEquipped then
			return
		end
		Tool.Enabled = false
		if Clicks == 1 or not DashEnabled then
			local AttackAnims = {
				{Animation = Animations.Slash1, Sounds = {{Delay = 0, Sound = Sounds.Slash}, {Delay = 0.25, Sound = Sounds.Slash}}},
			}
			Attack(AttackAnims)
		elseif Clicks > 1 and DashEnabled then
			Dash()
		end
		FirstClick = false
		Clicks = 0
		Tool.Enabled = true
	end
end

function CheckIfAlive()
	return (((Player and Player.Parent and Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent) and true) or false)
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso")
	if not CheckIfAlive() then
		return
	end
	Sounds.Unsheath:Play()
	Spawn(function()
		InvokeClient("PlayAnimation", Animations.Equip)
	end)
	Spawn(function()
		for i, v in pairs({"Left Arm", "Right Arm"}) do
			local Arm = Character:FindFirstChild(v)
			if Arm then
				Spawn(function()
					InvokeClient("SetLocalTransparencyModifier", {Object = Arm, Transparency = 0, AutoUpdate = false})
				end)
			end
		end
	end)
	Spawn(CreateDualWield)
	ToolEquipped = true
end

function Unequipped()
	Spinning = false
	Clicks = 0
	FirstClick = false
	for i, v in pairs({FakeHandle}) do
		if v and v.Parent then
			v:Destroy()
		end
	end
	for i, v in pairs({Helix, Spread, Sparks}) do
		v.Enabled = false
	end
	for i, v in pairs(Sounds) do
		if v and v.Parent then
			v:Stop()
		end
	end
	if ToolUnequipped then
		ToolUnequipped:disconnect()
	end
	if CheckIfAlive() then
		Humanoid.WalkSpeed = 16
	end
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
	if Mode == "KeyPress" then
		local Key = Value.Key
		local Down = Value.Down
		if Key == "q" then
			if Down and not Spinning and not FirstClick and Tool.Enabled and SpinningEnabled then
				SpinningEnabled = false
				Spinning = true
				local Animation = Animations.Spin
				CurrentAnimation = Animation
				Humanoid.WalkSpeed = 10
				Spawn(function()
					InvokeClient("PlayAnimation", Animation)
				end)
				Spawn(function()
					InvokeClient("DisableJump", true)
				end)
				Sounds.Spin.Pitch = 1
				Sounds.Spin:Stop()
				local StartTime = tick()
				local EndTime = (StartTime + 5)
				local MaxSpeed = 3
				local DesiredSpeed = Animation.Speed
				while Spinning and ToolEquipped and CheckIfAlive() do
					local CurrentTime = tick()
					local CurrentCharge = math.abs(CurrentTime - StartTime)
					local ChargePercent = Clamp(GetPercentage(StartTime, EndTime, CurrentTime), 0, 100)
					local ChargePercentToDecimal = (ChargePercent * 0.01)
					DesiredSpeed = Clamp((MaxSpeed * ChargePercentToDecimal), Animation.Speed, MaxSpeed)
					if DesiredSpeed >= 1.5 then 
						if not Sounds.Spin.IsPlaying then
							Sounds.Spin:Play()
						end
						for i, v in pairs({Helix, Spread}) do
							if not v.Enabled then
								v.Enabled = true
							end
						end
					end
					Sounds.Spin.Pitch = Clamp((2 * ChargePercentToDecimal), 2, 3)
					InvokeClient("PlayAnimation", {Animation = Animation.Animation, FadeTime = Animation.FadeTime, Weight = Animation.Weight, Speed = DesiredSpeed})
					wait(Rate)
				end
				for i, v in pairs({Helix, Spread}) do
					v.Enabled = false
				end
				Sounds.Spin:Stop()
				CurrentAnimation = nil
				Spawn(function()
					InvokeClient("DisableJump", false)
				end)
				Spawn(function()
					InvokeClient("StopAnimation", Animations.Spin)
				end)
				Humanoid.WalkSpeed = 16
				wait(5)
				SpinningEnabled = true
			elseif not Down and Spinning then
				Spinning = false
			end
		end
	end
end)

Blow(Handle)

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)