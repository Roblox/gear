local Trap = script.Parent 
local debounce = false

local debris = game:GetService("Debris")

local creatorTag

if Trap.CFrame.lookVector:Dot(Vector3.new(0, 1, 0)) > 0 then Trap.CFrame = Trap.CFrame * CFrame.Angles(0, -math.pi, 0) end

wait(1.5)
Trap.Transparency = 0.9

local burnSound 

function burnAWhile(humanoid, torso)
	local duration = 7
	if humanoid and torso then 
		fire = Instance.new("Fire")
		fire.Parent = torso
		fire.Heat = -1 
		fire.Size = 5 	
		while duration > 0 do 	
			duration  = duration - 1 
			humanoid:TakeDamage(7)
			wait(0.5)
		end
		if fire then fire:Destroy() end
	end
end

function tagHumanoid(humanoid)
	if humanoid then 
		creatorTag = script:FindFirstChild("creator")
		if creatorTag then 
			creatorTag.Parent = humanoid 
			debris:AddItem(creator, 2.5) 
		end
	end
end

function trapThem(trap, hit)
	if trap == nil or hit == nil or hit.Parent == nil then return end 	
	local humanoid = hit.Parent:FindFirstChild("Humanoid")
	if humanoid and not debounce then 
		debounce = true		
		humanoid.WalkSpeed = 0.0
		local torso = hit.Parent:FindFirstChild("Torso") or hit.Parent:FindFirstChild("UpperTorso")
		if torso then 
			torso.Anchored = true 
			trap.CFrame = torso.CFrame * CFrame.Angles(-math.pi/2, 0, 0)
			trap.Anchored = true
		end 
		if trap:FindFirstChild("Mesh") then trap.Mesh.Scale = Vector3.new(0.8, 0.8, 1.3) end 
		trap.Transparency = 0.0 
		wait(1.5)
		if trap:FindFirstChild("Fire") then
			burnSound = script:FindFirstChild("BurnSound")
			if burnSound then burnSound:Play() end
			trap.Fire.Enabled = true 
			trap.Fire.Size = 20
		end
		tagHumanoid(humanoid)
		humanoid:TakeDamage(70)		
		wait(2)		
		if trap then trap:Destroy() end 
		coroutine.resume(coroutine.create(function() burnAWhile(humanoid, torso) end))
		if humanoid then humanoid.WalkSpeed = 16.0 end
		if torso then torso.Anchored = false end	
		debounce = false
	end
end

Trap.Touched:connect(function(hit) trapThem(Trap, hit) end)
wait(75) 
if Trap then Trap:Destroy() end
if script then script:Destroy() end
