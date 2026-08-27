local Part = script.Parent
local DebrisService = game:GetService('Debris')
local Players = game:GetService('Players')
local RestorePlayer = Part:WaitForChild('RestorePlayer')
local RestorePlayerScript = RestorePlayer.Value:clone()

local IsPlayerFrozen = false

local function createFreezeEffect(c, torso, humanoid, hit)
	-- only freeze if they don't have an ice weld
	if c.Value and c.Value ~= nil and torso:FindFirstChild('IceWeld') == nil then
		local playerHit = Players:GetPlayerFromCharacter(hit.Parent)
		if playerHit then
			if playerHit == c.Value then
				return
			end
		end
		IsPlayerFrozen = true
		
		local part = Instance.new('Part')
		part.Name = 'Effect'
		part.BrickColor = BrickColor.new('Pastel light blue')
		part.FormFactor = 'Custom'
		part.Size = Vector3.new(5, 8, 5)
		part.Transparency = 0.3
		part.Reflectance = 0.3
		part.CanCollide = false
		part.TopSurface = 'Smooth'
		part.BottomSurface = 'Smooth'
		
		local cf = CFrame.Angles(0, math.pi * 2 * math.random(), 0.5 * math.random())
		part.CFrame = torso.CFrame * cf
		
		local motor = Instance.new('Motor')
		motor.Name = 'IceWeld'
		motor.Part0 = torso
		motor.Part1 = part
		motor.C0 = CFrame.Angles(0, math.pi * 2 * math.random(), 0.5 * math.random())
		motor.Parent = torso
		
		DebrisService:AddItem(part, 8)
		part.Parent = game.Workspace
		
		humanoid.WalkSpeed = 0
		RestorePlayerScript.Parent = humanoid
		RestorePlayerScript.Disabled = false
	end
end

Part.Touched:connect(function(hit)
	if IsPlayerFrozen then
		return
	end
	if hit and hit.Parent then
		local c = Part:FindFirstChild('creator')
		local humanoid = hit.Parent:FindFirstChild('Humanoid')
		local torso = hit.Parent:FindFirstChild('Torso')
		
		if c and humanoid and torso then
			local restorePlayerScript = humanoid:FindFirstChild('RestorePlayerScript')
			if not restorePlayerScript then
				createFreezeEffect(c, torso, humanoid, hit)
			end
		end
	end
end)

wait(0.8)
Part:remove()
