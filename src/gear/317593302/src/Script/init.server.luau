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
HieroglyphicsModule = require(Tool:WaitForChild("Hieroglyphics"))

FreezeScript = script:WaitForChild("FreezeScript")

Gravity = 196.20

Rate = (1 / 60)

Damage = {
	Touch = {Min = 3.5, Max = 6},
	Hit = {Min = 14, Max = 17},
}

Grips = {
	Normal = CFrame.new(0, 0, 1.4, 1, 0, 0, -0, 0, 1, 0, -1, 0),
}

BasePart = Create("Part"){
	Material = Enum.Material.Plastic,
	Shape = Enum.PartType.Block,
	TopSurface = Enum.SurfaceType.Smooth,
	BottomSurface = Enum.SurfaceType.Smooth,
	FormFactor = Enum.FormFactor.Custom,
	Size = Vector3.new(0.2, 0.2, 0.2),
	CanCollide = true,
	Locked = true,
}

Animations = {
	LeftSlash = {Animation = Tool:WaitForChild("LeftSlash"), FadeTime = nil, Weight = nil, Speed = nil, Duration = 0.5},
	RightSlash = {Animation = Tool:WaitForChild("RightSlash"), FadeTime = nil, Weight = nil, Speed = nil, Duration = 0.5},
	LeftSwingFast = {Animation = Tool:WaitForChild("LeftSwingFast"), FadeTime = nil, Weight = nil, Speed = nil, Duration = 0.5},
	RightSwingFast = {Animation = Tool:WaitForChild("RightSwingFast"), FadeTime = nil, Weight = nil, Speed = nil, Duration = 0.5},
	OverHeadSwing = {Animation = Tool:WaitForChild("OverHeadSwing"), FadeTime = nil, Weight = nil, Speed = nil, Duration = 0.5},
}

Sounds = {
	Unsheath = Handle:WaitForChild("Unsheath"),
	Slash = Handle:WaitForChild("Slash"),
}

Special = {
	Enabled = true,
	Active = false,
	Duration = (60 * 1),
	ReloadTime = (60 * 1),
}

RageMode = false
ReloadReady = true
ToolEquipped = false

ServerControl = (Tool:FindFirstChild("ServerControl") or Create("RemoteFunction"){
	Name = "ServerControl",
	Parent = Tool,
})

ClientControl = (Tool:FindFirstChild("ClientControl") or Create("RemoteFunction"){
	Name = "ClientControl",
	Parent = Tool,
})

Handle.Transparency = 0
Tool.Grip = Grips.Normal
Tool.Enabled = true

function GetNearbyObjects(Region, Ignore)
	local IgnoreList = (Ignore or {})
	table.insert(IgnoreList, ((Player and Player.Character) or nil))
	for i, v in pairs(Players:GetChildren()) do
		if v:IsA("Player") and v ~= Player and v.Character and v.Character.Parent and Functions.IsTeamMate(Player, v) then
			table.insert(IgnoreList, v.Character)
		end
	end
	return Functions.GetParts(Region, 250, IgnoreList)
end

function UseTechnique(Use, Renew)
	if (not CurrentTechnique or not CurrentTechnique.Technique) and Renew and ReloadReady then
		Spawn(CreateHieroglyphics)
	elseif CurrentTechnique and CurrentTechnique.Technique then
		ReloadReady = false
		CurrentTechnique.Technique = nil
		if Use then
			if CurrentTechnique.Gui and CurrentTechnique.Gui.Frame.Parent then
				Spawn(function()
					local Gui = CurrentTechnique.Gui.Gui
					local Frame = CurrentTechnique.Gui.Frame
					local FadeRate = 0.05
					local FadeAmount = 15
					for i = 1, FadeAmount do
						if not Gui or not Gui.Parent or not Frame or not Frame.Parent then
							break
						end
						Frame.ImageTransparency = ((1 / FadeAmount) * i)
						wait(FadeRate)
					end
					if CurrentTechnique.Gui.Gui.Parent then
						CurrentTechnique.Gui.Gui:Destroy()
					end
				end)
			end
		end
		wait(8)
		ReloadReady = true
		if not ToolEquipped or not CheckIfAlive() then
			return
		end
		Spawn(CreateHieroglyphics)
	else
	end
