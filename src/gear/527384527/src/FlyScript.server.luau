--Made by Luckymaxer

Tool = script.Parent
Handle = Tool.Handle

Players = game:GetService("Players")
Debris = game:GetService("Debris")

ToolEquipped = false

Remotes = Tool:WaitForChild("Remotes")

ServerControl = (Remotes:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Remotes

ClientControl = (Remotes:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Remotes

Duration = 30
CoolDownTime = 15

Using = false
TransparentParts = {}

Handle.Transparency = 0
Tool.Enabled = true

function CoolDown()
	Using = false
	for i, v in pairs({FlightPower, FlightSpin, FlightHold}) do
		if v and v.Parent then
			v:Destroy()
		end
	end
	for i,v in pairs({GhostItemAdded, GhostItemRemoved}) do
		if v then
			v:disconnect()
		end
	end
	for i, v in pairs(TransparentParts) do
		if v and v.Part and v.Part.Parent then
			v.Part.Transparency = v.Transparency
		end
	end
	TransparentParts = {}
	Spawn(function()
		InvokeClient("Fly", {Flying = false})
	end)
	wait(CoolDownTime)
	Tool.Enabled = true 
	Handle.Transparency = 0
end

function SetTransparency(PrimaryParent, Transparency)
	local Parts = {}
	local function SetParentTransparency(Parent)
		for i, v in pairs(Parent:GetChildren()) do
			if v ~= Tool then
				if v.Name ~= "HumanoidRootPart" then
					local ItemTransparent = false
					for ii, vv in pairs(TransparentParts) do
						if vv and vv.Part and vv.Part == v then
							ItemTransparent = true
						end
					end
					if not ItemTransparent then
						pcall(function()
							table.insert(Parts, {Part = v, Transparency = v.Transparency})
							v.Transparency = Transparency
						end)
					end
				end
				SetParentTransparency(v, Transparency)
			end
		end
	end
	SetParentTransparency(PrimaryParent)
	return Parts
end

function Activated()
	if not ToolEquipped or not CheckIfAlive() or not Tool.Enabled or Using then
		return
	end
	
	FlightSpin = Torso:FindFirstChild("FlightSpin")
	FlightPower = Torso:FindFirstChild("FlightPower")
	FlightHold = Torso:FindFirstChild("FlightHold")
	if FlightSpin or FlightPower or FlightHold then
		return
	end
	
	Tool.Enabled = false
	
	Using = true
	
	Handle.Transparency = 1
	
	FlightHold = Instance.new("BodyPosition")
	FlightHold.Name = "FlightHold"
	FlightHold.P = 100000
	FlightHold.maxForce = Vector3.new(0, 0, 0)
	FlightHold.position = Torso.Position
	FlightHold.Parent = Torso
	
	FlightPower = Instance.new("BodyVelocity")
	FlightPower.Name = "FlightPower"
	FlightPower.velocity = Vector3.new(0, 0, 0)
	FlightPower.P = 1000000
	FlightPower.maxForce = Vector3.new(FlightPower.P, FlightPower.P, FlightPower.P)
	FlightPower.P = 10000
	FlightPower.Parent = Torso
	
	FlightSpin = Instance.new("BodyGyro")
	FlightSpin.Name = "FlightSpin"
	FlightSpin.P = 1000000
	FlightSpin.maxTorque = Vector3.new(FlightSpin.P, FlightSpin.P, FlightSpin.P)
	FlightSpin.cframe = Torso.CFrame
	FlightSpin.Parent = Torso
	
	Torso.Velocity = Vector3.new(0, 0, 0)
	Torso.RotVelocity = Vector3.new(0, 0, 0)
	
	Spawn(function()
		InvokeClient("Fly", {Flying = true})
	end)
	
	local BaseTransparency = 0.8
	TransparentParts = SetTransparency(Character, BaseTransparency)
	GhostItemAdded = Character.ChildAdded:connect(function(Child)
		for i, v in pairs(SetTransparency(Child, BaseTransparency)) do
			table.insert(TransparentParts, v)
		end
	end)
	GhostItemRemoved = Character.ChildRemoved:connect(function(Child)
		for i, v in pairs(Child:GetChildren()) do
			for ii, vv in pairs(TransparentParts) do
				if vv.Part == v then
					vv.Part.Transparency = vv.Transparency
					table.remove(TransparentParts, ii)
				end
			end
		end
	end)
	
	local CurrentlyEquipped = true
	if ToolUnequipped then
		ToolUnequipped:disconnect()
	end
	
	ToolUnequipped = Tool.Unequipped:connect(function()
		CurrentlyEquipped = false
	end)
	
	wait(Duration)
	
	if ToolUnequipped then
		ToolUnequipped:disconnect()
	end
	
	if not ToolEquipped or not CurrentlyEquipped then
		return
	end
	
	CoolDown()
		
end

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent and Player and Player.Parent) and true) or false)
end

function Equipped()
	Character = Tool.Parent
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso")
	Player = Players:GetPlayerFromCharacter(Character)
	if not CheckIfAlive() then
		return
	end
	ToolEquipped = true
end

function Unequipped()
	Spawn(function()
		for i, v in pairs({FlightPower, FlightSpin, FlightHold}) do
			if v and v.Parent then
				v:Destroy()
			end
		end
		CoolDown()
	end)
	ToolEquipped = false
end

function OnServerInvoke(player, mode, value)
end

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
end

Tool.Changed:connect(function(Property)
	Handle.Transparency = ((Players:GetPlayerFromCharacter(Tool.Parent) and ((Using and 1) or 0)) or 0)
end)

ServerControl.OnServerInvoke = OnServerInvoke

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)