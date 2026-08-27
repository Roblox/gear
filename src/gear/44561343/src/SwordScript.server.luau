-- noSpikesMesh:  44471127
-- spikeRowMesh:  44471182


local damage = 10

sword = script.Parent.Handle
Tool = script.Parent

local bang = Tool.Handle.Bangbang
local whoosh = Tool.Handle.Whoosh

local debris = game:GetService("Debris")

local firingCharacter = nil


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
				humanoid.WalkSpeed = humanoid.WalkSpeed - 1
				if humanoid.WalkSpeed < 5 then humanoid.WalkSpeed = 5 end
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
	bang:Play()

	local anim = Instance.new("StringValue")
	anim.Name = "toolanim"
	anim.Value = "Slash"
	anim.Parent = Tool
end

Tool.Enabled = true
canShootMissiles = true
function onActivated()

	if not Tool.Enabled and not canShootMissiles then
		return
	end

	if Tool.Enabled then

		Tool.Enabled = false

		local character = Tool.Parent;
		local humanoid = character.Humanoid
		if humanoid == nil then
			print("Humanoid not found")
			return 
		end
	
		canDamage = true
	
		attack()
		wait(.5)
		attack()
		wait(.5)
		attack()
		wait(1)
		
		Tool.Enabled = true
	else
		whoosh:Play()
		-- shoot the spikes :D
		canShootMissiles = false
		Tool.Handle.Mesh.MeshId = "http://www.roblox.com/asset/?id=44471127"

		firingCharacter = Tool.Parent
		if firingCharacter ~= nil and firingCharacter:FindFirstChild("Humanoid") then
			for i = 1, 5 do
				angle = math.pi*2/5*i
				newMissile = Tool.SpikeRow:Clone()
				newMissile.CFrame = Tool.SpikeRow.CFrame * CFrame.Angles(0, 0, angle)
				newMissile.Name = "RowOfIceSpikes"
				newMissile.Transparency = 0
				newMissile.Velocity = newMissile.CFrame:vectorToWorldSpace(Vector3.new(1, 0, 0)).unit * 50
	
				newMissileFloatForce = Instance.new("BodyForce")
				newMissileFloatForce.force = Vector3.new(0, newMissile:GetMass()*(workspace.Gravity * 0.925), 0)
				newMissileFloatForce.Parent = newMissile
	
				newShooterTag = Instance.new("ObjectValue")
				newShooterTag.Name = "ShooterTag"
				newShooterTag.Value = firingCharacter
				newShooterTag.Parent = newMissile

				newScript = Tool.IceSpikeScript:Clone()
				newScript.Parent = newMissile
				newScript.Disabled = false

				newMissile.Parent = game.Workspace
	
				debris:AddItem(newMissile, 2)
			end
		-- spikeRowMesh:  44471182
		end
		wait(3)
		firingCharacter = nil
		Tool.Handle.Mesh.MeshId = "http://www.roblox.com/asset/?id=44410140"
		canShootMissiles = true
	end
end

script.Parent.Activated:connect(onActivated)
connection = sword.Touched:connect(blow)

