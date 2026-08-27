local Tool = script.Parent
local Axe = Tool.Handle

Tool.Enabled = true 

local damage = 12

local staticDamage = 12
local swingDamage = 18
local torsoDamage = 40

local debris = game:GetService("Debris")


local axeSound = Instance.new("Sound")
axeSound.SoundId = "rbxasset://sounds\\swordaxe.wav"
axeSound.Parent = sword
axeSound.Volume = .7

local vCharacter

function blow(hit)
	humanoid = hit.Parent:FindFirstChild("Humanoid")
	vCharacter = Tool.Parent
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)
	if humanoid ~= nil and myHumanoid ~= nil and humanoid ~= myHumanoid then 
		rightArm = vCharacter:FindFirstChild("Right Arm")
		if rightArm ~= nil then 
			rightGrip = rightArm:FindFirstChild("RightGrip")
			if rightGrip ~= nil and (rightGrip.Part0 == Axe or rightGrip.Part1 == Axe) then
				tagHumanoid(humanoid, vPlayer)
				if hit.Name == "Torso" then damage = torsoDamage end
				if humanoid.Health - damage < 25 then
					print("hai")
					coroutine.resume(coroutine.create(function() 
						print("Ohai")
						if hit then 
							print("??")
							local fire = Instance.new("Fire")
							fire.Color = Color3.new(0, 0, 0)
							fire.SecondaryColor = Color3.new(178/255, 178/255, 178/255) 
							fire.Parent = hit 
							debris:AddItem(fire, 5) 

							wait(1.75) 
						
							local e = Instance.new("Explosion")
							e.BlastRadius = 2 
							e.BlastPressure = 9999999
							e.Position = hit.Position
							e.Parent = game.Workspace 
							debris:AddItem(e, 1) 
						else 
							print("WTF") 
							print(hit) 
						end 
					end)) 
				end 				
				humanoid:TakeDamage(damage)
				damage = staticDamage
				wait(1.0)				
				untagHumanoid(humanoid)
			end
		end
	end
end

function tagHumanoid(humanoid, player)
	if humanoid ~= nil then
		creatorTag = Instance.new("ObjectValue")
		creatorTag.Name = "creator"
		creatorTag.Value = player
		creatorTag.Parent = humanoid
	end
end

function untagHumanoid(humanoid)
	if humanoid ~= nil then 
		tag = humanoid:FindFirstChild("creator")
		if tag ~= nil then tag:Remove() end
	end
end

function onActivated()
	if Tool.Enabled == false then 
		return
	end
	
	Tool.Enabled = false 
		
	vCharacter = Tool.Parent
	myHumanoid = vCharacter:FindFirstChild("Humanoid")		
	if myHumanoid == nil then 
		return
	end

	--axeSound = Tool:FindFirstChild("AxeSound")
	damage = swingDamage
	if axeSound then axeSound:Play() end
	wait(2.0)
	Tool.Enabled = true
end

function onEquipped()
end

function onUnequipped()
	if axeSound then axeSound:Stop() end
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)

Axe.Touched:connect(blow)
