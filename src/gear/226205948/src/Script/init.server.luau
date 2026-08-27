--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

FlowerScript = script:WaitForChild("FlowerScript")

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
	Summon = {Animation = Tool:WaitForChild("Summon"), FadeTime = nil, Weight = nil, Speed = 0.75, Duration = 2},
	LeftSlash = {Animation = Tool:WaitForChild("LeftSlash"), FadeTime = nil, Weight = nil, Speed = 1.2, Duration = 0.75, Damage = {Min = 30, Max = 35}},
	RightSlash = {Animation = Tool:WaitForChild("RightSlash"), FadeTime = nil, Weight = nil, Speed = 1.19, Duration = 0.75, Damage = {Min = 30, Max = 35}},
}

Sounds = {
	Slash = Handle:WaitForChild("Slash"),
	Unsheath = Handle:WaitForChild("Unsheath"),
	Flames = Handle:WaitForChild("Flames"),
	Flowers = Handle:WaitForChild("Flowers")
}

TouchDamage = {Min = 0, Max = 0}
ToolEquipped = false
Attacking = false

SpecialEnabled = true
SpecialActive = false
SpecialDuration = 30
SpecialReloadTime = 15

FlameDuration = 0
FlamesActive = false

ReloadTime = 0.75

Gravity = 196.20
Rate = (1 / 60)

ProjectileNames = {"Water", "Arrow", "Projectile", "Effect", "Rail", "Laser", "Bullet"}

HumanoidsHit = {}

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

Tool.Enabled = true

function CheckTableForString(Table, String)
	for i, v in pairs(Table) do
		if string.lower(v) == string.lower(String) then
			return true
		end
	end
	return false
end

function CheckIntangible(Hit)
	if Hit and Hit.Parent then
		if Hit.Transparency > 0.8 or CheckTableForString(ProjectileNames, Hit.Name) or Hit.Parent:FindFirstChild("Humanoid") then
			return true
		end
	end
	return false
end

function CastRay(StartPos, Vec, Length, Ignore, DelayIfHit)
	local Ignore = ((type(Ignore) == "table" and Ignore) or {Ignore})
	local RayHit, RayPos, RayNormal = game:GetService("Workspace"):FindPartOnRayWithIgnoreList(Ray.new(StartPos, Vec * Length), Ignore)
	if RayHit and CheckIntangible(RayHit) then
		if DelayIfHit then
			wait()
		end
		RayHit, RayPos, RayNormal = CastRay((RayPos + (Vec * 0.01)), Vec, (Length - ((StartPos - RayPos).magnitude)), Ignore, DelayIfHit)
	end
	return RayHit, RayPos, RayNormal
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

function CheckTableForInstance(Table, Instance)
	for i, v in pairs(Table) do
		if v == Instance then
			return true
		end
	end
	return false
end

function CreateFirePart(Create)
	for i, v in pairs(Handle:GetChildren()) do
		if v:IsA("BasePart") and v.Name == "FirePart" then
			v:Destroy()
		end
	end
	if not Create then
		return
	end
	local FirePart = BasePart:Clone()
	FirePart.Name = "FirePart"
	FirePart.Transparency = 1
	FirePart.CanCollide = false
	local Fire = Instance.new("Fire")
	Fire.Color = Color3.new((255 / 255), (255 / 255), (0 / 255))
	Fire.SecondaryColor = Color3.new((255 / 255), (255 / 255),  (127 / 255))
	Fire.Heat = 25
	Fire.Size = 3
	Fire.Enabled = true
	Fire.Parent = FirePart
	local FireWeld = Instance.new("Weld")
	FireWeld.Part0 = Handle
	FireWeld.Part1 = FirePart
	FireWeld.C0 = (FireWeld.C0 * CFrame.new(0, 0, 0.5)) * CFrame.Angles(-(math.pi / 2), 0, 0)
	FireWeld.Parent = FirePart
	FirePart.Parent = Handle
end

