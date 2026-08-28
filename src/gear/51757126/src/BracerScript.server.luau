local Tool = script.Parent
local Bracer = Tool.Handle

Tool.Enabled = true

local leftBracer

local vCharacter

local damage = 20 

local connection

function tagHumanoid(humanoid, player) 
  if humanoid then 
	 creatorTag = Instance.new("ObjectValue") 
	 creatorTag.Value = player 
	 creatorTag.Name = "creator" 
	 creatorTag.Parent = humanoid 
  end 
end 

function untagHumanoid(humanoid) 
  if humanoid then 
	 tag = humanoid:FindFirstChild("creator") 
	 if tag then tag:Remove() end 
  end 
end 


function blow(hit) 
  humanoid = hit.Parent:FindFirstChild("Humanoid") 
  vCharacter = Tool.Parent 
  myHumanoid = vCharacter:FindFirstChild("Humanoid") 
  vPlayer = game.Players:GetPlayerFromCharacter(vCharacter) 
  if humanoid ~= nil and humanoid ~= myHumanoid and myHumanoid ~= nil then 
	 rightArm = vCharacter:FindFirstChild("Right Arm") 
	 if rightArm then 
		rightGrip = rightArm:FindFirstChild("RightGrip") 
		if rightGrip and (rightGrip.Part0 == Bracer or rightGrip.Part1 == Bracer) then 
		  tagHumanoid(humanoid, vPlayer) 
		  humanoid:TakeDamage(damage) 
		  wait(1.0) 
		  untagHumanoid(humanoid) 
		end 
	 end 
  end 
end 

function blow2(hit) 
  humanoid = hit.Parent:FindFirstChild("Humanoid") 
  vCharacter = Tool.Parent 
  myHumanoid = vCharacter:FindFirstChild("Humanoid") 
  vPlayer = game.Players:GetPlayerFromCharacter(vCharacter) 
  if humanoid ~= nil and humanoid ~= myHumanoid and myHumanoid ~= nil then 
	 leftArm = vCharacter:FindFirstChild("Left Arm") 
	 if leftArm then 
		leftGrip = leftArm:FindFirstChild("LeftGrip") 
		if leftGrip and (leftGrip.Part0 == leftBracer or leftGrip.Part1 == leftBracer) then 
		  tagHumanoid(humanoid, vPlayer) 
		  humanoid:TakeDamage(damage) 
		  wait(1.0) 
		  untagHumanoid(humanoid) 
		end 
	 end 
  end 
end 

function onActivated()
	if Tool.Enabled == false then 
		return
	end

	Tool.Enabled = false

	wait(1.25)
	Tool.Enabled = true
end

function onEquipped()
	vCharacter = Tool.Parent
	leftArm = vCharacter:FindFirstChild("Left Arm")
	children = vCharacter:GetChildren()
	if leftArm then 
		bracer = vCharacter:FindFirstChild("Bracer")
		if bracer == nil then
			leftBracer = Bracer:Clone()
			leftBracer.Name = "Bracer"
			leftBracer.Parent = vCharacter
			
			leftGrip = Instance.new("Weld")
			leftGrip.Parent = leftArm
			leftGrip.Part0 = leftArm
			leftGrip.Part1 =  bracer
			leftGrip.C1 = CFrame.new(Vector3.new(-0.2, 0, 0)) * CFrame.Angles(math.pi/2, math.pi, 0)
			leftGrip.Name = "LeftGrip"
	
			connection = leftBracer.Touched:connect(blow2)
		end
	end

	for i = 1, #children do 
		print("Found Children")
		if children[i].className == "CharacterMesh" and children[i].BodyPart == Enum.BodyPart.RightArm  then 				
			Bracer.Mesh.Scale = Vector3.new(0.7, 0.8, 1.1)	
		elseif children[i].className == "CharacterMesh" and children[i].BodyPart == Enum.BodyPart.LeftArm then 
			leftBracer.Mesh.Scale = Vector3.new(0.7, 0.8, 1.1)
		end			
	end

	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	if myHumanoid then 
		myHumanoid.WalkSpeed = 20.0
	end
end

function onUnequipped()
	if vCharacter then 
		leftArm = vCharacter:findFirstChild("Left Arm")
		myHumanoid = vCharacter:FindFirstChild("Humanoid")
		if leftArm then 
			leftGrip = leftArm:FindFirstChild("LeftGrip")
			leftBracer = vCharacter:FindFirstChild("Bracer")
			if leftGrip then leftGrip:Remove() end
			if leftBracer then leftBracer:Remove() end
		end
	end
	if connection then connection:disconnect() end
	if myHumanoid then myHumanoid.WalkSpeed = 16 end

	if Bracer then Bracer.Mesh.Scale = Vector3.new(1.1, 1.1, 1.1) end
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)

Bracer.Touched:connect(blow)

if leftBracer then leftBracer.Touched:connect(blow2) end
