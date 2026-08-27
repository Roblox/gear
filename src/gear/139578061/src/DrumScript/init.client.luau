local Tool = script.Parent
local Handle = Tool:WaitForChild('Handle')
local HandleTouchConn = nil
local MyCharacter = nil
local MyHumanoid = nil
local MyPlayer = nil
local Players = Game:GetService('Players')
local Cleaner = script:WaitForChild('Cleaner')
local Ragdoller = script:WaitForChild('Ragdoller')
local Rimshot = Handle:WaitForChild('Rimshot')


local function New(ty)
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

local Animations = {}
local function PlayAnimation(animationName, speed)
	speed = speed or 1
	if Animations[animationName] then
		Animations[animationName]:Play(0.1, 1, speed)
	else
		print("Can't find animation:" , animationName)
	end
end

local function StopAnimation(animationName)
	if Animations[animationName] then
		Animations[animationName]:Stop()
	end
end

local function LoadAnimation(animationObject)
	if MyHumanoid then
		Animations[animationObject.Name] = MyHumanoid:LoadAnimation(animationObject)
	else
		print("Tried to load an anim without a humanoid")
	end
end


local function FindCharacterAncestor(part)
	if part then
		if part:FindFirstChild('Humanoid') then
			return part
		end
		return FindCharacterAncestor(part.Parent)
	end
end

local function CreateDrum()
	local drum = New'Part'
	{
		TopSurface = 'Smooth';
		BottomSurface = 'Smooth';
		FormFactor = 'Custom';
		CanCollide = true;
		Name = 'Drum';
		Size = Vector3.new(4,2.5,4);
		Shape = 'Ball';
		New'SpecialMesh'
		{
			MeshId = 'http://www.roblox.com/asset/?id=139468173';
			TextureId = 'http://www.roblox.com/asset/?id=139432181';
			Scale = Vector3.new(2,2,2);
		}
	}
	return drum
end

local function WeldDrum(drum, torso)
	if drum and torso then
		local weld = New'Weld'
		{
			Name = 'DrumWeld';
			Part0 = drum;
			Part1 = torso;
			C0 = (CFrame.new() + Vector3.new(0, 0.2, 0)) * CFrame.Angles(-math.pi * 0.4, 0, 0);
			C1 = CFrame.new();
		}
		weld.Parent = drum
	else
		print("WeldDrum: Invalid drum or torso")
	end
end

local function DisconnectTouch()
	if HandleTouchConn then
		HandleTouchConn:disconnect()
		HandleTouchConn = nil
	end
end

local function OnTouched(hitPart)
	local hitCharacter = FindCharacterAncestor(hitPart)
	if MyHumanoid and MyHumanoid.Health > 0 and hitCharacter and hitCharacter ~= MyCharacter then
		local drum = CreateDrum()
		local torso = hitCharacter:FindFirstChild('Torso')
		local hitHumanoid = hitCharacter:FindFirstChild('Humanoid')
		if torso and hitHumanoid and hitHumanoid.Health > 0 and not hitCharacter:FindFirstChild('Drum') then
			local clonedCleaner = Cleaner:Clone()
			local clonedRagdoller = Ragdoller:Clone()
			drum.Parent = hitCharacter
			clonedRagdoller.Parent = hitCharacter
			clonedRagdoller.Disabled = false
			clonedCleaner.Parent = drum
			clonedCleaner.Disabled = false
			WeldDrum(drum, torso)
			if Rimshot then
				Rimshot:Play()
			end			
			torso.RotVelocity = Vector3.new(0.5, 0.1, 0.3)
			DisconnectTouch()
		end
	end
end

local function OnActivated()
	if not Tool.Enabled then return end
	Tool.Enabled = false
	PlayAnimation('Swing', 0.8)
	wait(0.2)	
	HandleTouchConn = Handle.Touched:connect(OnTouched)
	wait(0.5)
	DisconnectTouch()
	wait(2)
	Tool.Enabled = true
end


local AnimConn = nil
local function OnEquipped(mouse)
	MyCharacter = Tool.Parent
	MyHumanoid = MyCharacter:FindFirstChild('Humanoid')
	MyPlayer = Players:GetPlayerFromCharacter(MyCharacter)
	
	
	AnimConn = Tool.ChildAdded:connect(function (child)
		if child:IsA('Animation') then
			LoadAnimation(animationObject)
		end
	end)
	for _, child in pairs(Tool:GetChildren()) do
		if child:IsA('Animation') then
			LoadAnimation(child)
		end
	end
end

local function OnUnequipped()
	DisconnectTouch()
	if Rimshot then
		Rimshot:Stop()
	end
	for name, animTrack in pairs(Animations) do
		StopAnimation(name);
	end
	if AnimConn then
		AnimConn:disconnect()
		AnimConn = nil
	end
end

do
	Tool.Activated:connect(OnActivated)
	Tool.Equipped:connect(OnEquipped)
	Tool.Unequipped:connect(OnUnequipped)
end
