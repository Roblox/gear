--Made by Luckymaxer
--Updated for R15 avatar by StarWars

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")
RunService = game:GetService("RunService")

RbxUtility = LoadLibrary("RbxUtility")
Create = RbxUtility.Create

StunScript = script:WaitForChild("StunScript")
PoisonFlashEffect = script:WaitForChild("PoisonFlashEffect")
DeathEffect = script:WaitForChild("DeathEffect")

DamageValues = {
	BaseDamage = 5,
	SlashDamage = 8,
	LungeDamage = 12,
}

--For R15 avatars
Animations = {
	R15Slash = 522635514,
	R15Lunge = 522638767
}

local BaseUrl = "rbxassetid://"

Damage = DamageValues.BaseDamage

Grips = {
	Up = CFrame.new(0.025, 0, 1.75, 1, 0, -0, 0, 0, 1, 0, -1, 0),
	Out = CFrame.new(0.025, 0, 1.75, 1, 0, -0, 0, 1, 0, 0, -0, 1),
}

Sounds = {
	Slash = Handle:WaitForChild("SwordSlash"),
	Lunge = Handle:WaitForChild("SwordLunge"),
	Unsheath = Handle:WaitForChild("Unsheath"),
	Poison = Handle:WaitForChild("Poison"),
}

BasePart = Create("Part"){
	Material = Enum.Material.Plastic,
	FormFactor = Enum.FormFactor.Custom,
	TopSurface = Enum.SurfaceType.Smooth,
	BottomSurface = Enum.SurfaceType.Smooth,
	Size = Vector3.new(0.2, 0.2, 0.2),
	Anchored = false,
	CanCollide = true,
	Locked = true,
}

GlowPart = BasePart:Clone()
GlowPart.Name = "Effect"
GlowPart.BrickColor = BrickColor.new("Really red")
GlowPart.Reflectance = 0
GlowPart.Transparency = 0.25
GlowPart.Material = Enum.Material.Neon
GlowPart.Size = Vector3.new(1, 1, 1)
GlowPart.CanCollide = false
Create("BlockMesh"){
	Name = "Mesh",
	Scale = Vector3.new(0.035, 0.25, 1.25),
	VertexColor = Vector3.new(1, 1, 1),
	Offset = Vector3.new(0, 0, 0),
	Parent = GlowPart,
}
Create("Weld"){
	Name = "Weld",
	Part0 = Handle,
	Part1 = GlowPart,
	C0 = CFrame.new(0.0375, 0, 0.025),
	C1 = CFrame.new(0, 0, 0),
	Parent = GlowPart,
}

Rate = (1 / 60)

Poisons = {}

ToolEquipped = false

ServerControl = (Tool:FindFirstChild("ServerControl") or Create("RemoteFunction"){
	Name = "ServerControl",
	Parent = Tool,
})

ClientControl = (Tool:FindFirstChild("ClientControl") or Create("RemoteFunction"){
	Name = "ClientControl",
	Parent = Tool,
})

Tool.Grip = Grips.Up
Tool.Enabled = true

function IsTeamMate(Player1, Player2)
	return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
end

function TagHumanoid(humanoid, player)
	local Creator_Tag = Create("ObjectValue"){
		Name = "creator",
		Value = player,
	}
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

