--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")
RunService = game:GetService("RunService")
UserInputService = game:GetService("UserInputService")

AmmoDisplay = script:WaitForChild("AmmoDisplay"):Clone()
CastLaser = Tool:WaitForChild("CastLaser"):Clone()

Camera = game:GetService("Workspace").CurrentCamera

BaseUrl = "http://www.roblox.com/asset/?id="

AnimationTracks = {}
LocalObjects = {}

Animations = {
	Hold = {Animation = Tool:WaitForChild("Hold"), FadeTime = nil, Weight = nil, Speed = 1, Duration = 2},
	Fire = {Animation = Tool:WaitForChild("Fire"), FadeTime = 0.25, Weight = nil, Speed = 0.5, Duration = 0.5},
	Reload = {Animation = Tool:WaitForChild("Reload"), FadeTime = nil, Weight = nil, Speed = 1, Duration = 2},
}

Sounds = {
	Reload = Handle:WaitForChild("Reload"),
	NoAmmo = Handle:WaitForChild("NoAmmo"),
}

Modules = Tool:WaitForChild("Modules")
Functions = require(Modules:WaitForChild("Functions"))

Remotes = Tool:WaitForChild("Remotes")
ServerControl = Remotes:WaitForChild("ServerControl")
ClientControl = Remotes:WaitForChild("ClientControl")

ConfigurationBin = Tool:WaitForChild("Configuration")
Configuration = {}
Configuration = Functions.CreateConfiguration(ConfigurationBin, Configuration)

InputCheck = Instance.new("ScreenGui")
InputCheck.Name = "InputCheck"
InputButton = Instance.new("ImageButton")
InputButton.Name = "InputButton"
InputButton.Image = ""
InputButton.BackgroundTransparency = 1
InputButton.ImageTransparency = 1
InputButton.Size = UDim2.new(1, 0, 1, 0)
InputButton.Parent = InputCheck

Cursors = {
	Normal = (BaseUrl .. "170908665"),
	EnemyHit = (BaseUrl .. "172618259"),
}

Rate = (1 / 60)

FiringOffset = Vector3.new(0, ((Handle.Size.Y / 4) - 0.2), -(Handle.Size.Z / 2))

Reloading = false
MouseDown = false
ToolEquipped = false

Tool.Enabled = true

function SetAnimation(mode, value)
	if mode == "PlayAnimation" and value and ToolEquipped and Humanoid then
		for i, v in pairs(AnimationTracks) do
			if v.Animation == value.Animation then
				v.AnimationTrack:Stop()
				table.remove(AnimationTracks, i)
			end
		end
		local AnimationTrack = Humanoid:LoadAnimation(value.Animation)
		table.insert(AnimationTracks, {Animation = value.Animation, AnimationTrack = AnimationTrack})
		AnimationTrack:Play(value.FadeTime, value.Weight, value.Speed)
	elseif mode == "StopAnimation" and value then
		for i, v in pairs(AnimationTracks) do
			if v.Animation == value.Animation then
				v.AnimationTrack:Stop(value.FadeTime)
				table.remove(AnimationTracks, i)
			end
		end
	end
end

function ToggleGui()
	if not AmmoDisplayClone or not AmmoDisplayClone.Parent then
		return
	end
	local Frame = AmmoDisplayClone.Frame
	local Ammo = Frame.Ammo
	if Configuration.Ammo.ClipSize.MaxValue > 0 then
		Ammo.AmmoCounter.CounterPart.Text = Configuration.Ammo.ClipSize.Value
	end
	Ammo.MagCounter.CounterPart.Text = Configuration.Ammo.Magazines.Value
end

