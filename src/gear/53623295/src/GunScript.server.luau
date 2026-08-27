local Tool = script.Parent 
local Spidergun = Tool.Handle 

Tool.Enabled = true 

local debris = game:GetService("Debris") 

part = Instance.new("Part") 
part.Size = Vector3.new(4, 0.2, 4) 
part.Transparency = 1.0
part.CanCollide = false

web = Instance.new("Decal")
web.Texture = "http://www.roblox.com/asset/?id=53592160"
web.Face = 1
web.Parent = part

web1 = Instance.new("Decal")
web1.Texture = "http://www.roblox.com/asset/?id=53592160"
web1.Face = 4
web1.Parent = part

local spidergunSound 

function bind(spider, hit)
	if hit.Parent then
		humanoid = hit.Parent:FindFirstChild("Humanoid")
		torso = hit.Parent:FindFirstChild("Torso") or hit.Parent:FindFirstChild("UpperTorso")
		if humanoid and torso then 
			humanoid:TakeDamage(15)
			local newScript = Tool:FindFirstChild("WebScript"):Clone() 
			newScript.Disabled = false 
			newScript.Parent = humanoid.Parent

			bv = Instance.new("BodyVelocity")
			bv.Name = "Rebound"
			bv.P = 100000
			bv.maxForce = Vector3.new(100000, 0, 100000)
			bv.velocity = (torso.Position - spider.Position).unit * 30.0
			bv.Parent = torso
			
			spider.Parent = humanoid.Parent
			spider.Name = "Web"

			weld = Instance.new("Weld")
			weld.Parent = humanoid.Parent
			weld.Part0 = torso
			weld.Part1 = spider
			weld.C1 = CFrame.new(Vector3.new(0, 0, 0))	
			
		else
			if spider then spider:Remove() end
		end
	end	
end

function shoot(pos, spider) 
      
	vCharacter = Tool.Parent 

	if vCharacter == nil or vCharacter:FindFirstChild("Humanoid") == nil then 
		print("Humanoid not found") 
		return 
	end      

	vPlayer = game.Players:GetPlayerFromCharacter(vCharacter) 
	if vPlayer == nil then 
		print("Player not found") 
		return 
	end 

	local spawnPos = vCharacter.PrimaryPart.Position 
	spawnPos = spawnPos + pos.unit * 5.0 

	spider.CFrame = CFrame.new(spawnPos, spawnPos + pos) * CFrame.Angles(math.pi/2, 0, 0)
	spider.Velocity = pos * 75.0	
	spider.Name ="spider" 
	spider.Parent = game.Workspace 
	--spider.CanCollide = true 

	local spiderFloat = Instance.new("BodyForce") 
	spiderFloat.force = Vector3.new(0.0, spider:GetMass() * workspace.Gravity, 0.0) 
	spiderFloat.Parent = spider 

	local creatorTag = Instance.new("ObjectValue") 
	creatorTag.Name = "creator" 
	creatorTag.Value = vPlayer 
	creatorTag.Parent = spider 

	spider.Touched:connect(function (hit) bind(spider, hit) end)

	debris:addItem(spider, 5) 
      
end 

function onActivated() 
	if Tool.Enabled == false then 
		return 
	end 
	Tool.Enabled = false 

	vCharacter = Tool.Parent 
	myHumanoid = vCharacter:FindFirstChild("Humanoid") 
	if myHumanoid == nil then 
		print("Humanoid not found") 
		return 
	end 

	myTorso = vCharacter:FindFirstChild("Torso") or vCharacter:FindFirstChild("UpperTorso") 
	if myTorso == nil then 
		print("Torso not found") 
		return 
	end 

	spidergunSound = Tool:FindFirstChild("SpiderGunSound") 
	if spidergunSound then spidergunSound:Play() end 

	local target = myHumanoid.TargetPoint 
	local lookAt = (target - vCharacter.Head.Position).unit      

	local spider = part:Clone() 	
	shoot(lookAt, spider) 
	wait(2.5) 
	Tool.Enabled = true 
end 

function onEquipped() 
end 

function onUnequipped() 
	if SpidergunSound then SpidergunSound:Stop() end 
end 

Tool.Activated:connect(onActivated) 
Tool.Equipped:connect(onEquipped) 
Tool.Unequipped:connect(onUnequipped)