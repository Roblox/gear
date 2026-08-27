--Made by Luckymaxer

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
	FormFactor = Enum.FormFactor.Custom,
	Size = Vector3.new(0.2, 0.2, 0.2),
	CanCollide = true,
	Locked = true,
	Anchored = false,
}

ReloadTime = 25
Duration = (60 * 5)

NPCSpawned = false
NPCReady = false

CurrentNPC = {}

ToolEquipped = false

DisplayModel = Tool:FindFirstChild("DisplayModel")
if DisplayModel then
	DisplayModel:Destroy()
end

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

function CreateNPCModel()
	local NPCModel = Create("Model"){
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
			Parent = NPCModel,
		}
	end
	RemoverClone.Disabled = false
	RemoverClone.Parent = NPCModel
	return NPCModel
end

function SetUpNPC(Figure)
	Figure.Name = "Ocelot"
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

function SpawnNPC()
	if NPCSpawned then
		return
	end
	for i, v in pairs(game:GetService("Workspace"):GetChildren()) do
		if v:IsA("Model") and v.Name == ToolName then
			v:Destroy()
		end
	end
	Handle.Transparency = 1
	NPCSpawned = true
	local NPCData = NPCModule.GetTable({Key = "MakeNPC", Player = Player})
	local OcelotData = NPCModule.GetTable({Key = "Ocelot", Player = Player})
	if not NPCData or not OcelotData then
		return
	end
	local NPCFunctions = NPCData.GetData({Player = Player, Tool = Tool})
	local OcelotFunctions = OcelotData.GetData({Player = Player, Tool = Tool})
	NPCReady = false
	CurrentNPC = {}
	local NPCModel = CreateNPCModel()
	--NPCFunctions.MakeNPC({NPC = NPCModel, AIControl = {Creator = Player, SelfSufficient = true}})
	local OcelotNPC = OcelotFunctions.MakeNPC()
	if not OcelotNPC then
		return
	end
	local BaseNPC = SetUpNPC(OcelotNPC:Clone())
	NPCModel.Changed:connect(function(Property)
		if Property == "Parent" and not NPCModel.Parent then
			for i, v in pairs(CurrentNPC) do
				if v and v.Parent then
					v:Destroy()
				end
			end
			CurrentNPC = {}
			Tool.Enabled = false
			wait(ReloadTime)
			Tool.Enabled = true
			Handle.Transparency = 0
			NPCSpawned = false
			if ToolEquipped and CheckIfAlive() then
				SpawnNPC()
			end
		end
	end)	
	Debris:AddItem(NPCModel, Duration)
	NPCModel.Parent = game:GetService("Workspace")
	local function CreatePawn()
		local NPCCopy = BaseNPC:Clone()
		local NPCHumanoid = NPCCopy.Humanoid
		local NPCTorso = NPCCopy.Torso
		table.insert(CurrentNPC, NPCCopy)
		NPCCopy.Changed:connect(function(Property)
			if Property == "Parent" and not NPCCopy.Parent then
				for i, v in pairs(CurrentNPC) do
					if v == NPCCopy then
						table.remove(CurrentNPC, i)
						if #CurrentNPC == 0 then
							if NPCModel and NPCModel.Parent then
								Debris:AddItem(NPCModel, 1)
								NPCModel:Destroy()
							end
						end
					end
				end
			end
		end)
		local DesiredOffset = Vector3.new(-3.75, 0, 0)
		NPCCopy.Offset.Value = DesiredOffset
		NPCCopy.Parent = NPCModel
		NPCTorso.CFrame = (Torso.CFrame * CFrame.new(DesiredOffset) - Vector3.new(0, 0.2, 0))
		NPCHumanoid:ChangeState(Enum.HumanoidStateType.Freefall)
	end
	CreatePawn()
	NPCReady = true
end

function Activated()
	if not Tool.Enabled or not ToolEquipped then
		return
	end
	local OcelotModel = game:GetService("Workspace"):FindFirstChild(ToolName)
	if OcelotModel then
		local MouseData = InvokeClient("MouseData")
		if not MouseData then
			return
		end
		local MousePosition = MouseData.Position
		if not MousePosition then
			return
		end
		local MouseTarget = MouseData.Target
		for i, v in pairs(CurrentNPC) do
			if v and v.Parent then
				local TargetPos = v:FindFirstChild("TargetPos")
				local Mode = v:FindFirstChild("Mode")
				local Target = v:FindFirstChild("Target")
				if TargetPos and Mode and Target then
					if MouseTarget and MouseTarget.Parent then
						TargetPos.Value = MousePosition
						local TargetParent = MouseTarget.Parent
						if TargetParent and TargetParent:FindFirstChild("Humanoid") then
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
	--[[elseif not OcelotModel and not NPCSpawned then
		SpawnNPC()]]
	end
end

function CheckIfAlive()
	return (((Player and Player.Parent and Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent) and true) or false)
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso")
	if not CheckIfAlive() then
		return
	end
	ToolName = (Player.Name .. "'sOcelot")
	ToolEquipped = true
	Spawn(function()
		SpawnNPC()
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
		Handle.Transparency = (((Tool.Parent:IsA("Backpack") or Players:GetPlayerFromCharacter(Tool.Parent) and ((not NPCSpawned and 0) or 1)) or 0))
	end
end)

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)