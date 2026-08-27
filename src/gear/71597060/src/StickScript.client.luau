local Tool = script.Parent
local Stick = Tool.Handle

local stabAnim
local slashAnim

local vCharacter
local myHumanoid
local myTorso

local debris = game:GetService("Debris")

local bodyVelocity = Instance.new("BodyVelocity")
bodyVelocity.P = 10000
bodyVelocity.Name = "QuakeVel"
bodyVelocity.maxForce = Vector3.new(10000, 10000, 10000)

local AOE = Vector3.new(15, 15, 15)

local anim

local damage = 14.5

local unequipped = false

local partsModel

local part = Instance.new("Part")
part.FormFactor = 3 
part.CanCollide = false 
part.Size = Vector3.new(1, 1, 1)

local bandanaMesh = Instance.new("SpecialMesh")
bandanaMesh.Name = "Bandana"
bandanaMesh.MeshId = "http://www.roblox.com/asset/?id=71545305"
bandanaMesh.TextureId = "http://www.roblox.com/asset/?id=71545324"

local bandanaC1 = CFrame.new(0, -0.300000012, -0.5, -1, 0, -8.74227766e-008, -8.74227766e-008, -2.18556949e-007, 1, -1.91068559e-014, 1, 2.18556949e-007)

local earringMesh = Instance.new("SpecialMesh")
earringMesh.Name = "Earring"
earringMesh.MeshId = "http://www.roblox.com/asset/?id=71545436"
earringMesh.TextureId = "http://www.roblox.com/asset/?id=71545324"

local earringC1 = CFrame.new(0, -0.599999964, 0, 1.91068547e-015, 4.37113883e-008, 1, 1, -4.37113883e-008, 0, 4.37113883e-008, 1, -4.37113883e-008)

local eyePatchMesh = Instance.new("SpecialMesh")
eyePatchMesh.Name = "EyePatch"
eyePatchMesh.MeshId = "http://www.roblox.com/asset/?id=71545496"
eyePatchMesh.TextureId = "http://www.roblox.com/asset/?id=71545324"

local eyePatchC1 = CFrame.new(0.25, 0.599999964, -0.24999997, -1, 3.49691135e-007, 4.37114061e-008, 4.37113776e-008, -8.74227766e-008, 1, 3.49691135e-007, 1, 8.74227695e-008)

local parrotMesh = Instance.new("SpecialMesh")
parrotMesh.Name = "Parrot"
parrotMesh.MeshId = "http://www.roblox.com/asset/?id=71545545"
parrotMesh.TextureId = "http://www.roblox.com/asset/?id=71545324"

local parrotC1 = CFrame.new(-0.799999952, -0.300000012, 0.75, -1, -1.91068542e-014, -8.74227766e-008, -8.74227766e-008, 2.18556949e-007, 1, 0, 1, -2.18556949e-007)


local meshes = {bandanaMesh, earringMesh, eyePatchMesh, parrotMesh}

-- Form Pirate 
local pirate = {}
pirate["Hat"] = game:GetService("InsertService"):LoadAsset(13477084):GetChildren()[1]
pirate["Torso"] = game:GetService("InsertService"):LoadAsset(27847359):GetChildren()[1]
pirate["Left Arm"]  = game:GetService("InsertService"):LoadAsset(27847412):GetChildren()[1]
pirate["Right Arm"] = game:GetService("InsertService"):LoadAsset(27847382):GetChildren()[1]
pirate["Left Leg"] = game:GetService("InsertService"):LoadAsset(27847445):GetChildren()[1]
pirate["Right Leg"] = game:GetService("InsertService"):LoadAsset(27847473):GetChildren()[1]
--

local stickWhackSound = Tool:FindFirstChild("StickWhackSound") 
if stickWhackSound == nil then 
	stickWhackSound = Instance.new("Sound") 
	stickWhackSound.Name = "StickWhackSound" 
	stickWhackSound.SoundId = "http://www.roblox.com/asset/?id=46153268" 
	stickWhackSound.Parent = Stick
	stickWhackSound.Volume = 1 
end 


