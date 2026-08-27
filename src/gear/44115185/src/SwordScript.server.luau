local damage = 10
local objection_damage = 10
local order_damage = 25
local overruled_damage = 50

sword = script.Parent.Handle
Tool = script.Parent

local bang = Tool.Handle.Bangbang
local objection = Tool.Handle.Objection
local order = Tool.Handle.Order
local overruled = Tool.Handle.Overruled


local canDamage = true  -- only damage one person once until next attack
function blow(hit)
	if not canDamage then return end
	if (hit.Parent == nil) then return end -- happens when bullet hits sword

	local humanoid = hit.Parent:findFirstChild("Humanoid")
	local vCharacter = Tool.Parent
	local vPlayer = game.Players:playerFromCharacter(vCharacter)
	local hum = vCharacter:findFirstChild("Humanoid") -- non-nil if tool held by a character
	if humanoid~=nil and humanoid ~= hum and hum ~= nil then
		-- final check, make sure sword is in-hand

		local right_arm = vCharacter:FindFirstChild("Right Arm") or vCharacter:FindFirstChild("RightHand")
		if (right_arm ~= nil) then
			local joint = right_arm:FindFirstChild("RightGrip")
			if (joint ~= nil and (joint.Part0 == sword or joint.Part1 == sword)) then
				tagHumanoid(humanoid, vPlayer)
				humanoid:TakeDamage(damage)
				if damage == overruled_damage then
					-- also knock down playa
					humanoid.Sit = true
				end
				canDamage = false
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
	local anim = Instance.new("StringValue")
	anim.Name = "toolanim"
	anim.Value = "Slash"
	anim.Parent = Tool
end


Tool.Enabled = true
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

	canDamage = true

	local randSelect = math.random(1,3)
	bang:Play()
	if randSelect == 1 then 
		damage = objection_damage
		objection:Play()
	elseif randSelect == 2 then 
		damage = order_damage
		order:Play()
	else
		damage = overruled_damage
		overruled:Play()
	end

	attack()
	wait(.5)
	attack()
	wait(.5)
	attack()
	wait(.5)

	Tool.Enabled = true
end

script.Parent.Activated:connect(onActivated)
connection = sword.Touched:connect(blow)

