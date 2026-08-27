--[[
	Fixed by ArceusInator.  Uses new spawning that works no matter where the player is.  Fixed teamkilling.
--]]

local Tool = script.Parent
local Doll = Tool.Handle

local GLib = require(206209239)

local vCharacter
local myHumanoid
local myTorso

Tool.Enabled = true 

local dollClone
local dollFire
local dollModel

local prevHealth = 100

local connection

local ray = Instance.new("Part")
ray.FormFactor = 3
ray.Shape = "Ball"
ray.Size = Vector3.new(0.4, 0.4, 0.4)
ray.CanCollide = false
ray.Transparency = 0.0

local bullet = Instance.new("SpecialMesh")
bullet.MeshId = "http://www.roblox.com/asset/?id=57810032"
bullet.TextureId = "http://www.roblox.com/asset/?id=57809568"
bullet.Parent = ray
bullet.Scale = Vector3.new(4, 4, 4)

local debris = game:GetService("Debris")

local shootSound
local alienSound

local attacking = false

function follow()	
	local stopped = false
	local bv
	if dollClone then bv = dollClone:FindFirstChild("FollowBV") end
	while dollClone and dollModel and myTorso and bv do 
		local distance = (myTorso.Position - dollClone.Position).magnitude
		if distance > 5.0 then 	
			stopped = false
			dollClone.CFrame = CFrame.new(dollClone.Position, myTorso.Position + Vector3.new(0, dollClone.Position.Y - myTorso.Position.Y, 0))  * CFrame.Angles(-math.pi/2, 0, 0)
			bv.Parent = dollClone
			if distance > 8.0 then 
				bv.velocity = (myTorso.Position - dollClone.Position).unit * 20.0 + Vector3.new(0, 2, 0)
			else 
				bv.velocity = (myTorso.Position - dollClone.Position).unit * 20.0 * (distance/24) + Vector3.new(0, 2, 0)
			end
		else 			
			if not stopped then 
				stopped = true
				bv.velocity = Vector3.new(0, 0, 0)
				dollClone.Velocity = Vector3.new(0, 0, 0)
				bv.Parent = nil
			end
		end
		wait()
	end
	Doll.Transparency = 0.0
end

function blow(ray, hit)
	local owner, target = GLib.GetPlayerFromPart(script), GLib.GetPlayerFromPart(hit)
	
	if ray and hit and hit.Parent and hit.Parent ~= vCharacter and not GLib.IsTeammate(owner, target) then 
		humanoid = hit.Parent:FindFirstChild("Humanoid")
		if humanoid then 
			humanoid:TakeDamage(30)
			if myHumanoid and myHumanoid.Health + 5 <=  myHumanoid.MaxHealth then 
				myHumanoid.Health = myHumanoid.Health + 5
			end
		end
	end
end

function shoot(torso)
	if dollClone == nil then return end
	shootSound = Tool:FindFirstChild("ShootSound")
	if shootSound then shootSound:Play() end
	local direction = (torso.Position - dollClone.Position).unit 
	
	local spawnPos = dollClone.Position + direction * 3.0

	local rayC = ray:Clone()
	rayC.CFrame = CFrame.new(spawnPos, spawnPos + direction)
	rayC.Velocity = direction * 50.0

	local float = Instance.new("BodyForce")
	float.force = Vector3.new(0, rayC:GetMass() * workspace.Gravity, 0)
	float.Parent = rayC
	
	local fire = Instance.new("Fire")
	fire.Parent = rayC
	fire.Color = Color3.new(0, 153/255, 0)
	fire.SecondaryColor = Color3.new(102/255, 51/255, 0)

	rayC.Parent = game.Workspace

	rayC.Touched:connect(function(hit) blow(rayC, hit) end)
	debris:AddItem(rayC, 5.0)	
end

function attack()
	if myHumanoid == nil then return end
	if myHumanoid.Health < prevHealth and dollClone and not attacking then
		prevHealth = myHumanoid.Health
		local owner = GLib.GetPlayerFromPart(myHumanoid)
		if owner then 
			local playr = owner 
			if playr:IsA("Player") then 
				local character = playr.Character
				if character and (character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")) then 
					attacking = true
					local torso = character.Torso
					print(1)
					shoot(torso)					
					attacking = false
				end
			end
		end
	end
end

function onActivated()
	if Tool.Enabled == false then 
		return 
	end

	vCharacter = Tool.Parent
	myTorso = vCharacter:FindFirstChild("Torso") or vCharacter:FindFirstChild("UpperTorso")
	myHumanoid = vCharacter:FindFirstChild("Humanoid")

	connection = myHumanoid.HealthChanged:connect(attack)
	
	if myTorso == nil or myHumanoid == nil then 
		return 
	end

	if dollClone == nil  then 

		Tool.Enabled = false

		alienSound = Tool:FindFirstChild("AlienSound")
		if alienSound then alienSound:Play() end

		dollModel = Instance.new("Model")
		dollModel.Name = "DollModel"

		dollClone = Doll:Clone()
		dollClone.CanCollide = false 
		dollClone.Parent = dollModel
		dollClone.Name = "AlienVoodoo"
		dollModel.Parent = vCharacter

		Doll.Transparency = 1.0

		dollFire = Instance.new("Fire")
		dollFire.Parent  = dollClone
		dollFire.Color = Color3.new(0, 153/255, 0)
		dollFire.SecondaryColor = Color3.new(102/255, 51/255, 0)

--		dollClone.CFrame = CFrame.Angles(0, math.pi/2, math.pi/2) * (myTorso.CFrame - myTorso.CFrame.lookVector * 3.0) + Vector3.new(0, 3, 0)
--		dollClone.CFrame = dollClone.CFrame * CFrame.Angles(-math.pi/2, 0, 0)
		dollClone.CFrame = myTorso.CFrame * CFrame.new(0, 20, 20) * CFrame.Angles(-math.pi/2, 0, 0)

		local dollFloat = Instance.new("BodyForce")
		dollFloat.Name = "DollFloat"
		dollFloat.Parent = dollClone
		dollFloat.force = Vector3.new(0, dollClone:GetMass() * 196, 0)	

		local bv = Instance.new("BodyVelocity")
		bv.Name = "FollowBV"
		bv.Parent = dollClone
		bv.maxForce = Vector3.new(50000, 50000, 50000)
		bv.P = 50000
		
		dollCo = coroutine.create(follow)
		coroutine.resume(dollCo)
	else 
		-- make the doll Attack
		attack()
	end

	wait(2.0)
	Tool.Enabled = true
end

function onEquipped()
end

function onUnequipped()
	if dollClone then dollClone:Destroy() dollClone = nil end
	if dollModel then dollModel:Destroy() dollModel = nil end	
	Doll.Transparency = 0.0
	if connection then connection:disconnect() end
	if shootSound then shootSound:Stop() end
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
