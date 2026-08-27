--Rescripted by TakeoHonorable
--Unleash the power of chaos!

function Create(ty)
	return function(data)
		local obj = Instance.new(ty)
		for k, v in pairs(data) do
			if type(k) == 'number' then
				v.Parent = obj
			else
				obj[k] = v
			end
		end
		return obj
	end
end

local Tool = script.Parent
Tool.Enabled = true

local Handle = Tool:WaitForChild("Handle")

local Remote,MouseLoc = Tool:WaitForChild("Remote"),Tool:WaitForChild("MouseLoc")

local Player,Character,Humanoid,Root

local Services = {
	Players = (game:FindService("Players") or game:GetService("Players")),
	TweenService = (game:FindService("TweenService") or game:GetService("TweenService")),
	RunService = (game:FindService("RunService") or game:GetService("RunService")),
	Debris = (game:FindService("Debris") or game:GetService("Debris")),
	ReplicatedStorage = (game:FindService("ReplicatedStorage") or game:GetService("ReplicatedStorage")),
	Lighting = (game:FindService("Lighting") or game:GetService("Lighting")),
	ServerScriptService = (game:FindService("ServerScriptService") or game:GetService("ServerScriptService"))
}

local Components = {
	FireParticle = Handle:WaitForChild("Effect"):WaitForChild("Fire")
}

local Properties = {
	BurnRange = 30,
	StunRange = 60,
	StunCooldown = 20,
	UnwingRange = 300,
	UnwingCooldown = 20,
	SwordDamage = 25,
	
}

local Grips = {
	Up = CFrame.new(0, -2.3, 0, 0, 0, 1, 0, 1, -0, -1, 0, 0),
	Out = CFrame.new(0, -2.3, 0, 0, 1, -0, 0, -0, -1, -1, 0, -0),
}

function IsTeamMate(Player1, Player2)
	return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
end

function IsInTable(Table,Value)
	for _,v in pairs(Table) do
		if v == Value then
			return true
		end
	end
	return false
end

function TagHumanoid(humanoid, player)
	local Creator_Tag = Create("ObjectValue"){
		Name = "creator",
		Value = player,
	}
	Services.Debris:AddItem(Creator_Tag, 2)
	Creator_Tag.Parent = humanoid
end

function UntagHumanoid(humanoid)
	for i, v in pairs(humanoid:GetChildren()) do
		if v:IsA("ObjectValue") and v.Name == "creator" then
			v:Destroy()
		end
	end
end

function CastRay(StartPos, Vec, Length, Ignore, DelayIfHit)
	local Ignore = ((type(Ignore) == "table" and Ignore) or {Ignore})
	local RayHit, RayPos, RayNormal = game:GetService("Workspace"):FindPartOnRayWithIgnoreList(Ray.new(StartPos, Vec * Length), Ignore)
	return RayHit, RayPos, RayNormal
end

local Sounds = {
	Unsheath = Handle:WaitForChild("Unsheath"),
	Slash = Handle:WaitForChild("Slash"),
	Lunge = Handle:WaitForChild("Lunge"),
	Fire = Handle:WaitForChild("Fire"),
	Burn = Handle:WaitForChild("Burn"),
	Leap = Handle:WaitForChild("Leap")
}

local Animations = {}
local BurnEffect,Debounce = nil,false

