-- SolarCrane

-- Waits for parent.child to exist, then returns it
local function WaitForChild(parent, childName)
	assert(parent, "ERROR: WaitForChild: parent is nil")
	while not parent:FindFirstChild(childName) do parent.ChildAdded:wait() end
	return parent[childName]
end

--local tool = Game.Selection:Get()[1]; tool.Grip = CFrame.new(0,-2.3,0) * CFrame.Angles(0, math.pi/2, 0)

local DebrisService = Game:GetService('Debris')
local PlayersService = Game:GetService('Players')
local contentProvider = game:GetService("ContentProvider")

local Tool = script.Parent
local Handle = WaitForChild(Tool, 'Handle')

local AnimationScript
local StartAnim
local StopAnim


local MyMouse
local MyTorso
local MyHumanoid
local MyPlayer
local MyCharacter

local HitSound
local SwingSound
local EnrageSound

local SWORD_DAMAGE_MIN = 35
local SWORD_DAMAGE_MAX = 65
local SWING_TIME = 1.3


local rate=1/30

local BASE_URL = contentProvider.BaseUrl

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
		if humanoid ~= MyHumanoid and humanoid and not HitHumanoids[humanoid] and MyHumanoid.Health > 0 and humanoid.Health > 0 then
			ApplyTag(humanoid)
			HitHumanoids[humanoid] = true
			-- maybe we display this above head
			local swingDamage = SWORD_DAMAGE_MIN + math.random(SWORD_DAMAGE_MAX - SWORD_DAMAGE_MIN)
			if humanoid.Health <= swingDamage then
				StartAnim:Invoke('Enrage')
				EnrageSound:Play()		
			end
			
			billboard(hitPart.Position,"-"..tostring(swingDamage))
			humanoid:TakeDamage(swingDamage)
			if HitSound then
				HitSound:Play()
			end
		end		
	end	
end

local Attacking = false
function OnActivated(target)
	if (Attacking or MyHumanoid.Health <= 0) or not MyCharacter:FindFirstChild('Right Arm') then return end
	Attacking = true
	Delay(0.2, function()
		if SwingSound then
			SwingSound:Play()
		end
	end)
	HitHumanoids = {}
	StartAnim:Invoke('AttackAnim')
	local touchConn =	Handle.Touched:connect(OnHit)
	wait(0.33)
	local spin = Instance.new("BodyAngularVelocity")
	DebrisService:AddItem(spin, 0.3)
	spin.angularvelocity = Vector3.new(0, -30, 0)
	spin.maxTorque = Vector3.new(0, 300000, 0)
	spin.Parent = MyTorso
	wait(0.3)
	if spin then
		spin:Destroy()
	end
	wait(SWING_TIME - 0.33 - 0.3)
	touchConn:disconnect()
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
	
	SwingSound = WaitForChild(Handle, 'Swing')
	HitSound = WaitForChild(Handle, 'Hit')
	EnrageSound = WaitForChild(Handle, 'Rage')
	ToolGui = WaitForChild(Tool, 'RechargeGui')
	
	StartGuiRecharge()
	
	StartAnim:Invoke('IdleAnim', 0.5)
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


Tool.Activated:connect(OnActivated)
Tool.Equipped:connect(OnEquipped)
Tool.Unequipped:connect(OnUnequipped)
