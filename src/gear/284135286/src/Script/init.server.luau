--Made by Luckymaxer
--Updated for R15 avatar by StarWars

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


AIScript = script:WaitForChild("AIScript")
Remover = script:WaitForChild("Remover")

NPCModule = require(191816425)

BaseUrl = "http://www.roblox.com/asset/?id="

Sounds = {}

BasePart = Create("Part"){
	Shape = Enum.PartType.Block,
	Material = Enum.Material.Plastic,
	TopSurface = Enum.SurfaceType.Smooth,
	BottomSurface = Enum.SurfaceType.Smooth,
	FormFactor = Enum.FormFactor.Custom,
	Size = Vector3.new(0.2, 0.2, 0.2),
	CanCollide = true,
	Locked = true,
	Anchored = false,
}

ReloadTime = 10
Duration = (60 * 2)

RobloxiansSpawned = false
RobloxiansReady = false

CurrentRobloxians = {}

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
Tool.Enabled = true

function CreateRobloxianModel()
	local RobloxianModel = Create("Model"){
		Name = ToolName,
	}
	local AIScriptClone = AIScript:Clone()
	AIScriptClone.Disabled = false
	AIScriptClone.Parent = RobloxianModel
	local RemoverClone = Remover:Clone()
	local Values = {
		{Name = "Creator", Class = "ObjectValue", Value = Player},
		{Name = "Tool", Class = "ObjectValue", Value = Tool},
	}
	for i, v in pairs(Values) do
		local Value = Create(v.Class){
			Name = v.Name,
			Value = v.Value,
			Parent = RobloxianModel,
		}
	end
	RemoverClone.Disabled = false
	RemoverClone.Parent = RobloxianModel
	return RobloxianModel
end

function SetUpRobloxian(Figure)
	local Values = {
		{Name = "Creator", Class = "ObjectValue", Value = Player},
		{Name = "Mode", Class = "StringValue", Value = "Follow"},
		{Name = "MaxDistance", Class = "NumberValue", Value = 150},
		{Name = "Follow", Class = "ObjectValue", Value = Player},
		{Name = "Offset", Class = "Vector3Value", Value = Vector3.new(0, 0, 0)},
		{Name = "Target", Class = "ObjectValue", Value = nil},
		{Name = "TargetPos", Class = "Vector3Value", Value = Vector3.new(0, 0, 0)},
		{Name = "Damage", Class = "NumberValue", Value = 5},
	}
	for i, v in pairs(Values) do
		local Value = Create(v.Class){
			Name = v.Name,
			Value = v.Value,
			Parent = Figure,
		}
	end
	local Humanoid = Figure:FindFirstChild("Humanoid")
	local Torso = Figure:FindFirstChild("Torso") or Figure:FindFirstChild("UpperTorso")
	if Humanoid and Torso then
		Humanoid.Died:connect(function()
			Debris:AddItem(Figure, 2)
		end)
		Humanoid.Jumping:connect(function()
		end)
		Figure.Changed:connect(function(Property)
			if Property == "Parent" and not Figure.Parent then
				Debris:AddItem(Figure, 2)
			end
		end)
	end
	return
end

function SpawnRobloxians()
	RobloxiansReady = false
	CurrentRobloxians = {}
	local RobloxianModel = CreateRobloxianModel()
	RobloxianModel.Changed:connect(function(Property)
		if Property == "Parent" and not RobloxianModel.Parent then
			for i, v in pairs(CurrentRobloxians) do
				if v and v.Parent then
					v:Destroy()
				end
			end
			CurrentRobloxians = {}
			Tool.Enabled = false
			wait(ReloadTime)
			Tool.Enabled = true
			Handle.Transparency = 0
			RobloxiansSpawned = false
		end
	end)	
	Debris:AddItem(RobloxianModel, Duration)
	RobloxianModel.Parent = game:GetService("Workspace")
	local function CreatePawn()
		local Data = NPCModule.GetTable({Key = "MakeNPC", Player = Player})
		if not Data then
			return
		end
		local NPCData = Data.GetData({Player = Player, Tool = Tool})
		local BaseNPC = NPCData.MakeNPC({Scale = 0.5, NameTagHidden = true, Appearance = Character})
		BaseNPC.Name = "ROBLOXian"
		local RobloxianCopy = BaseNPC:Clone()
		local RobloxianHumanoid = RobloxianCopy.Humanoid
		local RobloxianTorso = RobloxianCopy.Torso
		SetUpRobloxian(RobloxianCopy)
		RobloxianCopy.Follow.Value = Character
		table.insert(CurrentRobloxians, RobloxianCopy)
		RobloxianCopy.Changed:connect(function(Property)
			if Property == "Parent" and not RobloxianCopy.Parent then
				for i, v in pairs(CurrentRobloxians) do
					if v == RobloxianCopy then
						table.remove(CurrentRobloxians, i)
						if #CurrentRobloxians == 0 then
							if RobloxianModel and RobloxianModel.Parent then
								Debris:AddItem(RobloxianModel, 1)
								RobloxianModel:Destroy()
							end
						end
					end
				end
			end
		end)
		local OffsetValue = RobloxianCopy.Offset
		OffsetValue.Value = Vector3.new(3, 0, -1.5)
		RobloxianHumanoid.WalkSpeed = 16
		RobloxianHumanoid.MaxHealth = 100
		RobloxianHumanoid.Health = RobloxianHumanoid.MaxHealth
		RobloxianCopy.Parent = RobloxianModel
		RobloxianTorso.CFrame = (Torso.CFrame * CFrame.new(OffsetValue.Value) - Vector3.new(0, 0.2, 0))
		RobloxianHumanoid:ChangeState(Enum.HumanoidStateType.Freefall)
	end
	CreatePawn()
	RobloxiansReady = true
end

function Activated()
	if not Tool.Enabled or not ToolEquipped then
		return
	end
	if not RobloxiansSpawned then
		local RobloxianModel = game:GetService("Workspace"):FindFirstChild(ToolName)
		if RobloxianModel then
			return
		end
		Handle.Transparency = 1
		RobloxiansSpawned = true
		SpawnRobloxians()
	end
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
	ToolName = (Player.Name .. "'sROBLOXianClones")
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

function OnServerInvoke(player, Mode, Value)
	if player ~= Player or not ToolEquipped or not CheckIfAlive() or not Mode or not Value then
		return
	end
end

ServerControl.OnServerInvoke = OnServerInvoke

Tool.Changed:connect(function(Property)
	if Property == "Parent" and Tool.Parent then
		Handle.Transparency = (((Tool.Parent:IsA("Backpack") or Players:GetPlayerFromCharacter(Tool.Parent) and ((not RobloxiansSpawned and 0) or 1)) or 0))
	end
end)

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)