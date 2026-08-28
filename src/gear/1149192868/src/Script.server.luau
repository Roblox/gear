--by SolarCrane
--[[
	Fixed by ArceusInator
	- Reports KOs to the site
	- Fixed reload time
	- Doesn't kill teammates
	- Works with FE
--]]
local GLib = require(206209239)

-- Waits for the child of the specified parent
local function WaitForChild(parent, childName)
	while not parent:FindFirstChild(childName) do parent.ChildAdded:wait() end
	return parent[childName]
end

local LIGHTNING_DURATION = 10
local MAX_JUMP_DISTANCE = 100
local MAX_JUMPS = 5


local RADIUS = 15
local theShield

local Tool = script.Parent
local Handle = WaitForChild(Tool, 'Handle')

-- Player specific convenience variables
local MyPlayer = nil
local MyCharacter = nil
local MyHumanoid = nil
local MyTorso = nil

local PlayersService = Game:GetService('Players')
local DebrisService = game:GetService('Debris')

local FireSound
local LightningSound1
local LightningSound2
local LightningDecal

local HitCharacters = {}

local bodyGyro
local bodyRotation

local function NearestCharacter(origin, ignoreList)
	local players = PlayersService:GetPlayers()
	local closestDistance = MAX_JUMP_DISTANCE
	local closestCharacter = nil
	for k, player in pairs(players) do
		local character = player.Character
		if character and character:FindFirstChild('Torso') and not ignoreList[character] then
			local torso = character.Torso
			local distance = (torso.CFrame.p - origin).magnitude
			if distance < closestDistance then
				closestCharacter = character
				closestDistance = distance
			end
		end
	end
	return closestCharacter, closestDistance
end

local function TagHumanoid(humanoid, player)
	-- Add more tags here to customize what tags are available.
	while humanoid:FindFirstChild('creator') do
		humanoid:FindFirstChild('creator'):Destroy()
	end 
	local creatorTag = Instance.new("ObjectValue")
	creatorTag.Value = player
	creatorTag.Name = "creator"
	creatorTag.Parent = humanoid
	DebrisService:AddItem(creatorTag, 1.5)
end


function CreateLightning(startPoint, endPoint, orientation, duration)
	if not LightningDecal then return end

	-- Limit the distance of the lightning to the max jump distance
	if (endPoint - startPoint).magnitude > MAX_JUMP_DISTANCE then
		endPoint = startPoint + (endPoint - startPoint).unit * MAX_JUMP_DISTANCE
	end
	local lightningPart = Instance.new('Part')
	DebrisService:AddItem(lightningPart, duration)
	lightningPart.CanCollide = false
	lightningPart.FormFactor = Enum.FormFactor.Custom
	lightningPart.Size = Vector3.new(5, 0.1, (endPoint - startPoint).magnitude)
	lightningPart.Transparency = 1
	lightningPart.CFrame = CFrame.new((startPoint + endPoint) / 2, endPoint) * orientation -- * CFrame.Angles(0, math.rad(-90), 0)
	lightningPart.Anchored = true
	lightningPart.Touched:connect(OnShieldTouch)
	lightningPart.Parent = Workspace

	local lightningDecal = LightningDecal:Clone()
	lightningDecal.Parent = lightningPart
	lightningDecal = LightningDecal:Clone()
	lightningDecal.Face = Enum.NormalId.Bottom
	lightningDecal.Parent = lightningPart
	return lightningPart
end

local inTouch = false

function OnShieldTouch(hit)
	if inTouch then return end
	inTouch = true
	if hit and hit.Parent:FindFirstChild('Humanoid') then
		if not HitCharacters[hit.Parent] then
			local knockback = hit.Parent.Torso:FindFirstChild('BodyVelocity')
			if not knockback then
				knockback = Instance.new('BodyVelocity')
				DebrisService:AddItem(knockback, 1)
			end
			knockback.maxForce = Vector3.new(100000, 100000, 100000)
			knockback.velocity = (hit.Parent.Torso.CFrame.p - MyTorso.CFrame.p).unit * 50
			knockback.Parent = hit.Parent.Torso
		end
		local lastHitPosition = MyTorso.CFrame.p
		for i = 1, MAX_JUMPS do
			local nearChar, dist = NearestCharacter(lastHitPosition, HitCharacters)
			if nearChar and nearChar:FindFirstChild('Torso') and not HitCharacters[nearChar] and not GLib.IsTeammate(GLib.GetPlayerFromPart(script), GLib.GetPlayerFromPart(nearChar)) then
				if math.random(1,2) == 1 then
					LightningSound1:Play()
				else
					LightningSound2:Play()
				end
				wait(0.5)
				--print("Zapping" , nearChar.Name)
				HitCharacters[nearChar] = true
				CreateLightning(lastHitPosition, nearChar.Torso.CFrame.p, CFrame.new(0, math.rad(-90), 0), 0.5)
				-- Deal Damage
				GLib.TagHumanoid(GLib.GetPlayerFromPart(script), nearChar.Humanoid)
				nearChar.Humanoid:TakeDamage(35)
				lastHitPosition = nearChar.Torso.CFrame.p
			else
				break
			end
		end
		HitCharacters[hit.Parent] = true
		wait(1.5)
		if theShield then
			theShield:Destroy()
			theShield = nil
			MyHumanoid.WalkSpeed = 16
		end
		if bodyGyro then
			bodyGyro:Destroy()
			bodyGyro = nil
		end
		if bodyRotation then
			bodyRotation:Destroy()
			bodyRotation = nil
		end
	end
	inTouch = false
