local zombie
local zombieOwner

local target = script:FindFirstChild("Target")
print(target.Value)

local unAnchoredParts = {} 

function offsetModelBy(model, offset) 
     local childs = model:GetChildren() 
     for i = 1, #childs do
		if childs[i]:IsA("BasePart") then 
			childs[i].CFrame = childs[i].CFrame + offset 					
			if not childs[i].Anchored then table.insert(unAnchoredParts, childs[i]) end 
			childs[i].Anchored = true -- anchor everything 
		elseif childs[i]:IsA("Tool") or childs[i]:IsA("Accessory") or childs[i]:IsA("Model")then
			offsetModelBy(childs[i], offset) 
		end 
	end 
end 

function createZombie()
	print("Creating Zombie")
	--model = game:GetService("InsertService"):LoadAsset(51731605)
	model = game:GetService("InsertService"):LoadAsset(51761755)
	if model then 
		print("Found Model")
		children = model:GetChildren() 
		if children then zombie = children[1] end
	else print("Model Fetch failed")
	end	 

	if zombie then
		unAnchoredParts = {} 

		offsetVector = (target.Value - zombie.Torso.Position) --+ Vector3.new(0, 4, 0)
		offsetModelBy(zombie, offsetVector)

		zombie.Parent = game.Workspace 

		neck = zombie.Torso.Neck
		neck.Part0 = zombie.Head
		neck.Part1 = zombie.Torso		

		-- HotThoth's Unholy Hack to prevent the zombie from dying while spawning
		-- There is a more reliable way to do this, by making the entire Zombie in script
		-- but of course thats ugly in its own right! 
		for j = 1, 10 do 
		-- Insane script below!
		zombie.Humanoid.MaxHealth = 100 
		zombie.Humanoid.Health = 100 
		zombie:MakeJoints() 
		wait(.1) 
		end 

		-- unanchor everything 
		for u = 1, #unAnchoredParts do unAnchoredParts[u].Anchored = false end 

		zombieOwner = script.Owner
		zombieOwner.Parent = zombie

		actionScript = script.ActionScript
		actionScript.Parent = zombie
		actionScript.Disabled = false
		
		animateScript = script.Animate 
		animateScript.Parent = zombie
		animateScript.Disabled = false
	end
end

createZombie()

wait(2.0)

script:Destroy()


