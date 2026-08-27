--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")
InsertService = game:GetService("InsertService")


Module = require(191816425)

Functions = require(script:WaitForChild("Functions"))

StunScript = script:WaitForChild("StunScript")
OverseerMonitor = script:WaitForChild("OverseerMonitor")

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
	Whack = {Animation = Tool:WaitForChild("Whack"), FadeTime = nil, Weight = nil, Speed = 3, Duration = 1, Damage = {Min = 20, Max = 30}},
	Bash = {Animation = Tool:WaitForChild("Bash"), FadeTime = nil, Weight = nil, Speed = 3, Duration = 1, Damage = {Min = 15, Max = 20}},
	Spin = {Animation = Tool:WaitForChild("Spin"), FadeTime = nil, Weight = nil, Speed = 1, Duration = 1},
	RiseArms = {Animation = Tool:WaitForChild("RiseArms"), FadeTime = nil, Weight = nil, Speed = 0.8, Duration = nil},
}

Sounds = {
	Swing1 = Handle:WaitForChild("Swing1"),
	Swing2 = Handle:WaitForChild("Swing2"),
	Swing3 = Handle:WaitForChild("Swing3"),
	Swing4 = Handle:WaitForChild("Swing4"),
	Hit = Handle:WaitForChild("Hit"),
	Bash = Handle:WaitForChild("Bash"),
}

Grips = {
	Unequipped = CFrame.new(0, -0.75, 0.375, 1, 0, 0, 0, 1, 0, 0, 0, 1),
	Equipped = CFrame.new(0, -0.75, 0.375, 1, 0, 0, 0, 1, 0, 0, 0, 1),
}

Special = {
	Enabled = true,
	Active = false,
	Duration = 30,
	ReloadTime = 20,
}

OverseerCostume = {
	Body = {81725326, 81725392, 81725366, 81725429, 81725459},
	Hats = {82665932, 87262534, 63994173, 127505667, 153558902, 156486074, 182774658, 223751795, 232506984, 286511631, 286511038},
}

ToolEquipped = false

Clicks = 0
FirstClick = false

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

Tool.Grip = Grips.Unequipped
Tool.Enabled = true

function InsertAsset(AssetId)
	local AssetModel = InsertService:LoadAsset(AssetId)
	local Asset = AssetModel:GetChildren()[1]:Clone()
	Debris:AddItem(AssetModel, 1)
	return Asset
end

function Billboard(Pos, Text, Time, Color)
	local Rate = (1 / 30)
	local Pos = (Pos or Vector3.new(0, 0, 0))
	local Text = (Text or "")
	local Time = (Time or 2)
	local Color = (Color or Color3.new(1, 0, 0))
	local EffectPart = BasePart:Clone()
	EffectPart.Name = "Effect"
	EffectPart.Size = Vector3.new(0, 0, 0)
	EffectPart.CFrame = CFrame.new(Pos)
	EffectPart.Anchored = true
	EffectPart.CanCollide = false
	EffectPart.Transparency = 1
	local BillboardGui = Instance.new("BillboardGui")
	BillboardGui.Size = UDim2.new(3, 0, 3, 0)
	BillboardGui.Adornee = EffectPart
	local TextLabel = Instance.new("TextLabel")
	TextLabel.BackgroundTransparency = 1
	TextLabel.Size = UDim2.new(1, 0, 1, 0)
	TextLabel.Text = Text
	TextLabel.TextColor3 = Color
	TextLabel.TextScaled = true
	TextLabel.Font = Enum.Font.ArialBold
	TextLabel.Parent = BillboardGui
	BillboardGui.Parent = EffectPart
	Debris:AddItem(EffectPart, (Time + 0.1))
	EffectPart.Parent = game:GetService("Workspace")
	Delay(0, function()
		local Frames = (Time / Rate)
		for Frame = 1, Frames do
			wait(Rate)
			local Percent = (Frame / Frames)
			EffectPart.CFrame = CFrame.new(Pos) + Vector3.new(0, Percent, 0)
			TextLabel.TextTransparency = Percent
		end
		if EffectPart and EffectPart.Parent then
			EffectPart:Destroy()
		end
	end)
