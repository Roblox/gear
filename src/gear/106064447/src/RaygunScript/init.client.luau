-- SolarCrane

-- Waits for parent.child to exist, then returns it
local function WaitForChild(parent, childName)
	assert(parent, "ERROR: WaitForChild: parent is nil")
	while not parent:FindFirstChild(childName) do parent.ChildAdded:wait() end
	return parent[childName]
end

--local tool = Game.Selection:Get()[1]; tool.Grip = CFrame.new(0,-0.4,1.15)

local DebrisService = Game:GetService('Debris')
local PlayersService = Game:GetService('Players')
local contentProvider = game:GetService("ContentProvider")

local Tool = script.Parent
local Handle = WaitForChild(Tool, 'Handle')

local AnimationScript
local StartAnim
local StopAnim

local HeartScript

local MyMouse
local MyTorso
local MyHumanoid
local MyPlayer
local MyCharacter

local HitSound
local ShootSound

local SHOOT_DAMAGE_MIN = 25
local SHOOT_DAMAGE_MAX = 45
local SWING_TIME = 1.3
local LASER_TIME = 0.12
local MAX_SHOOT_DISTANCE = 120
local rate=1/30

local BASE_URL = contentProvider.BaseUrl
local AmmoTXId = BASE_URL .. 'asset/?id=105977933'
local AmmoMeshId = BASE_URL .. 'asset/?id=105992239'

local AmmoPrefab = Instance.new('Part')
AmmoPrefab.FormFactor = 'Custom'
AmmoPrefab.Size = Vector3.new(1, 1, 0.2)
AmmoPrefab.Locked = true
AmmoPrefab.TopSurface = 'Smooth'
AmmoPrefab.BottomSurface = 'Smooth'
AmmoPrefab.CanCollide = false
AmmoPrefab.Transparency = 0.25
AmmoPrefab.Name = 'Heart'


local AmmoMesh = Instance.new('SpecialMesh')
AmmoMesh.TextureId = AmmoTXId
AmmoMesh.MeshId = AmmoMeshId
AmmoMesh.Scale = Vector3.new(1.5,1.5,1.2)
-- Lets run randomize this from the range of (1,1,1) to (1,0,0) to add a little variation
AmmoMesh.VertexColor = Vector3.new(1,1,1)
AmmoMesh.Parent = AmmoPrefab

local SCALE_TO_STUD = 5.3 / 2

local CreatorTag

function ApplyTag(target)
	while target:FindFirstChild('creator') do
		target.creator:Destroy()
	end
	CreatorTag:Clone().Parent = target
end

function FindCharacter(part)
	if part.Parent == nil or part == Workspace then return nil end
	if part:FindFirstChild('Humanoid') then return part end
	return FindCharacter(part.Parent)
end

function RayIgnoreCheck(hit, pos)
	if hit then
		if hit.Transparency >= 1 or string.lower(hit.Name) == "water" or
				hit.Name == "Effect" or hit.Name == "Rocket" or hit.Name == "Bullet" or
				hit.Name == "Handle" or hit:IsDescendantOf(MyCharacter) then
			return true
		end
	end
	return false
end

-- @preconditions: vec should be a unit vector, and 0 < rayLength <= 1000
function RayCast(startPos, vec, rayLength)
	local hitObject, hitPos = game.Workspace:FindPartOnRay(Ray.new(startPos + (vec * .01), vec * rayLength), Handle)
	if hitObject and hitPos then
		local distance = rayLength - (hitPos - startPos).magnitude
		if RayIgnoreCheck(hitObject, hitPos) and distance > 0 then
			-- there is a chance here for potential infinite recursion
			return RayCast(hitPos, vec, distance)
		end
	end
	return hitObject, hitPos
end


function StartGuiRecharge()
	if PlayerGui and PlayerGui:FindFirstChild('Bar') and
			PlayerGui.Bar:FindFirstChild('Backing') and PlayerGui.Bar:FindFirstChild('Fill') and
			PlayerGui:FindFirstChild('RechargeText') then
		PlayerGui.RechargeText.Text = "Recharging..."
		local timeRemaining = math.min(COOLDOWN_TIME, tick() - LastUse)
		print('Start Size = ', timeRemaining / COOLDOWN_TIME)
		PlayerGui.Bar.Fill.Size = UDim2.new(timeRemaining / SWING_TIME, 0, 1, 0)
		PlayerGui.Bar.Fill:TweenSize(UDim2.new(1,0,1,0), "Out", "Linear", SWING_TIME - timeRemaining, false,
			function() if PlayerGui then PlayerGui.RechargeText.Text = "Ready" end end)
	end
