-----------------
--| Constants |--
-----------------

local BASE_COOLDOWN = 1 -- Seconds until tool can be used again
local THROW_FORCE = 75
local THROW_ANGLE =  1.30899694 --75 degrees...ish
local THRUST_SPEED = 100
local BASE_DAMAGE = 45
--------------------
--| WaitForChild |--
--------------------

-- Returns the ancestor that contains a Humanoid, if it exists
local function FindCharacterAncestor(subject)
	if subject and subject ~= Workspace then
		local humanoid = subject:FindFirstChild('Humanoid')
		if humanoid then
			return subject, humanoid
		else
			return FindCharacterAncestor(subject.Parent)
		end
	end
	return nil
end

-- Waits for parent.child to exist, then returns it
local function WaitForChild(parent, childName)
	assert(parent, "ERROR: WaitForChild: parent is nil")
	while not parent:FindFirstChild(childName) do parent.ChildAdded:wait() end
	return parent[childName]
end

-----------------
--| Variables |--
-----------------

local DebrisService = Game:GetService('Debris')
local PlayersService = Game:GetService('Players')

local Tool = script.Parent
local Handle = Tool.Handle

local ClickTransmitterScript = WaitForChild(Tool, 'ClickTransmitter')
local MouseDownObject = WaitForChild(ClickTransmitterScript, 'MouseDown')
local DoDrop = WaitForChild(ClickTransmitterScript, 'DoDrop')
local TargetPosition = WaitForChild(ClickTransmitterScript, 'TargetPosition')

local MouseDownTime = 0
local MouseDownLength = 0

local MyModel = nil
local MyPlayer = nil

local ThrustVelocity= Instance.new('BodyVelocity')
ThrustVelocity.maxForce=Vector3.new(9999999,0,9999999)

local TouchEnabled = false

local ThrowVelocity= Instance.new('BodyVelocity')
ThrowVelocity.maxForce = Vector3.new(9999999,9999999,9999999)
ThrowVelocity.velocity = Vector3.new(0,THROW_FORCE,0)

local creatorTag = Instance.new('ObjectValue',Tool)
creatorTag.Name = 'creator' --NOTE: Must be called 'creator' for website stats

local weaponNameTag = Instance.new('StringValue', creatorTag)
weaponNameTag.Name = 'weaponName'
weaponNameTag.Value = Tool.Name
local weaponIconTag = Instance.new('StringValue', creatorTag)
weaponIconTag.Name = 'weaponIcon'
weaponIconTag.Value = Tool.TextureId

-----------------
--| Functions |--
-----------------

local function ThrowCharacter(hitCharacter)
	print('throwing character')
	local throwTorso = hitCharacter:FindFirstChild('Torso')
	local myTorso = MyModel:FindFirstChild('Torso')

	if not (throwTorso and myTorso) then return end

	local dir = (throwTorso.CFrame.p - myTorso.CFrame.p)
	dir = Vector3.new(dir.x,0,dir.z).unit
	local holdMultiplier = math.min(2.5,math.max(MouseDownLength*.8,1))
	ThrowVelocity.velocity = Vector3.new(math.cos(THROW_ANGLE)*THROW_FORCE*dir.x*holdMultiplier,math.sin(THROW_ANGLE)*THROW_FORCE*holdMultiplier,
		math.cos(THROW_ANGLE)*THROW_FORCE*dir.z*holdMultiplier)
	print(ThrowVelocity.velocity)
	local hitHumanoid= hitCharacter:FindFirstChild('Humanoid')
	if hitHumanoid then
		local throwFinished=false
		ThrustVelocity.velocity=Vector3.new(0,0,0)
		Spawn(function()
			while not throwFinished do
				hitHumanoid.PlatformStand =true
				wait(1/30)
			end
		end)
		ThrowVelocity.Parent=throwTorso

		--Do damage
		local hitBindable = hitHumanoid:FindFirstChild('Hit')
		if hitBindable then
			hitBindable:Invoke(BASE_DAMAGE*math.min(2,math.max(MouseDownLength*.8,1)), creatorTag)
		else
			local ntag = creatorTag:Clone()
			ntag.Parent = hitHumanoid
			game.Debris:AddItem(ntag,1)
			hitHumanoid:TakeDamage(BASE_DAMAGE*math.min(2,math.max(MouseDownLength*.8,1)))
		end

		Delay(.1, function() ThrowVelocity.Parent=nil end)
		Delay(.5,function()
			throwFinished=true 
			ThrustVelocity.Parent=nil 
			wait(2/30)
			hitHumanoid.PlatformStand = false 
		end)
	end