end

function Blow(Hit)
	if not Hit or not Hit.Parent or not CheckIfAlive() or not CurrentAnimation then
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
	local character = Hit.Parent
	local humanoid = character:FindFirstChild("Humanoid")
	local torso = character:FindFirstChild("Torso")
	if not humanoid or humanoid.Health == 0 or not torso then
		return
	end
	local player = Players:GetPlayerFromCharacter(character)
	if player and (player == Player or Functions.IsTeamMate(Player, player)) then
		return
	end
	local HumanoidFound = false
	for i, v in pairs(HitHumanoids) do
		if v.Humanoid == humanoid then
			local Index = HitHumanoids[i]
			Index.Hits = (Index.Hits + 1)
			HitHumanoids[i] = Index
			if Index.Hits >= Index.MaxHits then
				HumanoidFound = true
			end
		end
	end
	if HumanoidFound then
		return
	end
	local Crit = false
	if CurrentAnimation == Animations.Whack then
		local CritChance = math.random(1, 10)
		if CritChance == 1 then
			Crit = true
			local FlingDirection = CFrame.new(Torso.Position, (torso.Position + Vector3.new(0, 5, 0))).lookVector
			humanoid.Sit = true
			torso.Velocity = (FlingDirection * 150)
		end
	end
	Sounds.Hit:Play()
	table.insert(HitHumanoids, {Humanoid = humanoid, Hits = 0, MaxHits = math.random(1, 3)})
	Functions.UntagHumanoid(humanoid)
	Functions.TagHumanoid(humanoid, Player)
	local DamageValue = CurrentAnimation.Damage
	local DamageAmount = math.random(DamageValue.Min, DamageValue.Max)
	local Radius = Vector3.new(1.25, 0.25, 1.25)
	Radius = (Radius * 100)
	local Offset = Vector3.new(math.random(-Radius.X, Radius.X), math.random(-Radius.Y, Radius.Y), math.random(-Radius.Z, Radius.Z))
	Offset = Offset * Vector3.new(0.01, 0.01, 0.01)
	Billboard((Handle.Position + Offset + Vector3.new(0, 2.5, 0)), DamageAmount, 2, BrickColor.new("Really red").Color)
	humanoid:TakeDamage(DamageAmount * ((Crit and 1.5) or 1))
end

