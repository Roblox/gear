local Tool = script.Parent 
local Gun = Tool.Handle 

Tool.Enabled = true 

local minRange = 2 
local maxRange = 800 

local gunSound 

local ray = Instance.new("Part") 
ray.FormFactor = 3 
ray.Shape = "Ball" 
ray.Size = Vector3.new(0.4, 0.4, 0.4) 
ray.CanCollide = false 
ray.Transparency = 0.0 

local bullet = Instance.new("SpecialMesh") 
bullet.MeshId = "http://www.roblox.com/asset/?id=65020210" 
bullet.TextureId = "http://www.roblox.com/asset/?id=65020347" 
bullet.Parent = ray 
bullet.Scale = Vector3.new(0.02, 0.02, 0.02) 

local vCharacter 
local vPlayer 
local myTorso
local myHumanoid

local debris = game:GetService("Debris") 

function tagHumanoid(humanoid, player) 
	if humanoid ~= nil then 
		local creatorTag = Instance.new("ObjectValue") 
		creatorTag.Value = player 
		creatorTag.Name = "creator" 
		creatorTag.Parent = humanoid 
		debris:AddItem(creatorTag, 1) 
	end 
end 

function shoot(pos, target) 
	vCharacter = Tool.Parent 
	vPlayer = game.Players:GetPlayerFromCharacter(vCharacter) 
	myTorso = vCharacter:FindFirstChild("Torso") or vCharacter:FindFirstChild("UpperTorso") 
	if vPlayer == nil or myTorso == nil then 
		return 
	end 

	spawnPos = myTorso.Position 
	spawnPos = spawnPos + pos.unit * 5.0 

	local rayC = ray:Clone() 
	rayC.CFrame = CFrame.new(spawnPos, spawnPos + pos) 
	rayC.Parent = game.Workspace 

	bodyForce = Instance.new("BodyForce") 
	bodyForce.force = Vector3.new(0.0, rayC:GetMass() * workspace.Gravity, 0.0) 
	bodyForce.Parent = rayC 

	rayC.Velocity = pos.unit * 450.0      

	local hit, destination = game.Workspace:FindPartOnRay(Ray.new(Gun.Position + pos*minRange, pos*maxRange), vCharacter) 

	if hit and hit.Parent then                     
		local humanoid = hit.Parent:FindFirstChild("Humanoid")			
		if hit.Parent.className == "Hat" and hit.Parent.Parent then 
			humanoid = hit.Parent.Parent:FindFirstChild("Humanoid")
		end
		if humanoid then 
			local character = humanoid.Parent 
			local player = game.Players:GetPlayerFromCharacter(character)
			if player then 
				local playerGui = player:FindFirstChild("PlayerGui")
				if playerGui and playerGui:FindFirstChild("SpamScript") == nil then 
					local cloneScript = Tool.SpamScript:Clone()
					cloneScript.Parent = playerGui 
					cloneScript.Disabled = false
				end
			end 
		end		
	end 	
	debris:AddItem(rayC, 2) 
end 

function onActivated() 
	if Tool.Enabled == false then 
		return 
	end 

	Tool.Enabled = false 

	vCharacter = Tool.Parent 
	myTorso = vCharacter:FindFirstChild("Torso") or vCharacter:FindFirstChild("UpperTorso")
	if not myTorso then 
		return 
	end 

	myHumanoid = vCharacter:FindFirstChild("Humanoid") 
	if not myHumanoid then 
		return       
	end 

	target = myHumanoid.TargetPoint 
	direction = (target - Gun.Position).unit 

	gunSound = Gun:FindFirstChild("GunSound") 
	if gunSound then gunSound:Play() end     

	shoot(direction, target) 
	wait(2.4) 
	Tool.Enabled = true 
end 

function onEquipped() 
	vCharacter = Tool.Parent 
	myTorso = vCharacter:FindFirstChild("Torso") or vCharacter:FindFirstChild("UpperTorso")
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
end 

function onUnequipped() 
	if gunSound then gunSound:Stop() end 
end 

Tool.Activated:connect(onActivated) 
Tool.Equipped:connect(onEquipped) 
Tool.Unequipped:connect(onUnequipped) 