function DealDamage(Hit, Damage)
	if not Hit or not Hit.Parent then
		return
	end
	local character = Hit.Parent
	local humanoid = character:FindFirstChild("Humanoid")
	local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
	if not humanoid or humanoid.Health == 0 or not torso then
		return
	end
	local player = Players:GetPlayerFromCharacter(character)
	if player and (player == Player or IsTeamMate(Player, player)) then
		return
	end
	UntagHumanoid(humanoid)
	TagHumanoid(humanoid, Player)
	humanoid:TakeDamage(Damage)
	if humanoid.Health <= 0 then
		local Direction = CFrame.new(Torso.Position, Hit.Position).lookVector
		Direction = Vector3.new(Direction.X, 1, Direction.Z)
		local DeathEffectScript = DeathEffect:Clone()
		DeathEffectScript.WindDirection.Value = Direction
		DeathEffectScript.Force.Value = Vector3.new(0, 0, 0)
		DeathEffectScript.Disabled = false
		DeathEffectScript.Parent = character
	else
		local PoisonFlashEffectScript = character:FindFirstChild(PoisonFlashEffect.Name)
		if PoisonFlashEffectScript then
			return
		end
		local ChanceToPoison = math.random()
		if ChanceToPoison <= 0.30 then
			local Sound = Sounds.Poison:Clone()
			Debris:AddItem(Sound, 4)
			Sound.Parent = torso
			Sound:Play()
			PoisonFlashEffectScript = PoisonFlashEffect:Clone()
			local Direction = CFrame.new(Torso.Position, Hit.Position).lookVector
			Direction = Vector3.new(Direction.X, 1, Direction.Z)
			local DeathEffectScript = DeathEffect:Clone()
			DeathEffectScript.WindDirection.Value = Direction
			DeathEffectScript.Force.Value = Vector3.new(0, 0, 0)
			DeathEffectScript.Disabled = true
			DeathEffectScript.Parent = PoisonFlashEffectScript
			local Creator = Create("ObjectValue"){
				Name = "Creator",
				Value = Player,
				Parent = PoisonFlashEffectScript,
			}
			local Creator = Create("ObjectValue"){
				Name = "Creator",
				Value = Player,
				Parent = PoisonFlashEffectScript,
			}
			PoisonFlashEffectScript.Disabled = false
			PoisonFlashEffectScript.Parent = character
			table.insert(Poisons, {Object = PoisonFlashEffectScript, Time = tick()})
			LightUpBlade()
		end
	end
end