end

function billboard(pos,text,timeVar,color)
	local pos=pos or Vector3.new(0,0,0)
	local text=text or "Hello World!"
	local timeVar = timeVar or 2
	local color=color or Color3.new(1,0,0)
	local pos=pos+Vector3.new(0,5,0)
	local ep=Instance.new("Part")
	ep.Name="Effect"
	ep.formFactor="Custom"
	ep.Size=Vector3.new(0,0,0)
	ep.TopSurface="Smooth"
	ep.BottomSurface="Smooth"
	ep.CFrame=CFrame.new(pos)
	ep.Anchored=true
	ep.CanCollide=false
	ep.Transparency=1
	local bb=Instance.new("BillboardGui")
	bb.Size=UDim2.new(3,0,3,0)
	bb.Adornee=ep
	local tl=Instance.new("TextLabel")
	tl.BackgroundTransparency=1
	tl.Size=UDim2.new(1,0,1,0)
	tl.Text=text
	tl.TextColor3=color
	tl.TextScaled=true
	tl.Font="ArialBold"

	tl.Parent=bb
	bb.Parent=ep
	DebrisService:AddItem(ep,timeVar+.1)
	ep.Parent=game.Workspace
	delay(0,function()
		local frames=timeVar/rate
		for frame=1,frames do
			wait(rate)
			local percent=frame/frames
			ep.CFrame=CFrame.new(pos)+Vector3.new(0,5*percent,0)
			tl.TextTransparency=percent
		end
		ep:remove()
	end)
end

local HitHumanoids = {}
function OnHit(hitPart)
	if hitPart then
		local char = FindCharacter(hitPart)
		local humanoid = char and char:FindFirstChild('Humanoid')
		if humanoid ~= MyHumanoid and humanoid and not HitHumanoids[humanoid] and
					MyHumanoid.Health > 0 and humanoid.Health > 0 and
					MyCharacter and MyCharacter:FindFirstChild('Right Arm') then
			ApplyTag(humanoid)
			HitHumanoids[humanoid] = true
			-- maybe we display this above head
			local swingDamage = SHOOT_DAMAGE_MIN + math.random(SHOOT_DAMAGE_MAX - SHOOT_DAMAGE_MIN)

			billboard(hitPart.Position,"-"..tostring(swingDamage))
			humanoid:TakeDamage(swingDamage)
			wait(0.1)
			if HitSound then
				HitSound:Play()		
			end
			if HeartScript and char:FindFirstChild('Torso') then
				local newHeart = HeartScript:Clone()
				newHeart.Parent = char.Torso
				newHeart.Disabled = false
			end
		end		
	end	
end

