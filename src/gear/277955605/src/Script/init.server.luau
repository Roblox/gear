--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
Mesh = Handle:WaitForChild("Mesh")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

RbxUtility = LoadLibrary("RbxUtility")
Create = RbxUtility.Create

BaseUrl = "http://www.roblox.com/asset/?id="

KnifeScript = script:WaitForChild("KnifeScript")

Animations = {
	RemoveCap = {Animation = Tool:WaitForChild("RemoveCap"), FadeTime = 0.1, Weight = nil, Speed = 0.75, Duration = 1},
	LeftSlash = {Animation = Tool:WaitForChild("LeftSlash"), FadeTime = nil, Weight = nil, Speed = 2, Duration = 0.5},
	RightSlash = {Animation = Tool:WaitForChild("RightSlash"), FadeTime = nil, Weight = nil, Speed = 2, Duration = 0.5},
	Charge = {Animation = Tool:WaitForChild("Charge"), FadeTime = nil, Weight = nil, Speed = 1, Duration = 1},	
	HoldCharge = {Animation = Tool:WaitForChild("HoldCharge"), FadeTime = 0, Weight = nil, Speed = 1, Duration = nil},
	Throw = {Animation = Tool:WaitForChild("Throw"), FadeTime = 0, Weight = nil, Speed = 5, Duration = 1},		
}

Sounds = {
	Unsheath = Handle:WaitForChild("Unsheath"),
	Slash = Handle:WaitForChild("Slash"),
	Throw = Handle:WaitForChild("Throw"),
}

Meshes = {
	Pen = 272570929,
	Knife = 272570983,
	Cap = 272570848,
}

BasePart = Create("Part"){
	Shape = Enum.PartType.Block,
	Material = Enum.Material.Plastic,
	FormFactor = Enum.FormFactor.Custom,
	TopSurface = Enum.SurfaceType.Smooth,
	BottomSurface = Enum.SurfaceType.Smooth,
	Size = Vector3.new(0.2, 0.2, 0.2),
	Locked = true,
	CanCollide = true,
	Anchored = false,
}

DamageValues = {
	BaseDamage = 8,
	SlashDamage = 14,
	KnifeDamage = 40,
}

Damage = DamageValues.BaseDamage

Gravity = 196.20
Rate = (1 / 60)

ReloadTime = 3

CurrentMode = "None"
HitDebounce = false
MouseDown = Create("BoolValue"){
	Value = false,
}
ToolEquipped = false

ServerControl = (Tool:FindFirstChild("ServerControl") or Create("RemoteFunction"){
	Name = "ServerControl",
	Parent = Tool,
})

ClientControl = (Tool:FindFirstChild("ClientControl") or Create("RemoteFunction"){
	Name = "ClientControl",
	Parent = Tool,
})

for i, v in pairs(Meshes) do
	Meshes[i] = (BaseUrl .. tostring(v))
end

Handle.Transparency = 0
Tool.Enabled = true

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

function Blow(Hit)
	if not Hit or not Hit.Parent or not CheckIfAlive() or not ToolEquipped or CurrentMode ~= "Knife" or HitDebounce then
		return
	end
	local RightArm = Character:FindFirstChild("Right Arm")
	if not RightArm then
		return
	end
	local RightGrip = RightArm:FindFirstChild("RightGrip")
	if not RightGrip or (RightGrip.Part0 ~= Handle and RightGrip.Part1 ~= Handle) then
		return
	end
	local character = Hit.Parent
	if character == Character then
		return
	end
	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid or humanoid.Health == 0 then
		return
	end
	local player = Players:GetPlayerFromCharacter(character)
	if player and (player == Player or IsTeamMate(Player, player)) then
		return
	end
	HitDebounce = true
	UntagHumanoid(humanoid)
	TagHumanoid(humanoid, Player)
	humanoid:TakeDamage(Damage)
	wait(0.1)
	HitDebounce = false
end