function LightUpBlade()
	for i, v in pairs(Tool:GetChildren()) do
		if v:IsA("BasePart") and v ~= Handle then
			v:Destroy()
		end
	end
	local GlowPartCopy = GlowPart:Clone()
	GlowPartCopy.Weld.Part0 = Handle
	local PoisonActivated = (#Poisons > 0)
	if not PoisonActivated then
		return
	end
	GlowPartCopy.Parent = Tool
	local AliveCheck = 0
	local HealTick = tick()
	local Glow = {
		Rate = 20,
		Amount = 0.25,
		Interval = 0,
		More = true,
	}
	while GlowPartCopy and GlowPartCopy.Parent and PoisonActivated and #Poisons > 0 do
		local Now = tick()
		if (Now - AliveCheck) >= 1 then
			AliveCheck = Now
			for i, v in pairs(Poisons) do
				local Object = v.Object
				if not Object or not Object.Parent or not Object.Parent.Parent or Object.Parent.Parent ~= game:GetService("Workspace") or (Now - v.Time) > 3.5 then
					table.remove(Poisons, i)
				end
			end
			if #Poisons == 0 then
				PoisonActivated = false
			end
		end
		if (Now - HealTick) >= 0.25 then
			HealTick = Now
			Humanoid.Health = (Humanoid.Health + 1.5)
		end
		Glow.Interval = (Glow.Interval + 1)
		if GlowPartCopy and GlowPartCopy.Parent then
			local NewGlow = (((Glow.Amount / Glow.Rate) * 1) * ((Glow.More and 1) or -1))
			GlowPartCopy.Transparency = (GlowPartCopy.Transparency + NewGlow)
		end
		if Glow.Interval > Glow.Rate then
			Glow.More = not Glow.More
			Glow.Interval = 0
		end
		wait()
	end
	Debris:AddItem(GlowPartCopy, 3)
	while GlowPartCopy and GlowPartCopy.Parent and GlowPartCopy.Transparency < 1 do
		GlowPartCopy.Transparency = (GlowPartCopy.Transparency + 0.05)
		wait(Rate)
	end
	Debris:AddItem(GlowPartCopy, 0.5)
	if GlowPartCopy and GlowPartCopy.Parent then
		GlowPartCopy:Destroy()
	end
end

function Blow(Hit)
	if not Hit or not Hit.Parent or not CheckIfAlive() or not ToolEquipped then
		return
	end
	local RightArm = Character:FindFirstChild("Right Arm") or Character:FindFirstChild("RightHand")
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
	DealDamage(Hit, Damage)
end

function Attack()
	Damage = DamageValues.SlashDamage
	Sounds.Slash:Play()
	if Humanoid then
		if Humanoid.RigType == Enum.HumanoidRigType.R6 then
			local Anim = Create("StringValue"){
				Name = "toolanim",
				Value = "Slash",
			}
			Debris:AddItem(Anim, 2)
			Anim.Parent = Tool
		elseif Humanoid.RigType == Enum.HumanoidRigType.R15 then
			local Anim = Tool:FindFirstChild("R15Slash")
			if Anim then
				local Track = Humanoid:LoadAnimation(Anim)
				Track:Play(0)
			end
		end
	end
end

function Lunge()
	Damage = DamageValues.LungeDamage

	Sounds.Lunge:Play()

	if Humanoid then
		if Humanoid.RigType == Enum.HumanoidRigType.R6 then
			local Anim = Create("StringValue"){
				Name = "toolanim",
				Value = "Lunge",
			}
			Debris:AddItem(Anim, 2)
			Anim.Parent = Tool
		elseif Humanoid.RigType == Enum.HumanoidRigType.R15 then
			local Anim = Tool:FindFirstChild("R15Lunge")
			if Anim then
				local Track = Humanoid:LoadAnimation(Anim)
				Track:Play(0)
			end
		end
	end
	
	wait(0.2)
	Tool.Grip = Grips.Out
	Spawn(function()
		local MouseData = InvokeClient("MouseData")
		if not MouseData then
			return
		end
		local MousePosition = MouseData.Position
		if not MousePosition then
			return
		end
		local RayData = WebStrike({
			Start = (Handle.CFrame * CFrame.new(0, 0, -(Handle.Size.Z / 2))).p,
			End = MousePosition,
		})
		if not RayData then
			return
		end
		local Hit = RayData.Hit
		if not Hit or not Hit.Parent then
			return
		end
		local character = Hit.Parent
		if character:IsA("Hat") then
			character = character.Parent
		end
		local humanoid = character:FindFirstChild("Humanoid")
		local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
		if not humanoid or humanoid.Health == 0 or not torso then
			return
		end
		local player = Players:GetPlayerFromCharacter(character)
		if player and (player == Player or IsTeamMate(Player, player)) then
			return
		end
		local StunScriptCopy = character:FindFirstChild(StunScript.Name)
		if not StunScriptCopy then
			StunScriptCopy = StunScript:Clone()
			local Duration = Create("NumberValue"){
				Name = "Duration",
				Value = 0,
				Parent = StunScriptCopy,
			}
		end
		local Duration = StunScriptCopy:FindFirstChild("Duration")
		if Duration then
			Duration.Value = 3
		end
		if StunScriptCopy.Disabled or not StunScriptCopy.Parent then
			StunScriptCopy.Parent = character
			StunScriptCopy.Disabled = false
		end
	end)
	wait(0.75)
	Tool.Grip = Grips.Up

	Damage = DamageValues.SlashDamage
end

Tool.Enabled = true
LastAttack = 0

function Activated()
	if not Tool.Enabled or not ToolEquipped or not CheckIfAlive() then
		return
	end
	Tool.Enabled = false
	local Tick = RunService.Stepped:wait()
	if (Tick - LastAttack < 0.2) then
		Lunge()
	else
		Attack()
	end
	LastAttack = Tick
	--wait(0.5)
	Damage = DamageValues.BaseDamage
	local SlashAnim = Create("Animation"){
		Name = "R15Slash",
		AnimationId = BaseUrl .. Animations.R15Slash,
		Parent = Tool
	}
	
	local LungeAnim = Create("Animation"){
		Name = "R15Lunge",
		AnimationId = BaseUrl .. Animations.R15Lunge,
		Parent = Tool
	}		
	Tool.Enabled = true
end

function CheckTableForString(Table, String)
	for i, v in pairs(Table) do
		if string.find(string.lower(String), string.lower(v)) then
			return true
		end
	end
	return false
end

function CheckIntangible(Hit)
	local ProjectileNames = {"Water", "Arrow", "Projectile", "Effect", "Rail", "Laser", "Bullet"}
	if Hit and Hit.Parent then
		if CheckTableForString(ProjectileNames, Hit.Name) then
			return true
		end
	end
	return false
end

function CastRay(StartPos, Vec, Length, Ignore, DelayIfHit)
	local Ignore = ((type(Ignore) == "table" and Ignore) or {Ignore})
	local RayHit, RayPos, RayNormal, RayMaterial = game:GetService("Workspace"):FindPartOnRayWithIgnoreList(Ray.new(StartPos, Vec * Length), Ignore)
	if RayHit and CheckIntangible(RayHit) then
		if DelayIfHit then
			wait()
		end
		RayHit, RayPos, RayNormal, RayMaterial = CastRay((RayPos + (Vec * 0.01)), Vec, (Length - ((StartPos - RayPos).Magnitude)), Ignore, DelayIfHit)
	end
	return RayHit, RayPos, RayNormal, RayMaterial
end

function WebStrike(Table)
	local Source = Table.Start
	local Destination = Table.End
	local MaxDistance = (Table.MaxDistance or 12)
	local MaxOffset = (Table.MaxOffset or 1)
	
	local Direction = (Destination - Source).Unit
	local Distance = (Source - Destination).Magnitude
	if Distance > MaxDistance then
		Distance = MaxDistance
		Destination = (Source + Direction * Distance)
	end
	
	local MaxSegLength = 2
	local MinSegLength = 1
	
	local LastDistance = 0
	local Points = {Source}
	
	while (Distance - LastDistance) > MaxSegLength do
		LastDistance = (LastDistance + ((math.random() * (MaxSegLength - MinSegLength)) + MinSegLength))
		local Offset = Vector3.new((math.random(-(MaxOffset * 1000), (MaxOffset * 1000)) * 0.001), (math.random(-(MaxOffset * 1000), (MaxOffset * 1000)) * 0.001), (math.random(-(MaxOffset * 1000), (MaxOffset * 1000)) * 0.001))
		local NewVector = (Source + (LastDistance * Direction) + Offset)
		table.insert(Points, NewVector)
		--wait(Rate)
	end	
	table.insert(Points, Destination)
	
	local Parts = {}
	
	local WebModel = Create("Model"){
		Name = "SpiderWebModel",
	}
	Debris:AddItem(WebModel, 5)
	WebModel.Parent = game:GetService("Workspace")	
	
	local RayData
	for Index, i in pairs(Points) do
		local LastPart = BasePart:Clone()
		LastPart.BrickColor = BrickColor.new("Institutional white")
		LastPart.Material = Enum.Material.Concrete
		for i, v in pairs({"Top", "Bottom", "Left", "Right", "Front", "Back"}) do
			LastPart[v .. "Surface"] = Enum.SurfaceType.SmoothNoOutlines
		end
		LastPart.Reflectance = 1
		LastPart.Transparency = 0.3
		LastPart.Anchored = true
		LastPart.CanCollide = false
		local Mesh = Create("BlockMesh"){
			Scale = Vector3.new(0.5, 1, 0.5),
			Parent = LastPart,
		}
		local Point = Points[Index + 1]
		if Point then
			local PartDirection = (CFrame.new(((i + Point) / 2), Point) * CFrame.Angles((math.pi / 2), 0, 0))
			LastPart.Size = Vector3.new(0.5, (i - Point).Magnitude, 0.5)
			LastPart.CFrame = PartDirection
			local PointDirection = (PartDirection * CFrame.Angles(-(math.pi / 2), 0, 0)).lookVector
			local RayHit, RayPos, RayNormal, RayMaterial = CastRay(LastPart.Position, PointDirection, (LastPart.Size.Y * 1), {Character, WebModel}, false)
			Debris:AddItem(LastPart, 1)
			LastPart.Parent = WebModel
			Spawn(function()
				local FadeFrames = 30
				local FadeRate = (1 / 60)
				for i = 1, FadeFrames do
					LastPart.Transparency = ((1 / FadeFrames) * i)
					wait(FadeRate)
				end
			end)
			if RayHit then
				RayData = {Hit = RayHit, Pos = RayPos, Normal = RayNormal, Material = RayMaterial}
				break
			end
			wait(Rate)
		end
	end
	return RayData
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
	ToolEquipped = true
	Sounds.Unsheath:Play()
end

function Unequipped()
	Tool.Grip = Grips.Up
	ToolEquipped = false
end

function OnServerInvoke(player, mode, value)
	if player ~= Player or not ToolEquipped or not value or not CheckIfAlive() then
		return
	end
end

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
end

Handle.Touched:connect(Blow)

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)

ServerControl.OnServerInvoke = OnServerInvoke