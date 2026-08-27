--Rescripted by Luckymaxer
--Made by Stickmasterluke
 --edited by fusroblox

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

AmmoHud = script:WaitForChild("AmmoHud")
 
BaseUrl = "http://www.roblox.com/asset/?id="

Modules = Tool:WaitForChild("Modules")
Configuration = require(Modules:WaitForChild("Configuration"))
Objects = require(Modules:WaitForChild("Templates"))
Content = require(Modules:WaitForChild("Content"))
Functions = require(Modules:WaitForChild("Functions"))

Variables = {
	Ammo = Configuration.ClipSize,
	Equipped = false,
	MouseDown = false,
	Initalized = false,
	Reloading = false,
	Check = true,
	ReloadCounter = 0,
}

Animations = {
	Fire = {Animation = Tool:WaitForChild("Fire"), FadeTime = 0, Weight = 1, Speed = 3, Duration = nil},
	Reload = {Animation = Tool:WaitForChild("Reload"), FadeTime = 0, Weight = 1, Speed = 2, Duration = 3.5},
	Idle = {Animation = Tool:WaitForChild("Idle"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil},
}

Sounds = {
	Fire = Handle:WaitForChild("Fire"),
	Reload = Handle:WaitForChild("Reload")
}

Events = {}
GuiEvents = {}

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

Tool.Enabled = true

function CanFire()
	return (((Variables.MouseDown and Variables.Equipped and CheckIfAlive() and not Variables.Reloading and Variables.Check) and true) or false)
end

function Events:Fire()
	if not Variables.MouseDown or not CanFire() then
		return
	end
	while CanFire() do
		Variables.Check = false
		local StartPosition = (Handle.CFrame * Configuration.BarrelPosition).p
		local TargetPosition = InvokeClient("MousePosition").Position
		Spawn(function()
			InvokeClient("PlayAnimation", Animations.Fire)
			Events:SendBullet(StartPosition, TargetPosition, Configuration.Spread, Configuration.SegmentLength, Character, Configuration.Colors[1], Configuration.GunDamage, Configuration.FadeDelayTime)
		end)
		if not CanFire() then
			break
		else
			wait(Configuration.FireRate)
			Variables.Check = true
			if not Configuration.Automatic then
				break
			end
		end
	end
	if not Variables.Check then
		wait(Configuration.FireRate)
		Variables.Check = true
	end
end

function Events:Reload()
	Variables.Reloading = true
	Tool.Enabled = false
	Spawn(function()
		local RightArm = Character:FindFirstChild("Right Arm")
		RightGrip = nil
		if RightArm then
			RightGrip = RightArm:FindFirstChild("RightGrip")
			if RightGrip then
				RightGrip.Part1 = nil
				RightGrip.Parent = nil
			end
		end
		if ChestWeld and ChestWeld.Parent then
			ChestWeld:Destroy()
		end
		ChestWeld = Functions.WeldBetween(Torso, Handle)
		local Animation = Animations.Reload
		InvokeClient("PlayAnimation", Animations.Reload)
		wait(Animation.Duration)
		if ChestWeld and ChestWeld.Parent then
			ChestWeld:Destroy()
		end
		if RightGrip then
			RightGrip.Part1 = Handle
			RightGrip.Parent = RightArm
		end
	end)
	if Variables.Clips then
		if Variables.Clips > 0 then
			Variables.Clips = (Variables.Clips - 1)
			GuiEvents:UpdateGui()
		else
			Variables.Reloading = false
			Tool.Enabled = true
			return
		end
	end
	Sounds.Reload:Play()
	for i = 1, Configuration.ClipSize do
		wait(Configuration.ReloadTime / Configuration.ClipSize)
		Variables.Ammo = i
		GuiEvents:UpdateGui()
	end
	Variables.Reloading = false
	Tool.Enabled = true
end

function Events:SpawnShell()
	local shell = Objects.Shell:Clone()
	Debris:AddItem(shell, 2)
	shell.Parent = game:GetService("Workspace")
	shell.CFrame = Handle.CFrame
end

function TakeHit(character)
	if not character then
		return
	end
	local torso = character:FindFirstChild("Torso")
	if not torso then
		return
	end
	local tvel = Instance.new("BodyVelocity")
	tvel.maxForce = Vector3.new(999999, 0, 9999999)
	tvel.velocity = ((torso.CFrame.p - Torso.CFrame.p).unit * 100)
	Debris:AddItem(tvel, 0.5)
	tvel.Parent = torso
end

function Events:SendBullet(StartPosition, EndPosition, Spread, SegmentLength, Ignore, Color, Damage, FadeDelay)
	if Variables.Ammo <= 0 then
		return
	end
	Variables.Ammo = (Variables.Ammo - 1)
	GuiEvents:UpdateNumbers(tostring(Variables.Ammo), AmmoHudClone.Bar.AmmoLeft)
	Events:SpawnShell()
	Sounds.Fire.Pitch = ((math.random() * 0.5) + 0.75)
	Sounds.Fire:Play()
	local BulletDistance = Configuration.Range
	local ClickDistance = (StartPosition - EndPosition).magnitude
	local EndPosition = (EndPosition + (Vector3.new((math.random() - 0.5), (math.random() - 0.5), (math.random() - 0.5)) * (ClickDistance / 100)))
	local BulletVec = (EndPosition - StartPosition).unit
	local TotalSegments = math.ceil(BulletDistance / SegmentLength)
	local LastPosition = StartPosition
	for i = 1, TotalSegments do
		local NewPosition = (StartPosition + (BulletVec * (BulletDistance * (i / TotalSegments))))
		local SegVec = (NewPosition - LastPosition).unit
		local BulletLength = (NewPosition - LastPosition).magnitude
		local BulletHit, EndPosition = Functions.CastRay(LastPosition, SegVec, BulletLength, Ignore, false)
		DrawBeam(LastPosition, EndPosition, Color, FadeDelay, Objects.Bullet)
		if BulletHit then
			local character = BulletHit.Parent
			if character:IsA("Hat") then
				character = character.Parent
			end
			if character == Character then
				return
			end
			local player = Players:GetPlayerFromCharacter(character)
			if player and Functions.IsTeamMate(Player, player) then
				return
			end
			local humanoid = character:FindFirstChild("Humanoid")
			if humanoid and humanoid.Health > 0 then
				Functions.UntagHumanoid(humanoid)
				Functions.TagHumanoid(humanoid, Player)
				TakeHit(character)
				humanoid:TakeDamage(Damage)
				if character:FindFirstChild("BlockShot") then
					
				end
			else
				Spawn(function()
					Events:HitEffect(EndPosition, BrickColor.new("Medium stone grey"), 5)
				end)
			end
			break
		end
		LastPosition = EndPosition
		wait(Configuration.Rate)
	end
	if Variables.Ammo < 1 then
		Events:Reload()
	end
end

function Events:MakeSpark(Position, Color)
	local EffectTime = 0.5
	local Effect = Objects.SparkEffect:Clone()
	Effect.BrickColor = Color
	local EffectVel = Instance.new("BodyVelocity")
	EffectVel.maxForce = Vector3.new(99999, 99999, 99999)
	EffectVel.velocity = Vector3.new((math.random() * 15 * Functions.SigNum(math.random(-10, 10))), (math.random() * 15 * Functions.SigNum(math.random(-10, 10))), (math.random() * 15 * Functions.SigNum(math.random(-10, 10))))
	EffectVel.Parent = Effect
	Effect.Size = Vector3.new((math.abs(EffectVel.velocity.x) / 30), (math.abs(EffectVel.velocity.y) / 30), (math.abs(EffectVel.velocity.z) / 30))
	Debris:AddItem(EffectVel, wait())
	Debris:AddItem(Effect, EffectTime * 2)
	Effect.Parent = game:GetService("Workspace")
	Effect.CFrame = CFrame.new(Position)
	local StartTime = time()
	while time() - StartTime < EffectTime do
		if Effect ~= nil then
			Effect.Transparency = ((time() - StartTime) / EffectTime)
		end
		wait()
	end
	if Effect and Effect.Parent then
		Effect:Destroy()
	end
end

function Events:HitEffect(Position, Color, NumberOfSparks)
	for i = 1, NumberOfSparks, 1 do
		Spawn(function()
			Events:MakeSpark(Position, Color)
		end)
	end
end

function DrawBeam(BeamStart, BeamEnd, Color, FadeDelay, TemplatePart)
	local Distance = 2 --(BeamStart - BeamEnd).magnitude
	local Laser = TemplatePart:Clone()
	Laser.BrickColor = Color
	Laser.Size = Vector3.new(0.1, 0.1, (Distance + 0.2))
	Debris:AddItem(Laser, FadeDelay)
	Laser.Parent = game:GetService("Workspace")
	Laser.CFrame = CFrame.new(((BeamEnd + BeamStart) / 2), BeamStart) * CFrame.new(0, 0, -(Distance / 2))
end

function GuiEvents.LoadGui(Player)
	if not Player then
		return
	end
	local PlayerGui = Player:FindFirstChild("PlayerGui")
	if not PlayerGui then
		return
	end
	AmmoHudClone = AmmoHud:Clone()
	AmmoHudClone.Parent = PlayerGui
	GuiEvents:UpdateNumbers(tostring(Variables.Ammo), AmmoHudClone.Bar.AmmoLeft)
end

function GuiEvents:UpdateGui()
	if not AmmoHudClone or not AmmoHudClone.Parent then
		return
	end
	GuiEvents:UpdateNumbers(tostring(Variables.Ammo), AmmoHudClone.Bar.AmmoLeft)
end

function GuiEvents:UpdateNumbers(Data, Frame)
	if not AmmoHudClone or not AmmoHudClone.Parent then
		return
	end
	local DataLength = string.len(Data)
	Data = ((((DataLength == 0 or DataLength == 1) and "0") or "") .. Data)
	local Frame1 = Frame:FindFirstChild("1")
	local Frame2 = Frame:FindFirstChild("2")
	if not Frame1 or not Frame2 then
		return
	end
	local Digit1 = Frame1:FindFirstChild("Digit")
	local Digit2 = Frame2:FindFirstChild("Digit")
	if not Digit1 or not Digit2 then
		return
	end
	for i, v in pairs({Digit1, Digit2}) do
		local StringPortion = ((v == Digit1 and string.sub(Data, 1, 1)) or (string.sub(Data, 2, 2)))
		local NumberImage = Content.NumberImages[tonumber(StringPortion)]
		if v.Image ~= (BaseUrl .. NumberImage) then
			local NewDigit = v:Clone()
			NewDigit.Position = UDim2.new(NewDigit.Position.X.Scale, NewDigit.Position.X.Offset, NewDigit.Position.Y.Scale, (NewDigit.Position.Y.Offset - 65))
			NewDigit.Image = (BaseUrl .. NumberImage)
			NewDigit.Parent = v.Parent
			if v == Digit1 then
				NewDigit:TweenPosition(v.Position, "Out", "Quad", 0.1)
			else
				NewDigit:TweenPosition(UDim2.new(v.Position.X.Scale, v.Position.X.Offset, v.Position.Y.Scale, 0), "Out", "Quad", .25)
			end
			v.Name = "OldDigit"
			v:TweenPosition(UDim2.new(v.Position.X.Scale, v.Position.X.Offset, v.Position.Y.Scale, (v.Position.Y.Offset + 65)), "Out", "Quad", 0.25)
			Debris:AddItem(v, 1)
		end
	end
end

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent and Player and Player.Parent) and true) or false)
end