end

function CreateHieroglyphics()
	if not CheckIfAlive() or not PlayerGui then
		return
	end
	local HieroglyphicsImages = {}
	for i, v in pairs(HieroglyphicsModule) do
		table.insert(HieroglyphicsImages, v)
	end
	local HieroglyphicCount = #HieroglyphicsImages
	local Hieroglyphics = {}
	local Circle = 360
	local HieroglyphicsReady = false
	local HieroglyphicChosen
	HieroglyphicGui = Create("ScreenGui"){
		Name = "HieroglyphicGui",
	}
	local Frame = Create("Frame"){
		Name = "Frame",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0.5, -125, 0.5, -125),
		Size = UDim2.new(0, 250, 0, 250),
		Rotation = 0,
		Parent = HieroglyphicGui,
	}
	for i, v in pairs(PlayerGui:GetChildren()) do
		if v:IsA("GuiBase") and v.Name == HieroglyphicGui.Name then
			v:Destroy()
		end
	end
	Spawn(function()
		for i = 1, HieroglyphicCount do
			local Angle = ((Circle / HieroglyphicCount) * i)
			local Size = 50
			local RadiusX = (math.sin(math.rad(Angle)) * 0.5)
			local RadiusY = (math.cos(math.rad(Angle)) * 0.5)
			local HieroglyphicNumber = math.random(1, #HieroglyphicsImages)
			local Hieroglyphic = HieroglyphicsImages[HieroglyphicNumber]
			table.remove(HieroglyphicsImages, HieroglyphicNumber)	
			local Image = Create("ImageLabel"){
				BackgroundTransparency = 1,
				Image = (BaseUrl .. Hieroglyphic),
				Rotation = -Frame.Rotation,
				ImageTransparency = 1,
				Position = UDim2.new((0.5 + RadiusX), (-Size / 2), (0.5 + RadiusY), (-Size / 2)),
				Size = UDim2.new(0, Size, 0, Size),
				Parent = Frame,
			}
			table.insert(Hieroglyphics, {Id = Hieroglyphic, Image = Image})
			Spawn(function()
				local FadeRate = 0.05
				local FadeAmount = 25
				for i = 1, FadeAmount do
					if not HieroglyphicGui or not HieroglyphicGui.Parent then
						return
					end
					Image.ImageTransparency = (1 - ((1 / FadeAmount) * i))
					wait(FadeRate)
				end
			end)
			wait(0.5)
		end
		wait(5)
		if not HieroglyphicGui or not HieroglyphicGui.Parent then
			return
		end
		HieroglyphicsReady = true
	end)
	Spawn(function()
		while not HieroglyphicChosen do
			if not HieroglyphicGui or not HieroglyphicGui.Parent then
				return
			end
			if HieroglyphicsReady then
				HieroglyphicsReady = false
				Spawn(function()
					local DesiredHieroglyphic = Hieroglyphics[math.random(1, #Hieroglyphics)]
					local FadeRate = 0.05
					local FadeAmount = 25
					for i = 1, FadeAmount do
						if not HieroglyphicGui or not HieroglyphicGui.Parent then
							return
						end
						local Transparency = ((1 / FadeAmount) * i)
						for ii, v in pairs(Hieroglyphics) do
							if v.Image ~= DesiredHieroglyphic.Image then
								v.Image.ImageTransparency = Transparency		
							end
						end
						wait(FadeRate)
					end
					local ResizeComplete, MoveComplete = false, false
					local function TransitionComplete()
						if not ResizeComplete or not MoveComplete then
							return
						end
						CurrentTechnique = {Start = tick(), Technique = DesiredHieroglyphic.Id, Gui = {Gui = HieroglyphicGui, Frame = DesiredHieroglyphic.Image}}
					end
					if not HieroglyphicGui or not HieroglyphicGui.Parent then
						return
					end
					HieroglyphicChosen = DesiredHieroglyphic.Image
					local DesiredSize = (Vector2.new(HieroglyphicChosen.Size.X.Offset, HieroglyphicChosen.Size.Y.Offset) * 3)
					HieroglyphicChosen:TweenSizeAndPosition(
						UDim2.new(0, DesiredSize.X, 0, DesiredSize.Y),
						UDim2.new(0.5, -(DesiredSize.X / 2), 0.5, -(DesiredSize.Y / 2)),
						Enum.EasingDirection.InOut,
						Enum.EasingStyle.Linear,
						1,
						true,
						(function()
							wait(1.5)
							if not HieroglyphicGui or not HieroglyphicGui.Parent then
								return
							end
							local DesiredSize = (Vector2.new(HieroglyphicChosen.Size.X.Offset, HieroglyphicChosen.Size.Y.Offset) / 2)
							Frame.Rotation = 45
							HieroglyphicChosen.Rotation = -Frame.Rotation
							HieroglyphicChosen:TweenSizeAndPosition(
								UDim2.new(0, DesiredSize.X, 0, DesiredSize.Y),
								UDim2.new(0, 0, 0, 0),
								Enum.EasingDirection.InOut,
								Enum.EasingStyle.Linear,
								1,
								true,
								(function()
									ResizeComplete = true
									TransitionComplete()
								end)
							)
							Frame:TweenPosition(
								UDim2.new(0, -75, 0, 40),
								Enum.EasingDirection.InOut,
								Enum.EasingStyle.Linear,
								1,
								true,
								(function()
									MoveComplete = true
									TransitionComplete()
								end)
							)
						end)
					)
				end)
			end
			local RotationRate = 2
			Frame.Rotation = (Frame.Rotation + RotationRate)
			if Frame.Rotation >= 360 then
				Frame.Rotation = 0
			end
			for i, v in pairs(Hieroglyphics) do
				v.Image.Rotation = (v.Image.Rotation - RotationRate)
			end
			wait()
		end
	end)
	HieroglyphicGui.Parent = PlayerGui
end

function SwingSword(SpinTime)
	Spawn(function()
		local StartSpin = tick()
		local EndSpin = (StartSpin + SpinTime)
		while tick() < EndSpin do
			Tool.Grip = (Grips.Normal * CFrame.Angles(math.pi * 2 * ((tick() - StartSpin) / SpinTime), 0, 0))
			wait()
		end
		Tool.Grip = Grips.Normal
	end)
end

function Swing(PossibleAnims)
	if not CheckIfAlive() or not ToolEquipped then
		return
	end
	if PossibleAnims and #PossibleAnims > 0 then
		local Animation = PossibleAnims[math.random(1, #PossibleAnims)]
		CurrentAnimation = Animation
		local AttackAnimation = CurrentAnimation
		if CurrentAnimation == Animations.LeftSlashFast or CurrentAnimation == Animations.RightSlashFast or CurrentAnimation == Animations.OverHeadSwing then
			--SwingSword(0.5)
		end
		Spawn(function()
			InvokeClient("PlayAnimation", CurrentAnimation)
		end)
		wait(Animation.Duration)
		CurrentAnimation = nil
	end
end

function Blow(Hit)
	if not Hit or not Hit.Parent or not CheckIfAlive() or not ToolEquipped then
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
	local torso = character:FindFirstChild("Torso")
	if not humanoid or humanoid.Health == 0 or not torso then
		return
	end
	local player = Players:GetPlayerFromCharacter(character)
	if player and (player == Player or Functions.IsTeamMate(Player, player)) then
		return
	end
	local PossibleDamage = ((CurrentAnimation and Damage.Hit) or Damage.Touch)
	local DamageValue = math.random(PossibleDamage.Min, PossibleDamage.Max)
	DamageValue = ((RageMode and (DamageValue * 1.25)) or DamageValue)
	Functions.UntagHumanoid(humanoid)
	Functions.TagHumanoid(humanoid, Player)
	humanoid:TakeDamage(DamageValue)
	if CurrentAnimation and CurrentTechnique then
		if CurrentTechnique.Technique == 316614873 and humanoid.Health <= 0 then
			Spawn(function()
				UseTechnique(true, false)
			end)
			for i, v in pairs(character:GetChildren()) do
				if v:IsA("BasePart") then
					v:Destroy()
				end
			end
			local AshColors = {"Pastel brown", "Light orange", "Burlap", "Fawn brown", "Cork", "Reddish brown", "Bronze"}
			for i = 1, math.random(35, 50) do
				local Ashes = BasePart:Clone()
				Ashes.Name = "Ashes"
				Ashes.BrickColor = BrickColor.new(AshColors[math.random(1, #AshColors)])
				Ashes.Material = Enum.Material.Sand
				for i, v in pairs({"Top", "Bottom", "Front", "Back", "Left", "Right"}) do
					Ashes[(v .. "Surface")] = Enum.SurfaceType.SmoothNoOutlines
				end
				Ashes.Size = Vector3.new((math.random(200, 250) * 0.001), (math.random(200, 250) * 0.001), (math.random(200, 250) * 0.001))
				Ashes.CFrame = (CFrame.new(torso.Position) * CFrame.new((math.random(-2000, 2000) * 0.001), (math.random(-2000, 2000) * 0.001), (math.random(-2000, 2000) * 0.001)) * CFrame.Angles(0, (math.random(-360, 360) * 0.01), 0))
				Debris:AddItem(Ashes, (14 + (i * 0.1)))
				Ashes.Parent = game:GetService("Workspace")
			end
		elseif CurrentTechnique.Technique == 316615073 then
			Spawn(function()
				UseTechnique(true, false)
			end)
			local FreezeScriptCopy = character:FindFirstChild(FreezeScript.Name)
			if not FreezeScriptCopy then
				FreezeScriptCopy = FreezeScript:Clone()
				local Duration = Create("NumberValue"){
					Name = "Duration",
					Parent = FreezeScriptCopy,
				}
			end
			local Duration = FreezeScriptCopy:FindFirstChild("Duration")
			if Duration then
				Duration.Value = 6
			end
			FreezeScriptCopy.Disabled = false
			FreezeScriptCopy.Parent = character
		elseif CurrentTechnique.Technique == 316615216 then
			Spawn(function()
				UseTechnique(true, false)
			end)
			Functions.UntagHumanoid(humanoid)
			Functions.TagHumanoid(humanoid, Player)
			humanoid:TakeDamage(60)
		end
	end
end

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent and Player and Player.Parent) and true) or false)
end

function Attack()
	Sounds.Slash:Play()
	local AttackAnims = {Animations.LeftSlash, Animations.RightSlash, Animations.LeftSwingFast, Animations.RightSwingFast, Animations.OverHeadSwing}
	Swing(AttackAnims)
end

function Activated()
	if not Tool.Enabled or not ToolEquipped or not CheckIfAlive() or Special.Active then
		return
	end
	Tool.Enabled = false
	if CurrentTechnique and CurrentTechnique.Technique then
		if CurrentTechnique.Technique == 316615118 or CurrentTechnique.Technique == 316614985 or CurrentTechnique.Technique == 316614299 then
			Spawn(function()
				UseTechnique(true, false)
			end)
			RageMode = true
			Humanoid.WalkSpeed = (16 * 2)
			Humanoid.JumpPower = 60
			local CurrentlyEquipped = true
			local WalkSpeedChanged = false
			for i, v in pairs({ToolUnequipped, WalkSpeedChangedCheck}) do
				if v then
					v:disconnect()
				end
			end
			ToolUnequipped = Tool.Unequipped:connect(function()
				CurrentlyEquipped = false
			end)
			WalkSpeedChangedCheck = Humanoid.Changed:connect(function(Property)
				if Property == "WalkSpeed" then
					WalkSpeedChanged = true
				end
			end)
			Delay(15, (function()
				RageMode = false
				if not WalkSpeedChanged and CurrentlyEquipped and ToolEquipped and CheckIfAlive() then
					Humanoid.WalkSpeed = 16
					Humanoid.JumpPower = 50
				end
			end))
		elseif CurrentTechnique.Technique == 316615142 then
			Spawn(function()
				UseTechnique(true, false)
			end)
			local PlayersAvailable = {}
			for i, v in pairs(Players:GetChildren()) do
				if v:IsA("Player") and v.Character and v.Character.Parent then
					local character = v.Character
					local torso = character:FindFirstChild("Torso")
					if torso then
						table.insert(PlayersAvailable, {Player = v, Character = character, Torso = torso})
					end
				end
			end
			if #PlayersAvailable > 0 then
				local RandomPlayer = PlayersAvailable[math.random(1, #PlayersAvailable)]
				local YourPosition = Torso.CFrame
				local EnemyPosition = RandomPlayer.Torso.CFrame
				Torso.CFrame = EnemyPosition
				RandomPlayer.Torso.CFrame = YourPosition
			end
		elseif CurrentTechnique.Technique == 316615173 or CurrentTechnique.Technique == 316614843 or CurrentTechnique.Technique == 316614325 then
			Spawn(function()
				UseTechnique(true, false)
			end)
			--Does nothing!
		elseif CurrentTechnique.Technique == 316614921 then
			Spawn(function()
				UseTechnique(true, false)
			end)
			if CheckIfAlive() then
				Humanoid.Health = Humanoid.MaxHealth
			end
		elseif CurrentTechnique.Technique == 316615031 then
			Spawn(function()
				UseTechnique(true, false)
			end)
			local Radius = 20
			local Region = Region3.new((Torso.Position - Vector3.new(Radius, Radius, Radius)), (Torso.Position + Vector3.new(Radius, Radius, Radius)))
			local Parts = GetNearbyObjects(Region, {})
			local Humanoids = {}
			for i, v in pairs(Parts) do
				local character = v.Parent
				local humanoid = character:FindFirstChild("Humanoid")
				if humanoid and humanoid.Health > 0 and not Functions.CheckTableForInstance(Humanoids, humanoid) then
					table.insert(Humanoids, humanoid)
					local creator = character:FindFirstChild("Creator")
					if (not creator or (creator and creator.Value ~= Player)) then
						Functions.UntagHumanoid(humanoid)
						Functions.TagHumanoid(humanoid, Player)
						humanoid:TakeDamage(25)
						humanoid.Sit = true
					end
				end
			end
		elseif CurrentTechnique.Technique == 316615002 then
			Spawn(function()
				UseTechnique(true, false)
			end)
			local Radius = 30
			local Region = Region3.new((Torso.Position - Vector3.new(Radius, Radius, Radius)), (Torso.Position + Vector3.new(Radius, Radius, Radius)))
			local Parts = GetNearbyObjects(Region, {})
			for i, v in pairs(Parts) do
				local character = v.Parent
				local humanoid = character:FindFirstChild("Humanoid")
				local player = Players:GetPlayerFromCharacter(character)
				if humanoid and humanoid.Health > 0 and player then
					local playergui = player:FindFirstChild("PlayerGui")
					if playergui then
						for i, v in pairs(playergui:GetChildren()) do
							if v:IsA("ScreenGui") and v.Name == "BlackOutGui" then
								v:Destroy()
							end
						end
						local BlackOutGui = Create("ScreenGui"){
							Name = "BlackOutGui",
							Create("Frame"){
								Name = "Frame",
								Size = UDim2.new(3, 0, 3, 0),
								Position = UDim2.new(-1.5, 0, -1.5, 0),
								BorderSizePixel = 0,
								BackgroundColor3 = Color3.new(0, 0, 0),
								Active = false,
							}
						}
						Debris:AddItem(BlackOutGui, 8)
						BlackOutGui.Parent = playergui
					end
				end
			end
		end
	end
	Attack()
	Tool.Enabled = true
end

function Equipped(Mouse)
	Character = Tool.Parent
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso")
	Player = Players:GetPlayerFromCharacter(Character)
	if not CheckIfAlive() then
		return
	end
	PlayerGui = Player:FindFirstChild("PlayerGui")
	Spawn(function()
		UseTechnique(false, true)
	end)
	Sounds.Unsheath:Play()
	ToolEquipped = true
end

function Unequipped()
	if CheckIfAlive() then
		Humanoid.WalkSpeed = 16
		Humanoid.JumpPower = 50
	end
	if HieroglyphicGui and HieroglyphicGui.Parent then
		HieroglyphicGui:Destroy()
	end
	RageMode = false
	ToolEquipped = false
end

function OnServerInvoke(player, mode, value)
	if player ~= Player or not ToolEquipped or not value or not CheckIfAlive() then
		return
	end
	if mode == "KeyPress" then
		local Key = value.Key
		local Down = value.Down
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

Handle.Touched:connect(Blow)

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)

CreateHieroglyphics()