function GetNearbyObjects(Region)
	local IgnoreList = {Character}
	for i, v in pairs(Players:GetChildren()) do
		if v:IsA("Player") and v ~= Player and v.Character and v.Character.Parent and Functions.IsTeamMate(Player, v) then
			table.insert(IgnoreList, v.Character)
		end
	end
	return Functions.GetParts(Region, 500, IgnoreList)
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
		local SingleClickAnims = {Animations.Whack}
		local DoubleClickAnims = {Animations.Bash}
		if Clicks < 2 then
			local SlashSounds = {Sounds.Swing1, Sounds.Swing2, Sounds.Swing3, Sounds.Swing4}
			SlashSounds[math.random(1, #SlashSounds)]:Play()
		else
			Sounds.Bash:Play()
		end
		CurrentAnimation = (((Clicks < 2 or #DoubleClickAnims == 0) and SingleClickAnims[math.random(1, #SingleClickAnims)]) or DoubleClickAnims[math.random(1, #DoubleClickAnims)])
		Tool.Grip = Grips.Unequipped
		HitHumanoids = {}
		Spawn(function()
			InvokeClient("PlayAnimation", CurrentAnimation)
		end)
		if CurrentAnimation.Animation == Animations.Whack.Animation then
			local SpinChance = math.random(1, 3)
			if SpinChance == 1 then
				Spawn(function()
					InvokeClient("PlayAnimation", Animations.Spin)
				end)
			end
		elseif CurrentAnimation.Animation == Animations.Bash.Animation then
			local RayHit, RayPos, RayNormal, RaySurface = Functions.CastRay(Handle.Position, Vector3.new(0, -1, 0), (Torso.Size.Y * 2), {Character}, false)
			if RayHit then
				local Radius = 20
				local Gravity = 196.20
				for i = 1, math.random(8, 16) do
					local Part = Instance.new("Part")
					Part.Name = "Effect"
					Part.Transparency = 1
					Part.FormFactor = Enum.FormFactor.Custom
					Part.Size = Vector3.new(2, 2, 2)
					Part.Anchored = false
					Part.CanCollide = false
					local HitDelay = false
					Part.Touched:connect(function(Hit)
						if not Hit or not Hit.Parent or HitDelay then
							return
						end
						local character = Hit.Parent
						local humanoid = character:FindFirstChild("Humanoid")
						if not humanoid or humanoid.Health == 0 then
							return
						end
						local player = Players:GetPlayerFromCharacter(character)
						if player and (player == Player or Functions.IsTeamMate(Player, player)) then
							return
						end
						HitDelay = true
						Functions.UntagHumanoid(humanoid)
						Functions.TagHumanoid(humanoid, Player)
						humanoid:TakeDamage(10)
						wait(0.5)
						HitDelay = false
					end)
					local Smoke = Instance.new("Fire")
					Smoke.Color = BrickColor.new("Lime green").Color
					Smoke.SecondaryColor = BrickColor.new("Really black").Color
					Smoke.Size = 8
					Smoke.Heat = 5
					Smoke.Parent = Part
					local Mass = (Part:GetMass() * Gravity)
					local Force = Instance.new("BodyForce")
					Force.force = Vector3.new(0, Mass, 0)
					Force.Parent = Part
					Part.Velocity = (Vector3.new(0, 1, 0) * 25)
					Delay(2, (function()
						Smoke.Enabled = false
						Part.Anchored = true
						HitDelay = true
					end))
					Debris:AddItem(Part, 3)
					Part.CFrame = (Torso.CFrame + (Torso.CFrame * CFrame.Angles(0, (math.random(-360, 360) * 0.01), 0)).lookVector * math.random(0, (Radius * 2.5)))
					Part.CFrame = (Part.CFrame - Vector3.new(0, 10, 0))
					Part.Parent = game:GetService("Workspace")
				end
				local NearbyObjects = GetNearbyObjects(Region3.new((Torso.Position - Vector3.new(Radius, Radius, Radius)), (Torso.Position + Vector3.new(Radius, Radius, Radius))))
				local HumanoidsHit = {}
				for i, v in pairs(NearbyObjects) do
					local character = v.Parent
					if character then
						local humanoid = character:FindFirstChild("Humanoid")
						local torso = character:FindFirstChild("Torso")
						if humanoid and humanoid.Health > 0 and torso and not Functions.CheckTableForInstance(HumanoidsHit, humanoid) then
							table.insert(HumanoidsHit, humanoid)
							humanoid.Sit = true
							torso.RotVelocity = (Vector3.new(math.random(), math.random(), math.random()) * (math.random() * 10))
							Functions.UntagHumanoid(humanoid)
							Functions.TagHumanoid(humanoid, Player)
							humanoid:TakeDamage(15)
							local StunChance = math.random(1, 10)
							if StunChance == 1 then
								local StunScriptCopy = character:FindFirstChild(StunScript.Name)
								if not StunScriptCopy then
									StunScriptCopy = StunScript:Clone()
									local Duration = Instance.new("NumberValue")
									Duration.Name = "Duration"
									Duration.Value = 0
									Duration.Parent = StunScriptCopy
									local JumpDisabler = StunScriptCopy:FindFirstChild("JumpDisabler")
									if JumpDisabler then
										JumpDisabler.Disabled = false
									end
								end
								local Duration = StunScriptCopy:FindFirstChild("Duration")
								if Duration then
									Duration.Value = 3.5
								end
								StunScriptCopy.Disabled = false
								StunScriptCopy.Parent = character
							end
						end
					end
				end
			end
--			GetNearbyObjects(Region)
		end
		wait(CurrentAnimation.Duration)
		HitHumanoids = {}
		Tool.Grip = Grips.Equipped
		CurrentAnimation = nil
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
	ToolEquipped = true
	Spawn(function()
		Tool.Grip = Grips.Equipped
		Spawn(function()
			InvokeClient("PlayAnimation", Animations.Equip)
		end)
		ModuleTable = Module.GetTable({Key = "MakeNPC", Player = Player})
		ModuleData = ModuleTable.GetData({Player = Player, Tool = Tool})
		NPC = ModuleData.MakeNPC({
			NameTagHidden = true,
			MaxHealth = 150,
			AIControl = {
				SelfSufficient = false,
				Creator = Player,
				Mode = "Wander",
				WanderRange = Vector3.new(10, 10, 10),
				AutoWander = true,
				MoveDelay = nil,
				Chase = true,
				ChaseDistance = 100,
				ChaseRange = 0,
				NormalSpeed = 16,
				ChaseSpeed = 20,
				Damage = 10,
				DamageDelay = 0.1,
			}
		}):Clone()
		NPC.Name = "Overseer Minion"
		for i, v in pairs(NPC:GetChildren()) do
			if v:IsA("BasePart") then
				v.BrickColor = BrickColor.new("Mid gray")
			end
		end
		for i, v in pairs(OverseerCostume.Body) do
			local Asset = InsertAsset(v)
			Asset.Parent = NPC
		end
		for i, v in pairs(OverseerCostume.Hats) do
			local Asset = InsertAsset(v)
		end
	end)
end

function Unequipped()
	Clicks = 0
	FirstClick = false
	for i, v in pairs({ToolUnequipped}) do
		if v then
			v:disconnect()
		end
	end
	Tool.Grip = Grips.Unequipped
	ToolEquipped = false
end

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
end

function OnServerInvoke(player, mode, value)
	if player ~= Player or not mode or not value then
		return
	end
	if mode == "KeyPress" then
		local Key = value.Key
		local Down = value.Down
		if Key == "q" and Down then
			if Special.Enabled and not Special.Active then
				Special.Enabled = false
				Special.Active = true
				Spawn(function()
					InvokeClient("PlayAnimation", Animations.RiseArms)
				end)
				wait(5)
				local OverseerModel = Instance.new("Model")
				OverseerModel.Name = "OverseerMinions"
				ModuleData.MakeNPC({
					NPC = OverseerModel,
					AIControl = {
						SelfSufficient = true,
					}
				})
				local OverseerMonitorCopy = OverseerMonitor:Clone()
				OverseerMonitorCopy.Disabled = false
				OverseerMonitorCopy.Parent = OverseerModel
				Debris:AddItem(OverseerModel, Special.Duration)
				OverseerModel.Parent = game:GetService("Workspace")
				for i = 1, 6 do
					local Minion = NPC:Clone()
					local Hat = OverseerCostume.Hats[math.random(1, #OverseerCostume.Hats)]
					Hat = InsertAsset(Hat)
					Hat.Parent = Minion
					local OverseerTorso = Minion:FindFirstChild("Torso")
					local SpawnRadius = 35
					local SpawnPosition = Vector3.new(Torso.Position.X + math.random(-SpawnRadius, SpawnRadius), Torso.Position.Y, Torso.Position.Z + math.random(-SpawnRadius, SpawnRadius))
					OverseerTorso.CFrame = (CFrame.new(SpawnPosition) * CFrame.Angles(0, (math.random(-360, 360) * 0.01), 0))
					Minion.Parent = OverseerModel
				end
				wait(Special.Duration)
				Special.Active = false
				wait(Special.ReloadTime)
				Special.Enabled = true
			end
		end
	end
end

Handle.Touched:connect(Blow)

ServerControl.OnServerInvoke = OnServerInvoke

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)