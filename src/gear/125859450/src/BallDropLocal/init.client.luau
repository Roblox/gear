local Tool = script.Parent
local Handle = Tool:WaitForChild('Handle')
local Player;
local Torso;
local Character;
local Humanoid;

local ANIM_Equip;
local ANIM_Throw;
local SOUND_Throw = Handle:WaitForChild('SOUND_Throw')

local RELOAD_TIME = 7
local RANGE = 200

local LastThrown = Tool:WaitForChild('LastThrown')

local PoleScript = Tool:WaitForChild('PoleScript')

local function tm()
	return Workspace.DistributedGameTime
end

local function Slerp(t, a, b)
	local om = math.acos(math.min(1, a.unit:Dot(b.unit)))
	if om < 0.01 then
		return (1-t)*a +
		          t *b
	else
		return (math.sin((1-t)*om)/math.sin(om))*a +
		       (math.sin(   t *om)/math.sin(om))*b
	end
end


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

Tool.Equipped:connect(function(mouse)
	Character = Tool.Parent
	Player = game.Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:WaitForChild('Humanoid')
	Torso = Character:WaitForChild('Torso')
	--
	ANIM_Equip = Humanoid:LoadAnimation(Tool:WaitForChild('ANIM_Equip'))
	ANIM_Throw = Humanoid:LoadAnimation(Tool:WaitForChild('ANIM_Throw'))
	--
	ANIM_Equip:Play()
	--
	if (tm()-LastThrown.Value) > RELOAD_TIME then
		Handle.Transparency = 0
		mouse.Icon = 'rbxasset://textures\\GunCursor.png'
	else
		Handle.Transparency = 1
		mouse.Icon = 'rbxasset://textures\\GunWaitCursor.png'
	end
	--
	mouse.Button1Down:connect(function()
		if (tm()-LastThrown.Value) > RELOAD_TIME then
			local ignore = {}
			local mouseRay = Ray.new(mouse.UnitRay.Origin, mouse.UnitRay.Direction*999)
			local hit, at = Workspace:FindPartOnRayWithIgnoreList(mouseRay, ignore)
			while hit and (FindCharacterAncestor(hit) or not hit.CanCollide or hit.Transparency == 1) do
				table.insert(ignore, hit)
				hit, at = Workspace:FindPartOnRayWithIgnoreList(mouseRay, ignore)
			end
			if (at-Torso.Position).magnitude > RANGE then return end
			--
			LastThrown.Value = tm()
			--
			ANIM_Throw:Play(0)
			Delay(0.1, function()
				SOUND_Throw:Play()
			end)
			--
			repeat until ANIM_Throw.KeyframeReached:wait() == 'Thrown'
			--
			local spear = Handle:Clone()
			local sc = PoleScript:Clone()
			sc.Parent = spear
			sc.Disabled = false
			--
			local desiredTarget = at
			local vectorTo = desiredTarget - Torso.Position
			local torsoVector = vectorTo.magnitude * Torso.CFrame.lookVector
			--
			local thetaBetween = math.acos(math.min(1, math.max(-1, vectorTo.unit:Dot(torsoVector.unit))))
			--
			if thetaBetween > math.pi/4 then
				local frac = (math.pi/4) / thetaBetween
				desiredTarget = Torso.Position + Slerp(frac, torsoVector, vectorTo)
			end
			--
			sc:WaitForChild('BallDropScript'):WaitForChild('creator').Value = Player
			sc:WaitForChild('BallDropScript'):WaitForChild('Target').Value = desiredTarget
			local failValue = sc:WaitForChild('BallDropScript'):WaitForChild('Fail')
			failValue.Changed:connect(function()
				if failValue.Value then
					LastThrown.Value = 0
					Handle.Transparency = 0
					mouse.Icon = 'rbxasset://textures\\GunCursor.png'					
				end
			end)
			--
			spear.Velocity = Vector3.new()
			spear.CanCollide = false
			spear.RotVelocity = Vector3.new()
			--
			local float = Instance.new('BodyForce', spear)
			float.force = Vector3.new(0,spear:GetMass(),0)*196.2
			--
			spear.Parent = game.Workspace
			--
			Handle.Transparency = 1
			mouse.Icon = 'rbxasset://textures\\GunWaitCursor.png'
			--
			wait(RELOAD_TIME - (tm()-LastThrown.Value))
			--
			if not failValue.Value then
				Handle.Transparency = 0
				mouse.Icon = 'rbxasset://textures\\GunCursor.png'
			end
		end
	end)
end)

Tool.Unequipped:connect(function()
	ANIM_Equip:Stop()
	ANIM_Throw:Stop()
	--
	Handle.Transparency = 0
end)