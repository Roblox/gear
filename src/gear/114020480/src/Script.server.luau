--Rescripted by Luckymaxer
--Made by Stickmasterluke

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")
InsertService = game:GetService("InsertService")

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

MaxRange = 100
Rate = (1 / 30)
Hairs = {13476917, 13745548, 14815761, 65941351}
Hats = {53039427, 1032641, 41453145, 51244458, 1031418, 53040003, 69434580, 10770304}
Costume = {	
	{Name = "Princess Torso", BodyPart = Enum.BodyPart.Torso, BaseTextureId = 0, MeshId = 54069300, OverlayTextureId = 54069610},
	{Name = "Princess Left Arm", BodyPart = Enum.BodyPart.LeftArm, BaseTextureId = 0, MeshId = 54069504, OverlayTextureId = 54069610},
	{Name = "Princess Right Arm", BodyPart = Enum.BodyPart.RightArm, BaseTextureId = 0, MeshId = 54069400, OverlayTextureId = 54069610},
	{Name = "Princess Left Leg", BodyPart = Enum.BodyPart.LeftLeg, BaseTextureId = 0, MeshId = -1, OverlayTextureId = 54069610},
	{Name = "Princess Right Leg", BodyPart = Enum.BodyPart.RightLeg, BaseTextureId = 0, MeshId = -1, OverlayTextureId = 54069610},
}

Animations = {
	Wave = {Animation = Tool:WaitForChild("Wave"), FadeTime = nil, Weight = nil, Speed = 1},
}

Sounds = {
	Fire = Handle:WaitForChild("Fire"),
}

BasePart = Create("Part"){
	Material = Enum.Material.Plastic,
	Shape = Enum.PartType.Block,
	FormFactor = Enum.FormFactor.Custom,
	TopSurface = Enum.SurfaceType.Smooth,
	BottomSurface = Enum.SurfaceType.Smooth,
	Size = Vector3.new(0.2, 0.2, 0.2),
	Anchored = false,
	CanCollide = true,
	Locked = true,
}

Snowball = Handle:Clone()
Snowball.Transparency = 0

Velocity = 50

Magic = BasePart:Clone()
Magic.Name = "Effect"
Magic.Transparency = 1
Magic.CanCollide = false
Magic.Anchored = true
Create("Sparkles"){
	SparkleColor = Color3.new((144 / 255), (25 / 255), (255 / 255)),
	Enabled = true,
	Parent = Magic,
}

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

Loaded = true
ToolEquipped = false

Handle.Transparency = 0
Tool.Enabled = true

function InsertAsset(AssetId)
	local AssetModel = InsertService:LoadAsset(AssetId)
	local Asset = AssetModel:GetChildren()[1]:Clone()
	Debris:AddItem(AssetModel, 1)
	return Asset
end


function Princessize(character)
	local Princessized = Create("StringValue"){
		Name = "Princessized",
		Parent = character,
	}
	local Hair = InsertAsset(Hairs[math.random(1, #Hairs)])
	local Hat = InsertAsset(Hats[math.random(1, #Hats)])
	local BodyParts = {}
	for i, v in pairs(Costume) do
		local CharacterMesh = Create("CharacterMesh"){
			Name = v.Name,
			BodyPart = v.BodyPart,
			MeshId = v.MeshId,
			BaseTextureId = v.BaseTextureId,
			OverlayTextureId = v.OverlayTextureId,
			Parent = character
		}
	end
	for i, v in pairs({Hair, Hair}) do
		v.Parent = character
	end
end

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Player and Player.Parent) and true) or false)
end

function Fire(targetPart, heat, size, clr1, clr2)
	local NewFire = Create("Fire"){
		Heat = heat,
		Size = size,
		Color = clr1,
		SecondaryColor = clr2,
		Parent = targetPart,
	}
	return NewFire
end

function Activated()
	local MouseData = InvokeClient("MouseData")
	if not MouseData or not MouseData.Position or not MouseData.Target or not ToolEquipped or not CheckIfAlive() or not Tool.Enabled then
		return
	end
	local character = MouseData.Target.Parent
	if character:IsA("Hat") or character:IsA("Accoutrement") or character:IsA("Tool") then
		character = character.Parent
	end
	if character:FindFirstChild("Princessized") then
		return
	end
	local humanoid = character:FindFirstChild("Humanoid")
	local torso = character:FindFirstChild("Torso")
	if not humanoid or humanoid.Health == 0 or not torso then
		return
	end
	local OriginalDistance = (Handle.Position - torso.Position).Magnitude
	if OriginalDistance > MaxRange then
		return
	end
	Tool.Enabled = false
	Spawn(function()
		InvokeClient("PlayAnimation", Animations.Wave)
	end)
	Sounds.Fire:Play()
	local MagicCopy = Magic:Clone()
	Debris:AddItem(MagicCopy, 10)
	MagicCopy.CFrame = (Handle.CFrame * CFrame.new(0, 2, 0))
	MagicCopy.Parent = game:GetService("Workspace")
	local Frames = (1 / Rate)
	for Frame = 1, Frames do
		local Vec = (MagicCopy.Position - torso.Position).Unit
		MagicCopy.CFrame = CFrame.new(torso.Position + Vec * ((1 - (Frame / Frames)) * OriginalDistance))
		wait(Rate)
	end
	if MagicCopy and MagicCopy.Parent then
		MagicCopy:Destroy()
	end
	local Fires = {
		Fire(torso, 10, 15, Color3.new(1, (1 / 3), 1), Color3.new(1, (2 / 3), 1)),
		Fire(torso, 0, 20, Color3.new(1, 1, 1), Color3.new(1, (2 / 3), 1)),
		Fire(torso, -10, 15, Color3.new(1, (1 / 3), 1), Color3.new(1, (2 / 3), 1)),
	}
	for i, v in pairs(Fires) do
		Debris:AddItem(v, 5)
	end
	wait(1)
	for i, v in pairs(character:GetChildren()) do
		if v:IsA("CharacterMesh") or v:IsA("ShirtGraphic") or v:IsA("Hat") or v:IsA("Accoutrement") or v:IsA("Clothing") then
			v:Destroy()
		end
	end
	for i, v in pairs(torso:GetChildren()) do
		if v:IsA("Decal") then
			v:Destroy()
		end
	end
	Princessize(character)
	wait(1.5)
	for i, v in pairs(Fires) do
		v.Enabled = false
	end
	wait(3)
	Tool.Enabled = true
end

function Equipped()
	Character = Tool.Parent
	Humanoid = Character:FindFirstChild("Humanoid")
	Player = Players:GetPlayerFromCharacter(Character)
	if not CheckIfAlive() then
		return
	end
	ToolEquipped = true
end

function Unequipped()
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
end

ServerControl.OnServerInvoke = OnServerInvoke

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)