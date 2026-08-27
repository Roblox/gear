--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

local function Create_PrivImpl(objectType)
	if type(objectType) ~= 'string' then
		error("Argument of Create must be a string", 2)
	end
	--return the proxy function that gives us the nice Create'string'{data} syntax
	--The first function call is a function call using Lua's single-string-argument syntax
	--The second function call is using Lua's single-table-argument syntax
	--Both can be chained together for the nice effect.
	return function(dat)
		--default to nothing, to handle the no argument given case
		dat = dat or {}

		--make the object to mutate
		local obj = Instance.new(objectType)
		local parent = nil

		--stored constructor function to be called after other initialization
		local ctor = nil

		for k, v in pairs(dat) do
			--add property
			if type(k) == 'string' then
				if k == 'Parent' then
					-- Parent should always be set last, setting the Parent of a new object
					-- immediately makes performance worse for all subsequent property updates.
					parent = v
				else
					obj[k] = v
				end


			--add child
			elseif type(k) == 'number' then
				if type(v) ~= 'userdata' then
					error("Bad entry in Create body: Numeric keys must be paired with children, got a: "..type(v), 2)
				end
				v.Parent = obj


			--event connect
			elseif type(k) == 'table' and k.__eventname then
				if type(v) ~= 'function' then
					error("Bad entry in Create body: Key `[Create.E\'"..k.__eventname.."\']` must have a function value\
							got: "..tostring(v), 2)
				end
				obj[k.__eventname]:connect(v)


			--define constructor function
			elseif k == t.Create then
				if type(v) ~= 'function' then
					error("Bad entry in Create body: Key `[Create]` should be paired with a constructor function, \
							got: "..tostring(v), 2)
				elseif ctor then
					--ctor already exists, only one allowed
					error("Bad entry in Create body: Only one constructor function is allowed", 2)
				end
				ctor = v


			else
				error("Bad entry ("..tostring(k).." => "..tostring(v)..") in Create body", 2)
			end
		end

		--apply constructor function if it exists
		if ctor then
			ctor(obj)
		end

		if parent then
			obj.Parent = parent
		end

		--return the completed object
		return obj
	end
end

--now, create the functor:
Create = setmetatable({}, {__call = function(tb, ...) return Create_PrivImpl(...) end})

--and create the "Event.E" syntax stub. Really it's just a stub to construct a table which our Create
--function can recognize as special.
Create.E = function(eventName)
	return {__eventname = eventName}
end


BaseUrl = "http://www.roblox.com/asset/?id="

Functions = require(script:WaitForChild("Functions"))

