--Fixed by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

Tool.Enabled = true

function fire(v)

	local missile = Instance.new("Part")

	local noise = Vector3.new(math.random() - .5, math.random() - .5, math.random() - .5).unit

	v = (v + (noise * .05)).unit


	local spawnPos = Handle.Position
	
	local PewPew = Tool.Handle:FindFirstChild("PewPew")	

	spawnPos  = spawnPos + (v * 2)

	
	missile.Position = spawnPos
	missile.Size = Vector3.new(1,1,1)
	missile.Velocity = v * 150
	missile.BrickColor = BrickColor.new(199)
	missile.Shape = 0
	missile.BottomSurface = 0
	missile.TopSurface = 0
	missile.Material = Enum.Material.CorrodedMetal
	missile.Elasticity = .05
	missile.Friction = .7
	missile.Name = "Bullet"
	
	Handle.HitSound:Clone().Parent = missile


	local force = Instance.new("BodyForce")
	force.Name = "BulletFloat"
	force.force = Vector3.new(0,98,0)
	force.Parent = missile

	local creator_tag = Instance.new("ObjectValue")
	creator_tag.Value = Player
	creator_tag.Name = "creator"
	creator_tag.Parent = missile
	
	local new_script = script.LaserBlast:clone()
	new_script.Disabled = false
	new_script.Parent = missile
	
	Debris:AddItem(missile, 10)

	missile.Parent = game:GetService("Workspace")

	Handle.PewPew:Play()

end



function gunUp()
	Tool.GripForward = Vector3.new(0,.981,-.196)
	Tool.GripRight = Vector3.new(1,0,0)
	Tool.GripUp = Vector3.new(0,.196,.981)
end

function gunOut()
	Tool.GripForward = Vector3.new(0,1,0)
	Tool.GripRight = Vector3.new(1,0,0)
	Tool.GripUp = Vector3.new(0,0,1)
end

function onActivated()
	if not Tool.Enabled or not ToolEquipped or not CheckIfAlive() then
		return
	end

	Tool.Enabled = false

	local targetPos = InvokeClient("MousePosition").Position
	local lookAt = (targetPos - Handle.Position).unit

	local reload = .1

	gunUp()
	fire(lookAt)
	wait(reload)
	gunOut()
	wait(reload)

	Tool.Enabled = true

end

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Player and Player.Parent) and true) or false)
end

function onEquipped(Mouse)
	Character = Tool.Parent
	Humanoid = Character:FindFirstChild("Humanoid")
	Player = Players:GetPlayerFromCharacter(Character)
	if not CheckIfAlive() then
		return
	end
	Handle.EquipSound:play()
	ToolEquipped = true
end

function onUnequipped()
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
	if player ~= Player or not ToolEquipped or not value or not CheckIfAlive() or not Tool.Enabled then
		return
	end
end

--ServerControl.OnServerInvoke = OnServerInvoke

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)