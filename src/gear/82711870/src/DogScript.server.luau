local Tool = script.Parent 
local Dog = Tool.Handle

local vCharacter
local myTorso 
local myHumanoid 

Tool.Enabled = true 

local petDog

local debris = game:GetService("Debris")

local summonSound 

function summonDog()
	if myTorso and myHumanoid then
		summonSound = Dog:FindFirstChild("LetItBegin")
		if summonSound then summonSound:Play() end 
		petDog = game:GetService("InsertService"):LoadAsset(82264079):GetChildren()[1] 
		if petDog then 
			debris:AddItem(petDog, 60) -- Make sure that it will get deleted 
			petDog:MoveTo(myTorso.Position + Vector3.new(math.random(-3, 3), 0, math.random(-3, 3)))

			local dogAIScript = Tool.DogAIScript:Clone()
		
			while dogAIScript:FindFirstChild("Dog") == nil do 			
				wait()
			end 

			petDog.Name = "Snarffle"
			
			dogAIScript.Dog.Value = petDog 
			dogAIScript.Parent = vCharacter

			local target = Instance.new("ObjectValue")
			target.Name = "Target"
			target.Value = nil 
			target.Parent = petDog

			wait()
			dogAIScript.Disabled = false 

			debris:AddItem(dogAIScript, 60)
		
			petDog.Parent = game.Workspace
			petDog:MoveTo(myTorso.Position + Vector3.new(math.random(-3, 3), 0, math.random(-3, 3)))
			Dog.Transparency = 1.0

			coroutine.resume(coroutine.create(function()
				wait(60.0)
				Dog.Transparency = 0.0
			end)) 

			if petDog:FindFirstChild("Humanoid") then 
				petDog.Humanoid.Died:connect(function()					
					debris:AddItem(petDog, 4) 
					Dog.Transparency = 0.0
					wait(3.5)					
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

	if not petDog or not petDog.Parent then 
		summonDog()
	end 

	local target = myHumanoid.TargetPoint
	local direction = (target - myTorso.Position).unit
	
	local hit = game.Workspace:FindPartOnRay(Ray.new(myTorso.Position, direction * 150), vCharacter)
	if hit then 
		local enemyHumanoid = hit.Parent:FindFirstChild("Humanoid")
		if enemyHumanoid then 
			if petDog and petDog:FindFirstChild("Target") then 
				petDog.Target.Value = enemyHumanoid
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
	if petDog then petDog:Destroy() end 	
	Dog.Transparency = 0.0
	if summonSound then summonSound:Stop() end 
end 

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)