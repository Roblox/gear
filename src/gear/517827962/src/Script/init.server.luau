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


BaseUrl = "http://www.roblox.com/asset/?id="

AIScript = script:WaitForChild("AIScript")
RemoverScript = script:WaitForChild("RemoverScript")

NPCModel = InsertService:LoadAsset(517579204)
NPC = NPCModel:GetChildren()[1]:Clone()
if NPCModel and NPCModel.Parent then
	NPCModel:Destroy()
end

BaseBone = Handle:Clone()
BaseBone.Name = "Fish"
BaseBone.Transparency = 0
BaseBone.Friction = 2
BaseBone.Elasticity = 0
BaseBone.Size = Vector3.new(1.25, 1.25, 1.25)
BaseBone.CanCollide = true

ReloadTime = 2

BoneEnabled = true
ToolEquipped = false

ServerControl = (Tool:FindFirstChild("ServerControl") or Create("RemoteFunction"){
	Name = "ServerControl",
	Parent = Tool,
})

ClientControl = (Tool:FindFirstChild("ClientControl") or Create("RemoteFunction"){
	Name = "ClientControl",
	Parent = Tool,
})

DisplayModel = Tool:FindFirstChild("DisplayModel")
if DisplayModel then
	DisplayModel:Destroy()
end

Handle.Transparency = 0
Tool.Enabled = true

function ThrowBone(TargetPosition)

	if not CheckIfAlive() or not ToolEquipped or not BoneEnabled or not PlayerNPC or not PlayerNPC.Parent or PlayerNPC:FindFirstChild("FakeTreat") then
		return
	end

	BoneEnabled = false	
	
	local MaxDistance = 100
	local StartPosition = Handle.Position
	local Direction = CFrame.new(StartPosition, Vector3.new(TargetPosition.X, StartPosition.Y, TargetPosition.Z))
	local SpawnPosition = (CFrame.new(StartPosition) + Direction.lookVector * BaseBone.Size.Z * 3)
	local Distance = (StartPosition - TargetPosition).Magnitude
	if Distance > MaxDistance then
		TargetPosition = (SpawnPosition + Direction.lookVector * MaxDistance)
		Distance = MaxDistance
	end
	
	local Velocity = Distance
	
	local ThrowVelocity = ((Direction.lookVector * Velocity) + Vector3.new(0, (Distance * 1), 0))
	
	local Bone = BaseBone:Clone()
	Bone.CFrame = SpawnPosition
	Bone.Velocity = ThrowVelocity
	Bone.RotVelocity = Vector3.new(math.random(), math.random(), math.random())
	
	Debris:AddItem(Bone, 5)
	
	Bone.Parent = game:GetService("Workspace")
	
	local Treat = PlayerNPC:FindFirstChild("Treat")
	if Treat then
		Treat.Value = Bone
	end
	
	Handle.Transparency = 1
	
	wait(2)
	
	Handle.Transparency = 0
	BoneEnabled = true

end

function MakeNPC()
	if PlayerNPC and PlayerNPC.Parent then
		PlayerNPC:Destroy()
	end
	PlayerNPC = NPC:Clone()
	NPCHumanoid = PlayerNPC:FindFirstChild("Humanoid")
	NPCHead = PlayerNPC:FindFirstChild("Head")
	NPCTorso = PlayerNPC:FindFirstChild("Torso")
	if not NPCHumanoid or not NPCHead or not NPCTorso then
		return
	end
	local Values = {
		{Name = "Creator", Class = "ObjectValue", Value = Player},
		{Name = "Tool", Class = "ObjectValue", Value = Tool},
		{Name = "Mode", Class = "StringValue", Value = "Follow"},
		{Name = "MaxDistance", Class = "NumberValue", Value = math.huge},
		{Name = "Follow", Class = "ObjectValue", Value = Player},
		{Name = "Offset", Class = "Vector3Value", Value = Vector3.new(-4, 0, -0.5)},
		{Name = "Target", Class = "ObjectValue", Value = nil},
		{Name = "TargetPos", Class = "Vector3Value", Value = Vector3.new(0, 0, 0)},
		{Name = "Damage", Class = "NumberValue", Value = 0},
	}
	for i, v in pairs(Values) do
		local Value = Instance.new(v.Class)
		Value.Name = v.Name
		Value.Value = v.Value
		Value.Parent = PlayerNPC
	end
	for i, v in pairs({RemoverScript, AIScript}) do
		local ScriptClone = v:Clone()
		ScriptClone.Disabled = false
		ScriptClone.Parent = PlayerNPC
	end
	PlayerNPC.Parent = game:GetService("Workspace")
	NPCTorso.CFrame = (Torso.CFrame * CFrame.new(PlayerNPC.Offset.Value))
	NPCHumanoid:ChangeState(Enum.HumanoidStateType.Freefall)
end

function Activated()
	local MouseData = InvokeClient("MouseData")
	if not Tool.Enabled or not CheckIfAlive() and MouseData and MouseData.Position then
		return
	end
	ThrowBone(MouseData.Position)
end

function CheckIfAlive()
	return (((Player and Player.Parent and Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent) and true) or false)
end

function Equipped()
	--Handle.Transparency = 1
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso")
	if not CheckIfAlive() then
		return
	end
	if Tool.Enabled then
		Spawn(function()
			MakeNPC()
		end)
	end
	ToolEquipped = true
end

function Unequipped()
	if PlayerNPC then
		for i, v in pairs({PlayerNPC}) do
			if v and v.Parent then
				v:Destroy()
			end
		end
		PlayerNPC = nil
		Spawn(function()
			Tool.Enabled = false
			wait(ReloadTime)
			Tool.Enabled = true
			if not ToolEquipped then
				--Handle.Transparency = 0
			end
		end)
	end
	ToolEquipped = false
end

function OnServerInvoke(player, mode, value)
	if player ~= Player or not ToolEquipped or not mode or not value or not CheckIfAlive() then
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

Tool.Changed:connect(function(Property)
	if not Tool or not Tool.Parent then
		return
	end
	if Property == "Enabled" and Tool.Enabled and ToolEquipped and CheckIfAlive() then
		MakeNPC()
	elseif Property == "Parent" then
		Handle.Transparency = (((Tool.Parent:IsA("Backpack") or Players:GetPlayerFromCharacter(Tool.Parent)) and ((BoneEnabled and 0) or 1)) or 0)
	end
end)

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)