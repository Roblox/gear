--Made by Luckymaxer
--Updated for R15 avatar by StarWars

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")
InsertService = game:GetService("InsertService")

SpiderModel = InsertService:LoadAsset(299861127)
Spider = SpiderModel:GetChildren()[1]:Clone()
Debris:AddItem(SpiderModel, 1)

CobWebShot = script:WaitForChild("CobWebShot")

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

ReloadTime = 60
Duration = nil

SpidersSpawned = false
SpidersReady = false

CurrentSpiders = {}

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

function IsTeamMate(Player1, Player2)
	return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
end

function CreateSpiderModel()
	local SpiderModel = Create("Model"){
		Name = ToolName,
	}
	local CobWebShotScript = CobWebShot:Clone()
	CobWebShotScript.Disabled = false
	CobWebShotScript.Parent = SpiderModel
	local RemoverClone = Remover:Clone()
	local Values = {
		{Name = "Creator", Class = "ObjectValue", Value = Player},
		{Name = "Tool", Class = "ObjectValue", Value = Tool},
	}
	for i, v in pairs(Values) do
		local Value = Create(v.Class){
			Name = v.Name,
			Value = v.Value,
			Parent = SpiderModel,
		}
	end
	RemoverClone.Disabled = false
	RemoverClone.Parent = SpiderModel
	return SpiderModel
end

function SetUpSpider(Figure)
	NPCData.MakeNPC({NPC = Figure, AIControl = {Creator = Player, Mode = "Follow", MaxDistance = 100, Follow = Player, Offset = Vector3.new(2, 0, 0), Chase = false, ChaseDistance = 50, ChaseRange = 8, Target = nil, TargetPos = Vector3.new(0, 0, 0), Damage = 15, NormalSpeed = 16, ChaseSpeed = 22, SelfSufficient = false}})
	Figure.Name = "Tarantula"
	local Humanoid = Figure:FindFirstChild("Humanoid")
	local Torso = Figure:FindFirstChild("Torso")
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
	return Figure
end

function SpawnSpiders()
	local Data = NPCModule.GetTable({Key = "MakeNPC", Player = Player})
	if not Data then
		return
	end
	NPCData = Data.GetData({Player = Player, Tool = Tool})
	SpidersReady = false
	CurrentSpiders = {}
	local SpiderModel = CreateSpiderModel()
	NPCData.MakeNPC({NPC = SpiderModel, AIControl = {Creator = Player, SelfSufficient = true}})
	local BaseNPC = SetUpSpider(Spider:Clone())
	SpiderModel.Changed:connect(function(Property)
		if Property == "Parent" and not SpiderModel.Parent then
			for i, v in pairs(CurrentSpiders) do
				if v and v.Parent then
					v:Destroy()
				end
			end
			CurrentSpiders = {}
			Tool.Enabled = false
			wait(ReloadTime)
			Tool.Enabled = true
			Handle.Transparency = 0
			SpidersSpawned = false
		end
	end)
	if Duration then
		Debris:AddItem(SpiderModel, Duration)
	end
	SpiderModel.Parent = game:GetService("Workspace")
	local function CreatePawn()
		local SpiderCopy = BaseNPC:Clone()
		local SpiderHumanoid = SpiderCopy.Humanoid
		local SpiderTorso = SpiderCopy.Torso
		table.insert(CurrentSpiders, SpiderCopy)
		SpiderCopy.Changed:connect(function(Property)
			if Property == "Parent" and not SpiderCopy.Parent then
				for i, v in pairs(CurrentSpiders) do
					if v == SpiderCopy then
						table.remove(CurrentSpiders, i)
						if #CurrentSpiders == 0 then
							if SpiderModel and SpiderModel.Parent then
								Debris:AddItem(SpiderModel, 1)
								SpiderModel:Destroy()
							end
						end
					end
				end
			end
		end)
		local OffsetValue = SpiderCopy.Offset
		OffsetValue.Value = Vector3.new(-5, 0, -0.5)
		SpiderCopy.Parent = SpiderModel
		SpiderTorso.CFrame = (Torso.CFrame * CFrame.new(OffsetValue.Value) - Vector3.new(0, 0.2, 0))
		SpiderHumanoid:ChangeState(Enum.HumanoidStateType.Freefall)
	end
	for i = 1, 1 do
		CreatePawn()
	end
	SpidersReady = true
end

function Activated()
	if not Tool.Enabled or not ToolEquipped then
		return
	end
	local SpiderModel = game:GetService("Workspace"):FindFirstChild(ToolName)
	if SpiderModel then
		local MouseData = InvokeClient("MousePosition")
		local MousePosition = MouseData.Position
		local MouseTarget = MouseData.Target
		for i, v in pairs(CurrentSpiders) do
			if v and v.Parent then
				local Target = v:FindFirstChild("Target")
				local TargetPos = v:FindFirstChild("TargetPos")
				local Mode = v:FindFirstChild("Mode")
				local NewMode = nil
				if Target and TargetPos and Mode then
					if MouseTarget and MouseTarget.Parent then
						TargetPos.Value = MousePosition
						local character = MouseTarget.Parent
						if character:IsA("Hat") then
							character = character.Parent
						end
						local player = Players:GetPlayerFromCharacter(character)
						if not player or (player and not IsTeamMate(player, Player)) then
							local creator = character:FindFirstChild("Creator")
							local humanoid = character:FindFirstChild("Humanoid")
							if humanoid and humanoid.Health > 0 and (not creator or (creator and creator.Value ~= Player and not IsTeamMate(Player, creator.Value))) then
								Target.Value = character
								NewMode = "Attack"
							end
						end
						if not NewMode then
							Target.Value = nil
							TargetPos.Value = MousePosition
							NewMode = "MoveTo"
						end
					else
						Target.Value = nil
						NewMode = "Follow"
					end
				end
				if NewMode then
					Mode.Value = NewMode
				end
			end
		end
	elseif not SpiderModel and not SpidersSpawned then
		Handle.Transparency = 1
		SpidersSpawned = true
		SpawnSpiders()
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
	ToolName = (Player.Name .. "'sTarantulas")
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
		Handle.Transparency = (((Tool.Parent:IsA("Backpack") or Players:GetPlayerFromCharacter(Tool.Parent) and ((not SpidersSpawned and 0) or 1)) or 0))
	end
end)

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)