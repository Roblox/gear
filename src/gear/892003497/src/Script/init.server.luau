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


Remover = script:WaitForChild("Remover")

NPCModule = require(191816425)

BaseUrl = "http://www.roblox.com/asset/?id="

BasePart = Create("Part"){
	Shape = Enum.PartType.Block,
	Material = Enum.Material.Plastic,
	TopSurface = Enum.SurfaceType.Smooth,
	BottomSurface = Enum.SurfaceType.Smooth,
	Size = Vector3.new(0.2, 0.2, 0.2),
	CanCollide = true,
	Locked = true,
	Anchored = false,
}

ReloadTime = 20
Duration = (60 * 2)

RobotsSpawned = false
RobotsReady = false

CurrentRobots = {}

ToolEquipped = false

Remotes = Tool:WaitForChild("Remotes")

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

function CreateRobotModel()
	local RobotModel = Create("Model"){
		Name = ToolName,
	}
	local RemoverClone = Remover:Clone()
	local Values = {
		{Name = "Creator", Class = "ObjectValue", Value = Player},
		{Name = "Tool", Class = "ObjectValue", Value = Tool},
	}
	for i, v in pairs(Values) do
		local Value = Create(v.Class){
			Name = v.Name,
			Value = v.Value,
			Parent = RobotModel,
		}
	end
	RemoverClone.Disabled = false
	RemoverClone.Parent = RobotModel
	return RobotModel
end

function SetUpRobot(Figure)
	Figure.Name = "Robot"
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

function SpawnRobots()
	local NPCData = NPCModule.GetTable({Key = "MakeNPC", Player = Player})
	local RobotData = NPCModule.GetTable({Key = "AttackCooler", Player = Player})
	if not NPCData or not RobotData then
		return
	end
	local NPCFunctions = NPCData.GetData({Player = Player, Tool = Tool})
	local RobotFunctions = RobotData.GetData({Player = Player, Tool = Tool})
	RobotsReady = false
	CurrentRobots = {}
	local RobotModel = CreateRobotModel()
	NPCFunctions.MakeNPC({NPC = RobotModel, AIControl = {Creator = Player, SelfSufficient = true}})
	local RobotNPC = RobotFunctions.MakeNPC()
	if not RobotNPC then
		return
	end
	local BaseNPC = SetUpRobot(RobotNPC:Clone())
	RobotModel.Changed:connect(function(Property)
		if Property == "Parent" and not RobotModel.Parent then
			for i, v in pairs(CurrentRobots) do
				if v and v.Parent then
					v:Destroy()
				end
			end
			CurrentRobots = {}
			Tool.Enabled = false
			wait(ReloadTime)
			Tool.Enabled = true
			Handle.Transparency = 0
			RobotsSpawned = false
		end
	end)	
	Debris:AddItem(RobotModel, Duration)
	RobotModel.Parent = game:GetService("Workspace")
	local function CreatePawn()
		local RobotCopy = BaseNPC:Clone()
		local RobotHumanoid = RobotCopy.Humanoid
		local RobotTorso = RobotCopy.Torso
		table.insert(CurrentRobots, RobotCopy)
		RobotCopy.Changed:connect(function(Property)
			if Property == "Parent" and not RobotCopy.Parent then
				for i, v in pairs(CurrentRobots) do
					if v == RobotCopy then
						table.remove(CurrentRobots, i)
						if #CurrentRobots == 0 then
							if RobotModel and RobotModel.Parent then
								Debris:AddItem(RobotModel, 1)
								RobotModel:Destroy()
							end
						end
					end
				end
			end
		end)
		local OffsetValue = RobotCopy.Offset
		OffsetValue.Value = Vector3.new(4, 0, 0)
		RobotCopy.Parent = RobotModel
		RobotTorso.CFrame = (Torso.CFrame * CFrame.new(OffsetValue.Value) - Vector3.new(0, 0.2, 0))
		RobotHumanoid:ChangeState(Enum.HumanoidStateType.Freefall)
	end
	for i = 1, 1 do
		CreatePawn()
	end
	RobotsReady = true
end

function Activated()
	if not Tool.Enabled or not ToolEquipped then
		return
	end
	local RobotModel = game:GetService("Workspace"):FindFirstChild(ToolName)
	if RobotModel then
		local MouseData = InvokeClient("MouseData")
		if not MouseData then
			return
		end
		local MousePosition = MouseData.Position
		if not MousePosition then
			return
		end
		local MouseTarget = MouseData.Target
		for i, v in pairs(CurrentRobots) do
			if v and v.Parent then
				local TargetPos = v:FindFirstChild("TargetPos")
				local Mode = v:FindFirstChild("Mode")
				local Target = v:FindFirstChild("Target")
				if TargetPos and Mode and Target then
					if MouseTarget and MouseTarget.Parent then
						TargetPos.Value = MousePosition
						local TargetParent = MouseTarget.Parent 
						if TargetParent and TargetParent:FindFirstChildOfClass("Humanoid") then
							Target.Value = TargetParent
							Mode.Value = "Attack"
						else 
							Mode.Value = "MoveTo"
							Target.Value = nil
						end 
					else 
						Mode.Value = "Follow"
						Target.Value = nil 
					end
				end
			end
		end
	elseif not RobotModel and not RobotsSpawned then
		Handle.Transparency = 1
		RobotsSpawned = true
		SpawnRobots()
	end
end


function CheckIfAlive()
	return (((Player and Player.Parent and Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent) and true) or false)
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("HumanoidRootPart")
	if not CheckIfAlive() then
		return
	end
	ToolName = (Player.Name .. "'sRobot")
	ToolEquipped = true
	Spawn(function()
		if ToolEquipped and CheckIfAlive() then
			Activated()
		end
	end)
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
		Handle.Transparency = (((Tool.Parent:IsA("Backpack") or Players:GetPlayerFromCharacter(Tool.Parent) and ((not RobotsSpawned and 0) or 1)) or 0))
	end
end)

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)