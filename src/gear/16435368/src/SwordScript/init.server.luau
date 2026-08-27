-------- OMG HAX
debris = game:GetService("Debris")
r = game:service("RunService")


local damage = 15


local slash_damage = 15


sword = script.Parent.Handle
Tool = script.Parent


local SlashSound = Instance.new("Sound")
SlashSound.SoundId = "rbxasset://sounds\\swordslash.wav"
SlashSound.Parent = sword
SlashSound.Volume = 1


local UnsheathSound = Instance.new("Sound")
UnsheathSound.SoundId = "rbxasset://sounds\\unsheath.wav"
UnsheathSound.Parent = sword
UnsheathSound.Volume = 1

local DustSound = Instance.new("Sound")
	DustSound.SoundId = "http://www.roblox.com/asset/?id=16433289"
	DustSound.Parent = sword
	DustSound.Volume = 1


function isTurbo(character)
	return character:FindFirstChild("RiddlingSkull") ~= nil
end
 

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
				if humanoid.Health > damage and humanoid.Health > 0 then
					tagHumanoid(humanoid, vPlayer)
					humanoid:TakeDamage(damage)
				else
					DarkKill(humanoid.Parent, humanoid, vPlayer, vCharacter)
				end
			end
		end


	end
end

function DarkKill(character, humanoid, attacker, vChar)

	if (character:FindFirstChild("ForceField") ~= nil) then return end

	DustSound:Play()

	local childs = character:GetChildren()

	local colors = {}

	tagHumanoid(humanoid, attacker)
	humanoid.Health = 0

	for i=1,#childs do
		if (childs[i].className == "Part") then
			colors[i] = childs[i].BrickColor
			childs[i].BrickColor = BrickColor.new(26)
			childs[i].CanCollide = true
			childs[i].Anchored = true
		end
		if (childs[i].Name == "Head") then
			local m = childs[i]:FindFirstChild("Mesh")
			if (m ~= nil) then
				m:Remove()
			end
			script.SkullMesh:Clone().Parent = childs[i]
			childs[i].Anchored = false
		end
	end

	wait(.25)
	local limit = 1
	if (isTurbo(vChar) == true) then limit = 3 end

	for i=1,#childs do
		if (childs[i].className == "Part" and childs[i].Name ~= "Head") then
			for n=0,limit do
				local p = Instance.new("Part")
				p.formFactor = 2
				p.Size = Vector3.new(1,.4,1)
				p.BrickColor = BrickColor.new(26)
				p.Material = Enum.Material.Concrete
				p.TopSurface = 0
				p.BottomSurface = 0
				p.CFrame = childs[i].CFrame + Vector3.new(0,n,0)
				childs[i]:Remove()
				p.Parent = game.Workspace
				debris:AddItem(p, 60)
			end
		end
	end


end


function tagHumanoid(humanoid, player)
	local creator_tag = Instance.new("ObjectValue")
	creator_tag.Value = player
	creator_tag.Name = "creator"
	creator_tag.Parent = humanoid
	debris:AddItem(creator_tag, 1)
end


function attack()
	damage = slash_damage
	SlashSound:play()
	local anim = Instance.new("StringValue")
	anim.Name = "toolanim"
	anim.Value = "Slash"
	anim.Parent = Tool
end


function swordUp()
	Tool.GripForward = Vector3.new(-1,0,0)
	Tool.GripRight = Vector3.new(0,1,0)
	Tool.GripUp = Vector3.new(0,0,1)
end

function swordOut()
	Tool.GripForward = Vector3.new(0,0,1)
	Tool.GripRight = Vector3.new(0,-1,0)
	Tool.GripUp = Vector3.new(-1,0,0)
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

	if (isTurbo(character) == true) then
		slash_damage = 20
	else
		slash_damage = 15
	end
	

	attack()

	wait(1)

	Tool.Enabled = true
end


function onEquipped()
	UnsheathSound:play()
end


script.Parent.Activated:connect(onActivated)
script.Parent.Equipped:connect(onEquipped)


connection = sword.Touched:connect(blow)