Damage = {
	Touch = {Min = 1, Max = 1},
	Slash = {Min = 12, Max = 17},
	DoubleSlash = {Min = 22, Max = 26},
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

AnimationsBin = Tool:WaitForChild("Animations")
R6Anims = AnimationsBin:WaitForChild("R6")
R15Anims = AnimationsBin:WaitForChild("R15")

Animations = {
	R6Equip = {Animation = R6Anims:WaitForChild("Equip"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil},
	R6LeftSlash = {Animation = R6Anims:WaitForChild("LeftSlash"), FadeTime = 0.125, Weight = nil, Speed = 2, Duration = 0.35},
	R6RightSlash = {Animation = R6Anims:WaitForChild("RightSlash"), FadeTime = 0.125, Weight = nil, Speed = 2, Duration = 0.35},
	R6InwardSlash = {Animation = R6Anims:WaitForChild("InwardSlash"), FadeTime = nil, Weight = 1, Speed = 3, Duration = 0.35},
	R6OutwardSlash = {Animation = R6Anims:WaitForChild("OutwardSlash"), FadeTime = 0.1, Weight = 1, Speed = 2, Duration = 0.35},
	R6Spin = {Animation = R6Anims:WaitForChild("Spin"), FadeTime = 0.1, Weight = 1, Speed = 2, Duration = 0.5},
	R15Equip = {Animation = R15Anims:WaitForChild("Equip"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil},
	R15LeftSlash = {Animation = R15Anims:WaitForChild("LeftSlash"), FadeTime = 0.125, Weight = nil, Speed = 2, Duration = 0.35},
	R15RightSlash = {Animation = R15Anims:WaitForChild("RightSlash"), FadeTime = 0.125, Weight = nil, Speed = 2, Duration = 0.35},
	R15InwardSlash = {Animation = R15Anims:WaitForChild("InwardSlash"), FadeTime = nil, Weight = 1, Speed = 3, Duration = 0.35},
	R15OutwardSlash = {Animation = R15Anims:WaitForChild("OutwardSlash"), FadeTime = 0.1, Weight = 1, Speed = 2, Duration = 0.35},
	R15Spin = {Animation = R15Anims:WaitForChild("Spin"), FadeTime = 0.1, Weight = 1, Speed = 2, Duration = 0.5},

}

Sounds = {
	Unsheath = Handle:WaitForChild("Unsheath"),
	Slash = Handle:WaitForChild("Slash"),
}

TouchDamage = {Min = 0, Max = 0}

FirstClick = false
Clicks = 0

Gravity = 196.20
Rate = (1 / 60)

AttackEnabled = true
ToolEquipped = false

Remotes = (Tool:FindFirstChild("Remotes") or Create("Folder"){
	Name = "Remotes",
	Parent = Tool,
})
ServerControl = (Remotes:FindFirstChild("Server") or Create("RemoteFunction"){
	Name = "Server",
	Parent = Remotes,
})

ClientControl = (Remotes:FindFirstChild("Client") or Create("RemoteFunction"){
	Name = "Client",
	Parent = Remotes,
})

for i, v in pairs(Tool:GetChildren()) do
	if v:IsA("BasePart") and v ~= Handle then
		v:Destroy()
	end
end

Handle.Transparency = 0
Tool.Enabled = true

function DisplayBillboardText(Pos, Text, Time, Color)
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

function Blow(Part)
	local Debounce = false
	local TouchedConnection = Part.Touched:connect(function(Hit)
		if not Hit or not Hit.Parent or not CheckIfAlive() or Debounce then
			return
		end
		local character = Hit.Parent
		local player = Players:GetPlayerFromCharacter(character)
		if player and (Player == player or Functions.IsTeamMate(Player, player)) then
			return
		end
		local humanoid = character:FindFirstChild("Humanoid")
		if not humanoid or humanoid.Health == 0 then
			return
		end
		Debounce = true
		Functions.UntagHumanoid(humanoid)
		Functions.TagHumanoid(humanoid, Player)		
		local DamageValue = Damage.Touch
		if CurrentAnimation then
			DamageValue = ((Clicks >= 2 and Damage.DoubleSlash) or Damage.Slash)
		end
		local FinalizedDamage = math.random(DamageValue.Min, DamageValue.Max)
		local Radius = Vector3.new(1.25, 0.25, 1.25)
		Radius = (Radius * 100)
		local Offset = Vector3.new(math.random(-Radius.X, Radius.X), math.random(-Radius.Y, Radius.Y), math.random(-Radius.Z, Radius.Z))
		Offset = Offset * Vector3.new(0.01, 0.01, 0.01)
		DisplayBillboardText((Handle.Position + Offset + Vector3.new(0, 2.5, 0)), FinalizedDamage, 2, BrickColor.new("Really red").Color)
		humanoid:TakeDamage(FinalizedDamage)
		if humanoid.Health <= 0 then
		end
		wait(0.1)
		Debounce = false
	end)
	return TouchedConnection
end

function Attack(PossibleAnims)
	if not CheckIfAlive() or not ToolEquipped then
		return
	end
	if PossibleAnims and #PossibleAnims > 0 then
		local CurrentlyEquipped = true
		if ToolUnequipped1 then
			ToolUnequipped1:disconnect()
		end
		ToolUnequipped1 = Tool.Unequipped:connect(function()
			CurrentlyEquipped = false
			if ToolUnequipped1 then
				ToolUnequipped1:disconnect()
			end
		end)
		local Animation = PossibleAnims[math.random(1, #PossibleAnims)]
		CurrentAnimation = Animation.Animation
		local AttackAnimation = CurrentAnimation
		Spawn(function()
			InvokeClient("PlayAnimation", CurrentAnimation)
		end)
		AttackAnimation.Start = tick()
		Spawn(function()
			for i, v in pairs(Animation.Sounds) do
				if not CurrentlyEquipped then
					break
				end
				if v.Delay > 0 then
					wait(v.Delay)
				end
				if not CurrentlyEquipped then
					break
				end
				v.Sound:Play()
			end
			if ToolUnequipped1 then
				ToolUnequipped1:disconnect()
			end
		end)
		if AttackAnimation.Duration and AttackAnimation.Duration > 0 then
			wait(AttackAnimation.Duration)
			AttackAnimation.Start = nil
			Spawn(function()
				InvokeClient("StopAnimation", AttackAnimation)
			end)
			CurrentAnimation = nil
		end
	end
end

function CreateDualWield()
	if FakeHandle and FakeHandle.Parent then
		FakeHandle:Destroy()
	end
	local LeftArm = (Character:FindFirstChild("Left Arm") or Character:FindFirstChild("LeftHand"))
	if LeftArm then
		FakeHandle = Handle:Clone()
		FakeHandle.Name = "FakeHandle"
		local LeftGrip = Create("Weld"){
			Part0 = LeftArm,
			Part1 = FakeHandle,
			C0 = ((Humanoid.RigType == Enum.HumanoidRigType.R15 and CFrame.new(0.125, -0.175, 0, 1, 0, -0, 0, 0, 1, 0, -1, -0)) or CFrame.new(0, -1, 0, 1, 0, -0, 0, 0, 1, 0, -1, -0)),
			C1 = Tool.Grip,
			Parent = FakeHandle,
		}
		Blow(FakeHandle)
		FakeHandle.Parent = Tool
	end
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
		wait(0.2)
		if ToolUnequipped then
			ToolUnequipped:disconnect()
		end
		if not CurrentlyEquipped then
			return
		end
		Tool.Enabled = false
		if Clicks == 1 then
			local AttackAnims = {
				{Animation = Animations.R6LeftSlash, Sounds = {{Delay = 0, Sound = Sounds.Slash}}},
				{Animation = Animations.R6RightSlash, Sounds = {{Delay = 0, Sound = Sounds.Slash}}},
			}
			if Humanoid.RigType == Enum.HumanoidRigType.R15 then
				AttackAnims = {
					{Animation = Animations.R15LeftSlash, Sounds = {{Delay = 0, Sound = Sounds.Slash}}},
					{Animation = Animations.R15RightSlash, Sounds = {{Delay = 0, Sound = Sounds.Slash}}},
				}
			end
			Attack(AttackAnims)
		elseif Clicks > 1 then
			local PossibleAnimations = {Animations.R6InwardSlash, Animations.R6OutwardSlash, Animations.R6Spin}
			if Humanoid.RigType == Enum.HumanoidRigType.R15 then
				PossibleAnimations = {Animations.R15InwardSlash, Animations.R15OutwardSlash, Animations.R15Spin}
			end
			for i, v in pairs(PossibleAnimations) do
				local Animation = v
				Animation.Weight = (math.random(750, 1000) * 0.001)
				Animation.Speed = (math.random(1250, 2000) * 0.001)
				Animation.Duration = (1 / Animation.Speed)
			end
			local Animation = PossibleAnimations[math.random(1, #PossibleAnimations)]
			local AttackAnims = {
				{Animation = Animation, Sounds = {{Delay = 0, Sound = Sounds.Slash}}}
			}
			Attack(AttackAnims)
		end
		FirstClick = false
		Clicks = 0
		Tool.Enabled = true
	end
end

function CheckIfAlive()
	return (((Player and Player.Parent and Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and RootPart and RootPart.Parent) and true) or false)
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	RootPart = Character:FindFirstChild("HumanoidRootPart")
	if not CheckIfAlive() then
		return
	end
	Sounds.Unsheath:Play()
	Spawn(function()
		CreateDualWield()
		Spawn(function()
			InvokeClient("PlayAnimation", ((Humanoid.RigType == Enum.HumanoidRigType.R15 and Animations.R15Equip) or Animations.R6Equip))
		end)
	end)
	ToolEquipped = true
end

function Unequipped()
	Clicks = 0
	FirstClick = false
	for i, v in pairs({FakeHandle, ToolUnequipped}) do
		if v then
			if tostring(v) == "Connection" then
				v:disconnect()
			elseif type(v) == "userdata" and v.Parent then
				v:Destroy()
			end
		end
	end
	for i, v in pairs(Sounds) do
		if v and v.Parent then
			v:Stop()
		end
	end
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
	if player ~= Player or not ToolEquipped or not CheckIfAlive() or not Mode or not Value then
		return
	end
end)

Blow(Handle)

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)