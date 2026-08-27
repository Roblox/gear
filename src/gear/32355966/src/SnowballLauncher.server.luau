local Players = game:GetService("Players")

Tool = script.Parent
VELOCITY = 50 -- constant
loaded=false

local Pellet = Instance.new("Part")
Pellet.BrickColor = BrickColor.new("Bright green")
Pellet.Shape = 0
Pellet.formFactor = 0
Pellet.Size = Vector3.new(3,3,3)
Pellet.Locked = true
Pellet.TopSurface = 0
Pellet.Transparency = 0.8
Pellet.BottomSurface = 0

local fire = Instance.new("Fire")
fire.Color = Color3.new(51/255,205/255,51/255)
fire.SecondaryColor = Color3.new(0,102/255,0)
fire.Heat = 13
fire.Parent = Pellet

local ServerControls = Tool:FindFirstChild("ServerControls") or Instance.new("RemoteEvent")
ServerControls.Name = "ServerControls"
ServerControls.Parent = Tool

Tool.SnowballScript:clone().Parent = Pellet


function fire(v, shootDirect)

-- find player's head pos

	local vCharacter = Tool.Parent
	local vPlayer = Players:GetPlayerFromCharacter(vCharacter)
	ServerControls:FireClient(vPlayer)

	local head = vCharacter:FindFirstChild("Head")
	if head == nil then return end

	Tool.Handle.Fire:Play()
	local launch = head.Position + 10 * v

	local missile = Pellet:clone()
	missile.CFrame = CFrame.new(launch,shootDirect)
	missile.Position = launch
	missile.Velocity = v * 130

	local force = Instance.new("BodyForce")
	force.force = Vector3.new(0,missile:GetMass() * workspace.Gravity,0)
	force.Parent = missile

	missile.SnowballScript.Disabled = false

	missile.Parent = workspace
end

function onEquipped()
	Tool.Handle.Fire:Stop()
end

function onUnequipped()
	Tool.Handle.Fire:Stop()
end

function onActivated()
	if not Tool.Enabled then return end
	Tool.Enabled = false

	local character = Tool.Parent;
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid == nil then
		print("Humanoid not found")
		return 
	end

	local targetPos = humanoid.TargetPoint
	local lookAt = (targetPos - character.Head.Position).unit
	shootDirect = targetPos

	fire(lookAt, shootDirect)
	wait(5)
	Tool.Enabled = true
end

Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
Tool.Activated:connect(onActivated)