local Attacking = false
function OnActivated()
	if (Attacking or MyHumanoid.Health <= 0) or not MyCharacter:FindFirstChild('Right Arm') or not MyMouse then return end
	Attacking = true
	Tool.Enabled = false
	if ShootSound then
		ShootSound:Play()
	end
	HitHumanoids = {}
	--StartAnim:Invoke('AttackAnim')
	local target, hitPos = RayCast(Handle.CFrame.p, (MyMouse.Hit.p - Handle.CFrame.p).unit, 250)
	--local target = MyMouse.Target
	local shootDistance =  MAX_SHOOT_DISTANCE
	--local hitPos = MyMouse.Hit.p
	if target and (target.CFrame.p - Handle.CFrame.p).magnitude < MAX_SHOOT_DISTANCE then
		OnHit(target)		
	end
	--[[
	local posCFrame = CFrame.new(Handle.CFrame.p, hitPos)
	local raCFrame = MyCharacter:FindFirstChild('Right Arm').CFrame
	posCFrame = (posCFrame - posCFrame.p) *  ((raCFrame - raCFrame.p) * CFrame.Angles(math.pi/2, 0, 0)) :inverse()
	Tool.Grip = posCFrame
	--]]
	local heartClone = AmmoPrefab:Clone()
	heartClone.Anchored = true
	local startPos = Handle.CFrame.p + Handle.CFrame:vectorToWorldSpace(Vector3.new(0, 0.225, -1.3))
	shootDistance = math.min(MAX_SHOOT_DISTANCE, (startPos - hitPos).magnitude)
	heartClone.CFrame = CFrame.new(startPos, hitPos) * CFrame.Angles(0, math.pi, 0)
	--local hsClone =	HeartScript:Clone()
	--hsClone.Parent = heartClone
	--hsClone.Disabled = false
	-- weld heartClone to gun
	--[[
	local weld = 	Instance.new('ManualWeld')
	weld.Part0 = Handle;
	weld.Part1 = heartClone;
	weld.C0 = CFrame.Angles(0, math.pi, 0) * CFrame.new(0, 0.225, 1.3)
	weld.Parent = heartClone
	--]]
	if heartClone:FindFirstChild('Mesh') then
		heartClone.Mesh.Scale = Vector3.new(1.5,1.5,1)
	end
	heartClone.Parent = Workspace
	DebrisService:AddItem(heartClone, 10)
	Spawn(function()
		for i = 1, 20 do
			wait()
			if heartClone and heartClone:FindFirstChild('Mesh') then
				heartClone:FindFirstChild('Mesh').Scale =
					heartClone:FindFirstChild('Mesh').Scale + Vector3.new(0, 0, MAX_SHOOT_DISTANCE * SCALE_TO_STUD / 10)
			end
		end
		wait(0.1)
		heartClone.CFrame = heartClone.CFrame * CFrame.Angles(0, math.pi, 0) +
			heartClone.CFrame:vectorToWorldSpace(Vector3.new(0,0,245 / 2))
			--heartClone.CFrame:vectorToWorldSpace(Vector3.new(0,0,MAX_SHOOT_DISTANCE * SCALE_TO_STUD/2))
		for i = 1, 20 do
			wait()
			if heartClone and heartClone:FindFirstChild('Mesh') then
				heartClone:FindFirstChild('Mesh').Scale =
					heartClone:FindFirstChild('Mesh').Scale - Vector3.new(0, 0, MAX_SHOOT_DISTANCE * SCALE_TO_STUD/ 10)
			end
		end	
		heartClone:Destroy()
	end)
	
	
	wait(0.33)
	--[[
	local spin = Instance.new("BodyAngularVelocity")
	DebrisService:AddItem(spin, 0.3)
	spin.angularvelocity = Vector3.new(0, -30, 0)
	spin.maxTorque = Vector3.new(0, 300000, 0)
	spin.Parent = MyTorso
	wait(0.3)
	if spin then
		spin:Destroy()
	end
	--]]
	wait(SWING_TIME - 0.33 - 0.3)
	
	Tool.Enabled = true
	Attacking = false
end


local Equipping = false
function OnEquipped(mouse)
	if Equipping then return end
	Equipping = true
	MyCharacter = Tool.Parent
	MyPlayer = PlayersService:GetPlayerFromCharacter(MyCharacter)
	MyTorso = MyCharacter:FindFirstChild('Torso')
	MyMouse = mouse
	MyHumanoid = MyCharacter:FindFirstChild('Humanoid')

	CreatorTag = Instance.new('ObjectValue')
	CreatorTag.Name = 'creator' --NOTE: Must be called 'creator' for website stats
	CreatorTag.Value = MyPlayer	

	AnimationScript = WaitForChild(Tool,'AnimationScript')
	StartAnim = WaitForChild(AnimationScript, 'Start')
	StopAnim = WaitForChild(AnimationScript, 'Stop')
	
	ShootSound = WaitForChild(Handle, 'Shoot')
	HitSound = WaitForChild(Handle, 'Hit')
	
	HeartScript = WaitForChild(script, 'HeartScript')
	
	
	--StartAnim:Invoke('IdleAnim', 0.5)
	Equipping = false
end

local UnEquipping = false
function OnUnequipped()
	if UnEquipping then return end
	UnEquipping = true
	if PlayerGui then
		PlayerGui:Destroy()
		PlayerGui = nil
	end
	UnEquipping = false
end


Tool.Equipped:connect(OnEquipped)
Tool.Unequipped:connect(OnUnequipped)
Tool.Activated:connect(OnActivated)
