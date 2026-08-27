-- SWORD OF JUDGEMENT --
-- HEAVY DAMAGE --
-- ACTIVE ABILITIES -- 
r = game:service("RunService") 
local sword = script.Parent.Handle 
local Tool = script.Parent 

local damage = 16

local slash_damage = 24
local lunge_damage = 32 

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

local cloneActive = Tool:FindFirstChild("CloneActive")

function blow(hit) 
	local humanoid = hit.Parent:findFirstChild("Humanoid") 
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
     Tool.GripRight = Vector3.new(0,0,-1) 
     Tool.GripUp = Vector3.new(0,-1, 0) 
end 

function swordOut() 
     Tool.GripForward = Vector3.new(0, 1, 0) 
     Tool.GripRight = Vector3.new(0, 0, -1) 
     Tool.GripUp = Vector3.new(-1, 0, 0) 
end 

Tool.Enabled = true 
local last_attack = 0 
function onActivated() 		
	if not Tool.Enabled then 
		 return 
	end 

	if cloneActive.Value == 1 then 	
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
end 

script.Parent.Activated:connect(onActivated) 
script.Parent.Equipped:connect(onEquipped) 

connection = sword.Touched:connect(blow) 
