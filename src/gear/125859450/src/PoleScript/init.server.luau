local Spear = script.Parent

local BallDropScript = script:WaitForChild('BallDropScript')

local Creator = BallDropScript:WaitForChild('creator')
local Player = Creator.Value
local DesiredTarget = BallDropScript:WaitForChild('Target')
local Character = Player.Character
local Fail = BallDropScript:WaitForChild('Fail')

Delay(10, function()
	Spear:Destroy()
end)

Delay(0.5, function()
	Spear.CanCollide = true
end)

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

local function onTouched(part)
	if not FindCharacterAncestor(part) then
		-- see if we have an empty space to do the effect in
		local at = (Spear.CFrame*CFrame.new(0,3.5,0)).p
		BallDropScript:WaitForChild('Target').Value = at
		local region = Region3.new(at + Vector3.new(-1,5,-1), at + Vector3.new(1,1,1))
		local parts = Workspace:FindPartsInRegion3(region)
		for _, part in pairs(parts) do
			if not FindCharacterAncestor(part) and part.CanCollide then
				Fail.Value = true
				Spear.Parent = nil
				return
			end
		end
		-- Create effect
		BallDropScript.Parent = nil
		BallDropScript.Disabled = false
		BallDropScript.Parent = game.Workspace
		Spear:Destroy()
		return true
	end
end
Spear.Touched:connect(onTouched)
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
local function topVector(cf)
	local _,_,_,_,r5,_,_,r8,_,_,r11,_ = cf:components()
	return Vector3.new(r5,r8,r11)
end
function CFrameFromTopBack(at, top, back)
	local right = top:Cross(back)
	return CFrame.new(at.x, at.y, at.z,
		              right.x, top.x, back.x,
		              right.y, top.y, back.y,
		              right.z, top.z, back.z)
end
local frac = 0
local start = Spear.Position
local target = DesiredTarget.Value
local initialDir = (CFrame.new(start, target)*CFrame.Angles(0.5, 0, 0)).lookVector
local finalDir = (CFrame.new(start, target)*CFrame.Angles(-0.5, 0, 0)).lookVector
local distance = (start-target).magnitude
local mid = (start + initialDir*distance/2)
local startT = tick()
local velo = 80
local duration = distance / velo
--
local ignore = {Spear}
while true do
	wait()
	local elapsed = tick()-startT
	local frac = elapsed / duration
	if frac > 1 then
		break
	end
	local lastAt = (Spear.CFrame*CFrame.new(0,3.5,0)).p
	local at = start:Lerp(mid,frac):Lerp(mid:Lerp(target,frac),frac)
	local dir = Slerp(frac,initialDir,finalDir)
	Spear.CFrame = CFrame.new(at, at+dir)*CFrame.Angles(-math.pi/2,0,0)
	local newAt = (Spear.CFrame*CFrame.new(0,3.5,0)).p
	local ray = Ray.new(lastAt, (newAt-lastAt))
	local hit, loc = Workspace:FindPartOnRayWithIgnoreList(ray, ignore)
	while hit do
		if onTouched(hit) then
			return
		end
		table.insert(ignore, hit)
		hit, loc = Workspace:FindPartOnRayWithIgnoreList(ray, ignore)
	end
end

Spear:Destroy()