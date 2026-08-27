--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
InsertService = game:GetService("InsertService")
Debris = game:GetService("Debris")

StunScript = script:WaitForChild("StunScript")

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

MaxCharge = 4.5

Animations = {
	Slash = {Animation = Tool:WaitForChild("Slash"), FadeTime = nil, Weight = nil, Speed = 2, Duration = 0.5},
	BeginCharge = {Animation = Tool:WaitForChild("BeginCharge"), FadeTime = nil, Weight = nil, Speed = (1 / MaxCharge), Duration = 1},
	Charge = {Animation = Tool:WaitForChild("Charge"), FadeTime = 0, Weight = nil, Speed = 0.25, Duration = nil},
	Release = {Animation = Tool:WaitForChild("Release"), FadeTime = 0, Weight = nil, Speed = 1.5, Duration = 1},
}

Damage = {
	Touch = {Min = 0, Max = 0},
	Charge = {Min = 18, Max = 100},	
}

Sounds = {
	Woosh = Handle:WaitForChild("Woosh"),
	Smack = Handle:WaitForChild("Smack"),
}

ReloadTime = 0.25

HitReady = false

Gravity = 196.20
Rate = (1 / 60)

MouseDown = false
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

function GetAllConnectedParts(Object)
	local Parts = {}
	local function GetConnectedParts(Object)
		for i, v in pairs(Object:GetConnectedParts()) do
			local Ignore = false
			for ii, vv in pairs(Parts) do
				if v == vv then
					Ignore = true
				end
			end
			if not Ignore then
				table.insert(Parts, v)
				GetConnectedParts(v)
			end
		end
	end
	GetConnectedParts(Object)
	return Parts
end

function Dash(TargetPosition)
	if not ToolEquipped or not CheckIfAlive() or not TargetPosition then
		return
	end
	local Direction = CFrame.new(Torso.Position, Vector3.new(TargetPosition.X, Torso.Position.Y, TargetPosition.Z))
	Torso.CFrame = Direction
	local Parts = GetAllConnectedParts(Torso)
	local Mass = 0
	for i, v in pairs(Parts) do
		Mass = (Mass + v:GetMass())
	end
	Mass = (Mass * Gravity * 100)
	local BodyVelocity = Instance.new("BodyVelocity")
	BodyVelocity.maxForce = Vector3.new(Mass, 0, Mass)
	BodyVelocity.velocity = Direction.lookVector * 100
	Debris:AddItem(BodyVelocity, 0.25)
	BodyVelocity.Parent = Torso
	local BodyGyro = Instance.new("BodyGyro")
	BodyGyro.maxTorque = Vector3.new(math.huge, math.huge, math.huge)
	BodyGyro.cframe = Direction
	Debris:AddItem(BodyGyro, 0.25)
	BodyGyro.Parent = Torso
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
		
		if not HitReady then
			return
		end
		
		HitReady = false
		Sounds.Smack:Play()
		
		UntagHumanoid(humanoid)
		TagHumanoid(humanoid, Player)
		
		local DamageValue = (ChargeDamage or math.random(Damage.Touch.Min, Damage.Touch.Max))
		
		if DamageValue <= 0 then
			return
		end
		
		local EstimatedHealth = (humanoid.Health - DamageValue)
		if EstimatedHealth > 0 and ChargePercentage >= 40 then
			local StunChance = math.random(1, 4)
			if StunChance == 1 and player then
				local StunScriptClone = StunScript:Clone()
				local Duration = Instance.new("NumberValue")
				Duration.Name = "Duration"
				Duration.Value = 3
				Duration.Parent = StunScriptClone
				StunScriptClone.Disabled = false
				Debris:AddItem(StunScriptClone, 5)
				StunScriptClone.Parent = character
			end
		end
		
		humanoid:TakeDamage(DamageValue)
		
	end)
	return TouchedConnection
end

function Activated()
	if not Tool.Enabled or not ToolEquipped or MouseDown or not CheckIfAlive() then
		return
	end
	MouseDown = true
	ChargeTick = tick()
	Spawn(function()
		InvokeClient("PlayAnimation", Animations.BeginCharge)
	end)
	while MouseDown and ToolEquipped and CheckIfAlive() and (tick() - ChargeTick) < MaxCharge do
		wait(Rate)
	end
	if MouseDown and ToolEquipped and CheckIfAlive() then
		Spawn(function()
			InvokeClient("StopAnimation", {Animation = Animations.BeginCharge.Animation, FadeTime = 0})
		end)
		Spawn(function()
			InvokeClient("PlayAnimation", Animations.Charge)
		end)
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
	Spawn(function()
		for i, v in pairs({"Right Arm"}) do
			local Limb = Character:FindFirstChild(v)
			if Limb then
				Spawn(function()
					InvokeClient("SetLocalTransparencyModifier", {Object = Limb, Transparency = 0, AutoUpdate = false})
				end)
			end
		end
	end)
	ToolEquipped = true
end

function Unequipped()
	MouseDown = false
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
	if player ~= Player or not ToolEquipped or not CheckIfAlive() or not Mode or not Value or not Tool.Enabled then
		return
	end
	if Mode == "Button1Click" then
		local Down = Value.Down
		if not Down and MouseDown then
			MouseDown = false
			if not ToolEquipped or not CheckIfAlive() then
				return
			end
			Tool.Enabled = false
			local CurrentlyEquipped = true
			if ToolUnequipped then
				ToolUnequipped:disconnect()
			end
			ToolUnequipped = Tool.Unequipped:connect(function()
				CurrentlyEquipped = false
			end)
			local TargetPosition = InvokeClient("MousePosition")
			if not TargetPosition or not ToolEquipped or not CurrentlyEquipped or not CheckIfAlive() then
				Tool.Enabled = true
			end
			local TickTime = (tick() - ChargeTick)
			ChargePercentage = Clamp(GetPercentage(0, MaxCharge, (tick() - ChargeTick)), 0, 100)
			ChargePercentageToDecimal = (ChargePercentage * 0.01)
			ChargeDamage = Clamp((Damage.Charge.Max * ChargePercentageToDecimal), Damage.Charge.Min, Damage.Charge.Max)
			local ChargeSpeed = Clamp((3 * ChargePercentageToDecimal), 1.5, 2.5)
			Spawn(function()
				InvokeClient("StopAnimation", {Animation = Animations.BeginCharge.Animation, FadeTime = 0})
			end)
			Spawn(function()
				InvokeClient("StopAnimation", {Animation = Animations.Charge.Animation, FadeTime = 0})
			end)
			if ToolEquipped and CurrentlyEquipped and CheckIfAlive() then
				if ChargePercentage >= 50 then
					Spawn(function()
						Dash(TargetPosition.Position)
					end)
				end
				Sounds.Woosh:Play()
				local Animation = Animations.Release
				Animation.Speed = ChargeSpeed
				CurrentAnimation = Animation
				HitReady = true
				InvokeClient("PlayAnimation", Animation)
				HitReady = false
				ChargeDamage = nil
				CurrentAnimation = nil
			end
			wait(ReloadTime)
			Tool.Enabled = true
			MouseDown = false
		end
	end
end)

Blow(Handle)

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)