--Made by Luckymaxer
--Updated for R15 avatars by StarWars

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
Mesh = Handle:WaitForChild("Mesh")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

BaseUrl = "rbxassetid://"

AnimationsFolder = Tool.Animations

BasePart = Instance.new("Part")
BasePart.Shape = Enum.PartType.Block
BasePart.Material = Enum.Material.Plastic
BasePart.TopSurface = Enum.SurfaceType.Smooth
BasePart.BottomSurface = Enum.SurfaceType.Smooth
BasePart.Size = Vector3.new(0.2, 0.2, 0.2)
BasePart.CanCollide = true
BasePart.Locked = true
BasePart.Anchored = false

BaseOrb = BasePart:Clone()
BaseOrb.Name = "Orb"
BaseOrb.Transparency = 0
BaseOrb.Reflectance = 0.5
BaseOrb.BrickColor = BrickColor.new("Teal")
BaseOrb.Material = Enum.Material.Ice
BaseOrb.CanCollide = false
OrbMesh = Instance.new("SpecialMesh")
OrbMesh.Name = "Mesh"
OrbMesh.MeshType = Enum.MeshType.Sphere
OrbMesh.Scale = Vector3.new(1.5, 1.5, 1.5)
OrbMesh.Parent = BaseOrb
FirePart = BasePart:Clone()
FirePart.Name = "FirePart"
FirePart.Transparency = 0
FirePart.Reflectance = 0.5
FirePart.BrickColor = BrickColor.new("Teal")
FirePart.Material = Enum.Material.Ice
FirePart.CanCollide = false
OrbFire = Instance.new("Fire")
OrbFire.Name = "Fire"
OrbFire.Color = Color3.new((0 / 255), (170 / 255), (255 / 255))
OrbFire.SecondaryColor = Color3.new((85 / 255), (255 / 255), (255 / 255))
OrbFire.Enabled = true
OrbFire.Parent = FirePart
OrbLight = Instance.new("PointLight")
OrbLight.Name = "Light"
OrbLight.Color = BaseOrb.BrickColor.Color
OrbLight.Shadows = false
OrbLight.Brightness = 50
OrbLight.Parent = BaseOrb
FireMesh = Instance.new("SpecialMesh")
FireMesh.Name = "Mesh"
FireMesh.MeshType = Enum.MeshType.FileMesh
FireMesh.MeshId = (BaseUrl .. "25212400")
FireMesh.Parent = FirePart
FirePart.Parent = BaseOrb
FireWeld = Instance.new("Weld")
FireWeld.Part0 = BaseOrb
FireWeld.Part1 = FirePart
FireWeld.Parent = BaseOrb

DefaultOrbSize = 0.5
MaxOrbSize = 5

Damage = {
	Min = 15,
	Max = 100
}

DefaultOrbVelocity = 30
MaxOrbVelocity = 200

MaxCharge = 6

