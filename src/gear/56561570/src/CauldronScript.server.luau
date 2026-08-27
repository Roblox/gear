local Tool = script.Parent
local Cauldron = Tool.Handle

local vCharacter
local myTorso
local vPlayer

local smoke

Tool.Enabled = true

local humanoids = {}
local cauldronClone

local dropSound

function onActivated()
	if Tool.Enabled == false then return end
	Tool.Enabled = false
	vCharacter = Tool.Parent
	myTorso = vCharacter:FindFirstChild("Torso")
	if myTorso == nil then return end	
	humanoids = {}
	vPlayer = game.Players:GetPlayerFromCharacter(vCharacter) 		
	smoke = Instance.new("Smoke")
	smoke.Color = Color3.new(0, 1, 0)
	smoke.Opacity = 0.2
	smoke.RiseVelocity = 0.0
	smoke.Size = 0.1
	smoke.Parent  = Cauldron
	wait(1.5)
	
	dropSound = Cauldron:FindFirstChild("DropSound")
	if dropSound then dropSound:Play() end
	
	cauldronClone = Cauldron:Clone()	
	cauldronClone.CanCollide = true
	cauldronClone.CFrame = Cauldron.CFrame 
	cauldronClone.Parent = game.Workspace

	Cauldron.Transparency = 1.0

	players = game.Players:GetChildren() 
	for i = 1, #players do 
		if players[i] ~= vPlayer then 
			tempChar = players[i].Character
			if tempChar then 
				tempHumanoid = tempChar:FindFirstChild("Humanoid") 
				tempTorso = tempChar:FindFirstChild("Torso")	
				if tempHumanoid and tempTorso then 
					distance = (tempTorso.Position - myTorso.Position).magnitude 
					if distance < 30.0 then
						if tempChar:FindFirstChild("ConfusionScript") == nil then 
							smokeClone = smoke:Clone() 
							smokeClone.Parent = tempTorso
							newScript = Tool.ConfusionScript:Clone()
							newScript.Parent = tempChar
							newScript.Disabled = false 
						end
					end
				end 
			end
		end
	end
	smoke.Size = 30 
	wait(1.0)
	if smoke then smoke:Remove() end
	wait(1.0)
	if cauldronClone then cauldronClone:Remove() end
	Cauldron.Transparency = 0.0
	wait(6.0)
	Tool.Enabled = true
end

function onEquipped()
end

function onUnequipped()
	Cauldron.Transparency = 0.0
	if dropSound then dropSound:Stop() end 
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
