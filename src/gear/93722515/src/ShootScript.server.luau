Tool = script.Parent
VELOCITY = 50 -- constant
loaded=false

local Pellet = Instance.new("Part")
--Pellet.Shape = 1
Pellet.formFactor = "Custom"
Pellet.Size = Vector3.new(.5,3,.5)
Pellet.BrickColor = BrickColor.new("Bright orange")
Pellet.Material = Enum.Material.Ice
Pellet.Locked = true
Pellet.TopSurface = 0
Pellet.BottomSurface = 0

local mesh=Instance.new("SpecialMesh")
--mesh.Scale=Vector3.new(1,1,4)
mesh.Parent=Pellet

local looper = Instance.new("Sound")
looper.Name = "RaySound"
looper.SoundId = "http://www.roblox.com/asset/?id=28912822"
looper.Looped = true
looper.Parent = Pellet



script.Parent.ProjectileScript:clone().Parent = Pellet
script.Parent.OutfitScript:clone().Parent = Pellet


function fire(v, shootDirect)

-- find player's head pos
	local vCharacter = Tool.Parent
	local vPlayer = game.Players:playerFromCharacter(vCharacter)

	local head = vCharacter:findFirstChild("Head")
	if head == nil then return end

	Tool.Handle.Fire:Play()
	local launch = head.Position + 10 * v

	local missile = Pellet:clone()
	missile.CFrame = CFrame.new(launch,shootDirect) * CFrame.Angles(math.pi/2,0,0)
	missile.Position = launch
	missile.Velocity = v * 200

	local force = Instance.new("BodyForce")
	force.force = Vector3.new(0,Pellet:GetMass()*9.81*20,0)
	force.Parent = missile

	missile.ProjectileScript.Disabled = false
	missile.RaySound:Play()

	missile.Parent = game.Workspace

end

function gunUp()
	Tool.GripPos = Vector3.new(0, -0.5, 1.1)
end

function gunOut()
	Tool.GripPos = Vector3.new(0, -0.5, 1.3)
end

function onEquipped()

	Tool.Handle.Fire:Stop()

end

function onUnequipped()

	Tool.Handle.Fire:Stop()

end

Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)


enabled = true
function onActivated()
	if not enabled  then
		return
	end

	enabled = false

	local character = Tool.Parent;
	local humanoid = character.Humanoid
	if humanoid == nil then
		print("Humanoid not found")
		return 
	end

	local targetPos = humanoid.TargetPoint
	local lookAt = (targetPos - character.Head.Position).unit
	shootDirect = targetPos

	local reload = 0.6

	gunUp()
	fire(lookAt, shootDirect)
	wait(reload)
	gunOut()
	wait(reload)

	enabled = true

end

script.Parent.Activated:connect(onActivated)