function Equipped()
	Character = Tool.Parent
	Player = Services.Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChildOfClass("Humanoid")
	Root = Character:WaitForChild("HumanoidRootPart")
	Animations = Tool:WaitForChild("Animations"):WaitForChild(Humanoid.RigType.Name)
	Animations = {
		Darken = Humanoid:LoadAnimation(Animations:WaitForChild("Darken")),
		Slash = Humanoid:LoadAnimation(Animations:WaitForChild("Slash")),
		Slam = Humanoid:LoadAnimation(Animations:WaitForChild("Slam"))
	}
	Sounds.Burn:Play()
	Sounds.Unsheath:Play()
	
	if BurnEffect then BurnEffect:Disconnect();BurnEffect = nil end
	BurnEffect = Services.RunService.Heartbeat:Connect(function()
		if Debounce then return end
		Debounce = true
		--Redcliff rogue effect
		local Neg,Pos = Handle.CFrame.p - Vector3.new(1,1,1) * Properties.BurnRange, Handle.CFrame.p + Vector3.new(1,1,1) * Properties.BurnRange
		local Region = Region3.new(Neg,Pos)
		local Parts = workspace:FindPartsInRegion3WithIgnoreList(Region,{Character},math.huge)
		for _,part in pairs(Parts) do
			if part and part.Parent and (Handle.CFrame.p-part.CFrame.p).Magnitude <= Properties.BurnRange then
				local Hum,FF = part.Parent:FindFirstChildOfClass("Humanoid"),part.Parent:FindFirstChildOfClass("ForceField")
				if not FF and Hum and Hum.Health ~= 0 and not IsTeamMate(Player,Services.Players:GetPlayerFromCharacter(Hum.Parent)) then
					local BurnScript = script:WaitForChild("BurnScript")
					if not Hum.Parent:FindFirstChild(BurnScript.Name) then
						BurnScript = BurnScript:Clone()
						BurnScript:WaitForChild("ToolHandle").Value = Handle
						BurnScript:WaitForChild("Creator").Value = Player
						BurnScript.Parent = Hum.Parent
						BurnScript.Disabled = false
					end
				end
			end
		end
		wait(1/3)
		Debounce = false
	end)
end

function Unequipped()
	if BurnEffect then BurnEffect:Disconnect();BurnEffect = nil end
	for _,ani in pairs(Animations) do
		if ani then
			ani:Stop()
		end
	end
	Sounds.Burn:Stop()
end

local LastAttack = 0

function Attack()
	Tool.Grip = Grips.Up
	Sounds.Slash:Play()
	local Anim = Create("StringValue"){
		Name = "toolanim",
		Value = "Slash",
		Parent = Tool,
	}
	Tool.Grip = Grips.Up
end

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Root and Root.Parent and Player and Player.Parent) and true) or false)
end

function Blow(Part, Damage)
	local PartTouched
	PartTouched = Part.Touched:Connect(function(Hit)
		if not Hit or not Hit.Parent or not CheckIfAlive() then
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
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
		if not humanoid or humanoid.Health == 0 and torso then
			return
		end
		local player = Services.Players:GetPlayerFromCharacter(character)
		if player and (player == Player or IsTeamMate(Player, player)) then
			return
		end
		if torso and not torso:FindFirstChild(Components.FireParticle.Name) then
			local Fire = Components.FireParticle:Clone()
			Services.Debris:AddItem(Fire, 2.5)
			Fire.Parent = torso
			coroutine.wrap(function()
				local Duration = 2.25
				local StartTick = tick()
				while (tick() - StartTick) < 2.25 and Fire and Fire.Parent == torso do
					UntagHumanoid(humanoid)
					TagHumanoid(humanoid, Player)
					humanoid:TakeDamage(2.5)
					wait(0.25)
				end
			end)()
		end
		local HealthAfter = (humanoid.Health - Damage)
		UntagHumanoid(humanoid)
		TagHumanoid(humanoid, Player)
		humanoid:TakeDamage(Damage)
	end)
	return PartTouched
end

