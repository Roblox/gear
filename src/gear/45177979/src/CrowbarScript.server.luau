debris = game:GetService("Debris")

local damage = 0


local slash_damage = 10

sword = script.Parent.Handle
Tool = script.Parent

local UnsheathSound = Instance.new("Sound")
UnsheathSound.SoundId = "rbxasset://sounds\\unsheath.wav"
UnsheathSound.Parent = sword
UnsheathSound.Volume = .5


function blow(hit)

	if (Tool.Enabled) then return end -- only damages on a swing

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
				
				if not sword.Hit.IsPlaying then sword.Hit:Play() end

				local otherTorso = hit.Parent:FindFirstChild("Torso")
				if otherTorso ~= nil then
					dir = (otherTorso.Position - sword.Position).unit
					local newBF = Instance.new("BodyForce")
					newBF.force = dir*10000
					newBF.Parent = otherTorso
					debris:AddItem(newBF, .5)
				else
					dir = (hit.Position - sword.Position).unit
					local newBF = Instance.new("BodyForce")
					newBF.force = dir*10000
					newBF.Parent = hit
					debris:AddItem(newBF, .5)
				end
				
				wait(1)
				untagHumanoid(humanoid)
			end
		end


	else
		if humanoid == nil and hum ~= nil then
			if not sword.Hit.IsPlaying then sword.Hit:Play() end
			print("whacked somethin")
			if (hit:getMass() < 34) then
				print("somethin small, so breaking joints")
				hit:BreakJoints()
			end
				--local dir = (hit.Position - vCharacter.Torso.Position).unit
				local dir = (hit.Position - sword.Position).unit
				local bf = Instance.new("BodyForce")
				bf.force = dir * 30000
				bf.Parent = hit
				debris:AddItem(bf, .5)
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
	sword.Swing:Play()
end


Tool.Enabled = true
function onActivated()

	if not Tool.Enabled then
		return
	end

	Tool.Enabled = false

	attack()

	wait(2)

	damage = 0

	Tool.Enabled = true
end


function onEquipped()
	UnsheathSound:play()
end


script.Parent.Activated:connect(onActivated)
script.Parent.Equipped:connect(onEquipped)


connection = sword.Touched:connect(blow)