function Attack()
	local SlashAnimations = {Animations.LeftSlash, Animations.RightSlash}
	local Animation = SlashAnimations[math.random(1, #SlashAnimations)]
	Spawn(function()
		InvokeClient("PlayAnimation", Animation)
		wait(Animation.Duration)
		InvokeClient("StopAnimation", Animation)
	end)
	Damage = DamageValues.SlashDamage
	Sounds.Slash.Pitch = (math.random(1250, 1750) * 0.001)
	Sounds.Slash:Play()
	local Anim = Instance.new("StringValue")
	Anim.Name = "toolanim"
	Anim.Value = "Slash"
	Anim.Parent = Tool
	wait(0.2)
	Damage = DamageValues.BaseDamage
end

function SetKnife(Mode)
	CurrentMode = Mode
	for i, v in pairs(Tool:GetChildren()) do
		if v:IsA("BasePart") and v ~= Handle then
			v:Destroy()
		end
	end
	if Mode == "Open" then
		Mesh.MeshId = Meshes.Knife
	elseif Mode == "Knife" then
		local CurrentlyEquipped = true
		if ToolUnequipped then
			ToolUnequipped:disconnect()
		end
		ToolUnequipped = Tool.Unequipped:connect(function()
			CurrentlyEquipped = false
		end)
		local Animation = Animations.RemoveCap
		Spawn(function()
			InvokeClient("PlayAnimation", Animation)
		end)
		if not CurrentlyEquipped then
			return
		end
		wait((Animation.Duration * Animation.Speed) / 2)
		if not CurrentlyEquipped then
			return
		end
		Mesh.MeshId = Meshes.Knife
		Sounds.Unsheath:Play()
		local PenCap
		local LeftArm = Character:FindFirstChild("Left Arm")
		if LeftArm then
			PenCap = BasePart:Clone()
			PenCap.Name = "PenCap"
			PenCap.CanCollide = false
			local PenCapMesh = Mesh:Clone()
			PenCapMesh.MeshId = Meshes.Cap
			PenCapMesh.Parent = PenCap
			local CapOffset = (Handle.CFrame * CFrame.new(0, -0.4, -0.75))
			local Weld = Create("Weld"){
				Name = "Weld",
				Part0 = LeftArm,
				Part1 = PenCap,
				C0 = (CFrame.new(0, -1.25, -0.5) * CFrame.Angles((math.pi * 0.75), (math.pi * 2), math.pi)),
				C1 = CFrame.new(0, 0, 0),
				Parent = PenCap,
			}
			PenCap.Parent = Tool
		end
		Mesh.MeshId = Meshes.Knife
		wait((Animation.Duration * Animation.Speed) / 1)
		if not CurrentlyEquipped then
			return
		end
		if ToolUnequipped then
			ToolUnequipped:disconnect()
		end
		if PenCap and PenCap.Parent then
			PenCap:Destroy()
		end
	else
		Mesh.MeshId = Meshes.Pen
	end
end

function Activated()
	if not Tool.Enabled or not CheckIfAlive() or CurrentMode == "Open" or MouseDown.Value then
		return
	end
	Tool.Enabled = false
	MouseDown.Value = true
	if CurrentMode ~= "Knife" then
		SetKnife("Knife")
	elseif CurrentMode == "Knife" then
		local CurrentlyEquipped = true
		local CurrentlyDown = true
		if ToolUnequipped then
			ToolUnequipped:disconnect()
		end
		ToolUnequipped = Tool.Unequipped:connect(function()
			CurrentlyEquipped = false
		end)
		MouseUp = MouseDown.Changed:connect(function()
			if not MouseDown.Value then
				CurrentlyDown = false
			end
		end)
		wait(0.25)
		if ToolUnequipped then
			ToolUnequipped:disconnect()
		end
		if CurrentlyEquipped then
			if CurrentlyDown then
				local Animation = Animations.Charge
				local StartTime = tick()
				local Speed = (Animation.Speed * 0.9)
				local EndTime = (Animation.Duration / Speed)
				local ThrowSpeed = {Min = 25, Max = 100}
				local FullyCharged = false
				Spawn(function()
					InvokeClient("PlayAnimation", {Animation = Animation.Animation, FadeTime = Animation.FadeTime, Weight = Animation.Weight, Speed = Speed})
				end)
				while ToolEquipped and CheckIfAlive() and CurrentlyDown do
					local Now = tick()
					if (Now - StartTime) >= EndTime and not FullyCharged then
						FullyCharged = true
						Spawn(function()
--							InvokeClient("StopAnimation", {Animation = Animation.Animation, FadeTime = nil})
							InvokeClient("PlayAnimation", Animations.HoldCharge)
						end)
					end
					wait(Rate)
				end
				if ToolEquipped and CheckIfAlive() then
					Spawn(function()
						if not FullyCharged then
							InvokeClient("StopAnimation", {Animation = Animation.Animation, FadeTime = 0})
						else
							InvokeClient("StopAnimation", Animations.HoldCharge)
						end
						Animation = Animations.Throw
						InvokeClient("PlayAnimation", Animation)
						wait(Animation.Duration)
						InvokeClient("StopAnimation", Animation)
					end)
					local CurrentTime = tick()
					local CurrentCharge = math.abs(CurrentTime - StartTime)
					local ChargePercent = Clamp(GetPercentage(StartTime, (StartTime + EndTime), CurrentTime), 0, 100)
					local ChargePercentToDecimal = (ChargePercent * 0.01)
					local ThrowSpeed = Clamp((ThrowSpeed.Max * ChargePercentToDecimal), ThrowSpeed.Min, ThrowSpeed.Max)
					local MousePosition = InvokeClient("MousePosition")
					if MousePosition then
						MousePosition = MousePosition.Position
					end
					Sounds.Throw:Play()
					local Direction = CFrame.new(Handle.Position, MousePosition)
					local Velocity = (Direction.lookVector * ThrowSpeed)
					local Knife = Handle:Clone()
					Knife.Name = "Projectile"
					Knife.Transparency = 0
					Knife.CanCollide = true
					Knife.CFrame = (Handle.CFrame * CFrame.new(0, -Handle.Size.Y, 0))
					local Values = {
						{Name = "Creator", Class = "ObjectValue", Value = Player},
						{Name = "Damage", Class = "NumberValue", Value = DamageValues.KnifeDamage},
					}
					for i, v in pairs(Values) do
						local Value = Create(v.Class){
							Name = v.Name,
							Value = v.Value,
							Parent = Knife,
						}
					end
					local KnifeScriptCopy = KnifeScript:Clone()
					KnifeScriptCopy.Disabled = false
					KnifeScriptCopy.Parent = Knife
					local Mass = (Knife:GetMass() * Gravity)
					local BodyVelocity = Create("BodyVelocity"){
						maxForce = Vector3.new(Mass, Mass, Mass),
						velocity = Velocity,
						Parent = Knife,
					}
					local BodyAngularVelocity = Create("BodyAngularVelocity"){
						maxTorque = Vector3.new(Mass, Mass, Mass),
						angularvelocity = ((Direction * CFrame.Angles(0, (math.pi / 2), 0)).lookVector * ThrowSpeed),
						Parent = Knife,
					}
					Knife.Velocity = Velocity
					Debris:AddItem(Knife, 2)
					Handle.Transparency = 1
					Knife.Parent = game:GetService("Workspace")
					wait(ReloadTime)
					SetKnife("Closed")
					Handle.Transparency = 0
				end
			else
				Attack()
			end
		end
	end
	Tool.Enabled = true
end

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent and Player and Player.Parent) and true) or false)
end

function Equipped(Mouse)
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso")
	if not CheckIfAlive() then
		return
	end
	MouseDown.Value = false
	ToolEquipped = true
	SetKnife("Closed")
end

function Unequipped()
	if ToolUnequipped then
		ToolUnequipped:disconnect()
	end
	MouseDown.Value = false
	ToolEquipped = false
	SetKnife("Closed")
end

function OnServerInvoke(player, mode, value)
	if player ~= Player or not ToolEquipped or not value or not CheckIfAlive() then
		return
	end
	if mode == "Button1Click" then
		local Down = value.Down
		if MouseDown.Value and not Down then
			MouseDown.Value = false
		end
	end
end

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
end

SetKnife("Closed")

ServerControl.OnServerInvoke = OnServerInvoke

Connection = Handle.Touched:connect(Blow)

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)