end





local function CreateLightningShield(origin)
	MyHumanoid.WalkSpeed = 25
	HitCharacters = {}
	HitCharacters[MyCharacter] = true
	theShield = Instance.new('Model')
	DebrisService:AddItem(theShield, 10)
	theShield.Parent = MyTorso
	for i = 1, 15 do
		local X = origin.X + RADIUS * math.cos(math.rad(i * 24))
		local Z = origin.Z + RADIUS * math.sin(math.rad(i * 24))
		local lightning = CreateLightning(origin + Vector3.new(0, 5, 0), Vector3.new(X, origin.Y, Z), CFrame.Angles(math.rad(-40), math.rad(-65), 0), LIGHTNING_DURATION)
		lightning.Anchored = false
		lightning.Parent = theShield
		local newWeld = Instance.new("ManualWeld")
		newWeld.Part0 = MyTorso
		newWeld.Part1 = lightning
		newWeld.C0 = CFrame.new()
		newWeld.C1 = newWeld.Part1.CFrame:inverse() * newWeld.Part0.CFrame
		newWeld.Parent = lightning
	end
	bodyGyro = Instance.new('BodyGyro')
	DebrisService:AddItem(bodyGyro, 10)
	bodyGyro.maxTorque = Vector3.new(1000000, 0, 100000)
	--bodyGyro.Parent = MyTorso
	bodyRotation = Instance.new('BodyAngularVelocity')
	bodyRotation.angularvelocity = Vector3.new(0, 60, 0)
	bodyRotation.maxTorque = Vector3.new(0, 10000000, 0)
	DebrisService:AddItem(bodyRotation, 10)
	bodyRotation.Parent = MyTorso
	wait(10)
	if theShield then
		theShield:Destroy()
		theShield = nil
		MyHumanoid.WalkSpeed = 16
	end
	if bodyGyro then
		bodyGyro:Destroy()
		bodyGyro = nil
	end
	if bodyRotation then
		bodyRotation:Destroy()
		bodyRotation = nil
	end
end

local attacking = false
local timeOfLastShield = 0

local SwingHits = {}

function blow(hit)
	if attacking and hit and hit.Parent and hit.Parent:FindFirstChild('Humanoid') and hit.Parent ~= MyCharacter then
		if MyHumanoid and MyHumanoid.Health > 0 then
			if not theShield and tick() - timeOfLastShield > 3 then
				CreateLightningShield(MyTorso.CFrame.p)
				timeOfLastShield = tick()
			end
			if not SwingHits[hit.Parent] and not GLib.IsTeammate(GLib.GetPlayerFromPart(script), GLib.GetPlayerFromPart(hit)) then
				GLib.TagHumanoid(GLib.GetPlayerFromPart(script), hit.Parent.Humanoid)
				hit.Parent.Humanoid:TakeDamage(10)
				SwingHits[hit.Parent] = true
			end
		end
	end
end

function OnActivated()
	if attacking then return end
	attacking = true
	if MyHumanoid and MyHumanoid.Health > 0 then
		SwingHits = {}
		Tool.PlayAttack.Disabled = false
	end
	wait(2)
	attacking = false
end

function OnKeyDown(key)
	if string.lower(key) == 'q' then
		--print('checking shield')
		if not theShield and tick() - timeOfLastShield > 10 then
			--print('Making shield')
			CreateLightningShield(MyTorso.CFrame.p)
			timeOfLastShield = tick()
		end
	end
end

function OnEquipped()
	LightningDecal = WaitForChild(Tool, 'LightningDecal')

	MyCharacter = Tool.Parent
	MyPlayer = game:GetService('Players'):GetPlayerFromCharacter(MyCharacter)
	MyHumanoid = MyCharacter:FindFirstChild('Humanoid')
	MyTorso = MyCharacter:FindFirstChild('Torso')
	LightningSound1 = WaitForChild(Handle, 'lightning1')
	LightningSound2 = WaitForChild(Handle, 'lightning2')
	Handle.Touched:connect(blow)
end

-- Unequip logic here
function OnUnequipped()
	MyCharacter = nil
	MyHumanoid = nil
	MyTorso = nil
	MyPlayer = nil

end

Tool.Equipped:connect(OnEquipped)
Tool.Unequipped:connect(OnUnequipped)
Tool.Activated:connect(OnActivated)

Tool.OnKeyDown.OnServerEvent:connect(function(client, ...)
	if client.Character == Tool.Parent then
		OnKeyDown(...)
	end
end)