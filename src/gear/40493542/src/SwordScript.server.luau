-------- OMG HAX

r = game:service("RunService")
local sword = script.Parent.Handle
local Tool = script.Parent

local unEquipped = false

swordGo = Tool.swordGo
swordGo.Value = false

local damage = 5
local p = nil
local humanoid = nil

--local slash_damage = 12
local slash_damage = 20
local regularWalk = 23

local numSwings = 0

--local LungeSound = Instance.new("Sound")
--LungeSound.SoundId = "rbxasset://sounds\\swordlunge.wav"
--LungeSound.Parent = sword
--LungeSound.Volume = .6

local UnsheathSound = Instance.new("Sound")
UnsheathSound.SoundId = "rbxasset://sounds\\unsheath.wav"
UnsheathSound.Parent = sword
UnsheathSound.Volume = 1

-- magical sword sound has id of 25256253...  for fast slashes, like swordslash.wav (SlashSound)


function blow(hit)
	if hit == nil then return end
	if hit.Parent == nil then return end
	local humanoid = hit.Parent:findFirstChild("Humanoid")
	local vCharacter = Tool.Parent
	if vCharacter == nil or vCharacter.Name == "Backpack" then return end
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


local newLeaves = {}

function leafSpray()
-- spray leaves which rotate crazily and fall slowly
if #newLeaves > 0 then
	for i = 1, #newLeaves do if newLeaves[i] ~= nil then newLeaves[i].Parent = nil end end
end
newLeaves = {}
	for i = 1, 5 do
		whichLeaf = math.random(1,5)
		newLeaves[i] = Tool:FindFirstChild("Leaf"..tostring(whichLeaf)):Clone()

		-- fall slowly
		newBF = Instance.new("BodyForce")
		newBF.force = Vector3.new(0, newLeaves[i]:GetMass()*180, 0) -- 170 means 10 y-vel is good, 180 means 5 y-vel is good
		newBF.Name = "LeafFloat"
		newBF.Parent = newLeaves[i]
		newLeaves[i].Anchored = false

		-- leaves shoot out
		newLeaves[i].Velocity = Vector3.new(10*(math.random()-.5),5,10*(math.random()-.5))
		newLeaves[i].Position = Tool.Handle.Position
		newLeaves[i].Parent = game.Workspace
		newLeaves[i].Transparency = 0

		-- and rotate crazily  
		newLeaves[i].RotVelocity = Vector3.new((math.random()-.5)*100,0,(math.random()-.5)*100)

		-- and kill after 5 seconds
		newLeaves[i].LeafKill.Disabled = false
	end
	Tool.Leaf1.Mesh.VertexColor = Vector3.new(1, 1-numSwings/10, 1-numSwings/10)
	Tool.Leaf2.Mesh.VertexColor = Vector3.new(1, 1-numSwings/10, 1-numSwings/10)
	Tool.Leaf3.Mesh.VertexColor = Vector3.new(1, 1-numSwings/10, 1-numSwings/10)
	Tool.Leaf4.Mesh.VertexColor = Vector3.new(1, 1-numSwings/10, 1-numSwings/10)
	Tool.Leaf5.Mesh.VertexColor = Vector3.new(1, 1-numSwings/10, 1-numSwings/10)
end


function attack()
	numSwings = numSwings + 1
	if numSwings > 7 then numSwings = 7 end

	Tool.Handle.Mesh.VertexColor = Vector3.new(1, 1-numSwings/10, 1-numSwings/10)
	vCharacter = Tool.Parent
	damage = slash_damage*(1 - numSwings/8)
	wait(.5)

	SlashSound = sword:FindFirstChild("SlashSound")
	if SlashSound ~= nil then SlashSound:play() end

	wait(.25)
	leafSpray()

	--[[st = Instance.new("BodyVelocity")
	st.maxForce = Vector3.new(50000, 0, 50000)
	st.velocity = -50*vCharacter.Torso.CFrame:vectorToWorldSpace(Vector3.new(0,0,1))
	st.Name = "SwordThrust"
	st.Parent = vCharacter.Torso
	wait(.5)
	st.velocity = -50*vCharacter.Torso.CFrame:vectorToWorldSpace(Vector3.new(0,0,1))
	SlashSound = sword:FindFirstChild("SlashSound")
	if SlashSound ~= nil then SlashSound:play() end
	wait(.5)
	st = vCharacter.Torso:FindFirstChild("SwordThrust")
	if st ~= nil then st.Parent = nil end
	--local anim = Instance.new("StringValue")
	--anim.Name = "toolanim"
	--anim.Value = "Slash"
	--anim.Parent = Tool
	--]]

	wait(.25)
	SlashSound = sword:FindFirstChild("SlashSound")
	if SlashSound ~= nil then SlashSound:play() end

	wait(.25)
	leafSpray()
end

function swordUp()
	Tool.GripForward = Vector3.new(-1,0,0)
	Tool.GripRight = Vector3.new(0,1,0)
	Tool.GripUp = Vector3.new(0,0,1)
end