function Lunge()
	local Sucess,Target = pcall(function() return MouseLoc:InvokeClient(Player) end)
	Target = (Sucess and Target) or Vector3.new(0,0,0)
	
	local TargetPosition = Target
	local Direction = (CFrame.new(Root.Position, TargetPosition).lookVector * Vector3.new(1, 0, 1))
	Tool.Grip = Grips.Out
	Sounds.Lunge:Play()
	local Anim = Create("StringValue"){
		Name = "toolanim",
		Value = "Lunge",
		Parent = Tool,
	}
	if Direction.Magnitude > 0.01 then
		Direction = Direction.Unit 
		local NewBV = Create("BodyVelocity"){
			P = 100000,
			MaxForce = Vector3.new(math.huge, 0, math.huge),
			Velocity = (Direction * 100),
		}
		Services.Debris:AddItem(NewBV, 0.75)
		NewBV.Parent = Root
		Root.CFrame = CFrame.new(Root.Position, (TargetPosition * Vector3.new(1, 0, 1) + Vector3.new(0, Root.Position.Y, 0)))
	end
	local Lunging = true
	coroutine.wrap(function()
		local Ignore = {}
		repeat
			if not Humanoid or Humanoid.Health == 0 then break end
			local RayHit, RayPos, RayNormal = CastRay(Handle.Position, Vector3.new(0, -1, 0), (Root.Size.Y * 3), {Character,unpack(Ignore)}, false)
			if RayHit then
				local TrailPart = Create("Part"){
					Transparency = 1,
					CanCollide = false,
					Anchored = true,
					Locked = true,
					TopSurface = Enum.SurfaceType.Smooth,
					BottomSurface = Enum.SurfaceType.Smooth,
					Name = "Effect",
					Size = Vector3.new(1,5,1)
				}
				local Light = Create("PointLight"){
					Brightness = 10,
					Range = 5,
					Shadows = true,
					Enabled = true,
					Color = Color3.fromRGB(255, 85, 0),
					Parent = TrailPart
				}
				Ignore[#Ignore+1] = TrailPart
				local Fire = Components.FireParticle:Clone()
				Fire.Parent = TrailPart
				Fire.Enabled = true
				local ParticleScriptCopy = script:WaitForChild("ParticleScript"):Clone()
				local Duration = Create("NumberValue"){
					Name = "Duration",
					Value = 4,
					Parent = Fire,
				}
				ParticleScriptCopy.Disabled = false
				ParticleScriptCopy.Parent = Fire
				TrailPart.Touched:Connect(function(hit)
					if not hit or not hit.Parent then return end
					local Hum = hit.Parent:FindFirstChildOfClass("Humanoid")
					if not Hum or Hum.Health <= 0 or IsTeamMate(Player,Services.Players:GetPlayerFromCharacter(Hum.Parent)) or Hum == Humanoid then return end
					UntagHumanoid(Hum)
					TagHumanoid(Hum,Player)
					Hum:TakeDamage(5)
				local torso = Hum.Parent:FindFirstChild("Torso") or Hum.Parent:FindFirstChild("UpperTorso")
				if torso and not torso:FindFirstChild(Components.FireParticle.Name) then
					local Fire = Components.FireParticle:Clone()
					Services.Debris:AddItem(Fire, 2.5)
					Fire.Parent = torso
					coroutine.wrap(function()
						local Duration = 2.25
						local StartTick = tick()
						while (tick() - StartTick) < 2.25 and Fire and Fire.Parent == torso do
							UntagHumanoid(Hum)
							TagHumanoid(Hum, Player)
							Hum:TakeDamage(2.5)
							wait(0.25)
						end
					end)()
				end
				local HealthAfter = (Hum.Health - 5)
				UntagHumanoid(Hum)
				TagHumanoid(Hum, Player)
				Hum:TakeDamage(5)
						end)
						--Blow(TrailPart, 5)
						Services.Debris:AddItem(TrailPart, 5)
						TrailPart.CFrame = (CFrame.new(RayPos, (CFrame.new(RayPos) + RayNormal * (TrailPart.Size.Y * 2)).p) * CFrame.Angles(-(math.pi / 2), (math.random(-360, 360) * 0.01), 0))
						TrailPart.Parent =  workspace
					end
			Services.RunService.Heartbeat:Wait()
		until not Lunging
	end)()
--Insert trail creation here

	wait(0.75)
	Tool.Grip = Grips.Up
	wait(0.5)
	Lunging = false
end


function Activated()
	if not Tool.Enabled then return end
	
	Tool.Enabled = false 
	
	local Time = Services.RunService.Stepped:Wait()
	if (Time - LastAttack) < 0.2 then
		Lunge()
	else
		Attack()
	end
	LastAttack = Time
	Tool.Enabled = true
end

Tool.Equipped:Connect(Equipped)
Tool.Unequipped:Connect(Unequipped)
Tool.Activated:Connect(Activated)

function ChangeTime()
	local TelaTime = script:WaitForChild("TelaTime")
	local Found = Services.ServerScriptService:FindFirstChild(TelaTime.Name)
	if not Found then
		local Clone = TelaTime:Clone()
		Clone.Parent = Services.ServerScriptService
		Clone.Disabled = false
	end
end

local CanStun,CanUnwing = true,true
function Stun()
	if not CanStun then return end
	CanStun = false
	ChangeTime()
	Animations.Slam:Play(nil,nil,2)
	Sounds.Leap:Play()
	delay(1.1*.5,function()
		--warn("Explosion!")
		local CenterPart = Create("Part"){
			Transparency = 1,
			Name = "ChaosCenter",
			TopSurface = Enum.SurfaceType.Smooth,
			BottomSurface = Enum.SurfaceType.Smooth,
			Anchored = true,
			Locked = true,
			CanCollide = false,
			Size = Vector3.new(1,1,1)*0,
			CFrame = Root.CFrame*CFrame.new(0,-Root.Size.Y*1.5,0),
			Parent = workspace
		}
		local Light = Create("PointLight"){
			Brightness = 5,
			Range = 60,
			Enabled = true,
			Shadows = false,
			Color = Color3.fromRGB(255, 85, 0),
			Parent = CenterPart
		}
		local TelaChaos = script:WaitForChild("ChaosExplosion"):Clone()
		TelaChaos:WaitForChild("Creator").Value = Player
		TelaChaos.Parent = CenterPart
		TelaChaos.Disabled = false
		delay(.5,function()
			Tool.Grip = Grips.Up
		end)
		Tool.Grip = Grips.Up*CFrame.Angles(math.rad(50),0,0)
		local Neg,Pos = Root.CFrame.p - Vector3.new(1,1,1) * Properties.StunRange,Root.CFrame.p + Vector3.new(1,1,1) * Properties.StunRange
		local Region = Region3.new(Neg,Pos)
		local Parts = workspace:FindPartsInRegion3WithIgnoreList(Region,{Character},math.huge)
		local Characters = {}
		for _,parts in pairs(Parts) do
			if parts and parts.Parent then
				local Hum,FF = parts:FindFirstChildOfClass("Humanoid"),parts.Parent:FindFirstChildOfClass("ForceField")
				if not FF and Hum and Hum.Health ~= 0 and CheckIfAlive() and not IsTeamMate(Player,Services.Players:GetPlayerFromCharacter(Hum.Parent)) and not IsInTable(Characters,Hum.Parent) then
					Characters[#Characters+1] = Hum.Parent
					local ThornScript = script:WaitForChild("ThornScript"):Clone()
					ThornScript.Parent = Hum.Parent
					ThornScript.Disabled = false
				end
			end
		end
	end)

	delay(Properties.StunCooldown,function()
		CanStun = true
	end)
end

function Unwing()
	if not CanUnwing then return end
	CanUnwing = false
	ChangeTime()
	Animations.Darken:Play()
	Sounds.Fire:Play()
	local Neg,Pos = Handle.CFrame.p - Vector3.new(1,1,1) * Properties.UnwingRange, Handle.CFrame.p + Vector3.new(1,1,1) * Properties.UnwingRange
	local Region = Region3.new(Neg,Pos)
	local Parts = workspace:FindPartsInRegion3WithIgnoreList(Region,{Character},1000)
	local CapHumanoids = {}
	for _,parts in pairs(Parts) do
		if parts and parts.Parent and (parts.CFrame.p-Handle.CFrame.p).Magnitude <= Properties.UnwingRange then
			local Hum,FF = parts.Parent:FindFirstChildOfClass("Humanoid"),parts.Parent:FindFirstChildOfClass("ForceField")
			if not FF and Hum and Hum.Health ~= 0 and not IsInTable(CapHumanoids,Hum) then
				CapHumanoids[#CapHumanoids+1] = Hum
				local UnwingScript = script:WaitForChild("UnwingScript"):Clone()
				UnwingScript:WaitForChild("Creator").Value = Player
				UnwingScript:WaitForChild("ToolHandle").Value = Handle
				UnwingScript.Parent = Hum.Parent
				UnwingScript.Disabled = false
			end
		end
	end
	
	delay(Properties.UnwingCooldown,function()
		CanUnwing = true
	end)
end

Remote.OnServerEvent:Connect(function(player,Key)
	if player ~= Player or not Key or not Tool.Enabled then return end
	if Key == Enum.KeyCode.E then
		Unwing()
	elseif Key == Enum.KeyCode.Q then
		Stun()
	end
end)

Blow(Handle, Properties.SwordDamage)