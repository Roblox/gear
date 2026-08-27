-- Umbrella -- 
-- Whack Animation, time 0.5 seconds 
-- Whack Sound, 0.4 seconds 

-- Handle to the game service, in case we need to get the time 
r = game:service("RunService") 

-- normal damage, when the Umbrella touches a humanoid object 
local damage = 8

-- Whack damage 
local whack_damage = 12

-- Handle to tool 
Umbrella = script.Parent.Handle 
Tool = script.Parent 

-- For the Animations 
local WhackAnim 

local TGrip = Tool.Grip 

sparkles = Instance.new("Sparkles")
sparkles.Parent = Umbrella
sparkles.SparkleColor = Color3.new(205/255, 145/255, 158/255)

-- Sounds! 
local UmbrellaWhack = Tool:FindFirstChild("UmbrellaWhack") 
if UmbrellaWhack == nil then 
	UmbrellaWhack = Instance.new("Sound") 
	UmbrellaWhack.Name = "UmbrellaWhack" 
	UmbrellaWhack.SoundId = "http://www.roblox.com/asset/?id=46153268" 
	UmbrellaWhack.Parent = Tool 
	UmbrellaWhack.Volume = 1 
end 

-- When a collision is detected between the player and another character 
function blow(hit) 
	if hit == nil or hit.Parent == nil then return end 
	local opponent = hit.Parent:findFirstChild("Torso") 
	local humanoid = hit.Parent:findFirstChild("Humanoid")      
	local vCharacter = Tool.Parent 
	local vPlayer = game.Players:playerFromCharacter(vCharacter) 
	local myTorso = vCharacter:findFirstChild("Torso") 
	local hum = vCharacter:findFirstChild("Humanoid") -- non-nil if tool held by a character 
	if humanoid~=nil and humanoid ~= hum and hum ~= nil then                
		 -- final check, make sure Umbrella is in-hand 
		local right_arm = vCharacter:FindFirstChild("Right Arm") 
		if (right_arm ~= nil) then 
			local joint = right_arm:FindFirstChild("RightGrip") 
			if (joint ~= nil and (joint.Part0 == Umbrella or joint.Part1 == Umbrella)) then 
				tagHumanoid(humanoid, vPlayer) 
				humanoid:TakeDamage(damage)                     
				-- Add body velocity to the opponent to push him when he gets whacked                     
				local bodyVelocity = Instance.new("BodyVelocity") 
				bodyVelocity.P = 100000 
				bodyVelocity.maxForce = Vector3.new(bodyVelocity.P, bodyVelocity.P, bodyVelocity.P) 
				bodyVelocity.velocity = (opponent.Position - myTorso.Position) * 6 
				bodyVelocity.Parent = opponent 
				wait(0.5) 
				if bodyVelocity ~= nil then bodyVelocity:remove() end 
				wait(0.5) 
				untagHumanoid(humanoid) 
			end 
		end 

	end 
end 

-- Tagging and Untagging primarily for the leaderboards 
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


-- On, left click! 
function attack() 
     damage = whack_damage 
     -- Play the sound 
     if UmbrellaWhack then UmbrellaWhack:Play() end 
end 

-- Tentative lock 
Tool.Enabled = true 

function onActivated() 
	if not Tool.Enabled then 
		 return 
	end 
	Tool.Enabled = false 
	-- Check if the handle to the Player is still available in the space 
	local MyPlayer = Tool.Parent 
	if MyPlayer == nil then 
		 return 
	end           
	-- Check to see if the humanoid is still in the world 
	local MyHumanoid= MyPlayer:FindFirstChild("Humanoid") 
	if MyHumanoid == nil then 
		 return 
	end      
	attack()      
	-- Load and play the animation 
	WhackAnim = MyHumanoid:LoadAnimation(Tool.Whack) 
	if WhackAnim then WhackAnim:Play() end      
	-- To rotate the fish as the character swings 
	Tool.GripForward = Vector3.new(0, 0, -1) 
	Tool.GripRight = Vector3.new(0, -1, 0) 
	Tool.GripUp = Vector3.new(1, 0, 0) 
	wait(0.5)      
	-- Reset the fish to its original orientation 
	Tool.Grip = TGrip  
	Tool.Enabled = true 
	-- Reset the damage 
	damage = 10
end 


function onEquipped()           
	-- Remove the sound if its still playing 
	UmbrellaWhack.Volume = 1 
	if UmbrellaWhack then UmbrellaWhack:Stop() end 
end 

function onUnequipped() 
	-- Remove the sounds and the animations 
	UmbrellaWhack.Volume = 0      
	if WhackAnim then WhackAnim:Stop() end      
	if UmbrellaWhack then UmbrellaWhack:Stop() end      
end 

Tool.Activated:connect(onActivated) 
Tool.Equipped:connect(onEquipped) 
Tool.Unequipped:connect(onUnequipped) 

connection = Umbrella.Touched:connect(blow) 
