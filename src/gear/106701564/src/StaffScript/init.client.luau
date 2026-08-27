-- SolarCrane

-- Waits for parent.child to exist, then returns it
local function WaitForChild(parent, childName)
	assert(parent, "ERROR: WaitForChild: parent is nil")
	--print("waiting for:" , childName)
	while not parent:FindFirstChild(childName) do parent.ChildAdded:wait() end
	--print("Got:", childName)
	return parent[childName]
end

--local tool = Game.Selection:Get()[1]; tool.Grip = CFrame.new(0,-2.3,0) * CFrame.Angles(0, math.pi/2, 0)

local DebrisService = Game:GetService('Debris')
local PlayersService = Game:GetService('Players')
local contentProvider = game:GetService("ContentProvider")
local InsertService = Game:GetService("InsertService")

local Tool = script.Parent
local Handle = WaitForChild(Tool, 'Handle')

local AnimationScript
local StartAnim
local StopAnim

-- Switch this to insertservice at some point
local RatPrefab = InsertService:LoadAsset(106690606):GetChildren()[1] --WaitForChild(Game.Lighting, 'Rat')
local RatController = WaitForChild(script, 'RatController')

local MyMouse
local MyTorso
local MyHumanoid
local MyPlayer
local MyCharacter


local Claw = WaitForChild(Tool, 'Claw')
local OrbWeld = WaitForChild(Claw, 'ManualWeld')
local ClawMotor = WaitForChild(Handle, 'Motor6D')
local Orb = WaitForChild(Tool, 'Orb')
local Sparkles = WaitForChild(Orb, 'Sparkles')

local SummonSounds = {WaitForChild(Handle, 'Summon1'), WaitForChild(Handle, 'Summon2'), WaitForChild(Handle, 'Summon3')}

local COOLDOWN_TIME = 4

local Rats = {}

local RATS_PER_SUMMON = 5
local MAX_RATS_OUT = 13

local rate=1/30

local BASE_URL = 'http://www.roblox.com/asset/?id=' --contentProvider.BaseUrl

local StaffMesh = '106677074'
local OrbMesh = '106677090'
local ClawMesh = '106677103'

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



local Attacking = false
function OnActivated()
	local hitPos = MyMouse.Hit
	if (Attacking or MyHumanoid.Health <= 0) or not MyCharacter:FindFirstChild('Right Arm') then return end
	Attacking = true
	Tool.Enabled = false
	if ClawMotor then
		ClawMotor.MaxVelocity = 0.3
	end
	Spawn(function()
		for i = 1, 10 do wait()
			if OrbWeld then
				OrbWeld.C0 = OrbWeld.C0 + Vector3.new(0,.1,0)
			end
		end end)
	if Sparkles then
		Sparkles.Enabled = true
	end
	StartAnim:Invoke('AttackAnim')
	SummonSounds[math.random(1,#SummonSounds)]:Play()
	local sortedRatList = {}
	for rat, creationTime in pairs(Rats) do
		if (rat == nil) or (rat:FindFirstChild('Torso') == nil) or (rat:FindFirstChild('Head') == nil) then
			Rats[rat] = nil
			rat:Destroy()
		else
			table.insert(sortedRatList, rat)
		end
	end
	table.sort(sortedRatList, function(a, b) return Rats[a] < Rats[b] end)

	local numRatsToDestroy = math.max(0, (#sortedRatList + RATS_PER_SUMMON) - MAX_RATS_OUT)

	--print("Num of sorted rats: ", #sortedRatList , " num of rats to destroy: " , numRatsToDestroy)

	for i = 1, numRatsToDestroy do
		local deadRat = sortedRatList[i]
		if deadRat and Rats[deadRat] then
			--print("Deleting rat at"..i..": " , deadRat.Name)
			deadRat:Destroy()
			Rats[deadRat] = nil
		end
	end

	for i = 1, RATS_PER_SUMMON do
		if RatPrefab then
			local newRat = RatPrefab:Clone()
			local newController = RatController:Clone()
			ApplyTag(newController)
			newController.Parent = newRat
			newController.Disabled = false
			Rats[newRat] = tick()
			WaitForChild(newRat, 'Torso')
			-- Might want to do a better method of finding free areas.
			newRat.Torso.CFrame = hitPos + CFrame.Angles(0, math.random() * math.pi * 2, 0) * Vector3.new(i + math.random(),5, i + math.random())
			newRat.Torso.CFrame = newRat.Torso.CFrame * CFrame.Angles(0, math.random() * math.pi * 2, 0)
			newRat.Parent = Workspace
		end
	end


	wait(COOLDOWN_TIME)
	for i = 1, 10 do wait()
		if OrbWeld then
			OrbWeld.C0 = OrbWeld.C0 - Vector3.new(0,.1,0)
		end
	end
	if Sparkles then
		Sparkles.Enabled = false
	end
	if ClawMotor then
		ClawMotor.MaxVelocity = 0.1
	end
	Tool.Enabled = true
	Attacking = false
end


local Equipping = false
function OnEquipped(mouse)
	print("Getting new mouse")
	MyMouse = mouse
	if Equipping then return end
	Equipping = true
	ClawMotor.CurrentAngle = 0
	ClawMotor.DesiredAngle = 1000000
	ClawMotor.MaxVelocity = 0.1
	MyCharacter = Tool.Parent
	MyPlayer = PlayersService:GetPlayerFromCharacter(MyCharacter)
	MyTorso = MyCharacter:FindFirstChild('Torso')
	MyHumanoid = MyCharacter:FindFirstChild('Humanoid')

	CreatorTag = Instance.new('ObjectValue')
	CreatorTag.Name = 'creator' --NOTE: Must be called 'creator' for website stats
	CreatorTag.Value = MyPlayer	

	AnimationScript = WaitForChild(Tool,'AnimationScript')
	StartAnim = WaitForChild(AnimationScript, 'Start')
	StopAnim = WaitForChild(AnimationScript, 'Stop')
	wait(0.5)
	if Tool:IsDescendantOf(Workspace) then
		StartAnim:Invoke('IdleAnim', 0.5)
	end
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
	for rat, _ in pairs(Rats) do
		rat:Destroy()
	end
	Sparkles.Enabled = false
	UnEquipping = false
end


Tool.Activated:connect(OnActivated)
Tool.Equipped:connect(OnEquipped)
Tool.Unequipped:connect(OnUnequipped)
