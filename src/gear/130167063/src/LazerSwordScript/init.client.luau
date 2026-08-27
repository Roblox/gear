local DAMAGE = 50;
local COOLDOWN_TIME = 1.5;

local DEBUG_PRINTING = true
function dPrint(...)
	if DEBUG_PRINTING then
		print(...)
	end
end


function New(ty)
	return function(data)
		local obj = Instance.new(ty)
		for k, v in pairs(data) do
			if type(k) == 'number' then
				v.Parent = obj
			else
				if type(v) == 'function' then
					obj[k]:connect(v)
				else
					obj[k] = v
				end
			end
		end
		return obj
	end
end

local CubeScript = nil
local Tool = script.Parent
local Handle =  nil;
local MyCharacter = nil
local MyPlayer = nil
local MyTorso = nil
local MyHumanoid = nil
local PlayersService = Game:GetService('Players')
local DebrisService = Game:GetService('Debris')

local AnimScript = Tool:WaitForChild('AnimationScript')
local StartAnim = AnimScript:WaitForChild('Start')
local StopAnim = AnimScript:WaitForChild('Stop')

local AxisVectors =
{	
}
do
	for val = -1, 1, 2 do
		table.insert(AxisVectors, Vector3.new(val, 0, 0))
	end
	for val = -1, 1, 2 do
		table.insert(AxisVectors, Vector3.new(0, val, 0))
	end
	for val = -1, 1, 2 do
		table.insert(AxisVectors, Vector3.new(0, 0, val))
	end
end

function FindCharacterAncestor(part)
	if part and part ~= Workspace then
		local humanoid = part:FindFirstChild('Humanoid')
		if part:IsA('Model') and humanoid and humanoid:IsA('Humanoid') then
			return part, humanoid
		end
		return FindCharacterAncestor(part.Parent)
	end	
end

function GetRandomFloat(low, high)
	assert(low < high, "GetRandomFloat: Low is larger than high.")
	local rand = math.random()
	rand = rand * (high - low)
	return (rand + low)
end

function MotorizeWeld()
	
end

-- Removes any old creator tags and applies new ones to the specified target
function ApplyTags(target)
	while target:FindFirstChild('creator') do
		target.creator:Destroy()
	end

	local creatorTag = Instance.new('ObjectValue')
	creatorTag.Value = MyPlayer
	creatorTag.Name = 'creator' --NOTE: Must be called 'creator' for website stats
	creatorTag.Parent = target
	DebrisService:AddItem(creatorTag, 4)
end

function CreateCube(pos)
	local newCube = New'Part'
	{
		Name = 'Cube';
		FormFactor = 'Custom';
		Size = Vector3.new(2,2,2);
		BrickColor = BrickColor.new('Teal');
		CFrame = CFrame.new(pos);
		TopSurface = 'Smooth';
		BottomSurface = 'Smooth';
		CanCollide = false;
		Anchored = true;
		New'PointLight'
		{
			Color = Color3.new(30/255, 234/255, 255/255);
			Brightness = 6;
		};
	}
	return newCube
end
local Attacking = false
local HitHumanoids = {}
function OnTouched(hitPart)
	if not Attacking then return end
	local hitCharacter, hitHumanoid = FindCharacterAncestor(hitPart)
	if hitCharacter and hitCharacter ~= MyCharacter and not HitHumanoids[hitHumanoid] and MyHumanoid and MyHumanoid.Health > 0 then
		HitHumanoids[hitHumanoid] = true
		if Handle and Handle:FindFirstChild('Hit') then
			Handle.Hit:Play()
		end
		if MyTorso and CubeScript and MyPlayer and Handle and hitHumanoid.Health > 0 then
			--for _, vec in pairs(AxisVectors) do
			for i = 1, 3 do
				local vec = AxisVectors[math.random(1, #AxisVectors)]
				local newCube = CreateCube(Handle.CFrame.p + (MyTorso.CFrame.lookVector * 0.25))-- + Vector3.new(GetRandomFloat(-0.5, 0.5),GetRandomFloat(-0.5, 0.5),GetRandomFloat(-0.5, 0.5)))
				newCube.Velocity = vec
				newCube.Parent = Workspace
				local newCubeScript = CubeScript:Clone()
				newCubeScript.Parent = newCube
				local cubeScriptOwner = newCubeScript:WaitForChild('Owner')
				cubeScriptOwner.Value = MyPlayer
				newCubeScript.Disabled = false
			end
		end
		hitHumanoid:TakeDamage(DAMAGE * GetRandomFloat(0.5, 1.5))
		ApplyTags(hitHumanoid)
	end
end

function OnActivated()
	if not Tool.Enabled then return end
	if MyHumanoid and MyHumanoid.Health > 0 then
		Tool.Enabled = false
		Attacking = true
		HitHumanoids = {}
		StartAnim:Invoke('AttackAnim')
		if Handle and Handle:FindFirstChild('Swing') then
			Handle.Swing:Play()
		end
		wait(0.8)
		Attacking = false
		wait(COOLDOWN_TIME - 0.8)
		Tool.Enabled = true
	end
end
local equipping = false
function OnEquipped(mouse)
	if equipping then return end
	equipping = true
	MyCharacter = Tool.Parent
	MyPlayer = MyCharacter and PlayersService:GetPlayerFromCharacter(MyCharacter)
	MyTorso = MyCharacter and MyCharacter:FindFirstChild('Torso')
	MyHumanoid = MyCharacter:WaitForChild('Humanoid')
	Handle = Tool:WaitForChild('Handle')
	CubeScript = script:WaitForChild('CubeScript')
	Handle.Touched:connect(OnTouched)
	StartAnim:Invoke('IdleAnim')
	MyHumanoid.WalkSpeed = MyHumanoid.WalkSpeed + 6
	equipping = false
end

function OnUnequipped()
	StopAnim:Invoke('IdleAnim')
	MyHumanoid.WalkSpeed = MyHumanoid.WalkSpeed - 6
end


Tool.Activated:connect(OnActivated)
Tool.Equipped:connect(OnEquipped)
Tool.Unequipped:connect(OnUnequipped)