end

local function EndThrust()

end

local function OnTouch(part)
	--print('got to touch')
	if not TouchEnabled then return end
	
	local hitCharacter = FindCharacterAncestor(part)
	if hitCharacter and hitCharacter ~= MyModel then
		ThrowCharacter(hitCharacter)
		EndThrust()
		TouchEnabled = false
	end
end

local function ThrustAttack(direction)
	local torso=WaitForChild(MyModel,'Torso')
	local humanoid=MyModel:FindFirstChild('Humanoid')
	if Tool.Parent == MyModel and humanoid and torso then
		ThrustVelocity.velocity=Vector3.new(direction.x,0,direction.z).unit*THRUST_SPEED
		ThrustVelocity.Parent=torso
		Delay(.25*math.min(math.max(MouseDownLength,1),3),function() 
			ThrustVelocity.Parent=nil 
			TouchEnabled = false 
		end)
	end
end


local function OnEquipped()
	MyModel = Tool.Parent
	MyPlayer = PlayersService:GetPlayerFromCharacter(MyModel)
	creatorTag.Value = MyPlayer
end

local function OnUnequipped()
	MyModel.Humanoid.WalkSpeed = 16
	ThrustVelocity.Parent=nil
end

local ThrustDirection
local cameraPos = WaitForChild(WaitForChild(script.Parent,'CameraTransmitterReceiver'),'CameraCFrame')
local MouseDown =false
local function OnMouseDownChanged(down, targetOverride)
	local myTorso = MyModel:FindFirstChild('Torso')
	local myHead = MyModel:FindFirstChild('Head')
	if not(Tool.Enabled and MyModel and MyModel:FindFirstChild('Humanoid') and myTorso and myHead and MyModel.Humanoid.Health > 0) then return end
	if down then -- Player just clicked
		MouseDownTime = tick()
		MyModel.Humanoid.WalkSpeed = 0
		wait(0)
		MouseDown= true 
		Spawn(function()
			local bgyro = Instance.new('BodyGyro') 
			bgyro.maxTorque= Vector3.new(9999999,9999999,9999999)
			bgyro.Parent= myTorso
			while MouseDown do
				ThrustDirection =(myHead.CFrame.p-cameraPos.Value.p)
				ThrustDirection = Vector3.new(ThrustDirection.X,0,ThrustDirection.Z).unit
				--myTorso.CFrame = CFrame.new(myTorso.CFrame.p,myTorso.CFrame.p+ThrustDirection)
				bgyro.cframe = CFrame.new(Vector3.new(0,0,0),ThrustDirection)
				wait(1/30)
			end
			bgyro:Destroy()
		end)
		--ThrustDirection = ((targetOverride or TargetPosition.Value) - MyModel.Torso.CFrame.p).unit
	else -- Player just released click
		Tool.Enabled = false
		MouseDownLength = tick() - MouseDownTime
		MouseDown = false
		TouchEnabled = true
		ThrustAttack(ThrustDirection)
		MyModel.Humanoid.WalkSpeed = 16
		wait(BASE_COOLDOWN*math.min(math.max(MouseDownLength,1),3))

		Tool.Enabled = true
	end
end

-- Also activate when the Action Button is pressed
local function OnChildAdded(child)
	if child.Name == 'ActionButtonData' then
		child.Changed:connect(function(newValue)
			local bindable = child:FindFirstChild('GetTargetPosition')
			if bindable then
				if string.sub(newValue, 1, 1) == 'v' then -- Button down
					OnMouseDownChanged(true)
				elseif string.sub(newValue, 1, 1) == '^' then  -- Button up
					OnMouseDownChanged(false)
				end
			end
		end)
	end
end

--------------------
--| Script Logic |--
--------------------

Tool.Equipped:connect(OnEquipped)
Tool.Unequipped:connect(OnUnequipped)
MouseDownObject.Changed:connect(OnMouseDownChanged)
Tool.ChildAdded:connect(OnChildAdded) --NOTE: Added for Action Button
Handle.Touched:connect(OnTouch)
