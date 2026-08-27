function waitForChild(parent, instance)
	while parent:FindFirstChild(instance) == nil do print(instance) wait() end 
	return parent:FindFirstChild(instance)
end 

local Tool = script.Parent 
local Sword = Tool.Handle 

local Character
local Player
local Torso
local Humanoid 

Tool.Enabled = true 

local Fanged_BoolValue = waitForChild(Tool, "Fanged")
local Fang_Weld = waitForChild(Tool, "FangWeld")  
local Fire_Part = waitForChild(Sword, "FirePart")
local Fang_Fire = waitForChild(Fire_Part, "DarkFire") 

local Damage = 16

local RBX_Debris = game:GetService("Debris")

local NumSpiders = 8
local AnansiId = 117508233
local Anansi = Game:GetService('InsertService'):LoadAsset(AnansiId):GetChildren()[1]

local function Cut(hit)
	if hit and hit.Parent then 
		local humanoid = hit.Parent:FindFirstChild("Humanoid")
		if hit.Parent:IsA("Hat") then
			humanoid = hit.Parent.Parent:FindFirstChild("Humanoid")
		end 
		if humanoid and humanoid ~= Humanoid and Humanoid then 
			humanoid:TakeDamage(Damage)
			if Fang_Fire and Fang_Fire.Enabled == true then
				coroutine.resume(coroutine.create(function()
					if humanoid and humanoid.Parent and humanoid.Parent:FindFirstChild("Torso") and not humanoid.Parent.Torso:FindFirstChild("DarkFire") then						
						local cFire = Fang_Fire:Clone()
						cFire.Parent = humanoid.Parent:FindFirstChild("Torso") 
						RBX_Debris:AddItem(cFire, 4) 
						if math.random() < 0.25 then 
							local anansi = Anansi:Clone()						
							local aScript = Tool:WaitForChild('AnansiAIScript'):Clone()
							aScript.Parent = Character
							aScript:WaitForChild('Anansi').Value = anansi
							anansi:WaitForChild('Target').Value = humanoid.Parent:WaitForChild('Torso')
							anansi.Parent = Character 
							aScript.Disabled = false
							RBX_Debris:AddItem(anansi, 30.0)
							RBX_Debris:AddItem(aScript, 30.0)
							anansi:MoveTo(Torso.CFrame.p + Torso.CFrame.lookVector * 4.0, Torso)
						end 
						local duration = 4
						while duration > 0 do
							humanoid:TakeDamage(3)
							duration = duration - 1 
							wait(1.0) 
						end  					
					end 
				end)) 
			end 
		end 
	end 
end

local function OnEquipped() 
	if Fang_Weld then 
		Fang_Weld.Parent = Tool 
	end 	
	Character = Tool.Parent 
	Player = game.Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso")
end 

Tool.Equipped:connect(OnEquipped)
Sword.Touched:connect(Cut)

local function FireSpiderCannon()
	local parts_List = {} 

	local ray = Instance.new("Part")
	ray.Parent = game.Workspace
	ray.FormFactor = 3 
	ray.Anchored = true
	ray.CanCollide = false 
	ray.Size = Vector3.new(1, 0.2, 1)
	ray.Material = Enum.Material.Plastic
	ray.BrickColor = BrickColor.new("Bright red")
	ray.Locked = true 
	ray.CFrame = CFrame.new(Fire_Part.CFrame.p, Vector3.new(0, 1, 0)) 	
			
	while ray.Size.Y < 100 do 		
		ray.Size = ray.Size *  Vector3.new(1, 2, 1) 
		ray.CFrame = CFrame.new(Fire_Part.CFrame.p) * CFrame.new(0, 0, -ray.Size/2)		
		wait(0.05)
	end 

	for i = 1, 8 do 
		local p = Instance.new('Part')
		p.Parent = Game.Workspace
		p.FormFactor = 3 
		p.Size = Vector3.new(1, 1, 1)
		p.CFrame = ray.CFrame * CFrame.Angles(0, 0, 2*i*math.pi/8)
		p.Anchored = true 
		p.BrickColor = BrickColor.new('Black')
		p.CanCollide = false

		table.insert(parts_List, p)
	end 	

	local duration = 3.0 
	while duration > 0  do 
		local count = 0 
		for _, part in pairs(parts_List) do 
			count = count + 1
			if part.Size.Y < 30 then 
				part.Size = part.Size + Vector3.new(0, 1, 0)
				part.CFrame = (ray.CFrame + Vector3.new(0, ray.Size.Y/2, 0)) * CFrame.Angles(0, 0, count * math.pi/8)
			end 
		end 
		wait()
		duration = duration - wait(0.25)
	end 
	
	wait(1.0)	
	ray:Destroy()
	for _, part in pairs(parts_List) do
		print('Anansi!')
		local anansi = Anansi:Clone()						
		local aScript = Tool:WaitForChild('AnansiAIScript'):Clone() 
		aScript:WaitForChild('Anansi').Value = anansi		
		anansi.Parent = Character 
		aScript.Parent = Character 
		aScript.Disabled = false
		anansi:MoveTo(part.CFrame.p + Vector3.new(math.random(1, 5), 0, math.random(1, 5)), Torso)
		RBX_Debris:AddItem(anansi, 30.0)
		RBX_Debris:AddItem(aScript, 30.0)
		part:Destroy()
		wait()
	end 
end 

Fanged_BoolValue.Changed:connect(function()	
	if Fanged_BoolValue.Value == true and Humanoid then 
		Fang_Fire.Enabled = true 
		Damage = 29
		Humanoid.WalkSpeed = 0.0 		
		FireSpiderCannon() 
		Humanoid.WalkSpeed = 21.0		
		wait(30)
		Damage = 16 
		Humanoid.WalkSpeed = 16.0
		Fang_Fire.Enabled = false 		
		wait(15)
		Fanged_BoolValue.Value = false
	else 		
		if not Humanoid then 
			if Fanged_BoolValue then 
				Fanged_BoolValue.Value = false 
			end 
		end  
	end  
end) 