Animations = {
	Equip = {Animation = AnimationsFolder.R6:WaitForChild("Equip"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil},
	Fire = {Animation = AnimationsFolder.R6:WaitForChild("Fire"), FadeTime = nil, Weight = nil, Speed = 4, Duration = 1},
	Charge = {Animation = AnimationsFolder.R6:WaitForChild("Charge"), FadeTime = nil, Weight = nil, Speed = (1 / MaxCharge), Duration = MaxCharge},
	HoldCharge = {Animation = AnimationsFolder.R6:WaitForChild("HoldCharge"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil},
	CastSpell = {Animation = AnimationsFolder.R6:WaitForChild("CastSpell"), FadeTime = nil, Weight = nil, Speed = 0.5, Duration = nil},

	R15Equip = {Animation = AnimationsFolder.R15:WaitForChild("Equip"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil},
	R15Fire = {Animation = AnimationsFolder.R15:WaitForChild("Fire"), FadeTime = nil, Weight = nil, Speed = 4, Duration = 1},
	R15Charge = {Animation = AnimationsFolder.R15:WaitForChild("Charge"), FadeTime = nil, Weight = nil, Speed = (1 / MaxCharge), Duration = MaxCharge},
	R15HoldCharge = {Animation = AnimationsFolder.R15:WaitForChild("HoldCharge"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil},
	R15CastSpell = {Animation = AnimationsFolder.R15:WaitForChild("CastSpell"), FadeTime = nil, Weight = nil, Speed = 0.5, Duration = nil},
}

Sounds = {
	Blast = Handle:WaitForChild("Blast"),
}

ToolEquipped = false
MouseDown = false

Gravity = workspace.Gravity
Rate = (1 / 60)
ReloadTime = 1

Tool.Enabled = true

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

function CheckIfAlive()
	return (((Player and Player.Parent and Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent) and true) or false)
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
	if not CheckIfAlive() then
		return
	end
	Spawn(function()
		for i, v in pairs(Animations) do
			InvokeClient("Preload", v.Animation.AnimationId)
		end
	end)
	Spawn(function()
		local Animation = Animations.Equip
		if Humanoid and Humanoid.RigType == Enum.HumanoidRigType.R15 then
			Animation = Animations.R15Equip
		end 
		InvokeClient("PlayAnimation", Animation)
	end)
	MouseDown = false
	ToolEquipped = true
end

function Unequipped()
	MouseDown = false
	if FullyChargedIndicator and FullyChargedIndicator.Parent then
		FullyChargedIndicator:Destroy()
	end
	Spawn(function()
		for i, v in pairs(Animations) do
			InvokeClient("StopAnimation", v)
		end
	end)
	ToolEquipped = false
end

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
end

function OnServerInvoke(player, Mode, Value)
	if player ~= Player or not ToolEquipped or not CheckIfAlive() then
		return
	end
	if Mode == "MouseClick" then
		local Down = Value.Down
		if Down and not MouseDown and Tool.Enabled then
			Spawn(function()
				MouseDown = true
				ChargeTick = tick()
				local Animation = Animations.Charge
				if Humanoid and Humanoid.RigType == Enum.HumanoidRigType.R15 then
					Animation = Animations.R15Charge
				end 
				InvokeClient("PlayAnimation", Animation)
				while MouseDown and ToolEquipped and CheckIfAlive() and (tick() - ChargeTick) < MaxCharge do
					wait(Rate)
				end
				if MouseDown and ToolEquipped and CheckIfAlive() then
					for i, v in pairs(Handle:GetChildren()) do
						if v:IsA("BasePart") then
							v:Destroy()
						end
					end
					FullyChargedIndicator = BasePart:Clone()
					FullyChargedIndicator.Transparency = 1
					FullyChargedIndicator.CanCollide = false
					local Sparkles = Instance.new("Sparkles")
					Sparkles.SparkleColor = BrickColor.new("Teal").Color
					Sparkles.Enabled = true
					Sparkles.Parent = FullyChargedIndicator
					local Fire = Instance.new("Fire")
					Fire.Color = Color3.new((0 / 255), (170 / 255), (255 / 255))
					Fire.SecondaryColor = Color3.new((85 / 255), (255 / 255), (255 / 255))
					Fire.Heat = 10
					Fire.Size = 2
					Fire.Enabled = true
					Fire.Parent = FullyChargedIndicator
					local Light = Instance.new("PointLight")
					Light.Color = BrickColor.new("Teal").Color
					Light.Brightness = 2
					Light.Range = 8
					Light.Shadows = false
					Light.Enabled = true
					Light.Parent = FullyChargedIndicator
					local Weld = Instance.new("Weld")
					Weld.Part0 = Handle
					Weld.Part1 = FullyChargedIndicator
					Weld.C0 = CFrame.new(0, ((Handle.Size.Y * 0.5) - (FullyChargedIndicator.Size.Y * 0.5)), 0)
					Weld.Parent = FullyChargedIndicator
					FullyChargedIndicator.Parent = Handle
					local Animation = Animations.HoldCharge
					if Humanoid and Humanoid.RigType == Enum.HumanoidRigType.R15 then
						Animation = Animations.R15HoldCharge
					end 
					InvokeClient("PlayAnimation", Animation)
				end
			end)
		elseif not Down and MouseDown then
			MouseDown = false
			if not ToolEquipped or not CheckIfAlive() then
				return
			end
			Tool.Enabled = false
			if FullyChargedIndicator and FullyChargedIndicator.Parent then
				FullyChargedIndicator:Destroy()
			end
			local TickTime = (tick() - ChargeTick)
			local ChargePercentage = math.clamp(GetPercentage(0, MaxCharge, (tick() - ChargeTick)), 0, 100)
			local ChargePercentageToDecimal = (ChargePercentage * 0.01)
			local OrbSize = math.clamp((MaxOrbSize * ChargePercentageToDecimal), DefaultOrbSize, MaxOrbSize)
			local OrbVelocity = math.clamp((MaxOrbVelocity * ChargePercentageToDecimal), DefaultOrbVelocity, MaxOrbVelocity)				
			local OrbDamage = math.clamp((Damage.Max * ChargePercentageToDecimal), Damage.Min, Damage.Max)
			local MousePosition = InvokeClient("MousePosition").Position
			if Humanoid then
				if Humanoid.RigType == Enum.HumanoidRigType.R6 then
					InvokeClient("StopAnimation", Animations.Charge)
					InvokeClient("StopAnimation", Animations.HoldCharge)
					InvokeClient("PlayAnimation", Animations.Fire)
				elseif Humanoid.RigType == Enum.HumanoidRigType.R15 then 
					InvokeClient("StopAnimation", Animations.R15Charge)
					InvokeClient("StopAnimation", Animations.R15HoldCharge)
					InvokeClient("PlayAnimation", Animations.R15Fire)					
				end
			end 
			Sounds.Blast:Play()
			Spawn(function()
				local Orb = BaseOrb:Clone()
				Orb.Size = Vector3.new(OrbSize, OrbSize, OrbSize)
				Orb.FirePart.Mesh.Scale = ((Orb.Size * 0.5)) + Vector3.new(0, (Orb.Size.Y * 0.25), 0)
				Orb.FirePart.Fire.Heat = math.clamp((25 * ChargePercentageToDecimal), 0, 25)
				Orb.FirePart.Fire.Size = math.clamp((10 * ChargePercentageToDecimal), 0, 10)
				Orb.Light.Range = math.clamp((MaxOrbSize * ChargePercentageToDecimal), 3, MaxOrbSize)
				Orb.Weld.C0 = CFrame.new(0, -(Orb.Size.Y + 0.1), 0) * CFrame.Angles(math.pi, 0, 0)
				local OrbCFrame = (Handle.CFrame * CFrame.new(0, ((Handle.Size.Y * 0.5) - ((OrbSize * 0.5) * 1--[[.5]])), -((Handle.Size.Z * 0.5) + ((OrbSize * 0.5) * 1.5))))
				local Direction = CFrame.new(OrbCFrame.p, MousePosition)
				local BodyGyro = Instance.new("BodyGyro")
				BodyGyro.maxTorque = Vector3.new(math.huge, math.huge, math.huge)
				BodyGyro.cframe = (Direction * CFrame.Angles(-(math.pi * 0.5), 0, 0))
				BodyGyro.Parent = Orb
				OrbVelocity = (Direction.lookVector * OrbVelocity)
				local Mass = ((Orb:GetMass() + Orb.FirePart:GetMass()) * Gravity)
				local BodyVelocity = Instance.new("BodyVelocity")
				BodyVelocity.maxForce = Vector3.new(Mass, Mass, Mass)
				BodyVelocity.velocity = OrbVelocity
				BodyVelocity.Parent = Orb
				Orb.Velocity = OrbVelocity
				Orb.CFrame = (Direction * CFrame.Angles(-(math.pi / 2), 0, 0))
				Orb.Touched:connect(function(Hit)
					if not Hit or not Hit.Parent then
						return
					end
					local character = Hit.Parent
					if character:IsA("Accessory") then
						character = character.Parent
					end
					if character == Character then
						return
					end
					local player = Players:GetPlayerFromCharacter(character)
					if player and IsTeamMate(Player, player) then
						return
					end
					local humanoid = character:FindFirstChildOfClass("Humanoid")
					if humanoid and humanoid.Health > 0 then
						UntagHumanoid(humanoid)
						TagHumanoid(humanoid, Player)
						humanoid:TakeDamage(OrbDamage)
						if OrbDamage < Damage.Max and Orb and Orb.Parent then
							Orb:Destroy()
						end
					end
				end)
				Debris:AddItem(Orb, 5)
				Orb.Parent = game:GetService("Workspace")
				Spawn(function()
					while Orb and Orb.Parent do
						local RotatedCFrame = Orb.CFrame * CFrame.Angles(0, 0.1, 0)
						BodyGyro.cframe = RotatedCFrame
						Orb.CFrame = RotatedCFrame
						wait(Rate)
					end
				end)
			end)
			wait(ReloadTime)
			Tool.Enabled = true
		end
	end
end

ServerControl.OnServerInvoke = OnServerInvoke

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)