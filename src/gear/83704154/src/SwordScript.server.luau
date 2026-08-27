local tool = script.Parent
local handle = tool.Handle

tool.Enabled = true

local damage = 15
local TorsoDmg = 80

local slashSound = Instance.new("Sound")
slashSound.SoundId = "rbxasset://sounds\\swordaxe.wav"
slashSound.Volume = 0.7
slashSound.Parent = tool

local vCharacter 


function Color(r, g, b)
	return Color3.new(r/255, g/255, b/255)
end


function flames(pos)
	local vCharacter = tool.Parent
	local myHumanoid = vCharacter:FindFirstChild("Humanoid")		
	local myTorso = vCharacter:FindFirstChild("Torso")

	local look = myTorso.CFrame.lookVector
	
	local firetable = {}
	local j = 1
	for i = 0, 50, 5 do
		local firepart = Instance.new("Part")
		firepart.Size = Vector3.new(4,4,4)
		firepart.Position = myTorso.Position + look*i
		firepart.Transparency = 1
		firepart.Anchored = true
		firepart.CanCollide = false
		firepart.Parent = game.Workspace
		firepart.Touched:connect(function(hit)
			local eHumanoid = hit.Parent:FindFirstChild("Humanoid")
			local vCharacter = tool.Parent
			local myHumanoid = vCharacter:FindFirstChild("Humanoid")
			if eHumanoid ~= nil and eHumanoid ~= myHumanoid then
				tagHumanoid(ehumanoid, vPlayer)
				eHumanoid:TakeDamage(15)
				wait(1.0)
				untagHumanoid(eHumanoid)
			end
		end)
		local fire = Instance.new("Fire")
		fire.Color = Color(0,153,255)
		fire.Size = (5*i)/10
		fire.Parent = firepart
		firetable[j] = firepart
		j = j +1 
		wait(0.05)
	end

	
	for i = 1, #firetable do
		firetable[i]:Remove()
		wait(0.05)
	end


	
	
	j = 1
end
	

function blow(hit)
	eHumanoid = hit.Parent:FindFirstChild("Humanoid")
	vCharacter = tool.Parent
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)
	if eHumanoid ~= nil and myHumanoid ~= nil and eHumanoid ~= myHumanoid then
		rightArm = vCharacter:FindFirstChild("Right Arm")
		if rightArm ~= nil then
			rightGrip = rightArm:FindFirstChild("RightGrip")
			if rightGrip ~= nil and (rightGrip.Part0 == handle or rightGrip.Part1 == handle) then
				tagHumanoid(ehumanoid, vPlayer)
				if hit.Name == "Torso" then 
					damage = TorsoDmg 
				end
				eHumanoid:TakeDamage(damage)
				wait(1.0)
				untagHumanoid(ehumanoid)
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
	end
end

function untagHumanoid(humanoid)
	if humanoid ~= nil then 
		tag = humanoid:FindFirstChild("creator")
		if tag ~= nil then tag:Remove() end
	end
end

function onActivated()
	if tool.Enabled == false then 
			return
	end
	
	tool.Enabled = false 
		
	vCharacter = tool.Parent
	myHumanoid = vCharacter:FindFirstChild("Humanoid")		
	myTorso = vCharacter:FindFirstChild("Torso")
	if myHumanoid == nil then 
		return
	end
	local look = myTorso.CFrame.lookVector
	flames(myTorso.Position + look*10)

	damage = 15
	if slashSound then slashSound:Play() end
	wait(.5)
	tool.Enabled = true
end

local currentHat 
local cloudHat

function onEquipped()
	vCharacter = tool.Parent
	print(vCharacter)
	for i, v in ipairs(vCharacter:GetChildren()) do
		if v.ClassName == "Hat" or v.ClassName == "Accoutrement" then
			currentHat = v
			--v:Remove()
			v.Handle.Transparency = 1
			currentHat.Handle.Transparency = 1
		end
	end
	local cloud = game:GetService("InsertService"):LoadAsset(73790841):GetChildren()[1]
	cloudHat = cloud
	cloudHat.Parent = vCharacter
	
end

function onUnequipped()
	if slashSound then slashSound:Stop() end
	
	cloudHat:Remove()
	if currentHat ~= nil then
		currentHat.Handle.Transparency  = 0
	end
end

tool.Activated:connect(onActivated)
tool.Equipped:connect(onEquipped)
tool.Unequipped:connect(onUnequipped)

handle.Touched:connect(blow)