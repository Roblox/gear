local damage = 20

sword = script.Parent.Handle
Tool = script.Parent

local bang = Tool.Handle.Bangbang

local debris = game:GetService("Debris")


function confuzzleHumanoid(myHum)
	myHum.Sit = true

	if myHum.Parent == nil then return end
	humHead = myHum.Parent:FindFirstChild("Head")
	if humHead == nil then return end

	local newStars = {}
	local angle = 0
	local numStars = 5

	local newStar = Instance.new("Part")
	local newStarMesh = Instance.new("SpecialMesh")
	newStarMesh.MeshId = "http://www.roblox.com/asset/?id=45428961"
	newStarMesh.TextureId = "http://www.roblox.com/asset/?id=45021124"
	newStarMesh.Scale = Vector3.new(2, 2, 2)
	newStarMesh.Parent = newStar
	newStar.Size = Vector3.new(1, 1, 1)
	newStar.Anchored = false
	newStar.CanCollide = false
	newStar.CFrame = humHead.CFrame

	--newStarForce = Instance.new("BodyPosition")
	--newStarForce.P = 100000
	--newStarForce.position = humHead.Position + humHead.CFrame:vectorToWorldSpace(Vector3.new( math.cos(angle), 1, math.sin(angle)))
	--newStarForce.maxForce = Vector3.new(newStarForce.P, newStarForce.P, newStarForce.P)
	--newStarForce.Parent = newStar

	newStarForce = Instance.new("BodyForce")
	newStarForce.force = Vector3.new(0, newStar:GetMass()*workspace.Gravity, 0)
	newStarForce.Parent = newStar

	newStar.RotVelocity = Vector3.new(math.random()-.5, math.random()-.5, math.random()-.5)*100

	newStar.Parent = game.Workspace

	debris:AddItem(newStar, 7)

	newStars[1] = newStar

	for i = 1, (numStars-1) do
		angle = angle + (math.pi*2)/numStars
		newStars[i+1] = newStar:Clone()
		--newStars[i+1].BodyPosition.position = humHead.Position + humHead.CFrame:vectorToWorldSpace(Vector3.new(math.cos(angle), 1, math.sin(angle)))--+ Vector3.new(math.cos(angle), 0, math.sin(angle))
		newStars[i+1].CFrame = newStars[i+1].CFrame - newStars[i+1].Position + humHead.Position + humHead.CFrame:vectorToWorldSpace(Vector3.new(math.cos(angle), 1, math.sin(angle)))
		newStars[i+1].RotVelocity = Vector3.new(math.random()-.5, math.random()-.5, math.random()-.5)*100
		newStars[i+1].Parent = game.Workspace
		debris:AddItem(newStars[i+1], 7)
	end

	-- keep the positions updated
	for i = 1, 50 do
		angle = i/5
		for j = 1, numStars do
			angle = angle + (math.pi*2)/numStars
			--newStars[j].BodyPosition.position = humHead.Position + humHead.CFrame:vectorToWorldSpace(Vector3.new(math.cos(angle), 1, math.sin(angle)))
			newStars[j].CFrame = newStars[j].CFrame - newStars[j].Position + humHead.Position + humHead.CFrame:vectorToWorldSpace(Vector3.new(math.cos(angle), 1, math.sin(angle)))
		end

		if i > 25 then
			for j = 1, numStars do
				newStars[j].Transparency = (i-25)/25
			end
		end

		wait(.1)
	end

end



local canDamage = false  -- only damage one person once until next attack
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
				canDamage = false
				tagHumanoid(humanoid, vPlayer)
				humanoid:TakeDamage(damage)

				co = coroutine.create(confuzzleHumanoid)
				coroutine.resume(co, humanoid)

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

	bang:Play()

	wait(.75)
	canDamage = true
	attack()
	wait(.75)
	attack()
	wait(.5)
	bang:Stop()
	wait(.25)
	canDamage = false
	wait(3)
	
	Tool.Enabled = true
end

script.Parent.Activated:connect(onActivated)
connection = sword.Touched:connect(blow)

