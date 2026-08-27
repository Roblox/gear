--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")
InsertService = game:GetService("InsertService")

Clothing = {
	Hats = {111514535, 179416832},
	BodyParts = {111514593, 111514642, 111514706, 111514785, 111517826},
}

ExplodeScript = script:WaitForChild("ExplodeScript")

NPCModule = require(191816425)

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

Gravity = 196.20

Rate = (1 / 60)

Damage = {
	Touch = {Min = 5, Max = 8},
	Hit = {Min = 16, Max = 20},
}

Grips = {
	Normal = CFrame.new(0, -2, 0.125, 1, 0, 0, 0, 1, -0, -0, 0, 1),
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
	Summon = {Animation = Tool:WaitForChild("Summon"), FadeTime = nil, Weight = nil, Speed = 1.5, Duration = 3},
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

Particles = {}

Lunging = false
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
			SwingSword(0.5)
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
	if not humanoid or humanoid.Health == 0 then
		return
	end
	local player = Players:GetPlayerFromCharacter(character)
	if player and (player == Player or IsTeamMate(Player, player)) then
		return
	end
	local PossibleDamage = ((CurrentAnimation and Damage.Hit) or Damage.Touch)
	local DamageValue = math.random(PossibleDamage.Min, PossibleDamage.Max)
	local HealthAfter = (humanoid.Health - DamageValue)
	UntagHumanoid(humanoid)
	TagHumanoid(humanoid, Player)
	humanoid:TakeDamage(DamageValue)
	if HealthAfter > 0 then
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
	local Data = NPCModule.GetTable({Key = "MakeNPC", Player = Player})
	if not Data then
		return
	end
	local NPCData = Data.GetData({Player = Player, Tool = Tool})
	OrinthianWarrior = NPCData.MakeNPC({NameTagHidden = true, MaxHealth = 150, AIControl = {Creator = Player, Mode = "Wander", MaxDistance = math.huge, Follow = nil, Offset = Vector3.new(0, 0, 0), Chase = true, ChaseDistance = 150, NormalSpeed = 18, ChaseSpeed = 22, Target = nil, TargetPos = Vector3.new(0, 0, 0), Damage = 10}})
	Sounds.Unsheath:Play()
	ToolEquipped = true
end

function Unequipped()
	if CheckIfAlive() then
		Humanoid.WalkSpeed = 16
	end
	for i, v in pairs({ToolUnequipped}) do
		if v then
			if tostring(v) == "Connection" then
				v:disconnect()
			elseif type(v) == "userdata" and v.Parent then
				v:Destroy()
			end
		end
	end
	ToolEquipped = false
end

function OnServerInvoke(player, mode, value)
	if player ~= Player or not ToolEquipped or not value or not CheckIfAlive() then
		return
	end
	if mode == "KeyPress" then
		local Key = value.Key
		local Down = value.Down
		if Key == "q" and Down then
			if not Special.Enabled or Special.Active then
				return
			end
			Special.Enabled = false
			Special.Active = true
			local CurrentlyEquipped = true
			if ToolUnequipped then
				ToolUnequipped:disconnect()
			end
			ToolUnequipped = Tool.Unequipped:connect(function()
				CurrentlyEquipped = false
			end)
			local Animation = Animations.Summon
			Spawn(function()
				InvokeClient("PlayAnimation", Animation)
			end)
			Humanoid.WalkSpeed = 0
			wait(Animation.Duration)
			if CurrentlyEquipped then
				Humanoid.WalkSpeed = 16
				local StartPoint = (Torso.CFrame + (Torso.CFrame.lookVector * Vector3.new(1, 0, 1)) * 5)
				for i = 1, 3 do
					local NPC = OrinthianWarrior:Clone()
					local ExplodeScriptCopy = ExplodeScript:Clone()
					ExplodeScriptCopy.Disabled = false
					ExplodeScriptCopy.Parent = NPC
					local Assets = {}
					for i, v in pairs(Clothing.BodyParts) do
						table.insert(Assets, v)
					end
					table.insert(Assets, Clothing.Hats[math.random(1, #Clothing.Hats)])
					for i, v in pairs(Assets) do
						local AssetModel = InsertService:LoadAsset(v)
						local Asset = AssetModel:GetChildren()[1]:Clone()
						Debris:AddItem(AssetModel, 1)
						Asset.Parent = NPC
					end
					Debris:AddItem(NPC, Special.Duration)
					NPC.Parent = game:GetService("Workspace")
					local NPCTorso = NPC:FindFirstChild("Torso")
					if NPCTorso then
						NPCTorso.CFrame = (StartPoint * CFrame.new((-4.5 + ((Torso.Size.X + 2.5) * (i - 1))), 0, 0))
					end
				end
				Special.Active = false
				wait(Special.ReloadTime)
				Special.Enabled = true
			else
				Special.Active = false
				Special.Enabled = true
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

Handle.Touched:connect(Blow)

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)