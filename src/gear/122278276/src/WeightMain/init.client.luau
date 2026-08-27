local Tool = script.Parent
local Handle = Tool:WaitForChild('Handle')
local WeightScript = Tool:WaitForChild('WeightScript')
local Player;
local Character;
local Humanoid;
local Torso;

local RELOAD_TIME = 1.5

local Equipped = false
local LastUse = Tool:WaitForChild('LastUse')

local ANIM_Equip;
local ANIM_Swing;

local SOUND_Swish = Handle:WaitForChild('SOUND_Swish')

function CreateWeight()
	local weightModel = Instance.new('Model')
	weightModel.Name = 'ThrownWeight'
	--
	local weight = Handle:Clone()
	local rotVelo = weight.RotVelocity
	weight:WaitForChild('creator').Value = Player
	weight.CanCollide = false
	weight.Parent = weightModel
	weight.CFrame = weight.CFrame + Torso.CFrame.lookVector*3
	--
	local force = Instance.new('BodyVelocity', weight)
	force.Name = 'Mover'
	force.maxForce = Vector3.new(100000,100000,100000)
	force.velocity = Vector3.new(0,0,0)
	--
	local endOne = Instance.new('Part', weightModel)
	endOne.Shape = 'Ball'
	endOne.Size = Vector3.new(3,3,3)
	endOne.Name = 'EndOne'
	endOne.TopSurface = 'Smooth'
	endOne.BottomSurface = 'Smooth'
	endOne.Transparency = 1
	endOne.CanCollide = false
	endOne.RotVelocity = rotVelo
	endOne.CFrame = weight.CFrame*CFrame.new(3,0,0)
	--
	local endTwo = endOne:Clone()
	endTwo.Name = 'EndTwo'
	endTwo.Parent = weightModel
	endTwo.CFrame = weight.CFrame*CFrame.new(-3,0,0)
	--
	local w = Instance.new('Weld', weight)
	w.Part0 = weight
	w.Part1 = endOne
	w.C0 = CFrame.new(3,0,0)
	--
	local w = Instance.new('Weld', weight)
	w.Part0 = weight
	w.Part1 = endTwo
	w.C0 = CFrame.new(-3,0,0)
	--
	local sc = WeightScript:Clone()
	weight.creator.Parent = sc
	sc.Disabled = false
	sc.Parent = weightModel
	--
	weightModel.Parent = game.Workspace
	--
	return weightModel
end

function ThrowWeight()
	local weight = CreateWeight()
	--
	local handle = weight.Handle
	handle.Mover.velocity = (Torso.CFrame*CFrame.Angles(0.3,0,0)).lookVector*50 + Handle.Velocity
end

Tool.Equipped:connect(function(mouse)
	Equipped = true
	Character = Tool.Parent
	Player = game.Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:WaitForChild('Humanoid')
	Torso = Character:WaitForChild('Torso')
	--
	ANIM_Equip = Humanoid:LoadAnimation(Tool:WaitForChild('ANIM_Equip'))
	ANIM_Swing = Humanoid:LoadAnimation(Tool:WaitForChild('ANIM_Swing'))
	--
	ANIM_Equip:Play(0)
	--
	Handle.Transparency = 0
	--
	mouse.Button1Down:connect(function()
		if (Workspace.DistributedGameTime - LastUse.Value) < RELOAD_TIME then return end
		LastUse.Value = Workspace.DistributedGameTime
		--
		ANIM_Swing:Play(0)
		Delay(0.3, function()
			SOUND_Swish:Play(0)
		end)
		repeat until ANIM_Swing.KeyframeReached:wait() == 'Throw'
		--
		ThrowWeight()
		Handle.Transparency = 1
		--
		wait(0.5)
		for i = 1, 0, -0.03 do 
			wait()
			if not Equipped then break end
			Handle.Transparency = i
		end
		--
		Handle.Transparency = 0
	end)
	--
	while Equipped do
		if (Workspace.DistributedGameTime - LastUse.Value) < RELOAD_TIME then
			mouse.Icon = 'rbxasset://textures\\GunWaitCursor.png'
		else
			mouse.Icon = 'rbxasset://textures\\GunCursor.png'
		end
		wait()
	end
end)

Tool.Unequipped:connect(function()
	Equipped = false
	if ANIM_Equip then ANIM_Equip:Stop() end
	if ANIM_Swing then ANIM_Swing:Stop() end
end)