function Reload()
	if Reloading or not Tool.Enabled or Configuration.Ammo.Magazines.Value >= Configuration.Ammo.Magazines.MaxValue then
		return
	end
	Tool.Enabled = false
	Reloading = true
	ToggleGui()
	local CanReload = true
	if Configuration.Ammo.ClipSize.MaxValue > 0 and Configuration.Ammo.ClipSize.Value <= 0 then
		CanReload = false
	else
		CanReload = true
	end
	if CanReload then
		Spawn(function()
			local Animation = Animations.Reload
			OnClientInvoke("PlayAnimation", Animation)
			wait(Animation.Duration)
			OnClientInvoke("StopAnimation", Animation)
		end)
		Sounds.Reload:Play()
		local AddedClips = ((Configuration.Ammo.Magazines.MaxValue > 0 and (Configuration.Ammo.Magazines.MaxValue - Configuration.Ammo.Magazines.Value)) or Configuration.Ammo.ClipSize.MaxValue)
		if Configuration.Ammo.ClipSize.MaxValue > 0 then
			AddedClips = ((AddedClips > Configuration.Ammo.ClipSize.Value and Configuration.Ammo.ClipSize.Value) or AddedClips)
		end
		--[[local ReloadRate = (Configuration.ReloadTime.Value / Configuration.Ammo.Magazines.MaxValue)
		for i = 1, AddedClips do
			wait(ReloadTime)
			Configuration.Ammo.Magazines.Value = (Configuration.Ammo.Magazines.Value + 1)
		end]]
		wait(Configuration.ReloadTime.Value)
		Configuration.Ammo.Magazines.Value = (Configuration.Ammo.Magazines.Value + AddedClips)
		Configuration.Ammo.ClipSize.Value = (Configuration.Ammo.ClipSize.Value - AddedClips)
		Sounds.Reload:Stop()
		ToggleGui()
	end
	Reloading = false
	Tool.Enabled = true
end

function RayTouched(Hit, Position)
	if not Hit or not Hit.Parent then
		return
	end
	local character = Hit.Parent
	if character:IsA("Hat") then
		character = character.Parent
	end
	if character == Character then
		return
	end
	local humanoid = character:FindFirstChild("Humanoid")
	local SoundChosen = Sounds.RayHit
	if not humanoid or humanoid.Health == 0 then
		return
	end
	local player = Players:GetPlayerFromCharacter(character)
	if player and Functions.IsTeamMate(Player, player) then
		return
	end
	Spawn(function()
		IconChangeTick = tick()
		PlayerMouse.Icon = Cursors.EnemyHit
		wait(1)
		if (tick() - IconChangeTick) >= 0.95 and ToolEquipped and PlayerMouse then
			PlayerMouse.Icon = Cursors.Normal
		end
	end)
end

function FireRay(StartPosition, TargetPosition)
	local Direction = CFrame.new(StartPosition, TargetPosition).lookVector
	local RayHit, RayPos, RayNormal = Functions.CastRay(StartPosition, Direction, Configuration.Range.Value, {Character}, false)
	local Backpack = Player:FindFirstChild("Backpack")
	if Backpack then
		local LaserScript = CastLaser:Clone()
		local StartPos = Instance.new("Vector3Value")
		StartPos.Name = "StartPosition"
		StartPos.Value = StartPosition
		StartPos.Parent = LaserScript
		local TargetPos = Instance.new("Vector3Value")
		TargetPos.Name = "TargetPosition"
		TargetPos.Value = RayPos
		TargetPos.Parent = LaserScript
		local RayHit = Instance.new("BoolValue")
		RayHit.Name = "RayHit"
		RayHit.Value = RayHit
		RayHit.Parent = LaserScript
		LaserScript.Disabled = false
		LaserScript.Parent = Backpack
	end
	Spawn(function()
		InvokeServer("CastLaser", {StartPosition = StartPosition, TargetPosition = RayPos, RayHit = ((RayHit and true) or false)})
	end)
	Spawn(function()
		InvokeServer("RayHit", {Hit = RayHit, Position = RayPos})
	end)
	RayTouched(RayHit, RayPos)
end

function Button1Pressed(Down)
	if not Down and MouseDown then
		MouseDown = false
	end
end

function KeyPress(Key, Down)
	if Key == "r" and Down then
		Reload()
	end
end