function Blow(Hit)
	if not Hit or not Hit.Parent or not CheckIfAlive() then
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
	if character == Character then
		return
	end
	
	local player = Players:GetPlayerFromCharacter(character)
	if player and IsTeamMate(Player, player) then
		return
	end
	
	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid or humanoid.Health == 0 or CheckTableForInstance(HumanoidsHit, humanoid) then
		return
	end
	
	table.insert(HumanoidsHit, humanoid)
	
	local DamageValue = ((CurrentAnimation and CurrentAnimation.Damage) or TouchDamage)
	local DamageAmount = (math.random(DamageValue.Min, DamageValue.Max) * ((FlamesActive and 1.10) or 1))
	
	UntagHumanoid(humanoid)
	TagHumanoid(humanoid, Player)
	
	local HealthAfter = (humanoid.Health - DamageAmount)
	
	humanoid:TakeDamage(DamageAmount)
	
	if HealthAfter <= 0 then
		if not FlamesActive then
			FlamesActive = true
			Sounds.Flames:Play()
			CreateFirePart(true)
			Spawn(function()
				while FlamesActive and ToolEquipped and CheckIfAlive() and FlameDuration > 0 do
					local Time = wait(Rate)
					FlameDuration = (FlameDuration - Time)
				end
				CreateFirePart(false)
				FlameDuration = 0
				FlamesActive = false
			end)
		else
			local HealthBack = (Humanoid.MaxHealth * 0.20)
			Humanoid.Health = (Humanoid.Health + HealthBack)
		end
		FlameDuration = 5
	end
	
end

