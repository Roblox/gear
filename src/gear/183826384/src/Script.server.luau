--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

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
	LeftSlash = {Animation = Tool:WaitForChild("LeftSlash"), FadeTime = nil, Weight = nil, Speed = nil, Duration = 0.75, Damage = 15},
	RightSlash = {Animation = Tool:WaitForChild("RightSlash"), FadeTime = nil, Weight = nil, Speed = nil, Duration = 0.75, Damage = 15},
	Rise = {Animation = Tool:WaitForChild("Rise"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil, Damage = 5, MaxDamage = 50}
}

Sounds = {
	Unsheath = Handle:WaitForChild("Unsheath"),
	Slash = Handle:WaitForChild("Slash"),
	Lunge = Handle:WaitForChild("Lunge")
}

Gravity = 196.20

Damage = 5

Equipped = false

CurrentAnimation = nil

Special = {
	Enabled = true,
	Active = false,
	ReloadTime = 20,
	Damage = 10,
}

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

Tool.Enabled = true

ServerControl.OnServerInvoke = (function(player, Mode, Value)
	if player == Player and Equipped and CheckIfAlive() then
		if Mode == "KeyPress" then
			local Key = Value.Key
			local Down = Value.Down
			if Key == "q" and Down then
				if Special.Enabled and not Special.Active and Tool.Enabled then
					Special.Enabled = false
					Special.Active = true
					local CurrentlyEquipped = true
					if ActivatedToolUnequipped then
						ActivatedToolUnequipped:disconnect()
					end
					ActivatedToolUnequipped = Tool.Unequipped:connect(function()
						CurrentlyEquipped = false
						if ActivatedToolUnequipped then
							ActivatedToolUnequipped:disconnect()
						end
					end)
					local player = Player
					local character = Character
					local humanoid = Humanoid
					local torso = Torso
					local Rise = Animations.Rise
					InvokeClient("PlayAnimation", Rise)
					local Mass = (GetTotalMass(Character) * Gravity * 1.5)
					BodyPosition = Instance.new("BodyPosition")
					BodyPosition.maxForce = Vector3.new(math.huge, Mass, math.huge)
					local FloatPosition = (torso.Position.Y + 25)
					BodyPosition.position = Vector3.new(torso.Position.X, FloatPosition, torso.Position.Z)
					Debris:AddItem(BodyPosition, 20)
					BodyPosition.Parent = Torso
					wait(3)
					if CurrentlyEquipped and humanoid and humanoid.Parent and humanoid.Health > 0 and torso and torso.Parent and BodyPosition and BodyPosition.Parent then
						BodyPosition.maxForce = Vector3.new(math.huge, math.huge, math.huge)
						local PX, PY, PZ, R00, R01, R02, R10, R11, R12,R20, R21, R22 = torso.CFrame:components()
						torso.CFrame = CFrame.new(PX, FloatPosition, PZ, R00, R01, R02, R10, R11, R12, R20, R21, R22)
						local TorsoCFrame = Torso.CFrame
						LandModel = Instance.new("Model")
						LandModel.Name = "LandModel"
						Debris:AddItem(LandModel, 15)
						LandModel.Parent = game:GetService("Workspace")
						local IncreaseRadius = 5
						local Radius = Character:GetModelSize().Y
						local GrassParts = {}
						local EarthParts = {}
						for i = 1, math.random(10, 15) do
							if humanoid and humanoid.Parent and humanoid.Health > 0 then
								for ii = 1, math.random(20, 35) do
									local LandPart = Instance.new("Model")
									LandPart.Name = "LandPart"
									local Size = (math.random(500, 1500) * 0.001)
									local Grass = BasePart:Clone()
									Grass.Name = "Grass"
									Grass.BrickColor = BrickColor.new("Bright green")
									Grass.Material = Enum.Material.Grass
									Grass.Size = Vector3.new(Size, 0.2, Size)
									Grass.CanCollide = false
									local Dirt = Grass:Clone()
									Dirt.Name = "Dirt"
									Dirt.BrickColor = BrickColor.new("Brown")
									local Weld = Instance.new("Weld")
									Weld.Part0 = Grass
									Weld.Part1 = Dirt
									Weld.C1 = CFrame.new(0, ((Grass.Size.Y / 2) + (Dirt.Size.Y / 2)), 0)
									Weld.Parent = Grass
									Grass.Parent = LandPart
									Dirt.Parent = LandPart
									LandPart.Parent = LandModel
									local Direction = CFrame.Angles(math.random(0, 360), math.random(0, 360), math.random(0, 360)).lookVector
									local StartPosition = (TorsoCFrame + Direction * (Radius + (IncreaseRadius * 2)))
									local EndPosition = (TorsoCFrame + Direction * (Radius + (IncreaseRadius * 1))).p
									Grass.CFrame = StartPosition
									Grass.CFrame = CFrame.new(Grass.Position, TorsoCFrame.p) * CFrame.Angles((math.pi / 2), 0, 0)
									Grass.Anchored = true
									local LandMass = (GetTotalMass(LandPart) * Gravity * 6)
									local BP = Instance.new("BodyPosition")
									BP.maxForce = Vector3.new(LandMass, LandMass, LandMass)
									BP.position = EndPosition
									BP.Parent = Grass
									Grass.Anchored = false
									table.insert(EarthParts, Grass)
									table.insert(EarthParts, Dirt)
									table.insert(GrassParts, {Part = Grass, Dirt = Dirt, BodyPosition = BP, Direction = Direction, Mass = LandMass})
								end
								wait(0.1)
							end
						end
						wait(3)
						if CurrentlyEquipped then
							local Limbs = {"Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"}
							local PlayerConnections = {}
							for i, v in pairs(Players:GetChildren()) do
								if v:IsA("Player") and v ~= player and v.Character then
									local EnemyPlayer = v
									local EnemyCharacter = EnemyPlayer.Character
									local EnemyHumanoid = EnemyCharacter:FindFirstChild("Humanoid")
									if EnemyHumanoid then
										for ii, vv in pairs(EnemyCharacter:GetChildren()) do
											if vv:IsA("BasePart") and CheckTableForString(Limbs, vv.Name) then
												local PlayerHit = vv.Touched:connect(function(Hit)
													if not Hit or not Hit.Parent then
														return
													end
													if CheckTableForInstance(EarthParts, Hit) then
														UntagHumanoid(EnemyHumanoid)
														TagHumanoid(EnemyHumanoid, EnemyPlayer)
														EnemyHumanoid:TakeDamage(Special.Damage)
													end
												end)
												table.insert(PlayerConnections, PlayerHit)
											end
										end
									end
								end
							end
							Delay(5, function()
								for i, v in pairs(PlayerConnections) do
									if v then
										v:disconnect()
									end
								end
							end)
							for i, v in pairs(GrassParts) do
								if v.Part and v.Part.Parent then
									if v.BodyPosition and v.BodyPosition.Parent then
										v.BodyPosition:Destroy()
									end
									v.Part.CanCollide = true
									if v.Dirt and v.Dirt.Parent then
										v.Dirt.CanCollide = true
									end
									local Velocity = v.Direction * 50
									local BV = Instance.new("BodyVelocity")
									BV.maxForce = Vector3.new(v.LandMass, v.LandMass, v.LandMass)
									BV.velocity = Velocity
									BV.Parent = v.Part
									v.Part.Velocity = Velocity
								end
							end
						end
					end
					wait(5)
					if CurrentlyEquipped then
						if BodyPosition and BodyPosition.Parent then
							BodyPosition:Destroy()
						end
						InvokeClient("StopAnimation", Rise)
					end
					Special.Active = false
					wait(Special.ReloadTime)
					Special.Enabled = true
				end
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

function CheckTableForInstance(Table, Instance)
	for i, v in pairs(Table) do
		if v == Instance then
			return true
		end
	end
	return false
end

function CheckTableForString(Table, String)
	for i, v in pairs(Table) do
		if string.lower(v) == string.lower(String) then
			return true
		end
	end
	return false
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

function Blow(Part)
	Part.Touched:connect(function(Hit)
		if not Hit or not Hit.Parent or not Equipped or not CheckIfAlive() then
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
		local humanoid = character:FindFirstChild("Humanoid")
		if character ~= Character and humanoid and humanoid.Health > 0 then
			local DamageValue = ((CurrentAnimation and CurrentAnimation.Damage) or Damage)
			UntagHumanoid(humanoid)
			TagHumanoid(humanoid, Player)
			humanoid:TakeDamage(DamageValue)
		end
	end)
end

function Activated()
	if not Tool.Enabled or not Equipped or not CheckIfAlive() or Special.Active then
		return
	end
	Tool.Enabled = false
	Sounds.Slash:Play()
	local CurrentlyEquipped = true
	if ActivatedToolUnequipped then
		ActivatedToolUnequipped:disconnect()
	end
	ActivatedToolUnequipped = Tool.Unequipped:connect(function()
		CurrentlyEquipped = false
		if ActivatedToolUnequipped then
			ActivatedToolUnequipped:disconnect()
		end
	end)
	local SlashAnims = {Animations.LeftSlash, Animations.RightSlash}
	local SlashAnim = SlashAnims[math.random(1, #SlashAnims)]
	CurrentAnimation = SlashAnim
	InvokeClient("PlayAnimation", SlashAnim)
	InvokeClient("PlaySound", Sounds.Slash)
	wait(SlashAnim.Duration)
	if CurrentlyEquipped then
		InvokeClient("StopAnimation", SlashAnim)
		CurrentAnimation = nil
	end
	Tool.Enabled = true
end

function CheckIfAlive()
	return (Player and Player.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent)
end

function Equipped(Mouse)
	Equipped = true
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso")
	if not CheckIfAlive() then
		return
	end
	Sounds.Unsheath:Play()
end

function Unequipped()
	Equipped = false
	CurrentAnimation = nil
	for i, v in pairs({BodyPosition, LandModel}) do
		if v and v.Parent then
			v:Destroy()
		end
	end
	for i, v in pairs({ActivatedToolUnequipped}) do
		if v then
			v:disconnect()
		end
	end
	for i, v in pairs(Animations) do
		if v and v.Parent then
			InvokeClient("StopAnimation", v)
		end
	end
	for i, v in pairs(Sounds) do
		if v and v.Parent then
			v:Stop()
			InvokeClient("StopSound", v)
		end
	end
end

Blow(Handle)

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)