function Equipped()
	Character = Tool.Parent
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso")
	Player = Players:GetPlayerFromCharacter(Character)
	if not CheckIfAlive() then
		return
	end
	Spawn(function()
		InvokeClient("PlayAnimation", Animations.Idle)
	end)
	Spawn(function()
		GuiEvents.LoadGui(Player)
	end)
	Variables.Equipped = true
end

function Unequipped()
	Variables.Equipped = false
	Variables.MouseDown = false
	RightGrip = nil
	for i, v in pairs(Sounds) do
		if v and v.Parent then
			v:Stop()
		end
	end
	for i, v in pairs({AmmoHudClone, ChestWeld}) do
		if v and v.Parent then
			v:Destroy()
		end
	end
end

function OnServerInvoke(player, mode, value)
	if player == Player and Variables.Equipped and value and CheckIfAlive() then
		if mode == "MouseClick" then
			local Down = value.Down
			Variables.MouseDown = Down
			if Variables.MouseDown then
				Events:Fire()
			end
		elseif mode == "KeyPress" then
			local Key = value.Key
			local ByteKey = string.byte(Key)
			local Down = value.Key
			if Key == "r" and Down then
				if Variables.Equipped and not Variables.MouseDown and not Variables.Reloading and CheckIfAlive() then
					Events:Reload()
				end
			end
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

ServerControl.OnServerInvoke = OnServerInvoke
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)