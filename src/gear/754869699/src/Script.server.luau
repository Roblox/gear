--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")
RunService = game:GetService("RunService")

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


DamageValues = {
	BaseDamage = 0,
	SlashDamage = 12,
}

Damage = DamageValues.BaseDamage

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

Rate = (1 / 60)

AnimationsBin = Tool:WaitForChild("Animations")
R6Anims = AnimationsBin:WaitForChild("R6")
R15Anims = AnimationsBin:WaitForChild("R15")

Animations = {
	R6Slash1 = {Animation = R6Anims:WaitForChild("Slash1"), FadeTime = nil, Weight = nil, Speed = 1.25, Duration = 0.5},
	R6Slash2 = {Animation = R6Anims:WaitForChild("Slash2"), FadeTime = nil, Weight = nil, Speed = 1.5, Duration = 0.5},
	R15Slash1 = {Animation = R15Anims:WaitForChild("Slash1"), FadeTime = nil, Weight = nil, Speed = 1.25, Duration = 0.5},
	R15Slash2 = {Animation = R15Anims:WaitForChild("Slash2"), FadeTime = nil, Weight = nil, Speed = 1.5, Duration = 0.5},
}

Sounds = {
	Unsheath = Handle:WaitForChild("Unsheath"),
	Slash = Handle:WaitForChild("Slash"),
}
ToolEquipped = false

Remotes = (Tool:FindFirstChild("Remotes") or Create("Folder"){
	Name = "Remotes",
	Parent = Tool,
})
ServerControl = (Remotes:FindFirstChild("ServerControl") or Create("RemoteFunction"){
	Name = "ServerControl",
	Parent = Remotes,
})
ClientControl = (Remotes:FindFirstChild("ClientControl") or Create("RemoteFunction"){
	Name = "ClientControl",
	Parent = Remotes,
})

Handle.Transparency = 0
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

function CheckTableForInstance(Table, Instance)
	for i, v in pairs(Table) do
		if v == Instance then
			return true
		end
	end
	return false
end

function DealDamage(character, damage)
	if not CheckIfAlive() or not character then
		return
	end
	local damage = (damage or 0)
	local humanoid = character:FindFirstChild("Humanoid")
	local rootpart = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso")
	if not humanoid or humanoid.Health == 0 or not rootpart then
		return
	end
	UntagHumanoid(humanoid)
	TagHumanoid(humanoid, Player)
	humanoid:TakeDamage(damage)
end

function GetAllConnectedParts(Object)
	local Parts = {}
	local function GetConnectedParts(Object)
		for i, v in pairs(Object:GetConnectedParts()) do
			local Ignore = false
			for ii, vv in pairs(Parts) do
				if v == vv then
					Ignore = true
				end
			end
			if not Ignore then
				table.insert(Parts, v)
				GetConnectedParts(v)
			end
		end
	end
	GetConnectedParts(Object)
	return Parts
end

function WeldTogether(Parent, PrimaryPart)
	local Parts = {}
	local function WeldModel(Parent, PrimaryPart)
		for i, v in pairs(Parent:GetChildren()) do
			if v:IsA("BasePart") and v ~= PrimaryPart then
				local Weld = Instance.new("Weld")
				Weld.Name = "Weld"
				Weld.Part0 = PrimaryPart
				Weld.Part1 = v
				Weld.C0 = PrimaryPart.CFrame:inverse()
				Weld.C1 = v.CFrame:inverse()
				Weld.Parent = v
				table.insert(Parts, v)
			end
			WeldModel(v, PrimaryPart)
		end
	end
	WeldModel(Parent, PrimaryPart)
	return Parts
end

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0) and true) or false)
end

function Blow(Part)
	local PartTouched
	local HitDelay = false
	PartTouched = Part.Touched:connect(function(Hit)
		if not Hit or not Hit.Parent or not CheckIfAlive() or not ToolEquipped or HitDelay then
			return
		end
		local RightArm = (Character:FindFirstChild("Right Arm") or Character:FindFirstChild("RightHand"))
		if not RightArm then
			return
		end
		local RightGrip = RightArm:FindFirstChild("RightGrip")
		if not RightGrip or (RightGrip.Part0 ~= Handle and RightGrip.Part1 ~= Handle) then
			return
		end
		local character = Hit.Parent
		local ToolHit = nil
		if character:IsA("Tool") then
			ToolHit = character
			character = character.Parent
		end
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
		local BreakChance = math.random()
		if ToolHit and BreakChance <= 0.4 and CurrentAnimation then
			local rarm = (character:FindFirstChild("Right Arm") or character:FindFirstChild("RightHand"))
			if not rarm then
				return
			end
			local rgrip = rarm:FindFirstChild("RightGrip")
			if rgrip then
				humanoid:UnequipTools()
				local handle = ToolHit:FindFirstChild("Handle")
				if handle then
					local HandlePos = handle.CFrame
					local ToolClone = ToolHit:Clone()
					local ToolCloneHandle = ToolClone:FindFirstChild("Handle")
					if ToolCloneHandle then
						local FakeTool = Instance.new("Model")
						FakeTool.Name = "FakeTool"
						local FakeHandle = nil
						for i, v in pairs(GetAllConnectedParts(ToolCloneHandle)) do
							local FakePart = v:Clone()
							if v == ToolCloneHandle then
								FakeHandle = FakePart
							end
							FakePart.Name = "Effect"
							FakePart.CanCollide = false
							FakePart.Parent = FakeTool
						end
						if FakeHandle then
							WeldTogether(FakeTool, FakeHandle)
							FakeHandle.CFrame = HandlePos
							Debris:AddItem(FakeTool, 3)
							FakeTool.Parent = game:GetService("Workspace")
							FakeHandle.Velocity = ((CFrame.new(Handle.Position, (FakeHandle.Position + Vector3.new(0, math.random(-3, 10), 0))) * CFrame.Angles(math.rad(math.random(-90, 180)), math.rad(math.random(-90, 180)), 0)).lookVector * math.random(75, 150))
						end
					end
				end
			end
			ToolHit:Destroy()
		end
		HitDelay = true
		local TotalDamage = Damage
		DealDamage(character, TotalDamage)
		local Now = tick()
		wait(0.05)
		HitDelay = false
	end)
end

function Attack()
	Damage = DamageValues.SlashDamage
	Sounds.Slash:Play()
	--[[local Anim = Create("StringValue"){
		Name = "toolanim",
		Value = "Slash",
	}
	Debris:AddItem(Anim, 2)
	Anim.Parent = Tool]]
	local SwingAnimations = ((Humanoid.RigType == Enum.HumanoidRigType.R6 and {Animations.R6Slash1, Animations.R6Slash2})
	or (Humanoid.RigType == Enum.HumanoidRigType.R15 and {Animations.R15Slash1, Animations.R15Slash2}))
	local Animation = SwingAnimations[math.random(1, #SwingAnimations)]
	CurrentAnimation = Animation
	Spawn(function()
		InvokeClient("PlayAnimation", Animation)
	end)
	wait(Animation.Duration)
	CurrentAnimation = nil
end

function Activated()
	if not Tool.Enabled or not ToolEquipped or not CheckIfAlive() then
		return
	end
	Tool.Enabled = false
	Attack()
	Damage = DamageValues.BaseDamage
	Tool.Enabled = true
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
	ToolEquipped = true
end

function Unequipped()
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

ServerControl.OnServerInvoke = OnServerInvoke

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)

Blow(Handle)