function blow(hit)	
	local character
	local nameCheck 
	local foundIt = false
	if hit and hit.Parent then		
		if hit.Parent.className == "Hat" and hit.Parent.Parent then 
			humanoid = hit.Parent.Parent:FindFirstChild("Humanoid")					
		else 
			humanoid = hit.Parent:FindFirstChild("Humanoid")		
		end
	end
	vCharacter = Tool.Parent
	myHumanoid = vCharacter:FindFirstChild("Humanoid")	
	vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)
	if humanoid ~= nil and myHumanoid ~= nil and humanoid ~= myHumanoid then 
		rightArm = vCharacter:FindFirstChild("Right Arm")
		if rightArm then 
			rightGrip = rightArm:FindFirstChild("RightGrip")			
			if rightGrip and (rightGrip.Part0 == Stick or rightGrip.Part1 == Stick) then	
				character = humanoid.Parent 
				tagHumanoid(humanoid, vPlayer)
				humanoid:TakeDamage(damage)	
				if hit.Name == "Left Arm" then nameCheck = Enum.BodyPart.LeftArm
				elseif hit.Name == "Right Arm" then nameCheck = Enum.BodyPart.RightArm
				elseif hit.Name == "Right Leg" then nameCheck = Enum.BodyPart.RightLeg
				elseif hit.Name == "Left Leg" then nameCheck = Enum.BodyPart.LeftLeg
				elseif hit.Name == "Torso" then nameCheck = Enum.BodyPart.Torso
				elseif hit.Name == "Head" or (hit.Name == "Handle" and hit.Parent and hit.Parent.className == "Hat") then nameCheck = "Hat" end
				if character then 
					local children = character:GetChildren()
					local head = character:FindFirstChild("Head")
					for i = 1, #children do 									
						if children[i].className == "CharacterMesh" and children[i].BodyPart == nameCheck then
							foundIt = true
							print("Removing ", children[i])
							children[i]:Remove()
							if pirate[hit.Name] then 
								pirate[hit.Name]:Clone().Parent = character
							end
						end
						if children[i].className == "Hat" and head then -- and nameCheck == "Hat" then 									
							--if pirate[nameCheck] and pirate[nameCheck]:FindFirstChild("Handle") then 			

								local hat = Instance.new("Hat")
								local Hpart = pirate["Hat"].Handle:clone()
								Hpart.Parent = hat
								Hpart.Position = character.Head.Position
								hat.Name = "Spack Jarrow"
								--hat.Parent = character
								hat.AttachmentPos = pirate["Hat"].AttachmentPos
								hat.AttachmentRight = pirate["Hat"].AttachmentRight
								hat.AttachmentUp = pirate["Hat"].AttachmentUp
								hat.AttachmentForward = pirate["Hat"].AttachmentForward 
							--end
							if children[i] then children[i]:Remove() end
							if character:FindFirstChild("PartsModel") then character.PartsModel:Destroy() end 
							partsModel = Instance.new("Model")
							partsModel.Name = "PartsModel"
							partsModel.Parent = character
							for i = 1, #meshes do 
								local p1 = part:Clone()
								meshes[i]:Clone().Parent = p1
								p1.Name = i .. ""

								local w1 = Instance.new("Weld")
								w1.Parent = head
								w1.Part0 = head 
								w1.Part1 = p1 								

								p1.Parent = partsModel								
								if meshes[i].Name == "Bandana" then 
									w1.C1 = bandanaC1 
								elseif meshes[i].Name == "Parrot" then 
									w1.C1 = parrotC1
								elseif meshes[i].Name == "Earring" then 
									w1.C1 = earringC1
								else
									w1.C1 = eyePatchC1
								end 
							end 
						end
					end	
					if foundIt == false then 
						if hit.Name =="Head" or (hit.Name == "Handle" and hit.Parent and hit.Parent.className == "Hat") then 
							if pirate[nameCheck] and pirate[nameCheck]:FindFirstChild("Handle") then 
								local hat = Instance.new("Hat")
								local Hpart = pirate[nameCheck].Handle:clone()
								Hpart.Parent = hat
								Hpart.Position = character.Head.Position
								hat.Name = "Spack Jarrow"
								--hat.Parent = character
								hat.AttachmentPos = pirate[nameCheck].AttachmentPos
								hat.AttachmentRight = pirate[nameCheck].AttachmentRight
								hat.AttachmentUp = pirate[nameCheck].AttachmentUp
								hat.AttachmentForward = pirate[nameCheck].AttachmentForward 
							end
						else					
							if pirate[hit.Name] and pirate[hit.Name]:FindFirstChild("Handle") then 
								local hat = Instance.new("Hat")
								local Hpart = pirate[hit.Name].Handle:clone()
								Hpart.Parent = hat
								Hpart.Position = character.Head.Position
								hat.Name = "Spack Jarrow"
								--hat.Parent = character
								hat.AttachmentPos = pirate[hit.Name].AttachmentPos
								hat.AttachmentRight = pirate[hit.Name].AttachmentRight
								hat.AttachmentUp = pirate[hit.Name].AttachmentUp
								hat.AttachmentForward = pirate[hit.Name].AttachmentForward 
							end
						end
					end
					if myHumanoid.WalkSpeed < 20.0 then myHumanoid.WalkSpeed = 20.0 end 
					coroutine.resume(coroutine.create(function()
						wait(2.0)
						if myHumanoid then
							if unequipped == true then 
								myHumanoid.WalkSpeed = 16.0 
							else
								myHumanoid.WalkSpeed = 18.0
							end 
						end 
					end)) 
				end
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
		debris:AddItem(creatorTag, 1)
	end
end

function onActivated()	
	if Tool.Enabled == false then
		return
	end

	vCharacter = Tool.Parent
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	if myHumanoid == nil then 
		return
	end
	
	tick()

	Tool.Enabled = false
	
	local rand = math.random(1, 2)
	anim = myHumanoid:LoadAnimation(Tool.Whack)	
	if anim then anim:Play() end
	
	stickWhackSound = Stick:FindFirstChild("StickWhackSound")
	if stickWhackSound then 
		stickWhackSound:Play() 
	end 	

	Tool.GripForward = Vector3.new(0, 0, -1) 
	Tool.GripRight = Vector3.new(0, -1, 0) 
	Tool.GripUp = Vector3.new(1, 0, 0) 

	wait(0.5)      
	
	Tool.GripForward = Vector3.new(0.0, 1.0, 0.0) 
	Tool.GripRight = Vector3.new(1.0, 0.0, 0.0) 
	Tool.GripUp = Vector3.new(0.0, 0.0, 1.0)    
  
	Tool.Enabled = true 
end

function onEquipped(mouse)	
	vCharacter = Tool.Parent		
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	myTorso = vCharacter:FindFirstChild("Torso")
	unequipped = false
end

function onUnequipped()	
	if anim then anim:Stop() end
	if stickWhackSound then 
		stickWhackSound:Stop() 
	end 
	unequipped = true 
	if myHumanoid  then myHumanoid.WalkSpeed = 16.0 end
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)

Stick.Touched:connect(blow)