function Activated()
	if not Tool.Enabled or not ToolEquipped or Reloading then
		return
	end
	Tool.Enabled = false
	if Configuration.Ammo.Magazines.Value > 0 then
		local FirstShot = false
		if Configuration.Automatic.Value then
			MouseDown = true
		end
		OnClientInvoke("StopAnimation", {Animation = Animations.Fire.Animation, FadeTime = nil})
		OnClientInvoke("PlayAnimation", Animations.Fire)
		while MouseDown or not FirstShot and ToolEquipped and CheckIfAlive() do
			if Configuration.Ammo.Magazines.Value <= 0 or not ToolEquipped or not CheckIfAlive() then
				break
			end
			if not FirstShot then
				FirstShot = true
			end
			local BurstAmount = math.random(Configuration.Burst.Bullets.MinValue, Configuration.Burst.Bullets.MaxValue)
			local WithinFiringRange = false
			Spawn(function()
				InvokeServer("Fire", true)
			end)
			for i = 1, ((BurstAmount > 0 and BurstAmount) or 1) do
				local TargetPosition = OnClientInvoke("MousePosition")
				if not TargetPosition then
					break
				end
				TargetPosition = TargetPosition.Position
				local StartPosition = (Handle.CFrame * CFrame.new(FiringOffset.X, FiringOffset.Y, FiringOffset.Z)).p
				if BurstAmount > 0 then
					local Offset = (Configuration.Burst.Offset.Value * 100)
					TargetPosition = TargetPosition + Vector3.new((math.random(-Offset.X, Offset.X) * 0.01), (math.random(-Offset.Y, Offset.Y) * 0.01), (math.random(-Offset.Z, Offset.Z) * 0.01))
				end
				local Accuracy = (Configuration.Accuracy.Value * 100)
				TargetPosition = TargetPosition + Vector3.new((math.random(-Accuracy.X, Accuracy.X) * 0.01), (math.random(-Accuracy.Y, Accuracy.Y) * 0.01), (math.random(-Accuracy.Z, Accuracy.Z) * 0.01))
				Configuration.Ammo.Magazines.Value = (Configuration.Ammo.Magazines.Value - 1)
				FireRay(StartPosition, TargetPosition)
			end
			ToggleGui()
			wait(Configuration.FireRate.Value)
		end
		OnClientInvoke("StopAnimation", {Animation = Animations.Fire.Animation, FadeTime = 0.25})
	else
		Tool.Enabled = true
		Sounds.NoAmmo:Play()
		Reload()
	end
	MouseDown = false
	Tool.Enabled = true
	if Configuration.Ammo.Magazines.Value <= 0 then
		Sounds.NoAmmo:Play()
		Reload()
	end
end

function CheckIfAlive()
	return (((Player and Player.Parent and Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0) and true) or false)
end