function swordOut()
	Tool.GripForward = Vector3.new(0,0,1)
	Tool.GripRight = Vector3.new(0,1,0)
	Tool.GripUp = Vector3.new(1,0,0)
end


Tool.Enabled = true
function onActivated()

	if not Tool.Enabled or not swordGo.Value then
		return
	end

	Tool.Enabled = false

	local character = Tool.Parent;
	local humanoid = character.Humanoid
	if humanoid == nil then
		print("Humanoid not found")
		return 
	end

	attack()

	wait(.5)
	Tool.Enabled = true
end


function swordWhirlAnimation()
	Tool.Handle.Transparency = 1
	
	if #newLeaves > 0 then
		for i = 1, #newLeaves do if newLeaves[i] ~= nil then newLeaves[i].Parent = nil end end
	end
	newLeaves = {}

	for i = 1, 20 do
		whichLeaf = math.random(1,5)
		newLeaves[i] = Tool:FindFirstChild("Leaf"..tostring(whichLeaf)):Clone()
		newLeaves[i].CFrame = CFrame.new(Tool.Handle.Position + Vector3.new((math.random()-.5)*200, (math.random())*50, (math.random()-.5)*200))
		newLeaves[i].Parent = game.Workspace
		newLeaves[i].Transparency = 0
		
		newBP = Instance.new("BodyPosition")
		newBP.Name = "LeafWhirlForce"
		newBP.position = Tool.Handle.Position + Vector3.new((math.random()-.5)*2, (i-10)*.2, (math.random()-.5)*2)
		newBP.P = 2000
		newBP.maxForce = Vector3.new(newBP.P, newBP.P, newBP.P)
		newBP.Parent = newLeaves[i]
		newLeaves[i].Anchored = false

		-- and rotate crazily  
		newLeaves[i].RotVelocity = Vector3.new((math.random()-.5)*100,0,(math.random()-.5)*100)

		-- and kill after 5 seconds
		--newLeaves[i].LeafKill.Disabled = false
	end

	while (unEquipped or newLeaves[10] == nil or ((newLeaves[10].Position - Tool.Handle.Position):Dot(newLeaves[10].Position - Tool.Handle.Position) > .1)) do
		if unEquipped or newLeaves[10] == nil then return end
		for j = 1, 20 do
			lwf = newLeaves[j]:FindFirstChild("LeafWhirlForce")
			if lwf ~= nil then
				if j ~= 10 then lwf.position = Tool.Handle.Position + Vector3.new((math.random()-.5)*2, (j-10)*.2, (math.random()-.5)*2)
				else lwf.position = Tool.Handle.Position + Vector3.new(0, (j-10)*.2, 0) end
				lwf.P = lwf.P + 100
				lwf.maxForce = Vector3.new(lwf.P, lwf.P, lwf.P)

				dist = (lwf.position-newLeaves[j].Position):Dot((lwf.position-newLeaves[j].Position))/50
				if (j > 5) then newLeaves[j].Mesh.VertexColor = Vector3.new(dist/(dist+1)+.3, dist/(dist+1)+.3, dist/(dist+1)+.3) end
			end
		end
		wait(.1)
	end

	Tool.Handle.Transparency = 0
	
	for i = 1, 20 do newLeaves[i].Parent = nil end
end


function onEquipped()
	unEquipped = false
	swordGo.Value = false
	numSwings = 0
	Tool.Handle.Mesh.VertexColor = Vector3.new(1,1,1)
	Tool.Leaf1.Mesh.VertexColor = Vector3.new(1,1,1)
	Tool.Leaf2.Mesh.VertexColor = Vector3.new(1,1,1)
	Tool.Leaf3.Mesh.VertexColor = Vector3.new(1,1,1)
	Tool.Leaf4.Mesh.VertexColor = Vector3.new(1,1,1)
	Tool.Leaf5.Mesh.VertexColor = Vector3.new(1,1,1)
	
	swordWhirlAnimation()

	if not unEquipped then
	
		SlashSound = sword:FindFirstChild("SlashSound")
		if SlashSound == nil then
			SlashSound = Instance.new("Sound")
			SlashSound.SoundId = "rbxasset://sounds\\swordslash.wav"
			SlashSound.Parent = sword
			SlashSound.Volume = .7
			SlashSound.Name = "SlashSound"
		end
	
		swordGo.Value = true
	
		UnsheathSound:play()

	end

end

function onUnequipped()
	unEquipped = true

	for i = 1, #newLeaves do
		newLeaves[i].Parent = nil
	end

	SlashSound = sword:FindFirstChild("SlashSound")
	if SlashSound ~= nil then
		SlashSound:Stop()
		SlashSound.Parent = nil
		SlashSound = nil
	end

	--[[torso = Tool.Parent:FindFirstChild("Torso")
	if torso == nil then return end
	st = torso:FindFirstChild("SwordThrust")
	if st ~= nil then st.Parent = nil end]]--
end	

script.Parent.Activated:connect(onActivated)
script.Parent.Equipped:connect(onEquipped)
script.Parent.Unequipped:connect(onUnequipped)

connection = sword.Touched:connect(blow)