function Attack(PossibleAnims, PossibleSounds)
	if PossibleAnims and #PossibleAnims > 0 then
		if PossibleSounds and #PossibleSounds > 0 then
			local RandomSound = PossibleSounds[math.random(1, #PossibleSounds)]
			RandomSound:Play()
		end
		local SelectedAnimation = PossibleAnims[math.random(1, #PossibleAnims)]
		Delay(((SelectedAnimation.Delay and SelectedAnimation.Delay) or 0), (function()
			HumanoidsHit = {}
			CurrentAnimation = SelectedAnimation
			InvokeClient("PlayAnimation", CurrentAnimation)
			if CurrentAnimation and CurrentAnimation.Duration and CurrentAnimation.Duration > 0 then
				wait(CurrentAnimation.Duration)
			end
			CurrentAnimation = nil
			HumanoidsHit = {}
		end))
	end
end

function Activated()
	if not Tool.Enabled or not ToolEquipped then
		return
	end
	Tool.Enabled = false
	Attacking = true
	local AttackSounds = {Sounds.Slash}
	local AttackAnims = {Animations.LeftSlash, Animations.RightSlash}
	Attack(AttackAnims, AttackSounds)
	Attacking = false
	wait(ReloadTime)
	Tool.Enabled = true
end

function GrowFlower(Part, Position)
	if not Part or not Part.Parent or not Position then
		return
	end
	local ToObjectSpace = Part.CFrame:toObjectSpace(CFrame.new(Position + Vector3.new(0, -1, 0)) * CFrame.Angles(0, (math.random() * math.pi * 2), 0))
	if not ToObjectSpace then
		return
	end
	local GrowRate = 0.1
	local GrowHeight = (0.5 + math.random())
	local PlantType = math.random(1, 2)
	local Flower = BasePart:Clone()
	Flower.Name = "Effect"
	Flower.CanCollide = false
	local FlowerMesh = Instance.new("SpecialMesh")
	if PlantType == 1 then
		FlowerMesh.MeshId = (BaseUrl .. "12212520")
		FlowerMesh.TextureId = (BaseUrl .. "12212536")
		FlowerMesh.VertexColor = Vector3.new((math.random(1, 3) * 0.1), 7.8, (math.random(1, 3) * 0.1))
		FlowerMesh.Scale = Vector3.new(1, 3, 1)
	elseif PlantType == 2 then
		GrowHeight = (1.25 + (math.random() * 0.5))
		local Colors = {
			Vector3.new(0, 0.5, 1), --Blue
			Vector3.new(1, 1, 0), --Yellow
			Vector3.new(0.5, 0.5, 1), --Purple
			Vector3.new(1, 1, 1), --White
		}
		FlowerMesh.MeshId = (BaseUrl .. "111797211")
		FlowerMesh.TextureId = (BaseUrl .. "225802148")
		FlowerMesh.VertexColor = Colors[math.random(1, #Colors)]
		FlowerMesh.Scale = Vector3.new(0.5, 0.5, 0.5)
	end
	FlowerMesh.Parent = Flower
	local Weld = Instance.new("Motor")
	Weld.Part0 = Part
	Weld.Part1 = Flower
	Weld.C0 = ToObjectSpace
	Weld.C1 = CFrame.new()
	Weld.Parent = Flower
	Sounds.Flowers:Play()
	Spawn(function()
		local GrowFrames = math.ceil(5 / GrowRate)
		for i = 1, GrowFrames do
			if Weld and Weld.Parent then
				wait(GrowRate)
				Weld.C1 = CFrame.new(0, (-(i / GrowFrames) * GrowHeight),0)
			end
		end
	end)
	return Flower
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
		InvokeClient("PlayAnimation", Animations.Equip)
	end)
	Sounds.Unsheath:Play()
	ToolEquipped = true
end

function Unequipped()
	Attacking = false
	FlameDuration = 0
	FlamesActive = false
	for i, v in pairs(Sounds) do
		v:Stop()
	end
	if CheckIfAlive() then
		Humanoid.WalkSpeed = 16
	end
	CreateFirePart(false)
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
	if player ~= Player or not ToolEquipped or not CheckIfAlive() then
		return
	end
	if Mode == "Button1Click" then
		local Down = Value.Down
	elseif Mode == "KeyPress" then
		local Down = Value.Down
		local Key = Value.Key
		local ByteKey = string.byte(Key)
		if Key == "q" and Down and SpecialEnabled and not SpecialActive then
			SpecialEnabled = false
			SpecialActive = true
			Humanoid.WalkSpeed = 0
			InvokeClient("PlayAnimation", Animations.Summon)
			local Radius = 20
			local FlowerModel = Instance.new("Model")
			FlowerModel.Name = "Flowers"
			local FlowerScriptClone = FlowerScript:Clone()
			local Creator = Instance.new("ObjectValue")
			Creator.Name = "Creator"
			Creator.Value = Player
			Creator.Parent = FlowerScriptClone
			local Duration = Instance.new("NumberValue")
			Duration.Name = "Duration"
			Duration.Value = SpecialDuration
			Duration.Parent = FlowerScriptClone
			FlowerScriptClone.Disabled = false
			FlowerScriptClone.Parent = FlowerModel
			FlowerModel.Parent = game:GetService("Workspace")
			for i = 1, 250 do
				if not ToolEquipped or not CheckIfAlive() then
					break
				end
				local Direction = (Torso.CFrame * CFrame.Angles(0, (math.random(-360, 360) * 0.01), 0)).lookVector
				local Distance = (math.random(-(Radius * 1000), (Radius * 1000)) * 0.001)
				local Position = (Torso.CFrame + Direction * Distance).p
				local RayHit, RayPos, RayNormal = CastRay(Position, Vector3.new(0, -1, 0), (Torso.Size.Y * 4), {Character}, false)
				if RayHit then
					local Flower = GrowFlower(RayHit, RayPos)
					if (i % 2) == 1 then
						--local Smoke = Instance.new("Smoke")
						--Smoke.Color = Color3.new((255 / 255), (255 / 255), (0 /255))
						--Smoke.Opacity = 0.15
						--Smoke.RiseVelocity = 0.25
						--Smoke.Size = 0.1
						--Smoke.Enabled = true
						--Smoke.Parent = Flower
					end
					Flower.Parent = FlowerModel
				end
			end
			wait(5)
			if CheckIfAlive() then
				Humanoid.WalkSpeed = 16
				Spawn(function()
					InvokeClient("StopAnimation", Animations.Summon)
				end)
			end
			wait(SpecialDuration - 5)
			SpecialActive = false
			wait(SpecialReloadTime)
			SpecialEnabled = true
		end
	end
end)

CreateFirePart(false)

Handle.Touched:connect(Blow)

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)