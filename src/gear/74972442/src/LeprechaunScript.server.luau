local Tool = script.Parent 
local Leprechaun = Tool.Handle

local vCharacter
local myTorso 
local myHumanoid 

Tool.Enabled = true 

local petLeprechaun

local debris = game:GetService("Debris")

local summonSound 

function summonLeprechaun()
	if myTorso and myHumanoid then
		summonSound = Leprechaun:FindFirstChild("LetItBegin")
		if summonSound then summonSound:Play() end 
		petLeprechaun = game:GetService("InsertService"):LoadAsset(74900154 ):GetChildren()[1] 
		if petLeprechaun then 
			debris:AddItem(petLeprechaun, 60) -- Make sure that it will get deleted 
			petLeprechaun:MoveTo(myTorso.Position + Vector3.new(math.random(-3, 3), 0, math.random(-3, 3)))

			local leprechaunAIScript = Tool.LeprechaunAIScript:Clone()
		
			while leprechaunAIScript:FindFirstChild("Leprechaun") == nil do 			
				wait()
			end 
			
			leprechaunAIScript.Leprechaun.Value = petLeprechaun 
			leprechaunAIScript.Parent = vCharacter

			local target = Instance.new("ObjectValue")
			target.Name = "Target"
			target.Value = nil 
			target.Parent = petLeprechaun

			wait()
			leprechaunAIScript.Disabled = false 

			debris:AddItem(leprechaunAIScript, 60)
		
			petLeprechaun.Parent = game.Workspace
			petLeprechaun:MoveTo(myTorso.Position + Vector3.new(math.random(-3, 3), 0, math.random(-3, 3)))
			Leprechaun.Transparency = 1.0

			coroutine.resume(coroutine.create(function()
				wait(60.0)
				Leprechaun.Transparency = 0.0
			end)) 

			if petLeprechaun:FindFirstChild("Humanoid") then 
				petLeprechaun.Humanoid.Died:connect(function()					
					debris:AddItem(petLeprechaun, 4) 
					Leprechaun.Transparency = 0.0
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

	if not petLeprechaun or not petLeprechaun.Parent then 
		summonLeprechaun()
	end 

	local target = myHumanoid.TargetPoint
	local direction = (target - myTorso.Position).unit
	
	local hit = game.Workspace:FindPartOnRay(Ray.new(myTorso.Position, direction * 150), vCharacter)
	if hit then 
		local enemyHumanoid = hit.Parent:FindFirstChild("Humanoid")
		if enemyHumanoid then 
			if petLeprechaun and petLeprechaun:FindFirstChild("Target") then 
				petLeprechaun.Target.Value = enemyHumanoid
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
	if petLeprechaun then petLeprechaun:Destroy() end 	
	Leprechaun.Transparency = 0.0
	if summonSound then summonSound:Stop() end 
end 

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)