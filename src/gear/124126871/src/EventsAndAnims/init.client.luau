math.randomseed(tick())

local Tool = script.Parent
local Muzzle = Tool:WaitForChild('Muzzle')
local Fire = Muzzle:WaitForChild('Fire')
local Bullet = Tool:WaitForChild('Bullet')
local Walrus = Tool:WaitForChild('Walrus')
local Handle = Tool:WaitForChild('Handle')

local Debris = game:GetService('Debris')

local BULLET_SPEED = 50
local BULLET_LIFETIME = 5
local FLARE_TIME = 0.1
local SMOKE_TIME = 1
local DISABLED_TIME = 0.2
local STEP_TIME = 0.1
local NUM_STEPS = 10
local MAX_NUM_WALRUSES = 5	-- at most MAX_NUM_WALRUSES walruses can be attached to a given character

local Anims = {}

local FireSound

local function Play(animationName)
	if not Anims[animationName] then
		local humanoid = Tool.Parent:FindFirstChild('Humanoid')
		if humanoid and humanoid.ClassName == 'Humanoid' then
			local unloadedAnim = Tool:FindFirstChild(animationName)
			if unloadedAnim then
				Anims[animationName] = humanoid:LoadAnimation(unloadedAnim)
				Anims[animationName]:Play()
			end
		end
	else
		Anims[animationName]:Play()
	end
end

local function Stop(animationName)
	if Anims[animationName] then 
		Anims[animationName]:Stop()
	end
end

local function WeldInPlace(part0, part1, name)
	local weld = Instance.new("ManualWeld")
	weld.Part0 = part0
	weld.Part1 = part1
	weld.C0 = CFrame.new()
	weld.C1 = part1.CFrame:inverse() * part0.CFrame
	if name then
		weld.Name = name
	else
		weld.Name = "WeldTo" .. part1.Name
	end
	weld.Parent = part0
	return weld
end

function SpawnWalrus(bullet, part, character)
	print(part.Name)
	local cframe = CFrame.new(bullet.Position, part.Position)
	numWalruses = 0
	for _, child in pairs(character:GetChildren()) do
		if child.Name == "Walrus" then
			numWalruses = numWalruses + 1
		end
	end
	if numWalruses < MAX_NUM_WALRUSES then
		bullet:Destroy()
		local walrus = Walrus:Clone()
		walrus.Parent = character
		walrus.CFrame = cframe
		WeldInPlace(part, walrus)
		local loveScript = walrus:WaitForChild('Love')
		loveScript.Disabled = false
	end
end

function OnTouched(bullet, part)
	local bodyVelocity = bullet:FindFirstChild('BodyVelocity')
	if part.Parent ~= Tool and bodyVelocity and part.Name ~= "Walrus" then
		bodyVelocity:Destroy()
		local character = part.Parent
		if character then
			local player = game.Players:GetPlayerFromCharacter(character)
			if player and player ~= game.Players.LocalPlayer then
				SpawnWalrus(bullet, part, character)
			elseif character:IsA('Accoutrement') then
				character = character.Parent
				if character then 
					player = game.Players:GetPlayerFromCharacter(character)
					if player and player ~= game.Players.LocalPlayer then
						SpawnWalrus(bullet, part, character)
					end
				else
					return
				end
			end
		else
			return
		end
	end
end

function OnActivated()
	if Tool.Enabled then
		Tool.Enabled = false
		Delay(DISABLED_TIME, function() Tool.Enabled = true end)
		Play('FireAnim')
		FireSound = Handle:FindFirstChild('FireSound')
		if FireSound then FireSound:Play() end
		Fire.Enabled = true
		Delay(FLARE_TIME, function() Fire.Enabled = false end)
		
		local character = Tool.Parent
		local torso = nil
		if character then
			torso = character:FindFirstChild('Torso')
		end
		local direction = torso and torso.CFrame.lookVector or Bullet.CFrame.lookVector	
		
		local bullet = Bullet:Clone()
		bullet.CanCollide = true
		bullet.Transparency = 0.0
		local bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.velocity = BULLET_SPEED * direction
		bodyVelocity.Parent = bullet
		bullet.Velocity = BULLET_SPEED * direction
		bullet.Parent = Workspace
		bullet.Touched:connect(function(part) OnTouched(bullet, part) end)
		Debris:AddItem(bullet, BULLET_LIFETIME)
	end
end

function OnEquipped()
	Play('EquipAnim')
end

function OnUnequipped()
	Stop('EquipAnim')
	Stop('FireAnim')
	if FireSound then FireSound:Stop() end
	Fire.Enabled = false
end
	

Tool.Equipped:connect(OnEquipped)
Tool.Activated:connect(OnActivated)
Tool.Unequipped:connect(OnUnequipped)

