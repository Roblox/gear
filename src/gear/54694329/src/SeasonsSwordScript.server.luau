-- ALL SEASONS --
-- OH YA BROSKI --
r = game:service("RunService") 
local sword = script.Parent.Handle 
local Tool = script.Parent 

local damage = 22

local slash_damage = 30
local lunge_damage = 36 

local SlashSound = Instance.new("Sound") 
SlashSound.SoundId = "rbxasset://sounds\\swordslash.wav" 
SlashSound.Parent = sword 
SlashSound.Volume = .7 

local LungeSound = Instance.new("Sound") 
LungeSound.SoundId = "rbxasset://sounds\\swordlunge.wav" 
LungeSound.Parent = sword 
LungeSound.Volume = .6 

local UnsheathSound = Instance.new("Sound") 
UnsheathSound.SoundId = "rbxasset://sounds\\unsheath.wav" 
UnsheathSound.Parent = sword 
UnsheathSound.Volume = 1 

local vCharacter
local myHumanoid
local myTorso

local formIce 

local co

function freeze(humanoid, torso)		
	print("coroutined")
	ice = sword:FindFirstChild("Ice")
	if ice then ice:Remove() end
	if torso and humanoid then 
		print("Done")
		humanoid.WalkSpeed = 0
		torso.Anchored = true
		icicle = Instance.new("Part")				
		icicle.FormFactor = 3
		icicle.Size = Vector3.new(3,2,3)
		icicle.Position = torso.Position + Vector3.new(0, -2, 0)
		icicle.CanCollide = false 
		icicle.Parent = game.Workspace
	
		float = Instance.new("BodyForce")
		float.force = Vector3.new(0, icicle:GetMass() * 196.1, 0)
		float.Parent = icicle
	
		mesh = Instance.new("SpecialMesh")
		mesh.MeshId = "http://www.roblox.com/asset/?id=54687962"
		mesh.TextureId = "http://www.roblox.com/asset/?id=54688004"
		mesh.Scale = Vector3.new(1.4, 1.4, 1.4)
		mesh.Parent = icicle

		wait(3.5)
		if icicle then icicle:Remove() end
		humanoid.WalkSpeed = 16
		torso.Anchored = false
	end
end

function blow(hit) 
	local humanoid = hit.Parent:findFirstChild("Humanoid") 
	local tempTorso = hit.Parent:FindFirstChild("Torso")
	local vCharacter = Tool.Parent 
	local vPlayer = game.Players:playerFromCharacter(vCharacter) 
	local hum = vCharacter:findFirstChild("Humanoid") -- non-nil if tool held by a character 
	if humanoid~=nil and humanoid ~= hum and hum ~= nil then           
		-- final check, make sure sword is in-hand 
		local right_arm = vCharacter:FindFirstChild("Right Arm") 
		if (right_arm ~= nil) then 
			local joint = right_arm:FindFirstChild("RightGrip") 
			if (joint ~= nil and (joint.Part0 == sword or joint.Part1 == sword)) then 
				tagHumanoid(humanoid, vPlayer)                                                         
				humanoid:TakeDamage(damage)	
				formIce = Tool:FindFirstChild("FormIce")
				if formIce and formIce.Value == 1 then 
					print("Icing")
					formIce.Value = 0
					co = coroutine.create(freeze)
					coroutine.resume(co, humanoid, tempTorso)
				end
				wait(1) 
				untagHumanoid(humanoid)                     
			end 
		end 
	end 
end 


function tagHumanoid(humanoid, player) 
     local creator_tag = Instance.new("ObjectValue") 
     creator_tag.Value = player 
     creator_tag.Name = "creator" 
     creator_tag.Parent = humanoid 
end 

function untagHumanoid(humanoid) 
     if humanoid ~= nil then 
          local tag = humanoid:findFirstChild("creator") 
          if tag ~= nil then 
               tag.Parent = nil 
          end 
     end 
end 


function attack() 
     damage = slash_damage 
     SlashSound:play() 
     local anim = Instance.new("StringValue") 
     anim.Name = "toolanim" 
     anim.Value = "Slash" 
     anim.Parent = Tool 
end 

function lunge() 
     damage = lunge_damage 
     LungeSound:play() 


     local anim = Instance.new("StringValue") 
     anim.Name = "toolanim" 
     anim.Value = "Lunge" 
     anim.Parent = Tool 
      
     force = Instance.new("BodyVelocity") 
     force.velocity = Vector3.new(0,10,0) --Tool.Parent.Torso.CFrame.lookVector * 80 
     force.Parent = Tool.Parent.Torso 
     wait(.2) 
     swordOut() 
     wait(.2) 
     force.Parent = nil 
     wait(.4) 
     swordUp() 
     damage = slash_damage 
end 

function swordUp() 
     Tool.GripForward = Vector3.new(1,0,0) 
     Tool.GripRight = Vector3.new(0, -1, 0) 
     Tool.GripUp = Vector3.new(0, 0, 1) 
end 

function swordOut() 
     Tool.GripForward = Vector3.new(0, 0, 1) 
     Tool.GripRight = Vector3.new(0, -1, 0) 
     Tool.GripUp = Vector3.new(-1, 0, 0) 
end 

Tool.Enabled = true 
local last_attack = 0 
function onActivated() 		
	if not Tool.Enabled then 
		 return 
	end 

	Tool.Enabled = false 

	local character = Tool.Parent; 
	local humanoid = character.Humanoid 
	if humanoid == nil then 
		 print("Humanoid not found") 
		 return 
	end 

	t = r.Stepped:wait() 

	if (t - last_attack < .2) then 
		 lunge() 
	else 
		 attack() 
	end 

	last_attack = t 

	--wait(0.5) 

	Tool.Enabled = true 
end 

function onEquipped()      
	UnsheathSound:play()  
	vCharacter = Tool.Parent
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	if myHumanoid then myHumanoid.WalkSpeed = 20 end
	formIce = Tool:FindFirstChild("FormIce")
	regenScript = Tool:FindFirstChild("RegenScript")
	if regenScript then
		regenScript.Disabled = false
	end
end 

function onUnequipped()
	if myHumanoid then myHumanoid.WalkSpeed = 16 end
	regenScript = Tool:FindFirstChild("RegenScript")
	if regenScript then
		regenScript.Disabled = true
	end
end

script.Parent.Activated:connect(onActivated) 
script.Parent.Equipped:connect(onEquipped) 
script.Parent.Unequipped:connect(onUnequipped)

connection = sword.Touched:connect(blow) 