function Equipped(Mouse)
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	if not CheckIfAlive() then
		return
	end
	ToolEquipped = true
	Spawn(function()
		PlayerMouse = Player:GetMouse()
		Mouse.Button1Down:connect(function()
			Button1Pressed(true)
		end)
		Mouse.Button1Up:connect(function()
			Button1Pressed(false)
		end)
		Mouse.KeyDown:connect(function(Key)
			KeyPress(Key, true)
		end)
		Mouse.KeyUp:connect(function(Key)
			KeyPress(Key, false)
		end)
		Humanoid.CameraOffset = Vector3.new(0, 0.35, 0)
		OnClientInvoke("PlayAnimation", Animations.Hold)
		local PlayerGui = Player:FindFirstChild("PlayerGui")
		if PlayerGui then
			if UserInputService.TouchEnabled then
				InputCheckClone = InputCheck:Clone()
				InputCheckClone.InputButton.InputBegan:connect(function()
					InvokeServer("Button1Click", {Down = true})
				end)
				InputCheckClone.InputButton.InputEnded:connect(function()
					InvokeServer("Button1Click", {Down = false})
				end)
				InputCheckClone.Parent = PlayerGui
			end
			local function AdjustAmmoDisplay()
				local Frame = AmmoDisplayClone.Frame
				Frame.CurrentWeapon.Text = Configuration.ToolName.Value
				local Ammo = Frame.Ammo
				Ammo.AmmoCounter.CounterPart.Text = ((Configuration.Ammo.ClipSize.MaxValue > 0 and Configuration.Ammo.ClipSize.Value) or "--")
				Ammo.MagCounter.CounterPart.Text = Configuration.Ammo.Magazines.Value
			end
			AmmoDisplayClone = AmmoDisplay:Clone()
			AdjustAmmoDisplay()
			AmmoDisplayClone.Parent = PlayerGui
			ToggleGui()
			for i, v in pairs({ClipSizeChanged, MagazinesChanged}) do
				if v then
					v:disconnect()
				end
			end
			ClipSizeChanged = Configuration.Ammo.ClipSize.Changed:connect(function()
				AdjustAmmoDisplay()
			end)
			MagazinesChanged = Configuration.Ammo.Magazines.Changed:connect(function()
				AdjustAmmoDisplay()
			end)
		end
		for i, v in pairs({"Left Arm", "Right Arm"}) do
			local Arm = Character:FindFirstChild(v)
			if Arm then
				Spawn(function()
					OnClientInvoke("SetLocalTransparencyModifier", {Object = Arm, Transparency = 0, AutoUpdate = false})
				end)
			end
		end
		Mouse.Icon = Cursors.Normal
	end)
end

function Unequipped()
	LocalObjects = {}
	if CheckIfAlive() then
		Humanoid.CameraOffset = Vector3.new(0, 0, 0)
	end
	for i, v in pairs(Sounds) do
		v:Stop()
	end
	if PlayerMouse then
		PlayerMouse.Icon = ""
	end
	for i, v in pairs({InputCheckClone, ObjectLocalTransparencyModifier, AmmoDisplayClone, ClipSizeChanged, MagazinesChanged}) do
		if tostring(v) == "Connection" then
			v:disconnect()
		elseif v and v.Parent then
			v:Destroy()
		end
	end
	MouseDown = false
	for i, v in pairs(AnimationTracks) do
		if v and v.AnimationTrack then
			v.AnimationTrack:Stop()
		end
	end
	AnimationTracks = {}
	ToolEquipped = false
end

function InvokeServer(mode, value)
	pcall(function()
		local ServerReturn = ServerControl:InvokeServer(mode, value)
		return ServerReturn
	end)
end

function OnClientInvoke(mode, value)
	if mode == "PlayAnimation" and value and ToolEquipped and Humanoid then
		SetAnimation("PlayAnimation", value)
	elseif mode == "StopAnimation" and value then
		SetAnimation("StopAnimation", value)
	elseif mode == "PlaySound" and value then
		value:Play()
	elseif mode == "StopSound" and value then
		value:Stop()
	elseif mode == "MousePosition" then
		return {Position = PlayerMouse.Hit.p, Target = PlayerMouse.Target}
	elseif mode == "SetLocalTransparencyModifier" and value and ToolEquipped then
		pcall(function()
			local ObjectFound = false
			for i, v in pairs(LocalObjects) do
				if v == value then
					ObjectFound = true
				end
			end
			if not ObjectFound then
				table.insert(LocalObjects, value)
				if ObjectLocalTransparencyModifier then
					ObjectLocalTransparencyModifier:disconnect()
				end
				ObjectLocalTransparencyModifier = RunService.RenderStepped:connect(function()
					for i, v in pairs(LocalObjects) do
						if v.Object and v.Object.Parent then
							local CurrentTransparency = v.Object.LocalTransparencyModifier
							if ((not v.AutoUpdate and (CurrentTransparency == 1 or  CurrentTransparency == 0)) or v.AutoUpdate) then
								v.Object.LocalTransparencyModifier = v.Transparency
							end
						else
							table.remove(LocalObjects, i)
						end
					end
				end)
			end
		end)
	end
end

ClientControl.OnClientInvoke = OnClientInvoke

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)