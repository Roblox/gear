local Tool = script.Parent 
local Monkey = Tool.Handle

local vCharacter
local myTorso 
local myHumanoid 

Tool.Enabled = true 

local petMonkey

local debris = game:GetService("Debris")

function summonMonkey()
	if myTorso and myHumanoid then
		petMonkey = game:GetService("InsertService"):LoadAsset(71536048):GetChildren()[1] 
		if petMonkey then 
			debris:AddItem(petMonkey, 60) -- Make sure that it will get deleted 
			petMonkey:MoveTo(myTorso.Position + Vector3.new(math.random(-3, 3), 0, math.random(-3, 3)))

			local monkeyAIScript = Tool.MonkeyAIScript:Clone()
		
			while monkeyAIScript:FindFirstChild("Monkey") == nil do 			
				wait()
			end 
			
			monkeyAIScript.Monkey.Value = petMonkey 
			monkeyAIScript.Parent = vCharacter

			local target = Instance.new("ObjectValue")
			target.Name = "Target"
			target.Value = nil 
			target.Parent = petMonkey

			wait()
			monkeyAIScript.Disabled = false 

			debris:AddItem(monkeyAIScript, 60)
		
			petMonkey.Parent = workspace
			petMonkey:MoveTo(myTorso.Position + Vector3.new(math.random(-3, 3), 0, math.random(-3, 3)))
			Monkey.Transparency = 1.0

			coroutine.resume(coroutine.create(function()
				wait(60.0)
				Monkey.Transparency = 0.0
			end)) 

			if petMonkey:FindFirstChild("Humanoid") then 
				petMonkey.Humanoid.Died:connect(function()					
					debris:AddItem(petMonkey, 4) 
					wait(3.5)
					Monkey.Transparency = 0.0
				end)
			end 
		end 
	end 
end 

function onActivated()
	if Tool.Enabled == false then 
		return 
	end 

	if myTorso == nil or myHumanoid == nil then 
		return 
	end 
	

	Tool.Enabled = false 

	if not petMonkey or not petMonkey.Parent then 
		summonMonkey()
	end 

	local target = myHumanoid.TargetPoint
	local direction = (target - myTorso.Position).unit
	
	local hit = workspace:FindPartOnRay(Ray.new(myTorso.Position, direction * 150), vCharacter)
	if hit then 
		local enemyHumanoid = hit.Parent:FindFirstChild("Humanoid")
		if enemyHumanoid then 
			if petMonkey:FindFirstChild("Target") then 
				petMonkey.Target.Value = enemyHumanoid
			end 
		end 
	end 

	wait(2.0)
		
	Tool.Enabled = true
end 

function onEquipped()
	vCharacter = Tool.Parent 
	myTorso = vCharacter:FindFirstChild("Torso") or vCharacter:FindFirstChild("UpperTorso")
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
end 

function onUnequipped()
	if petMonkey then petMonkey:Destroy() end 	
	Monkey.Transparency = 0.0
end 

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)