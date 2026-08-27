-- Strange issue when I try to do the entire logic in a single script
-- Must look into this more
local Tool = script.Parent
local vCharacter
local myHumanoid
local myTorso
local vPlayer

Tool.Enabled = true

local fire = Instance.new("Fire")
fire.Color = Color3.new(205/255, 50/255, 120/255)
fire.Size = 8

local reload = 4	

local debris = game:GetService("Debris")

local burnSound = Tool.Handle:FindFirstChild("burnSound")
if burnSound == nil then
	burnSound = Instance.new("Sound")
	burnSound.Name = "burnSound"
	burnSound.SoundId = "http://www.roblox.com/asset/?id=31758982"
	burnSound.Parent = Tool.Handle
	burnSound.Volume = 0
end

local fireSound = Instance.new("Sound")
fireSound.Name = "fireSound"
fireSound.SoundId = "http://www.roblox.com/asset/?id=32791565"
fireSound.Parent = ball
fireSound.Volume = 1

function spread(direction)		
	spawnPos = vCharacter.PrimaryPart.Position
	vPlayer = game.Players:playerFromCharacter(vCharacter)
	if vPlayer  == nil then return end 
	local missile = Instance.new("Part")
	
	fire:Clone().Parent = missile	

	spawnPos  = spawnPos + (direction * 2)
	
	missile.Position = spawnPos
	missile.Size = Vector3.new(3.5, 3.5, 3.5)
	missile.Velocity = direction * 20
	missile.Name = "Flame"
	missile.Transparency = 1
	missile.CanCollide = false

	local force = Instance.new("BodyForce")
	force.force = Vector3.new(0, missile:GetMass()* 200, 0)
	force.Parent = missile	

	local creator_tag = Instance.new("ObjectValue")
	creator_tag.Value = vPlayer
	creator_tag.Name = "creator"
	creator_tag.Parent = missile
	
	local new_script = script.Parent.FlameSpreadScript:Clone()
	new_script.Disabled = false
	new_script.Parent = missile	

	missile.Parent = game.Workspace	
end

function onActivated()
	if not Tool.Enabled then
		return
	end
	Tool.Enabled = false

	vCharacter = Tool.Parent
	myTorso = vCharacter:FindFirstChild("Torso")
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	if myHumanoid == nil or myTorso == nil then		
		return 
	end

	local pauseTime = .10 
	local tempVect = Workspace.CurrentCamera.CoordinateFrame:pointToObjectSpace(myHumanoid.TargetPoint)
	local oldTargetDepth = tempVect.Z
	
	Workspace.CurrentCamera.CoordinateFrame:pointToObjectSpace(myHumanoid.TargetPoint)
	
	burnSound.Volume = 1
	burnSound:Play()
	for i = 1, 20 do
		local direction = (myHumanoid.TargetPoint - myTorso.Position).unit
		if (script.Dir.Value.magnitude > .9 and script.Dir.Value.magnitude < 1.1) then
			direction = script.Dir.Value
		end
		spread(direction)		
		wait(pauseTime)
		burnSound:Play()
	end
	wait(1)	
	if burnSound then burnSound:Stop() end
	wait(reload)
	Tool.Enabled = true
end

function onEquipped()		
end

function onUnequipped()
	if burnSound then burnSound:Stop() end
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
